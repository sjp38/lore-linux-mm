Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57B446B028E
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:33:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i123-v6so6813456pfc.13
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:33:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q185-v6si17504162pga.322.2018.07.10.15.31.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:31:12 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v2 10/27] x86/mm: Introduce _PAGE_DIRTY_SW
Date: Tue, 10 Jul 2018 15:26:22 -0700
Message-Id: <20180710222639.8241-11-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-1-yu-cheng.yu@intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

A RO and dirty PTE exists in the following cases:

(a) A page is modified and then shared with a fork()'ed child;
(b) A R/O page that has been COW'ed;
(c) A SHSTK page.

The processor does not read the dirty bit for (a) and (b), but
checks the dirty bit for (c).  To prevent the use of non-SHSTK
memory as SHSTK, we introduce a spare bit of the 64-bit PTE as
_PAGE_BIT_DIRTY_SW and use that for (a) and (b).  This results
to the following possible PTE settings:

Modified PTE:             (R/W + DIRTY_HW)
Modified and shared PTE:  (R/O + DIRTY_SW)
R/O PTE COW'ed:           (R/O + DIRTY_SW)
SHSTK PTE:                (R/O + DIRTY_HW)
SHSTK PTE COW'ed:         (R/O + DIRTY_HW)
SHSTK PTE shared:         (R/O + DIRTY_SW)

Note that _PAGE_BIT_DRITY_SW is only used in R/O PTEs but
not R/W PTEs.

When this patch is applied, there are six free bits left in
the 64-bit PTE.  There is no more free bit in the 32-bit
PTE (except for PAE) and shadow stack is not implemented
for the 32-bit kernel.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/pgtable.h       | 109 ++++++++++++++++++++++++---
 arch/x86/include/asm/pgtable_types.h |  14 +++-
 include/asm-generic/pgtable.h        |  21 ++++++
 3 files changed, 132 insertions(+), 12 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 28806f8f36c3..ecbd3539a864 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -116,9 +116,9 @@ extern pmdval_t early_pmd_flags;
  * The following only work if pte_present() is true.
  * Undefined behaviour if not..
  */
-static inline int pte_dirty(pte_t pte)
+static inline bool pte_dirty(pte_t pte)
 {
-	return pte_flags(pte) & _PAGE_DIRTY;
+	return pte_flags(pte) & _PAGE_DIRTY_BITS;
 }
 
 
@@ -140,9 +140,9 @@ static inline int pte_young(pte_t pte)
 	return pte_flags(pte) & _PAGE_ACCESSED;
 }
 
-static inline int pmd_dirty(pmd_t pmd)
+static inline bool pmd_dirty(pmd_t pmd)
 {
-	return pmd_flags(pmd) & _PAGE_DIRTY;
+	return pmd_flags(pmd) & _PAGE_DIRTY_BITS;
 }
 
 static inline int pmd_young(pmd_t pmd)
@@ -150,9 +150,9 @@ static inline int pmd_young(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_ACCESSED;
 }
 
-static inline int pud_dirty(pud_t pud)
+static inline bool pud_dirty(pud_t pud)
 {
-	return pud_flags(pud) & _PAGE_DIRTY;
+	return pud_flags(pud) & _PAGE_DIRTY_BITS;
 }
 
 static inline int pud_young(pud_t pud)
@@ -281,9 +281,23 @@ static inline pte_t pte_clear_flags(pte_t pte, pteval_t clear)
 	return native_make_pte(v & ~clear);
 }
 
+#if defined(CONFIG_X86_INTEL_SHADOW_STACK_USER)
+static inline pte_t pte_move_flags(pte_t pte, pteval_t from, pteval_t to)
+{
+	if (pte_flags(pte) & from)
+		pte = pte_set_flags(pte_clear_flags(pte, from), to);
+	return pte;
+}
+#else
+static inline pte_t pte_move_flags(pte_t pte, pteval_t from, pteval_t to)
+{
+	return pte;
+}
+#endif
+
 static inline pte_t pte_mkclean(pte_t pte)
 {
-	return pte_clear_flags(pte, _PAGE_DIRTY);
+	return pte_clear_flags(pte, _PAGE_DIRTY_BITS);
 }
 
 static inline pte_t pte_mkold(pte_t pte)
