Received: from smtp3.akamai.com (vwall3.sanmateo.corp.akamai.com [172.23.1.73])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j2G9M66O018503
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 01:22:07 -0800 (PST)
From: pmeda@akamai.com
Date: Wed, 16 Mar 2005 01:31:02 -0800
Message-Id: <200503160931.BAA20204@allur.sanmateo.akamai.com>
Subject: [PATCH 1/2] madvise: do not split the maps
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This attempts to avoid splittings when it is not
needed, that is when vm_flags are same as new flags.
The idea is from the <2.6.11 mlock_fixup and others.
This will provide base for the next madvise merging
patch.

Signed-off-by: Prasanna Meda <pmeda@akamai.com>

--- linux/mm/madvise.c	Mon Mar 14 23:46:16 2005
+++ Linux/mm/madvise.c	Wed Mar 16 06:17:58 2005
@@ -19,6 +19,21 @@
 {
 	struct mm_struct * mm = vma->vm_mm;
 	int error = 0;
+	int new_flags = vma->vm_flags & ~VM_READHINTMASK;
+
+	switch (behavior) {
+	case MADV_SEQUENTIAL:
+		new_flags |= VM_SEQ_READ;
+		break;
+	case MADV_RANDOM:
+		new_flags |= VM_RAND_READ;
+		break;
+	default:
+		break;
+	}
+
+	if (new_flags == vma->vm_flags)
+		goto out;
 
 	if (start != vma->vm_start) {
 		error = split_vma(mm, vma, start, 1);
@@ -36,17 +51,7 @@
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
 	VM_ClearReadHint(vma);
-
-	switch (behavior) {
-	case MADV_SEQUENTIAL:
-		vma->vm_flags |= VM_SEQ_READ;
-		break;
-	case MADV_RANDOM:
-		vma->vm_flags |= VM_RAND_READ;
-		break;
-	default:
-		break;
-	}
+	vma->vm_flags = new_flags;
 
 out:
 	if (error == -ENOMEM)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
