Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D51A6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 09:12:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l3so519183wrc.12
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 06:12:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l38si8829994wrc.193.2017.08.07.06.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 06:12:40 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v77DAYRl073251
	for <linux-mm@kvack.org>; Mon, 7 Aug 2017 09:12:38 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c6jehrpsq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Aug 2017 09:12:38 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 7 Aug 2017 14:12:36 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd: replace ENOSPC with ESRCH in case mm has gone during copy/zeropage
Date: Mon,  7 Aug 2017 16:12:25 +0300
Message-Id: <1502111545-32305-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Mike Kravetz <mike.kravetz@oracle.com>

When the process exit races with outstanding mcopy_atomic, it would be
better to return ESRCH error. When such race occurs the process and it's mm
are going away and returning "no such process" to the uffd monitor seems
better fit than ENOSPC.

Suggested-by: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
The man-pages update is ready and I'll send it out once the patch is
merged.

 fs/userfaultfd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 06ea26b8c996..b0d5897bc4e6 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1600,7 +1600,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
 				   uffdio_copy.len);
 		mmput(ctx->mm);
 	} else {
-		return -ENOSPC;
+		return -ESRCH;
 	}
 	if (unlikely(put_user(ret, &user_uffdio_copy->copy)))
 		return -EFAULT;
@@ -1647,7 +1647,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 				     uffdio_zeropage.range.len);
 		mmput(ctx->mm);
 	} else {
-		return -ENOSPC;
+		return -ESRCH;
 	}
 	if (unlikely(put_user(ret, &user_uffdio_zeropage->zeropage)))
 		return -EFAULT;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
