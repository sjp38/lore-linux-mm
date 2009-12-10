Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C3C3F6B0047
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 03:04:36 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA84XCQ025660
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Dec 2009 17:04:33 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52F4545DE4F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:04:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3155145DE4D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:04:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A1271DB803C
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:04:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B0BDC1DB803F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:04:32 +0900 (JST)
Date: Thu, 10 Dec 2009 17:01:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC mm][PATCH 5/5] counting lowmem rss per mm
Message-Id: <20091210170137.8031e4cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mingo@elte.hu
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

Following is the test result of micro-benchmark of parallel page faults.
Bigger page fault number indicates better scalability.
(measured under USE_SPLIT_PTLOCKS environemt)
[Before lowmem counter]
 Performance counter stats for './multi-fault 2' (5 runs):

       46997471  page-faults                ( +-   0.720% )
     1004100076  cache-references           ( +-   0.734% )
      180959964  cache-misses               ( +-   0.374% )
 29263437363580464  bus-cycles                 ( +-   0.002% )

   60.003315683  seconds time elapsed   ( +-   0.004% )

3.85 miss/faults
[After lowmem counter]
 Performance counter stats for './multi-fault 2' (5 runs):

       45976947  page-faults                ( +-   0.405% )
      992296954  cache-references           ( +-   0.860% )
      183961537  cache-misses               ( +-   0.473% )
 29261902069414016  bus-cycles                 ( +-   0.002% )

   60.001403261  seconds time elapsed   ( +-   0.000% )

4.0 miss/faults.

Then, small cost is added. But I think this is within reasonable
range.

If you have good idea for improve this number, it's welcome.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c       |    4 +--
 include/linux/mm.h       |   38 +++++++++++++++++++++++++++++-
 include/linux/mm_types.h |    7 +++--
 mm/filemap_xip.c         |    2 -
 mm/fremap.c              |    2 -
 mm/memory.c              |   59 +++++++++++++++++++++++++++++++++--------------
 mm/oom_kill.c            |    8 +++---
 mm/rmap.c                |   10 ++++---
 mm/swapfile.c            |    2 -
 9 files changed, 100 insertions(+), 32 deletions(-)

Index: mmotm-2.6.32-Dec8/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Dec8.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Dec8/include/linux/mm_types.h
@@ -200,11 +200,14 @@ typedef unsigned long mm_counter_t;
 #endif /* !USE_SPLIT_PTLOCKS */
 
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
 
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
Index: mmotm-2.6.32-Dec8/mm/memory.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/memory.c
+++ mmotm-2.6.32-Dec8/mm/memory.c
@@ -156,12 +156,26 @@ static void add_mm_counter_fast(struct m
 		add_mm_counter(mm, member, val);
 }
 
-#define inc_mm_counter_fast(mm, member)	add_mm_counter_fast(mm, member, 1)
-#define dec_mm_counter_fast(mm, member)	add_mm_counter_fast(mm, member, -1)
+static void add_mm_counter_page_fast(struct mm_struct *mm,
+		int member, int val, struct page *page)
+{
+	if (unlikely(is_lowmem_page(page)))
+			member += LOWMEM_COUNTER;
+	return add_mm_counter_fast(mm, member, val);
+}
+
+#define inc_mm_counter_fast(mm, member, page) \
+	add_mm_counter_page_fast(mm, member, 1, page)
+#define dec_mm_counter_fast(mm, member, page) \
+	add_mm_counter_page_fast(mm, member, -1, page)
 #else
 
-#define inc_mm_counter_fast(mm, member)	inc_mm_counter(mm, member)
-#define dec_mm_counter_fast(mm, member)	dec_mm_counter(mm, member)
+#define add_mm_counter_fast(mm, member, val) add_mm_counter(mm, member, val)
+
+#define inc_mm_counter_fast(mm, member, page)\
+	inc_mm_counter_page(mm, member, page)
+#define dec_mm_counter_fast(mm, member, page)\
+	dec_mm_counter_page(mm, member, page)
 
 #endif
 
