Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C80166007E3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 20:32:13 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB31W33d027694
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Dec 2009 10:32:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C2BF45DE83
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 10:32:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9564545DE71
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 10:31:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DCFE1DB803E
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 10:31:57 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CF871DF800C
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 10:31:54 +0900 (JST)
Date: Thu, 3 Dec 2009 10:28:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][mmotm][PATCH] percpu mm struct counter cache
Message-Id: <20091203102851.daeb940c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

Christophs's mm_counter+percpu implemtation has scalability at updates but
read-side had some problems. Inspired by that, I tried to write percpu-cache
counter + synchronization method. My own tiny benchmark shows something good
but this patch's hooks may summon other troubles...

Now, I start from sharing codes here. Any comments are welcome.
(Especially, moving hooks to somewhere better is my concern.)
My test proram will be posted in reply to this mail.

Regards,
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch is for implemanting light-weight per-mm statistics.
Now, when split-pagetable-lock is used, statistics per mm struct
is maintainer by atomic_long_t value. This costs one atomic_inc()
under page_table_lock and if multi-thread program runs and shares
mm_struct, this tend to cause cache-miss+atomic_ops.

This patch adds per-cpu mm statistics cache and sync it in periodically.
Cached Information are synchronized into mm_struct at
  - tick
  - context_switch.
  if there is difference.

Tiny test progam on x86-64/4core/2socket machine shows (small) improvements.
This test program measures # of page faults on cpu  0 and 4.
(Using all 8cpus, most of time is used for spinlock and you can't see
 benefits of this patch..)

[Before Patch]
Performance counter stats for './multi-fault 2' (5 runs):

       44282223  page-faults                ( +-   0.912% )
     1015540330  cache-references           ( +-   1.701% )
      210497140  cache-misses               ( +-   0.731% )
 29262804803383988  bus-cycles                 ( +-   0.003% )

   60.003401467  seconds time elapsed   ( +-   0.004% )

 4.75 miss/faults
 660825108.1564714580837551899777 bus-cycles/faults

[After Patch]
Performance counter stats for './multi-fault 2' (5 runs):

       45543398  page-faults                ( +-   0.499% )
     1031865896  cache-references           ( +-   2.720% )
      184901499  cache-misses               ( +-   0.626% )
 29261889737265056  bus-cycles                 ( +-   0.002% )

   60.001218501  seconds time elapsed   ( +-   0.000% )

 4.05 miss/faults
 642505632.5 bus-cycles/faults

Note: to enable split-pagetable-lock, you have to disable SPINLOCK_DEBUG.

This patch moves mm_counter definitions to mm.h+memory.c from sched.h.
So, total patch size seems to be big.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c       |    4 -
 include/linux/mm.h       |   55 ++++++++++++++++++
 include/linux/mm_types.h |   23 +++++--
 include/linux/sched.h    |   54 ------------------
 kernel/exit.c            |    4 +
 kernel/fork.c            |    3 -
 kernel/sched.c           |    1 
 kernel/timer.c           |    2 
 mm/filemap_xip.c         |    2 
 mm/fremap.c              |    2 
 mm/memory.c              |  139 ++++++++++++++++++++++++++++++++++++++++++-----
 mm/oom_kill.c            |    4 -
 mm/rmap.c                |   10 +--
 mm/swapfile.c            |    2 
 14 files changed, 217 insertions(+), 88 deletions(-)

Index: mmotm-2.6.32-Nov24/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Nov24.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Nov24/include/linux/mm_types.h
@@ -24,11 +24,6 @@ struct address_space;
 
 #define USE_SPLIT_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 
-#if USE_SPLIT_PTLOCKS
-typedef atomic_long_t mm_counter_t;
-#else  /* !USE_SPLIT_PTLOCKS */
-typedef unsigned long mm_counter_t;
-#endif /* !USE_SPLIT_PTLOCKS */
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -199,6 +194,21 @@ struct core_state {
 	struct completion startup;
 };
 
