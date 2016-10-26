Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E64B6B027C
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t25so149727080pfg.3
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 01:49:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n16si1392793pgd.276.2016.10.26.01.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 01:49:31 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9Q8n1xi097349
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:31 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26ajdyvg89-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:30 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 26 Oct 2016 02:49:28 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 3/5] mm/hugetlb: add tlb_remove_hugetlb_entry for handling hugetlb pages
Date: Wed, 26 Oct 2016 14:18:37 +0530
In-Reply-To: <20161026084839.27299-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161026084839.27299-1-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <20161026084839.27299-4-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This add tlb_remove_hugetlb_entry similar to tlb_remove_pmd_tlb_entry.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/arm/include/asm/tlb.h  | 2 ++
 arch/ia64/include/asm/tlb.h | 3 +++
 arch/s390/include/asm/tlb.h | 2 ++
 arch/sh/include/asm/tlb.h   | 3 +++
 arch/um/include/asm/tlb.h   | 3 +++
 include/asm-generic/tlb.h   | 6 ++++++
 mm/hugetlb.c                | 2 +-
 7 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 1e25cd80589e..82841ba1f51f 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -186,6 +186,8 @@ tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long addr)
 	tlb_add_flush(tlb, addr);
 }
 
+#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
+	tlb_remove_tlb_entry(tlb, ptep, address)
 /*
  * In the case of tlb vma handling, we can optimise these away in the
  * case where we're doing a full MM flush.  When we're doing a munmap,
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index 77e541cf0e5d..b3f369ab844d 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -283,6 +283,9 @@ do {							\
 	__tlb_remove_tlb_entry(tlb, ptep, addr);	\
 } while (0)
 
+#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
+	tlb_remove_tlb_entry(tlb, ptep, address)
+
 #define pte_free_tlb(tlb, ptep, address)		\
 do {							\
 	tlb->need_flush = 1;				\
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 15711de10403..094440b59f9e 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -162,5 +162,7 @@ static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 #define tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
 #define tlb_remove_pmd_tlb_entry(tlb, pmdp, addr)	do { } while (0)
 #define tlb_migrate_finish(mm)			do { } while (0)
+#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
+	tlb_remove_tlb_entry(tlb, ptep, address)
 
 #endif /* _S390_TLB_H */
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 025cdb1032f6..e7d15e8c75c1 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -65,6 +65,9 @@ tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long address)
 		tlb->end = address + PAGE_SIZE;
 }
 
+#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
+	tlb_remove_tlb_entry(tlb, ptep, address)
+
 /*
  * In the case of tlb vma handling, we can optimise these away in the
  * case where we're doing a full MM flush.  When we're doing a munmap,
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index 821ff0acfe17..a4427029c3c8 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -141,6 +141,9 @@ static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
+#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
+	tlb_remove_tlb_entry(tlb, ptep, address)
+
 #define pte_free_tlb(tlb, ptep, addr) __pte_free_tlb(tlb, ptep, addr)
 
 #define pud_free_tlb(tlb, pudp, addr) __pud_free_tlb(tlb, pudp, addr)
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index dba727becd5f..38c2b708df6e 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -220,6 +220,12 @@ static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb, struct page *pa
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
+#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	     \
+	do {							     \
+		__tlb_adjust_range(tlb, address, huge_page_size(h)); \
+		__tlb_remove_tlb_entry(tlb, ptep, address);	     \
+	} while (0)
+
 /**
  * tlb_remove_pmd_tlb_entry - remember a pmd mapping for later tlb invalidation
  * This is a nop so far, because only x86 needs it.
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ec49d9ef1eef..655d3cf05551 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3272,7 +3272,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		}
 
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
-		tlb_remove_tlb_entry(tlb, ptep, address);
+		tlb_remove_huge_tlb_entry(h, tlb, ptep, address);
 		if (huge_pte_dirty(pte))
 			set_page_dirty(page);
 
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
