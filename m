Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D57B6B0038
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 14:04:20 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o200so5250007itg.2
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:04:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f66si1095298oib.48.2017.09.20.11.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 11:04:18 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] userfaultfd: non-cooperative: fix fork use after free
Date: Wed, 20 Sep 2017 20:04:13 +0200
Message-Id: <20170920180413.26713-1-aarcange@redhat.com>
In-Reply-To: <20170919131839.GD30715@leverpostej>
References: <20170919131839.GD30715@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, syzkaller@googlegroups.com, stable@vger.kernel.org

When reading the event from the uffd, we put it on a temporary
fork_event list to detect if we can still access it after releasing
and retaking the event_wqh.lock.

If fork aborts and removes the event from the fork_event all is fine
as long as we're still in the userfault read context and fork_event
head is still alive.

We've to put the event allocated in the fork kernel stack, back from
fork_event list-head to the event_wqh head, before returning from
userfaultfd_ctx_read, because the fork_event head lifetime is limited
to the userfaultfd_ctx_read stack lifetime.

Forgetting to move the event back to its event_wqh place then results
in __remove_wait_queue(&ctx->event_wqh, &ewq->wq); in
userfaultfd_event_wait_completion to remove it from a head that has
been already freed from the reader stack.

This could only happen if resolve_userfault_fork failed (for example
if there are no file descriptors available to allocate the fork
uffd). If it succeeded it was put back correctly.

Furthermore, after find_userfault_evt receives a fork event, the
forked userfault context in fork_nctx and
uwq->msg.arg.reserved.reserved1 can be released by the fork thread as
soon as the event_wqh.lock is released. Taking a reference on the
fork_nctx before dropping the lock prevents an use after free in
resolve_userfault_fork().

If the fork side aborted and it already released everything, we still
try to succeed resolve_userfault_fork(), if possible.

Reported-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 66 +++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 56 insertions(+), 10 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 06d6cfda1e8e..16366587e579 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -599,6 +599,12 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 			break;
 		if (ACCESS_ONCE(ctx->released) ||
 		    fatal_signal_pending(current)) {
+			/*
+			 * &ewq->wq may be queued in fork_event, but
+			 * __remove_wait_queue ignores the head
+			 * parameter. It would be a problem if it
+			 * didn't.
+			 */
 			__remove_wait_queue(&ctx->event_wqh, &ewq->wq);
 			if (ewq->msg.event == UFFD_EVENT_FORK) {
 				struct userfaultfd_ctx *new;
@@ -1072,6 +1078,12 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 					(unsigned long)
 					uwq->msg.arg.reserved.reserved1;
 				list_move(&uwq->wq.entry, &fork_event);
+				/*
+				 * fork_nctx can be freed as soon as
+				 * we drop the lock, unless we take a
+				 * reference on it.
+				 */
+				userfaultfd_ctx_get(fork_nctx);
 				spin_unlock(&ctx->event_wqh.lock);
 				ret = 0;
 				break;
@@ -1102,19 +1114,53 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 
 	if (!ret && msg->event == UFFD_EVENT_FORK) {
 		ret = resolve_userfault_fork(ctx, fork_nctx, msg);
+		spin_lock(&ctx->event_wqh.lock);
+		if (!list_empty(&fork_event)) {
+			/*
+			 * The fork thread didn't abort, so we can
+			 * drop the temporary refcount.
+			 */
+			userfaultfd_ctx_put(fork_nctx);
+
+			uwq = list_first_entry(&fork_event,
+					       typeof(*uwq),
+					       wq.entry);
+			/*
+			 * If fork_event list wasn't empty and in turn
+			 * the event wasn't already released by fork
+			 * (the event is allocated on fork kernel
+			 * stack), put the event back to its place in
+			 * the event_wq. fork_event head will be freed
+			 * as soon as we return so the event cannot
+			 * stay queued there no matter the current
+			 * "ret" value.
+			 */
+			list_del(&uwq->wq.entry);
+			__add_wait_queue(&ctx->event_wqh, &uwq->wq);
 
-		if (!ret) {
-			spin_lock(&ctx->event_wqh.lock);
-			if (!list_empty(&fork_event)) {
-				uwq = list_first_entry(&fork_event,
-						       typeof(*uwq),
-						       wq.entry);
-				list_del(&uwq->wq.entry);
-				__add_wait_queue(&ctx->event_wqh, &uwq->wq);
+			/*
+			 * Leave the event in the waitqueue and report
+			 * error to userland if we failed to resolve
+			 * the userfault fork.
+			 */
+			if (likely(!ret))
 				userfaultfd_event_complete(ctx, uwq);
-			}
-			spin_unlock(&ctx->event_wqh.lock);
+		} else {
+			/*
+			 * Here the fork thread aborted and the
+			 * refcount from the fork thread on fork_nctx
+			 * has already been released. We still hold
+			 * the reference we took before releasing the
+			 * lock above. If resolve_userfault_fork
+			 * failed we've to drop it because the
+			 * fork_nctx has to be freed in such case. If
+			 * it succeeded we'll hold it because the new
+			 * uffd references it.
+			 */
+			if (ret)
+				userfaultfd_ctx_put(fork_nctx);
 		}
+		spin_unlock(&ctx->event_wqh.lock);
 	}
 
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
