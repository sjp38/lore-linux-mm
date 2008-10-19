Date: Sun, 19 Oct 2008 02:13:06 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0810190111250.25710@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de>
 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Oct 2008, Linus Torvalds wrote:
> On Fri, 17 Oct 2008, Linus Torvalds wrote:
> > 
> > But I think that what Nick did is correct - we always start traversal 
> > through anon_vma->head, so no, the "list_add_tail()" won't expose it to 
> > anybody else, because nobody else has seen the anon_vma().
> > 
> > That said, that's really too damn subtle. We shouldn't rely on memory 
> > ordering for the list handling, when the list handling is _supposed_ to be 
> > using that anon_vma->lock thing.
> 
> So maybe a better patch would be as follows? It simplifies the whole thing 
> by just always locking and unlocking the vma, whether it's newly allocated 
> or not (and whether it then gets dropped as unnecessary or not).
> 
> It still does that "smp_read_barrier_depends()" in the same old place. I 
> don't have the energy to look at Hugh's point about people reading 
> anon_vma without doing the whole "prepare" thing.
> 
> It adds more lines than it removes, but it's just because of the comments. 
> With the locking simplification, it actually removes more lines of actual 
> code than it adds. And now we always do that list_add_tail() with the 
> anon_vma lock held, which should simplify thinking about this, and avoid 
> at least one subtle ordering issue.
> 
> 		Linus

I'm slowly approaching the conclusion that this is the only patch
which is needed here.

The newly-allocated "locked = NULL" mis-optimization still looks
wrong to me in the face of SLAB_DESTROY_BY_RCU, and you kill that.

You also address Nick's second point about barriers: you've arranged
them differently, but I don't think that matters; or the smp_wmb()
could go into the "allocated = anon_vma" block, couldn't it?  that
would reduce its overhead a little.  (If we needed more than an
Alpha-barrier in the common path, then I'd look harder for a way
to avoid it more often, but it'll do as is.)

I thought for a while that even the barriers weren't needed, because
the only thing mmap.c and memory.c do with anon_vma (until they've
up_readed mmap_sem and down_writed it to rearrange vmas) is note its
address.  Then I found one exception, the use of anon_vma_lock()
in expand_downwards() and expand_upwards() (it's not really being
used as an anon_vma lock, just as a convenient spinlock to serialize
concurrent stack faults for a moment): but I don't think that could
ever actually need the barriers, the anon_vma for the stack should
be well-established before there can be any racing threads on it.

But at last I realized the significant exception is right there in
anon_vma_prepare(): the spin_lock(&anon_vma->lock) of an anon_vma
coming back from find_mergeable_anon_vma() does need that lock to
be visibly initialized - that is the clinching case for barriers.

That leaves Nick's original point, of the three CPUs with the third
doing reclaim, with my point about needing smp_read_barrier_depends()
over there.  I now think those races were illusory, that we were all
overlooking something.  Reclaim (or page migration) doesn't arrive at
those pages by scanning the old mem_map[] array, it gets them off an
LRU list, whose spinlock is locked and unlocked to take them off; and
the original faulting CPU had to lock and unlock that spinlock to put
them on the LRU originally, at a stage after its anon_vma_prepare().

Surely we have enough barriers there to make sure that anon_vma->lock
is visibly initialized by the time page_lock_anon_vma() tries to take
it?  And it's not any kind of coincidence: isn't this a general pattern,
that a newly initialized structure containing a lock is made available
to other threads such as reclaim, and they can rely on that lock being
visibly initialized, because the structure is made available to them
by being put onto and examined on some separately locked list or tree?

Nick, are you happy with Linus's patch below?
Or if not, please explain again what's missing - thanks.

Hugh

> 
> ---
>  mm/rmap.c |   33 +++++++++++++++++++++++----------
>  1 files changed, 23 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 0383acf..9221bf7 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -63,35 +63,48 @@ int anon_vma_prepare(struct vm_area_struct *vma)
>  	might_sleep();
>  	if (unlikely(!anon_vma)) {
>  		struct mm_struct *mm = vma->vm_mm;
> -		struct anon_vma *allocated, *locked;
> +		struct anon_vma *allocated;
>  
>  		anon_vma = find_mergeable_anon_vma(vma);
> -		if (anon_vma) {
> -			allocated = NULL;
> -			locked = anon_vma;
> -			spin_lock(&locked->lock);
> -		} else {
> +		allocated = NULL;
> +		if (!anon_vma) {
>  			anon_vma = anon_vma_alloc();
>  			if (unlikely(!anon_vma))
>  				return -ENOMEM;
>  			allocated = anon_vma;
> -			locked = NULL;
>  		}
> +		spin_lock(&anon_vma->lock);
>  
>  		/* page_table_lock to protect against threads */
>  		spin_lock(&mm->page_table_lock);
>  		if (likely(!vma->anon_vma)) {
> +			/*
> +			 * We hold the mm->page_table_lock, but another
> +			 * CPU may be doing an optimistic load (the one
> +			 * at the top), and we want to make sure that
> +			 * the anon_vma changes are visible.
> +			 */
> +			smp_wmb();
>  			vma->anon_vma = anon_vma;
>  			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
>  			allocated = NULL;
>  		}
>  		spin_unlock(&mm->page_table_lock);
> -
> -		if (locked)
> -			spin_unlock(&locked->lock);
> +		spin_unlock(&anon_vma->lock);
>  		if (unlikely(allocated))
>  			anon_vma_free(allocated);
>  	}
> +	/*
> +	 * Subtle: we looked up anon_vma without any locking
> +	 * (in the comon case), and are going to look at the
> +	 * spinlock etc behind it. In order to know that it's
> +	 * initialized, we need to do a read barrier here.
> +	 *
> +	 * We can use the cheaper "depends" version, since we
> +	 * are following a pointer, and only on alpha may that
> +	 * give a stale value.
> +	 */
> +	smp_read_barrier_depends();
>  	return 0;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
