Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E911A6B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 10:16:33 -0400 (EDT)
Date: Mon, 9 Mar 2009 14:16:28 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC PATCH 1/2] mm: tlb: Add range to tlb_start_vma() and
 tlb_end_vma()
In-Reply-To: <1236603597-1646-1-git-send-email-Aaro.Koskinen@nokia.com>
Message-ID: <Pine.LNX.4.64.0903091352430.28665@blonde.anvils>
References: <49B511E9.8030405@nokia.com> <1236603597-1646-1-git-send-email-Aaro.Koskinen@nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Aaro Koskinen <Aaro.Koskinen@nokia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Mar 2009, Aaro Koskinen wrote:

> Pass the range to be teared down with tlb_start_vma() and
> tlb_end_vma(). This allows architectures doing per-VMA handling to flush
> only the needed range instead of the full VMA region.
> 
> This patch changes the interface only, no changes in functionality.
> 
> Signed-off-by: Aaro Koskinen <Aaro.Koskinen@nokia.com>
> ---
>  arch/alpha/include/asm/tlb.h    |    4 ++--
>  arch/arm/include/asm/tlb.h      |    6 ++++--
>  arch/avr32/include/asm/tlb.h    |    4 ++--
>  arch/blackfin/include/asm/tlb.h |    4 ++--
>  arch/cris/include/asm/tlb.h     |    4 ++--
>  arch/ia64/include/asm/tlb.h     |    8 ++++----
>  arch/m68k/include/asm/tlb.h     |    4 ++--
>  arch/mips/include/asm/tlb.h     |    4 ++--
>  arch/parisc/include/asm/tlb.h   |    4 ++--
>  arch/powerpc/include/asm/tlb.h  |    4 ++--
>  arch/s390/include/asm/tlb.h     |    4 ++--
>  arch/sh/include/asm/tlb.h       |    4 ++--
>  arch/sparc/include/asm/tlb_32.h |    4 ++--
>  arch/sparc/include/asm/tlb_64.h |    4 ++--
>  arch/um/include/asm/tlb.h       |    4 ++--
>  arch/x86/include/asm/tlb.h      |    4 ++--
>  arch/xtensa/include/asm/tlb.h   |    8 ++++----
>  include/asm-frv/tlb.h           |    4 ++--
>  include/asm-m32r/tlb.h          |    4 ++--
>  include/asm-mn10300/tlb.h       |    4 ++--
>  mm/memory.c                     |   10 +++++++---
>  21 files changed, 53 insertions(+), 47 deletions(-)
...
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -896,17 +896,21 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
>  
>  static unsigned long unmap_page_range(struct mmu_gather *tlb,
>  				struct vm_area_struct *vma,
> -				unsigned long addr, unsigned long end,
> +				unsigned long range_start, unsigned long end,
>  				long *zap_work, struct zap_details *details)
>  {
>  	pgd_t *pgd;
>  	unsigned long next;
> +	unsigned long addr = range_start;
> +	unsigned long range_end;
>  
>  	if (details && !details->check_mapping && !details->nonlinear_vma)
>  		details = NULL;
>  
>  	BUG_ON(addr >= end);
> -	tlb_start_vma(tlb, vma);
> +	BUG_ON(*zap_work <= 0);
> +	range_end = addr + min(end - addr, (unsigned long)*zap_work);
> +	tlb_start_vma(tlb, vma, range_start, range_end);
>  	pgd = pgd_offset(vma->vm_mm, addr);
>  	do {
>  		next = pgd_addr_end(addr, end);
> @@ -917,7 +921,7 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
>  		next = zap_pud_range(tlb, vma, pgd, addr, next,
>  						zap_work, details);
>  	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
> -	tlb_end_vma(tlb, vma);
> +	tlb_end_vma(tlb, vma, range_start, range_end);
>  
>  	return addr;
>  }
> -- 

Sorry, I don't like this second-guessing of zap_work at all (okay,
we all hate zap_work, and would love to rework the tlb mmu_gather
stuff to be preemptible, but the file truncation case has so far
discouraged us).

Take a look at the levels below, in particular zap_pte_range(),
and you'll see that zap_work is just an approximate cap upon the
amount of work being done while zapping, and is decremented by
wildly different amounts if a pte (or swap entry) is there or not.

So the range_end you calculate will usually be misleadingly
different from the actual end of the range.

I don't see that you need to change the interface and other arches
at all.  What prevents ARM from noting the first and last addresses
freed in its struct mmu_gather when tlb_remove_tlb_entry() is called
(see arch/um/include/asm/tlb.h for an example of that), then using
that in its tlb_end_vma() TLB flushing?

Admittedly you won't know the end for cache flusing in tlb_start_vma(),
but you haven't mentioned that one as a problem, and I expect you can
devise (ARM-specific) optimizations to avoid repetition there too.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
