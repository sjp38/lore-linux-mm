Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA766B0070
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 04:26:01 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so53131013pac.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 01:26:01 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id ow4si2451854pdb.113.2015.04.30.01.25.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 01:25:58 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 30 Apr 2015 13:55:55 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 294743940049
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:55:52 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3U8PpS445744224
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:55:51 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3U8PoM9029897
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:55:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 1/3] mm/thp: Use pmdp_splitting_flush_notify to clear pmd on splitting
Date: Thu, 30 Apr 2015 13:55:39 +0530
Message-Id: <1430382341-8316-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1430382341-8316-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1430382341-8316-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Some arch may require an explicit IPI before a THP PMD split. This
ensures that a local_irq_disable can prevent a parallel THP PMD split.
So use new function which arch can override

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/asm-generic/pgtable.h |  5 +++++
 mm/huge_memory.c              |  7 ++++---
 mm/pgtable-generic.c          | 11 +++++++++++
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index fe617b7e4be6..d091a666f5b1 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -184,6 +184,11 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH_NOTIFY
+extern void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
+					unsigned long address, pmd_t *pmdp);
+#endif
+
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				       pgtable_t pgtable);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cce4604c192f..81e9578bf43a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2606,9 +2606,10 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
-
-	/* leave pmd empty until pte is filled */
-	pmdp_clear_flush_notify(vma, haddr, pmd);
+	/*
+	 * leave pmd empty until pte is filled.
+	 */
+	pmdp_splitting_flush_notify(vma, haddr, pmd);
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 2fe699cedd4d..0fc1f5a06979 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/pagemap.h>
+#include <linux/mmu_notifier.h>
 #include <asm/tlb.h>
 #include <asm-generic/pgtable.h>
 
@@ -184,3 +185,13 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
+
+#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH_NOTIFY
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp)
+{
+	pmdp_clear_flush_notify(vma, address, pmdp);
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
