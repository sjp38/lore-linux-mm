Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id BF3EA900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 10:44:38 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id y13so830627pdi.6
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 07:44:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id pg8si1546384pbb.73.2014.10.28.07.44.37
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 07:44:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: do not mark zero-page pmd write-protected explicitly
Date: Tue, 28 Oct 2014 16:44:32 +0200
Message-Id: <1414507472-115086-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Zero pages can be used only in anonymous mappings, which never have
writable vma->vm_page_prot: see protection_map in mm/mmap.c and __PX1X
definitions.

Let's drop redundant pmd_wrprotect() in set_huge_zero_page().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 74c78aa8bc2f..6939c9b4a1c7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -784,7 +784,6 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	if (!pmd_none(*pmd))
 		return false;
 	entry = mk_pmd(zero_page, vma->vm_page_prot);
-	entry = pmd_wrprotect(entry);
 	entry = pmd_mkhuge(entry);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, haddr, pmd, entry);
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
