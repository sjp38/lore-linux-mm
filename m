Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A78DA6B0253
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:42:37 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id r129so19698180wmr.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 05:42:37 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id 17si2491602wjv.159.2016.03.20.05.42.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 20 Mar 2016 05:42:36 -0700 (PDT)
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rapoport@il.ibm.com>;
	Sun, 20 Mar 2016 12:42:36 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9333F1B0804B
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:43:04 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2KCgXlU56688700
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:42:33 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2KCgX7L017034
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 08:42:33 -0400
From: Mike Rapoport <rapoport@il.ibm.com>
Subject: [PATCH 1/5] uffd: Split the find_userfault() routine
Date: Sun, 20 Mar 2016 14:42:17 +0200
Message-Id: <1458477741-6942-2-git-send-email-rapoport@il.ibm.com>
In-Reply-To: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
References: <1458477741-6942-1-git-send-email-rapoport@il.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>, Mike Rapoport <rapoport@il.ibm.com>

From: Pavel Emelyanov <xemul@parallels.com>

I will need one to lookup for userfaultfd_wait_queue-s in different
wait queue

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Mike Rapoport <rapoport@il.ibm.com>
---
 fs/userfaultfd.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 66cdb44..4f0b53d 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -483,25 +483,30 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
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
 }
 
+static inline struct userfaultfd_wait_queue *find_userfault(
+		struct userfaultfd_ctx *ctx)
+{
+	return find_userfault_in(&ctx->fault_pending_wqh);
+}
+
 static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
