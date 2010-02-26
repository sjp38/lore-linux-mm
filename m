Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4866F6B008C
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:06 -0500 (EST)
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK941g028006
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:04 -0500
Message-Id: <20100226200903.521314484@redhat.com>
Date: Fri, 26 Feb 2010 21:05:02 +0100
From: aarcange@redhat.com
Subject: [patch 29/35] verify pmd_trans_huge isnt leaking
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=debug_pte_trans_huge
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

pte_trans_huge must not leak in certain vmas like the mmio special pfn or
filebacked mappings.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/memory.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1423,6 +1423,7 @@ int __get_user_pages(struct task_struct 
 			pmd = pmd_offset(pud, pg);
 			if (pmd_none(*pmd))
 				return i ? : -EFAULT;
+			VM_BUG_ON(pmd_trans_huge(*pmd));
 			pte = pte_offset_map(pmd, pg);
 			if (pte_none(*pte)) {
 				pte_unmap(pte);
@@ -1624,8 +1625,10 @@ pte_t *get_locked_pte(struct mm_struct *
 	pud_t * pud = pud_alloc(mm, pgd, addr);
 	if (pud) {
 		pmd_t * pmd = pmd_alloc(mm, pud, addr);
-		if (pmd)
+		if (pmd) {
+			VM_BUG_ON(pmd_trans_huge(*pmd));
 			return pte_alloc_map_lock(mm, pmd, addr, ptl);
+		}
 	}
 	return NULL;
 }
@@ -1844,6 +1847,7 @@ static inline int remap_pmd_range(struct
 	pmd = pmd_alloc(mm, pud, addr);
 	if (!pmd)
 		return -ENOMEM;
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	do {
 		next = pmd_addr_end(addr, end);
 		if (remap_pte_range(mm, pmd, addr, next,
@@ -3319,6 +3323,7 @@ static int follow_pte(struct mm_struct *
 		goto out;
 
 	pmd = pmd_offset(pud, address);
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto out;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
