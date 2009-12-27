Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2800B60021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 05:10:02 -0500 (EST)
Received: by gxk24 with SMTP id 24so8755406gxk.6
        for <linux-mm@kvack.org>; Sun, 27 Dec 2009 02:10:00 -0800 (PST)
Message-ID: <4B372D2D.60908@gmail.com>
Date: Sun, 27 Dec 2009 18:47:25 +0900
From: Minchan Kim <minchan.kim@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] asynchronous page fault.
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi, Kame. 

KAMEZAWA Hiroyuki wrote:
> Speculative page fault v3.
> 
> This version is much simpler than old versions and doesn't use mm_accessor
> but use RCU. This is based on linux-2.6.33-rc2.
> 
> This patch is just my toy but shows...
>  - Once RB-tree is RCU-aware and no-lock in readside, we can avoid mmap_sem
>    in page fault. 
> So, what we need is not mm_accessor, but RCU-aware RB-tree, I think.
> 
> But yes, I may miss something critical ;)
> 
> After patch, statistics perf show is following. Test progam is attached.
>   
> # Samples: 1331231315119
> #
> # Overhead          Command             Shared Object  Symbol
> # ........  ...............  ........................  ......
> #
>     28.41%  multi-fault-all  [kernel]                  [k] clear_page_c
>             |
>             --- clear_page_c
>                 __alloc_pages_nodemask
>                 handle_mm_fault
>                 do_page_fault
>                 page_fault
>                 0x400950
>                |
>                 --100.00%-- (nil)
> 
>     21.69%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
>             |
>             --- _raw_spin_lock
>                |
>                |--81.85%-- free_pcppages_bulk
>                |          free_hot_cold_page
>                |          __pagevec_free
>                |          release_pages
>                |          free_pages_and_swap_cache
> 
> 
> I'll be almost offline in the next week. 
> 
> Minchan, in this version, I didn't add CONFIG and some others which was
> recommended just for my laziness. Sorry.

No problem :)
Thanks for X-mas present. 

