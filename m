Date: Tue, 6 Mar 2007 03:23:19 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 3/5] mm: RCUify vma lookup
Message-ID: <20070306022319.GF23845@wotan.suse.de>
References: <20070306013815.951032000@taijtu.programming.kicks-ass.net> <20070306014211.293824000@taijtu.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070306014211.293824000@taijtu.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@engr.sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 06, 2007 at 02:38:18AM +0100, Peter Zijlstra wrote:
> mostly lockless vma lookup using the new b+tree
> pin the vma using an atomic refcount
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/linux/init_task.h |    3 
>  include/linux/mm.h        |    7 +
>  include/linux/sched.h     |    2 
>  kernel/fork.c             |    4 
>  mm/mmap.c                 |  212 ++++++++++++++++++++++++++++++++++++++++------
>  5 files changed, 199 insertions(+), 29 deletions(-)
> 
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -103,12 +103,14 @@ struct vm_area_struct {
>  	void * vm_private_data;		/* was vm_pte (shared mem) */
>  	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
>  
> +	atomic_t vm_count;
>  #ifndef CONFIG_MMU
>  	atomic_t vm_usage;		/* refcount (VMAs shared if !MMU) */
>  #endif
>  #ifdef CONFIG_NUMA
>  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>  #endif
> +	struct rcu_head vm_rcu_head;
>  };
>  
>  static inline struct vm_area_struct *
> @@ -1047,6 +1049,8 @@ static inline void vma_nonlinear_insert(
>  }
>  
>  /* mmap.c */
> +extern void btree_rcu_flush(struct btree_freevec *);
> +extern void free_vma(struct vm_area_struct *vma);
>  extern int __vm_enough_memory(long pages, int cap_sys_admin);
>  extern void vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
> @@ -1132,6 +1136,9 @@ extern struct vm_area_struct * find_vma(
>  extern struct vm_area_struct * find_vma_prev(struct mm_struct * mm, unsigned long addr,
>  					     struct vm_area_struct **pprev);
>  
> +extern struct vm_area_struct * find_get_vma(struct mm_struct *mm, unsigned long addr);
> +extern void put_vma(struct vm_area_struct *vma);
> +
>  /* Look up the first VMA which intersects the interval start_addr..end_addr-1,
>     NULL if none.  Assume start_addr < end_addr. */
>  static inline struct vm_area_struct * find_vma_intersection(struct mm_struct * mm, unsigned long start_addr, unsigned long end_addr)
> Index: linux-2.6/include/linux/sched.h
> ===================================================================
> --- linux-2.6.orig/include/linux/sched.h
> +++ linux-2.6/include/linux/sched.h
> @@ -54,6 +54,7 @@ struct sched_param {
>  #include <linux/cpumask.h>
>  #include <linux/errno.h>
>  #include <linux/nodemask.h>
> +#include <linux/rcupdate.h>
>  
>  #include <asm/system.h>
>  #include <asm/semaphore.h>
> @@ -311,6 +312,7 @@ struct mm_struct {
>  	struct list_head mm_vmas;
>  	struct btree_root mm_btree;
>  	spinlock_t mm_btree_lock;
> +	wait_queue_head_t mm_wq;
>  	struct vm_area_struct * mmap_cache;	/* last find_vma result */
>  	unsigned long (*get_unmapped_area) (struct file *filp,
>  				unsigned long addr, unsigned long len,
> Index: linux-2.6/mm/mmap.c
> ===================================================================
> --- linux-2.6.orig/mm/mmap.c
> +++ linux-2.6/mm/mmap.c
> @@ -39,6 +39,18 @@ static void unmap_region(struct mm_struc
>  		struct vm_area_struct *vma, struct vm_area_struct *prev,
>  		unsigned long start, unsigned long end);
>  
> +static void __btree_rcu_flush(struct rcu_head *head)
> +{
> +	struct btree_freevec *freevec =
> +		container_of(head, struct btree_freevec, rcu_head);
> +	btree_freevec_flush(freevec);
> +}
> +
> +void btree_rcu_flush(struct btree_freevec *freevec)
> +{
> +	call_rcu(&freevec->rcu_head, __btree_rcu_flush);
> +}
> +
>  /*
>   * WARNING: the debugging will use recursive algorithms so never enable this
>   * unless you know what you are doing.
> @@ -217,6 +229,18 @@ void unlink_file_vma(struct vm_area_stru
>  	}
>  }
>  
> +static void __free_vma(struct rcu_head *head)
> +{
> +	struct vm_area_struct *vma =
> +		container_of(head, struct vm_area_struct, vm_rcu_head);
> +	kmem_cache_free(vm_area_cachep, vma);
> +}
> +
> +void free_vma(struct vm_area_struct *vma)
> +{
> +	call_rcu(&vma->vm_rcu_head, __free_vma);
> +}
> +
>  /*
>   * Close a vm structure and free it, returning the next.
>   */
> @@ -229,7 +253,7 @@ static void remove_vma(struct vm_area_st
>  		fput(vma->vm_file);
>  	mpol_free(vma_policy(vma));
>  	list_del(&vma->vm_list);
> -	kmem_cache_free(vm_area_cachep, vma);
> +	free_vma(vma);
>  }
>  
>  asmlinkage unsigned long sys_brk(unsigned long brk)
> @@ -312,6 +336,7 @@ __vma_link_list(struct mm_struct *mm, st
>  void __vma_link_btree(struct mm_struct *mm, struct vm_area_struct *vma)
>  {
>  	int err;
> +	atomic_set(&vma->vm_count, 1);
>  	spin_lock(&mm->mm_btree_lock);
>  	err = btree_insert(&mm->mm_btree, vma->vm_start, vma);
>  	spin_unlock(&mm->mm_btree_lock);
> @@ -388,6 +413,17 @@ __insert_vm_struct(struct mm_struct * mm
>  	mm->map_count++;
>  }
>  
> +static void lock_vma(struct vm_area_struct *vma)
> +{
> +	wait_event(vma->vm_mm->mm_wq, (atomic_cmpxchg(&vma->vm_count, 1, 0) == 1));
> +}
> +
> +static void unlock_vma(struct vm_area_struct *vma)
> +{
> +	BUG_ON(atomic_read(&vma->vm_count));
> +	atomic_set(&vma->vm_count, 1);
> +}

This is a funny scheme you're trying to do in order to try to avoid
rwsems. Of course it is subject to writer starvation, so please just
use an rwsem per vma for this.

If the -rt tree cannot do them properly, then it just has to turn them
into mutexes and take the hit itself.

There is no benefit for the -rt tree to do this anyway, because you're
just re-introducing the fundamental problem that it has with rwsems
anyway (ie. poor priority inheritance).

In this case I guess you still need some sort of refcount in order to force
the lookup into the slowpath, but please don't use it for locking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