@@ -685,12 +699,17 @@ copy_one_pte(struct mm_struct *dst_mm, s
 
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
@@ -876,6 +895,7 @@ static unsigned long zap_pte_range(struc
 	pte_t *pte;
 	spinlock_t *ptl;
 	int rss[NR_MM_COUNTERS];
+	int type;
 
 	init_rss_vec(rss);
 
@@ -923,15 +943,18 @@ static unsigned long zap_pte_range(struc
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
@@ -1592,7 +1615,7 @@ static int insert_page(struct vm_area_st
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter_fast(mm, MM_FILEPAGES);
+	inc_mm_counter_fast(mm, MM_FILEPAGES, page);
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2228,11 +2251,12 @@ gotten:
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
@@ -2665,8 +2689,9 @@ static int do_swap_page(struct mm_struct
 	 * discarded at swap_free().
 	 */
 
-	inc_mm_counter_fast(mm, MM_ANONPAGES);
-	dec_mm_counter_fast(mm, MM_SWAPENTS);
+	inc_mm_counter_fast(mm, MM_ANONPAGES, page);
+	/* SWAPENTS counter is not related to page..then use bare call */
+	add_mm_counter_fast(mm, MM_SWAPENTS, -1);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -2750,7 +2775,7 @@ static int do_anonymous_page(struct mm_s
 	if (!pte_none(*page_table))
 		goto release;
 
-	inc_mm_counter_fast(mm, MM_ANONPAGES);
+	inc_mm_counter_fast(mm, MM_ANONPAGES, page);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
@@ -2904,10 +2929,10 @@ static int __do_fault(struct mm_struct *
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
Index: mmotm-2.6.32-Dec8/mm/rmap.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/rmap.c
+++ mmotm-2.6.32-Dec8/mm/rmap.c
@@ -815,9 +815,9 @@ int try_to_unmap_one(struct page *page, 
 
 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
 		if (PageAnon(page)) /* Not increments swapents counter */
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
Index: mmotm-2.6.32-Dec8/mm/swapfile.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/swapfile.c
+++ mmotm-2.6.32-Dec8/mm/swapfile.c
@@ -841,7 +841,7 @@ static int unuse_pte(struct vm_area_stru
 	}
 
 	dec_mm_counter(vma->vm_mm, MM_SWAPENTS);
-	inc_mm_counter(vma->vm_mm, MM_ANONPAGES);
+	inc_mm_counter_page(vma->vm_mm, MM_ANONPAGES, page);
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
Index: mmotm-2.6.32-Dec8/mm/filemap_xip.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/filemap_xip.c
+++ mmotm-2.6.32-Dec8/mm/filemap_xip.c
@@ -194,7 +194,7 @@ retry:
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush_notify(vma, address, pte);
 			page_remove_rmap(page);
-			dec_mm_counter(mm, MM_FILEPAGES);
+			dec_mm_counter_page(mm, MM_FILEPAGES, page);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			page_cache_release(page);
Index: mmotm-2.6.32-Dec8/mm/fremap.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/fremap.c
+++ mmotm-2.6.32-Dec8/mm/fremap.c
@@ -40,7 +40,7 @@ static void zap_pte(struct mm_struct *mm
 			page_remove_rmap(page);
 			page_cache_release(page);
 			update_hiwater_rss(mm);
-			dec_mm_counter(mm, MM_FILEPAGES);
+			dec_mm_counter_page(mm, MM_FILEPAGES, page);
 		}
 	} else {
 		if (!pte_file(pte))
Index: mmotm-2.6.32-Dec8/include/linux/mm.h
===================================================================
--- mmotm-2.6.32-Dec8.orig/include/linux/mm.h
+++ mmotm-2.6.32-Dec8/include/linux/mm.h
@@ -977,8 +977,27 @@ static inline void exit_mm_counters(void
 }
 #endif /* !USE_SPLIT_PTLOCKS */
 
+static inline unsigned long get_file_rss(struct mm_struct *mm)
+{
+	return get_mm_counter(mm, MM_FILEPAGES) +
+		get_mm_counter(mm, MM_FILE_LOWPAGES);
+}
+
+static inline unsigned long get_anon_rss(struct mm_struct *mm)
+{
+	return get_mm_counter(mm, MM_ANONPAGES) +
+		get_mm_counter(mm, MM_ANON_LOWPAGES);
+}
+
+static inline unsigned long get_low_rss(struct mm_struct *mm)
+{
+	return get_mm_counter(mm, MM_FILE_LOWPAGES) +
+		get_mm_counter(mm, MM_ANON_LOWPAGES);
+}
+
 #define get_mm_rss(mm)					\
-	(get_mm_counter(mm, MM_FILEPAGES) + get_mm_counter(mm, MM_ANONPAGES))
+	(get_file_rss(mm) + get_anon_rss(mm))
+
 #define update_hiwater_rss(mm)	do {			\
 	unsigned long _rss = get_mm_rss(mm);		\
 	if ((mm)->hiwater_rss < _rss)			\
@@ -1008,6 +1027,23 @@ static inline unsigned long get_mm_hiwat
 	return max(mm->hiwater_vm, mm->total_vm);
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
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
Index: mmotm-2.6.32-Dec8/fs/proc/task_mmu.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/fs/proc/task_mmu.c
+++ mmotm-2.6.32-Dec8/fs/proc/task_mmu.c
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
 
Index: mmotm-2.6.32-Dec8/mm/oom_kill.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/oom_kill.c
+++ mmotm-2.6.32-Dec8/mm/oom_kill.c
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
