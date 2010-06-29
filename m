Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AF34B6B01B4
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 15:09:55 -0400 (EDT)
Date: Tue, 29 Jun 2010 12:08:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [S+Q 01/16] [PATCH] ipc/sem.c: Bugfix for semop() not reporting
 successful operation
Message-Id: <20100629120857.00f4b42d.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006291042100.16135@router.home>
References: <20100625212026.810557229@quilx.com>
	<20100625212101.622422748@quilx.com>
	<AANLkTinmvRtH24uflD9e7MknaW6tgMSnN75vVgaj0IM6@mail.gmail.com>
	<alpine.DEB.2.00.1006291042100.16135@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 2010 10:42:42 -0500 (CDT)
Christoph Lameter <cl@linux-foundation.org> wrote:

> This is a patch from Manfred. Required to make 2.6.35-rc3 work.
> 

My current version of the patch is below.

I believe that Luca has still seen problems with this patch applied so
its current status is "stuck, awaiting developments".

Is that a correct determination?

Thanks.


From: Manfred Spraul <manfred@colorfullife.com>

The last change to improve the scalability moved the actual wake-up out of
the section that is protected by spin_lock(sma->sem_perm.lock).

This means that IN_WAKEUP can be in queue.status even when the spinlock is
acquired by the current task.  Thus the same loop that is performed when
queue.status is read without the spinlock acquired must be performed when
the spinlock is acquired.

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=16255

[akpm@linux-foundation.org: clean up kerneldoc, checkpatch warning and whitespace]
Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
Reported-by: Luca Tettamanti <kronos.it@gmail.com>
Tested-by: Luca Tettamanti <kronos.it@gmail.com>
Reported-by: Christoph Lameter <cl@linux-foundation.org>
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 ipc/sem.c |   37 +++++++++++++++++++++++++++++++------
 1 file changed, 31 insertions(+), 6 deletions(-)

diff -puN ipc/sem.c~ipc-semc-bugfix-for-semop-not-reporting-successful-operation ipc/sem.c
--- a/ipc/sem.c~ipc-semc-bugfix-for-semop-not-reporting-successful-operation
+++ a/ipc/sem.c
@@ -1256,6 +1256,33 @@ out:
 	return un;
 }
 
+
+/**
+ * get_queue_result - Retrieve the result code from sem_queue
+ * @q: Pointer to queue structure
+ *
+ * Retrieve the return code from the pending queue. If IN_WAKEUP is found in
+ * q->status, then we must loop until the value is replaced with the final
+ * value: This may happen if a task is woken up by an unrelated event (e.g.
+ * signal) and in parallel the task is woken up by another task because it got
+ * the requested semaphores.
+ *
+ * The function can be called with or without holding the semaphore spinlock.
+ */
+static int get_queue_result(struct sem_queue *q)
+{
+	int error;
+
+	error = q->status;
+	while (unlikely(error == IN_WAKEUP)) {
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
@@ -1409,11 +1436,7 @@ SYSCALL_DEFINE4(semtimedop, int, semid, 
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
@@ -1427,10 +1450,12 @@ SYSCALL_DEFINE4(semtimedop, int, semid, 
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
