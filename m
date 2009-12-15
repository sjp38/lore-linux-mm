Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EE5A86B0085
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 04:19:29 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF9JR9I010751
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Dec 2009 18:19:27 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 95A8645DE70
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:19:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E8DE45DE6F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:19:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 295651DB8044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:19:26 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD57D1DB8041
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:19:25 +0900 (JST)
Date: Tue, 15 Dec 2009 18:16:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmotm][PATCH 5/5] mm : count lowmem rss
Message-Id: <20091215181623.1321f391.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091215180904.c307629f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091215180904.c307629f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, minchan.kim@gmail.com, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Some case of OOM-Kill is caused by memory shortage in lowmem area. For example,
NORMAL_ZONE is exhausted on x86-32/HIGHMEM kernel.

Now, oom-killer doesn't have no lowmem usage information of processes and
selects victim processes based on global memory usage information.
In bad case, this can cause chains of kills of innocent processes without
progress, oom-serial-killer.

For making oom-killer lowmem aware, this patch adds counters for accounting
lowmem usage per process. (patches for oom-killer is not included in this.)

Adding counter is easy but one of concern is the cost for new counter.
But this patch doesn't adds # of counting cost but adds "if" senetense
to check a page is lwomem.
With micro benchmark, almost no regression.

Changelog: 2009/12/14
 - makes get_xx_rss() to be not-inlined functions.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c       |    4 +-
 include/linux/mm.h       |   27 ++++++++++++---
 include/linux/mm_types.h |    7 ++--
 mm/filemap_xip.c         |    2 -
 mm/fremap.c              |    2 -
 mm/memory.c              |   80 ++++++++++++++++++++++++++++++++++++-----------
 mm/oom_kill.c            |    8 ++--
 mm/rmap.c                |   10 +++--
 mm/swapfile.c            |    2 -
 9 files changed, 105 insertions(+), 37 deletions(-)

Index: mmotm-2.6.32-Dec8-pth/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Dec8-pth/include/linux/mm_types.h
@@ -194,11 +194,14 @@ struct core_state {
 };
 
 enum {
-	MM_FILEPAGES,
-	MM_ANONPAGES,
+	MM_FILEPAGES,	/* file's rss is MM_FILEPAGES + MM_LOW_FILEPAGES */
+	MM_ANONPAGES,   /* anon`'s rss is MM_FILEPAGES + MM_LOW_FILEPAGES */
+	MM_FILE_LOWPAGES, /* pages from lower zones in file rss*/
+	MM_ANON_LOWPAGES, /* pages from lower zones in anon rss*/
 	MM_SWAPENTS,
 	NR_MM_COUNTERS
 };
+#define LOWMEM_COUNTER	2
 
 #if USE_SPLIT_PTLOCKS
 #define SPLIT_RSS_COUNTING
Index: mmotm-2.6.32-Dec8-pth/mm/memory.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/memory.c
+++ mmotm-2.6.32-Dec8-pth/mm/memory.c
@@ -137,7 +137,7 @@ void __sync_task_rss_stat(struct task_st
 	task->rss_stat.events = 0;
 }
 
