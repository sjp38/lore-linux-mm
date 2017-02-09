Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 645B428089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 22:01:18 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id o185so11081931itb.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 19:01:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x69si3541500ita.91.2017.02.08.19.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 19:01:17 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v192wjVx074254
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 22:01:17 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28gcrj6e2u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 22:01:16 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 8 Feb 2017 20:01:16 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm/autonuma: Let architecture override how the write bit should be stashed in a protnone pte.
Date: Thu,  9 Feb 2017 08:30:58 +0530
Message-Id: <1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Autonuma preserves the write permission across numa fault to avoid taking
a writefault after a numa fault (Commit: b191f9b106ea " mm: numa: preserve PTE
write permissions across a NUMA hinting fault"). Architecture can implement
protnone in different ways and some may choose to implement that by clearing Read/
Write/Exec bit of pte. Setting the write bit on such pte can result in wrong
behaviour. Fix this up by allowing arch to override how to save the write bit
on a protnone pte.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/asm-generic/pgtable.h | 16 ++++++++++++++++
 mm/huge_memory.c              |  4 ++--
 mm/memory.c                   |  2 +-
 mm/mprotect.c                 |  4 ++--
 4 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 18af2bcefe6a..b6f3a8a4b738 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -192,6 +192,22 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addres
 }
 #endif
 
+#ifndef pte_savedwrite
+#define pte_savedwrite pte_write
+#endif
+
+#ifndef pte_mk_savedwrite
+#define pte_mk_savedwrite pte_mkwrite
+#endif
+
+#ifndef pmd_savedwrite
+#define pmd_savedwrite pmd_write
+#endif
+
+#ifndef pmd_mk_savedwrite
+#define pmd_mk_savedwrite pmd_mkwrite
+#endif
+
 #ifndef __HAVE_ARCH_PMDP_SET_WRPROTECT
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static inline void pmdp_set_wrprotect(struct mm_struct *mm,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9a6bd6c8d55a..2f0f855ec911 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1300,7 +1300,7 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	goto out;
 clear_pmdnuma:
 	BUG_ON(!PageLocked(page));
-	was_writable = pmd_write(pmd);
+	was_writable = pmd_savedwrite(pmd);
 	pmd = pmd_modify(pmd, vma->vm_page_prot);
 	pmd = pmd_mkyoung(pmd);
 	if (was_writable)
@@ -1555,7 +1555,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			entry = pmdp_huge_get_and_clear_notify(mm, addr, pmd);
 			entry = pmd_modify(entry, newprot);
 			if (preserve_write)
-				entry = pmd_mkwrite(entry);
+				entry = pmd_mk_savedwrite(entry);
 			ret = HPAGE_PMD_NR;
 			set_pmd_at(mm, addr, pmd, entry);
 			BUG_ON(vma_is_anonymous(vma) && !preserve_write &&
diff --git a/mm/memory.c b/mm/memory.c
index e78bf72f30dd..88c24f89d6d3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3388,7 +3388,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	int target_nid;
 	bool migrated = false;
 	pte_t pte;
-	bool was_writable = pte_write(vmf->orig_pte);
+	bool was_writable = pte_savedwrite(vmf->orig_pte);
 	int flags = 0;
 
 	/*
diff --git a/mm/mprotect.c b/mm/mprotect.c
index f9c07f54dd62..15f5c174a7c1 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -113,13 +113,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			ptent = ptep_modify_prot_start(mm, addr, pte);
 			ptent = pte_modify(ptent, newprot);
 			if (preserve_write)
-				ptent = pte_mkwrite(ptent);
+				ptent = pte_mk_savedwrite(ptent);
 
 			/* Avoid taking write faults for known dirty pages */
 			if (dirty_accountable && pte_dirty(ptent) &&
 					(pte_soft_dirty(ptent) ||
 					 !(vma->vm_flags & VM_SOFTDIRTY))) {
-				ptent = pte_mkwrite(ptent);
+				ptent = pte_mk_savedwrite(ptent);
 			}
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
 			pages++;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
