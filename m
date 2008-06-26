Message-Id: <20080626003833.399527531@sgi.com>
References: <20080626003632.049547282@sgi.com>
Date: Wed, 25 Jun 2008 17:36:35 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 3/5] Add capability to check if rwsems are contended.
Content-Disposition: inline; filename=rwsem_is_contended
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: apw@shadowen.org, Andrea Arcangeli <andrea@qumranet.com>, Hugh Dickins <hugh@veritas.com>, holt@sgi.com, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Add a function to rw_semaphores to check if there are any processes
waiting for the semaphore. Add rwsem_needbreak() to sched.h that works
in the same way as spinlock_needbreak().

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

---
 include/linux/rwsem.h |    2 ++
 include/linux/sched.h |    9 +++++++++
 lib/rwsem-spinlock.c  |   12 ++++++++++++
 lib/rwsem.c           |   12 ++++++++++++
 4 files changed, 35 insertions(+)

Index: linux-2.6/include/linux/rwsem.h
===================================================================
--- linux-2.6.orig/include/linux/rwsem.h	2008-06-09 20:20:59.037591344 -0700
+++ linux-2.6/include/linux/rwsem.h	2008-06-09 20:28:47.359341232 -0700
@@ -57,6 +57,8 @@ extern void up_write(struct rw_semaphore
  */
 extern void downgrade_write(struct rw_semaphore *sem);
 
+extern int rwsem_is_contended(struct rw_semaphore *sem);
+
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 /*
  * nested locking. NOTE: rwsems are not allowed to recurse
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h	2008-06-09 20:20:59.045591415 -0700
+++ linux-2.6/include/linux/sched.h	2008-06-09 20:28:47.389841510 -0700
@@ -2071,6 +2071,15 @@ static inline int spin_needbreak(spinloc
 #endif
 }
 
+static inline int rwsem_needbreak(struct rw_semaphore *sem)
+{
+#ifdef CONFIG_PREEMPT
+	return rwsem_is_contended(sem);
+#else
+	return 0;
+#endif
+}
+
 /*
  * Reevaluate whether the task has signals pending delivery.
  * Wake the task if so.
Index: linux-2.6/lib/rwsem-spinlock.c
===================================================================
--- linux-2.6.orig/lib/rwsem-spinlock.c	2008-06-09 20:20:59.053591561 -0700
+++ linux-2.6/lib/rwsem-spinlock.c	2008-06-09 20:28:47.402091148 -0700
@@ -305,6 +305,18 @@ void __downgrade_write(struct rw_semapho
 	spin_unlock_irqrestore(&sem->wait_lock, flags);
 }
 
+int rwsem_is_contended(struct rw_semaphore *sem)
+{
+	/*
+	 * Racy check for an empty list. False positives or negatives
+	 * would be okay. False positive may cause a useless dropping of
+	 * locks. False negatives may cause locks to be held a bit
+	 * longer until the next check.
+	 */
+	return !list_empty(&sem->wait_list);
+}
+
+EXPORT_SYMBOL(rwsem_is_contended);
 EXPORT_SYMBOL(__init_rwsem);
 EXPORT_SYMBOL(__down_read);
 EXPORT_SYMBOL(__down_read_trylock);
Index: linux-2.6/lib/rwsem.c
===================================================================
--- linux-2.6.orig/lib/rwsem.c	2008-06-09 20:20:59.061591425 -0700
+++ linux-2.6/lib/rwsem.c	2008-06-09 20:28:47.402091148 -0700
@@ -251,6 +251,18 @@ asmregparm struct rw_semaphore *rwsem_do
 	return sem;
 }
 
+int rwsem_is_contended(struct rw_semaphore *sem)
+{
+	/*
+	 * Racy check for an empty list. False positives or negatives
+	 * would be okay. False positive may cause a useless dropping of
+	 * locks. False negatives may cause locks to be held a bit
+	 * longer until the next check.
+	 */
+	return !list_empty(&sem->wait_list);
+}
+
+EXPORT_SYMBOL(rwsem_is_contended);
 EXPORT_SYMBOL(rwsem_down_read_failed);
 EXPORT_SYMBOL(rwsem_down_write_failed);
 EXPORT_SYMBOL(rwsem_wake);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
