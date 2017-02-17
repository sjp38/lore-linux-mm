Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB9F14405E4
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 09:14:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so62706887pfb.7
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:14:13 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q11si5933430pgf.297.2017.02.17.06.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 06:14:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 23/33] x86/paravirt: make paravirt code support 5-level paging
Date: Fri, 17 Feb 2017 17:13:18 +0300
Message-Id: <20170217141328.164563-24-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Add operations to allocate/release p4ds.

TODO: cover XEN.

Not-yet-Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/paravirt.h       | 44 +++++++++++++++++++++++++++++++----
 arch/x86/include/asm/paravirt_types.h |  7 +++++-
 arch/x86/include/asm/pgalloc.h        |  2 ++
 arch/x86/kernel/paravirt.c            |  9 +++++--
 4 files changed, 55 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 432c6e730ed1..7605910598a6 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -357,6 +357,16 @@ static inline void paravirt_release_pud(unsigned long pfn)
 	PVOP_VCALL1(pv_mmu_ops.release_pud, pfn);
 }
 
+static inline void paravirt_alloc_p4d(struct mm_struct *mm, unsigned long pfn)
+{
+	PVOP_VCALL2(pv_mmu_ops.alloc_p4d, mm, pfn);
+}
+
+static inline void paravirt_release_p4d(unsigned long pfn)
+{
+	PVOP_VCALL1(pv_mmu_ops.release_p4d, pfn);
+}
+
 static inline void pte_update(struct mm_struct *mm, unsigned long addr,
 			      pte_t *ptep)
 {
@@ -571,14 +581,35 @@ static inline void set_p4d(p4d_t *p4dp, p4d_t p4d)
 			    val);
 }
 
-static inline void p4d_clear(p4d_t *p4dp)
+#if CONFIG_PGTABLE_LEVELS >= 5
+
+static inline p4d_t __p4d(p4dval_t val)
 {
-	set_p4d(p4dp, __p4d(0));
+	p4dval_t ret;
+
+	if (sizeof(p4dval_t) > sizeof(long))
+		ret = PVOP_CALLEE2(p4dval_t, pv_mmu_ops.make_p4d,
+				   val, (u64)val >> 32);
+	else
+		ret = PVOP_CALLEE1(p4dval_t, pv_mmu_ops.make_p4d,
+				   val);
+
+	return (p4d_t) { ret };
 }
 
-#if CONFIG_PGTABLE_LEVELS >= 5
+static inline p4dval_t p4d_val(p4d_t p4d)
+{
+	p4dval_t ret;
+
+	if (sizeof(p4dval_t) > sizeof(long))
+		ret =  PVOP_CALLEE2(p4dval_t, pv_mmu_ops.p4d_val,
+				    p4d.p4d, (u64)p4d.p4d >> 32);
+	else
+		ret =  PVOP_CALLEE1(p4dval_t, pv_mmu_ops.p4d_val,
+				    p4d.p4d);
 
-#error FIXME
+	return ret;
+}
 
 static inline void set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
@@ -599,6 +630,11 @@ static inline void pgd_clear(pgd_t *pgdp)
 
 #endif  /* CONFIG_PGTABLE_LEVELS == 5 */
 
+static inline void p4d_clear(p4d_t *p4dp)
+{
+	set_p4d(p4dp, __p4d(0));
+}
+
 #endif	/* CONFIG_PGTABLE_LEVELS == 4 */
 
 #endif	/* CONFIG_PGTABLE_LEVELS >= 3 */
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
index 3982c200845f..2dfbb7cedbaa 100644
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -238,9 +238,11 @@ struct pv_mmu_ops {
 	void (*alloc_pte)(struct mm_struct *mm, unsigned long pfn);
 	void (*alloc_pmd)(struct mm_struct *mm, unsigned long pfn);
 	void (*alloc_pud)(struct mm_struct *mm, unsigned long pfn);
+	void (*alloc_p4d)(struct mm_struct *mm, unsigned long pfn);
 	void (*release_pte)(unsigned long pfn);
 	void (*release_pmd)(unsigned long pfn);
 	void (*release_pud)(unsigned long pfn);
+	void (*release_p4d)(unsigned long pfn);
 
 	/* Pagetable manipulation functions */
 	void (*set_pte)(pte_t *ptep, pte_t pteval);
@@ -284,7 +286,10 @@ struct pv_mmu_ops {
 	void (*set_p4d)(p4d_t *p4dp, p4d_t p4dval);
 
 #if CONFIG_PGTABLE_LEVELS >= 5
-#error FIXME
+	struct paravirt_callee_save p4d_val;
+	struct paravirt_callee_save make_p4d;
+
+	void (*set_pgd)(pgd_t *pgdp, pgd_t pgdval);
 #endif	/* CONFIG_PGTABLE_LEVELS >= 5 */
 
 #endif	/* CONFIG_PGTABLE_LEVELS >= 4 */
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index 2f585054c63c..b2d0cd8288aa 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -17,9 +17,11 @@ static inline void paravirt_alloc_pmd(struct mm_struct *mm, unsigned long pfn)	{
 static inline void paravirt_alloc_pmd_clone(unsigned long pfn, unsigned long clonepfn,
 					    unsigned long start, unsigned long count) {}
 static inline void paravirt_alloc_pud(struct mm_struct *mm, unsigned long pfn)	{}
+static inline void paravirt_alloc_p4d(struct mm_struct *mm, unsigned long pfn)	{}
 static inline void paravirt_release_pte(unsigned long pfn) {}
 static inline void paravirt_release_pmd(unsigned long pfn) {}
 static inline void paravirt_release_pud(unsigned long pfn) {}
+static inline void paravirt_release_p4d(unsigned long pfn) {}
 #endif
 
 /*
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
index f8aedc112d5e..974359f83cff 100644
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -405,9 +405,11 @@ struct pv_mmu_ops pv_mmu_ops __ro_after_init = {
 	.alloc_pte = paravirt_nop,
 	.alloc_pmd = paravirt_nop,
 	.alloc_pud = paravirt_nop,
+	.alloc_p4d = paravirt_nop,
 	.release_pte = paravirt_nop,
 	.release_pmd = paravirt_nop,
 	.release_pud = paravirt_nop,
+	.release_p4d = paravirt_nop,
 
 	.set_pte = native_set_pte,
 	.set_pte_at = native_set_pte_at,
@@ -436,8 +438,11 @@ struct pv_mmu_ops pv_mmu_ops __ro_after_init = {
 	.set_p4d = native_set_p4d,
 
 #if CONFIG_PGTABLE_LEVELS >= 5
-#error FIXME
-#endif /* CONFIG_PGTABLE_LEVELS >= 4 */
+	.p4d_val = PTE_IDENT,
+	.make_p4d = PTE_IDENT,
+
+	.set_pgd = native_set_pgd,
+#endif /* CONFIG_PGTABLE_LEVELS >= 5 */
 #endif /* CONFIG_PGTABLE_LEVELS >= 4 */
 #endif /* CONFIG_PGTABLE_LEVELS >= 3 */
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
