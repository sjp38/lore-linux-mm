Date: Tue, 3 Jul 2007 18:42:47 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/5] avoid tlb gather restarts.
In-Reply-To: <20070703121228.254110263@de.ibm.com>
Message-ID: <Pine.LNX.4.64.0707031829390.2111@blonde.wat.veritas.com>
References: <20070703111822.418649776@de.ibm.com> <20070703121228.254110263@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Jul 2007, Martin Schwidefsky wrote:
> From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> If need_resched() is false in the inner loop of unmap_vmas it is
> unnecessary to do a full blown tlb_finish_mmu / tlb_gather_mmu for
> each ZAP_BLOCK_SIZE ptes. Do a tlb_flush_mmu() instead. That gives
> architectures with a non-generic tlb flush implementation room for
> optimization. The tlb_flush_mmu primitive is a available with the
> generic tlb flush code, the ia64_tlb_flush_mm needs to be renamed
> and a dummy function is added to arm and arm26.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

Acked-by: Hugh Dickins <hugh@veritas.com>

(Looking at it, I see that we could argue that there ought to be a
need_resched() etc. check after your tlb_flush_mmu() in unmap_vmas,
in case it's spent a long while in there on some arches; but I don't
think we have the ZAP_BLOCK_SIZE tuned with any great precision, and
you'd at worst be doubling the latency there, so let's not worry
about it.  I write this merely in order to reserve myself an
"I told you so" if anyone ever notices increased latency ;)

> ---
> 
>  include/asm-arm/tlb.h   |    5 +++++
>  include/asm-arm26/tlb.h |    5 +++++
>  include/asm-ia64/tlb.h  |    6 +++---
>  mm/memory.c             |   16 ++++++----------
>  4 files changed, 19 insertions(+), 13 deletions(-)
> 
> diff -urpN linux-2.6/include/asm-arm/tlb.h linux-2.6-patched/include/asm-arm/tlb.h
> --- linux-2.6/include/asm-arm/tlb.h	2006-11-08 10:45:43.000000000 +0100
> +++ linux-2.6-patched/include/asm-arm/tlb.h	2007-07-03 12:56:46.000000000 +0200
> @@ -52,6 +52,11 @@ tlb_gather_mmu(struct mm_struct *mm, uns
>  }
>  
>  static inline void
> +tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
> +{
> +}
> +
> +static inline void
>  tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
>  {
>  	if (tlb->fullmm)
> diff -urpN linux-2.6/include/asm-arm26/tlb.h linux-2.6-patched/include/asm-arm26/tlb.h
> --- linux-2.6/include/asm-arm26/tlb.h	2006-11-08 10:45:43.000000000 +0100
> +++ linux-2.6-patched/include/asm-arm26/tlb.h	2007-07-03 12:56:46.000000000 +0200
> @@ -29,6 +29,11 @@ tlb_gather_mmu(struct mm_struct *mm, uns
>  }
>  
>  static inline void
> +tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
> +{
> +}
> +
> +static inline void
>  tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
>  {
>          if (tlb->need_flush)
> diff -urpN linux-2.6/include/asm-ia64/tlb.h linux-2.6-patched/include/asm-ia64/tlb.h
> --- linux-2.6/include/asm-ia64/tlb.h	2006-11-08 10:45:45.000000000 +0100
> +++ linux-2.6-patched/include/asm-ia64/tlb.h	2007-07-03 12:56:46.000000000 +0200
> @@ -72,7 +72,7 @@ DECLARE_PER_CPU(struct mmu_gather, mmu_g
>   * freed pages that where gathered up to this point.
>   */
>  static inline void
> -ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
> +tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
>  {
>  	unsigned int nr;
>  
> @@ -160,7 +160,7 @@ tlb_finish_mmu (struct mmu_gather *tlb, 
>  	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
>  	 * tlb->end_addr.
>  	 */
> -	ia64_tlb_flush_mmu(tlb, start, end);
> +	tlb_flush_mmu(tlb, start, end);
>  
>  	/* keep the page table cache within bounds */
>  	check_pgt_cache();
> @@ -184,7 +184,7 @@ tlb_remove_page (struct mmu_gather *tlb,
>  	}
>  	tlb->pages[tlb->nr++] = page;
>  	if (tlb->nr >= FREE_PTE_NR)
> -		ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
> +		tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
>  }
>  
>  /*
> diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
> --- linux-2.6/mm/memory.c	2007-06-18 09:43:22.000000000 +0200
> +++ linux-2.6-patched/mm/memory.c	2007-07-03 12:56:46.000000000 +0200
> @@ -853,18 +853,15 @@ unsigned long unmap_vmas(struct mmu_gath
>  				break;
>  			}
>  
> -			tlb_finish_mmu(*tlbp, tlb_start, start);
> -
>  			if (need_resched() ||
>  				(i_mmap_lock && need_lockbreak(i_mmap_lock))) {
> -				if (i_mmap_lock) {
> -					*tlbp = NULL;
> +				if (i_mmap_lock)
>  					goto out;
> -				}
> +				tlb_finish_mmu(*tlbp, tlb_start, start);
>  				cond_resched();
> -			}
> -
> -			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
> +				*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
> +			} else
> +				tlb_flush_mmu(*tlbp, tlb_start, start);
>  			tlb_start_valid = 0;
>  			zap_work = ZAP_BLOCK_SIZE;
>  		}
> @@ -892,8 +889,7 @@ unsigned long zap_page_range(struct vm_a
>  	tlb = tlb_gather_mmu(mm, 0);
>  	update_hiwater_rss(mm);
>  	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
> -	if (tlb)
> -		tlb_finish_mmu(tlb, address, end);
> +	tlb_finish_mmu(tlb, address, end);
>  	return end;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
