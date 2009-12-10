Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D0DB56B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 02:36:23 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA7aKom025921
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Dec 2009 16:36:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7E8A45DE52
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:36:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C511045DE4E
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:36:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 802DD1DB803B
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:36:19 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 179641DB8037
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:36:19 +0900 (JST)
Date: Thu, 10 Dec 2009 16:33:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC mm][PATCH 1/5] mm counter cleanup
Message-Id: <20091210163326.28bb7eb8.kamezawa.hiroyu@jp.fujitsu.com>
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

Now, per-mm statistics counter is defined by macro in sched.h

This patch modifies it to
  - Define them in mm.h as inline functions
  - Use array instead of macro's name creation. For making easier to add
    new coutners.

This patch is for reducing patch size in future patch to modify
implementation of per-mm counter.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c       |    4 -
 include/linux/mm.h       |   95 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |   21 ++++++----
 include/linux/sched.h    |   54 --------------------------
 kernel/fork.c            |    6 +-
 kernel/tsacct.c          |    1 
 mm/filemap_xip.c         |    2 
 mm/fremap.c              |    2 
 mm/memory.c              |   58 +++++++++++++++++-----------
 mm/oom_kill.c            |    4 -
 mm/rmap.c                |   10 ++--
 mm/swapfile.c            |    2 
 12 files changed, 161 insertions(+), 98 deletions(-)

