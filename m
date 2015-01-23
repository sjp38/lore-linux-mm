Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 434AF6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 06:37:11 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id l15so2171591wiw.4
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 03:37:10 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id hu10si2537401wjb.53.2015.01.23.03.37.09
        for <linux-mm@kvack.org>;
        Fri, 23 Jan 2015 03:37:09 -0800 (PST)
Date: Fri, 23 Jan 2015 13:37:01 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: incorporate read-only pages into transparent huge
 pages
Message-ID: <20150123113701.GB5975@node.dhcp.inet.fi>
References: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com

On Fri, Jan 23, 2015 at 09:47:36AM +0200, Ebru Akagunduz wrote:
> This patch aims to improve THP collapse rates, by allowing
> THP collapse in the presence of read-only ptes, like those
> left in place by do_swap_page after a read fault.
> 
> Currently THP can collapse 4kB pages into a THP when
> there are up to khugepaged_max_ptes_none pte_none ptes
> in a 2MB range. This patch applies the same limit for
> read-only ptes.
> 
> The patch was tested with a test program that allocates
> 800MB of memory, writes to it, and then sleeps. I force
> the system to swap out all but 190MB of the program by
> touching other memory. Afterwards, the test program does
> a mix of reads and writes to its memory, and the memory
> gets swapped back in.
> 
> Without the patch, only the memory that did not get
> swapped out remained in THPs, which corresponds to 24% of
> the memory of the program. The percentage did not increase
> over time.
> 
> With this patch, after 5 minutes of waiting khugepaged had
> collapsed 55% of the program's memory back into THPs.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> ---
> I've written down test results:
> 
> With the patch:
> After swapped out:
> cat /proc/pid/smaps:
> Anonymous:      100352 kB
> AnonHugePages:  98304 kB
> Swap:           699652 kB
> Fraction:       97,95
> 
> cat /proc/meminfo:
> AnonPages:      1763732 kB
> AnonHugePages:  1716224 kB
> Fraction:       97,30
> 
> After swapped in:
> In a few seconds:
> cat /proc/pid/smaps
> Anonymous:      800004 kB
> AnonHugePages:  235520 kB
> Swap:           0 kB
> Fraction:       29,43
> 
> cat /proc/meminfo:
> AnonPages:      2464336 kB
> AnonHugePages:  1853440 kB
> Fraction:       75,21
> 
> In five minutes:
> cat /proc/pid/smaps:
> Anonymous:      800004 kB
> AnonHugePages:  440320 kB
> Swap:           0 kB
> Fraction:       55,0
> 
> cat /proc/meminfo:
> AnonPages:      2464340
> AnonHugePages:  2058240
> Fraction:       83,52
> 
> Without the patch:
> After swapped out:
> cat /proc/pid/smaps:
> Anonymous:      190660 kB
> AnonHugePages:  190464 kB
> Swap:           609344 kB
> Fraction:       99,89
> 
> cat /proc/meminfo:
> AnonPages:      1740456 kB
> AnonHugePages:  1667072 kB
> Fraction:       95,78
> 
> After swapped in:
> cat /proc/pid/smaps:
> Anonymous:      800004 kB
> AnonHugePages:  190464 kB
> Swap:           0 kB
> Fraction:       23,80
> 
> cat /proc/meminfo:
> AnonPages:      2350032 kB
> AnonHugePages:  1667072 kB
> Fraction:       70,93
> 
> I waited 10 minutes the fractions
> did not change without the patch.
> 
>  mm/huge_memory.c | 25 ++++++++++++++++++++-----
>  1 file changed, 20 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 817a875..af750d9 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2158,7 +2158,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  			else
>  				goto out;
>  		}
> -		if (!pte_present(pteval) || !pte_write(pteval))
> +		if (!pte_present(pteval))
>  			goto out;
>  		page = vm_normal_page(vma, address, pteval);
>  		if (unlikely(!page))
> @@ -2169,7 +2169,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
>  
>  		/* cannot use mapcount: can't collapse if there's a gup pin */
> -		if (page_count(page) != 1)
> +		if (page_count(page) != 1 + !!PageSwapCache(page))
>  			goto out;
>  		/*
>  		 * We can do it before isolate_lru_page because the
> @@ -2179,6 +2179,17 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>  		 */
>  		if (!trylock_page(page))
>  			goto out;
> +		if (!pte_write(pteval)) {
> +			if (PageSwapCache(page) && !reuse_swap_page(page)) {
> +					unlock_page(page);
> +					goto out;
> +			}
> +			/*
> +			 * Page is not in the swap cache, and page count is
> +			 * one (see above). It can be collapsed into a THP.
> +			 */
> +		}

Hm. As a side effect it will effectevely allow collapse in PROT_READ vmas,
right? I'm not convinced it's a good idea.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
