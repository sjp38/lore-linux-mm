Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E49EC6B0221
	for <linux-mm@kvack.org>; Tue,  4 May 2010 23:20:43 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [10.3.21.3])
	by smtp-out.google.com with ESMTP id o453KeCu015106
	for <linux-mm@kvack.org>; Tue, 4 May 2010 20:20:41 -0700
Received: from gwj17 (gwj17.prod.google.com [10.200.10.17])
	by hpaq3.eem.corp.google.com with ESMTP id o453KbpB003917
	for <linux-mm@kvack.org>; Tue, 4 May 2010 20:20:39 -0700
Received: by gwj17 with SMTP id 17so1956846gwj.29
        for <linux-mm@kvack.org>; Tue, 04 May 2010 20:20:37 -0700 (PDT)
Date: Tue, 4 May 2010 20:20:33 -0700
From: Michel Lespinasse <walken@google.com>
Subject: rwsem: down_read_unfair() proposal
Message-ID: <20100505032033.GA19232@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@google.com>, Linux-MM <linux-mm@kvack.org>
Cc: Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

I am looking at ways to solve the following problem:

Some cluster monitoring software we use at Google periodically accesses
files such as /proc/<pid>/exe or /proc/<pid>/maps, which requires
acquiring that pid's mmap_sem for read. Sometimes when the machines get
loaded enough, this acquisition can take a long time - typically this
happens when thread A acquires mmap_sem for reads in do_page_fault and
gets blocked (either trying to allocate a page or trying to read from
disk); then thread B tries to acquire mmap_sem for write and gets queued
behind A; then the monitoring software tries to read /proc/<pid>/maps
and gets queued behind B due to rwlock fair behavior.

We have been using patches that address these issues by allowing the
/proc/<pid>/exe and /proc/<pid>/maps code paths to acquire the mmap_sem
for reading in an unfair way, thus allowing the monitoring software to
bypass thread B and acquire mmap_sem concurrently with thread A.

This was easy to implement with the generic rwsem, and looks like it's
doable with the x86 rwsem implementation as well in a way that would only
involve changes to the rwsem spinlock-protected slow paths in lib/rwsem.c .
We are still working on that code but I thought we should ask first how
the developer community feels about the general idea.

For reference, here is one patch we have (against 2.6.33) using
down_read_unfair() in such a way (but with no x86 specific rwsem
implementation yet)


Author: Ying Han <yinghan@google.com>

    Introduce down_read_unfair()
    
    In down_read_unfair(), reader is not waiting non-exclusive lock
    even a writer on the queue. Apply it to maps & exes in procfs where
    monitoring program reads frequently.
    
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 58324c2..d51bc55 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1367,7 +1367,7 @@ struct file *get_mm_exe_file(struct mm_struct *mm)
 
 	/* We need mmap_sem to protect against races with removal of
 	 * VM_EXECUTABLE vmas */
-	down_read(&mm->mmap_sem);
+	down_read_unfair(&mm->mmap_sem);
 	exe_file = mm->exe_file;
 	if (exe_file)
 		get_file(exe_file);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f277c4a..118e0cd 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -119,7 +119,7 @@ static void *m_start(struct seq_file *m, loff_t *pos)
 	mm = mm_for_maps(priv->task);
 	if (!mm)
 		return NULL;
-	down_read(&mm->mmap_sem);
+	down_read_unfair(&mm->mmap_sem);
 
 	tail_vma = get_gate_vma(priv->task);
 	priv->tail_vma = tail_vma;
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 5d9fd64..2ab484b 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -193,7 +193,7 @@ static void *m_start(struct seq_file *m, loff_t *pos)
 		priv->task = NULL;
 		return NULL;
 	}
