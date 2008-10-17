Date: Fri, 17 Oct 2008 23:14:57 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <20081016041033.GB10371@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0810172300280.30871@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Added Linus and LKML to the Cc now I see that he's suggesting
a similar but not identical patch under that other thread.

On Thu, 16 Oct 2008, Nick Piggin wrote:

> Hi,
> 
> Still would like independent confirmation of these problems and the fix, but
> it still looks buggy to me...
> 
> ---
> 
> There are some races in the anon_vma code.
> 
> The race comes about because adding our vma to the tail of anon_vma->head comes
> after the assignment of vma->anon_vma to a new anon_vma pointer. In the case
> where this is a new anon_vma, this is done without holding any locks.  So a
> parallel anon_vma_prepare might see the vma already has an anon_vma, so it
> won't serialise on the page_table_lock. It may proceed and the anon_vma to a
> page in the page fault path. Another thread may then pick up the page from the
> LRU list, find its mapcount incremented, and attempt to iterate over the
> anon_vma's list concurrently with the first thread (because the first one is
> not holding the anon_vma lock). This is a fairly subtle race, and only likely
> to be hit in kernels where the spinlock is preemptible and the first thread is
> preempted at the right time... but OTOH it is _possible_ to hit here; on bigger
> SMP systems cacheline transfer latencies could be very large, or we could take
> an NMI inside the lock or something. Fix this by initialising the list before
> adding the anon_vma to vma.
> 
> After that, there is a similar data-race with memory ordering where the store
> to make the anon_vma visible passes previous stores to initialize the anon_vma.
> This race also includes stores to initialize the anon_vma spinlock by the
> slab constructor. Add and comment appropriate barriers to solve this.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Ow, you do break my head with these things.

I'm pretty sure you're on to something here, it certainly looks
suspicious.  But I've not yet convinced myself that what you (or
Linus) propose is the right answer - I was going to think through
some more, but spotting the other from Linus thought I ought at
least to introduce you to each other ;)

My problem is really with the smp_read_barrier_depends() you each
have in anon_vma_prepare().  But the only thing which its CPU
does with the anon_vma is put its address into a struct page
(or am I forgetting more?).  Wouldn't the smp_read_barrier_depends()
need to be, not there in anon_vma_prepare(), but over on the third
CPU, perhaps in page_lock_anon_vma()?

I've also been toying with the idea of taking the newly alloc'ed
anon_vma's lock here in the !vma->anon_vma case, instead of having
that "locked = NULL" business.  That might be a good idea, but I'm
rather thinking it doesn't quite address the issue at hand.

Taking a break...

Hugh

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
