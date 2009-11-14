Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5961B6B0062
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:25 -0500 (EST)
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIANH1014283
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:23 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 16 of 25] add pmd mmu_notifier helpers
Message-Id: <38ec838b81f216020492.1258220314@v2.random>
In-Reply-To: <patchbomb.1258220298@v2.random>
References: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:34 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add mmu notifier helpers to handle pmd huge operations.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -243,6 +243,32 @@ static inline void mmu_notifier_mm_destr
 	__pte;								\
 })
 
+#define pmdp_clear_flush_notify(__vma, __address, __pmdp)		\
+({									\
+	pmd_t __pmd;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	VM_BUG_ON(__address & ~HPAGE_MASK);				\
+	mmu_notifier_invalidate_range_start(___vma->vm_mm, ___address,	\
+					    (__address)+HPAGE_SIZE);	\
+	__pmd = pmdp_clear_flush(___vma, ___address, __pmdp);		\
+	mmu_notifier_invalidate_range_end(___vma->vm_mm, ___address,	\
+					  (__address)+HPAGE_SIZE);	\
+	__pmd;								\
+})
+
+#define pmdp_freeze_flush_notify(__vma, __address, __pmdp)		\
+({									\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	VM_BUG_ON(__address & ~HPAGE_MASK);				\
+	mmu_notifier_invalidate_range_start(___vma->vm_mm, ___address,	\
+					    (__address)+HPAGE_SIZE);	\
+	pmdp_freeze_flush(___vma, ___address, __pmdp);			\
+	mmu_notifier_invalidate_range_end(___vma->vm_mm, ___address,	\
+					  (__address)+HPAGE_SIZE);	\
+})
+
 #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
 ({									\
 	int __young;							\
@@ -254,6 +280,17 @@ static inline void mmu_notifier_mm_destr
 	__young;							\
 })
 
+#define pmdp_clear_flush_young_notify(__vma, __address, __pmdp)		\
+({									\
+	int __young;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	__young = pmdp_clear_flush_young(___vma, ___address, __pmdp);	\
+	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
+						  ___address);		\
+	__young;							\
+})
+
 #define set_pte_at_notify(__mm, __address, __ptep, __pte)		\
 ({									\
 	struct mm_struct *___mm = __mm;					\
@@ -305,7 +342,10 @@ static inline void mmu_notifier_mm_destr
 }
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
+#define pmdp_clear_flush_young_notify pmdp_clear_flush_young
 #define ptep_clear_flush_notify ptep_clear_flush
+#define pmdp_clear_flush_notify pmdp_clear_flush
+#define pmdp_freeze_flush_notify pmdp_freeze_flush
 #define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
