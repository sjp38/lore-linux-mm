Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACB612806CB
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b78so16162309wrd.18
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 10:12:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y72si12303365wme.154.2017.04.17.10.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 10:12:32 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3HH92vi023661
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:31 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29w0e13v1p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:30 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 17 Apr 2017 13:12:30 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 6/7] powerpc/hugetlb: Add follow_huge_pd implementation for ppc64.
Date: Mon, 17 Apr 2017 22:41:45 +0530
In-Reply-To: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1492449106-27467-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hugetlbpage.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 80f6d2ed551a..5c829a83a4cc 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -17,6 +17,8 @@
 #include <linux/memblock.h>
 #include <linux/bootmem.h>
 #include <linux/moduleparam.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
@@ -618,6 +620,46 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 }
 
 /*
+ * 64 bit book3s use generic follow_page_mask
+ */
+#ifdef CONFIG_PPC_BOOK3S_64
+
+struct page *follow_huge_pd(struct vm_area_struct *vma,
+			    unsigned long address, hugepd_t hpd,
+			    int flags, int pdshift)
+{
+	pte_t *ptep;
+	spinlock_t *ptl;
+	struct page *page = NULL;
+	unsigned long mask;
+	int shift = hugepd_shift(hpd);
+	struct mm_struct *mm = vma->vm_mm;
+
+retry:
+	ptl = &mm->page_table_lock;
+	spin_lock(ptl);
+
+	ptep = hugepte_offset(hpd, address, pdshift);
+	if (pte_present(*ptep)) {
+		mask = (1UL << shift) - 1;
+		page = pte_page(*ptep);
+		page += ((address & mask) >> PAGE_SHIFT);
+		if (flags & FOLL_GET)
+			get_page(page);
+	} else {
+		if (is_hugetlb_entry_migration(*ptep)) {
+			spin_unlock(ptl);
+			__migration_entry_wait(mm, ptep, ptl);
+			goto retry;
+		}
+	}
+	spin_unlock(ptl);
+	return page;
+}
+
+#else /* !CONFIG_PPC_BOOK3S_64 */
+
+/*
  * We are holding mmap_sem, so a parallel huge page collapse cannot run.
  * To prevent hugepage split, disable irq.
  */
@@ -672,6 +714,7 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 	BUG();
 	return NULL;
 }
+#endif
 
 static unsigned long hugepte_addr_end(unsigned long addr, unsigned long end,
 				      unsigned long sz)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
