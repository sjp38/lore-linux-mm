Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3909D6B000D
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 13:46:55 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so6291967pgt.6
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:46:55 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id w66si7115741pfi.23.2018.03.23.10.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 10:46:53 -0700 (PDT)
Subject: [PATCH 03/11] x86/mm: introduce "default" kernel PTE mask
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 23 Mar 2018 10:44:52 -0700
References: <20180323174447.55F35636@viggo.jf.intel.com>
In-Reply-To: <20180323174447.55F35636@viggo.jf.intel.com>
Message-Id: <20180323174452.8617EBB0@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The __PAGE_KERNEL_* page permissions are "raw".  They contain bits
that may or may not be supported on the current processor.  They need
to be filtered by a mask (currently __supported_pte_mask) to turn them
into a value that we can actually set in a PTE.

These __PAGE_KERNEL_* values all contain _PAGE_GLOBAL.  But, with PTI,
we want to be able to support _PAGE_GLOBAL (have the bit set in
__supported_pte_mask) but not have it appear in any of these masks by
default.

This patch creates a new mask, __default_kernel_pte_mask, and applies
it when creating all of the PAGE_KERNEL_* masks.  This makes
PAGE_KERNEL_* safe to use anywhere (they only contain supported bits).
It also ensures that PAGE_KERNEL_* contains _PAGE_GLOBAL on PTI=n
kernels but clears _PAGE_GLOBAL when PTI=y.

We also make __default_kernel_pte_mask a non-GPL exported symbol
because there are plenty of driver-available interfaces that take
PAGE_KERNEL_* permissions.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org
Cc: Nadav Amit <namit@vmware.com>
---

 b/arch/x86/include/asm/pgtable_types.h |   27 +++++++++++++++------------
 b/arch/x86/mm/init.c                   |    6 ++++++
 b/arch/x86/mm/init_32.c                |    8 +++++++-
 b/arch/x86/mm/init_64.c                |    5 +++++
 4 files changed, 33 insertions(+), 13 deletions(-)

diff -puN arch/x86/include/asm/pgtable_types.h~KERN-pgprot-default arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~KERN-pgprot-default	2018-03-21 16:31:57.339192320 -0700
+++ b/arch/x86/include/asm/pgtable_types.h	2018-03-21 16:31:57.348192320 -0700
@@ -196,19 +196,21 @@ enum page_cache_mode {
 #define __PAGE_KERNEL_NOENC	(__PAGE_KERNEL)
 #define __PAGE_KERNEL_NOENC_WP	(__PAGE_KERNEL_WP)
 
-#define PAGE_KERNEL		__pgprot(__PAGE_KERNEL | _PAGE_ENC)
-#define PAGE_KERNEL_NOENC	__pgprot(__PAGE_KERNEL)
-#define PAGE_KERNEL_RO		__pgprot(__PAGE_KERNEL_RO | _PAGE_ENC)
-#define PAGE_KERNEL_EXEC	__pgprot(__PAGE_KERNEL_EXEC | _PAGE_ENC)
-#define PAGE_KERNEL_EXEC_NOENC	__pgprot(__PAGE_KERNEL_EXEC)
-#define PAGE_KERNEL_RX		__pgprot(__PAGE_KERNEL_RX | _PAGE_ENC)
-#define PAGE_KERNEL_NOCACHE	__pgprot(__PAGE_KERNEL_NOCACHE | _PAGE_ENC)
-#define PAGE_KERNEL_LARGE	__pgprot(__PAGE_KERNEL_LARGE | _PAGE_ENC)
-#define PAGE_KERNEL_LARGE_EXEC	__pgprot(__PAGE_KERNEL_LARGE_EXEC | _PAGE_ENC)
-#define PAGE_KERNEL_VVAR	__pgprot(__PAGE_KERNEL_VVAR | _PAGE_ENC)
+#define default_pgprot(x)	__pgprot((x) & __default_kernel_pte_mask)
 
-#define PAGE_KERNEL_IO		__pgprot(__PAGE_KERNEL_IO)
-#define PAGE_KERNEL_IO_NOCACHE	__pgprot(__PAGE_KERNEL_IO_NOCACHE)
+#define PAGE_KERNEL		default_pgprot(__PAGE_KERNEL | _PAGE_ENC)
+#define PAGE_KERNEL_NOENC	default_pgprot(__PAGE_KERNEL)
+#define PAGE_KERNEL_RO		default_pgprot(__PAGE_KERNEL_RO | _PAGE_ENC)
+#define PAGE_KERNEL_EXEC	default_pgprot(__PAGE_KERNEL_EXEC | _PAGE_ENC)
+#define PAGE_KERNEL_EXEC_NOENC	default_pgprot(__PAGE_KERNEL_EXEC)
+#define PAGE_KERNEL_RX		default_pgprot(__PAGE_KERNEL_RX | _PAGE_ENC)
+#define PAGE_KERNEL_NOCACHE	default_pgprot(__PAGE_KERNEL_NOCACHE | _PAGE_ENC)
+#define PAGE_KERNEL_LARGE	default_pgprot(__PAGE_KERNEL_LARGE | _PAGE_ENC)
+#define PAGE_KERNEL_LARGE_EXEC	default_pgprot(__PAGE_KERNEL_LARGE_EXEC | _PAGE_ENC)
+#define PAGE_KERNEL_VVAR	default_pgprot(__PAGE_KERNEL_VVAR | _PAGE_ENC)
+
+#define PAGE_KERNEL_IO		default_pgprot(__PAGE_KERNEL_IO)
+#define PAGE_KERNEL_IO_NOCACHE	default_pgprot(__PAGE_KERNEL_IO_NOCACHE)
 
 #endif	/* __ASSEMBLY__ */
 
@@ -483,6 +485,7 @@ static inline pgprot_t pgprot_large_2_4k
 typedef struct page *pgtable_t;
 
 extern pteval_t __supported_pte_mask;
+extern pteval_t __default_kernel_pte_mask;
 extern void set_nx(void);
 extern int nx_enabled;
 
diff -puN arch/x86/mm/init_32.c~KERN-pgprot-default arch/x86/mm/init_32.c
--- a/arch/x86/mm/init_32.c~KERN-pgprot-default	2018-03-21 16:31:57.341192320 -0700
+++ b/arch/x86/mm/init_32.c	2018-03-21 16:31:57.348192320 -0700
@@ -558,8 +558,14 @@ static void __init pagetable_init(void)
 	permanent_kmaps_init(pgd_base);
 }
 
