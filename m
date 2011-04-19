Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B26BC8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 16:08:58 -0400 (EDT)
Date: Tue, 19 Apr 2011 13:08:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 20/20] mm: Optimize page_lock_anon_vma() fast-path
Message-Id: <20110419130800.7148a602.akpm@linux-foundation.org>
In-Reply-To: <20110401121726.285750519@chello.nl>
References: <20110401121258.211963744@chello.nl>
	<20110401121726.285750519@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Fri, 01 Apr 2011 14:13:18 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Optimize the page_lock_anon_vma() fast path to be one atomic op,
> instead of two.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> LKML-Reference: <new-submission>
> ---
>  mm/rmap.c |   86 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 82 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c
> +++ linux-2.6/mm/rmap.c
> @@ -85,6 +85,29 @@ static inline struct anon_vma *anon_vma_
>  static inline void anon_vma_free(struct anon_vma *anon_vma)
>  {
>  	VM_BUG_ON(atomic_read(&anon_vma->refcount));
> +
> +	/*
> +	 * Synchronize against page_lock_anon_vma() such that
> +	 * we can safely hold the lock without the anon_vma getting
> +	 * freed.
> +	 *
> +	 * Relies on the full mb implied by the atomic_dec_and_test() from
> +	 * put_anon_vma() against the acquire barrier implied by
> +	 * mutex_trylock() from page_lock_anon_vma(). This orders:
> +	 *
> +	 * page_lock_anon_vma()		VS	put_anon_vma()
> +	 *   mutex_trylock()			  atomic_dec_and_test()
> +	 *   LOCK				  MB
> +	 *   atomic_read()			  mutex_is_locked()
> +	 *
> +	 * LOCK should suffice since the actual taking of the lock must
> +	 * happen _before_ what follows.
> +	 */
> +	if (mutex_is_locked(&anon_vma->root->mutex)) {
> +		anon_vma_lock(anon_vma);
> +		anon_vma_unlock(anon_vma);
> +	}
> +
>  	kmem_cache_free(anon_vma_cachep, anon_vma);
>  }

Did we need to include all this stuff in uniprocessor builds?

It would be neater to add a new anon_vma_is_locked().

This code is too tricksy to deserve life :(

> @@ -371,20 +394,75 @@ struct anon_vma *page_get_anon_vma(struc
>  	return anon_vma;
>  }
>  
> +/*
> + * Similar to page_get_anon_vma() except it locks the anon_vma.
> + *
> + * Its a little more complex as it tries to keep the fast path to a single
> + * atomic op -- the trylock. If we fail the trylock, we fall back to getting a
> + * reference like with page_get_anon_vma() and then block on the mutex.
> + */
>  struct anon_vma *page_lock_anon_vma(struct page *page)
>  {
> -	struct anon_vma *anon_vma = page_get_anon_vma(page);
> +	struct anon_vma *anon_vma = NULL;
> +	unsigned long anon_mapping;
>  
> -	if (anon_vma)
> -		anon_vma_lock(anon_vma);
> +	rcu_read_lock();
> +	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
> +	if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
> +		goto out;

Why?  Needs a comment.

> +	if (!page_mapped(page))
> +		goto out;

Why?  How can this come about? Needs a comment.

> +
> +	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
> +	if (mutex_trylock(&anon_vma->root->mutex)) {

anon_vma_trylock()?

Or just remove all the wrapper functions and open-code all the locking.
These tricks all seem pretty tied-up with the mutex implementation
anyway.

> +		/*
> +		 * If we observe a !0 refcount, then holding the lock ensures
> +		 * the anon_vma will not go away, see __put_anon_vma().
> +		 */
> +		if (!atomic_read(&anon_vma->refcount)) {
> +			anon_vma_unlock(anon_vma);
> +			anon_vma = NULL;
> +		}
> +		goto out;
> +	}
> +
> +	/* trylock failed, we got to sleep */
> +	if (!atomic_inc_not_zero(&anon_vma->refcount)) {
> +		anon_vma = NULL;
> +		goto out;
> +	}
>  
> +	if (!page_mapped(page)) {
> +		put_anon_vma(anon_vma);
> +		anon_vma = NULL;
> +		goto out;
> +	}

Also quite opaque, needs decent commentary.

I'd have expected this test to occur after the lock was acquired.

> +	/* we pinned the anon_vma, its safe to sleep */
> +	rcu_read_unlock();
> +	anon_vma_lock(anon_vma);
> +
> +	if (atomic_dec_and_test(&anon_vma->refcount)) {
> +		/*
> +		 * Oops, we held the last refcount, release the lock
> +		 * and bail -- can't simply use put_anon_vma() because
> +		 * we'll deadlock on the anon_vma_lock() recursion.
> +		 */
> +		anon_vma_unlock(anon_vma);
> +		__put_anon_vma(anon_vma);
> +		anon_vma = NULL;
> +	}
> +
> +	return anon_vma;
> +
> +out:
> +	rcu_read_unlock();
>  	return anon_vma;
>  }
>  
>  void page_unlock_anon_vma(struct anon_vma *anon_vma)
>  {
>  	anon_vma_unlock(anon_vma);
> -	put_anon_vma(anon_vma);
>  }

Geeze, I hope this patch is worth it :( :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