-static void add_mm_counter_fast(struct mm_struct *mm, int member, int val)
+static void __add_mm_counter_fast(struct mm_struct *mm, int member, int val)
 {
 	struct task_struct *task = current;
 
@@ -146,8 +146,17 @@ static void add_mm_counter_fast(struct m
 	else
 		add_mm_counter(mm, member, val);
 }
-#define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member,1)
-#define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member,-1)
+static void add_mm_counter_fast(struct mm_struct *mm, int member,
+	int val, struct page *page)
+{
+	if (is_lowmem_page(page))
+		member += LOWMEM_COUNTER;
+	__add_mm_counter_fast(mm, member, val);
+}
+#define inc_mm_counter_fast(mm, member, page)\
+	add_mm_counter_fast(mm, member,1, page)
+#define dec_mm_counter_fast(mm, member, page)\
+	add_mm_counter_fast(mm, member,-1, page)
 
 /* sync counter once per 64 page faults */
 #define TASK_RSS_EVENTS_THRESH	(64)
@@ -183,8 +192,9 @@ void sync_mm_rss(struct task_struct *tas
 }
 #else
 
-#define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)
-#define dec_mm_counter_fast(mm, member) dec_mm_counter(mm, member)
+#define inc_mm_counter_fast(mm, member, page) inc_mm_counter_page(mm, member, page)
+#define dec_mm_counter_fast(mm, member, page) dec_mm_counter_page(mm, member, page)
+#define __add_mm_counter_fast(mm, member, val) add_mm_counter(mm, member, val)
 
 static void check_sync_rss_stat(struct task_struct *task)
 {
@@ -195,6 +205,30 @@ void sync_mm_rss(struct task_struct *tas
 }
 #endif
 
+unsigned long get_file_rss(struct mm_struct *mm)
+{
+	return get_mm_counter(mm, MM_ANONPAGES)
+		+ get_mm_counter(mm, MM_ANON_LOWPAGES);
+}
+
+unsigned long get_anon_rss(struct mm_struct *mm)
+{
+	return get_mm_counter(mm, MM_FILEPAGES)
+		+ get_mm_counter(mm, MM_FILE_LOWPAGES);
+}
+
+unsigned long get_low_rss(struct mm_struct *mm)
+{
+	return get_mm_counter(mm, MM_ANON_LOWPAGES)
+		+ get_mm_counter(mm, MM_FILE_LOWPAGES);
+}
+
+unsigned long get_mm_rss(struct mm_struct *mm)
+{
+	return get_file_rss(mm) + get_anon_rss(mm);
+}
+
+
 /*
  * If a p?d_bad entry is found while walking page tables, report
  * the error, before resetting entry to p?d_none.  Usually (but
@@ -714,12 +748,17 @@ copy_one_pte(struct mm_struct *dst_mm, s
 
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
+		int type;
+
 		get_page(page);
 		page_dup_rmap(page);
 		if (PageAnon(page))
-			rss[MM_ANONPAGES]++;
+			type = MM_ANONPAGES;
 		else
-			rss[MM_FILEPAGES]++;
+			type = MM_FILEPAGES;
+		if (is_lowmem_page(page))
+			type += LOWMEM_COUNTER;
+		rss[type]++;
 	}
 
 out_set_pte:
@@ -905,6 +944,7 @@ static unsigned long zap_pte_range(struc
 	pte_t *pte;
 	spinlock_t *ptl;
 	int rss[NR_MM_COUNTERS];
+	int type;
 
 	init_rss_vec(rss);
 
@@ -952,15 +992,18 @@ static unsigned long zap_pte_range(struc
 				set_pte_at(mm, addr, pte,
 					   pgoff_to_pte(page->index));
 			if (PageAnon(page))
-				rss[MM_ANONPAGES]--;
+				type = MM_ANONPAGES;
 			else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent) &&
 				    likely(!VM_SequentialReadHint(vma)))
 					mark_page_accessed(page);
-				rss[MM_FILEPAGES]--;
+				type = MM_FILEPAGES;
 			}
+			if (is_lowmem_page(page))
+				type += LOWMEM_COUNTER;
+			rss[type]--;
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
@@ -1621,7 +1664,7 @@ static int insert_page(struct vm_area_st
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter_fast(mm, MM_FILEPAGES);
+	inc_mm_counter_fast(mm, MM_FILEPAGES, page);
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2257,11 +2300,12 @@ gotten:
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
-				dec_mm_counter_fast(mm, MM_FILEPAGES);
-				inc_mm_counter_fast(mm, MM_ANONPAGES);
+				dec_mm_counter_fast(mm, MM_FILEPAGES, old_page);
+				inc_mm_counter_fast(mm, MM_ANONPAGES, new_page);
 			}
 		} else
-			inc_mm_counter_fast(mm, MM_ANONPAGES);
+			inc_mm_counter_fast(mm, MM_ANONPAGES, new_page);
+
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2694,8 +2738,9 @@ static int do_swap_page(struct mm_struct
 	 * discarded at swap_free().
 	 */
 
-	inc_mm_counter_fast(mm, MM_ANONPAGES);
-	dec_mm_counter_fast(mm, MM_SWAPENTS);
+	inc_mm_counter_fast(mm, MM_ANONPAGES, page);
+	/* SWAPENTS counter is not related to page..then use bare call */
+	__add_mm_counter_fast(mm, MM_SWAPENTS, -1);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -2779,7 +2824,7 @@ static int do_anonymous_page(struct mm_s
 	if (!pte_none(*page_table))
 		goto release;
 
-	inc_mm_counter_fast(mm, MM_ANONPAGES);
+	inc_mm_counter_fast(mm, MM_ANONPAGES, page);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
@@ -2933,10 +2978,10 @@ static int __do_fault(struct mm_struct *
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		if (anon) {
-			inc_mm_counter_fast(mm, MM_ANONPAGES);
+			inc_mm_counter_fast(mm, MM_ANONPAGES, page);
 			page_add_new_anon_rmap(page, vma, address);
 		} else {
-			inc_mm_counter_fast(mm, MM_FILEPAGES);
+			inc_mm_counter_fast(mm, MM_FILEPAGES, page);
 			page_add_file_rmap(page);
 			if (flags & FAULT_FLAG_WRITE) {
 				dirty_page = page;
Index: mmotm-2.6.32-Dec8-pth/mm/rmap.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/rmap.c
+++ mmotm-2.6.32-Dec8-pth/mm/rmap.c
@@ -815,9 +815,9 @@ int try_to_unmap_one(struct page *page, 
 
 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
 		if (PageAnon(page))
-			dec_mm_counter(mm, MM_ANONPAGES);
+			dec_mm_counter_page(mm, MM_ANONPAGES, page);
 		else
-			dec_mm_counter(mm, MM_FILEPAGES);
+			dec_mm_counter_page(mm, MM_FILEPAGES, page);
 		set_pte_at(mm, address, pte,
 				swp_entry_to_pte(make_hwpoison_entry(page)));
 	} else if (PageAnon(page)) {
@@ -839,7 +839,7 @@ int try_to_unmap_one(struct page *page, 
 					list_add(&mm->mmlist, &init_mm.mmlist);
 				spin_unlock(&mmlist_lock);
 			}
-			dec_mm_counter(mm, MM_ANONPAGES);
+			dec_mm_counter_page(mm, MM_ANONPAGES, page);
 			inc_mm_counter(mm, MM_SWAPENTS);
 		} else if (PAGE_MIGRATION) {
 			/*
@@ -858,7 +858,7 @@ int try_to_unmap_one(struct page *page, 
 		entry = make_migration_entry(page, pte_write(pteval));
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else
-		dec_mm_counter(mm, MM_FILEPAGES);
+		dec_mm_counter_page(mm, MM_FILEPAGES, page);
 
 	page_remove_rmap(page);
 	page_cache_release(page);
@@ -998,6 +998,8 @@ static int try_to_unmap_cluster(unsigned
 		page_remove_rmap(page);
 		page_cache_release(page);
 		dec_mm_counter(mm, MM_FILEPAGES);
+		if (is_lowmem_page(page))
+			dec_mm_counter(mm, MM_FILEPAGES);
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
Index: mmotm-2.6.32-Dec8-pth/mm/swapfile.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/swapfile.c
+++ mmotm-2.6.32-Dec8-pth/mm/swapfile.c
@@ -841,7 +841,7 @@ static int unuse_pte(struct vm_area_stru
 	}
 
 	dec_mm_counter(vma->vm_mm, MM_SWAPENTS);
-	inc_mm_counter(vma->vm_mm, MM_ANONPAGES);
+	inc_mm_counter_page(vma->vm_mm, MM_ANONPAGES, page);
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
Index: mmotm-2.6.32-Dec8-pth/mm/filemap_xip.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/filemap_xip.c
+++ mmotm-2.6.32-Dec8-pth/mm/filemap_xip.c
@@ -194,7 +194,7 @@ retry:
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush_notify(vma, address, pte);
 			page_remove_rmap(page);
-			dec_mm_counter(mm, MM_FILEPAGES);
+			dec_mm_counter_page(mm, MM_FILEPAGES, page);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			page_cache_release(page);
Index: mmotm-2.6.32-Dec8-pth/mm/fremap.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/fremap.c
+++ mmotm-2.6.32-Dec8-pth/mm/fremap.c
@@ -40,7 +40,7 @@ static void zap_pte(struct mm_struct *mm
 			page_remove_rmap(page);
 			page_cache_release(page);
 			update_hiwater_rss(mm);
-			dec_mm_counter(mm, MM_FILEPAGES);
+			dec_mm_counter_page(mm, MM_FILEPAGES, page);
 		}
 	} else {
 		if (!pte_file(pte))
Index: mmotm-2.6.32-Dec8-pth/include/linux/mm.h
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/include/linux/mm.h
+++ mmotm-2.6.32-Dec8-pth/include/linux/mm.h
@@ -939,11 +939,10 @@ static inline void dec_mm_counter(struct
 
 #endif /* !USE_SPLIT_PTLOCKS */
 
-static inline unsigned long get_mm_rss(struct mm_struct *mm)
-{
-	return get_mm_counter(mm, MM_FILEPAGES) +
-		get_mm_counter(mm, MM_ANONPAGES);
-}
+unsigned long get_mm_rss(struct mm_struct *mm);
+unsigned long get_file_rss(struct mm_struct *mm);
+unsigned long get_anon_rss(struct mm_struct *mm);
+unsigned long get_low_rss(struct mm_struct *mm);
 
 static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
 {
@@ -978,6 +977,23 @@ static inline void setmax_mm_hiwater_rss
 		*maxrss = hiwater_rss;
 }
 
+/* Utility for lowmem counting */
+static inline void
+inc_mm_counter_page(struct mm_struct *mm, int member, struct page *page)
+{
+	if (unlikely(is_lowmem_page(page)))
+		member += LOWMEM_COUNTER;
+	inc_mm_counter(mm, member);
+}
+
+static inline void
+dec_mm_counter_page(struct mm_struct *mm, int member, struct page *page)
+{
+	if (unlikely(is_lowmem_page(page)))
+		member += LOWMEM_COUNTER;
+	dec_mm_counter(mm, member);
+}
+
 void sync_mm_rss(struct task_struct *task, struct mm_struct *mm);
 
 /*
@@ -1034,6 +1050,7 @@ int __pmd_alloc(struct mm_struct *mm, pu
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
 int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
 
+
 /*
  * The following ifdef needed to get the 4level-fixup.h header to work.
  * Remove it when 4level-fixup.h has been removed.
Index: mmotm-2.6.32-Dec8-pth/fs/proc/task_mmu.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/fs/proc/task_mmu.c
+++ mmotm-2.6.32-Dec8-pth/fs/proc/task_mmu.c
@@ -68,11 +68,11 @@ unsigned long task_vsize(struct mm_struc
 int task_statm(struct mm_struct *mm, int *shared, int *text,
 	       int *data, int *resident)
 {
-	*shared = get_mm_counter(mm, MM_FILEPAGES);
+	*shared = get_file_rss(mm);
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
-	*resident = *shared + get_mm_counter(mm, MM_ANONPAGES);
+	*resident = *shared + get_anon_rss(mm);
 	return mm->total_vm;
 }
 
Index: mmotm-2.6.32-Dec8-pth/mm/oom_kill.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/oom_kill.c
+++ mmotm-2.6.32-Dec8-pth/mm/oom_kill.c
@@ -398,11 +398,13 @@ static void __oom_kill_task(struct task_
 
 	if (verbose)
 		printk(KERN_ERR "Killed process %d (%s) "
-		       "vsz:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
+		       "vsz:%lukB, anon-rss:%lukB, file-rss:%lukB "
+			"lowmem %lukB\n",
 		       task_pid_nr(p), p->comm,
 		       K(p->mm->total_vm),
-		       K(get_mm_counter(p->mm, MM_ANONPAGES)),
-		       K(get_mm_counter(p->mm, MM_FILEPAGES)));
+		       K(get_anon_rss(p->mm)),
+		       K(get_file_rss(p->mm)),
+			K(get_low_rss(p->mm)));
 	task_unlock(p);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
