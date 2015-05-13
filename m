Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 12B5B6B006C
	for <linux-mm@kvack.org>; Wed, 13 May 2015 10:52:46 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so54013837pdb.1
        for <linux-mm@kvack.org>; Wed, 13 May 2015 07:52:45 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ha1si27337812pbd.249.2015.05.13.07.52.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 07:52:44 -0700 (PDT)
Message-ID: <55536534.5080605@parallels.com>
Date: Wed, 13 May 2015 17:52:36 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 1/5] uffd: Split the find_userfault() routine
References: <5553651B.1020909@parallels.com>
In-Reply-To: <5553651B.1020909@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>

I will need one to lookup for userfaultfd_wait_queue-s in different
wait queue.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 fs/userfaultfd.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index c89e96f..c593a72 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -433,23 +433,29 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 }
 
 /* fault_pending_wqh.lock must be hold by the caller */
-static inline struct userfaultfd_wait_queue *find_userfault(
-	struct userfaultfd_ctx *ctx)
+static inline struct userfaultfd_wait_queue *find_userfault_in(
+		wait_queue_head_t *wqh)
 {
 	wait_queue_t *wq;
 	struct userfaultfd_wait_queue *uwq;
 
-	VM_BUG_ON(!spin_is_locked(&ctx->fault_pending_wqh.lock));
+	VM_BUG_ON(!spin_is_locked(&wqh->lock));
 
 	uwq = NULL;
-	if (!waitqueue_active(&ctx->fault_pending_wqh))
+	if (!waitqueue_active(wqh))
 		goto out;
 	/* walk in reverse to provide FIFO behavior to read userfaults */
-	wq = list_last_entry(&ctx->fault_pending_wqh.task_list,
-			     typeof(*wq), task_list);
+	wq = list_last_entry(&wqh->task_list, typeof(*wq), task_list);
 	uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
 out:
 	return uwq;
+
+}
+
+static inline struct userfaultfd_wait_queue *find_userfault(
+		struct userfaultfd_ctx *ctx)
+{
+	return find_userfault_in(&ctx->fault_pending_wqh);
 }
 
 static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
