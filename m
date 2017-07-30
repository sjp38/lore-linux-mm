Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C67276B05AB
	for <linux-mm@kvack.org>; Sun, 30 Jul 2017 03:02:18 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g28so43087335wrg.3
        for <linux-mm@kvack.org>; Sun, 30 Jul 2017 00:02:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z3si21010373wrb.434.2017.07.30.00.02.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Jul 2017 00:02:17 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6U6wlKk087688
	for <linux-mm@kvack.org>; Sun, 30 Jul 2017 03:02:16 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c0mh2v18c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 30 Jul 2017 03:02:15 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 30 Jul 2017 08:02:14 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd: non-cooperative: flush event_wqh at release time
Date: Sun, 30 Jul 2017 10:02:07 +0300
Message-Id: <1501398127-30419-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, stable@vger.kernel.org

There maybe still threads waiting on event_wqh at the time the userfault
file descriptor is closed. Flush the events wait-queue to prevent waiting
threads from hanging.

Cc: stable@vger.kernel.org
Fixes: 9cd75c3cd4c3d ("userfaultfd: non-cooperative: add ability to report
non-PF events from uffd descriptor")

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 2d8c2d848668..06ea26b8c996 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -854,6 +854,9 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	__wake_up_locked_key(&ctx->fault_wqh, TASK_NORMAL, &range);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 
+	/* Flush pending events that may still wait on event_wqh */
+	wake_up_all(&ctx->event_wqh);
+
 	wake_up_poll(&ctx->fd_wqh, POLLHUP);
 	userfaultfd_ctx_put(ctx);
 	return 0;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