+/*
+ * for per-mm accounting.
+ */
+#if USE_SPLIT_PTLOCKS
+typedef atomic_long_t mm_counter_t;
+#else  /* !USE_SPLIT_PTLOCKS */
+typedef unsigned long mm_counter_t;
+#endif /* !USE_SPLIT_PTLOCKS */
+
+enum {
+	MM_FILEPAGES,
+	MM_ANONPAGES,
+	NR_MM_STATS,
+};
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
@@ -226,8 +236,7 @@ struct mm_struct {
 	/* Special counters, in some configurations protected by the
 	 * page_table_lock, in other configurations by being atomic.
 	 */
-	mm_counter_t _file_rss;
-	mm_counter_t _anon_rss;
+	mm_counter_t counters[NR_MM_STATS];
 
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
Index: mmotm-2.6.32-Nov24/include/linux/sched.h
===================================================================
--- mmotm-2.6.32-Nov24.orig/include/linux/sched.h
+++ mmotm-2.6.32-Nov24/include/linux/sched.h
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
Index: mmotm-2.6.32-Nov24/mm/memory.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/mm/memory.c
+++ mmotm-2.6.32-Nov24/mm/memory.c
@@ -121,6 +121,115 @@ static int __init init_zero_pfn(void)
 }
 core_initcall(init_zero_pfn);
 
+
+#ifdef USE_SPLIT_PTLOCKS
+
+struct pcp_mm_cache {
+	struct mm_struct *mm;
+	long counters[NR_MM_STATS];
+};
+static DEFINE_PER_CPU(struct pcp_mm_cache, curr_mmc);
+/*
+ * The mm counters are not protected by its page_table_lock,
+ * so must be incremented atomically.
+ */
+void set_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	atomic_long_set(&mm->counters[member], value);
+}
+
+unsigned long get_mm_counter(struct mm_struct *mm, int member)
+{
+	long ret = atomic_long_read(&mm->counters[member]);
+	if (ret < 0)
+		return 0;
+	return ret;
+}
+
+void add_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	atomic_long_add(value, &mm->counters[member]);
+}
+
+/*
+ * Always called under pte_lock....irq off, mm != curr_mmc.mm if called
+ * by get_user_pages() etc.
+ */
+static void
+add_mm_counter_fast(struct mm_struct *mm, int member, long val)
+{
+	if (likely(percpu_read(curr_mmc.mm) == mm))
+		percpu_add(curr_mmc.counters[member], val);
+	else
+		add_mm_counter(mm, member, val);
+}
+
+/* Called by not-preemptable context */
+void sync_tsk_mm_counters(void)
+{
+	struct pcp_mm_cache *cache = &per_cpu(curr_mmc, smp_processor_id());
+	int i;
+
+	if (!cache->mm)
+		return;
+
+	for (i = 0; i < NR_MM_STATS; i++) {
+		if (!cache->counters[i])
+			continue;
+		add_mm_counter(cache->mm, i, cache->counters[i]);
+		cache->counters[i] = 0;
+	}
+}
+
+void prepare_mm_switch(struct task_struct *prev, struct task_struct *next)
+{
+	if (prev->mm == next->mm)
+		return;
+	/* If task is exited, sync is already done and prev->mm is NULL */
+	if (prev->mm)
+		sync_tsk_mm_counters();
+	percpu_write(curr_mmc.mm, next->mm);
+}
+
+#else  /* !USE_SPLIT_PTLOCKS */
+/*
+ * The mm counters are protected by its page_table_lock,
+ * so can be incremented directly.
+ */
+void set_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	mm->counters[member] = value;
+}
+
+unsigned long get_mm_counter(struct mm_struct *mm, int member)
+{
+	return mm->counters[member];
+}
+
+void add_mm_counter(struct mm_struct *mm, int member, long val)
+{
+	mm->counters[member] += val;
+}
+
+void sync_tsk_mm_counters(struct task_struct *tsk)
+{
+}
+
+#define add_mm_counter_fast(mm, member, val) add_mm_counter(mm, member, val)
+
+#endif /* !USE_SPLIT_PTLOCKS */
+/* Special asynchronous routine for page fault path */
+#define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member, 1)
+#define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member, -1)
+
+void init_mm_counters(struct mm_struct *mm)
+{
+	int i;
+
+	for (i = 0; i < NR_MM_STATS; i++)
+		set_mm_counter(mm, i, 0);
+}
+
 /*
  * If a p?d_bad entry is found while walking page tables, report
  * the error, before resetting entry to p?d_none.  Usually (but
@@ -378,10 +487,11 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 
 static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
 {
+	/* use synchronous updates here */
 	if (file_rss)
-		add_mm_counter(mm, file_rss, file_rss);
+		add_mm_counter(mm, MM_FILEPAGES, file_rss);
 	if (anon_rss)
