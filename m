Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F126CC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 07:55:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DEA92083B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 07:55:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="tGy4dZjP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DEA92083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D4058E0006; Thu, 27 Jun 2019 03:55:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15C1E8E0002; Thu, 27 Jun 2019 03:55:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 023018E0005; Thu, 27 Jun 2019 03:55:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0CD38E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 03:55:45 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n7so878694pgr.12
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 00:55:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MpOUeEkvqBGir2f98aDkacJdBVDpZN8Lj4IqhjTaiXI=;
        b=mED6hp3gj8XMvaJqmfMvqQH56n3SAeIhwmFsfWxnG5fvYFOleZHLHgwhvNM8KmDkqn
         v0qxdh4VB0ShVF7VEI6XrTyOY/xMLj26GJlHkKKoHXIfiYeMBIxdvyr6YC0LM7jpc0Kt
         iCxetkiGxXrK9aYx9tSItsmpWOjg1BtFCetxUNz9lxZnRFII5cun8pRJXZxgAwDNYecL
         FY62grEakKGLvrPe7P+4HH6qMn4ZiHjbRlbNgv63DJBoJNw/LCAXO3fYB1Uzd+nVJYPm
         68S3+jtSe637vsU/ctxT9rzOzRAEVbhJnd5qTWbhDCbHy/a/DwsUsGxWnbTTRXjxf2h0
         QAnw==
X-Gm-Message-State: APjAAAXOHZq/FEa6O07DKDgYw5AHgOzUGoGtxnvV+ote2iW5NqPexQIW
	xvZZM9HrYSe+PIUIxTINmB34lEM+W7zsoks++gKXxnXYRjukzCbe5dX8n6Q4UuW+yGf3XEme7cK
	ZTaXnoAvv5J80fqMiO7vFzbhPeAmB1knfOS1N2UfWRVyS5eT7K8Q27AXQ6hVEu0fB1Q==
X-Received: by 2002:a17:90a:d681:: with SMTP id x1mr4299677pju.13.1561622145229;
        Thu, 27 Jun 2019 00:55:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBF5h2VfM3EFuhYWqObA2j5VgDFZ/mgEew5Od87hWT8A5zUMUYZw0n1rx4NKu/5i2/146X
X-Received: by 2002:a17:90a:d681:: with SMTP id x1mr4299612pju.13.1561622144293;
        Thu, 27 Jun 2019 00:55:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561622144; cv=none;
        d=google.com; s=arc-20160816;
        b=OgurjmdbQ057ky17Kibd14UfX1X1fw5VAt7CL4+wweHF+tPvMdDfNG7UpAZE4dfPEO
         DcaKGUa9qrHUFN02tOEIQlVtfiT6GsFCd6hvrqwwfr24w6+4B0nQQOQDYgjLY39AYgmu
         zojbaXlZPId9T2E7AndQF+INLEW7siQ1xQ6ExC5g/EbhiUJZrVL4uma+GorFKQsOGBXU
         jHpaiTN9Z3rAsMo1fY+ZN2Cg/ft8LZXsHEUsGKg/TgGVDJhNS6TlcAxxeE4HKvCwo8nj
         UyBe+Nz5Q9eYLmyqPlFM9XKXUfeMkDDtuGQXyUZzjZokghp7gBPGUujwf/e7sOp8O6qF
         /puQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MpOUeEkvqBGir2f98aDkacJdBVDpZN8Lj4IqhjTaiXI=;
        b=xPvLE7Qax6YW9tcrzOkQsYaaIXXhV/+doX90J4705E12Bz5260esIXbk/NJpDQDRGj
         bTFoPbPSvOoNMEruDxFXjBmM0mZbS+LbFp8hGVKGmOLxAJjw6x8Cbhp5IBviZivyu71y
         ihrdw6WpotQ3dl2WxXZFG1HB2UXLM6DQhKurwqnCoCWvkpA56AHAxbI3snidSomhtMYb
         /C7nfzi7+CcsYxAGyFHkuCgQ5nc1fytUVQtW5mo1yvCj8GsCftPHfbYkV/LfBvKTcFTQ
         rwedR3re7UBfeK+uXpf2PPTGlaP3Sr5tSDcE77Onb1rRkVrrH1TRBrLO5Zl8Cu0qxyCl
         8ypQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tGy4dZjP;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l70si4265709pje.68.2019.06.27.00.55.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 00:55:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tGy4dZjP;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sol.localdomain (c-24-5-143-220.hsd1.ca.comcast.net [24.5.143.220])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 25C4E20828;
	Thu, 27 Jun 2019 07:55:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561622143;
	bh=Rfx3QvLxxmERfr1nfPQEGnlDjMwAzu8Gqm3kSJPs1Qk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=tGy4dZjPdaaMYHcZN52wEdtsRUL3Q2x6njs9FHunjdLo6zZUbEAsHH/oQOHzPODk5
	 nOnioWkFfM74gBYx3WphthiXLfSld4O2v9vdc5DxmMLDzSeit9l7PvsBVDQsVkYddR
	 31F2G+rMInUGL6o6vLtAoLtGVi8025+N75KgEJJ4=
