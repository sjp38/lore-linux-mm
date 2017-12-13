Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B45C6B0268
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 05:58:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z25so1369315pgu.18
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 02:58:16 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g188si1079666pgc.386.2017.12.13.02.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 02:58:15 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 09/12] x86/mm: Provide pmdp_establish() helper
Date: Wed, 13 Dec 2017 13:57:53 +0300
Message-Id: <20171213105756.69879-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
References: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

We need an atomic way to setup pmd page table entry, avoiding races with
CPU setting dirty/accessed bits. This is required to implement
pmdp_invalidate() that doesn't lose these bits.

On PAE we can avoid expensive cmpxchg8b for cases when new page table
entry is not present. If it's present, fallback to cpmxchg loop.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/pgtable-3level.h | 37 ++++++++++++++++++++++++++++++++++-
 arch/x86/include/asm/pgtable.h        | 15 ++++++++++++++
 2 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index bc4af5453802..2c874cfc7789 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -158,7 +158,6 @@ static inline pte_t native_ptep_get_and_clear(pte_t *ptep)
 #define native_ptep_get_and_clear(xp) native_local_ptep_get_and_clear(xp)
 #endif
 
-#ifdef CONFIG_SMP
 union split_pmd {
 	struct {
 		u32 pmd_low;
@@ -166,6 +165,8 @@ union split_pmd {
 	};
 	pmd_t pmd;
 };
+
+#ifdef CONFIG_SMP
 static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
 {
 	union split_pmd res, *orig = (union split_pmd *)pmdp;
@@ -181,6 +182,40 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
 #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
+#ifndef pmdp_establish
+#define pmdp_establish pmdp_establish
+static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmdp, pmd_t pmd)
+{
+	pmd_t old;
+
+	/*
+	 * If pmd has present bit cleared we can get away without expensive
+	 * cmpxchg64: we can update pmdp half-by-half without racing with
+	 * anybody.
+	 */
+	if (!(pmd_val(pmd) & _PAGE_PRESENT)) {
+		union split_pmd old, new, *ptr;
+
+		ptr = (union split_pmd *)pmdp;
+
+		new.pmd = pmd;
+
+		/* xchg acts as a barrier before setting of the high bits */
+		old.pmd_low = xchg(&ptr->pmd_low, new.pmd_low);
+		old.pmd_high = ptr->pmd_high;
+		ptr->pmd_high = new.pmd_high;
+		return old.pmd;
+	}
+
+	{
+		old = *pmdp;
+	} while (cmpxchg64(&pmdp->pmd, old.pmd, pmd.pmd) != old.pmd);
+
+	return old;
+}
+#endif
+
 #ifdef CONFIG_SMP
 union split_pud {
 	struct {
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 95e2dfd75521..099ebe0053c3 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1094,6 +1094,21 @@ static inline int pud_write(pud_t pud)
 	return pud_flags(pud) & _PAGE_RW;
 }
 
+#ifndef pmdp_establish
+#define pmdp_establish pmdp_establish
+static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmdp, pmd_t pmd)
+{
+	if (IS_ENABLED(CONFIG_SMP)) {
+		return xchg(pmdp, pmd);
+	} else {
+		pmd_t old = *pmdp;
+		*pmdp = pmd;
+		return old;
+	}
+}
+#endif
+
 /*
  * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
  *
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
