Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 822076B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 21:57:19 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA62vGuo027418
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 11:57:16 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 437A42AF1A3
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 11:57:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D30945DE4F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 11:57:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F2A4B1DB8044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 11:57:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 922821DB803A
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 11:57:15 +0900 (JST)
Date: Fri, 6 Nov 2009 11:54:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC MM] swap counters
Message-Id: <20091106115440.2e6ac39f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911051703320.10180@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>
	<alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1>
	<alpine.DEB.1.10.0911051703320.10180@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009 17:05:19 -0500 (EST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> Kamezawa sans swap counters on top of it all. Now we need no additional
> atomic ops in VM fast paths.
> 
Thanks, I'll rewrite mine in this way.
(As Minchan pointed out, is_migration_entry() is not enough.)

I'll post rebased one in reply to this.

Regards,
-Kame


> ---
>  fs/proc/task_mmu.c       |   14 +++++++++++---
>  include/linux/mm_types.h |    1 +
>  mm/memory.c              |   17 +++++++++++++----
>  mm/rmap.c                |    1 +
>  mm/swapfile.c            |    1 +
>  5 files changed, 27 insertions(+), 7 deletions(-)
> 
> Index: linux-2.6/fs/proc/task_mmu.c
> ===================================================================
> --- linux-2.6.orig/fs/proc/task_mmu.c	2009-11-05 15:58:48.000000000 -0600
> +++ linux-2.6/fs/proc/task_mmu.c	2009-11-05 16:03:12.000000000 -0600
> @@ -16,8 +16,9 @@
> 
>  void task_mem(struct seq_file *m, struct mm_struct *mm)
>  {
> -	unsigned long data, text, lib;
> +	unsigned long data, text, lib, swap;
>  	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
> +	int cpu;
> 
>  	/*
>  	 * Note: to minimize their overhead, mm maintains hiwater_vm and
> @@ -36,6 +37,11 @@ void task_mem(struct seq_file *m, struct
>  	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
>  	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
>  	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
> +
> +	swap = 0;
> +	for_each_possible_cpu(cpu)
> +		swap += per_cpu(mm->rss->swap, cpu);
> +
>  	seq_printf(m,
>  		"VmPeak:\t%8lu kB\n"
>  		"VmSize:\t%8lu kB\n"
> @@ -46,7 +52,8 @@ void task_mem(struct seq_file *m, struct
>  		"VmStk:\t%8lu kB\n"
>  		"VmExe:\t%8lu kB\n"
>  		"VmLib:\t%8lu kB\n"
> -		"VmPTE:\t%8lu kB\n",
> +		"VmPTE:\t%8lu kB\n"
> +		"VmSwap:\t%8lu kB\n",
>  		hiwater_vm << (PAGE_SHIFT-10),
>  		(total_vm - mm->reserved_vm) << (PAGE_SHIFT-10),
>  		mm->locked_vm << (PAGE_SHIFT-10),
> @@ -54,7 +61,8 @@ void task_mem(struct seq_file *m, struct
>  		total_rss << (PAGE_SHIFT-10),
>  		data << (PAGE_SHIFT-10),
>  		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
> -		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10);
> +		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10,
> +		swap << (PAGE_SHIFT - 10));
>  }
> 
>  unsigned long task_vsize(struct mm_struct *mm)
> Index: linux-2.6/include/linux/mm_types.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm_types.h	2009-11-05 15:51:38.000000000 -0600
> +++ linux-2.6/include/linux/mm_types.h	2009-11-05 15:51:55.000000000 -0600
> @@ -28,6 +28,7 @@ struct address_space;
>  struct mm_counter {
>  	long file;
>  	long anon;
> +	long swap;
>  	long readers;
>  };
> 
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c	2009-11-05 15:52:00.000000000 -0600
> +++ linux-2.6/mm/memory.c	2009-11-05 16:01:48.000000000 -0600
> @@ -587,7 +587,9 @@ copy_one_pte(struct mm_struct *dst_mm, s
>  						 &src_mm->mmlist);
>  				spin_unlock(&mmlist_lock);
>  			}
> -			if (is_write_migration_entry(entry) &&
> +			if (!is_migration_entry(entry))
> +				__this_cpu_inc(src_mm->rss->swap);
> +			else if (is_write_migration_entry(entry) &&
>  					is_cow_mapping(vm_flags)) {
>  				/*
>  				 * COW mappings require pages in both parent
> @@ -864,9 +866,15 @@ static unsigned long zap_pte_range(struc
>  		if (pte_file(ptent)) {
>  			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
>  				print_bad_pte(vma, addr, ptent, NULL);
> -		} else if
> -		  (unlikely(!free_swap_and_cache(pte_to_swp_entry(ptent))))
> -			print_bad_pte(vma, addr, ptent, NULL);
> +		} else {
> +			swp_entry_t ent = pte_to_swp_entry(ptent);
> +
> +			if (!is_migration_entry(ent))
> +				__this_cpu_dec(mm->rss->swap);
> +
> +			if (unlikely(!free_swap_and_cache(ent)))
> +				print_bad_pte(vma, addr, ptent, NULL);
> +		}
>  		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
>  	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
> 
> @@ -2569,6 +2577,7 @@ static int do_swap_page(struct mm_struct
>  	 */
> 
>  	__this_cpu_inc(mm->rss->anon);
> +	__this_cpu_dec(mm->rss->swap);
>  	pte = mk_pte(page, vma->vm_page_prot);
>  	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
>  		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c	2009-11-05 15:57:51.000000000 -0600
> +++ linux-2.6/mm/rmap.c	2009-11-05 15:58:43.000000000 -0600
> @@ -830,6 +830,7 @@ static int try_to_unmap_one(struct page
>  				spin_unlock(&mmlist_lock);
>  			}
>  			__this_cpu_dec(mm->rss->anon);
> +			__this_cpu_inc(mm->rss->swap);
>  		} else if (PAGE_MIGRATION) {
>  			/*
>  			 * Store the pfn of the page in a special migration
> Index: linux-2.6/mm/swapfile.c
> ===================================================================
> --- linux-2.6.orig/mm/swapfile.c	2009-11-05 15:57:15.000000000 -0600
> +++ linux-2.6/mm/swapfile.c	2009-11-05 15:57:36.000000000 -0600
> @@ -832,6 +832,7 @@ static int unuse_pte(struct vm_area_stru
>  	}
> 
>  	__this_cpu_inc(vma->vm_mm->rss->anon);
> +	__this_cpu_dec(vma->vm_mm->rss->swap);
>  	get_page(page);
>  	set_pte_at(vma->vm_mm, addr, pte,
>  		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
