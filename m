Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 841B76B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 10:18:45 -0500 (EST)
Received: by iofh3 with SMTP id h3so67894910iof.3
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 07:18:45 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id c75si18561509iod.73.2015.11.12.07.18.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Nov 2015 07:18:44 -0800 (PST)
Received: from localhost
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <jjherne@linux.vnet.ibm.com>;
	Thu, 12 Nov 2015 08:18:43 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id ECAA238C8054
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 10:18:40 -0500 (EST)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tACFIeYN59179124
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:18:40 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tACFH1X2007146
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 10:17:01 -0500
From: "Jason J. Herne" <jjherne@linux.vnet.ibm.com>
Subject: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on s390
Date: Thu, 12 Nov 2015 10:18:36 -0500
Message-Id: <1447341516-18076-1-git-send-email-jjherne@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-s390@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, borntraeger@de.ibm.com, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>

MADV_NOHUGEPAGE processing is too restrictive. kvm already disables
hugepage but hugepage_madvise() takes the error path when we ask to turn
on the MADV_NOHUGEPAGE bit and the bit is already on. This causes Qemu's
new postcopy migration feature to fail on s390 because its first action is
to madvise the guest address space as NOHUGEPAGE. This patch modifies the
code so that the operation succeeds without error now.

Signed-off-by: Jason J. Herne <jjherne@linux.vnet.ibm.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c29ddeb..62fe06b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2009,7 +2009,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		/*
 		 * Be somewhat over-protective like KSM for now!
 		 */
-		if (*vm_flags & (VM_HUGEPAGE | VM_NO_THP))
+		if (*vm_flags & VM_NO_THP)
 			return -EINVAL;
 		*vm_flags &= ~VM_NOHUGEPAGE;
 		*vm_flags |= VM_HUGEPAGE;
@@ -2025,7 +2025,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		/*
 		 * Be somewhat over-protective like KSM for now!
 		 */
-		if (*vm_flags & (VM_NOHUGEPAGE | VM_NO_THP))
+		if (*vm_flags & VM_NO_THP)
 			return -EINVAL;
 		*vm_flags &= ~VM_HUGEPAGE;
 		*vm_flags |= VM_NOHUGEPAGE;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
