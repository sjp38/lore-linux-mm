From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] mm: fix anon_vma races
Date: Tue, 21 Oct 2008 13:44:45 +1100
References: <20081016041033.GB10371@wotan.suse.de> <1224413500.10548.55.camel@lappy.programming.kicks-ass.net> <alpine.LFD.2.00.0810191105090.4386@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0810191105090.4386@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810211344.45410.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, stable@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 20 October 2008 05:25, Linus Torvalds wrote:
> On Sun, 19 Oct 2008, Peter Zijlstra wrote:
> > Part of the confusion is that we don't clear those pointers at the end
> > of their lifetimes (page_remove_rmap and anon_vma_unlink).
> >
> > I guess the !page_mapping() test in page_lock_anon_vma() is meant to
> > deal with this
>
> Hmm. So that part I'm still not entirely convinced about.
>
> The thing is, we have two issues on anon_vma usage, and the
> page_lock_anon_vma() usage in particular:
>
>  - the integrity of the list itself
>
>    Here it should be sufficient to just always get the lock, to the point
>    where we don't need to care about anything else. So getting the lock
>    properly on new allocation makes all the other races irrelevant.
>
>  - the integrity of the _result_ of traversing the list
>
>    This is what the !page_mapping() thing is supposedly protecting
>    against, I think.
>
>    But as far as I can tell, there's really two different use cases here:
>    (a) people who care deeply about the result and (b) people who don't.
>
>    And the difference between the two cases is whether they had the page
>    locked or not. The "try_to_unmap()" callers care deeply, and lock the
>    page. In contrast, some "page_referenced()" callers (really just
>    shrink_active_list) don't care deeply, and to them the return value is
>    really just a heuristic.
>
> As far as I can tell, all the people who care deeply will lock the page
> (and _have_ to lock the page), and thus 'page->mapping' should be stable
> for those cases.
>
> And then we have the other cases, who just want a heuristic, and they
> don't hold the page lock, but if we look at the wrong active_vma that has
> gotten reallocated to something else, they don't even really care.
>
> So I'm not seeing the reason for that check for page_mapped() at the end.
> Does it actually protect against anything relevant?
>
> Anyway, I _think_ the part that everybody agrees about is the initial
> locking of the anon_vma. Whether we then even need any memory barriers
> and/or the page_mapped() check is an independent question. Yes? No?
>
> So I'm suggesting this commit as the part we at least all agree on. But I
> haven't pushed it out yet, so you can still holler.. But I think all the
> discussion is about other issues, and we all agree on at least this part?
>
> 		Linus
>
> ---
> From f422f2ec50872331820f15711f48b9ffc9cbb64e Mon Sep 17 00:00:00 2001
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sun, 19 Oct 2008 10:32:20 -0700
> Subject: [PATCH] anon_vma_prepare: properly lock even newly allocated
> entries
>
> The anon_vma code is very subtle, and we end up doing optimistic lookups
> of anon_vmas under RCU in page_lock_anon_vma() with no locking.  Other
> CPU's can also see the newly allocated entry immediately after we've
> exposed it by setting "vma->anon_vma" to the new value.
>
> We protect against the anon_vma being destroyed by having the SLAB
> marked as SLAB_DESTROY_BY_RCU, so the RCU lookup can depend on the
> allocation not being destroyed - but it might still be free'd and
> re-allocated here to a new vma.
>
> As a result, we should not do the anon_vma list ops on a newly allocated
> vma without proper locking.

Thanks, this is exactly what I proposed. I preferred to add more
explicit comments about why it's OK to expose anon_vma to vma->anon_vma
without ordering initialisation etc.

But those comments were mainly for the benefit of others. If you and
Hugh now agree with me on that, then maybe no comments are required.

>
> Acked-by: Nick Piggin <npiggin@suse.de>
> Acked-by: Hugh Dickins <hugh@veritas.com>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>  mm/rmap.c |   42 ++++++++++++++++++++++++++++++++----------
>  1 files changed, 32 insertions(+), 10 deletions(-)
>
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 0383acf..e8d639b 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -55,7 +55,33 @@
>
>  struct kmem_cache *anon_vma_cachep;
>
> -/* This must be called under the mmap_sem. */
> +/**
> + * anon_vma_prepare - attach an anon_vma to a memory region
> + * @vma: the memory region in question
> + *
> + * This makes sure the memory mapping described by 'vma' has
> + * an 'anon_vma' attached to it, so that we can associate the
> + * anonymous pages mapped into it with that anon_vma.
> + *
> + * The common case will be that we already have one, but if
> + * if not we either need to find an adjacent mapping that we
> + * can re-use the anon_vma from (very common when the only
> + * reason for splitting a vma has been mprotect()), or we
> + * allocate a new one.
> + *
> + * Anon-vma allocations are very subtle, because we may have
> + * optimistically looked up an anon_vma in page_lock_anon_vma()
> + * and that may actually touch the spinlock even in the newly
> + * allocated vma (it depends on RCU to make sure that the
> + * anon_vma isn't actually destroyed).
> + *
> + * As a result, we need to do proper anon_vma locking even
> + * for the new allocation. At the same time, we do not want
> + * to do any locking for the common case of already having
> + * an anon_vma.
> + *
> + * This must be called with the mmap_sem held for reading.
> + */
>  int anon_vma_prepare(struct vm_area_struct *vma)
>  {
>  	struct anon_vma *anon_vma = vma->anon_vma;
> @@ -63,20 +89,17 @@ int anon_vma_prepare(struct vm_area_struct *vma)
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
> @@ -87,8 +110,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
>  		}
>  		spin_unlock(&mm->page_table_lock);
>
> -		if (locked)
> -			spin_unlock(&locked->lock);
> +		spin_unlock(&anon_vma->lock);
>  		if (unlikely(allocated))
>  			anon_vma_free(allocated);
>  	}
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