-		add_mm_counter(mm, anon_rss, anon_rss);
+		add_mm_counter(mm, MM_ANONPAGES, anon_rss);
 }
 
 /*
@@ -632,7 +742,10 @@ copy_one_pte(struct mm_struct *dst_mm, s
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
@@ -648,7 +761,7 @@ static int copy_pte_range(struct mm_stru
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
-	int rss[2];
+	int rss[NR_MM_STATS];
 	swp_entry_t entry = (swp_entry_t){0};
 
 again:
@@ -688,7 +801,7 @@ again:
 	arch_leave_lazy_mmu_mode();
 	spin_unlock(src_ptl);
 	pte_unmap_nested(orig_src_pte);
-	add_mm_rss(dst_mm, rss[0], rss[1]);
+	add_mm_rss(dst_mm, rss[MM_FILEPAGES], rss[MM_ANONPAGES]);
 	pte_unmap_unlock(orig_dst_pte, dst_ptl);
 	cond_resched();
 
@@ -1527,7 +1640,7 @@ static int insert_page(struct vm_area_st
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter(mm, file_rss);
+	inc_mm_counter_fast(mm, MM_FILEPAGES);
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2163,11 +2276,11 @@ gotten:
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
-				dec_mm_counter(mm, file_rss);
-				inc_mm_counter(mm, anon_rss);
+				dec_mm_counter_fast(mm, MM_FILEPAGES);
+				inc_mm_counter_fast(mm, MM_ANONPAGES);
 			}
 		} else
-			inc_mm_counter(mm, anon_rss);
+			inc_mm_counter_fast(mm, MM_ANONPAGES);
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2600,7 +2713,7 @@ static int do_swap_page(struct mm_struct
 	 * discarded at swap_free().
 	 */
 
