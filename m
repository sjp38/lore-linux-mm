Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9030D6B02FD
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t126so110509937pgc.9
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b1si23958937pld.97.2017.05.24.04.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 04:20:21 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OB9jlr141469
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:21 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2amvavx09s-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:21 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 24 May 2017 12:20:18 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v2 04/10] mm: Handle range lock field when collapsing huge pages
Date: Wed, 24 May 2017 13:19:55 +0200
In-Reply-To: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1495624801-8063-5-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

When collapsing huge pages from swap in operatioin, a vm_fault
structure is built and passed to do_swap_page(). The new range field
of the vm_fault structure must be set correctly when dealing with
range_lock.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/khugepaged.c | 39 +++++++++++++++++++++++++++++++++------
 1 file changed, 33 insertions(+), 6 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 945fd1ca49b5..6357f32608a5 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -872,7 +872,11 @@ static int hugepage_vma_revalidate(struct mm_struct *mm, unsigned long address,
 static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd,
-					int referenced)
+					int referenced
+#ifdef CONFIG_MEM_RANGE_LOCK
+					, struct range_lock *range
+#endif
+	)
 {
 	int swapped_in = 0, ret = 0;
 	struct vm_fault vmf = {
@@ -881,6 +885,9 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		.flags = FAULT_FLAG_ALLOW_RETRY,
 		.pmd = pmd,
 		.pgoff = linear_page_index(vma, address),
+#ifdef CONFIG_MEM_RANGE_LOCK
+		.lockrange = range,
+#endif
 	};
 
 	/* we only decide to swapin, if there is enough young ptes */
@@ -927,7 +934,11 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 static void collapse_huge_page(struct mm_struct *mm,
 				   unsigned long address,
 				   struct page **hpage,
-				   int node, int referenced)
+				   int node, int referenced
+#ifdef CONFIG_MEM_RANGE_LOCK
+				   , struct range_lock *range
+#endif
+				   )
 {
 	pmd_t *pmd, _pmd;
 	pte_t *pte;
@@ -985,7 +996,11 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * If it fails, we release mmap_sem and jump out_nolock.
 	 * Continuing to collapse causes inconsistency.
 	 */
-	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced)) {
+	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced
+#ifdef CONFIG_MEM_RANGE_LOCK
+					 , range
+#endif
+		    )) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
 		up_read(&mm->mmap_sem);
 		goto out_nolock;
@@ -1092,7 +1107,11 @@ static void collapse_huge_page(struct mm_struct *mm,
 static int khugepaged_scan_pmd(struct mm_struct *mm,
 			       struct vm_area_struct *vma,
 			       unsigned long address,
-			       struct page **hpage)
+			       struct page **hpage
+#ifdef CONFIG_MEM_RANGE_LOCK
+			       , struct range_lock *range
+#endif
+	)
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
@@ -1206,7 +1225,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	if (ret) {
 		node = khugepaged_find_target_node();
 		/* collapse_huge_page will return with the mmap_sem released */
-		collapse_huge_page(mm, address, hpage, node, referenced);
+		collapse_huge_page(mm, address, hpage, node, referenced
+#ifdef CONFIG_MEM_RANGE_LOCK
+				   , range
+#endif
+			);
 	}
 out:
 	trace_mm_khugepaged_scan_pmd(mm, page, writable, referenced,
@@ -1727,7 +1750,11 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 			} else {
 				ret = khugepaged_scan_pmd(mm, vma,
 						khugepaged_scan.address,
-						hpage);
+						hpage
+#ifdef CONFIG_MEM_RANGE_LOCK
+						, &range
+#endif
+						);
 			}
 			/* move to next address */
 			khugepaged_scan.address += HPAGE_PMD_SIZE;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
