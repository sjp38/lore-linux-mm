Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6372D6B025F
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:42:45 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id r129so19700248wmr.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 05:42:45 -0700 (PDT)
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com. [195.75.94.104])
        by mx.google.com with ESMTPS id g16si18713345wjn.102.2016.03.20.05.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 20 Mar 2016 05:42:44 -0700 (PDT)
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rapoport@il.ibm.com>;
	Sun, 20 Mar 2016 12:42:43 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id DF0881B0804B
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:43:10 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2KCgexY8520036
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:42:40 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2KCgdTF017265
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:42:40 -0400
From: Mike Rapoport <rapoport@il.ibm.com>
Subject: [PATCH 2/5] uffd: Add ability to report non-PF events from uffd descriptor
Date: Sun, 20 Mar 2016 14:42:18 +0200
Message-Id: <1458477741-6942-3-git-send-email-rapoport@il.ibm.com>
In-Reply-To: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
References: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>, Mike Rapoport <rapoport@il.ibm.com>

From: Pavel Emelyanov <xemul@parallels.com>

The custom events are queued in ctx->event_wqh not to disturb the
fast-path-ed PF queue-wait-wakeup functions.

The events to be generated (other than PF-s) are requested in UFFD_API
ioctl with the uffd_api.features bits. Those, known by the kernel, are
then turned on and reported back to the user-space.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Mike Rapoport <rapoport@il.ibm.com>
---
 fs/userfaultfd.c | 99 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 97 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 4f0b53d..c8e7039 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -12,6 +12,7 @@
  *  mm/ksm.c (mm hashing).
  */
 
+#include <linux/list.h>
 #include <linux/hashtable.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
@@ -45,18 +46,23 @@ struct userfaultfd_ctx {
 	wait_queue_head_t fault_wqh;
 	/* waitqueue head for the pseudo fd to wakeup poll/read */
 	wait_queue_head_t fd_wqh;
+	/* waitqueue head for events */
+	wait_queue_head_t event_wqh;
 	/* a refile sequence protected by fault_pending_wqh lock */
 	struct seqcount refile_seq;
 	/* pseudo fd refcounting */
 	atomic_t refcount;
 	/* userfaultfd syscall flags */
 	unsigned int flags;
+	/* features requested from the userspace */
+	unsigned int features;
 	/* state machine */
 	enum userfaultfd_state state;
 	/* released */
 	bool released;
 	/* mm with one ore more vmas attached to this userfaultfd_ctx */
 	struct mm_struct *mm;
+
 };
 
 struct userfaultfd_wait_queue {
@@ -135,6 +141,8 @@ static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 		VM_BUG_ON(waitqueue_active(&ctx->fault_pending_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->fault_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fault_wqh));
+		VM_BUG_ON(spin_is_locked(&ctx->event_wqh.lock));
+		VM_BUG_ON(waitqueue_active(&ctx->event_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->fd_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fd_wqh));
 		mmput(ctx->mm);
@@ -423,6 +431,59 @@ out:
 	return ret;
 }
 
+static int __maybe_unused userfaultfd_event_wait_completion(
+		struct userfaultfd_ctx *ctx,
+		struct userfaultfd_wait_queue *ewq)
+{
+	int ret = 0;
+
+	ewq->ctx = ctx;
+	init_waitqueue_entry(&ewq->wq, current);
+
+	spin_lock(&ctx->event_wqh.lock);
+	/*
+	 * After the __add_wait_queue the uwq is visible to userland
+	 * through poll/read().
+	 */
+	__add_wait_queue(&ctx->event_wqh, &ewq->wq);
+	for (;;) {
+		set_current_state(TASK_KILLABLE);
+		if (ewq->msg.event == 0)
+			break;
+		if (ACCESS_ONCE(ctx->released) ||
+		    fatal_signal_pending(current)) {
+			ret = -1;
+			__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
+			break;
+		}
+
+		spin_unlock(&ctx->event_wqh.lock);
+
+		wake_up_poll(&ctx->fd_wqh, POLLIN);
+		schedule();
+
+		spin_lock(&ctx->event_wqh.lock);
+	}
+	__set_current_state(TASK_RUNNING);
+	spin_unlock(&ctx->event_wqh.lock);
+
+	/*
+	 * ctx may go away after this if the userfault pseudo fd is
+	 * already released.
+	 */
+
+	userfaultfd_ctx_put(ctx);
+	return ret;
+}
+
+static void userfaultfd_event_complete(struct userfaultfd_ctx *ctx,
+				       struct userfaultfd_wait_queue *ewq)
+{
+	ewq->msg.event = 0;
+	wake_up_locked(&ctx->event_wqh);
+	__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
+}
+
 static int userfaultfd_release(struct inode *inode, struct file *file)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
