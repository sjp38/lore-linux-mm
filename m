Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 235266B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 03:34:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 184so3439149wmo.7
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 00:34:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g145si8813368wmg.198.2017.07.17.00.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 00:34:46 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6H7Xmiw088205
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 03:34:45 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2brpbsnx2u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 03:34:45 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 17 Jul 2017 08:34:44 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2] userfaultfd: non-cooperative: notify about unmap of destination during mremap
Date: Mon, 17 Jul 2017 10:34:36 +0300
Message-Id: <1500276876-3350-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, stable@vger.kernel.org

When mremap is called with MREMAP_FIXED it unmaps memory at the destination
address without notifying userfaultfd monitor. If the destination were
registered with userfaultfd, the monitor has no way to distinguish between
the old and new ranges and to properly relate the page faults that would
occur in the destination region.

Cc: stable@vger.kernel.org
Fixes: 897ab3e0c49e ("userfaultfd: non-cooperative: add event for memory
unmaps")

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---

v2: make sure userfault callbacks are called with mmap_sem released
 
 mm/mremap.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index cd8a1b199ef9..8d6fc5f104d1 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -428,6 +428,7 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 		unsigned long new_addr, unsigned long new_len, bool *locked,
 		struct vm_userfaultfd_ctx *uf,
+		struct list_head *uf_unmap_early,
 		struct list_head *uf_unmap)
 {
 	struct mm_struct *mm = current->mm;
@@ -446,7 +447,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (addr + old_len > new_addr && new_addr + new_len > addr)
 		goto out;
 
-	ret = do_munmap(mm, new_addr, new_len, NULL);
+	ret = do_munmap(mm, new_addr, new_len, uf_unmap_early);
 	if (ret)
 		goto out;
 
@@ -514,6 +515,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	unsigned long charged = 0;
 	bool locked = false;
 	struct vm_userfaultfd_ctx uf = NULL_VM_UFFD_CTX;
+	LIST_HEAD(uf_unmap_early);
 	LIST_HEAD(uf_unmap);
 
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
@@ -541,7 +543,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 	if (flags & MREMAP_FIXED) {
 		ret = mremap_to(addr, old_len, new_addr, new_len,
-				&locked, &uf, &uf_unmap);
+				&locked, &uf, &uf_unmap_early, &uf_unmap);
 		goto out;
 	}
 
@@ -621,6 +623,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	up_write(&current->mm->mmap_sem);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
+	userfaultfd_unmap_complete(mm, &uf_unmap_early);
 	mremap_userfaultfd_complete(&uf, addr, new_addr, old_len);
 	userfaultfd_unmap_complete(mm, &uf_unmap);
 	return ret;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
