Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 30FE76B0082
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 01:57:57 -0500 (EST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC -v2 PATCH -mm] change anon_vma linking to fix multi-process server scalability issue
In-Reply-To: <4B57E442.5060700@redhat.com>
References: <20100121133448.73BD.A69D9226@jp.fujitsu.com> <4B57E442.5060700@redhat.com>
Message-Id: <20100122135809.6C11.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri, 22 Jan 2010 15:57:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, minchan.kim@gmail.com, lwoodman@redhat.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

> On 01/21/2010 12:05 AM, KOSAKI Motohiro wrote:
> 
> >> In a workload with 1000 child processes and a VMA with 1000 anonymous
> >> pages per process that get COWed, this leads to a system with a million
> >> anonymous pages in the same anon_vma, each of which is mapped in just
> >> one of the 1000 processes.  However, the current rmap code needs to
> >> walk them all, leading to O(N) scanning complexity for each page.
> 
> >> This reduces rmap scanning complexity to O(1) for the pages of
> >> the 1000 child processes, with O(N) complexity for at most 1/N
> >> pages in the system.  This reduces the average scanning cost in
> >> heavily forking workloads from O(N) to 2.
> 
> > I've only roughly reviewed this patch. So, perhaps I missed something.
> > My first impression is, this is slightly large but benefit is only affected
> > corner case.
> 
> At the moment it mostly triggers with artificial workloads, but
> having 1000 client connections to eg. an Oracle database is not
> unheard of.
> 
> The reason for wanting to fix the corner case is because it is
> so incredibly bad.
> 
> > If my remember is correct, you said you expect Nick's fair rwlock + Larry's rw-anon-lock
> > makes good result at some week ago. Why do you make alternative patch?
> > such way made bad result? or this patch have alternative benefit?
> 
> After looking at the complexity figures (above), I suspect that
> making a factor 5-10 speedup is not going to fix a factor 1000
> increased complexity.
> 
> > This patch seems to increase fork overhead instead decreasing vmscan overhead.
> > I'm not sure it is good deal.
> 
> My hope is that the overhead of adding a few small objects per VMA
> will be unnoticable, compared to the overhead of refcounting pages,
> handling page tables, etc.
> 
> The code looks like it could be a lot of anon_vma_chains, but in
> practice the depth is limited because exec() wipes them all out.
> Most of the time we will have just 0, 1 or 2 anon_vmas attached to
> a VMA - one for the current process and one for the parent.
> 
> > Hmm...
> > Why can't we convert read side anon-vma walk to rcu? It need rcu aware vma
> > free, but anon_vma is alredy freed by rcu.
> 
> Changing the locking to RCU does not reduce the amount of work
> that needs to be done in page_referenced_anon.  If we have 1000
> siblings with 1000 pages each, we still end up scanning all
> 1000 processes for each of those 1000 pages in the pageout code.
> 
> Adding parallelism to that with better locking may speed it up
> by the number of CPUs at most, which really may not help much
> in these workloads.
> 
> Today having 1000 client connections to a forking server is
> considered a lot, but I suspect it could be more common in a
> few years. I would like Linux to be ready for those kinds of
> workloads.

Thanks. probably I understand your intention. I think this patch
need performance comparision with simple rw-spinlock patch. but
I don't worry it, maybe someone else does this.


roughly review is here.

