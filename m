Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E78126B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 13:29:53 -0500 (EST)
Received: from localhost.localdomain by digidescorp.com (Cipher TLSv1:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001211258.msg
	for <linux-mm@kvack.org>; Tue, 02 Mar 2010 12:29:51 -0600
From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: [PATCH] nommu: get_user_pages(): pin last page on non-page-aligned start
Date: Tue,  2 Mar 2010 12:29:44 -0600
Message-Id: <1267554584-24349-1-git-send-email-steve@digidescorp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "Steven J. Magnani" <steve@digidescorp.com>
List-ID: <linux-mm.kvack.org>

The noMMU version of get_user_pages() fails to pin the last page
when the start address isn't page-aligned. The patch fixes this in a way
that makes find_extend_vma() congruent to its MMU cousin.

Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
---
diff -uprN a/mm/nommu.c b/mm/nommu.c
--- a/mm/nommu.c	2010-03-01 16:37:31.000000000 -0600
+++ b/mm/nommu.c	2010-03-01 21:34:49.000000000 -0600
@@ -146,7 +146,7 @@ int __get_user_pages(struct task_struct 
 			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
 
 	for (i = 0; i < nr_pages; i++) {
-		vma = find_vma(mm, start);
+		vma = find_extend_vma(mm, start);
 		if (!vma)
 			goto finish_or_fault;
 
@@ -764,7 +764,7 @@ EXPORT_SYMBOL(find_vma);
  */
 struct vm_area_struct *find_extend_vma(struct mm_struct *mm, unsigned long addr)
 {
-	return find_vma(mm, addr);
+	return find_vma(mm, addr & PAGE_MASK);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
