Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id AEC846B00DC
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 13:09:31 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fb1so6770764pad.3
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 10:09:31 -0700 (PDT)
Received: from psmtp.com ([74.125.245.138])
        by mx.google.com with SMTP id rr7si12236794pbc.15.2013.10.22.10.09.29
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 10:09:30 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 22 Oct 2013 22:39:22 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 386B7DA806C
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:59:09 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9MBVPfK38666418
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 17:01:26 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9MBSZJg023230
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:35 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 7/9] mm: numafaults: Use change_pmd_protnuma for updating _PAGE_NUMA for regular pmds
Date: Tue, 22 Oct 2013 16:58:18 +0530
Message-Id: <1382441300-1513-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Archs like ppc64 have different layout for pmd entries pointing to PTE
page. Hence add a separate function for modifying them

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable.h | 17 +++++++++++++++++
 include/asm-generic/pgtable.h      | 20 ++++++++++++++++++++
 mm/memory.c                        |  2 +-
 mm/mprotect.c                      | 24 ++++++------------------
 4 files changed, 44 insertions(+), 19 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 9d87125..67ea8fb 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -75,6 +75,23 @@ static inline pte_t pte_mknuma(pte_t pte)
 	return pte;
 }
 
+#define change_pmd_protnuma change_pmd_protnuma
+static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
+				       pmd_t *pmdp, int prot_numa)
+{
+	/*
+	 * We don't track the _PAGE_PRESENT bit here
+	 */
+	unsigned long pmd_val;
+	pmd_val = pmd_val(*pmdp);
+	if (prot_numa)
+		pmd_val |= _PAGE_NUMA;
+	else
+		pmd_val &= ~_PAGE_NUMA;
+	pmd_set(pmdp, pmd_val | _PAGE_NUMA);
+}
+
+
 #define pmd_numa pmd_numa
 static inline int pmd_numa(pmd_t pmd)
 {
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index f330d28..568a8c4 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -697,6 +697,18 @@ static inline pmd_t pmd_mknuma(pmd_t pmd)
 	return pmd_clear_flags(pmd, _PAGE_PRESENT);
 }
 #endif
+
+#ifndef change_pmd_protnuma
+static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
+				       pmd_t *pmd, int prot_numa)
+{
+	if (prot_numa)
+		set_pmd_at(mm, addr & PMD_MASK, pmd, pmd_mknuma(*pmd));
+	else
+		set_pmd_at(mm, addr & PMD_MASK, pmd, pmd_mknonnuma(*pmd));
+}
+
+#endif
 #else
 extern int pte_numa(pte_t pte);
 extern int pmd_numa(pmd_t pmd);
@@ -704,6 +716,8 @@ extern pte_t pte_mknonnuma(pte_t pte);
 extern pmd_t pmd_mknonnuma(pmd_t pmd);
 extern pte_t pte_mknuma(pte_t pte);
 extern pmd_t pmd_mknuma(pmd_t pmd);
+extern void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
+				pmd_t *pmd, int prot_numa);
 #endif /* CONFIG_ARCH_USES_NUMA_PROT_NONE */
 #else
 static inline int pmd_numa(pmd_t pmd)
@@ -735,6 +749,12 @@ static inline pmd_t pmd_mknuma(pmd_t pmd)
 {
 	return pmd;
 }
+
+static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
+				       pmd_t *pmd, int prot_numa)
+{
+	BUG();
+}
 #endif /* CONFIG_NUMA_BALANCING */
 
 #endif /* CONFIG_MMU */
diff --git a/mm/memory.c b/mm/memory.c
index ca00039..e930e50 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3605,7 +3605,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
 	if (pmd_numa(pmd)) {
-		set_pmd_at(mm, _addr, pmdp, pmd_mknonnuma(pmd));
+		change_pmd_protnuma(mm, _addr, pmdp, 0);
 		numa = true;
 	}
 	spin_unlock(&mm->page_table_lock);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 94722a4..88de575 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -112,22 +112,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	return pages;
 }
 
-#ifdef CONFIG_NUMA_BALANCING
-static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
-				       pmd_t *pmd)
-{
-	spin_lock(&mm->page_table_lock);
-	set_pmd_at(mm, addr & PMD_MASK, pmd, pmd_mknuma(*pmd));
-	spin_unlock(&mm->page_table_lock);
-}
-#else
-static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
-				       pmd_t *pmd)
-{
-	BUG();
-}
-#endif /* CONFIG_NUMA_BALANCING */
-
 static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		pud_t *pud, unsigned long addr, unsigned long end,
 		pgprot_t newprot, int dirty_accountable, int prot_numa)
@@ -161,8 +145,12 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		 * node. This allows a regular PMD to be handled as one fault
 		 * and effectively batches the taking of the PTL
 		 */
-		if (prot_numa && all_same_node)
-			change_pmd_protnuma(vma->vm_mm, addr, pmd);
+		if (prot_numa && all_same_node) {
+			spin_lock(&vma->vm_mm->page_table_lock);
+			change_pmd_protnuma(vma->vm_mm, addr, pmd, 1);
+			spin_unlock(&vma->vm_mm->page_table_lock);
+
+		}
 	} while (pmd++, addr = next, addr != end);
 
 	return pages;
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
