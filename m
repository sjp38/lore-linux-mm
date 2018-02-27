Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A47DA6B0008
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:07 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id c9so8077768qth.16
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 00:20:07 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a11si907578qtc.480.2018.02.27.00.20.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 00:20:06 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1R8JmRM086406
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:06 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gd1xcv5ys-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 03:20:05 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 27 Feb 2018 08:20:03 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/3] userfaultfd: non-cooperative: generalize wake key structure
Date: Tue, 27 Feb 2018 10:19:51 +0200
In-Reply-To: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1519719592-22668-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, crml <criu@openvz.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Upcoming support for synchronous non-page-fault events will require
userfaultfd_wake_function to be able to differentiate between the event
types. Depending on the event type, different parameters will define if the
wait queue element should be awaken. This requires more general structure
than userfaultfd_wake_range to be used as the "key" parameter for
userfaultfd_wake_function.
This patch introduces userfaultfd_wake_key that is used for waking up
threads waiting on page-fault and non-cooperative events.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 114 +++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 72 insertions(+), 42 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index b32c7aaeca6b..d9f74b389706 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -91,21 +91,44 @@ struct userfaultfd_wake_range {
 	unsigned long len;
 };
 
+struct userfaultfd_wake_key {
+	u8 event;
+	union {
+		struct userfaultfd_wake_range range;
+	} arg;
+};
+
+static bool userfaultfd_should_wake(struct userfaultfd_wait_queue *uwq,
+				    struct userfaultfd_wake_key *key)
+{
+	/* key->event == 0 means wake all */
+	if (key->event && key->event != uwq->msg.event)
+		return false;
+
+	if (key->event == UFFD_EVENT_PAGEFAULT) {
+		unsigned long start, len, address;
+
+		/* len == 0 means wake all threads waiting on page fault */
+		address = uwq->msg.arg.pagefault.address;
+		start = key->arg.range.start;
+		len = key->arg.range.len;
+		if (len && (start > address || start + len <= address))
+			return false;
+	}
+
+	return true;
+}
+
 static int userfaultfd_wake_function(wait_queue_entry_t *wq, unsigned mode,
-				     int wake_flags, void *key)
+				     int wake_flags, void *_key)
 {
-	struct userfaultfd_wake_range *range = key;
+	struct userfaultfd_wake_key *key = _key;
 	int ret;
 	struct userfaultfd_wait_queue *uwq;
-	unsigned long start, len;
 
 	uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
 	ret = 0;
-	/* len == 0 means wake all */
-	start = range->start;
-	len = range->len;
-	if (len && (start > uwq->msg.arg.pagefault.address ||
-		    start + len <= uwq->msg.arg.pagefault.address))
+	if (!userfaultfd_should_wake(uwq, key))
 		goto out;
 	WRITE_ONCE(uwq->waken, true);
 	/*
@@ -585,7 +608,7 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 		goto out;
 
 	ewq->ctx = ctx;
-	init_waitqueue_entry(&ewq->wq, current);
+	userfaultfd_init_waitqueue(ctx, ewq);
 	release_new_ctx = NULL;
 
 	spin_lock(&ctx->event_wqh.lock);
@@ -596,7 +619,7 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 	__add_wait_queue(&ctx->event_wqh, &ewq->wq);
 	for (;;) {
 		set_current_state(TASK_KILLABLE);
-		if (ewq->msg.event == 0)
+		if (READ_ONCE(ewq->waken))
 			break;
 		if (READ_ONCE(ctx->released) ||
 		    fatal_signal_pending(current)) {
@@ -653,9 +676,10 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 static void userfaultfd_event_complete(struct userfaultfd_ctx *ctx,
 				       struct userfaultfd_wait_queue *ewq)
 {
-	ewq->msg.event = 0;
-	wake_up_locked(&ctx->event_wqh);
-	__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
+	struct userfaultfd_wake_key key = { 0 };
+
+	key.event = ewq->msg.event;
+	 __wake_up_locked_key(&ctx->event_wqh, TASK_NORMAL, &key);
 }
 
 int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
@@ -854,8 +878,10 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	struct userfaultfd_ctx *ctx = file->private_data;
 	struct mm_struct *mm = ctx->mm;
 	struct vm_area_struct *vma, *prev;
-	/* len == 0 means wake all */
-	struct userfaultfd_wake_range range = { .len = 0, };
+	/* event == 0 means wake all */
+	struct userfaultfd_wake_key key = {
+		.event = 0,
+	};
 	unsigned long new_flags;
 
 	WRITE_ONCE(ctx->released, true);
@@ -903,12 +929,12 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * the fault_*wqh.
 	 */
 	spin_lock(&ctx->fault_pending_wqh.lock);
-	__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &range);
-	__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, &range);
+	__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &key);
+	__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, &key);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 
 	/* Flush pending events that may still wait on event_wqh */
-	wake_up_all(&ctx->event_wqh);
+	__wake_up(&ctx->event_wqh, TASK_NORMAL, 0, &key);
 
 	wake_up_poll(&ctx->fd_wqh, EPOLLHUP);
 	userfaultfd_ctx_put(ctx);