-pteval_t __supported_pte_mask __read_mostly = ~(_PAGE_NX | _PAGE_GLOBAL);
+#define DEFAULT_PTE_MASK ~(_PAGE_NX | _PAGE_GLOBAL)
+/* Bits supported by the hardware: */
+pteval_t __supported_pte_mask __read_mostly = DEFAULT_PTE_MASK;
+/* Bits allowed in normal kernel mappings: */
+pteval_t __default_kernel_pte_mask __read_mostly = DEFAULT_PTE_MASK;
 EXPORT_SYMBOL_GPL(__supported_pte_mask);
+/* Used in PAGE_KERNEL_* macros which are reasonably used out-of-tree: */
+EXPORT_SYMBOL(__default_kernel_pte_mask);
 
 /* user-defined highmem size */
 static unsigned int highmem_pages = -1;
diff -puN arch/x86/mm/init_64.c~KERN-pgprot-default arch/x86/mm/init_64.c
--- a/arch/x86/mm/init_64.c~KERN-pgprot-default	2018-03-21 16:31:57.343192320 -0700
+++ b/arch/x86/mm/init_64.c	2018-03-21 16:31:57.349192320 -0700
@@ -65,8 +65,13 @@
  * around without checking the pgd every time.
  */
 
+/* Bits supported by the hardware: */
 pteval_t __supported_pte_mask __read_mostly = ~0;
+/* Bits allowed in normal kernel mappings: */
+pteval_t __default_kernel_pte_mask __read_mostly = ~0;
 EXPORT_SYMBOL_GPL(__supported_pte_mask);
+/* Used in PAGE_KERNEL_* macros which are reasonably used out-of-tree: */
+EXPORT_SYMBOL(__default_kernel_pte_mask);
 
 int force_personality32;
 
diff -puN arch/x86/mm/init.c~KERN-pgprot-default arch/x86/mm/init.c
--- a/arch/x86/mm/init.c~KERN-pgprot-default	2018-03-21 16:31:57.345192320 -0700
+++ b/arch/x86/mm/init.c	2018-03-21 16:31:57.349192320 -0700
@@ -190,6 +190,12 @@ static void __init probe_page_size_mask(
 		enable_global_pages();
 	}
 
+	/* By the default is everything supported: */
+	__default_kernel_pte_mask = __supported_pte_mask;
+	/* Except when with PTI where the kernel is mostly non-Global: */
+	if (cpu_feature_enabled(X86_FEATURE_PTI))
+		__default_kernel_pte_mask &= ~_PAGE_GLOBAL;
+
 	/* Enable 1 GB linear kernel mappings if available: */
 	if (direct_gbpages && boot_cpu_has(X86_FEATURE_GBPAGES)) {
 		printk(KERN_INFO "Using GB pages for direct mapping\n");
_
