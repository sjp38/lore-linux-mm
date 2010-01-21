Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7B11B6B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 01:51:28 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 16 of 30] add pmd mmu_notifier helpers
Message-Id: <709e8a886ddac88289c9.1264054840@v2.random>
In-Reply-To: <patchbomb.1264054824@v2.random>
References: <patchbomb.1264054824@v2.random>
Date: Thu, 21 Jan 2010 07:20:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
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
+	VM_BUG_ON(__address & ~HPAGE_PMD_MASK);				\
+	mmu_notifier_invalidate_range_start(___vma->vm_mm, ___address,	\
+					    (__address)+HPAGE_PMD_SIZE);\
+	__pmd = pmdp_clear_flush(___vma, ___address, __pmdp);		\
+	mmu_notifier_invalidate_range_end(___vma->vm_mm, ___address,	\
+					  (__address)+HPAGE_PMD_SIZE);	\
+	__pmd;								\
+})
+
+#define pmdp_splitting_flush_notify(__vma, __address, __pmdp)		\
+({									\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	VM_BUG_ON(__address & ~HPAGE_PMD_MASK);				\
+	mmu_notifier_invalidate_range_start(___vma->vm_mm, ___address,	\
+					    (__address)+HPAGE_PMD_SIZE);\
+	pmdp_splitting_flush(___vma, ___address, __pmdp);		\
+	mmu_notifier_invalidate_range_end(___vma->vm_mm, ___address,	\
+					  (__address)+HPAGE_PMD_SIZE);	\
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
+#define pmdp_splitting_flush_notify pmdp_splitting_flush
 #define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
