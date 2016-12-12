Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA6AD6B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:34:44 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id x186so39611584vkd.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 08:34:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x6si11270439vkb.55.2016.12.12.08.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 08:34:43 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBCGYHpK083093
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:34:43 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 279t6e72t5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 11:34:43 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 12 Dec 2016 09:34:42 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mm/thp/pagecache/collapse: Free the pte page table on collapse for thp page cache.
Date: Mon, 12 Dec 2016 22:04:28 +0530
In-Reply-To: <20161212163428.6780-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161212163428.6780-1-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <20161212163428.6780-2-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With THP page cache, when trying to build a huge page from regular pte pages,
we just clear the pmd entry. We will take another fault and at that point we
will find the huge page in the radix tree, thereby using the huge page to
complete the page fault

The second fault path will allocate the needed pgtable_t page for archs like
ppc64. So no need to deposit the same in collapse path. Depositing them in
the collapse path resulting in a pgtable_t memory leak also giving errors like
"[ 2362.021762] BUG: non-zero nr_ptes on freeing mm: 3"

Fixes:"mm: THP page cache support for ppc64"

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/khugepaged.c | 21 ++-------------------
 1 file changed, 2 insertions(+), 19 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 7434a63cac94..4e0914849e55 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1242,7 +1242,6 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 	struct vm_area_struct *vma;
 	unsigned long addr;
 	pmd_t *pmd, _pmd;
-	bool deposited = false;
 
 	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
@@ -1267,26 +1266,10 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
 			/* assume page table is clear */
 			_pmd = pmdp_collapse_flush(vma, addr, pmd);
-			/*
-			 * now deposit the pgtable for arch that need it
-			 * otherwise free it.
-			 */
-			if (arch_needs_pgtable_deposit()) {
-				/*
-				 * The deposit should be visibile only after
-				 * collapse is seen by others.
-				 */
-				smp_wmb();
-				pgtable_trans_huge_deposit(vma->vm_mm, pmd,
-							   pmd_pgtable(_pmd));
-				deposited = true;
-			}
 			spin_unlock(ptl);
 			up_write(&vma->vm_mm->mmap_sem);
-			if (!deposited) {
-				atomic_long_dec(&vma->vm_mm->nr_ptes);
-				pte_free(vma->vm_mm, pmd_pgtable(_pmd));
-			}
+			atomic_long_dec(&vma->vm_mm->nr_ptes);
+			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
 		}
 	}
 	i_mmap_unlock_write(mapping);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
