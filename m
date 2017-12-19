Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52DEB6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:58:39 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y2so12799510pgv.8
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:58:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v90si11475407pfk.397.2017.12.19.08.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 08:58:38 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 1/2] mm: Make follow_pte_pmd an inline
Date: Tue, 19 Dec 2017 08:58:22 -0800
Message-Id: <20171219165823.24243-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Josh Triplett <josh@joshtriplett.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The one user of follow_pte_pmd (dax) emits a sparse warning because
it doesn't know that follow_pte_pmd conditionally returns with the
pte/pmd locked.  The required annotation is already there; it's just
in the wrong file.
---
 include/linux/mm.h | 15 ++++++++++++++-
 mm/memory.c        | 16 +---------------
 2 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ea818ff739cd..94a9d2149bd6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1314,7 +1314,7 @@ int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
-int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 			     unsigned long *start, unsigned long *end,
 			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
@@ -1324,6 +1324,19 @@ int follow_phys(struct vm_area_struct *vma, unsigned long address,
 int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 			void *buf, int len, int write);
 
+static inline int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+			     unsigned long *start, unsigned long *end,
+			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
+{
+	int res;
+
+	/* (void) is needed to make gcc happy */
+	(void) __cond_lock(*ptlp,
+			   !(res = __follow_pte_pmd(mm, address, start, end,
+						    ptepp, pmdpp, ptlp)));
+	return res;
+}
+
 static inline void unmap_shared_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen)
 {
diff --git a/mm/memory.c b/mm/memory.c
index cfaba6287702..cb433662af21 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4201,7 +4201,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 }
 #endif /* __PAGETABLE_PMD_FOLDED */
 
-static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 			    unsigned long *start, unsigned long *end,
 			    pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
 {
@@ -4278,20 +4278,6 @@ static inline int follow_pte(struct mm_struct *mm, unsigned long address,
 	return res;
 }
 
-int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
-			     unsigned long *start, unsigned long *end,
-			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
-{
-	int res;
-
-	/* (void) is needed to make gcc happy */
-	(void) __cond_lock(*ptlp,
-			   !(res = __follow_pte_pmd(mm, address, start, end,
-						    ptepp, pmdpp, ptlp)));
-	return res;
-}
-EXPORT_SYMBOL(follow_pte_pmd);
-
 /**
  * follow_pfn - look up PFN at a user virtual address
  * @vma: memory mapping
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
