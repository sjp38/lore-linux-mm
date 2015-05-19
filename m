Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3950C6B00AB
	for <linux-mm@kvack.org>; Tue, 19 May 2015 09:00:53 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so16973217wgb.3
        for <linux-mm@kvack.org>; Tue, 19 May 2015 06:00:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id on7si18263339wic.76.2015.05.19.06.00.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 06:00:51 -0700 (PDT)
Message-ID: <555B3400.7030201@suse.cz>
Date: Tue, 19 May 2015 15:00:48 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 04/28] mm, thp: adjust conditions when we can reuse
 the page on WP fault
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-5-git-send-email-kirill.shutemov@linux.intel.com> <5555B914.8050800@suse.cz> <20150515112113.GD6250@node.dhcp.inet.fi> <5555DA15.10903@suse.cz> <20150515132911.GA6625@node.dhcp.inet.fi>
In-Reply-To: <20150515132911.GA6625@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/15/2015 03:29 PM, Kirill A. Shutemov wrote:
> On Fri, May 15, 2015 at 01:35:49PM +0200, Vlastimil Babka wrote:
>> On 05/15/2015 01:21 PM, Kirill A. Shutemov wrote:
>>> On Fri, May 15, 2015 at 11:15:00AM +0200, Vlastimil Babka wrote:
>>>> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
>>>>> With new refcounting we will be able map the same compound page with
>>>>> PTEs and PMDs. It requires adjustment to conditions when we can reuse
>>>>> the page on write-protection fault.
>>>>>
>>>>> For PTE fault we can't reuse the page if it's part of huge page.
>>>>>
>>>>> For PMD we can only reuse the page if nobody else maps the huge page or
>>>>> it's part. We can do it by checking page_mapcount() on each sub-page,
>>>>> but it's expensive.
>>>>>
>>>>> The cheaper way is to check page_count() to be equal 1: every mapcount
>>>>> takes page reference, so this way we can guarantee, that the PMD is the
>>>>> only mapping.
>>>>>
>>>>> This approach can give false negative if somebody pinned the page, but
>>>>> that doesn't affect correctness.
>>>>>
>>>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>>>> Tested-by: Sasha Levin <sasha.levin@oracle.com>
>>>>
>>>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>>>>
>>>> So couldn't the same trick be used in Patch 1 to avoid counting individual
>>>> oder-0 pages?
>>>
>>> Hm. You're right, we could. But is smaps that performance sensitive to
>>> bother?
>>
>> Well, I was nudged to optimize it when doing the shmem swap accounting
>> changes there :) User may not care about the latency of obtaining the smaps
>> file contents, but since it has mmap_sem locked for that, the process might
>> care...
>
> Somewthing like this?

Yeah, that should work.

>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index e04399e53965..5bc3d2b1176e 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -462,6 +462,19 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>          if (young || PageReferenced(page))
>                  mss->referenced += size;
>
> +       /*
> +        * page_count(page) == 1 guarantees the page is mapped exactly once.
> +        * If any subpage of the compound page mapped with PTE it would elevate
> +        * page_count().
> +        */
> +       if (page_count(page) == 1) {
> +               if (dirty || PageDirty(page))
> +                       mss->private_dirty += size;
> +               else
> +                       mss->private_clean += size;
> +               return;
> +       }
> +
>          for (i = 0; i < nr; i++, page++) {
>                  int mapcount = page_mapcount(page);
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
