Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB886B035A
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 17:23:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j128so291708337pfg.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 14:23:17 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l24si23948313pgn.71.2016.12.20.14.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 14:23:16 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 1/2] mm: add follow_pte_pmd()
Date: Tue, 20 Dec 2016 15:23:05 -0700
Message-Id: <1482272586-21177-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1482272586-21177-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1482272586-21177-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Similar to follow_pte(), follow_pte_pmd() allows either a PTE leaf or a
huge page PMD leaf to be found and returned.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Suggested-by: Dave Hansen <dave.hansen@intel.com>
---
 include/linux/mm.h |  2 ++
 mm/memory.c        | 37 ++++++++++++++++++++++++++++++-------
 2 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4424784..ff0e1c1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1212,6 +1212,8 @@ void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 int follow_pte(struct mm_struct *mm, unsigned long address, pte_t **ptepp,
 	       spinlock_t **ptlp);
+int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
diff --git a/mm/memory.c b/mm/memory.c
index 455c3e6..29edd91 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3779,8 +3779,8 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 }
 #endif /* __PAGETABLE_PMD_FOLDED */
 
-static int __follow_pte(struct mm_struct *mm, unsigned long address,
-		pte_t **ptepp, spinlock_t **ptlp)
+static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+		pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -3797,11 +3797,20 @@ static int __follow_pte(struct mm_struct *mm, unsigned long address,
 
 	pmd = pmd_offset(pud, address);
 	VM_BUG_ON(pmd_trans_huge(*pmd));
-	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
-		goto out;
 
-	/* We cannot handle huge page PFN maps. Luckily they don't exist. */
-	if (pmd_huge(*pmd))
+	if (pmd_huge(*pmd)) {
+		if (!pmdpp)
+			goto out;
+
+		*ptlp = pmd_lock(mm, pmd);
+		if (pmd_huge(*pmd)) {
+			*pmdpp = pmd;
+			return 0;
+		}
+		spin_unlock(*ptlp);
+	}
+
+	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto out;
 
 	ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
@@ -3824,9 +3833,23 @@ int follow_pte(struct mm_struct *mm, unsigned long address, pte_t **ptepp,
 
 	/* (void) is needed to make gcc happy */
 	(void) __cond_lock(*ptlp,
-			   !(res = __follow_pte(mm, address, ptepp, ptlp)));
+			   !(res = __follow_pte_pmd(mm, address, ptepp, NULL,
+					   ptlp)));
+	return res;
+}
+
+int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
+{
+	int res;
+
+	/* (void) is needed to make gcc happy */
+	(void) __cond_lock(*ptlp,
+			   !(res = __follow_pte_pmd(mm, address, ptepp, pmdpp,
+					   ptlp)));
 	return res;
 }
+EXPORT_SYMBOL(follow_pte_pmd);
 
 /**
  * follow_pfn - look up PFN at a user virtual address
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