-	down_read(&mm->mmap_sem);
+	down_read_unfair(&mm->mmap_sem);
 
 	/* start from the Nth VMA */
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p))
diff --git a/include/linux/rwsem-spinlock.h b/include/linux/rwsem-spinlock.h
index bdfcc25..48199db 100644
--- a/include/linux/rwsem-spinlock.h
+++ b/include/linux/rwsem-spinlock.h
@@ -60,7 +60,8 @@ do {								\
 	__init_rwsem((sem), #sem, &__key);			\
 } while (0)
 
-extern void __down_read(struct rw_semaphore *sem);
+extern void __down_read_fair(struct rw_semaphore *sem);
+extern void __down_read_unfair(struct rw_semaphore *sem);
 extern int __down_read_trylock(struct rw_semaphore *sem);
 extern void __down_write(struct rw_semaphore *sem);
 extern void __down_write_nested(struct rw_semaphore *sem, int subclass);
diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index efd348f..65d666e 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -20,6 +20,7 @@ struct rw_semaphore;
 #include <linux/rwsem-spinlock.h> /* use a generic implementation */
 #else
 #include <asm/rwsem.h> /* use an arch-specific implementation */
+#error "Missing down_read_unfair support."
 #endif
 
 /*
@@ -28,6 +29,11 @@ struct rw_semaphore;
 extern void down_read(struct rw_semaphore *sem);
 
 /*
+ * lock for reading - skip waitting writers
+ */
+extern void down_read_unfair(struct rw_semaphore *sem);
+
+/*
  * trylock for reading -- returns 1 if successful, 0 if contention
  */
 extern int down_read_trylock(struct rw_semaphore *sem);
diff --git a/kernel/rwsem.c b/kernel/rwsem.c
index cae050b..24578c5 100644
--- a/kernel/rwsem.c
+++ b/kernel/rwsem.c
@@ -21,12 +21,25 @@ void __sched down_read(struct rw_semaphore *sem)
 	might_sleep();
 	rwsem_acquire_read(&sem->dep_map, 0, 0, _RET_IP_);
 
-	LOCK_CONTENDED(sem, __down_read_trylock, __down_read);
+	LOCK_CONTENDED(sem, __down_read_trylock, __down_read_fair);
 }
 
 EXPORT_SYMBOL(down_read);
 
 /*
+ * lock for reading - skip waitting writers
+ */
+void __sched down_read_unfair(struct rw_semaphore *sem)
+{
+	might_sleep();
+	rwsem_acquire_read(&sem->dep_map, 0, 0, _RET_IP_);
+
+	LOCK_CONTENDED(sem, __down_read_trylock, __down_read_unfair);
+}
+
+EXPORT_SYMBOL(down_read_unfair);
+
+/*
  * trylock for reading -- returns 1 if successful, 0 if contention
  */
 int down_read_trylock(struct rw_semaphore *sem)
@@ -112,7 +125,7 @@ void down_read_nested(struct rw_semaphore *sem, int subclass)
 	might_sleep();
 	rwsem_acquire_read(&sem->dep_map, subclass, 0, _RET_IP_);
 
-	LOCK_CONTENDED(sem, __down_read_trylock, __down_read);
+	LOCK_CONTENDED(sem, __down_read_trylock, __down_read_fair);
 }
 
 EXPORT_SYMBOL(down_read_nested);
@@ -121,7 +134,7 @@ void down_read_non_owner(struct rw_semaphore *sem)
 {
 	might_sleep();
 
-	__down_read(sem);
+	__down_read_fair(sem);
 }
 
 EXPORT_SYMBOL(down_read_non_owner);
diff --git a/lib/rwsem-spinlock.c b/lib/rwsem-spinlock.c
index ccf95bf..8c44c08 100644
--- a/lib/rwsem-spinlock.c
+++ b/lib/rwsem-spinlock.c
@@ -139,14 +139,14 @@ __rwsem_wake_one_writer(struct rw_semaphore *sem)
 /*
  * get a read lock on the semaphore
  */
-void __sched __down_read(struct rw_semaphore *sem)
+void __sched __down_read(struct rw_semaphore *sem, int unfair)
 {
 	struct rwsem_waiter waiter;
 	struct task_struct *tsk;
 
 	spin_lock_irq(&sem->wait_lock);
 
-	if (sem->activity >= 0 && list_empty(&sem->wait_list)) {
+	if (sem->activity >= 0 && (unfair || list_empty(&sem->wait_list))) {
 		/* granted */
 		sem->activity++;
 		spin_unlock_irq(&sem->wait_lock);
@@ -161,7 +161,11 @@ void __sched __down_read(struct rw_semaphore *sem)
 	waiter.flags = RWSEM_WAITING_FOR_READ;
 	get_task_struct(tsk);
 
-	list_add_tail(&waiter.list, &sem->wait_list);
+	if (unfair) {
+		list_add(&waiter.list, &sem->wait_list);
+	} else {
+		list_add_tail(&waiter.list, &sem->wait_list);
+	}
 
 	/* we don't need to touch the semaphore struct anymore */
 	spin_unlock_irq(&sem->wait_lock);
@@ -180,6 +184,22 @@ void __sched __down_read(struct rw_semaphore *sem)
 }
 
 /*
+ * wrapper for fair __down_read
+ */
+void __sched __down_read_fair(struct rw_semaphore *sem)
+{
+	__down_read(sem, 0);
+}
+
+/*
+ * wrapper for unfair __down_read
+ */
+void __sched __down_read_unfair(struct rw_semaphore *sem)
+{
+	__down_read(sem, 1);
+}
+
+/*
  * trylock for reading -- returns 1 if successful, 0 if contention
  */
 int __down_read_trylock(struct rw_semaphore *sem)


-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
