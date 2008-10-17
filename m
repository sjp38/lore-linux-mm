Subject: Re: [patch] mm: fix anon_vma races
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20081016041033.GB10371@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de>
Content-Type: text/plain
Date: Sat, 18 Oct 2008 01:13:41 +0200
Message-Id: <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-16 at 06:10 +0200, Nick Piggin wrote:

> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c
> +++ linux-2.6/mm/rmap.c
> @@ -81,8 +81,15 @@ int anon_vma_prepare(struct vm_area_stru
>  		/* page_table_lock to protect against threads */
>  		spin_lock(&mm->page_table_lock);
>  		if (likely(!vma->anon_vma)) {
> -			vma->anon_vma = anon_vma;
>  			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
> +			/*
> +			 * This smp_wmb() is required to order all previous
> +			 * stores to initialize the anon_vma (by the slab
> +			 * ctor) and add this vma, with the store to make it
> +			 * visible to other CPUs via vma->anon_vma.
> +			 */
> +			smp_wmb();
> +			vma->anon_vma = anon_vma;

I'm not getting why you explicitly move the list_add_tail() before the
wmb, doesn't the list also expose the anon_vma to other cpus?

Hmm, I guess not, since we won't set the page->mapping until well after
the wmb.. still, tricky.

>  			allocated = NULL;
>  		}
>  		spin_unlock(&mm->page_table_lock);
> @@ -91,6 +98,15 @@ int anon_vma_prepare(struct vm_area_stru
>  			spin_unlock(&locked->lock);
>  		if (unlikely(allocated))
>  			anon_vma_free(allocated);
> +	} else {
> +		/*
> +		 * This smp_read_barrier_depends is required to order the data
> +		 * dependent loads of fields in anon_vma, with the load of the
> +		 * anon_vma pointer vma->anon_vma. This complements the above
> +		 * smp_wmb, and prevents a CPU from loading uninitialized
> +		 * contents of anon_vma.
> +		 */
> +		smp_read_barrier_depends();
>  	}
>  	return 0;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
