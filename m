Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 388E26B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 03:02:11 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA826in004208
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Dec 2009 17:02:06 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 917FE45DE64
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:02:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 42C5245DE51
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:02:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 196B01DB8041
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:02:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 97D441DB803F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:02:04 +0900 (JST)
Date: Thu, 10 Dec 2009 16:59:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC mm][PATCH 3/5] counting swap ents per mm
Message-Id: <20091210165911.97850977.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>


One of frequent questions from users about memory management is
what numbers of swap ents are user for processes. And this information will
give some hints to oom-killer.

Besides we can count the number of swapents per a process by scanning
/proc/<pid>/smaps, this is very slow and not good for usual process information
handler which works like 'ps' or 'top'.
(ps or top is now enough slow..)

This patch adds a counter of swapents to mm_counter and update is at 
each swap events. Information is exported via /proc/<pid>/status file as

[kamezawa@bluextal ~]$ cat /proc/self/status
Name:   cat
State:  R (running)
Tgid:   2904
Pid:    2904
PPid:   2862
TracerPid:      0
Uid:    500     500     500     500
Gid:    500     500     500     500
FDSize: 256
Groups: 500
VmPeak:    82696 kB
VmSize:    82696 kB
VmLck:         0 kB
VmHWM:       504 kB
VmRSS:       504 kB
VmData:      172 kB
VmStk:        84 kB
VmExe:        48 kB
VmLib:      1568 kB
VmPTE:        40 kB
VmSwap:        0 kB <============== this.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c       |    9 ++++++---
 include/linux/mm_types.h |    1 +
 mm/memory.c              |   16 ++++++++++++----
 mm/rmap.c                |    3 ++-
 mm/swapfile.c            |    1 +
 5 files changed, 22 insertions(+), 8 deletions(-)

Index: mmotm-2.6.32-Dec8/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Dec8.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Dec8/include/linux/mm_types.h
@@ -202,6 +202,7 @@ typedef unsigned long mm_counter_t;
 enum {
 	MM_FILEPAGES,
 	MM_ANONPAGES,
+	MM_SWAPENTS,
 	NR_MM_COUNTERS
 };
 
Index: mmotm-2.6.32-Dec8/mm/memory.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/memory.c
+++ mmotm-2.6.32-Dec8/mm/memory.c
@@ -650,7 +650,9 @@ copy_one_pte(struct mm_struct *dst_mm, s
 						 &src_mm->mmlist);
 				spin_unlock(&mmlist_lock);
 			}
-			if (is_write_migration_entry(entry) &&
+			if (likely(!non_swap_entry(entry)))
+				rss[MM_SWAPENTS]++;
+			else if (is_write_migration_entry(entry) &&
 					is_cow_mapping(vm_flags)) {
 				/*
 				 * COW mappings require pages in both parent
@@ -945,9 +947,14 @@ static unsigned long zap_pte_range(struc
 		if (pte_file(ptent)) {
 			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
 				print_bad_pte(vma, addr, ptent, NULL);
-		} else if
-		  (unlikely(!free_swap_and_cache(pte_to_swp_entry(ptent))))
-			print_bad_pte(vma, addr, ptent, NULL);
+		} else {
+			swp_entry_t entry = pte_to_swp_entry(ptent);
+
+			if (!non_swap_entry(entry))
+				rss[MM_SWAPENTS]--;
+		  	if (unlikely(!free_swap_and_cache(entry)))
+				print_bad_pte(vma, addr, ptent, NULL);
+		}
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
 
@@ -2659,6 +2666,7 @@ static int do_swap_page(struct mm_struct
 	 */
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
+	dec_mm_counter_fast(mm, MM_SWAPENTS);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
Index: mmotm-2.6.32-Dec8/mm/rmap.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/rmap.c
+++ mmotm-2.6.32-Dec8/mm/rmap.c
@@ -814,7 +814,7 @@ int try_to_unmap_one(struct page *page, 
 	update_hiwater_rss(mm);
 
 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
-		if (PageAnon(page))
+		if (PageAnon(page)) /* Not increments swapents counter */
 			dec_mm_counter(mm, MM_ANONPAGES);
 		else
 			dec_mm_counter(mm, MM_FILEPAGES);
@@ -840,6 +840,7 @@ int try_to_unmap_one(struct page *page, 
 				spin_unlock(&mmlist_lock);
 			}
 			dec_mm_counter(mm, MM_ANONPAGES);
+			inc_mm_counter(mm, MM_SWAPENTS);
 		} else if (PAGE_MIGRATION) {
 			/*
 			 * Store the pfn of the page in a special migration
Index: mmotm-2.6.32-Dec8/mm/swapfile.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/swapfile.c
+++ mmotm-2.6.32-Dec8/mm/swapfile.c
@@ -840,6 +840,7 @@ static int unuse_pte(struct vm_area_stru
 		goto out;
 	}
 
+	dec_mm_counter(vma->vm_mm, MM_SWAPENTS);
 	inc_mm_counter(vma->vm_mm, MM_ANONPAGES);
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
Index: mmotm-2.6.32-Dec8/fs/proc/task_mmu.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/fs/proc/task_mmu.c
+++ mmotm-2.6.32-Dec8/fs/proc/task_mmu.c
@@ -16,7 +16,7 @@
 
 void task_mem(struct seq_file *m, struct mm_struct *mm)
 {
-	unsigned long data, text, lib;
+	unsigned long data, text, lib, swap;
 	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
 
 	/*
@@ -36,6 +36,7 @@ void task_mem(struct seq_file *m, struct
 	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
 	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
+	swap = get_mm_counter(mm, MM_SWAPENTS);
 	seq_printf(m,
 		"VmPeak:\t%8lu kB\n"
 		"VmSize:\t%8lu kB\n"
@@ -46,7 +47,8 @@ void task_mem(struct seq_file *m, struct
 		"VmStk:\t%8lu kB\n"
 		"VmExe:\t%8lu kB\n"
 		"VmLib:\t%8lu kB\n"
-		"VmPTE:\t%8lu kB\n",
+		"VmPTE:\t%8lu kB\n"
+		"VmSwap:\t%8lu kB\n",
 		hiwater_vm << (PAGE_SHIFT-10),
 		(total_vm - mm->reserved_vm) << (PAGE_SHIFT-10),
 		mm->locked_vm << (PAGE_SHIFT-10),
@@ -54,7 +56,8 @@ void task_mem(struct seq_file *m, struct
 		total_rss << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
-		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10);
+		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10,
+		swap << (PAGE_SHIFT-10));
 }
 
 unsigned long task_vsize(struct mm_struct *mm)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