[ generally, this patch have too few lock related comment. I think I
  haven't undestand correct lock rule of this patch. ]


> @@ -516,7 +517,8 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
>  	/*
>  	 * cover the whole range: [new_start, old_end)
>  	 */
> -	vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
> +	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
> +		return -ENOMEM;

shift_arg_pages() have two vma_adjust() call. why don't we need change both?


> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 84a524a..44cfb13 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -167,7 +167,7 @@ struct vm_area_struct {
>  	 * can only be in the i_mmap tree.  An anonymous MAP_PRIVATE, stack
>  	 * or brk vma (with NULL file) can only be in an anon_vma list.
>  	 */
> -	struct list_head anon_vma_node;	/* Serialized by anon_vma->lock */
> +	struct list_head anon_vma_chain; /* Serialized by anon_vma->lock */
>  	struct anon_vma *anon_vma;	/* Serialized by page_table_lock */

Is this comment really correct? for example, following vma->anon_vma_chain
operation is in place out of anon_vma lock.

	static void anon_vma_chain_link(struct vm_area_struct *vma,
	                                struct anon_vma_chain *avc,
	                                struct anon_vma *anon_vma)
	{
	        avc->vma = vma;
	        avc->anon_vma = anon_vma;
	        list_add(&avc->same_vma, &vma->anon_vma_chain);

	        spin_lock(&anon_vma->lock);
	        list_add_tail(&avc->same_anon_vma, &anon_vma->head);
	        spin_unlock(&anon_vma->lock);
	}

I guess you intend to write /* locked by mmap_sem & friends */.


note: however I don't think "& friends" is good comment ;-)


>  	/* Function pointers to deal with this struct. */
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index b019ae6..0d1903a 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -37,7 +37,27 @@ struct anon_vma {
>  	 * is serialized by a system wide lock only visible to
>  	 * mm_take_all_locks() (mm_all_locks_mutex).
>  	 */
> -	struct list_head head;	/* List of private "related" vmas */
> +	struct list_head head;	/* Chain of private "related" vmas */
> +};

Hmm..
It seems unclear comment. this list head don't linked struct vm_area_struct.
instead, linked struct anon_vma_chain. so "related vmas" isn't kindly comment.


> +
> +/*
> + * The copy-on-write semantics of fork mean that an anon_vma
> + * can become associated with multiple processes. Furthermore,
> + * each child process will have its own anon_vma, where new
> + * pages for that process are instantiated.
> + *
> + * This structure allows us to find the anon_vmas associated
> + * with a VMA, or the VMAs associated with an anon_vma.
> + * The "same_vma" list contains the anon_vma_chains linking
> + * all the anon_vmas associated with this VMA.
> + * The "same_anon_vma" list contains the anon_vma_chains
> + * which link all the VMAs associated with this anon_vma.
> + */
> +struct anon_vma_chain {
> +	struct vm_area_struct *vma;
> +	struct anon_vma *anon_vma;
> +	struct list_head same_vma;	/* locked by mmap_sem & friends */
> +	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
>  };

Probably, This place need more lots comments. struct anon_vma_chain
makes very complex relationship graph. example or good ascii art is needed.
especially, fork parent and child have different anon_vma_chain. it
seems tricky.


> +static inline void anon_vma_merge(struct vm_area_struct *vma,
> +				  struct vm_area_struct *next)
> +{
> +	BUG_ON(vma->anon_vma != next->anon_vma);
> +	unlink_anon_vmas(next);
> +}
> +

Probably VM_BUG_ON is enough?




> @@ -792,11 +809,13 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
>  				is_mergeable_anon_vma(prev->anon_vma,
>  						      next->anon_vma)) {
>  							/* cases 1, 6 */
> -			vma_adjust(prev, prev->vm_start,
> +			err = vma_adjust(prev, prev->vm_start,
>  				next->vm_end, prev->vm_pgoff, NULL);
>  		} else					/* cases 2, 5, 7 */
> -			vma_adjust(prev, prev->vm_start,
> +			err = vma_adjust(prev, prev->vm_start,
>  				end, prev->vm_pgoff, NULL);
> +		if (err)
> +			return NULL;
>  		return prev;
>  	}

Currently, the callers of vma_merge() assume vma_merge doesn't failure.
IOW, they don't think return NULL is failure.

Probably we need to change all callers too.


> @@ -2454,7 +2506,8 @@ int mm_take_all_locks(struct mm_struct *mm)
>  		if (signal_pending(current))
>  			goto out_unlock;
>  		if (vma->anon_vma)
> -			vm_lock_anon_vma(mm, vma->anon_vma);
> +			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
> +				vm_lock_anon_vma(mm, avc->anon_vma);
>  	}

This function is not protected by mmap_sem. but anon_vma_chain->same_vma
iteration need to mmap_sem if your commnet is correct.


> @@ -2509,13 +2562,15 @@ static void vm_unlock_mapping(struct address_space *mapping)
>  void mm_drop_all_locks(struct mm_struct *mm)
>  {
>  	struct vm_area_struct *vma;
> +	struct anon_vma_chain *avc;
>  
>  	BUG_ON(down_read_trylock(&mm->mmap_sem));
>  	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
>  
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  		if (vma->anon_vma)
> -			vm_unlock_anon_vma(vma->anon_vma);
> +			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
> +				vm_unlock_anon_vma(avc->anon_vma);
>  		if (vma->vm_file && vma->vm_file->f_mapping)
>  			vm_unlock_mapping(vma->vm_file->f_mapping);
>  	}

ditto.

> @@ -188,10 +276,21 @@ static void anon_vma_ctor(void *data)
>  	INIT_LIST_HEAD(&anon_vma->head);
>  }


>  void __init anon_vma_init(void)
>  {
>  	anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
>  			0, SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_ctor);
> +	anon_vma_chain_cachep = kmem_cache_create("anon_vma_chain",
> +			sizeof(struct anon_vma_chain), 0,
> +			SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_chain_ctor);
>  }

Why do we need SLAB_DESTROY_BY_RCU?
anon_vma's one is required by page migration. (Oops, It should be commented, I think)
but which code require anon_vma_chain's one?


>  /*
> @@ -240,6 +339,14 @@ vma_address(struct page *page, struct vm_area_struct *vma)
>  		/* page should be within @vma mapping range */
>  		return -EFAULT;
>  	}
> +	if (unlikely(vma->vm_flags & VM_LOCK_RMAP))
> +		/*
> +		 * This VMA is being unlinked or not yet linked into the
> +		 * VMA tree.  Do not try to follow this rmap.  This race
> +		 * condition can result in page_referenced ignoring a
> +		 * reference or try_to_unmap failing to unmap a page.
> +		 */
> +		return -EFAULT;
>  	return address;
>  }

In this place, the task have anon_vma->lock, but don't have mmap_sem.
But, VM_LOCK_RMAP changing point (i.e. vma_adjust()) is protected by mmap_sem.

IOW, "if (vma->vm_flags & VM_LOCK_RMAP)" return unstable value. Why can we use
unstable value as "lock"? 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