Index: mmotm-2.6.32-Dec8/include/linux/mm.h
===================================================================
--- mmotm-2.6.32-Dec8.orig/include/linux/mm.h
+++ mmotm-2.6.32-Dec8/include/linux/mm.h
@@ -868,6 +868,101 @@ extern int mprotect_fixup(struct vm_area
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
+	atomic_long_set(&(mm)->counters[member], value);
+}
+
+static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
+{
+	return (unsigned long)atomic_long_read(&(mm)->counters[member]);
+}
+
+static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	atomic_long_add(value, &(mm)->counters[member]);
+}
+
+static inline void inc_mm_counter(struct mm_struct *mm, int member)
+{
+	atomic_long_inc(&(mm)->counters[member]);
+}
+
+static inline void dec_mm_counter(struct mm_struct *mm, int member)
+{
+	atomic_long_dec(&(mm)->counters[member]);
+}
+
+#else  /* !USE_SPLIT_PTLOCKS */
+/*
+ * The mm counters are protected by its page_table_lock,
+ * so can be incremented directly.
+ */
+static inline void set_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	mm->counters[member] = value;
+}
+
+static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
+{
+	return mm->counters[member];
+}
+
+static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	mm->counters[member] += value;
+}
+
+static inline void inc_mm_counter(struct mm_struct *mm, int member)
+{
+	mm->counters[member]++;
+}
+
+static inline void dec_mm_counter(struct mm_struct *mm, int member)
+{
+	mm->counters[member]--;
+}
+
+#endif /* !USE_SPLIT_PTLOCKS */
+
+#define get_mm_rss(mm)					\
+	(get_mm_counter(mm, MM_FILEPAGES) + get_mm_counter(mm, MM_ANONPAGES))
+#define update_hiwater_rss(mm)	do {			\
+	unsigned long _rss = get_mm_rss(mm);		\
+	if ((mm)->hiwater_rss < _rss)			\
+		(mm)->hiwater_rss = _rss;		\
+} while (0)
+#define update_hiwater_vm(mm)	do {			\
+	if ((mm)->hiwater_vm < (mm)->total_vm)		\
+		(mm)->hiwater_vm = (mm)->total_vm;	\
+} while (0)
+
+static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
+{
+	return max(mm->hiwater_rss, get_mm_rss(mm));
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
+static inline unsigned long get_mm_hiwater_vm(struct mm_struct *mm)
+{
+	return max(mm->hiwater_vm, mm->total_vm);
+}
 
 /*
  * A callback you can register to apply pressure to ageable caches.
Index: mmotm-2.6.32-Dec8/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Dec8.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Dec8/include/linux/mm_types.h
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
@@ -199,6 +193,18 @@ struct core_state {
 	struct completion startup;
 };
 
+#if USE_SPLIT_PTLOCKS
+typedef atomic_long_t mm_counter_t;
+#else  /* !USE_SPLIT_PTLOCKS */
+typedef unsigned long mm_counter_t;
+#endif /* !USE_SPLIT_PTLOCKS */
+
+enum {
+	MM_FILEPAGES,
+	MM_ANONPAGES,
+	NR_MM_COUNTERS
+};
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
@@ -226,8 +232,7 @@ struct mm_struct {
 	/* Special counters, in some configurations protected by the
 	 * page_table_lock, in other configurations by being atomic.
 	 */
-	mm_counter_t _file_rss;
-	mm_counter_t _anon_rss;
+	mm_counter_t counters[NR_MM_COUNTERS];
 
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
Index: mmotm-2.6.32-Dec8/include/linux/sched.h
===================================================================
--- mmotm-2.6.32-Dec8.orig/include/linux/sched.h
+++ mmotm-2.6.32-Dec8/include/linux/sched.h
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
Index: mmotm-2.6.32-Dec8/mm/memory.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/memory.c
+++ mmotm-2.6.32-Dec8/mm/memory.c
@@ -376,12 +376,21 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	return 0;
 }
 
-static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
+static inline void init_rss_vec(int *rss)
 {
-	if (file_rss)
-		add_mm_counter(mm, file_rss, file_rss);
-	if (anon_rss)
-		add_mm_counter(mm, anon_rss, anon_rss);
+	int i;
+
+	for (i = 0; i < NR_MM_COUNTERS; i++)
+		rss[i] = 0;
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
@@ -632,7 +641,10 @@ copy_one_pte(struct mm_struct *dst_mm, s
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
@@ -648,11 +660,12 @@ static int copy_pte_range(struct mm_stru
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
@@ -688,7 +701,7 @@ again:
 	arch_leave_lazy_mmu_mode();
 	spin_unlock(src_ptl);
 	pte_unmap_nested(orig_src_pte);
-	add_mm_rss(dst_mm, rss[0], rss[1]);
+	add_mm_rss_vec(dst_mm, rss);
 	pte_unmap_unlock(orig_dst_pte, dst_ptl);
 	cond_resched();
 
@@ -816,8 +829,9 @@ static unsigned long zap_pte_range(struc
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
@@ -863,14 +877,14 @@ static unsigned long zap_pte_range(struc
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
@@ -893,7 +907,7 @@ static unsigned long zap_pte_range(struc
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
 
-	add_mm_rss(mm, file_rss, anon_rss);
+	add_mm_rss_vec(mm, rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
@@ -1527,7 +1541,7 @@ static int insert_page(struct vm_area_st
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter(mm, file_rss);
+	inc_mm_counter(mm, MM_FILEPAGES);
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2163,11 +2177,11 @@ gotten:
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
@@ -2600,7 +2614,7 @@ static int do_swap_page(struct mm_struct
 	 * discarded at swap_free().
 	 */
 
-	inc_mm_counter(mm, anon_rss);
+	inc_mm_counter(mm, MM_ANONPAGES);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -2684,7 +2698,7 @@ static int do_anonymous_page(struct mm_s
 	if (!pte_none(*page_table))
 		goto release;
 
-	inc_mm_counter(mm, anon_rss);
+	inc_mm_counter(mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
@@ -2838,10 +2852,10 @@ static int __do_fault(struct mm_struct *
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
Index: mmotm-2.6.32-Dec8/fs/proc/task_mmu.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/fs/proc/task_mmu.c
+++ mmotm-2.6.32-Dec8/fs/proc/task_mmu.c
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
 
Index: mmotm-2.6.32-Dec8/kernel/fork.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/kernel/fork.c
+++ mmotm-2.6.32-Dec8/kernel/fork.c
@@ -446,6 +446,8 @@ static void mm_init_aio(struct mm_struct
 
 static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 {
+	int i;
+
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
@@ -454,8 +456,8 @@ static struct mm_struct * mm_init(struct
 		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
 	mm->core_state = NULL;
 	mm->nr_ptes = 0;
-	set_mm_counter(mm, file_rss, 0);
-	set_mm_counter(mm, anon_rss, 0);
+	for (i = 0; i < NR_MM_COUNTERS; i++)
+		set_mm_counter(mm, i, 0);
 	spin_lock_init(&mm->page_table_lock);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
Index: mmotm-2.6.32-Dec8/kernel/tsacct.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/kernel/tsacct.c
+++ mmotm-2.6.32-Dec8/kernel/tsacct.c
@@ -21,6 +21,7 @@
 #include <linux/tsacct_kern.h>
 #include <linux/acct.h>
 #include <linux/jiffies.h>
+#include <linux/mm.h>
 
 /*
  * fill in basic accounting fields
Index: mmotm-2.6.32-Dec8/mm/filemap_xip.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/filemap_xip.c
+++ mmotm-2.6.32-Dec8/mm/filemap_xip.c
@@ -194,7 +194,7 @@ retry:
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush_notify(vma, address, pte);
 			page_remove_rmap(page);
-			dec_mm_counter(mm, file_rss);
+			dec_mm_counter(mm, MM_FILEPAGES);
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
-			dec_mm_counter(mm, file_rss);
+			dec_mm_counter(mm, MM_FILEPAGES);
 		}
 	} else {
 		if (!pte_file(pte))
Index: mmotm-2.6.32-Dec8/mm/oom_kill.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/oom_kill.c
+++ mmotm-2.6.32-Dec8/mm/oom_kill.c
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
Index: mmotm-2.6.32-Dec8/mm/rmap.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/rmap.c
+++ mmotm-2.6.32-Dec8/mm/rmap.c
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
Index: mmotm-2.6.32-Dec8/mm/swapfile.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/swapfile.c
+++ mmotm-2.6.32-Dec8/mm/swapfile.c
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
