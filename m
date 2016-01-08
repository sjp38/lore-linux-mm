Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8D7828E9
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:48 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id q63so16321773pfb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:48 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id fd9si19601263pac.80.2016.01.08.15.15.47
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:47 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 08/13] x86/mm: Teach CR3 readers about PCID
Date: Fri,  8 Jan 2016 15:15:26 -0800
Message-Id: <a60b1372af0e506248e6af0cc057dc61eba1c470.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

The kernel has several code paths that read CR3.  Most of them assume that
CR3 contains the PGD's physical address, whereas some of them awkwardly
use PHYSICAL_PAGE_MASK to mask off low bits.

Add explicit mask macros for CR3 and convert all of the CR3 readers.
This will keep them from breaking when PCID is enabled.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h | 8 ++++++++
 arch/x86/kernel/head64.c        | 3 ++-
 arch/x86/mm/fault.c             | 8 ++++----
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 4eba5164430d..3d905f12cda9 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -48,6 +48,14 @@ static inline void invpcid_flush_all_nonglobals(void)
 	__invpcid(0, 0, 3);
 }
 
+#ifdef CONFIG_X86_64
+#define CR3_ADDR_MASK 0x7FFFFFFFFFFFF000ull
+#define CR3_PCID_MASK 0xFFFull
+#else
+#define CR3_ADDR_MASK 0xFFFFF000ull
+#define CR3_PCID_MASK 0ull
+#endif
+
 #ifdef CONFIG_PARAVIRT
 #include <asm/paravirt.h>
 #else
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index f129a9af6357..3d075ac01a47 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -60,7 +60,8 @@ int __init early_make_pgtable(unsigned long address)
 	pmdval_t pmd, *pmd_p;
 
 	/* Invalid address or early pgt is done ?  */
-	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
+	if (physaddr >= MAXMEM ||
+	    (read_cr3() & CR3_ADDR_MASK) != __pa_nodebug(early_level4_pgt))
 		return -1;
 
 again:
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index eef44d9a3f77..9ceae2dc9be1 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -282,7 +282,7 @@ static noinline int vmalloc_fault(unsigned long address)
 	 * Do _not_ use "current" here. We might be inside
 	 * an interrupt in the middle of a task switch..
 	 */
-	pgd_paddr = read_cr3();
+	pgd_paddr = read_cr3() & CR3_ADDR_MASK;
 	pmd_k = vmalloc_sync_one(__va(pgd_paddr), address);
 	if (!pmd_k)
 		return -1;
@@ -321,7 +321,7 @@ static bool low_pfn(unsigned long pfn)
 
 static void dump_pagetable(unsigned long address)
 {
-	pgd_t *base = __va(read_cr3());
+	pgd_t *base = __va(read_cr3() & CR3_ADDR_MASK);
 	pgd_t *pgd = &base[pgd_index(address)];
 	pmd_t *pmd;
 	pte_t *pte;
@@ -459,7 +459,7 @@ static int bad_address(void *p)
 
 static void dump_pagetable(unsigned long address)
 {
-	pgd_t *base = __va(read_cr3() & PHYSICAL_PAGE_MASK);
+	pgd_t *base = __va(read_cr3() & CR3_ADDR_MASK);
 	pgd_t *pgd = base + pgd_index(address);
 	pud_t *pud;
 	pmd_t *pmd;
@@ -595,7 +595,7 @@ show_fault_oops(struct pt_regs *regs, unsigned long error_code,
 		pgd_t *pgd;
 		pte_t *pte;
 
-		pgd = __va(read_cr3() & PHYSICAL_PAGE_MASK);
+		pgd = __va(read_cr3() & CR3_ADDR_MASK);
 		pgd += pgd_index(address);
 
 		pte = lookup_address_in_pgd(pgd, address, &level);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