@@ -507,6 +568,12 @@ static inline struct userfaultfd_wait_queue *find_userfault(
 	return find_userfault_in(&ctx->fault_pending_wqh);
 }
 
+static inline struct userfaultfd_wait_queue *find_userfault_evt(
+		struct userfaultfd_ctx *ctx)
+{
+	return find_userfault_in(&ctx->event_wqh);
+}
+
 static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
@@ -538,6 +605,9 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 		smp_mb();
 		if (waitqueue_active(&ctx->fault_pending_wqh))
 			ret = POLLIN;
+		else if (waitqueue_active(&ctx->event_wqh))
+			ret = POLLIN;
+
 		return ret;
 	default:
 		BUG();
@@ -601,6 +671,19 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			break;
 		}
 		spin_unlock(&ctx->fault_pending_wqh.lock);
+
+		spin_lock(&ctx->event_wqh.lock);
+		uwq = find_userfault_evt(ctx);
+		if (uwq) {
+			*msg = uwq->msg;
+
+			userfaultfd_event_complete(ctx, uwq);
+			spin_unlock(&ctx->event_wqh.lock);
+			ret = 0;
+			break;
+		}
+		spin_unlock(&ctx->event_wqh.lock);
+
 		if (signal_pending(current)) {
 			ret = -ERESTARTSYS;
 			break;
@@ -1133,6 +1216,14 @@ out:
 	return ret;
 }
 
+static inline unsigned int uffd_ctx_features(__u64 user_features)
+{
+	/*
+	 * For the current set of features the bits just coincide
+	 */
+	return (unsigned int)user_features;
+}
+
 /*
  * userland asks for a certain API version and we return which bits
  * and ioctl commands are implemented in this kernel for such API
@@ -1151,19 +1242,21 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 	ret = -EFAULT;
 	if (copy_from_user(&uffdio_api, buf, sizeof(uffdio_api)))
 		goto out;
-	if (uffdio_api.api != UFFD_API || uffdio_api.features) {
+	if (uffdio_api.api != UFFD_API ||
+	    (uffdio_api.features & ~UFFD_API_FEATURES)) {
 		memset(&uffdio_api, 0, sizeof(uffdio_api));
 		if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
 			goto out;
 		ret = -EINVAL;
 		goto out;
 	}
-	uffdio_api.features = UFFD_API_FEATURES;
+	uffdio_api.features &= UFFD_API_FEATURES;
 	uffdio_api.ioctls = UFFD_API_IOCTLS;
 	ret = -EFAULT;
 	if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
 		goto out;
 	ctx->state = UFFD_STATE_RUNNING;
+	ctx->features = uffd_ctx_features(uffdio_api.features);
 	ret = 0;
 out:
 	return ret;
@@ -1250,6 +1343,7 @@ static void init_once_userfaultfd_ctx(void *mem)
 
 	init_waitqueue_head(&ctx->fault_pending_wqh);
 	init_waitqueue_head(&ctx->fault_wqh);
+	init_waitqueue_head(&ctx->event_wqh);
 	init_waitqueue_head(&ctx->fd_wqh);
 	seqcount_init(&ctx->refile_seq);
 }
@@ -1290,6 +1384,7 @@ static struct file *userfaultfd_file_create(int flags)
 
 	atomic_set(&ctx->refcount, 1);
 	ctx->flags = flags;
+	ctx->features = 0;
 	ctx->state = UFFD_STATE_WAIT_API;
 	ctx->released = false;
 	ctx->mm = current->mm;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
