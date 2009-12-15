Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AD0D36B0078
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 04:14:38 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF9EJXG000524
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Dec 2009 18:14:19 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3FA245DE62
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:14:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BBFD245DE55
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:14:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8270F1DB803E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:14:18 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EE7951DB8041
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:14:17 +0900 (JST)
Date: Tue, 15 Dec 2009 18:11:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmotm][PATCH 1/5] clean up mm_counter
Message-Id: <20091215181116.ee2c31f7.kamezawa.hiroyu@jp.fujitsu.com>
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

Now, per-mm statistics counter is defined by macro in sched.h

This patch modifies it to
  - defined in mm.h as inlinf functions
  - use array instead of macro's name creation.

This patch is for reducing patch size in future patch to modify
implementation of per-mm counter.

Changelog: 2009/12/14
 - added a struct rss_stat instead of bare counters.
 - use memset instead of for() loop.
 - rewrite macros into static inline functions.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c       |    4 -
 include/linux/mm.h       |  104 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |   33 +++++++++-----
 include/linux/sched.h    |   54 ------------------------
 kernel/fork.c            |    3 -
 kernel/tsacct.c          |    1 
 mm/filemap_xip.c         |    2 
 mm/fremap.c              |    2 
 mm/memory.c              |   56 +++++++++++++++----------
 mm/oom_kill.c            |    4 -
 mm/rmap.c                |   10 ++--
 mm/swapfile.c            |    2 
 12 files changed, 174 insertions(+), 101 deletions(-)

Index: mmotm-2.6.32-Dec8-pth/include/linux/mm.h
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/include/linux/mm.h
+++ mmotm-2.6.32-Dec8-pth/include/linux/mm.h
@@ -868,6 +868,110 @@ extern int mprotect_fixup(struct vm_area
  */
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages);
+/*
+ * per-process(per-mm_struct) statistics.
+ */
+#if USE_SPLIT_PTLOCKS
+/*
+ * The mm counters are not protected by its page_table_lock,
+ * so must be incremented atomically.
+ */
+static inline void set_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	atomic_long_set(&mm->rss_stat.count[member], value);
+}
+
+static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
+{
+	return (unsigned long)atomic_long_read(&mm->rss_stat.count[member]);
+}
+
+static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	atomic_long_add(value, &mm->rss_stat.count[member]);
+}
+
+static inline void inc_mm_counter(struct mm_struct *mm, int member)
+{
+	atomic_long_inc(&mm->rss_stat.count[member]);
+}
+
+static inline void dec_mm_counter(struct mm_struct *mm, int member)
+{
+	atomic_long_dec(&mm->rss_stat.count[member]);
+}
+
+#else  /* !USE_SPLIT_PTLOCKS */
+/*
+ * The mm counters are protected by its page_table_lock,
+ * so can be incremented directly.
+ */
+static inline void set_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	mm->rss_stat.count[member] = value;
+}
+
+static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
+{
+	return mm->rss_stat.count[member];
+}
+
+static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	mm->rss_stat.count[member] += value;
+}
+
+static inline void inc_mm_counter(struct mm_struct *mm, int member)
+{
+	mm->rss_stat.count[member]++;
+}
+
+static inline void dec_mm_counter(struct mm_struct *mm, int member)
+{
+	mm->rss_stat.count[member]--;
+}
+
+#endif /* !USE_SPLIT_PTLOCKS */
+
+static inline unsigned long get_mm_rss(struct mm_struct *mm)
+{
+	return get_mm_counter(mm, MM_FILEPAGES) +
+		get_mm_counter(mm, MM_ANONPAGES);
+}
+
+static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
+{
+	return max(mm->hiwater_rss, get_mm_rss(mm));
+}
+
+static inline unsigned long get_mm_hiwater_vm(struct mm_struct *mm)
+{
+	return max(mm->hiwater_vm, mm->total_vm);
+}
+
+static inline void update_hiwater_rss(struct mm_struct *mm)
+{
+	unsigned long _rss = get_mm_rss(mm);
+
+	if ((mm)->hiwater_rss < _rss)
+		(mm)->hiwater_rss = _rss;
+}
+
+static inline void update_hiwater_vm(struct mm_struct *mm)
+{
+	if (mm->hiwater_vm < mm->total_vm)
+		mm->hiwater_vm = mm->total_vm;
+}
+
+static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
+					 struct mm_struct *mm)
+{
+	unsigned long hiwater_rss = get_mm_hiwater_rss(mm);
+
+	if (*maxrss < hiwater_rss)
+		*maxrss = hiwater_rss;
+}
+
 
 /*
  * A callback you can register to apply pressure to ageable caches.
Index: mmotm-2.6.32-Dec8-pth/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Dec8-pth/include/linux/mm_types.h
@@ -24,12 +24,6 @@ struct address_space;
 
 #define USE_SPLIT_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 
-#if USE_SPLIT_PTLOCKS
-typedef atomic_long_t mm_counter_t;
-#else  /* !USE_SPLIT_PTLOCKS */
-typedef unsigned long mm_counter_t;
-#endif /* !USE_SPLIT_PTLOCKS */
-
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -199,6 +193,22 @@ struct core_state {
 	struct completion startup;
 };
 
