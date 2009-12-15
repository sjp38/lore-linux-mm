Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 03CF06B007B
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 04:16:41 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF9Gb27023564
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Dec 2009 18:16:37 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F03E45DE4E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:16:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 45D3045DE4F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:16:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2637E1DB8038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:16:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDA2C1DB803C
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:16:36 +0900 (JST)
Date: Tue, 15 Dec 2009 18:13:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmotm][PATCH 2/5] mm : avoid  false sharing on mm_counter
Message-Id: <20091215181337.1c4f638d.kamezawa.hiroyu@jp.fujitsu.com>
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

Considering the nature of per mm stats, it's the shared object among
threads and can be a cache-miss point in the page fault path.

This patch adds per-thread cache for mm_counter. RSS value will be counted
into a struct in task_struct and synchronized with mm's one at events.

Now, in this patch, the event is the number of calls to handle_mm_fault.
Per-thread value is added to mm at each 64 calls.

 rough estimation with small benchmark on parallel thread (2threads) shows
 [before]
     4.5 cache-miss/faults
 [after]
     4.0 cache-miss/faults
 Anyway, the most contended object is mmap_sem if the number of threads grows.

Changlog: 2009/12/15
 - added Documentation
 - removed all hooks from scheduler and ticks.
 - added event counter instead of them.
 - make counter per thread rather than per cpu. This removes many
   complicated codes.
 - added SPLIT_RSS_COUNTING instead of reusing USE_SPLIT_PTLOCKS.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/filesystems/proc.txt |    6 ++
 fs/exec.c                          |    1 
 include/linux/mm.h                 |    8 +--
 include/linux/mm_types.h           |    6 ++
 include/linux/sched.h              |    4 +
 kernel/exit.c                      |    3 -
 mm/memory.c                        |   94 +++++++++++++++++++++++++++++++++----
 7 files changed, 107 insertions(+), 15 deletions(-)

Index: mmotm-2.6.32-Dec8-pth/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Dec8-pth/include/linux/mm_types.h
@@ -200,9 +200,15 @@ enum {
 };
 
 #if USE_SPLIT_PTLOCKS
+#define SPLIT_RSS_COUNTING
 struct mm_rss_stat {
 	atomic_long_t count[NR_MM_COUNTERS];
 };
