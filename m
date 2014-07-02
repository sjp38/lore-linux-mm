Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 671EA6B003A
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 12:51:35 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id u57so11352188wes.5
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 09:51:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e4si20617902wij.16.2014.07.02.09.51.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 09:51:34 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 09/10] userfaultfd: make userfaultfd_write non blocking
Date: Wed,  2 Jul 2014 18:50:15 +0200
Message-Id: <1404319816-30229-10-git-send-email-aarcange@redhat.com>
In-Reply-To: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
References: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Paolo Bonzini <pbonzini@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>, Mel Gorman <mgorman@suse.de>

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
index 4902fa3..deed8cb 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -378,9 +378,7 @@ static ssize_t userfaultfd_write(struct file *file, const char __user *buf,
 				 size_t count, loff_t *ppos)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
-	ssize_t res;
 	__u64 range[2];
-	DECLARE_WAITQUEUE(wait, current);
 
 	if (ctx->state == USERFAULTFD_STATE_ASK_PROTOCOL) {
 		__u64 protocol;
@@ -408,34 +406,12 @@ static ssize_t userfaultfd_write(struct file *file, const char __user *buf,
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
