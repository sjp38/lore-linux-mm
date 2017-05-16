Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 73A386B03A5
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p74so122067687pfd.11
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:36:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d2si13576147pgf.380.2017.05.16.03.36.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 03:36:15 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4GAaAjc043540
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:15 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afwhj71px-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:36:14 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 16 May 2017 11:36:12 +0100
From: "Mike Rapoport" <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 2/5] userfaultfd: introduce userfaultfd_should_wait helper
Date: Tue, 16 May 2017 13:35:59 +0300
In-Reply-To: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1494930962-3318-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index b061e96..fee5f08 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -91,21 +91,31 @@ struct userfaultfd_wake_range {
 	unsigned long len;
 };
 
+static bool userfaultfd_should_wake(struct userfaultfd_wait_queue *uwq,
+				    struct userfaultfd_wake_range *range)
+{
+	unsigned long start, len, address;
+
+	/* len == 0 means wake all */
+	address = uwq->msg.arg.pagefault.address;
+	start = range->start;
+	len = range->len;
+	if (len && (start > address || start + len <= address))
+		return false;
+
+	return true;
+}
+
 static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
 				     int wake_flags, void *key)
 {
 	struct userfaultfd_wake_range *range = key;
 	int ret;
 	struct userfaultfd_wait_queue *uwq;
-	unsigned long start, len;
 
 	uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
 	ret = 0;
-	/* len == 0 means wake all */
-	start = range->start;
-	len = range->len;
-	if (len && (start > uwq->msg.arg.pagefault.address ||
-		    start + len <= uwq->msg.arg.pagefault.address))
+	if (!userfaultfd_should_wake(uwq, range))
 		goto out;
 	WRITE_ONCE(uwq->waken, true);
 	/*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