@@ -1201,20 +1227,20 @@ static ssize_t userfaultfd_read(struct file *file, char __user *buf,
 }
 
 static void __wake_userfault(struct userfaultfd_ctx *ctx,
-			     struct userfaultfd_wake_range *range)
+			     struct userfaultfd_wake_key *key)
 {
 	spin_lock(&ctx->fault_pending_wqh.lock);
 	/* wake all in the range and autoremove */
 	if (waitqueue_active(&ctx->fault_pending_wqh))
 		__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL,
-				     range);
+				     key);
 	if (waitqueue_active(&ctx->fault_wqh))
-		__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, range);
+		__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, key);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 }
 
 static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
-					   struct userfaultfd_wake_range *range)
+					   struct userfaultfd_wake_key *key)
 {
 	unsigned seq;
 	bool need_wakeup;
@@ -1241,7 +1267,7 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
 		cond_resched();
 	} while (read_seqcount_retry(&ctx->refile_seq, seq));
 	if (need_wakeup)
-		__wake_userfault(ctx, range);
+		__wake_userfault(ctx, key);
 }
 
 static __always_inline int validate_range(struct mm_struct *mm,
@@ -1567,10 +1593,11 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 			 * permanently and it avoids userland to call
 			 * UFFDIO_WAKE explicitly.
 			 */
-			struct userfaultfd_wake_range range;
-			range.start = start;
-			range.len = vma_end - start;
-			wake_userfault(vma->vm_userfaultfd_ctx.ctx, &range);
+			struct userfaultfd_wake_key key;
+			key.event = UFFD_EVENT_PAGEFAULT;
+			key.arg.range.start = start;
+			key.arg.range.len = vma_end - start;
+			wake_userfault(vma->vm_userfaultfd_ctx.ctx, &key);
 		}
 
 		new_flags = vma->vm_flags & ~(VM_UFFD_MISSING | VM_UFFD_WP);
@@ -1622,7 +1649,7 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
 {
 	int ret;
 	struct uffdio_range uffdio_wake;
-	struct userfaultfd_wake_range range;
+	struct userfaultfd_wake_key key;
 	const void __user *buf = (void __user *)arg;
 
 	ret = -EFAULT;
@@ -1633,16 +1660,17 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
 	if (ret)
 		goto out;
 
-	range.start = uffdio_wake.start;
-	range.len = uffdio_wake.len;
+	key.event = UFFD_EVENT_PAGEFAULT;
+	key.arg.range.start = uffdio_wake.start;
+	key.arg.range.len = uffdio_wake.len;
 
 	/*
 	 * len == 0 means wake all and we don't want to wake all here,
 	 * so check it again to be sure.
 	 */
-	VM_BUG_ON(!range.len);
+	VM_BUG_ON(!key.arg.range.len);
 
-	wake_userfault(ctx, &range);
+	wake_userfault(ctx, &key);
 	ret = 0;
 
 out:
@@ -1655,7 +1683,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 	__s64 ret;
 	struct uffdio_copy uffdio_copy;
 	struct uffdio_copy __user *user_uffdio_copy;
-	struct userfaultfd_wake_range range;
+	struct userfaultfd_wake_key key;
 
 	user_uffdio_copy = (struct uffdio_copy __user *) arg;
 
@@ -1691,12 +1719,13 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 		goto out;
 	BUG_ON(!ret);
 	/* len == 0 would wake all */
-	range.len = ret;
+	key.event = UFFD_EVENT_PAGEFAULT;
+	key.arg.range.len = ret;
 	if (!(uffdio_copy.mode & UFFDIO_COPY_MODE_DONTWAKE)) {
-		range.start = uffdio_copy.dst;
-		wake_userfault(ctx, &range);
+		key.arg.range.start = uffdio_copy.dst;
+		wake_userfault(ctx, &key);
 	}
-	ret = range.len == uffdio_copy.len ? 0 : -EAGAIN;
+	ret = key.arg.range.len == uffdio_copy.len ? 0 : -EAGAIN;
 out:
 	return ret;
 }
@@ -1707,7 +1736,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 	__s64 ret;
 	struct uffdio_zeropage uffdio_zeropage;
 	struct uffdio_zeropage __user *user_uffdio_zeropage;
-	struct userfaultfd_wake_range range;
+	struct userfaultfd_wake_key key;
 
 	user_uffdio_zeropage = (struct uffdio_zeropage __user *) arg;
 
@@ -1738,12 +1767,13 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 		goto out;
 	/* len == 0 would wake all */
 	BUG_ON(!ret);
-	range.len = ret;
+	key.event = UFFD_EVENT_PAGEFAULT;
+	key.arg.range.len = ret;
 	if (!(uffdio_zeropage.mode & UFFDIO_ZEROPAGE_MODE_DONTWAKE)) {
-		range.start = uffdio_zeropage.range.start;
-		wake_userfault(ctx, &range);
+		key.arg.range.start = uffdio_zeropage.range.start;
+		wake_userfault(ctx, &key);
 	}
-	ret = range.len == uffdio_zeropage.range.len ? 0 : -EAGAIN;
+	ret = key.arg.range.len == uffdio_zeropage.range.len ? 0 : -EAGAIN;
 out:
 	return ret;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
