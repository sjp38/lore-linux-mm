Date: Fri, 29 Jun 2007 19:56:33 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/5] avoid tlb gather restarts.
In-Reply-To: <20070629141527.557443600@de.ibm.com>
Message-ID: <Pine.LNX.4.64.0706291927260.1509@blonde.wat.veritas.com>
References: <20070629135530.912094590@de.ibm.com> <20070629141527.557443600@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I don't dare comment on your page_mkclean_one patch (5/5),
that dirty page business has grown too subtle for me.

Your cleanups 2-4 look good, especially the mm_types.h one (how
confident are you that everything builds?), and I'm glad we can
now lay ptep_establish to rest.  Though I think you may have 
missed removing a __HAVE_ARCH_PTEP... from frv at least?

But this one...

On Fri, 29 Jun 2007, Martin Schwidefsky wrote:

> If need_resched() is false it is unnecessary to call tlb_finish_mmu()
> and tlb_gather_mmu() for each vma in unmap_vmas(). Moving the tlb gather
> restart under the if that contains the cond_resched() will avoid
> unnecessary tlb flush operations that are triggered by tlb_finish_mmu() 
> and tlb_gather_mmu().
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

Sorry, no.  It looks reasonable, but unmap_vmas is treading a delicate
and uncomfortable line between hi-performance and lo-latency: you've
chosen to improve performance at the expense of latency.

You think you're just moving the finish/gather to where they're
actually necessary; but the thing is, that per-cpu struct mmu_gather
is liable to accumulate a lot of unpreemptible work for the future
tlb_finish_mmu, particularly when anon pages are associated with swap.

So although there may be no need to resched right now, if we keep on
gathering more and more without flushing, we'll be very unresponsive
when a resched is needed later on.  Hence Ingo's ZAP_BLOCK_SIZE to
split it up, small when CONFIG_PREEMPT, more reasonable but still
limited when not.

I expect there is some tinkering which could be done to improve it a
little; but my ambition has always been to eliminate ZAP_BLOCK_SIZE,
get away from the per-cpu'ness of the mmu_gather, and make unmap_vmas
preemptible.  But the i_mmap_lock case, and the per-arch variations
in TLB flushing, have forever stalled me.

Hugh

> ---
> 
>  mm/memory.c |    7 +++----
>  1 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
> --- linux-2.6/mm/memory.c	2007-06-29 15:44:08.000000000 +0200
> +++ linux-2.6-patched/mm/memory.c	2007-06-29 15:44:08.000000000 +0200
> @@ -851,19 +851,18 @@ unsigned long unmap_vmas(struct mmu_gath
>  				break;
>  			}
>  
> -			tlb_finish_mmu(*tlbp, tlb_start, start);
> -
>  			if (need_resched() ||
>  				(i_mmap_lock && need_lockbreak(i_mmap_lock))) {
> +				tlb_finish_mmu(*tlbp, tlb_start, start);
>  				if (i_mmap_lock) {
>  					*tlbp = NULL;
>  					goto out;
>  				}
>  				cond_resched();
> +				*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
> +				tlb_start_valid = 0;
>  			}
>  
> -			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
> -			tlb_start_valid = 0;
>  			zap_work = ZAP_BLOCK_SIZE;
>  		}
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
