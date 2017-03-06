Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04CF16B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 06:20:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b2so204901056pgc.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 03:20:56 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z31si18785715plb.153.2017.03.06.03.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 03:20:55 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: drop unused pmdp_huge_get_and_clear_notify()
Date: Mon,  6 Mar 2017 14:20:47 +0300
Message-Id: <20170306112047.24809-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>

Dave noticed that after fixing MADV_DONTNEED vs. numa balancing race the
last pmdp_huge_get_and_clear_notify() user is gone.

Let's drop the helper.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 include/linux/mmu_notifier.h | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 51891fb0d3ce..c91b3bcd158f 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -394,18 +394,6 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	___pud;								\
 })
 
-#define pmdp_huge_get_and_clear_notify(__mm, __haddr, __pmd)		\
-({									\
-	unsigned long ___haddr = __haddr & HPAGE_PMD_MASK;		\
-	pmd_t ___pmd;							\
-									\
-	___pmd = pmdp_huge_get_and_clear(__mm, __haddr, __pmd);		\
-	mmu_notifier_invalidate_range(__mm, ___haddr,			\
-				      ___haddr + HPAGE_PMD_SIZE);	\
-									\
-	___pmd;								\
-})
-
 /*
  * set_pte_at_notify() sets the pte _after_ running the notifier.
  * This is safe to start by updating the secondary MMUs, because the primary MMU
@@ -489,7 +477,6 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 #define	ptep_clear_flush_notify ptep_clear_flush
 #define pmdp_huge_clear_flush_notify pmdp_huge_clear_flush
 #define pudp_huge_clear_flush_notify pudp_huge_clear_flush
-#define pmdp_huge_get_and_clear_notify pmdp_huge_get_and_clear
 #define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