+enum {
+	MM_FILEPAGES,
+	MM_ANONPAGES,
+	NR_MM_COUNTERS
+};
+
+#if USE_SPLIT_PTLOCKS
+struct mm_rss_stat {
+	atomic_long_t count[NR_MM_COUNTERS];
+};
+#else  /* !USE_SPLIT_PTLOCKS */
+struct mm_rss_stat {
+	unsigned long count[NR_MM_COUNTERS];
+};
+#endif /* !USE_SPLIT_PTLOCKS */
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
@@ -223,11 +233,6 @@ struct mm_struct {
 						 * by mmlist_lock
 						 */
 
-	/* Special counters, in some configurations protected by the
-	 * page_table_lock, in other configurations by being atomic.
-	 */
-	mm_counter_t _file_rss;
-	mm_counter_t _anon_rss;
 
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
@@ -240,6 +245,12 @@ struct mm_struct {
 
 	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
 
+	/*
+	 * Special counters, in some configurations protected by the
+	 * page_table_lock, in other configurations by being atomic.
+	 */
+	struct mm_rss_stat rss_stat;
+
 	struct linux_binfmt *binfmt;
 
 	cpumask_t cpu_vm_mask;
Index: mmotm-2.6.32-Dec8-pth/include/linux/sched.h
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/include/linux/sched.h
+++ mmotm-2.6.32-Dec8-pth/include/linux/sched.h
@@ -385,60 +385,6 @@ arch_get_unmapped_area_topdown(struct fi
 extern void arch_unmap_area(struct mm_struct *, unsigned long);
 extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
 
-#if USE_SPLIT_PTLOCKS
-/*
- * The mm counters are not protected by its page_table_lock,
- * so must be incremented atomically.
- */
-#define set_mm_counter(mm, member, value) atomic_long_set(&(mm)->_##member, value)
-#define get_mm_counter(mm, member) ((unsigned long)atomic_long_read(&(mm)->_##member))
-#define add_mm_counter(mm, member, value) atomic_long_add(value, &(mm)->_##member)
-#define inc_mm_counter(mm, member) atomic_long_inc(&(mm)->_##member)
-#define dec_mm_counter(mm, member) atomic_long_dec(&(mm)->_##member)
-
-#else  /* !USE_SPLIT_PTLOCKS */
-/*
- * The mm counters are protected by its page_table_lock,
- * so can be incremented directly.
- */
-#define set_mm_counter(mm, member, value) (mm)->_##member = (value)
-#define get_mm_counter(mm, member) ((mm)->_##member)
-#define add_mm_counter(mm, member, value) (mm)->_##member += (value)
-#define inc_mm_counter(mm, member) (mm)->_##member++
-#define dec_mm_counter(mm, member) (mm)->_##member--
-
-#endif /* !USE_SPLIT_PTLOCKS */
-
-#define get_mm_rss(mm)					\
-	(get_mm_counter(mm, file_rss) + get_mm_counter(mm, anon_rss))
-#define update_hiwater_rss(mm)	do {			\
-	unsigned long _rss = get_mm_rss(mm);		\
-	if ((mm)->hiwater_rss < _rss)			\
-		(mm)->hiwater_rss = _rss;		\
-} while (0)
-#define update_hiwater_vm(mm)	do {			\
-	if ((mm)->hiwater_vm < (mm)->total_vm)		\
-		(mm)->hiwater_vm = (mm)->total_vm;	\
-} while (0)
-
-static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
-{
-	return max(mm->hiwater_rss, get_mm_rss(mm));
-}
-
-static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
-					 struct mm_struct *mm)
-{
-	unsigned long hiwater_rss = get_mm_hiwater_rss(mm);
-
-	if (*maxrss < hiwater_rss)
-		*maxrss = hiwater_rss;
-}
-
-static inline unsigned long get_mm_hiwater_vm(struct mm_struct *mm)
-{
-	return max(mm->hiwater_vm, mm->total_vm);
-}
 
 extern void set_dumpable(struct mm_struct *mm, int value);
 extern int get_dumpable(struct mm_struct *mm);
