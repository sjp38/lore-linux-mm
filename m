Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA6MRqq7027645
	for <linux-mm@kvack.org>; Tue, 6 Nov 2007 17:27:52 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA6MRp75483974
	for <linux-mm@kvack.org>; Tue, 6 Nov 2007 17:27:52 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA6MRpsY007207
	for <linux-mm@kvack.org>; Tue, 6 Nov 2007 17:27:51 -0500
Subject: [PATCH] Use VM_ flags in protection_map rather than magic value
From: Matt Helsley <matthltc@us.ibm.com>
Content-Type: text/plain
Date: Tue, 06 Nov 2007 14:11:09 -0800
Message-Id: <1194387069.18598.92.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Trivial <trivial@kernel.org>
List-ID: <linux-mm.kvack.org>

Replace the magic value with a mask of flags that produce the same
value. This is consistent with the other uses of protection_map[].

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
---
 mm/mmap.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.23/mm/mmap.c
===================================================================
--- linux-2.6.23.orig/mm/mmap.c
+++ linux-2.6.23/mm/mmap.c
@@ -2245,11 +2245,12 @@ int install_special_mapping(struct mm_st
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
 
 	vma->vm_flags = vm_flags | mm->def_flags;
-	vma->vm_page_prot = protection_map[vma->vm_flags & 7];
+	vma->vm_page_prot = protection_map[vma->vm_flags &
+						(VM_READ|VM_WRITE|VM_EXEC)];
 
 	vma->vm_ops = &special_mapping_vmops;
 	vma->vm_private_data = pages;
 
 	if (unlikely(insert_vm_struct(mm, vma))) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
