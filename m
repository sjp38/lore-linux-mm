Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 102616B0266
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:23:00 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so48817896pfx.1
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:23:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h7si2863284plk.119.2017.01.19.00.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 00:22:59 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0J8E5Y1082950
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:22:58 -0500
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0a-001b2d01.pphosted.com with ESMTP id 282pchpwe6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:22:58 -0500
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 19 Jan 2017 08:22:56 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/3] userfaultfd: non-cooperative: add madvise() event for MADV_REMOVE request
Date: Thu, 19 Jan 2017 10:22:33 +0200
In-Reply-To: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1484814154-1557-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

When a page is removed from a shared mapping, the uffd reader should be
notified, so that it won't attempt to handle #PF events for the removed
pages.
We can reuse the UFFD_EVENT_REMOVE because from the uffd monitor point
of view, the semantices of madvise(MADV_DONTNEED) and madvise(MADV_REMOVE)
is exactly the same.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/madvise.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/madvise.c b/mm/madvise.c
index ab5ef14..0012071 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -520,6 +520,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 	 * mmap_sem.
 	 */
 	get_file(f);
+	userfaultfd_remove(vma, prev, start, end);
 	up_read(&current->mm->mmap_sem);
 	error = vfs_fallocate(f,
 				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
