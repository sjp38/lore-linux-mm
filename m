Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9C1F6B026C
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:23:02 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id l23so44638629ybj.6
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:23:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m4si812760ywm.296.2017.01.19.00.23.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 00:23:01 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0J8E4EQ032844
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:23:01 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 282kphvjm0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:23:01 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 19 Jan 2017 08:22:59 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/3] userfaultfd: non-cooperative: selftest: enable REMOVE event test for shmem
Date: Thu, 19 Jan 2017 10:22:34 +0200
In-Reply-To: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1484814154-1557-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Now when madvise(MADV_REMOVE) notifies uffd reader, we should verify that
appliciation actually sees zeros at the removed range.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 tools/testing/selftests/vm/userfaultfd.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/tools/testing/selftests/vm/userfaultfd.c b/tools/testing/selftests/vm/userfaultfd.c
index 9eb77df..e9449c8 100644
--- a/tools/testing/selftests/vm/userfaultfd.c
+++ b/tools/testing/selftests/vm/userfaultfd.c
@@ -569,9 +569,9 @@ static int userfaultfd_open(int features)
  * part is accessed after mremap. Since hugetlbfs does not support
  * mremap, the entire monitored area is accessed in a single pass for
  * HUGETLB_TEST.
- * The release of the pages currently generates event only for
+ * The release of the pages currently generates event for shmem and
  * anonymous memory (UFFD_EVENT_REMOVE), hence it is not checked
- * for hugetlb and shmem.
+ * for hugetlb.
  */
 static int faulting_process(void)
 {
@@ -610,7 +610,6 @@ static int faulting_process(void)
 		}
 	}
 
-#ifndef SHMEM_TEST
 	if (release_pages(area_dst))
 		return 1;
 
@@ -618,7 +617,6 @@ static int faulting_process(void)
 		if (my_bcmp(area_dst + nr * page_size, zeropage, page_size))
 			fprintf(stderr, "nr %lu is not zero\n", nr), exit(1);
 	}
-#endif /* SHMEM_TEST */
 
 #endif /* HUGETLB_TEST */
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
