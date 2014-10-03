Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 70FAA6B0075
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 13:08:50 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id e89so1233574qgf.32
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 10:08:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 20si13246186qgm.102.2014.10.03.10.08.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 10:08:45 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 15/17] userfaultfd: make userfaultfd_write non blocking
Date: Fri,  3 Oct 2014 19:08:05 +0200
Message-Id: <1412356087-16115-16-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

It is generally inefficient to ask the wakeup of userfault ranges
where there's not a single userfault address read through
userfaultfd_read earlier and in turn waiting a wakeup. However it may
come handy to wakeup the same userfault range twice in case of
multiple thread faulting on the same address. But we should still
return an error so if the application thinks this occurrence can never
happen it will know it hit a bug. So just return -ENOENT instead of
blocking.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 34 +++++-----------------------------
 1 file changed, 5 insertions(+), 29 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 62b827e..2667d0d 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -458,9 +458,7 @@ static ssize_t userfaultfd_write(struct file *file, const char __user *buf,
 				 size_t count, loff_t *ppos)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
-	ssize_t res;
 	__u64 range[2];
-	DECLARE_WAITQUEUE(wait, current);
 
 	if (ctx->state == USERFAULTFD_STATE_ASK_PROTOCOL) {
 		__u64 protocol;
@@ -488,34 +486,12 @@ static ssize_t userfaultfd_write(struct file *file, const char __user *buf,
 	if (range[0] >= range[1])
 		return -ERANGE;
 
-	spin_lock(&ctx->fd_wqh.lock);
-	__add_wait_queue(&ctx->fd_wqh, &wait);
-	for (;;) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		/* always take the fd_wqh lock before the fault_wqh lock */
-		if (find_userfault(ctx, NULL, POLLOUT)) {
-			if (!wake_userfault(ctx, range)) {
-				res = sizeof(range);
-				break;
-			}
-		}
-		if (signal_pending(current)) {
-			res = -ERESTARTSYS;
-			break;
-		}
-		if (file->f_flags & O_NONBLOCK) {
-			res = -EAGAIN;
-			break;
-		}
-		spin_unlock(&ctx->fd_wqh.lock);
-		schedule();
-		spin_lock(&ctx->fd_wqh.lock);
-	}
-	__remove_wait_queue(&ctx->fd_wqh, &wait);
-	__set_current_state(TASK_RUNNING);
-	spin_unlock(&ctx->fd_wqh.lock);
+	/* always take the fd_wqh lock before the fault_wqh lock */
+	if (find_userfault(ctx, NULL, POLLOUT))
+		if (!wake_userfault(ctx, range))
+			return sizeof(range);
 
-	return res;
+	return -ENOENT;
 }
 
 #ifdef CONFIG_PROC_FS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
