Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 56BE7440D29
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:25 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a19so3970724pfa.23
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:25 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f13si9581665pgn.698.2017.11.10.11.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:24 -0800 (PST)
Subject: [PATCH 04/30] x86, kaiser: disable global pages by default with KAISER
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:05 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193105.02A90543@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, bp@suse.de, tglx@linutronix.de, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

Global pages stay in the TLB across context switches.  Since all contexts
share the same kernel mapping, these mappings are marked as global pages
so kernel entries in the TLB are not flushed out on a context switch.

But, even having these entries in the TLB opens up something that an
attacker can use [1].

That means that even when KAISER switches page tables on return to user
space the global pages would stay in the TLB cache.

Disable global pages so that kernel TLB entries can be flushed before
returning to user space. This way, all accesses to kernel addresses from
userspace result in a TLB miss independent of the existence of a kernel
mapping.

Replace _PAGE_GLOBAL by __PAGE_KERNEL_GLOBAL and keep _PAGE_GLOBAL
available so that it can still be used for a few selected kernel mappings
which must be visible to userspace, when KAISER is enabled, like the
entry/exit code and data.

1. The double-page-fault attack:
   http://www.ieee-security.org/TC/SP2013/papers/4977a191.pdf

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/pgtable_types.h |   14 +++++++++++++-
 b/arch/x86/mm/pageattr.c               |   16 ++++++++--------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff -puN arch/x86/include/asm/pgtable_types.h~kaiser-prep-disable-global-pages arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~kaiser-prep-disable-global-pages	2017-11-10 11:22:06.621244956 -0800
+++ b/arch/x86/include/asm/pgtable_types.h	2017-11-10 11:22:06.626244956 -0800
@@ -179,8 +179,20 @@ enum page_cache_mode {
 #define PAGE_READONLY_EXEC	__pgprot(_PAGE_PRESENT | _PAGE_USER |	\
 					 _PAGE_ACCESSED)
 
+/*
+ * Disable global pages for anything using the default
+ * __PAGE_KERNEL* macros.  PGE will still be enabled
+ * and _PAGE_GLOBAL may still be used carefully.
+ */
+#ifdef CONFIG_KAISER
+#define __PAGE_KERNEL_GLOBAL	0
+#else
+#define __PAGE_KERNEL_GLOBAL	_PAGE_GLOBAL
+#endif
+
 #define __PAGE_KERNEL_EXEC						\
-	(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_GLOBAL)
+	(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY | _PAGE_ACCESSED |	\
+	 __PAGE_KERNEL_GLOBAL)
 #define __PAGE_KERNEL		(__PAGE_KERNEL_EXEC | _PAGE_NX)
 
 #define __PAGE_KERNEL_RO		(__PAGE_KERNEL & ~_PAGE_RW)
diff -puN arch/x86/mm/pageattr.c~kaiser-prep-disable-global-pages arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~kaiser-prep-disable-global-pages	2017-11-10 11:22:06.623244956 -0800
+++ b/arch/x86/mm/pageattr.c	2017-11-10 11:22:06.627244956 -0800
@@ -585,9 +585,9 @@ try_preserve_large_page(pte_t *kpte, uns
 	 * for the ancient hardware that doesn't support it.
 	 */
 	if (pgprot_val(req_prot) & _PAGE_PRESENT)
-		pgprot_val(req_prot) |= _PAGE_PSE | _PAGE_GLOBAL;
+		pgprot_val(req_prot) |= _PAGE_PSE | __PAGE_KERNEL_GLOBAL;
 	else
-		pgprot_val(req_prot) &= ~(_PAGE_PSE | _PAGE_GLOBAL);
+		pgprot_val(req_prot) &= ~(_PAGE_PSE | __PAGE_KERNEL_GLOBAL);
 
 	req_prot = canon_pgprot(req_prot);
 
@@ -705,9 +705,9 @@ __split_large_page(struct cpa_data *cpa,
 	 * for the ancient hardware that doesn't support it.
 	 */
 	if (pgprot_val(ref_prot) & _PAGE_PRESENT)
-		pgprot_val(ref_prot) |= _PAGE_GLOBAL;
+		pgprot_val(ref_prot) |= __PAGE_KERNEL_GLOBAL;
 	else
-		pgprot_val(ref_prot) &= ~_PAGE_GLOBAL;
+		pgprot_val(ref_prot) &= ~__PAGE_KERNEL_GLOBAL;
 
 	/*
 	 * Get the target pfn from the original entry:
@@ -938,9 +938,9 @@ static void populate_pte(struct cpa_data
 	 * support it.
 	 */
 	if (pgprot_val(pgprot) & _PAGE_PRESENT)
-		pgprot_val(pgprot) |= _PAGE_GLOBAL;
+		pgprot_val(pgprot) |= __PAGE_KERNEL_GLOBAL;
 	else
-		pgprot_val(pgprot) &= ~_PAGE_GLOBAL;
+		pgprot_val(pgprot) &= ~__PAGE_KERNEL_GLOBAL;
 
 	pgprot = canon_pgprot(pgprot);
 
@@ -1242,9 +1242,9 @@ repeat:
 		 * support it.
 		 */
 		if (pgprot_val(new_prot) & _PAGE_PRESENT)
-			pgprot_val(new_prot) |= _PAGE_GLOBAL;
+			pgprot_val(new_prot) |= __PAGE_KERNEL_GLOBAL;
 		else
-			pgprot_val(new_prot) &= ~_PAGE_GLOBAL;
+			pgprot_val(new_prot) &= ~__PAGE_KERNEL_GLOBAL;
 
 		/*
 		 * We need to keep the pfn from the existing PTE,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
