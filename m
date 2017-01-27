Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1F9D6B0069
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:45:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p192so54230339wme.1
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 10:45:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u108si6878777wrc.135.2017.01.27.10.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 10:44:59 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0RIchXt089995
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:44:58 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2884ka9ad3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:44:58 -0500
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 27 Jan 2017 18:44:56 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 1/5] mm: call vm_munmap in munmap syscall instead of using open coded version
Date: Fri, 27 Jan 2017 20:44:29 +0200
In-Reply-To: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1485542673-24387-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The commit dc0ef0df7b6a (mm: make mmap_sem for write waits killable for mm
syscalls) replaced call to vm_munmap in munmap syscall with open coded
version to allow different waits on mmap_sem in munmap syscall and
vm_munmap. Now both functions use down_write_killable, so we can restore
the call to vm_munmap from the munmap system call.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 mm/mmap.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index b729084..f040ea0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2680,15 +2680,8 @@ int vm_munmap(unsigned long start, size_t len)
 
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
-	int ret;
-	struct mm_struct *mm = current->mm;
-
 	profile_munmap(addr);
-	if (down_write_killable(&mm->mmap_sem))
-		return -EINTR;
-	ret = do_munmap(mm, addr, len);
-	up_write(&mm->mmap_sem);
-	return ret;
+	return vm_munmap(addr, len);
 }
 
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