@@ -293,6 +307,7 @@ static inline pte_t pte_mkold(pte_t pte)
 
 static inline pte_t pte_wrprotect(pte_t pte)
 {
+	pte = pte_move_flags(pte, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
 	return pte_clear_flags(pte, _PAGE_RW);
 }
 
@@ -303,9 +318,27 @@ static inline pte_t pte_mkexec(pte_t pte)
 
 static inline pte_t pte_mkdirty(pte_t pte)
 {
+	pteval_t dirty = (!IS_ENABLED(CONFIG_X86_INTEL_SHSTK_USER) ||
+			   pte_write(pte)) ? _PAGE_DIRTY_HW:_PAGE_DIRTY_SW;
+	return pte_set_flags(pte, dirty | _PAGE_SOFT_DIRTY);
+}
+
+#ifdef CONFIG_ARCH_HAS_SHSTK
+static inline pte_t pte_mkdirty_shstk(pte_t pte)
+{
+	pte = pte_clear_flags(pte, _PAGE_DIRTY_SW);
 	return pte_set_flags(pte, _PAGE_DIRTY_HW | _PAGE_SOFT_DIRTY);
 }
 
+static inline bool is_shstk_pte(pte_t pte)
+{
+	pteval_t val;
+
+	val = pte_flags(pte) & (_PAGE_RW | _PAGE_DIRTY_HW);
+	return (val == _PAGE_DIRTY_HW);
+}
+#endif
+
 static inline pte_t pte_mkyoung(pte_t pte)
 {
 	return pte_set_flags(pte, _PAGE_ACCESSED);
@@ -313,6 +346,7 @@ static inline pte_t pte_mkyoung(pte_t pte)
 
 static inline pte_t pte_mkwrite(pte_t pte)
 {
+	pte = pte_move_flags(pte, _PAGE_DIRTY_SW, _PAGE_DIRTY_HW);
 	return pte_set_flags(pte, _PAGE_RW);
 }
 
@@ -360,6 +394,20 @@ static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
 	return native_make_pmd(v & ~clear);
 }
 
+#if defined(CONFIG_X86_INTEL_SHADOW_STACK_USER)
+static inline pmd_t pmd_move_flags(pmd_t pmd, pmdval_t from, pmdval_t to)
+{
+	if (pmd_flags(pmd) & from)
+		pmd = pmd_set_flags(pmd_clear_flags(pmd, from), to);
+	return pmd;
+}
+#else
+static inline pmd_t pmd_move_flags(pmd_t pmd, pmdval_t from, pmdval_t to)
+{
+	return pmd;
+}
+#endif
+
 static inline pmd_t pmd_mkold(pmd_t pmd)
 {
 	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
@@ -367,19 +415,39 @@ static inline pmd_t pmd_mkold(pmd_t pmd)
 
 static inline pmd_t pmd_mkclean(pmd_t pmd)
 {
-	return pmd_clear_flags(pmd, _PAGE_DIRTY);
+	return pmd_clear_flags(pmd, _PAGE_DIRTY_BITS);
 }
 
 static inline pmd_t pmd_wrprotect(pmd_t pmd)
 {
+	pmd = pmd_move_flags(pmd, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
 	return pmd_clear_flags(pmd, _PAGE_RW);
 }
 
 static inline pmd_t pmd_mkdirty(pmd_t pmd)
 {
+	pmdval_t dirty = (!IS_ENABLED(CONFIG_X86_INTEL_SHSTK_USER) ||
+			  (pmd_flags(pmd) & _PAGE_RW)) ?
+			  _PAGE_DIRTY_HW:_PAGE_DIRTY_SW;
+	return pmd_set_flags(pmd, dirty | _PAGE_SOFT_DIRTY);
+}
+
+#ifdef CONFIG_ARCH_HAS_SHSTK
+static inline pmd_t pmd_mkdirty_shstk(pmd_t pmd)
+{
+	pmd = pmd_clear_flags(pmd, _PAGE_DIRTY_SW);
 	return pmd_set_flags(pmd, _PAGE_DIRTY_HW | _PAGE_SOFT_DIRTY);
 }
 
+static inline bool is_shstk_pmd(pmd_t pmd)
+{
+	pmdval_t val;
+
+	val = pmd_flags(pmd) & (_PAGE_RW | _PAGE_DIRTY_HW);
+	return (val == _PAGE_DIRTY_HW);
+}
+#endif
+
 static inline pmd_t pmd_mkdevmap(pmd_t pmd)
 {
 	return pmd_set_flags(pmd, _PAGE_DEVMAP);
@@ -397,6 +465,7 @@ static inline pmd_t pmd_mkyoung(pmd_t pmd)
 
 static inline pmd_t pmd_mkwrite(pmd_t pmd)
 {
+	pmd = pmd_move_flags(pmd, _PAGE_DIRTY_SW, _PAGE_DIRTY_HW);
 	return pmd_set_flags(pmd, _PAGE_RW);
 }
 
@@ -419,6 +488,20 @@ static inline pud_t pud_clear_flags(pud_t pud, pudval_t clear)
 	return native_make_pud(v & ~clear);
 }
 
+#if defined(CONFIG_X86_INTEL_SHADOW_STACK_USER)
+static inline pud_t pud_move_flags(pud_t pud, pudval_t from, pudval_t to)
+{
+	if (pud_flags(pud) & from)
+		pud = pud_set_flags(pud_clear_flags(pud, from), to);
+	return pud;
+}
+#else
+static inline pud_t pud_move_flags(pud_t pud, pudval_t from, pudval_t to)
+{
+	return pud;
+}
+#endif
+
 static inline pud_t pud_mkold(pud_t pud)
 {
 	return pud_clear_flags(pud, _PAGE_ACCESSED);
@@ -426,17 +509,22 @@ static inline pud_t pud_mkold(pud_t pud)
 
 static inline pud_t pud_mkclean(pud_t pud)
 {
-	return pud_clear_flags(pud, _PAGE_DIRTY);
+	return pud_clear_flags(pud, _PAGE_DIRTY_BITS);
 }
 
 static inline pud_t pud_wrprotect(pud_t pud)
 {
+	pud = pud_move_flags(pud, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
 	return pud_clear_flags(pud, _PAGE_RW);
 }
 
 static inline pud_t pud_mkdirty(pud_t pud)
 {
-	return pud_set_flags(pud, _PAGE_DIRTY_HW | _PAGE_SOFT_DIRTY);
+	pudval_t dirty = (!IS_ENABLED(CONFIG_X86_INTEL_SHSTK_USER) ||
+			  (pud_flags(pud) & _PAGE_RW)) ?
+			  _PAGE_DIRTY_HW:_PAGE_DIRTY_SW;
+
+	return pud_set_flags(pud, dirty | _PAGE_SOFT_DIRTY);
 }
 
 static inline pud_t pud_mkdevmap(pud_t pud)
@@ -456,6 +544,7 @@ static inline pud_t pud_mkyoung(pud_t pud)
 
 static inline pud_t pud_mkwrite(pud_t pud)
 {
+	pud = pud_move_flags(pud, _PAGE_DIRTY_SW, _PAGE_DIRTY_HW);
 	return pud_set_flags(pud, _PAGE_RW);
 }
 
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 806abf530f50..4bad635beaab 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -23,6 +23,7 @@
 #define _PAGE_BIT_SOFTW2	10	/* " */
 #define _PAGE_BIT_SOFTW3	11	/* " */
 #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
+#define _PAGE_BIT_SOFTW5	57	/* available for programmer */
 #define _PAGE_BIT_SOFTW4	58	/* available for programmer */
 #define _PAGE_BIT_PKEY_BIT0	59	/* Protection Keys, bit 1/4 */
 #define _PAGE_BIT_PKEY_BIT1	60	/* Protection Keys, bit 2/4 */
@@ -34,6 +35,7 @@
 #define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
 #define _PAGE_BIT_DEVMAP	_PAGE_BIT_SOFTW4
+#define _PAGE_BIT_DIRTY_SW	_PAGE_BIT_SOFTW5 /* was written to */
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
@@ -108,6 +110,14 @@
 #define _PAGE_DEVMAP	(_AT(pteval_t, 0))
 #endif
 
+#if defined(CONFIG_X86_INTEL_SHADOW_STACK_USER)
+#define _PAGE_DIRTY_SW	(_AT(pteval_t, 1) << _PAGE_BIT_DIRTY_SW)
+#else
+#define _PAGE_DIRTY_SW	(_AT(pteval_t, 0))
+#endif
+
+#define _PAGE_DIRTY_BITS (_PAGE_DIRTY_HW | _PAGE_DIRTY_SW)
+
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
 #define _PAGE_TABLE_NOENC	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |\
@@ -121,9 +131,9 @@
  * instance, and is *not* included in this mask since
  * pte_modify() does modify it.
  */
-#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
+#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |			\
 			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY_HW |	\
-			 _PAGE_SOFT_DIRTY)
+			 _PAGE_DIRTY_SW | _PAGE_SOFT_DIRTY)
 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
 
 /*
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index f59639afaa39..4ee683c9ac19 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1097,4 +1097,25 @@ static inline void init_espfix_bsp(void) { }
 #endif
 #endif
 
+#ifndef CONFIG_ARCH_HAS_SHSTK
+static inline pte_t pte_mkdirty_shstk(pte_t pte)
+{
+	return pte;
+}
+static inline bool is_shstk_pte(pte_t pte)
+{
+	return false;
+}
+
+static inline pmd_t pmd_mkdirty_shstk(pmd_t pmd)
+{
+	return pmd;
+}
+
+static inline bool is_shstk_pmd(pmd_t pmd)
+{
+	return false;
+}
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
-- 
2.17.1
