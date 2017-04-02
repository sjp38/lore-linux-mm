Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF4936B0038
	for <linux-mm@kvack.org>; Sun,  2 Apr 2017 09:36:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l43so20650716wre.4
        for <linux-mm@kvack.org>; Sun, 02 Apr 2017 06:36:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h34si16035922wrh.233.2017.04.02.06.36.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Apr 2017 06:36:31 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v32DXXjm071582
	for <linux-mm@kvack.org>; Sun, 2 Apr 2017 09:36:29 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29jyf0nepw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 02 Apr 2017 09:36:29 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 2 Apr 2017 14:36:27 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH for 4.11] userfaultfd: report actual registered features in fdinfo
Date: Sun,  2 Apr 2017 16:36:21 +0300
Message-Id: <1491140181-22121-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

fdinfo for userfault file descriptor reports UFFD_API_FEATURES. Up until
recently, the UFFD_API_FEATURES was defined as 0, therefore corresponding
field in fdinfo always contained zero. Now, with introduction of several
additional features, UFFD_API_FEATURES is not longer 0 and it seems better
to report actual features requested for the userfaultfd object described by
the fdinfo. First, the applications that were using userfault will still
see zero at the features field in fdinfo. Next, reporting actual features
rather than available features, gives clear indication of what userfault
features are used by an application.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1d227b0..f7555fc 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1756,7 +1756,7 @@ static void userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
 	 *	protocols: aa:... bb:...
 	 */
 	seq_printf(m, "pending:\t%lu\ntotal:\t%lu\nAPI:\t%Lx:%x:%Lx\n",
-		   pending, total, UFFD_API, UFFD_API_FEATURES,
+		   pending, total, UFFD_API, ctx->features,
 		   UFFD_API_IOCTLS|UFFD_API_RANGE_IOCTLS);
 }
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
