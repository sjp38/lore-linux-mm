Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9AB386B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 02:43:12 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD7hA3G003000
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Nov 2009 16:43:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 09AC045DE65
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:43:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC7EF45DE57
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:43:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 571128F8006
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:43:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B8289E78001
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:43:06 +0900 (JST)
Date: Fri, 13 Nov 2009 16:40:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC MM 3/4] add mm version number
Message-Id: <20091113164029.e7e8bcea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cl@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Add logical timestamp to mm_struct, which is incremented always
mmap_sem(write) is got and released. By this, it works like seqlock's
counter and indicates mm_struct is modified or not.

And this adds vma_cache to each thread. Each thread remember the last
faulted vma and grab reference count. Correctness of cache is checked by
mm->generation timestamp. (mm struct's vma cache is not very good
if mm is shared, I think)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/x86/mm/fault.c       |   18 ++++++++++++++++--
 fs/exec.c                 |    4 ++++
 include/linux/init_task.h |    1 +
 include/linux/mm_types.h  |   11 ++++++++++-
 include/linux/sched.h     |    4 ++++
 kernel/exit.c             |    3 +++
 kernel/fork.c             |    5 ++++-
 7 files changed, 42 insertions(+), 4 deletions(-)

Index: mmotm-2.6.32-Nov2/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/mm_types.h
+++ mmotm-2.6.32-Nov2/include/linux/mm_types.h
@@ -216,6 +216,7 @@ struct mm_struct {
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
+	unsigned int generation;		/* logical timestamp of last modification */
 	struct rw_semaphore sem;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
 
@@ -308,16 +309,21 @@ static inline int mm_reader_trylock(stru
 static inline void mm_writer_lock(struct mm_struct *mm)
 {
 	down_write(&mm->sem);
+	mm->generation++;
 }
 
 static inline void mm_writer_unlock(struct mm_struct *mm)
 {
+	mm->generation++;
 	up_write(&mm->sem);
 }
 
 static inline int mm_writer_trylock(struct mm_struct *mm)
 {
-	return down_write_trylock(&mm->sem);
+	int ret = down_write_trylock(&mm->sem);
+	if (!ret)
+		mm->generation++;
+	return ret;
 }
 
 static inline int mm_locked(struct mm_struct *mm)
@@ -327,17 +333,20 @@ static inline int mm_locked(struct mm_st
 
 static inline void mm_writer_to_reader_lock(struct mm_struct *mm)
 {
+	mm->generation++;
 	downgrade_write(&mm->sem);
 }
 
 static inline void mm_writer_lock_nested(struct mm_struct *mm, int x)
 {
 	down_write_nested(&mm->sem, x);
+	mm->generation++;
 }
 
 static inline void mm_lock_init(struct mm_struct *mm)
 {
 	init_rwsem(&mm->sem);
+	mm->generation = 0;
 }
 
 static inline void mm_lock_prefetch(struct mm_struct *mm)
Index: mmotm-2.6.32-Nov2/arch/x86/mm/fault.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/arch/x86/mm/fault.c
+++ mmotm-2.6.32-Nov2/arch/x86/mm/fault.c
@@ -952,6 +952,7 @@ do_page_fault(struct pt_regs *regs, unsi
 	struct mm_struct *mm;
 	int write;
 	int fault;
+	int cachehit = 0;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1071,8 +1072,13 @@ do_page_fault(struct pt_regs *regs, unsi
 		 */
 		might_sleep();
 	}
-
-	vma = find_vma(mm, address);
+	if ((mm->generation == current->mm_generation) && current->vma_cache) {
+		vma = current->vma_cache;
+		if ((vma->vm_start <= address) && (address < vma->vm_end))
+			cachehit = 1;
+	}
+	if (!cachehit)
+		vma = find_vma(mm, address);
 	if (unlikely(!vma)) {
 		bad_area(regs, error_code, address);
 		return;
@@ -1133,6 +1139,14 @@ good_area:
 		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, 0,
 				     regs, address);
 	}
+	/* cache information */
+	if (!cachehit) {
+		if (current->vma_cache)
+			vma_put(current->vma_cache);
+		current->vma_cache = vma;
+		current->mm_generation = mm->generation;
+		vma_get(vma);
+	}
 
 	check_v8086_mode(regs, address, tsk);
 
Index: mmotm-2.6.32-Nov2/include/linux/sched.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/sched.h
+++ mmotm-2.6.32-Nov2/include/linux/sched.h
@@ -1370,6 +1370,10 @@ struct task_struct {
 /* hung task detection */
 	unsigned long last_switch_count;
 #endif
+/* For relaxing per-thread page fault, information is cached.*/
+	struct vm_area_struct *vma_cache;
+	unsigned int mm_generation;
+
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /* filesystem information */
Index: mmotm-2.6.32-Nov2/kernel/fork.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/kernel/fork.c
+++ mmotm-2.6.32-Nov2/kernel/fork.c
@@ -264,6 +264,9 @@ static struct task_struct *dup_task_stru
 #endif
 	tsk->splice_pipe = NULL;
 
+	tsk->vma_cache = NULL;
+	tsk->mm_generation = 0;
+
 	account_kernel_stack(ti, 1);
 
 	return tsk;
@@ -289,7 +292,7 @@ static int dup_mmap(struct mm_struct *mm
 	 * Not linked in yet - no deadlock potential:
 	 */
 	mm_writer_lock_nested(mm, SINGLE_DEPTH_NESTING);
-
+	mm->generation = 0;
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
Index: mmotm-2.6.32-Nov2/kernel/exit.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/kernel/exit.c
+++ mmotm-2.6.32-Nov2/kernel/exit.c
@@ -645,6 +645,9 @@ static void exit_mm(struct task_struct *
 	struct mm_struct *mm = tsk->mm;
 	struct core_state *core_state;
 
+	if (tsk->vma_cache)
+		vma_put(tsk->vma_cache);
+
 	mm_release(tsk, mm);
 	if (!mm)
 		return;
Index: mmotm-2.6.32-Nov2/fs/exec.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/fs/exec.c
+++ mmotm-2.6.32-Nov2/fs/exec.c
@@ -720,6 +720,10 @@ static int exec_mmap(struct mm_struct *m
 			return -EINTR;
 		}
 	}
+	if (tsk->vma_cache) {
+		vma_put(tsk->vma_cache);
+		tsk->vma_cache = NULL;
+	}
 	task_lock(tsk);
 	active_mm = tsk->active_mm;
 	tsk->mm = mm;
Index: mmotm-2.6.32-Nov2/include/linux/init_task.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/init_task.h
+++ mmotm-2.6.32-Nov2/include/linux/init_task.h
@@ -156,6 +156,7 @@ extern struct cred init_cred;
 		 __MUTEX_INITIALIZER(tsk.cred_guard_mutex),		\
 	.comm		= "swapper",					\
 	.thread		= INIT_THREAD,					\
+	.vma_cache	= NULL,						\
 	.fs		= &init_fs,					\
 	.files		= &init_files,					\
 	.signal		= &init_signals,				\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
