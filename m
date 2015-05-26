Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id E988F6B00C8
	for <linux-mm@kvack.org>; Tue, 26 May 2015 11:34:12 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so86579122wic.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 08:34:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e3si24428471wjw.125.2015.05.26.08.34.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 08:34:11 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] userfaultfd: cleanup superfluous _irq locking
Date: Tue, 26 May 2015 17:34:01 +0200
Message-Id: <1432654441-28023-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1432654441-28023-1-git-send-email-aarcange@redhat.com>
References: <1432654441-28023-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

This leftover shouldn't have caused any malfunction because the loop
either schedules or it re-enables irqs immediately and schedule()
doesn't seem to BUG_ON(irqs_disabled()). However lately we've been
using the non blocking model so the schedule isn't really exercised
here. Regardless of the side effects this must be fixed as it's not ok
to enter schedule with irq disabled and it's not beneficial to toggle
irqs in the first place.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index a519f74..5f11678 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -558,11 +558,11 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 		}
 		spin_unlock(&ctx->fd_wqh.lock);
 		schedule();
-		spin_lock_irq(&ctx->fd_wqh.lock);
+		spin_lock(&ctx->fd_wqh.lock);
 	}
 	__remove_wait_queue(&ctx->fd_wqh, &wait);
 	__set_current_state(TASK_RUNNING);
-	spin_unlock_irq(&ctx->fd_wqh.lock);
+	spin_unlock(&ctx->fd_wqh.lock);
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
