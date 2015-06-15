Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4CF6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 02:35:45 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so1257226qkh.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 23:35:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z92si11850109qgd.1.2015.06.14.23.35.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 23:35:44 -0700 (PDT)
Message-ID: <557E7235.1090105@redhat.com>
Date: Mon, 15 Jun 2015 02:35:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/3] mm: make optimistic check for swapin readahead
References: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com> <1434294283-8699-3-git-send-email-ebru.akagunduz@gmail.com> <CALq1K=JzAWt2NUB8SOitBcXeegFTA5OOUm7NsxE3RGTzkuWfuA@mail.gmail.com> <557E65E7.9010000@redhat.com> <CALq1K=LZvnfj2T2i3BrUK7uuYVLJDc=-0=K4ov0f+8QMeEt=og@mail.gmail.com>
In-Reply-To: <CALq1K=LZvnfj2T2i3BrUK7uuYVLJDc=-0=K4ov0f+8QMeEt=og@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi <n-horiguchi@ah.jp.nec.com>, aarcange <aarcange@redhat.com>, "iamjoonsoo.kim" <iamjoonsoo.kim@lge.com>, Xiexiuqi <xiexiuqi@huawei.com>, gorcunov <gorcunov@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, "aneesh.kumar" <aneesh.kumar@linux.vnet.ibm.com>, hughd <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, mhocko <mhocko@suse.cz>, boaz <boaz@plexistor.com>, raindel <raindel@mellanox.com>

On 06/15/2015 02:08 AM, Leon Romanovsky wrote:
> On Mon, Jun 15, 2015 at 8:43 AM, Rik van Riel <riel@redhat.com> wrote:
>> On 06/15/2015 01:40 AM, Leon Romanovsky wrote:
>>> On Sun, Jun 14, 2015 at 6:04 PM, Ebru Akagunduz
>>> <ebru.akagunduz@gmail.com> wrote:
>>>> This patch makes optimistic check for swapin readahead
>>>> to increase thp collapse rate. Before getting swapped
>>>> out pages to memory, checks them and allows up to a
>>>> certain number. It also prints out using tracepoints
>>>> amount of unmapped ptes.
>>>>
>>>> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
>>
>>>> @@ -2639,11 +2640,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>>>>  {
>>>>         pmd_t *pmd;
>>>>         pte_t *pte, *_pte;
>>>> -       int ret = 0, none_or_zero = 0;
>>>> +       int ret = 0, none_or_zero = 0, unmapped = 0;
>>>>         struct page *page;
>>>>         unsigned long _address;
>>>>         spinlock_t *ptl;
>>>> -       int node = NUMA_NO_NODE;
>>>> +       int node = NUMA_NO_NODE, max_ptes_swap = HPAGE_PMD_NR/8;
>>> Sorry for asking, my knoweldge of THP is very limited, but why did you
>>> choose this default value?
>>> From the discussion followed by your patch
>>> (https://lkml.org/lkml/2015/2/27/432), I got an impression that it is
>>> not necessary right value.
>>
>> I believe that Ebru's main focus for this initial version of
>> the patch series was to get the _mechanism_ (patch 3) right,
>> while having a fairly simple policy to drive it.
>>
>> Any suggestions on when it is a good idea to bring in pages
>> from swap, and whether to treat resident-in-swap-cache pages
>> differently from need-to-be-paged-in pages, and what other
>> factors should be examined, are very welcome...
> My concern with these patches that they deal with specific
> load/scenario (most of the application returned back from swap). In
> scenario there only 10% of data will be required, it theoretically can
> bring upto 80% data (70% waste).

The chosen threshold ensures that the remaining non-resident
4kB pages in a THP are only brought in if 7/8th (or 87.5%) of
the pages are already resident.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
