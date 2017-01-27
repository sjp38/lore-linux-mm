Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D36B6B0266
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:45:14 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so360778299pfx.1
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 10:45:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l87si5172696pfi.169.2017.01.27.10.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 10:45:13 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0RIdHl6109650
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:45:13 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2884kb15t0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:45:13 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 27 Jan 2017 18:45:10 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 5/5] userfaultfd_copy: return -ENOSPC in case mm has gone
Date: Fri, 27 Jan 2017 20:44:33 +0200
In-Reply-To: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1485542673-24387-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

In the non-cooperative userfaultfd case, the process exit may race with
outstanding mcopy_atomic called by the uffd monitor. Returning -ENOSPC
instead of -EINVAL when mm is already gone will allow uffd monitor to
distinguish this case from other error conditions.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 fs/userfaultfd.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 839ffd5..6587f40 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1603,6 +1603,8 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 		ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
 				   uffdio_copy.len);
 		mmput(ctx->mm);
+	} else {
+		return -ENOSPC;
 	}
 	if (unlikely(put_user(ret, &user_uffdio_copy->copy)))
 		return -EFAULT;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