From: Eric Biggers <ebiggers@kernel.org>
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-aio@kvack.org,
	linux-fsdevel@vger.kernel.org,
	syzkaller-bugs@googlegroups.com,
	Christoph Hellwig <hch@lst.de>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] userfaultfd: disable irqs for fault_pending and event locks
Date: Thu, 27 Jun 2019 00:50:04 -0700
Message-Id: <20190627075004.21259-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190612194825.GH18795@gmail.com>
References: <20190612194825.GH18795@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Eric Biggers <ebiggers@google.com>

When IOCB_CMD_POLL is used on a userfaultfd, aio_poll() disables IRQs
and takes kioctx::ctx_lock, then userfaultfd_ctx::fd_wqh.lock.  This may
have to wait for userfaultfd_ctx::fd_wqh.lock to be released by
userfaultfd_ctx_read(), which can be waiting for
userfaultfd_ctx::fault_pending_wqh.lock or
userfaultfd_ctx::event_wqh.lock.  But elsewhere the fault_pending_wqh
and event_wqh locks are taken with IRQs enabled.  Since the IRQ handler
may take kioctx::ctx_lock, lockdep reports that a deadlock is possible.

Fix it by always disabling IRQs when taking the fault_pending_wqh and
event_wqh locks.

Commit ae62c16e105a ("userfaultfd: disable irqs when taking the
waitqueue lock") didn't fix this because it only accounted for the
fd_wqh lock, not the other locks nested inside it.

Reported-by: syzbot+fab6de82892b6b9c6191@syzkaller.appspotmail.com
Reported-by: syzbot+53c0b767f7ca0dc0c451@syzkaller.appspotmail.com
Reported-by: syzbot+a3accb352f9c22041cfa@syzkaller.appspotmail.com
Fixes: bfe4037e722e ("aio: implement IOCB_CMD_POLL")
Cc: <stable@vger.kernel.org> # v4.19+
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/userfaultfd.c | 42 ++++++++++++++++++++++++++----------------
 1 file changed, 26 insertions(+), 16 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index ae0b8b5f69e6..ccbdbd62f0d8 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -40,6 +40,16 @@ enum userfaultfd_state {
 /*
  * Start with fault_pending_wqh and fault_wqh so they're more likely
  * to be in the same cacheline.
+ *
+ * Locking order:
+ *	fd_wqh.lock
+ *		fault_pending_wqh.lock
+ *			fault_wqh.lock
+ *		event_wqh.lock
+ *
+ * To avoid deadlocks, IRQs must be disabled when taking any of the above locks,
+ * since fd_wqh.lock is taken by aio_poll() while it's holding a lock that's
+ * also taken in IRQ context.
  */
 struct userfaultfd_ctx {
 	/* waitqueue head for the pending (i.e. not read) userfaults */
@@ -458,7 +468,7 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	blocking_state = return_to_userland ? TASK_INTERRUPTIBLE :
 			 TASK_KILLABLE;
 
-	spin_lock(&ctx->fault_pending_wqh.lock);
+	spin_lock_irq(&ctx->fault_pending_wqh.lock);
 	/*
 	 * After the __add_wait_queue the uwq is visible to userland
 	 * through poll/read().
@@ -470,7 +480,7 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	 * __add_wait_queue.
 	 */
 	set_current_state(blocking_state);
-	spin_unlock(&ctx->fault_pending_wqh.lock);
+	spin_unlock_irq(&ctx->fault_pending_wqh.lock);
 
 	if (!is_vm_hugetlb_page(vmf->vma))
 		must_wait = userfaultfd_must_wait(ctx, vmf->address, vmf->flags,
@@ -552,13 +562,13 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	 * kernel stack can be released after the list_del_init.
 	 */
 	if (!list_empty_careful(&uwq.wq.entry)) {
-		spin_lock(&ctx->fault_pending_wqh.lock);
+		spin_lock_irq(&ctx->fault_pending_wqh.lock);
 		/*
 		 * No need of list_del_init(), the uwq on the stack
 		 * will be freed shortly anyway.
 		 */
 		list_del(&uwq.wq.entry);
-		spin_unlock(&ctx->fault_pending_wqh.lock);
+		spin_unlock_irq(&ctx->fault_pending_wqh.lock);
 	}
 
 	/*
@@ -583,7 +593,7 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 	init_waitqueue_entry(&ewq->wq, current);
 	release_new_ctx = NULL;
 
-	spin_lock(&ctx->event_wqh.lock);
+	spin_lock_irq(&ctx->event_wqh.lock);
 	/*
 	 * After the __add_wait_queue the uwq is visible to userland
 	 * through poll/read().
@@ -613,15 +623,15 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 			break;
 		}
 
-		spin_unlock(&ctx->event_wqh.lock);
+		spin_unlock_irq(&ctx->event_wqh.lock);
 
 		wake_up_poll(&ctx->fd_wqh, EPOLLIN);
 		schedule();
 
-		spin_lock(&ctx->event_wqh.lock);
+		spin_lock_irq(&ctx->event_wqh.lock);
 	}
 	__set_current_state(TASK_RUNNING);
-	spin_unlock(&ctx->event_wqh.lock);
+	spin_unlock_irq(&ctx->event_wqh.lock);
 
 	if (release_new_ctx) {
 		struct vm_area_struct *vma;
@@ -918,10 +928,10 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * the last page faults that may have been already waiting on
 	 * the fault_*wqh.
 	 */
-	spin_lock(&ctx->fault_pending_wqh.lock);
+	spin_lock_irq(&ctx->fault_pending_wqh.lock);
 	__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &range);
 	__wake_up(&ctx->fault_wqh, TASK_NORMAL, 1, &range);
-	spin_unlock(&ctx->fault_pending_wqh.lock);
+	spin_unlock_irq(&ctx->fault_pending_wqh.lock);
 
 	/* Flush pending events that may still wait on event_wqh */
 	wake_up_all(&ctx->event_wqh);
@@ -1134,7 +1144,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 
 	if (!ret && msg->event == UFFD_EVENT_FORK) {
 		ret = resolve_userfault_fork(ctx, fork_nctx, msg);
-		spin_lock(&ctx->event_wqh.lock);
+		spin_lock_irq(&ctx->event_wqh.lock);
 		if (!list_empty(&fork_event)) {
 			/*
 			 * The fork thread didn't abort, so we can
@@ -1180,7 +1190,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			if (ret)
 				userfaultfd_ctx_put(fork_nctx);
 		}
-		spin_unlock(&ctx->event_wqh.lock);
+		spin_unlock_irq(&ctx->event_wqh.lock);
 	}
 
 	return ret;
@@ -1219,14 +1229,14 @@ static ssize_t userfaultfd_read(struct file *file, char __user *buf,
 static void __wake_userfault(struct userfaultfd_ctx *ctx,
 			     struct userfaultfd_wake_range *range)
 {
-	spin_lock(&ctx->fault_pending_wqh.lock);
+	spin_lock_irq(&ctx->fault_pending_wqh.lock);
 	/* wake all in the range and autoremove */
 	if (waitqueue_active(&ctx->fault_pending_wqh))
 		__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL,
 				     range);
 	if (waitqueue_active(&ctx->fault_wqh))
 		__wake_up(&ctx->fault_wqh, TASK_NORMAL, 1, range);
-	spin_unlock(&ctx->fault_pending_wqh.lock);
+	spin_unlock_irq(&ctx->fault_pending_wqh.lock);
 }
 
 static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
@@ -1881,7 +1891,7 @@ static void userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
 	wait_queue_entry_t *wq;
 	unsigned long pending = 0, total = 0;
 
-	spin_lock(&ctx->fault_pending_wqh.lock);
+	spin_lock_irq(&ctx->fault_pending_wqh.lock);
 	list_for_each_entry(wq, &ctx->fault_pending_wqh.head, entry) {
 		pending++;
 		total++;
@@ -1889,7 +1899,7 @@ static void userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
 	list_for_each_entry(wq, &ctx->fault_wqh.head, entry) {
 		total++;
 	}
-	spin_unlock(&ctx->fault_pending_wqh.lock);
+	spin_unlock_irq(&ctx->fault_pending_wqh.lock);
 
 	/*
 	 * If more protocols will be added, there will be all shown
-- 
2.22.0

