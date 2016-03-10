Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 592B9828E1
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 18:55:57 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id u190so50953904pfb.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:55:57 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id ua2si9297558pac.51.2016.03.10.15.55.40
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 15:55:40 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 07/14] x86: Unify native_*_get_and_clear !SMP case
Date: Thu, 10 Mar 2016 18:55:24 -0500
Message-Id: <1457654131-4562-8-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, willy@linux.intel.com

x86_32 and x86_64 had diverged slightly in their implementations
of the non-SMP cases for native_ptep_get_and_clear() and
native_pmdp_get_and_clear().  Unify the non-SMP cases in pgtable.h,
leaving only the SMP cases in the other three files.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 arch/x86/include/asm/pgtable-2level.h |  6 ------
 arch/x86/include/asm/pgtable-3level.h |  7 +------
 arch/x86/include/asm/pgtable.h        |  5 +++++
 arch/x86/include/asm/pgtable_64.h     | 18 ++----------------
 4 files changed, 8 insertions(+), 28 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
index fd74a11..520318f 100644
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -42,17 +42,11 @@ static inline pte_t native_ptep_get_and_clear(pte_t *xp)
 {
 	return __pte(xchg(&xp->pte_low, 0));
 }
-#else
-#define native_ptep_get_and_clear(xp) native_local_ptep_get_and_clear(xp)
-#endif
 
-#ifdef CONFIG_SMP
 static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
 {
 	return __pmd(xchg((pmdval_t *)xp, 0));
 }
-#else
-#define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
 /* Bit manipulation helper on pte/pgoff entry */
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index cdaa58c..b1b6412 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -149,11 +149,7 @@ static inline pte_t native_ptep_get_and_clear(pte_t *ptep)
 
 	return res;
 }
-#else
-#define native_ptep_get_and_clear(xp) native_local_ptep_get_and_clear(xp)
-#endif
 
-#ifdef CONFIG_SMP
 union split_pmd {
 	struct {
 		u32 pmd_low;
@@ -161,6 +157,7 @@ union split_pmd {
 	};
 	pmd_t pmd;
 };
+
 static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
 {
 	union split_pmd res, *orig = (union split_pmd *)pmdp;
@@ -172,8 +169,6 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
 
 	return res.pmd;
 }
-#else
-#define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
 /* Encode and de-code a swap entry */
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 1ff49ec..35306ca 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -740,6 +740,11 @@ static inline pmd_t native_local_pmdp_get_and_clear(pmd_t *pmdp)
 	return res;
 }
 
+#ifndef CONFIG_SMP
+#define native_ptep_get_and_clear(p)	native_local_ptep_get_and_clear(p)
+#define native_pmdp_get_and_clear(p)	native_local_pmdp_get_and_clear(p)
+#endif
+
 static inline void native_set_pte_at(struct mm_struct *mm, unsigned long addr,
 				     pte_t *ptep , pte_t pte)
 {
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 2ee7811..a0c0219 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -70,31 +70,17 @@ static inline void native_pmd_clear(pmd_t *pmd)
 	native_set_pmd(pmd, native_make_pmd(0));
 }
 
+#ifdef CONFIG_SMP
 static inline pte_t native_ptep_get_and_clear(pte_t *xp)
 {
-#ifdef CONFIG_SMP
 	return native_make_pte(xchg(&xp->pte, 0));
-#else
-	/* native_local_ptep_get_and_clear,
-	   but duplicated because of cyclic dependency */
-	pte_t ret = *xp;
-	native_pte_clear(NULL, 0, xp);
-	return ret;
-#endif
 }
 
 static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
 {
-#ifdef CONFIG_SMP
 	return native_make_pmd(xchg(&xp->pmd, 0));
-#else
-	/* native_local_pmdp_get_and_clear,
-	   but duplicated because of cyclic dependency */
-	pmd_t ret = *xp;
-	native_pmd_clear(xp);
-	return ret;
-#endif
 }
+#endif
 
 static inline void native_set_pud(pud_t *pudp, pud_t pud)
 {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
