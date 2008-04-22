Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 07 of 12] Add a function to rw_semaphores to check if there
	are any processes
Message-Id: <8965539f4d174c79bd37.1208872283@duo.random>
In-Reply-To: <patchbomb.1208872276@duo.random>
Date: Tue, 22 Apr 2008 15:51:23 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1208872187 -7200
# Node ID 8965539f4d174c79bd37e58e8b037d5db906e219
# Parent  fbce3fecb033eb3fba1d9c2398ac74401ce0ecb5
Add a function to rw_semaphores to check if there are any processes
waiting for the semaphore. Add rwsem_needbreak to sched.h that works
in the same way as spinlock_needbreak().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -59,6 +59,8 @@
  */
 extern void downgrade_write(struct rw_semaphore *sem);
 
+extern int rwsem_is_contended(struct rw_semaphore *sem);
+
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 /*
  * nested locking. NOTE: rwsems are not allowed to recurse
diff --git a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1984,6 +1984,15 @@
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
diff --git a/lib/rwsem-spinlock.c b/lib/rwsem-spinlock.c
--- a/lib/rwsem-spinlock.c
+++ b/lib/rwsem-spinlock.c
@@ -305,6 +305,18 @@
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
diff --git a/lib/rwsem.c b/lib/rwsem.c
--- a/lib/rwsem.c
+++ b/lib/rwsem.c
@@ -251,6 +251,18 @@
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
