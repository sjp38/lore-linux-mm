Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 061D76B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:12:14 -0400 (EDT)
Message-Id: <20100709190850.289011972@quilx.com>
Date: Fri, 09 Jul 2010 14:07:07 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q2 01/19] Bugfix for semop() not reporting successful operation
References: <20100709190706.938177313@quilx.com>
Content-Disposition: inline; filename=0001-ipc-sem.c-Bugfix-for-semop.patch
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

[Necessary to make 2.6.35-rc3 not deadlock. Not sure if this is the "right"(tm)
fix]

The last change to improve the scalability moved the actual wake-up out of
the section that is protected by spin_lock(sma->sem_perm.lock).

This means that IN_WAKEUP can be in queue.status even when the spinlock is
acquired by the current task. Thus the same loop that is performed when
queue.status is read without the spinlock acquired must be performed when
the spinlock is acquired.

Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 ipc/sem.c |   36 ++++++++++++++++++++++++++++++------
 1 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/ipc/sem.c b/ipc/sem.c
index 506c849..523665f 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -1256,6 +1256,32 @@ out:
 	return un;
 }
 
+
+/** get_queue_result - Retrieve the result code from sem_queue
+ * @q: Pointer to queue structure
+ *
+ * The function retrieve the return code from the pending queue. If 
+ * IN_WAKEUP is found in q->status, then we must loop until the value
+ * is replaced with the final value: This may happen if a task is
+ * woken up by an unrelated event (e.g. signal) and in parallel the task
+ * is woken up by another task because it got the requested semaphores.
+ *
+ * The function can be called with or without holding the semaphore spinlock.
+ */
+static int get_queue_result(struct sem_queue *q)
+{
+	int error;
+
+	error = q->status;
+	while(unlikely(error == IN_WAKEUP)) {
+		cpu_relax();
+		error = q->status;
+	}
+
+	return error;
+}
+
+
 SYSCALL_DEFINE4(semtimedop, int, semid, struct sembuf __user *, tsops,
 		unsigned, nsops, const struct timespec __user *, timeout)
 {
@@ -1409,11 +1435,7 @@ SYSCALL_DEFINE4(semtimedop, int, semid, struct sembuf __user *, tsops,
 	else
 		schedule();
 
-	error = queue.status;
-	while(unlikely(error == IN_WAKEUP)) {
-		cpu_relax();
-		error = queue.status;
-	}
+	error = get_queue_result(&queue);
 
 	if (error != -EINTR) {
 		/* fast path: update_queue already obtained all requested
@@ -1427,10 +1449,12 @@ SYSCALL_DEFINE4(semtimedop, int, semid, struct sembuf __user *, tsops,
 		goto out_free;
 	}
 
+	error = get_queue_result(&queue);
+
 	/*
 	 * If queue.status != -EINTR we are woken up by another process
 	 */
-	error = queue.status;
+
 	if (error != -EINTR) {
 		goto out_unlock_free;
 	}
-- 
1.7.0.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
