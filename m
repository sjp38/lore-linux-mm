Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 45A4D6B02F3
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h65so1523296wmd.7
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:53:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m82si3641453wmf.108.2017.04.27.08.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 08:53:09 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3RFmuZW060516
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:08 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a3jjkk89e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:53:07 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 16:53:05 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v3 01/17] mm: Dont assume page-table invariance during faults
Date: Thu, 27 Apr 2017 17:52:40 +0200
In-Reply-To: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1493308376-23851-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

From: Peter Zijlstra <peterz@infradead.org>

One of the side effects of speculating on faults (without holding
mmap_sem) is that we can race with free_pgtables() and therefore we
cannot assume the page-tables will stick around.

Remove the relyance on the pte pointer.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 mm/memory.c | 27 ---------------------------
 1 file changed, 27 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 6bf2b471e30c..374b99de75a5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1962,30 +1962,6 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
-/*
- * handle_pte_fault chooses page fault handler according to an entry which was
- * read non-atomically.  Before making any commitment, on those architectures
- * or configurations (e.g. i386 with PAE) which might give a mix of unmatched
- * parts, do_swap_page must check under lock before unmapping the pte and
- * proceeding (but do_wp_page is only called after already making such a check;
- * and do_anonymous_page can safely check later on).
- */
-static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
-				pte_t *page_table, pte_t orig_pte)
-{
-	int same = 1;
-#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
-	if (sizeof(pte_t) > sizeof(unsigned long)) {
-		spinlock_t *ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
-		same = pte_same(*page_table, orig_pte);
-		spin_unlock(ptl);
-	}
-#endif
-	pte_unmap(page_table);
-	return same;
-}
-
 static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
 {
 	debug_dma_assert_idle(src);
@@ -2542,9 +2518,6 @@ int do_swap_page(struct vm_fault *vmf)
 	int exclusive = 0;
 	int ret = 0;
 
-	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
-		goto out;
-
 	entry = pte_to_swp_entry(vmf->orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
