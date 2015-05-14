Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 78F0B6B009C
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:57 -0400 (EDT)
Received: by wibt6 with SMTP id t6so23973651wib.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fc9si39845246wjc.177.2015.05.14.10.31.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:45 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 14/23] userfaultfd: wake pending userfaults
Date: Thu, 14 May 2015 19:31:11 +0200
Message-Id: <1431624680-20153-15-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

This is an optimization but it's a userland visible one and it affects
the API.

The downside of this optimization is that if you call poll() and you
get POLLIN, read(ufd) may still return -EAGAIN. The blocked userfault
may be waken by a different thread, before read(ufd) comes
around. This in short means that poll() isn't really usable if the
userfaultfd is opened in blocking mode.

userfaults won't wait in "pending" state to be read anymore and any
UFFDIO_WAKE or similar operations that has the objective of waking
userfaults after their resolution, will wake all blocked userfaults
for the resolved range, including those that haven't been read() by
userland yet.

The behavior of poll() becomes not standard, but this obviates the
need of "spurious" UFFDIO_WAKE and it lets the userland threads to
restart immediately without requiring an UFFDIO_WAKE. This is even
more significant in case of repeated faults on the same address from
multiple threads.

This optimization is justified by the measurement that the number of
spurious UFFDIO_WAKE accounts for 5% and 10% of the total
userfaults for heavy workloads, so it's worth optimizing those away.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 65 +++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 43 insertions(+), 22 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index b45cefe..50edbd8 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -52,6 +52,10 @@ struct userfaultfd_ctx {
 struct userfaultfd_wait_queue {
 	struct uffd_msg msg;
 	wait_queue_t wq;
+	/*
+	 * Only relevant when queued in fault_wqh and only used by the
+	 * read operation to avoid reading the same userfault twice.
+	 */
 	bool pending;
 	struct userfaultfd_ctx *ctx;
 };
@@ -71,9 +75,6 @@ static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
 
 	uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
 	ret = 0;
-	/* don't wake the pending ones to avoid reads to block */
-	if (uwq->pending && !ACCESS_ONCE(uwq->ctx->released))
-		goto out;
 	/* len == 0 means wake all */
 	start = range->start;
 	len = range->len;
@@ -183,12 +184,14 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	struct mm_struct *mm = vma->vm_mm;
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue uwq;
+	int ret;
 
 	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
+	ret = VM_FAULT_SIGBUS;
 	ctx = vma->vm_userfaultfd_ctx.ctx;
 	if (!ctx)
-		return VM_FAULT_SIGBUS;
+		goto out;
 
 	BUG_ON(ctx->mm != mm);
 
@@ -201,7 +204,7 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	 * caller of handle_userfault to release the mmap_sem.
 	 */
 	if (unlikely(ACCESS_ONCE(ctx->released)))
-		return VM_FAULT_SIGBUS;
+		goto out;
 
 	/*
 	 * Check that we can return VM_FAULT_RETRY.
@@ -227,15 +230,16 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 			dump_stack();
 		}
 #endif
-		return VM_FAULT_SIGBUS;
+		goto out;
 	}
 
 	/*
 	 * Handle nowait, not much to do other than tell it to retry
 	 * and wait.
 	 */
+	ret = VM_FAULT_RETRY;
 	if (flags & FAULT_FLAG_RETRY_NOWAIT)
-		return VM_FAULT_RETRY;
+		goto out;
 
 	/* take the reference before dropping the mmap_sem */
 	userfaultfd_ctx_get(ctx);
@@ -255,21 +259,23 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	 * through poll/read().
 	 */
 	__add_wait_queue(&ctx->fault_wqh, &uwq.wq);
-	for (;;) {
-		set_current_state(TASK_KILLABLE);
-		if (!uwq.pending || ACCESS_ONCE(ctx->released) ||
-		    fatal_signal_pending(current))
-			break;
-		spin_unlock(&ctx->fault_wqh.lock);
+	set_current_state(TASK_KILLABLE);
+	spin_unlock(&ctx->fault_wqh.lock);
 
+	if (likely(!ACCESS_ONCE(ctx->released) &&
+		   !fatal_signal_pending(current))) {
 		wake_up_poll(&ctx->fd_wqh, POLLIN);
 		schedule();
+		ret |= VM_FAULT_MAJOR;
+	}
 
+	__set_current_state(TASK_RUNNING);
+	/* see finish_wait() comment for why list_empty_careful() */
+	if (!list_empty_careful(&uwq.wq.task_list)) {
 		spin_lock(&ctx->fault_wqh.lock);
+		list_del_init(&uwq.wq.task_list);
+		spin_unlock(&ctx->fault_wqh.lock);
 	}
-	__remove_wait_queue(&ctx->fault_wqh, &uwq.wq);
-	__set_current_state(TASK_RUNNING);
-	spin_unlock(&ctx->fault_wqh.lock);
 
 	/*
 	 * ctx may go away after this if the userfault pseudo fd is
@@ -277,7 +283,8 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	 */
 	userfaultfd_ctx_put(ctx);
 
-	return VM_FAULT_RETRY;
+out:
+	return ret;
 }
 
 static int userfaultfd_release(struct inode *inode, struct file *file)
@@ -391,6 +398,12 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 	case UFFD_STATE_WAIT_API:
 		return POLLERR;
 	case UFFD_STATE_RUNNING:
+		/*
+		 * poll() never guarantees that read won't block.
+		 * userfaults can be waken before they're read().
+		 */
+		if (unlikely(!(file->f_flags & O_NONBLOCK)))
+			return POLLERR;
 		spin_lock(&ctx->fault_wqh.lock);
 		ret = find_userfault(ctx, NULL);
 		spin_unlock(&ctx->fault_wqh.lock);
@@ -806,11 +819,19 @@ out:
 }
 
 /*
- * This is mostly needed to re-wakeup those userfaults that were still
- * pending when userland wake them up the first time. We don't wake
- * the pending one to avoid blocking reads to block, or non blocking
- * read to return -EAGAIN, if used with POLLIN, to avoid userland
- * doubts on why POLLIN wasn't reliable.
+ * userfaultfd_wake is needed in case an userfault is in flight by the
+ * time a UFFDIO_COPY (or other ioctl variants) completes. The page
+ * may be well get mapped and the page fault if repeated wouldn't lead
+ * to a userfault anymore, but before scheduling in TASK_KILLABLE mode
+ * handle_userfault() doesn't recheck the pagetables and it doesn't
+ * serialize against UFFDO_COPY (or other ioctl variants). Ultimately
+ * the knowledge of which pages are mapped is left to userland who is
+ * responsible for handling the race between read() userfaults and
+ * background UFFDIO_COPY (or other ioctl variants), if done by
+ * separate concurrent threads.
+ *
+ * userfaultfd_wake may be used in combination with the
+ * UFFDIO_*_MODE_DONTWAKE to wakeup userfaults in batches.
  */
 static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
 			    unsigned long arg)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
