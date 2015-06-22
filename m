Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id F2DAA6B0070
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 12:01:40 -0400 (EDT)
Received: by lacny3 with SMTP id ny3so112722205lac.3
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 09:01:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j18si35700391wjn.172.2015.06.22.09.01.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Jun 2015 09:01:38 -0700 (PDT)
Message-ID: <5588315D.5070804@suse.cz>
Date: Mon, 22 Jun 2015 18:01:33 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv6 29/36] thp: implement split_huge_pmd()
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <1433351167-125878-30-git-send-email-kirill.shutemov@linux.intel.com> <557959BC.5000303@suse.cz> <20150622111434.GC7934@node.dhcp.inet.fi>
In-Reply-To: <20150622111434.GC7934@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/22/2015 01:14 PM, Kirill A. Shutemov wrote:
> On Thu, Jun 11, 2015 at 11:49:48AM +0200, Vlastimil Babka wrote:
>> On 06/03/2015 07:06 PM, Kirill A. Shutemov wrote:
>>
>> The order of actions here means that between TestSetPageDoubleMap() and the
>> atomic incs, anyone calling page_mapcount() on one of the pages not
>> processed by the for loop yet, will see a value lower by 1 from what he
>> should see. I wonder if that can cause any trouble somewhere, especially if
>> there's only one other compound mapping and page_mapcount() will return 0
>> instead of 1?
>
> Good catch. Thanks.
>
> What about this?
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 0f1f5731a893..cd0e6addb662 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2636,15 +2636,25 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>                          for (i = 0; i < HPAGE_PMD_NR; i++)
>                                  atomic_dec(&page[i]._mapcount);
>                  }
> -       } else if (!TestSetPageDoubleMap(page)) {
> +       } else if (!PageDoubleMap(page)) {
>                  /*
>                   * The first PMD split for the compound page and we still
>                   * have other PMD mapping of the page: bump _mapcount in
>                   * every small page.
> +                *
>                   * This reference will go away with last compound_mapcount.
> +                *
> +                * Note, we need to increment mapcounts before setting
> +                * PG_double_map to avoid false-negative page_mapped().
>                   */
>                  for (i = 0; i < HPAGE_PMD_NR; i++)
>                          atomic_inc(&page[i]._mapcount);
> +
> +               if (TestSetPageDoubleMap(page)) {
> +                       /* Race with another  __split_huge_pmd() for the page */
> +                       for (i = 0; i < HPAGE_PMD_NR; i++)
> +                               atomic_dec(&page[i]._mapcount);
> +               }
>          }

Yeah that should work.

>          smp_wmb(); /* make pte visible before pmd */



>
>> Conversely, when clearing PageDoubleMap() above (or in one of those rmap
>> functions IIRC), one could see mapcount inflated by one. But I guess that's
>> less dangerous.
>
> I think it's safe.

OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
