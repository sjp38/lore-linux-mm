Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 41E3C6B006E
	for <linux-mm@kvack.org>; Wed, 13 May 2015 10:53:08 -0400 (EDT)
Received: by pdea3 with SMTP id a3so53913168pde.3
        for <linux-mm@kvack.org>; Wed, 13 May 2015 07:53:08 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kl4si27379718pbc.127.2015.05.13.07.53.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 07:53:06 -0700 (PDT)
Message-ID: <5553654A.7010007@parallels.com>
Date: Wed, 13 May 2015 17:52:58 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 2/5] uffd: Add ability to report non-PF events from uffd descriptor
References: <5553651B.1020909@parallels.com>
In-Reply-To: <5553651B.1020909@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>

The custom events are queued in ctx->event_wqh not to disturb the
fast-path-ed PF queue-wait-wakeup functions.

The events to be generated (other than PF-s) are requested in UFFD_API
ioctl with the uffd_api.features bits. Those, known by the kernel, are
then turned on and reported back to the user-space.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 fs/userfaultfd.c | 97 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 95 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index c593a72..83acb19 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -12,6 +12,7 @@
  *  mm/ksm.c (mm hashing).
  */
 
+#include <linux/list.h>
 #include <linux/hashtable.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
@@ -43,12 +44,16 @@ struct userfaultfd_ctx {
 	wait_queue_head_t fault_pending_wqh;
 	/* waitqueue head for the userfaults */
 	wait_queue_head_t fault_wqh;
+	/* waitqueue head for events */
+	wait_queue_head_t event_wqh;
 	/* waitqueue head for the pseudo fd to wakeup poll/read */
 	wait_queue_head_t fd_wqh;
 	/* pseudo fd refcounting */
 	atomic_t refcount;
 	/* userfaultfd syscall flags */
 	unsigned int flags;
+	/* features requested from the userspace */
+	unsigned int features;
 	/* state machine */
 	enum userfaultfd_state state;
 	/* released */
@@ -120,6 +125,8 @@ static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 		VM_BUG_ON(waitqueue_active(&ctx->fault_pending_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->fault_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fault_wqh));
+		VM_BUG_ON(spin_is_locked(&ctx->event_wqh.lock));
+		VM_BUG_ON(waitqueue_active(&ctx->event_wqh));
 		VM_BUG_ON(spin_is_locked(&ctx->fd_wqh.lock));
 		VM_BUG_ON(waitqueue_active(&ctx->fd_wqh));
 		mmput(ctx->mm);
@@ -373,6 +380,58 @@ out:
 	return ret;
 }
 
+static int __maybe_unused userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
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
+				fatal_signal_pending(current)) {
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
+		struct userfaultfd_wait_queue *ewq)
+{
+	ewq->msg.event = 0;
+	wake_up_locked(&ctx->event_wqh);
+	__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
+}
+
 static int userfaultfd_release(struct inode *inode, struct file *file)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
@@ -458,6 +517,12 @@ static inline struct userfaultfd_wait_queue *find_userfault(
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
@@ -489,6 +554,9 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 		smp_mb();
 		if (waitqueue_active(&ctx->fault_pending_wqh))
 			ret = POLLIN;
+		else if (waitqueue_active(&ctx->event_wqh))
+			ret = POLLIN;
+
 		return ret;
 	default:
 		BUG();
@@ -528,6 +596,19 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
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
@@ -1084,6 +1165,14 @@ out:
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
@@ -1102,19 +1191,21 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 	ret = -EFAULT;
 	if (copy_from_user(&uffdio_api, buf, sizeof(uffdio_api)))
 		goto out;
-	if (uffdio_api.api != UFFD_API || uffdio_api.features) {
+	if (uffdio_api.api != UFFD_API ||
+			(uffdio_api.features & ~UFFD_API_FEATURES)) {
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
@@ -1201,6 +1292,7 @@ static void init_once_userfaultfd_ctx(void *mem)
 
 	init_waitqueue_head(&ctx->fault_pending_wqh);
 	init_waitqueue_head(&ctx->fault_wqh);
+	init_waitqueue_head(&ctx->event_wqh);
 	init_waitqueue_head(&ctx->fd_wqh);
 }
 
@@ -1240,6 +1332,7 @@ static struct file *userfaultfd_file_create(int flags)
 
 	atomic_set(&ctx->refcount, 1);
 	ctx->flags = flags;
+	ctx->features = 0;
 	ctx->state = UFFD_STATE_WAIT_API;
 	ctx->released = false;
 	ctx->mm = current->mm;
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