+/* per-thread cached information, */
+struct task_rss_stat {
+	int events;	/* for synchronization threshold */
+	int count[NR_MM_COUNTERS];
+};
 #else  /* !USE_SPLIT_PTLOCKS */
 struct mm_rss_stat {
 	unsigned long count[NR_MM_COUNTERS];
Index: mmotm-2.6.32-Dec8-pth/include/linux/sched.h
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/include/linux/sched.h
+++ mmotm-2.6.32-Dec8-pth/include/linux/sched.h
@@ -1222,7 +1222,9 @@ struct task_struct {
 	struct plist_node pushable_tasks;
 
 	struct mm_struct *mm, *active_mm;
-
+#if defined(SPLIT_RSS_COUNTING)
+	struct task_rss_stat	rss_stat;
+#endif
 /* task state */
 	int exit_state;
 	int exit_code, exit_signal;
Index: mmotm-2.6.32-Dec8-pth/mm/memory.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/mm/memory.c
+++ mmotm-2.6.32-Dec8-pth/mm/memory.c
@@ -122,6 +122,79 @@ static int __init init_zero_pfn(void)
 core_initcall(init_zero_pfn);
 
 
+#if defined(SPLIT_RSS_COUNTING)
+
+void __sync_task_rss_stat(struct task_struct *task, struct mm_struct *mm)
+{
+	int i;
+
+	for (i = 0; i < NR_MM_COUNTERS; i++) {
+		if (task->rss_stat.count[i]) {
+			add_mm_counter(mm, i, task->rss_stat.count[i]);
+			task->rss_stat.count[i] = 0;
+		}
+	}
+	task->rss_stat.events = 0;
+}
+
+static void add_mm_counter_fast(struct mm_struct *mm, int member, int val)
+{
+	struct task_struct *task = current;
+
+	if (likely(task->mm == mm))
+		task->rss_stat.count[member] += val;
+	else
+		add_mm_counter(mm, member, val);
+}
+#define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member,1)
+#define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member,-1)
+
+/* sync counter once per 64 page faults */
+#define TASK_RSS_EVENTS_THRESH	(64)
+static void check_sync_rss_stat(struct task_struct *task)
+{
+	if (unlikely(task != current))
+		return;
+	if (unlikely(task->rss_stat.events++ > TASK_RSS_EVENTS_THRESH))
+		__sync_task_rss_stat(task, task->mm);
+}
+
+unsigned long get_mm_counter(struct mm_struct *mm, int member)
+{
+	long val = 0;
+
+	/*
+	 * Don't use task->mm here...for avoiding to use task_get_mm()..
+ 	 * The caller must guarantee task->mm is not invalid.
+ 	 */
+	val = atomic_long_read(&mm->rss_stat.count[member]);
+	/*
+	 * counter is updated in asynchronous manner and may go to minus.
+	 * But it's never be expected number for users.
+	 */
+	if (val < 0)
+		return 0;
+	return (unsigned long)val;
+}
+
+void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
+{
+	__sync_task_rss_stat(task, mm);
+}
+#else
+
+#define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)
+#define dec_mm_counter_fast(mm, member) dec_mm_counter(mm, member)
+
+static void check_sync_rss_stat(struct task_struct *task)
+{
+}
+
+void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
+{
+}
+#endif
+
 /*
  * If a p?d_bad entry is found while walking page tables, report
  * the error, before resetting entry to p?d_none.  Usually (but
@@ -386,6 +459,8 @@ static inline void add_mm_rss_vec(struct
 {
 	int i;
 
+	if (current->mm == mm)
+		sync_mm_rss(current, mm);
 	for (i = 0; i < NR_MM_COUNTERS; i++)
 		if (rss[i])
 			add_mm_counter(mm, i, rss[i]);
@@ -1539,7 +1614,7 @@ static int insert_page(struct vm_area_st
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter(mm, MM_FILEPAGES);
+	inc_mm_counter_fast(mm, MM_FILEPAGES);
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2175,11 +2250,11 @@ gotten:
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
-				dec_mm_counter(mm, MM_FILEPAGES);
-				inc_mm_counter(mm, MM_ANONPAGES);
+				dec_mm_counter_fast(mm, MM_FILEPAGES);
+				inc_mm_counter_fast(mm, MM_ANONPAGES);
 			}
 		} else
-			inc_mm_counter(mm, MM_ANONPAGES);
+			inc_mm_counter_fast(mm, MM_ANONPAGES);
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2612,7 +2687,7 @@ static int do_swap_page(struct mm_struct
 	 * discarded at swap_free().
 	 */
 
-	inc_mm_counter(mm, MM_ANONPAGES);
+	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -2696,7 +2771,7 @@ static int do_anonymous_page(struct mm_s
 	if (!pte_none(*page_table))
 		goto release;
 
-	inc_mm_counter(mm, MM_ANONPAGES);
+	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
@@ -2850,10 +2925,10 @@ static int __do_fault(struct mm_struct *
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		if (anon) {
-			inc_mm_counter(mm, MM_ANONPAGES);
+			inc_mm_counter_fast(mm, MM_ANONPAGES);
 			page_add_new_anon_rmap(page, vma, address);
 		} else {
-			inc_mm_counter(mm, MM_FILEPAGES);
+			inc_mm_counter_fast(mm, MM_FILEPAGES);
 			page_add_file_rmap(page);
 			if (flags & FAULT_FLAG_WRITE) {
 				dirty_page = page;
@@ -3031,6 +3106,9 @@ int handle_mm_fault(struct mm_struct *mm
 
 	count_vm_event(PGFAULT);
 
+	/* do counter updates before entering really critical section. */
+	check_sync_rss_stat(current);
+
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
 
Index: mmotm-2.6.32-Dec8-pth/include/linux/mm.h
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/include/linux/mm.h
+++ mmotm-2.6.32-Dec8-pth/include/linux/mm.h
@@ -871,7 +871,7 @@ int __get_user_pages_fast(unsigned long 
 /*
  * per-process(per-mm_struct) statistics.
  */
-#if USE_SPLIT_PTLOCKS
+#if defined(SPLIT_RSS_COUNTING)
 /*
  * The mm counters are not protected by its page_table_lock,
  * so must be incremented atomically.
@@ -881,10 +881,7 @@ static inline void set_mm_counter(struct
 	atomic_long_set(&mm->rss_stat.count[member], value);
 }
 
-static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
-{
-	return (unsigned long)atomic_long_read(&mm->rss_stat.count[member]);
-}
+unsigned long get_mm_counter(struct mm_struct *mm, int member);
 
 static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
 {
@@ -972,6 +969,7 @@ static inline void setmax_mm_hiwater_rss
 		*maxrss = hiwater_rss;
 }
 
+void sync_mm_rss(struct task_struct *task, struct mm_struct *mm);
 
 /*
  * A callback you can register to apply pressure to ageable caches.
Index: mmotm-2.6.32-Dec8-pth/fs/exec.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/fs/exec.c
+++ mmotm-2.6.32-Dec8-pth/fs/exec.c
@@ -702,6 +702,7 @@ static int exec_mmap(struct mm_struct *m
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
 	old_mm = current->mm;
+	sync_mm_rss(tsk, old_mm);
 	mm_release(tsk, old_mm);
 
 	if (old_mm) {
Index: mmotm-2.6.32-Dec8-pth/kernel/exit.c
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/kernel/exit.c
+++ mmotm-2.6.32-Dec8-pth/kernel/exit.c
@@ -944,7 +944,8 @@ NORET_TYPE void do_exit(long code)
 				preempt_count());
 
 	acct_update_integrals(tsk);
-
+	/* sync mm's RSS info before statistics gathering */
+	sync_mm_rss(tsk, tsk->mm);
 	group_dead = atomic_dec_and_test(&tsk->signal->live);
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
Index: mmotm-2.6.32-Dec8-pth/Documentation/filesystems/proc.txt
===================================================================
--- mmotm-2.6.32-Dec8-pth.orig/Documentation/filesystems/proc.txt
+++ mmotm-2.6.32-Dec8-pth/Documentation/filesystems/proc.txt
@@ -189,6 +189,12 @@ memory usage. Its seven fields are expla
 contains details information about the process itself.  Its fields are
 explained in Table 1-4.
 
+(for SMP CONFIG users)
+For making accounting scalable, RSS related information are handled in
+asynchronous manner and the vaule may not be very precise. To see a precise
+snapshot of a moment, you can see /proc/<pid>/smaps file and scan page table.
+It's slow but very precise.
+
 Table 1-2: Contents of the statm files (as of 2.6.30-rc7)
 ..............................................................................
  Field                       Content

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
