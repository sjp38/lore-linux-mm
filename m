Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 34F316B026A
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:27 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id n68so21034991itn.4
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k21si2946577iti.65.2016.12.16.06.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:26 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 05/42] userfaultfd: non-cooperative: Split the find_userfault() routine
Date: Fri, 16 Dec 2016 15:47:44 +0100
Message-Id: <20161216144821.5183-6-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Pavel Emelyanov <xemul@parallels.com>

I will need one to lookup for userfaultfd_wait_queue-s in different
wait queue

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 0f998d1..8dc95ac 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -489,25 +489,30 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
