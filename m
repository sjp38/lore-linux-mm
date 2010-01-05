Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 53AA76005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 19:29:22 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o050TJSf006761
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Jan 2010 09:29:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AC4A45DE56
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:29:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4244C45DE4F
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:29:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 08FC01DB8062
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:29:19 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 996021DB805D
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:29:18 +0900 (JST)
Date: Tue, 5 Jan 2010 09:25:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-Id: <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100104182813.753545361@chello.nl>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 04 Jan 2010 19:24:35 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Generic speculative fault handler, tries to service a pagefault
> without holding mmap_sem.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>


I'm sorry if I miss something...how does this patch series avoid
that vma is removed while __do_fault()->vma->vm_ops->fault() is called ?
("vma is removed" means all other things as freeing file struct etc..)

Thanks,
-Kame




> ---
>  include/linux/mm.h |    2 +
>  mm/memory.c        |   59 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 60 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -1998,7 +1998,7 @@ again:
>  	if (!*ptep)
>  		goto out;
>  
> -	if (vma_is_dead(vma, seq))
> +	if (vma && vma_is_dead(vma, seq))
>  		goto unlock;
>  
>  	unpin_page_tables();
> @@ -3112,6 +3112,63 @@ int handle_mm_fault(struct mm_struct *mm
>  	return handle_pte_fault(mm, vma, address, entry, pmd, flags, 0);
>  }
>  
> +int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
> +		unsigned int flags)
> +{
> +	pmd_t *pmd = NULL;
> +	pte_t *pte, entry;
> +	spinlock_t *ptl;
> +	struct vm_area_struct *vma;
> +	unsigned int seq;
> +	int ret = VM_FAULT_RETRY;
> +	int dead;
> +
> +	__set_current_state(TASK_RUNNING);
> +	flags |= FAULT_FLAG_SPECULATIVE;
> +
> +	count_vm_event(PGFAULT);
> +
> +	rcu_read_lock();
> +	if (!pte_map_lock(mm, NULL, address, pmd, flags, 0, &pte, &ptl))
> +		goto out_unlock;
> +
> +	vma = find_vma(mm, address);
> +
> +	if (!vma)
> +		goto out_unmap;
> +
> +	dead = RB_EMPTY_NODE(&vma->vm_rb);
> +	seq = vma->vm_sequence.sequence;
> +	/*
> +	 * Matches both the wmb in write_seqcount_begin/end() and
> +	 * the wmb in detach_vmas_to_be_unmapped()/__unlink_vma().
> +	 */
> +	smp_rmb();
> +	if (dead || seq & 1)
> +		goto out_unmap;
> +
> +	if (!(vma->vm_end > address && vma->vm_start <= address))
> +		goto out_unmap;
> +
> +	if (read_seqcount_retry(&vma->vm_sequence, seq))
> +		goto out_unmap;
> +
> +	entry = *pte;
> +
> +	pte_unmap_unlock(pte, ptl);
> +
> +	ret = handle_pte_fault(mm, vma, address, entry, pmd, flags, seq);
> +
> +out_unlock:
> +	rcu_read_unlock();
> +	return ret;
> +
> +out_unmap:
> +	pte_unmap_unlock(pte, ptl);
> +	goto out_unlock;
> +}
> +
> +
>  #ifndef __PAGETABLE_PUD_FOLDED
>  /*
>   * Allocate page upper directory.
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -829,6 +829,8 @@ int invalidate_inode_page(struct page *p
>  #ifdef CONFIG_MMU
>  extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			unsigned long address, unsigned int flags);
> +extern int handle_speculative_fault(struct mm_struct *mm,
> +			unsigned long address, unsigned int flags);
>  #else
>  static inline int handle_mm_fault(struct mm_struct *mm,
>  			struct vm_area_struct *vma, unsigned long address,
> 
> -- 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
