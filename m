Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9FA6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:43:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r16so225348368pfg.4
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:43:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e17si32921748pga.261.2016.10.18.08.43.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 08:43:06 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9IFcvhC039853
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:43:05 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 265hptju3r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:43:05 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 18 Oct 2016 11:43:04 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm/hugetlb: Use the right pte val for compare in hugetlb_cow
Date: Tue, 18 Oct 2016 21:12:45 +0530
Message-Id: <20161018154245.18023-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Jan Stancek <jstancek@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We cannot use the pte value used in set_pte_at for pte_same comparison,
because archs like ppc64, filter/add new pte flag in set_pte_at. Instead
fetch the pte value inside hugetlb_cow. We are comparing pte value to
make sure the pte didn't change since we dropped the page table lock.
hugetlb_cow get called with page table lock held, and we can take a copy
of the pte value before we drop the page table lock.

With hugetlbfs, we optimize the MAP_PRIVATE write fault path with no
previous mapping (huge_pte_none entries), by forcing a cow in the fault
path. This avoid take an addition fault to covert a read-only mapping
to read/write. Here we were comparing a recently instantiated pte (via
set_pte_at) to the pte values from linux page table. As explained above
on ppc64 such pte_same check returned wrong result, resulting in us
taking an additional fault on ppc64.

Fixes: 6a119eae942c ("powerpc/mm: Add a _PAGE_PTE bit")

Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ec49d9ef1eef..da8fbd02b92e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3386,15 +3386,17 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
  * Keep the pte_same checks anyway to make transition from the mutex easier.
  */
 static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pte_t *ptep, pte_t pte,
-			struct page *pagecache_page, spinlock_t *ptl)
+		       unsigned long address, pte_t *ptep,
+		       struct page *pagecache_page, spinlock_t *ptl)
 {
+	pte_t pte;
 	struct hstate *h = hstate_vma(vma);
 	struct page *old_page, *new_page;
 	int ret = 0, outside_reserve = 0;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
+	pte = huge_ptep_get(ptep);
 	old_page = pte_page(pte);
 
 retry_avoidcopy:
@@ -3668,7 +3670,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	hugetlb_count_add(pages_per_huge_page(h), mm);
 	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
 		/* Optimization, do the COW without a second fault */
-		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page, ptl);
+		ret = hugetlb_cow(mm, vma, address, ptep, page, ptl);
 	}
 
 	spin_unlock(ptl);
@@ -3822,8 +3824,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!huge_pte_write(entry)) {
-			ret = hugetlb_cow(mm, vma, address, ptep, entry,
-					pagecache_page, ptl);
+			ret = hugetlb_cow(mm, vma, address, ptep,
+					  pagecache_page, ptl);
 			goto out_put_page;
 		}
 		entry = huge_pte_mkdirty(entry);
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
