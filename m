Subject: Re: [patch] mm: fix anon_vma races
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LFD.2.00.0810191105090.4386@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de>
	 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
	 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
	 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
	 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
	 <20081018013258.GA3595@wotan.suse.de>
	 <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
	 <20081018022541.GA19018@wotan.suse.de>
	 <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
	 <20081018052046.GA26472@wotan.suse.de> <1224326299.28131.132.camel@twins>
	 <Pine.LNX.4.64.0810191048410.11802@blonde.site>
	 <1224413500.10548.55.camel@lappy.programming.kicks-ass.net>
	 <alpine.LFD.2.00.0810191105090.4386@nehalem.linux-foundation.org>
Content-Type: text/plain
Date: Sun, 19 Oct 2008 20:45:56 +0200
Message-Id: <1224441956.8861.5.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2008-10-19 at 11:25 -0700, Linus Torvalds wrote:

> Anyway, I _think_ the part that everybody agrees about is the initial 
> locking of the anon_vma. Whether we then even need any memory barriers 
> and/or the page_mapped() check is an independent question. Yes? No?

Yes

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
> Subject: [PATCH] anon_vma_prepare: properly lock even newly allocated entries
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
> 
> Acked-by: Nick Piggin <npiggin@suse.de>
> Acked-by: Hugh Dickins <hugh@veritas.com>

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
