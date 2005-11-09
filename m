Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA9Ndcoj030139
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:39:38 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA9Ndch4110260
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:39:38 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA9Ndb1k002064
	for <linux-mm@kvack.org>; Wed, 9 Nov 2005 18:39:38 -0500
Subject: [PATCH 3/4] Hugetlb: Reorganize hugetlb_fault to prepare for COW
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1131578925.28383.9.camel@localhost.localdomain>
References: <1131578925.28383.9.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 09 Nov 2005 17:38:47 -0600
Message-Id: <1131579527.28383.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>, wli@holomorphy.com, hugh@veritas.com, rohit.seth@intel.com, kenneth.w.chen@intel.com, "ADAM G. LITKE [imap]" <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch splits the "no_page()" type activity into its own function,
hugetlb_no_page().  hugetlb_fault() becomes the entry point for hugetlb faults
and delegates to the appropriate handler depending on the type of fault.  Right
now we still have only hugetlb_no_page() but a later patch introduces a COW
fault.

Original post by David Gibson <david@gibson.dropbear.id.au>

Version 2: Wed 9 Nov 2005
	Broken out into a separate patch

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
Signed-off-by: Adam Litke <agl@us.ibm.com>
---
 hugetlb.c |   34 +++++++++++++++++++++++++---------
 1 files changed, 25 insertions(+), 9 deletions(-)
diff -upN reference/mm/hugetlb.c current/mm/hugetlb.c
--- reference/mm/hugetlb.c
+++ current/mm/hugetlb.c
@@ -370,20 +370,15 @@ out:
 	return page;
 }
 
-int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, int write_access)
+int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pte_t *ptep)
 {
 	int ret = VM_FAULT_SIGBUS;
 	unsigned long idx;
 	unsigned long size;
-	pte_t *pte;
 	struct page *page;
 	struct address_space *mapping;
 
-	pte = huge_pte_alloc(mm, address);
-	if (!pte)
-		goto out;
-
 	mapping = vma->vm_file->f_mapping;
 	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
 		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
@@ -402,11 +397,11 @@ int hugetlb_fault(struct mm_struct *mm, 
 		goto backout;
 
 	ret = VM_FAULT_MINOR;
-	if (!pte_none(*pte))
+	if (!pte_none(*ptep))
 		goto backout;
 
 	add_mm_counter(mm, file_rss, HPAGE_SIZE / PAGE_SIZE);
-	set_huge_pte_at(mm, address, pte, make_huge_pte(vma, page));
+	set_huge_pte_at(mm, address, ptep, make_huge_pte(vma, page));
 	spin_unlock(&mm->page_table_lock);
 	unlock_page(page);
 out:
@@ -420,6 +415,27 @@ backout:
 	goto out;
 }
 
+int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, int write_access)
+{
+	pte_t *ptep;
+	pte_t entry;
+
+	ptep = huge_pte_alloc(mm, address);
+	if (!ptep)
+		return VM_FAULT_OOM;
+
+	entry = *ptep;
+	if (pte_none(entry))
+		return hugetlb_no_page(mm, vma, address, ptep);
+
+	/*
+	 * We could get here if another thread instantiated the pte
+	 * before the test above.
+	 */
+	return VM_FAULT_MINOR;
+}
+
 int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			struct page **pages, struct vm_area_struct **vmas,
 			unsigned long *position, int *length, int i)

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
