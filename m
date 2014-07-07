Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5006B003A
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 06:42:05 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id l4so2719293lbv.14
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 03:42:05 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.231])
        by mx.google.com with ESMTP id ev11si20990239lac.25.2014.07.07.03.42.04
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 03:42:04 -0700 (PDT)
Date: Mon, 7 Jul 2014 13:41:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v10 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20140707104137.GA23150@node.dhcp.inet.fi>
References: <1404694438-10272-1-git-send-email-minchan@kernel.org>
 <1404694438-10272-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404694438-10272-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Jul 07, 2014 at 09:53:52AM +0900, Minchan Kim wrote:
> Linux doesn't have an ability to free pages lazy while other OS
> already have been supported that named by madvise(MADV_FREE).
> 
> The gain is clear that kernel can discard freed pages rather than
> swapping out or OOM if memory pressure happens.
> 
> Without memory pressure, freed pages would be reused by userspace
> without another additional overhead(ex, page fault + allocation
> + zeroing).
> 
> How to work is following as.
> 
> When madvise syscall is called, VM clears dirty bit of ptes of
> the range. If memory pressure happens, VM checks dirty bit of
> page table and if it found still "clean", it means it's a
> "lazyfree pages" so VM could discard the page instead of swapping out.
> Once there was store operation for the page before VM peek a page
> to reclaim, dirty bit is set so VM can swap out the page instead of
> discarding.
> 
> Firstly, heavy users would be general allocators(ex, jemalloc,
> tcmalloc and hope glibc supports it) and jemalloc/tcmalloc already
> have supported the feature for other OS(ex, FreeBSD)
> 
> barrios@blaptop:~/benchmark/ebizzy$ lscpu
> Architecture:          x86_64
> CPU op-mode(s):        32-bit, 64-bit
> Byte Order:            Little Endian
> CPU(s):                4
> On-line CPU(s) list:   0-3
> Thread(s) per core:    2
> Core(s) per socket:    2
> Socket(s):             1
> NUMA node(s):          1
> Vendor ID:             GenuineIntel
> CPU family:            6
> Model:                 42
> Stepping:              7
> CPU MHz:               2801.000
> BogoMIPS:              5581.64
> Virtualization:        VT-x
> L1d cache:             32K
> L1i cache:             32K
> L2 cache:              256K
> L3 cache:              4096K
> NUMA node0 CPU(s):     0-3
> 
> ebizzy benchmark(./ebizzy -S 10 -n 512)
> 
>  vanilla-jemalloc		MADV_free-jemalloc
> 
> 1 thread
> records:  10              records:  10
> avg:      7682.10         avg:      15306.10
> std:      62.35(0.81%)    std:      347.99(2.27%)
> max:      7770.00         max:      15622.00
> min:      7598.00         min:      14772.00
> 
> 2 thread
> records:  10              records:  10
> avg:      12747.50        avg:      24171.00
> std:      792.06(6.21%)   std:      895.18(3.70%)
> max:      13337.00        max:      26023.00
> min:      10535.00        min:      23152.00
> 
> 4 thread
> records:  10              records:  10
> avg:      16474.60        avg:      33717.90
> std:      1496.45(9.08%)  std:      2008.97(5.96%)
> max:      17877.00        max:      35958.00
> min:      12224.00        min:      29565.00
> 
> 8 thread
> records:  10              records:  10
> avg:      16778.50        avg:      33308.10
> std:      825.53(4.92%)   std:      1668.30(5.01%)
> max:      17543.00        max:      36010.00
> min:      14576.00        min:      29577.00
> 
> 16 thread
> records:  10              records:  10
> avg:      20614.40        avg:      35516.30
> std:      602.95(2.92%)   std:      1283.65(3.61%)
> max:      21753.00        max:      37178.00
> min:      19605.00        min:      33217.00
> 
> 32 thread
> records:  10              records:  10
> avg:      22771.70        avg:      36018.50
> std:      598.94(2.63%)   std:      1046.76(2.91%)
> max:      24035.00        max:      37266.00
> min:      22108.00        min:      34149.00
> 
> In summary, MADV_FREE is about 2 time faster than MADV_DONTNEED.
> 
> Cc: Michael Kerrisk <mtk.manpages@gmail.com>
> Cc: Linux API <linux-api@vger.kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Jason Evans <je@fb.com>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---

...

> +static void madvise_free_page_range(struct mmu_gather *tlb,
> +			     struct vm_area_struct *vma,
> +			     unsigned long addr, unsigned long end)
> +{
> +	pgd_t *pgd;
> +	unsigned long next;
> +
> +	BUG_ON(addr >= end);
> +	tlb_start_vma(tlb, vma);
> +	pgd = pgd_offset(vma->vm_mm, addr);
> +	do {
> +		next = pgd_addr_end(addr, end);
> +		if (pgd_none_or_clear_bad(pgd))
> +			continue;
> +		next = madvise_free_pud_range(tlb, vma, pgd, addr, next);
> +	} while (pgd++, addr = next, addr != end);
> +	tlb_end_vma(tlb, vma);

Any particular reason why pagewalker can't be used here?

> +}

...

> @@ -381,6 +547,13 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
>  		return madvise_remove(vma, prev, start, end);
>  	case MADV_WILLNEED:
>  		return madvise_willneed(vma, prev, start, end);
> +	case MADV_FREE:
> +		/*
> +		 * XXX: In this implementation, MADV_FREE works like
> +		 * MADV_DONTNEED on swapless system or full swap.
> +		 */
> +		if (get_nr_swap_pages() > 0)
> +			return madvise_free(vma, prev, start, end);

Looks racy wrt to full swap. What will happen if we will do madvise_free()
on full swap?

>  	case MADV_DONTNEED:
>  		return madvise_dontneed(vma, prev, start, end);
>  	default:

...

> @@ -1204,6 +1223,16 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			}
>  			dec_mm_counter(mm, MM_ANONPAGES);
>  			inc_mm_counter(mm, MM_SWAPENTS);
> +		} else if (flags & TTU_UNMAP) {
> +			if (dirty || PageDirty(page)) {
> +				set_pte_at(mm, address, pte, pteval);
> +				ret = SWAP_FAIL;
> +				goto out_unmap;

I don't get this part.
Looks like it will fail to unmap the page if it's dirty and not backed by
swapcache. Current code doesn't have such limitation.
Do we really need this?

> +			} else {
> +				/* It's a freeable page by madvise_free */
> +				dec_mm_counter(mm, MM_ANONPAGES);
> +				goto discard;
> +			}
>  		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
>  			/*
>  			 * Store the pfn of the page in a special migration

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
