Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B68F76B02FD
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:27:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c184so17720607wmd.6
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 23:27:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b58si15317246wra.454.2017.07.26.23.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 23:27:09 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6R6O3nH080150
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:27:08 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2by364t79a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:27:07 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 07:27:06 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd_zeropage: return -ENOSPC in case mm has gone
Date: Thu, 27 Jul 2017 09:26:59 +0300
Message-Id: <1501136819-21857-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, stable@vger.kernel.org

In the non-cooperative userfaultfd case, the process exit may race with
outstanding mcopy_atomic called by the uffd monitor.  Returning -ENOSPC
instead of -EINVAL when mm is already gone will allow uffd monitor to
distinguish this case from other error conditions.


Cc: stable@vger.kernel.org
Fixes: 96333187ab162 ("userfaultfd_copy: return -ENOSPC in case mm has gone")

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---

Unfortunately, I've overlooked userfaultfd_zeropage when I updated
userfaultd_copy :(

 fs/userfaultfd.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index cadcd12a3d35..2d8c2d848668 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1643,6 +1643,8 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
 		ret = mfill_zeropage(ctx->mm, uffdio_zeropage.range.start,
 				     uffdio_zeropage.range.len);
 		mmput(ctx->mm);
+	} else {
+		return -ENOSPC;
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