Index: mmotm-2.6.32-Dec8-pth/mm/memory.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/memory.c
+++ mmotm-2.6.32-Dec8-pth/mm/memory.c
@@ -121,6 +121,7 @@ static int __init init_zero_pfn(void)
 }
 core_initcall(init_zero_pfn);
 
+
 /*
  * If a p?d_bad entry is found while walking page tables, report
  * the error, before resetting entry to p?d_none.  Usually (but
@@ -376,12 +377,18 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	return 0;
 }
 
-static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
+static inline void init_rss_vec(int *rss)
 {
-	if (file_rss)
-		add_mm_counter(mm, file_rss, file_rss);
-	if (anon_rss)
-		add_mm_counter(mm, anon_rss, anon_rss);
+	memset(rss, 0, sizeof(int) * NR_MM_COUNTERS);
+}
+
+static inline void add_mm_rss_vec(struct mm_struct *mm, int *rss)
+{
+	int i;
+
+	for (i = 0; i < NR_MM_COUNTERS; i++)
+		if (rss[i])
+			add_mm_counter(mm, i, rss[i]);
 }
 
 /*
@@ -632,7 +639,10 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page);
-		rss[PageAnon(page)]++;
+		if (PageAnon(page))
+			rss[MM_ANONPAGES]++;
+		else
+			rss[MM_FILEPAGES]++;
 	}
 
 out_set_pte:
@@ -648,11 +658,12 @@ static int copy_pte_range(struct mm_stru
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
-	int rss[2];
+	int rss[NR_MM_COUNTERS];
 	swp_entry_t entry = (swp_entry_t){0};
 
 again:
-	rss[1] = rss[0] = 0;
+	init_rss_vec(rss);
+
 	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
 		return -ENOMEM;
@@ -688,7 +699,7 @@ again:
 	arch_leave_lazy_mmu_mode();
 	spin_unlock(src_ptl);
 	pte_unmap_nested(orig_src_pte);
-	add_mm_rss(dst_mm, rss[0], rss[1]);
+	add_mm_rss_vec(dst_mm, rss);
 	pte_unmap_unlock(orig_dst_pte, dst_ptl);
 	cond_resched();
 
@@ -816,8 +827,9 @@ static unsigned long zap_pte_range(struc
 	struct mm_struct *mm = tlb->mm;
 	pte_t *pte;
 	spinlock_t *ptl;
-	int file_rss = 0;
-	int anon_rss = 0;
+	int rss[NR_MM_COUNTERS];
+
+	init_rss_vec(rss);
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -863,14 +875,14 @@ static unsigned long zap_pte_range(struc
 				set_pte_at(mm, addr, pte,
 					   pgoff_to_pte(page->index));
 			if (PageAnon(page))
-				anon_rss--;
+				rss[MM_ANONPAGES]--;
 			else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent) &&
 				    likely(!VM_SequentialReadHint(vma)))
 					mark_page_accessed(page);
-				file_rss--;
+				rss[MM_FILEPAGES]--;
 			}
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
@@ -893,7 +905,7 @@ static unsigned long zap_pte_range(struc
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
 
-	add_mm_rss(mm, file_rss, anon_rss);
+	add_mm_rss_vec(mm, rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
@@ -1527,7 +1539,7 @@ static int insert_page(struct vm_area_st
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter(mm, file_rss);
+	inc_mm_counter(mm, MM_FILEPAGES);
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2163,11 +2175,11 @@ gotten:
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
-				dec_mm_counter(mm, file_rss);
-				inc_mm_counter(mm, anon_rss);
+				dec_mm_counter(mm, MM_FILEPAGES);
+				inc_mm_counter(mm, MM_ANONPAGES);
 			}
 		} else
-			inc_mm_counter(mm, anon_rss);
+			inc_mm_counter(mm, MM_ANONPAGES);
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2600,7 +2612,7 @@ static int do_swap_page(struct mm_struct
 	 * discarded at swap_free().
 	 */
 
