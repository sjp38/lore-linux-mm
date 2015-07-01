Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3586B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 14:28:02 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so40588095ieb.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 11:28:02 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id ng9si3431926icb.4.2015.07.01.11.28.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 11:28:01 -0700 (PDT)
Received: by igrv9 with SMTP id v9so40844871igr.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 11:28:01 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] mm:Make the function zap_huge_pmd bool
Date: Wed,  1 Jul 2015 14:27:57 -0400
Message-Id: <1435775277-27381-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This makes the function zap_huge_pmd have a return type of bool
now due to this particular function always returning one or zero
as its return value.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 include/linux/huge_mm.h | 2 +-
 mm/huge_memory.c        | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index f10b20f..e83174e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -19,7 +19,7 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
 					  pmd_t *pmd,
 					  unsigned int flags);
-extern int zap_huge_pmd(struct mmu_gather *tlb,
+extern bool zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c107094..32b1993 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1384,11 +1384,11 @@ out:
 	return 0;
 }
 
-int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
+bool zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
 	spinlock_t *ptl;
-	int ret = 0;
+	int ret = false;
 
 	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		struct page *page;
@@ -1419,7 +1419,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			tlb_remove_page(tlb, page);
 		}
 		pte_free(tlb->mm, pgtable);
-		ret = 1;
+		ret = true;
 	}
 	return ret;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
