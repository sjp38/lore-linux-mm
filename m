Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA1D6B0253
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 18:26:13 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u83so9402883wmb.8
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 15:26:13 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h15si22249905wrb.551.2017.11.26.15.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 15:26:12 -0800 (PST)
Message-Id: <20171126232414.393912629@linutronix.de>
Date: Mon, 27 Nov 2017 00:14:05 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V2 2/5] x86/kaiser: Simplify disabling of global pages
References: <20171126231403.657575796@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-kaiser--Make-page-global-disabling-sane.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

The current way of disabling global pages at compile time prevents boot
time disabling of kaiser and creates unnecessary indirections.

Global pages can be supressed by __supported_pte_mask as well. The shadow
mappings set PAGE_GLOBAL for the minimal kernel mappings which are required
for entry/exit. These mappings are setup manually so the filtering does not
take place.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/pgtable_types.h |   16 +---------------
 arch/x86/mm/init.c                   |   13 ++++++++++---
 arch/x86/mm/pageattr.c               |   16 ++++++++--------
 3 files changed, 19 insertions(+), 26 deletions(-)

--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -191,23 +191,9 @@ enum page_cache_mode {
 #define PAGE_READONLY_EXEC	__pgprot(_PAGE_PRESENT | _PAGE_USER |	\
 					 _PAGE_ACCESSED)
 
-/*
- * Disable global pages for anything using the default
- * __PAGE_KERNEL* macros.
- *
- * PGE will still be enabled and _PAGE_GLOBAL may still be used carefully
- * for a few selected kernel mappings which must be visible to userspace,
- * when KAISER is enabled, like the entry/exit code and data.
- */
-#ifdef CONFIG_KAISER
-#define __PAGE_KERNEL_GLOBAL	0
-#else
-#define __PAGE_KERNEL_GLOBAL	_PAGE_GLOBAL
-#endif
-
 #define __PAGE_KERNEL_EXEC						\
 	(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY | _PAGE_ACCESSED |	\
-	 __PAGE_KERNEL_GLOBAL)
+	 _PAGE_GLOBAL)
 #define __PAGE_KERNEL		(__PAGE_KERNEL_EXEC | _PAGE_NX)
 
 #define __PAGE_KERNEL_RO		(__PAGE_KERNEL & ~_PAGE_RW)
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -161,6 +161,13 @@ struct map_range {
 
 static int page_size_mask;
 
+static void enable_global_pages(void)
+{
+#ifndef CONFIG_KAISER
+	__supported_pte_mask |= _PAGE_GLOBAL;
+#endif
+}
+
 static void __init probe_page_size_mask(void)
 {
 	/*
@@ -179,11 +186,11 @@ static void __init probe_page_size_mask(
 		cr4_set_bits_and_update_boot(X86_CR4_PSE);
 
 	/* Enable PGE if available */
+	__supported_pte_mask |= _PAGE_GLOBAL;
 	if (boot_cpu_has(X86_FEATURE_PGE)) {
 		cr4_set_bits_and_update_boot(X86_CR4_PGE);
-		__supported_pte_mask |= _PAGE_GLOBAL;
-	} else
-		__supported_pte_mask &= ~_PAGE_GLOBAL;
+		enable_global_pages();
+	}
 
 	/* Enable 1 GB linear kernel mappings if available: */
 	if (direct_gbpages && boot_cpu_has(X86_FEATURE_GBPAGES)) {
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -585,9 +585,9 @@ try_preserve_large_page(pte_t *kpte, uns
 	 * for the ancient hardware that doesn't support it.
 	 */
 	if (pgprot_val(req_prot) & _PAGE_PRESENT)
-		pgprot_val(req_prot) |= _PAGE_PSE | __PAGE_KERNEL_GLOBAL;
+		pgprot_val(req_prot) |= _PAGE_PSE | _PAGE_GLOBAL;
 	else
-		pgprot_val(req_prot) &= ~(_PAGE_PSE | __PAGE_KERNEL_GLOBAL);
+		pgprot_val(req_prot) &= ~(_PAGE_PSE | _PAGE_GLOBAL);
 
 	req_prot = canon_pgprot(req_prot);
 
@@ -705,9 +705,9 @@ static int
 	 * for the ancient hardware that doesn't support it.
 	 */
 	if (pgprot_val(ref_prot) & _PAGE_PRESENT)
-		pgprot_val(ref_prot) |= __PAGE_KERNEL_GLOBAL;
+		pgprot_val(ref_prot) |= _PAGE_GLOBAL;
 	else
-		pgprot_val(ref_prot) &= ~__PAGE_KERNEL_GLOBAL;
+		pgprot_val(ref_prot) &= ~_PAGE_GLOBAL;
 
 	/*
 	 * Get the target pfn from the original entry:
@@ -938,9 +938,9 @@ static void populate_pte(struct cpa_data
 	 * support it.
 	 */
 	if (pgprot_val(pgprot) & _PAGE_PRESENT)
-		pgprot_val(pgprot) |= __PAGE_KERNEL_GLOBAL;
+		pgprot_val(pgprot) |= _PAGE_GLOBAL;
 	else
-		pgprot_val(pgprot) &= ~__PAGE_KERNEL_GLOBAL;
+		pgprot_val(pgprot) &= ~_PAGE_GLOBAL;
 
 	pgprot = canon_pgprot(pgprot);
 
@@ -1242,9 +1242,9 @@ static int __change_page_attr(struct cpa
 		 * support it.
 		 */
 		if (pgprot_val(new_prot) & _PAGE_PRESENT)
-			pgprot_val(new_prot) |= __PAGE_KERNEL_GLOBAL;
+			pgprot_val(new_prot) |= _PAGE_GLOBAL;
 		else
-			pgprot_val(new_prot) &= ~__PAGE_KERNEL_GLOBAL;
+			pgprot_val(new_prot) &= ~_PAGE_GLOBAL;
 
 		/*
 		 * We need to keep the pfn from the existing PTE,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