-	inc_mm_counter(mm, anon_rss);
+	inc_mm_counter(mm, MM_ANONPAGES);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -2684,7 +2696,7 @@ static int do_anonymous_page(struct mm_s
 	if (!pte_none(*page_table))
 		goto release;
 
-	inc_mm_counter(mm, anon_rss);
+	inc_mm_counter(mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
@@ -2838,10 +2850,10 @@ static int __do_fault(struct mm_struct *
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		if (anon) {
-			inc_mm_counter(mm, anon_rss);
+			inc_mm_counter(mm, MM_ANONPAGES);
 			page_add_new_anon_rmap(page, vma, address);
 		} else {
-			inc_mm_counter(mm, file_rss);
+			inc_mm_counter(mm, MM_FILEPAGES);
 			page_add_file_rmap(page);
 			if (flags & FAULT_FLAG_WRITE) {
 				dirty_page = page;
Index: mmotm-2.6.32-Dec8-pth/fs/proc/task_mmu.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/fs/proc/task_mmu.c
+++ mmotm-2.6.32-Dec8-pth/fs/proc/task_mmu.c
@@ -65,11 +65,11 @@ unsigned long task_vsize(struct mm_struc
 int task_statm(struct mm_struct *mm, int *shared, int *text,
 	       int *data, int *resident)
 {
-	*shared = get_mm_counter(mm, file_rss);
+	*shared = get_mm_counter(mm, MM_FILEPAGES);
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
-	*resident = *shared + get_mm_counter(mm, anon_rss);
+	*resident = *shared + get_mm_counter(mm, MM_ANONPAGES);
 	return mm->total_vm;
 }
 
Index: mmotm-2.6.32-Dec8-pth/kernel/fork.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/kernel/fork.c
+++ mmotm-2.6.32-Dec8-pth/kernel/fork.c
@@ -454,8 +454,7 @@ static struct mm_struct * mm_init(struct
 		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
 	mm->core_state = NULL;
 	mm->nr_ptes = 0;
-	set_mm_counter(mm, file_rss, 0);
-	set_mm_counter(mm, anon_rss, 0);
+	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
Index: mmotm-2.6.32-Dec8-pth/kernel/tsacct.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/kernel/tsacct.c
+++ mmotm-2.6.32-Dec8-pth/kernel/tsacct.c
@@ -21,6 +21,7 @@
 #include <linux/tsacct_kern.h>
 #include <linux/acct.h>
 #include <linux/jiffies.h>
+#include <linux/mm.h>
 
 /*
  * fill in basic accounting fields
Index: mmotm-2.6.32-Dec8-pth/mm/filemap_xip.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/filemap_xip.c
+++ mmotm-2.6.32-Dec8-pth/mm/filemap_xip.c
@@ -194,7 +194,7 @@ retry:
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush_notify(vma, address, pte);
 			page_remove_rmap(page);
-			dec_mm_counter(mm, file_rss);
+			dec_mm_counter(mm, MM_FILEPAGES);
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
-			dec_mm_counter(mm, file_rss);
+			dec_mm_counter(mm, MM_FILEPAGES);
 		}
 	} else {
 		if (!pte_file(pte))
Index: mmotm-2.6.32-Dec8-pth/mm/oom_kill.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/oom_kill.c
+++ mmotm-2.6.32-Dec8-pth/mm/oom_kill.c
@@ -401,8 +401,8 @@ static void __oom_kill_task(struct task_
 		       "vsz:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		       task_pid_nr(p), p->comm,
 		       K(p->mm->total_vm),
-		       K(get_mm_counter(p->mm, anon_rss)),
-		       K(get_mm_counter(p->mm, file_rss)));
+		       K(get_mm_counter(p->mm, MM_ANONPAGES)),
+		       K(get_mm_counter(p->mm, MM_FILEPAGES)));
 	task_unlock(p);
 
 	/*
Index: mmotm-2.6.32-Dec8-pth/mm/rmap.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/rmap.c
+++ mmotm-2.6.32-Dec8-pth/mm/rmap.c
@@ -815,9 +815,9 @@ int try_to_unmap_one(struct page *page, 
 
 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
 		if (PageAnon(page))
-			dec_mm_counter(mm, anon_rss);
+			dec_mm_counter(mm, MM_ANONPAGES);
 		else
-			dec_mm_counter(mm, file_rss);
+			dec_mm_counter(mm, MM_FILEPAGES);
 		set_pte_at(mm, address, pte,
 				swp_entry_to_pte(make_hwpoison_entry(page)));
 	} else if (PageAnon(page)) {
@@ -839,7 +839,7 @@ int try_to_unmap_one(struct page *page, 
 					list_add(&mm->mmlist, &init_mm.mmlist);
 				spin_unlock(&mmlist_lock);
 			}
-			dec_mm_counter(mm, anon_rss);
+			dec_mm_counter(mm, MM_ANONPAGES);
 		} else if (PAGE_MIGRATION) {
 			/*
 			 * Store the pfn of the page in a special migration
@@ -857,7 +857,7 @@ int try_to_unmap_one(struct page *page, 
 		entry = make_migration_entry(page, pte_write(pteval));
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else
-		dec_mm_counter(mm, file_rss);
+		dec_mm_counter(mm, MM_FILEPAGES);
 
 	page_remove_rmap(page);
 	page_cache_release(page);
@@ -996,7 +996,7 @@ static int try_to_unmap_cluster(unsigned
 
 		page_remove_rmap(page);
 		page_cache_release(page);
-		dec_mm_counter(mm, file_rss);
+		dec_mm_counter(mm, MM_FILEPAGES);
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
Index: mmotm-2.6.32-Dec8-pth/mm/swapfile.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/swapfile.c
+++ mmotm-2.6.32-Dec8-pth/mm/swapfile.c
@@ -840,7 +840,7 @@ static int unuse_pte(struct vm_area_stru
 		goto out;
 	}
 
-	inc_mm_counter(vma->vm_mm, anon_rss);
+	inc_mm_counter(vma->vm_mm, MM_ANONPAGES);
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
