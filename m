Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 07A586B0255
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 10:35:21 -0500 (EST)
Received: by iofh3 with SMTP id h3so36862511iof.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 07:35:20 -0800 (PST)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id w6si11925317igp.20.2015.11.11.07.35.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 07:35:20 -0800 (PST)
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <jjherne@linux.vnet.ibm.com>;
	Wed, 11 Nov 2015 10:35:19 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C654638C8046
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 10:35:17 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tABFZH3958654774
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 15:35:17 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tABFZHMW027242
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 10:35:17 -0500
From: "Jason J. Herne" <jjherne@linux.vnet.ibm.com>
Subject: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on s390
Date: Wed, 11 Nov 2015 10:35:16 -0500
Message-Id: <1447256116-16461-1-git-send-email-jjherne@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-s390@vger.kernel.org
Cc: linux-mm@kvack.org, aarcange@redhat.com, borntraeger@de.ibm.com, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>

MADV_NOHUGEPAGE processing is too restrictive. kvm already disables
hugepage but hugepage_madvise() takes the error path when we ask to turn
on the MADV_NOHUGEPAGE bit and the bit is already on. This causes Qemu's
new postcopy migration feature to fail on s390 because its first action is
to madvise the guest address space as NOHUGEPAGE. This patch modifies the
code so that the operation succeeds without error now.

Signed-off-by: Jason J. Herne <jjherne@linux.vnet.ibm.com>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c29ddeb..a8b5347 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
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