> 
> =
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Asynchronous page fault.
> 
> This patch is for avoidng mmap_sem in usual page fault. At running highly
> multi-threaded programs, mm->mmap_sem can use much CPU because of false
> sharing when it causes page fault in parallel. (Run after fork() is a typical
> case, I think.)
> This patch uses a speculative vma lookup to reduce that cost.
> 
> Considering vma lookup, rb-tree lookup, the only operation we do is checking
> node->rb_left,rb_right. And there are no complicated operation.
> At page fault, there are no demands for accessing sorted-vma-list or access
> prev or next in many case. Except for stack-expansion, we always need a vma
> which contains page-fault address. Then, we can access vma's RB-tree in
> speculative way.
> Even if RB-tree rotation occurs while we walk tree for look-up, we just
> miss vma without oops. In other words, we can _try_ to find vma in lockless
> manner. If failed, retry is ok.... we take lock and access vma.
> 
> For lockess walking, this uses RCU and adds find_vma_speculative(). And
> per-vma wait-queue and reference count. This refcnt+wait_queue guarantees that
> there are no thread which access the vma when we call subsystem's unmap
> functions.
> 
> Test result on my tiny test program on 8core/2socket machine is here.
> This measures how many page fault can occur in 60sec in parallel.
> 
> [root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all-split 8
> 
>  Performance counter stats for './multi-fault-all-split 8' (5 runs):
> 
>        17481387  page-faults                ( +-   0.409% )
>       509914595  cache-misses               ( +-   0.239% )
> 
>    60.002277793  seconds time elapsed   ( +-   0.000% )
> 
> 
> [root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all-split 8
> 
> 
>  Performance counter stats for './multi-fault-all-split 8' (5 runs):
> 
>        35949073  page-faults                ( +-   0.364% )
>       473091100  cache-misses               ( +-   0.304% )
> 
>    60.005444117  seconds time elapsed   ( +-   0.004% )
> 
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

<snip>


> +/* called when vma is unlinked and wait for all racy access.*/
> +static void invalidate_vma_before_free(struct vm_area_struct *vma)
> +{
> +	atomic_dec(&vma->refcnt);
> +	wait_event(vma->wait_queue, !atomic_read(&vma->refcnt));
> +}

I think we have to make sure atomicity of both (atomic_dec and wait_event).

> +
>  /*
>   * Requires inode->i_mapping->i_mmap_lock
>   */
> @@ -238,7 +256,7 @@ static struct vm_area_struct *remove_vma
>  			removed_exe_file_vma(vma->vm_mm);
>  	}
>  	mpol_put(vma_policy(vma));
> -	kmem_cache_free(vm_area_cachep, vma);
> +	free_vma_rcu(vma);
>  	return next;
>  }
>  
> @@ -404,6 +422,8 @@ __vma_link_list(struct mm_struct *mm, st
>  void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
>  		struct rb_node **rb_link, struct rb_node *rb_parent)
>  {
> +	atomic_set(&vma->refcnt, 1);
> +	init_waitqueue_head(&vma->wait_queue);
>  	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
>  	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
>  }
> @@ -614,6 +634,7 @@ again:			remove_next = 1 + (end > next->
>  		 * us to remove next before dropping the locks.
>  		 */
>  		__vma_unlink(mm, next, vma);
> +		invalidate_vma_before_free(next);
>  		if (file)
>  			__remove_shared_vm_struct(next, file, mapping);
>  		if (next->anon_vma)
> @@ -640,7 +661,7 @@ again:			remove_next = 1 + (end > next->
>  		}
>  		mm->map_count--;
>  		mpol_put(vma_policy(next));
> -		kmem_cache_free(vm_area_cachep, next);
> +		free_vma_rcu(next);
>  		/*
>  		 * In mprotect's case 6 (see comments on vma_merge),
>  		 * we must remove another next too. It would clutter
> @@ -1544,6 +1565,55 @@ out:
>  }
>  
>  /*
> + * Returns vma which contains given address. This scans rb-tree in speculative
> + * way and increment a reference count if found. Even if vma exists in rb-tree,
> + * this function may return NULL in racy case. So, this function cannot be used
> + * for checking whether given address is valid or not.
> + */
> +struct vm_area_struct *
> +find_vma_speculative(struct mm_struct *mm, unsigned long addr)
> +{
> +	struct vm_area_struct *vma = NULL;
> +	struct vm_area_struct *vma_tmp;
> +	struct rb_node *rb_node;
> +
> +	if (unlikely(!mm))
> +		return NULL;;
> +
> +	rcu_read_lock();
> +	rb_node = rcu_dereference(mm->mm_rb.rb_node);
> +	vma = NULL;
> +	while (rb_node) {
> +		vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
> +
> +		if (vma_tmp->vm_end > addr) {
> +			vma = vma_tmp;
> +			if (vma_tmp->vm_start <= addr)
> +				break;
> +			rb_node = rcu_dereference(rb_node->rb_left);
> +		} else
> +			rb_node = rcu_dereference(rb_node->rb_right);
> +	}
> +	if (vma) {
> +		if ((vma->vm_start <= addr) && (addr < vma->vm_end)) {
> +			if (!atomic_inc_not_zero(&vma->refcnt))
> +				vma = NULL;
> +		} else
> +			vma = NULL;
> +	}
> +	rcu_read_unlock();
> +	return vma;
> +}
> +
> +void vma_put(struct vm_area_struct *vma)
> +{
> +	if ((atomic_dec_return(&vma->refcnt) == 1) &&
> +	    waitqueue_active(&vma->wait_queue))
> +		wake_up(&vma->wait_queue);
> +	return;
> +}
> +

Let's consider following case. 

CPU 0					CPU 1

find_vma_speculative(refcnt = 2)
					do_unmap 
					invaliate_vma_before_free(refcount = 1)
					wait_event
vma_put
refcnt = 0
skip wakeup 

Hmm.. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
