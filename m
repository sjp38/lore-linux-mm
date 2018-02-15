Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B28F6B0006
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:25:21 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i11so3924135pgq.10
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:25:21 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n7si2517379pga.670.2018.02.15.05.25.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 05:25:19 -0800 (PST)
Subject: [PATCH 2/3] x86/mm: introduce __PAGE_KERNEL_GLOBAL
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 15 Feb 2018 05:20:55 -0800
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
In-Reply-To: <20180215132053.6C9B48C8@viggo.jf.intel.com>
Message-Id: <20180215132055.F341C31E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

Kernel mappings are historically _PAGE_GLOBAL.  But, with PTI, we do not
want them to be _PAGE_GLOBAL.  We currently accomplish this by simply
clearing _PAGE_GLOBAL from the suppotred mask which ensures it is
cleansed from many of our PTE construction sites:

        if (!static_cpu_has(X86_FEATURE_PTI))
	                __supported_pte_mask |= _PAGE_GLOBAL;

But, this also means that we now get *no* opportunity to use global
pages with PTI, even for data which is shared such as the cpu_entry_area
and entry/exit text.

This patch introduces a new mask: __PAGE_KERNEL_GLOBAL.  This mask
can be thought of as the default global bit value when creating kernel
mappings.  We make it _PAGE_GLOBAL when PTI=n, but 0 when PTI=y.  This
ensures that on PTI kernels, all of the __PAGE_KERNEL_* users will not
get _PAGE_GLOBAL.

This also restores _PAGE_GLOBAL to __supported_pte_mask, allowing it
to be set in the first place.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/pgtable_types.h |    9 ++++++++-
 b/arch/x86/mm/init.c                   |    8 +-------
 b/arch/x86/mm/pageattr.c               |    9 +++++----
 3 files changed, 14 insertions(+), 12 deletions(-)

diff -puN arch/x86/include/asm/pgtable_types.h~kpti-no-global-for-kernel-mappings arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~kpti-no-global-for-kernel-mappings	2018-02-13 15:17:56.144210060 -0800
+++ b/arch/x86/include/asm/pgtable_types.h	2018-02-13 15:17:56.152210060 -0800
@@ -180,8 +180,15 @@ enum page_cache_mode {
 #define PAGE_READONLY_EXEC	__pgprot(_PAGE_PRESENT | _PAGE_USER |	\
 					 _PAGE_ACCESSED)
 
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+#define __PAGE_KERNEL_GLOBAL		0
+#else
+#define __PAGE_KERNEL_GLOBAL		_PAGE_GLOBAL
+#endif
+
 #define __PAGE_KERNEL_EXEC						\
-	(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_GLOBAL)
+	(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY | _PAGE_ACCESSED | 	\
+	 __PAGE_KERNEL_GLOBAL)
 #define __PAGE_KERNEL		(__PAGE_KERNEL_EXEC | _PAGE_NX)
 
 #define __PAGE_KERNEL_RO		(__PAGE_KERNEL & ~_PAGE_RW)
diff -puN arch/x86/mm/init.c~kpti-no-global-for-kernel-mappings arch/x86/mm/init.c
--- a/arch/x86/mm/init.c~kpti-no-global-for-kernel-mappings	2018-02-13 15:17:56.146210060 -0800
+++ b/arch/x86/mm/init.c	2018-02-13 15:17:56.152210060 -0800
@@ -162,12 +162,6 @@ struct map_range {
 
 static int page_size_mask;
 
-static void enable_global_pages(void)
-{
-	if (!static_cpu_has(X86_FEATURE_PTI))
-		__supported_pte_mask |= _PAGE_GLOBAL;
-}
-
 static void __init probe_page_size_mask(void)
 {
 	/*
@@ -189,7 +183,7 @@ static void __init probe_page_size_mask(
 	__supported_pte_mask &= ~_PAGE_GLOBAL;
 	if (boot_cpu_has(X86_FEATURE_PGE)) {
 		cr4_set_bits_and_update_boot(X86_CR4_PGE);
-		enable_global_pages();
+		__supported_pte_mask |= _PAGE_GLOBAL;
 	}
 
 	/* Enable 1 GB linear kernel mappings if available: */
diff -puN arch/x86/mm/pageattr.c~kpti-no-global-for-kernel-mappings arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~kpti-no-global-for-kernel-mappings	2018-02-13 15:17:56.148210060 -0800
+++ b/arch/x86/mm/pageattr.c	2018-02-13 15:17:56.153210060 -0800
@@ -593,7 +593,8 @@ try_preserve_large_page(pte_t *kpte, uns
 	 * different bit positions in the two formats.
 	 */
 	req_prot = pgprot_4k_2_large(req_prot);
-	req_prot = pgprot_set_on_present(req_prot, _PAGE_GLOBAL | _PAGE_PSE);
+	req_prot = pgprot_set_on_present(req_prot,
+			__PAGE_KERNEL_GLOBAL | _PAGE_PSE);
 	req_prot = canon_pgprot(req_prot);
 
 	/*
@@ -703,7 +704,7 @@ __split_large_page(struct cpa_data *cpa,
 		return 1;
 	}
 
-	ref_prot = pgprot_set_on_present(ref_prot, _PAGE_GLOBAL);
+	ref_prot = pgprot_set_on_present(ref_prot, __PAGE_KERNEL_GLOBAL);
 
 	/*
 	 * Get the target pfn from the original entry:
@@ -926,7 +927,7 @@ static void populate_pte(struct cpa_data
 
 	pte = pte_offset_kernel(pmd, start);
 
-	pgprot = pgprot_set_on_present(pgprot, _PAGE_GLOBAL);
+	pgprot = pgprot_set_on_present(pgprot, __PAGE_KERNEL_GLOBAL);
 	pgprot = canon_pgprot(pgprot);
 
 	while (num_pages-- && start < end) {
@@ -1219,7 +1220,7 @@ repeat:
 
 		new_prot = static_protections(new_prot, address, pfn);
 
-		new_prot = pgprot_set_on_present(new_prot, _PAGE_GLOBAL);
+		new_prot = pgprot_set_on_present(new_prot, __PAGE_KERNEL_GLOBAL);
 
 		/*
 		 * We need to keep the pfn from the existing PTE,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
