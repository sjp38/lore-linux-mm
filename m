Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 06C9B6B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 22:21:41 -0500 (EST)
Received: by iajr24 with SMTP id r24so10389355iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 19:21:41 -0800 (PST)
Date: Tue, 6 Mar 2012 19:21:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] mm, counters: remove task argument to sync_mm_rss and
 __sync_task_rss_stat
Message-ID: <alpine.DEB.2.00.1203061919260.21806@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

sync_mm_rss() can only be used for current to avoid race conditions in
iterating and clearing its per-task counters.  Remove the task argument
for it and its helper function, __sync_task_rss_stat(), to avoid thinking
it can be used safely for anything other than current.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/exec.c          |    2 +-
 include/linux/mm.h |    4 ++--
 kernel/exit.c      |    2 +-
 mm/memory.c        |   18 +++++++++---------
 mm/mmu_context.c   |    2 +-
 5 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -822,7 +822,7 @@ static int exec_mmap(struct mm_struct *mm)
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
 	old_mm = current->mm;
-	sync_mm_rss(tsk, old_mm);
+	sync_mm_rss(old_mm);
 	mm_release(tsk, old_mm);
 
 	if (old_mm) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1127,9 +1127,9 @@ static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
 }
 
 #if defined(SPLIT_RSS_COUNTING)
-void sync_mm_rss(struct task_struct *task, struct mm_struct *mm);
+void sync_mm_rss(struct mm_struct *mm);
 #else
-static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
+static inline void sync_mm_rss(struct mm_struct *mm)
 {
 }
 #endif
diff --git a/kernel/exit.c b/kernel/exit.c
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -953,7 +953,7 @@ void do_exit(long code)
 	acct_update_integrals(tsk);
 	/* sync mm's RSS info before statistics gathering */
 	if (tsk->mm)
-		sync_mm_rss(tsk, tsk->mm);
+		sync_mm_rss(tsk->mm);
 	group_dead = atomic_dec_and_test(&tsk->signal->live);
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -125,17 +125,17 @@ core_initcall(init_zero_pfn);
 
 #if defined(SPLIT_RSS_COUNTING)
 
-static void __sync_task_rss_stat(struct task_struct *task, struct mm_struct *mm)
+static void __sync_task_rss_stat(struct mm_struct *mm)
 {
 	int i;
 
 	for (i = 0; i < NR_MM_COUNTERS; i++) {
-		if (task->rss_stat.count[i]) {
-			add_mm_counter(mm, i, task->rss_stat.count[i]);
-			task->rss_stat.count[i] = 0;
+		if (current->rss_stat.count[i]) {
+			add_mm_counter(mm, i, current->rss_stat.count[i]);
+			current->rss_stat.count[i] = 0;
 		}
 	}
-	task->rss_stat.events = 0;
+	current->rss_stat.events = 0;
 }
 
 static void add_mm_counter_fast(struct mm_struct *mm, int member, int val)
@@ -157,7 +157,7 @@ static void check_sync_rss_stat(struct task_struct *task)
 	if (unlikely(task != current))
 		return;
 	if (unlikely(task->rss_stat.events++ > TASK_RSS_EVENTS_THRESH))
-		__sync_task_rss_stat(task, task->mm);
+		__sync_task_rss_stat(task->mm);
 }
 
 unsigned long get_mm_counter(struct mm_struct *mm, int member)
@@ -178,9 +178,9 @@ unsigned long get_mm_counter(struct mm_struct *mm, int member)
 	return (unsigned long)val;
 }
 
-void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
+void sync_mm_rss(struct mm_struct *mm)
 {
-	__sync_task_rss_stat(task, mm);
+	__sync_task_rss_stat(mm);
 }
 #else /* SPLIT_RSS_COUNTING */
 
@@ -661,7 +661,7 @@ static inline void add_mm_rss_vec(struct mm_struct *mm, int *rss)
 	int i;
 
 	if (current->mm == mm)
-		sync_mm_rss(current, mm);
+		sync_mm_rss(mm);
 	for (i = 0; i < NR_MM_COUNTERS; i++)
 		if (rss[i])
 			add_mm_counter(mm, i, rss[i]);
diff --git a/mm/mmu_context.c b/mm/mmu_context.c
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -53,7 +53,7 @@ void unuse_mm(struct mm_struct *mm)
 	struct task_struct *tsk = current;
 
 	task_lock(tsk);
-	sync_mm_rss(tsk, mm);
+	sync_mm_rss(mm);
 	tsk->mm = NULL;
 	/* active_mm is still 'mm' */
 	enter_lazy_tlb(mm, tsk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