-	inc_mm_counter(mm, anon_rss);
+	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -2684,7 +2797,7 @@ static int do_anonymous_page(struct mm_s
 	if (!pte_none(*page_table))
 		goto release;
 
-	inc_mm_counter(mm, anon_rss);
+	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
@@ -2838,10 +2951,10 @@ static int __do_fault(struct mm_struct *
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		if (anon) {
-			inc_mm_counter(mm, anon_rss);
+			inc_mm_counter_fast(mm, MM_ANONPAGES);
 			page_add_new_anon_rmap(page, vma, address);
 		} else {
-			inc_mm_counter(mm, file_rss);
+			inc_mm_counter_fast(mm, MM_FILEPAGES);
 			page_add_file_rmap(page);
 			if (flags & FAULT_FLAG_WRITE) {
 				dirty_page = page;
Index: mmotm-2.6.32-Nov24/kernel/fork.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/kernel/fork.c
+++ mmotm-2.6.32-Nov24/kernel/fork.c
@@ -452,8 +452,7 @@ static struct mm_struct * mm_init(struct
 		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
 	mm->core_state = NULL;
 	mm->nr_ptes = 0;
-	set_mm_counter(mm, file_rss, 0);
-	set_mm_counter(mm, anon_rss, 0);
+	init_mm_counters(mm);
 	spin_lock_init(&mm->page_table_lock);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
Index: mmotm-2.6.32-Nov24/mm/fremap.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/mm/fremap.c
+++ mmotm-2.6.32-Nov24/mm/fremap.c
@@ -40,7 +40,7 @@ static void zap_pte(struct mm_struct *mm
 			page_remove_rmap(page);
 			page_cache_release(page);
 			update_hiwater_rss(mm);
-			dec_mm_counter(mm, file_rss);
+			dec_mm_counter(mm, MM_FILEPAGES);
 		}
 	} else {
 		if (!pte_file(pte))
Index: mmotm-2.6.32-Nov24/mm/rmap.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/mm/rmap.c
+++ mmotm-2.6.32-Nov24/mm/rmap.c
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
@@ -995,7 +995,7 @@ static int try_to_unmap_cluster(unsigned
 
 		page_remove_rmap(page);
 		page_cache_release(page);
-		dec_mm_counter(mm, file_rss);
+		dec_mm_counter(mm, MM_FILEPAGES);
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
Index: mmotm-2.6.32-Nov24/mm/swapfile.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/mm/swapfile.c
+++ mmotm-2.6.32-Nov24/mm/swapfile.c
@@ -839,7 +839,7 @@ static int unuse_pte(struct vm_area_stru
 		goto out;
 	}
 
-	inc_mm_counter(vma->vm_mm, anon_rss);
+	add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
Index: mmotm-2.6.32-Nov24/kernel/timer.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/kernel/timer.c
+++ mmotm-2.6.32-Nov24/kernel/timer.c
@@ -1200,6 +1200,8 @@ void update_process_times(int user_tick)
 	account_process_tick(p, user_tick);
 	run_local_timers();
 	rcu_check_callbacks(cpu, user_tick);
+	/* sync cached mm stat information */
+	sync_tsk_mm_counters();
 	printk_tick();
 	scheduler_tick();
 	run_posix_cpu_timers(p);
Index: mmotm-2.6.32-Nov24/mm/filemap_xip.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/mm/filemap_xip.c
+++ mmotm-2.6.32-Nov24/mm/filemap_xip.c
@@ -194,7 +194,7 @@ retry:
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush_notify(vma, address, pte);
 			page_remove_rmap(page);
-			dec_mm_counter(mm, file_rss);
+			dec_mm_counter(mm, MM_FILEPAGES);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			page_cache_release(page);
Index: mmotm-2.6.32-Nov24/include/linux/mm.h
===================================================================
--- mmotm-2.6.32-Nov24.orig/include/linux/mm.h
+++ mmotm-2.6.32-Nov24/include/linux/mm.h
@@ -863,6 +863,61 @@ extern int mprotect_fixup(struct vm_area
 			  struct vm_area_struct **pprev, unsigned long start,
 			  unsigned long end, unsigned long newflags);
 
+/* For per-mm stat accounting */
+extern void set_mm_counter(struct mm_struct *mm, int member, long value);
+extern unsigned long get_mm_counter(struct mm_struct *mm, int member);
+extern void add_mm_counter(struct mm_struct *mm, int member, long value);
+extern void sync_tsk_mm_counters(void);
+extern void init_mm_counters(struct mm_struct *mm);
+
+#ifdef USE_SPLIT_PTLOCKS
+extern void prepare_mm_switch(struct task_struct *prev,
+				 struct task_struct *next);
+#else
+static inline prepare_mm_switch(struct task_struct *prev,
+				struct task_struct *next)
+{
+}
+#endif
+
+#define inc_mm_counter(mm, member) add_mm_counter((mm), (member), 1)
+#define dec_mm_counter(mm, member) add_mm_counter((mm), (member), -1)
+
+#define get_mm_rss(mm)			\
+	(get_mm_counter(mm, MM_FILEPAGES) +\
+	 get_mm_counter(mm, MM_ANONPAGES))
+
+#define update_hiwater_rss(mm)	do {			\
+	unsigned long _rss = get_mm_rss(mm);		\
+	if ((mm)->hiwater_rss < _rss)			\
+		(mm)->hiwater_rss = _rss;		\
+} while (0)
+
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
+
+
 /*
  * doesn't attempt to fault and will return short.
  */
Index: mmotm-2.6.32-Nov24/fs/proc/task_mmu.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/fs/proc/task_mmu.c
+++ mmotm-2.6.32-Nov24/fs/proc/task_mmu.c
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
 
Index: mmotm-2.6.32-Nov24/mm/oom_kill.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/mm/oom_kill.c
+++ mmotm-2.6.32-Nov24/mm/oom_kill.c
@@ -400,8 +400,8 @@ static void __oom_kill_task(struct task_
 		       "vsz:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		       task_pid_nr(p), p->comm,
 		       K(p->mm->total_vm),
-		       K(get_mm_counter(p->mm, anon_rss)),
-		       K(get_mm_counter(p->mm, file_rss)));
+		       K(get_mm_counter(p->mm, MM_ANONPAGES)),
+		       K(get_mm_counter(p->mm, MM_FILEPAGES)));
 	task_unlock(p);
 
 	/*
Index: mmotm-2.6.32-Nov24/kernel/exit.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/kernel/exit.c
+++ mmotm-2.6.32-Nov24/kernel/exit.c
@@ -681,6 +681,10 @@ static void exit_mm(struct task_struct *
 	}
 	atomic_inc(&mm->mm_count);
 	BUG_ON(mm != tsk->active_mm);
+	/* drop cached information */
+	preempt_disable();
+	sync_tsk_mm_counters();
+	preempt_enable();
 	/* more a memory barrier than a real lock */
 	task_lock(tsk);
 	tsk->mm = NULL;
Index: mmotm-2.6.32-Nov24/kernel/sched.c
===================================================================
--- mmotm-2.6.32-Nov24.orig/kernel/sched.c
+++ mmotm-2.6.32-Nov24/kernel/sched.c
@@ -2858,6 +2858,7 @@ context_switch(struct rq *rq, struct tas
 	trace_sched_switch(rq, prev, next);
 	mm = next->mm;
 	oldmm = prev->active_mm;
+	prepare_mm_switch(prev, next);
 	/*
 	 * For paravirt, this is coupled with an exit in switch_to to
 	 * combine the page table reload and the switch backend into

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
