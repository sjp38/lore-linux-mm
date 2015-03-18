Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id F0E066B006C
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 15:34:59 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so51368179pad.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:34:59 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id xz4si37916809pac.62.2015.03.18.12.34.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 12:34:59 -0700 (PDT)
Message-ID: <5509D35A.1080206@parallels.com>
Date: Wed, 18 Mar 2015 22:34:50 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] uffd: Tossing bits around
References: <5509D342.7000403@parallels.com>
In-Reply-To: <5509D342.7000403@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>
Cc: Sanidhya Kashyap <sanidhya.gatech@gmail.com>

Reformat the existing code a bit to make it easier for
further patching.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 fs/userfaultfd.c | 37 ++++++++++++++++++++++++++++---------
 1 file changed, 28 insertions(+), 9 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index b4c7f25..6c9a2d6 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -61,6 +61,23 @@ struct userfaultfd_wake_range {
 	unsigned long len;
 };
 
+static const struct file_operations userfaultfd_fops;
+
+static struct userfaultfd_ctx *userfaultfd_ctx_alloc(void)
+{
+	struct userfaultfd_ctx *ctx;
+
+	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
+	if (ctx) {
+		atomic_set(&ctx->refcount, 1);
+		init_waitqueue_head(&ctx->fault_wqh);
+		init_waitqueue_head(&ctx->fd_wqh);
+		ctx->released = false;
+	}
+
+	return ctx;
+}
+
 static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
 				     int wake_flags, void *key)
 {
@@ -307,15 +324,15 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static inline unsigned int find_userfault(struct userfaultfd_ctx *ctx,
+static inline unsigned int do_find_userfault(wait_queue_head_t *wqh,
 					  struct userfaultfd_wait_queue **uwq)
 {
 	wait_queue_t *wq;
 	struct userfaultfd_wait_queue *_uwq;
 	unsigned int ret = 0;
 
-	spin_lock(&ctx->fault_wqh.lock);
-	list_for_each_entry(wq, &ctx->fault_wqh.task_list, task_list) {
+	spin_lock(&wqh->lock);
+	list_for_each_entry(wq, &wqh->task_list, task_list) {
 		_uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
 		if (_uwq->pending) {
 			ret = POLLIN;
@@ -324,11 +341,17 @@ static inline unsigned int find_userfault(struct userfaultfd_ctx *ctx,
 			break;
 		}
 	}
-	spin_unlock(&ctx->fault_wqh.lock);
+	spin_unlock(&wqh->lock);
 
 	return ret;
 }
 
+static inline unsigned int find_userfault(struct userfaultfd_ctx *ctx,
+		struct userfaultfd_wait_queue **uwq)
+{
+	return do_find_userfault(&ctx->fault_wqh, uwq);
+}
+
 static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
@@ -1080,16 +1103,12 @@ static struct file *userfaultfd_file_create(int flags)
 		goto out;
 
 	file = ERR_PTR(-ENOMEM);
-	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
+	ctx = userfaultfd_ctx_alloc();
 	if (!ctx)
 		goto out;
 
-	atomic_set(&ctx->refcount, 1);
-	init_waitqueue_head(&ctx->fault_wqh);
-	init_waitqueue_head(&ctx->fd_wqh);
 	ctx->flags = flags;
 	ctx->state = UFFD_STATE_WAIT_API;
-	ctx->released = false;
 	ctx->mm = current->mm;
 	/* prevent the mm struct to be freed */
 	atomic_inc(&ctx->mm->mm_count);
-- 
1.8.4.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
