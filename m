Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1102B6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 18:54:32 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA5NodJT015382
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 08:50:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E271445DE6E
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 08:50:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C2E3D45DE4D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 08:50:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AA1D1E18003
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 08:50:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C5F6E18002
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 08:50:38 +0900 (JST)
Date: Fri, 6 Nov 2009 08:48:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] show per-process swap usage via procfs
Message-Id: <20091106084806.7503b165.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262360911050711k47a63896xe4915157664cb822@mail.gmail.com>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360911050711k47a63896xe4915157664cb822@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, cl@linux-foundation.org, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009 00:11:32 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi, Kame.
> 
Hi,

<snip>
> > A /*
> > @@ -597,7 +600,9 @@ copy_one_pte(struct mm_struct *dst_mm, s
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  &src_mm->mmlist);
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A spin_unlock(&mmlist_lock);
> > A  A  A  A  A  A  A  A  A  A  A  A }
> > - A  A  A  A  A  A  A  A  A  A  A  if (is_write_migration_entry(entry) &&
> > + A  A  A  A  A  A  A  A  A  A  A  if (!is_migration_entry(entry))
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  rss[2]++;
> 
> First thought I come to is that we believe !is_migration_entry(entry) equal
> swap entry?
> We began supporting HWPOISON.
> HWPOISON would be rare event so some less exact swap accouting may
> be allowed, I think.  Is this enough to jusitfy that?
> 
Ah, ok, I'll fix here.


> > + A  A  A  A  A  A  A  A  A  A  A  else if (is_write_migration_entry(entry) &&
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A is_cow_mapping(vm_flags)) {
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A /*
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  * COW mappings require pages in both parent
> > @@ -648,11 +653,11 @@ static int copy_pte_range(struct mm_stru
> > A  A  A  A pte_t *src_pte, *dst_pte;
> > A  A  A  A spinlock_t *src_ptl, *dst_ptl;
> > A  A  A  A int progress = 0;
> > - A  A  A  int rss[2];
> > + A  A  A  int rss[3];
> > A  A  A  A swp_entry_t entry = (swp_entry_t){0};
> >
> > A again:
> > - A  A  A  rss[1] = rss[0] = 0;
> > + A  A  A  rss[2] = rss[1] = rss[0] = 0;
> > A  A  A  A dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
> > A  A  A  A if (!dst_pte)
> > A  A  A  A  A  A  A  A return -ENOMEM;
> > @@ -688,7 +693,7 @@ again:
> > A  A  A  A arch_leave_lazy_mmu_mode();
> > A  A  A  A spin_unlock(src_ptl);
> > A  A  A  A pte_unmap_nested(orig_src_pte);
> > - A  A  A  add_mm_rss(dst_mm, rss[0], rss[1]);
> > + A  A  A  add_mm_rss(dst_mm, rss[0], rss[1], rss[2]);
> > A  A  A  A pte_unmap_unlock(orig_dst_pte, dst_ptl);
> > A  A  A  A cond_resched();
> >
> > @@ -818,6 +823,7 @@ static unsigned long zap_pte_range(struc
> > A  A  A  A spinlock_t *ptl;
> > A  A  A  A int file_rss = 0;
> > A  A  A  A int anon_rss = 0;
> > + A  A  A  int swap_usage = 0;
> >
> > A  A  A  A pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> > A  A  A  A arch_enter_lazy_mmu_mode();
> > @@ -887,13 +893,18 @@ static unsigned long zap_pte_range(struc
> > A  A  A  A  A  A  A  A if (pte_file(ptent)) {
> > A  A  A  A  A  A  A  A  A  A  A  A if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A print_bad_pte(vma, addr, ptent, NULL);
> > - A  A  A  A  A  A  A  } else if
> > - A  A  A  A  A  A  A  A  (unlikely(!free_swap_and_cache(pte_to_swp_entry(ptent))))
> > - A  A  A  A  A  A  A  A  A  A  A  print_bad_pte(vma, addr, ptent, NULL);
> > + A  A  A  A  A  A  A  } else {
> > + A  A  A  A  A  A  A  A  A  A  A  swp_entry_t ent = pte_to_swp_entry(ptent);
> > +
> > + A  A  A  A  A  A  A  A  A  A  A  if (!is_migration_entry(ent))
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  swap_usage--;
> 
> ditto
> 
ok, will do.


> > + A  A  A  A  A  A  A  A  A  A  A  if (unlikely(!free_swap_and_cache(ent)))
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  print_bad_pte(vma, addr, ptent, NULL);
> > + A  A  A  A  A  A  A  }
> > A  A  A  A  A  A  A  A pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
> > A  A  A  A } while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
> >
> > - A  A  A  add_mm_rss(mm, file_rss, anon_rss);
> > + A  A  A  add_mm_rss(mm, file_rss, anon_rss, swap_usage);
> > A  A  A  A arch_leave_lazy_mmu_mode();
> > A  A  A  A pte_unmap_unlock(pte - 1, ptl);
> >
> > @@ -2595,6 +2606,7 @@ static int do_swap_page(struct mm_struct
> > A  A  A  A  */
> >
> > A  A  A  A inc_mm_counter(mm, anon_rss);
> > + A  A  A  dec_mm_counter(mm, swap_usage);
> > A  A  A  A pte = mk_pte(page, vma->vm_page_prot);
> > A  A  A  A if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
> > A  A  A  A  A  A  A  A pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> > Index: mmotm-2.6.32-Nov2/mm/swapfile.c
> > ===================================================================
> > --- mmotm-2.6.32-Nov2.orig/mm/swapfile.c
> > +++ mmotm-2.6.32-Nov2/mm/swapfile.c
> > @@ -837,6 +837,7 @@ static int unuse_pte(struct vm_area_stru
> > A  A  A  A }
> >
> > A  A  A  A inc_mm_counter(vma->vm_mm, anon_rss);
> > + A  A  A  dec_mm_counter(vma->vm_mm, swap_usage);
> > A  A  A  A get_page(page);
> > A  A  A  A set_pte_at(vma->vm_mm, addr, pte,
> > A  A  A  A  A  A  A  A  A  pte_mkold(mk_pte(page, vma->vm_page_prot)));
> > Index: mmotm-2.6.32-Nov2/fs/proc/task_mmu.c
> > ===================================================================
> > --- mmotm-2.6.32-Nov2.orig/fs/proc/task_mmu.c
> > +++ mmotm-2.6.32-Nov2/fs/proc/task_mmu.c
> > @@ -17,7 +17,7 @@
> > A void task_mem(struct seq_file *m, struct mm_struct *mm)
> > A {
> > A  A  A  A unsigned long data, text, lib;
> > - A  A  A  unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
> > + A  A  A  unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss, swap;
> >
> > A  A  A  A /*
> > A  A  A  A  * Note: to minimize their overhead, mm maintains hiwater_vm and
> > @@ -36,6 +36,7 @@ void task_mem(struct seq_file *m, struct
> > A  A  A  A data = mm->total_vm - mm->shared_vm - mm->stack_vm;
> > A  A  A  A text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
> > A  A  A  A lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
> > + A  A  A  swap = get_mm_counter(mm, swap_usage);
> > A  A  A  A seq_printf(m,
> > A  A  A  A  A  A  A  A "VmPeak:\t%8lu kB\n"
> > A  A  A  A  A  A  A  A "VmSize:\t%8lu kB\n"
> > @@ -46,7 +47,8 @@ void task_mem(struct seq_file *m, struct
> > A  A  A  A  A  A  A  A "VmStk:\t%8lu kB\n"
> > A  A  A  A  A  A  A  A "VmExe:\t%8lu kB\n"
> > A  A  A  A  A  A  A  A "VmLib:\t%8lu kB\n"
> > - A  A  A  A  A  A  A  "VmPTE:\t%8lu kB\n",
> > + A  A  A  A  A  A  A  "VmPTE:\t%8lu kB\n"
> > + A  A  A  A  A  A  A  "VmSwap:\t%8lu kB\n",
> > A  A  A  A  A  A  A  A hiwater_vm << (PAGE_SHIFT-10),
> > A  A  A  A  A  A  A  A (total_vm - mm->reserved_vm) << (PAGE_SHIFT-10),
> > A  A  A  A  A  A  A  A mm->locked_vm << (PAGE_SHIFT-10),
> > @@ -54,7 +56,8 @@ void task_mem(struct seq_file *m, struct
> > A  A  A  A  A  A  A  A total_rss << (PAGE_SHIFT-10),
> > A  A  A  A  A  A  A  A data << (PAGE_SHIFT-10),
> > A  A  A  A  A  A  A  A mm->stack_vm << (PAGE_SHIFT-10), text, lib,
> > - A  A  A  A  A  A  A  (PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10);
> > + A  A  A  A  A  A  A  (PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10,
> > + A  A  A  A  A  A  A  swap << (PAGE_SHIFT - 10));
> > A }
> >
> > A unsigned long task_vsize(struct mm_struct *mm)
> > Index: mmotm-2.6.32-Nov2/mm/rmap.c
> > ===================================================================
> > --- mmotm-2.6.32-Nov2.orig/mm/rmap.c
> > +++ mmotm-2.6.32-Nov2/mm/rmap.c
> > @@ -834,6 +834,7 @@ static int try_to_unmap_one(struct page
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A spin_unlock(&mmlist_lock);
> > A  A  A  A  A  A  A  A  A  A  A  A }
> > A  A  A  A  A  A  A  A  A  A  A  A dec_mm_counter(mm, anon_rss);
> > + A  A  A  A  A  A  A  A  A  A  A  inc_mm_counter(mm, swap_usage);
> > A  A  A  A  A  A  A  A } else if (PAGE_MIGRATION) {
> > A  A  A  A  A  A  A  A  A  A  A  A /*
> > A  A  A  A  A  A  A  A  A  A  A  A  * Store the pfn of the page in a special migration
> > Index: mmotm-2.6.32-Nov2/kernel/fork.c
> > ===================================================================
> > --- mmotm-2.6.32-Nov2.orig/kernel/fork.c
> > +++ mmotm-2.6.32-Nov2/kernel/fork.c
> > @@ -454,6 +454,7 @@ static struct mm_struct * mm_init(struct
> > A  A  A  A mm->nr_ptes = 0;
> > A  A  A  A set_mm_counter(mm, file_rss, 0);
> > A  A  A  A set_mm_counter(mm, anon_rss, 0);
> > + A  A  A  set_mm_counter(mm, swap_usage, 0);
> > A  A  A  A spin_lock_init(&mm->page_table_lock);
> > A  A  A  A mm->free_area_cache = TASK_UNMAPPED_BASE;
> > A  A  A  A mm->cached_hole_size = ~0UL;
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org. A For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 
> That's good.
> From now on, we can chagne scanning of pte to find swap pte
> in smaps_pte_rangem, too. :)
> 

Thanks, I'll update this.
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
