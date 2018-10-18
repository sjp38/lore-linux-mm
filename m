Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5196B0010
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 11:41:10 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d63-v6so23282573pld.18
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 08:41:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 29-v6si21598951pgl.104.2018.10.18.08.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Oct 2018 08:41:09 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] userfaultfd: disable irqs when taking the waitqueue lock
Date: Thu, 18 Oct 2018 17:41:01 +0200
Message-Id: <20181018154101.18750-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

userfaultfd contains howe-grown locking of the waitqueue lock,
and does not disable interrupts.  This relies on the fact that
no one else takes it from interrupt context and violates an
invariat of the normal waitqueue locking scheme.  With aio poll
it is easy to trigger other locks that disable interrupts (or
are called from interrupt context).

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/userfaultfd.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index bfa0ec69f924..356d2b8568c1 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1026,7 +1026,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 	struct userfaultfd_ctx *fork_nctx = NULL;
 
 	/* always take the fd_wqh lock before the fault_pending_wqh lock */
-	spin_lock(&ctx->fd_wqh.lock);
+	spin_lock_irq(&ctx->fd_wqh.lock);
 	__add_wait_queue(&ctx->fd_wqh, &wait);
 	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
@@ -1112,13 +1112,13 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			ret = -EAGAIN;
 			break;
 		}
-		spin_unlock(&ctx->fd_wqh.lock);
+		spin_unlock_irq(&ctx->fd_wqh.lock);
 		schedule();
-		spin_lock(&ctx->fd_wqh.lock);
+		spin_lock_irq(&ctx->fd_wqh.lock);
 	}
 	__remove_wait_queue(&ctx->fd_wqh, &wait);
 	__set_current_state(TASK_RUNNING);
-	spin_unlock(&ctx->fd_wqh.lock);
+	spin_unlock_irq(&ctx->fd_wqh.lock);
 
 	if (!ret && msg->event == UFFD_EVENT_FORK) {
 		ret = resolve_userfault_fork(ctx, fork_nctx, msg);
-- 
2.19.1
