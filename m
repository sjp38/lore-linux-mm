Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 153DC6B0012
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 21:12:59 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 1-v6so12063233plv.6
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 18:12:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id bg3-v6si1765709plb.118.2018.04.03.18.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 18:12:57 -0700 (PDT)
Subject: [PATCH 11/11] x86/pti: leave kernel text global for !PCID
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 03 Apr 2018 18:10:11 -0700
References: <20180404010946.6186729B@viggo.jf.intel.com>
In-Reply-To: <20180404010946.6186729B@viggo.jf.intel.com>
Message-Id: <20180404011011.82027E0C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


Note: This has changed since the last version.  It now clones the
kernel text PMDs at a much later point and also disables this
functionality on AMD K8 processors.  Details in the patch.

--

I'm sticking this at the end of the series because it's a bit weird.
It can be dropped and the rest of the series is still useful without
it.

Global pages are bad for hardening because they potentially let an
exploit read the kernel image via a Meltdown-style attack which
makes it easier to find gadgets.

But, global pages are good for performance because they reduce TLB
misses when making user/kernel transitions, especially when PCIDs
are not available, such as on older hardware, or where a hypervisor
has disabled them for some reason.

This patch implements a basic, sane policy: If you have PCIDs, you
only map a minimal amount of kernel text global.  If you do not have
PCIDs, you map all kernel text global.

This policy effectively makes PCIDs something that not only adds
performance but a little bit of hardening as well.

I ran a simple "lseek" microbenchmark[1] to test the benefit on
a modern Atom microserver.  Most of the benefit comes from applying
the series before this patch ("entry only"), but there is still a
signifiant benefit from this patch.

No Global Lines (baseline  ): 6077741 lseeks/sec
88 Global Lines (entry only): 7528609 lseeks/sec (+23.9%)
94 Global Lines (this patch): 8433111 lseeks/sec (+38.8%)

1. https://github.com/antonblanchard/will-it-scale/blob/master/tests/lseek1.c

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

 b/arch/x86/include/asm/pti.h |    2 +
 b/arch/x86/mm/init_64.c      |    6 +++
 b/arch/x86/mm/pti.c          |   79 ++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 83 insertions(+), 4 deletions(-)

diff -puN arch/x86/include/asm/pti.h~kpti-global-text-option arch/x86/include/asm/pti.h
--- a/arch/x86/include/asm/pti.h~kpti-global-text-option	2018-04-02 16:41:18.309605165 -0700
+++ b/arch/x86/include/asm/pti.h	2018-04-02 16:41:18.316605165 -0700
@@ -6,8 +6,10 @@
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 extern void pti_init(void);
 extern void pti_check_boottime_disable(void);
+extern void pti_clone_kernel_text(void);
 #else
 static inline void pti_check_boottime_disable(void) { }
+static inline void pti_clone_kernel_text(void) { }
 #endif
 
 #endif /* __ASSEMBLY__ */
diff -puN arch/x86/mm/init_64.c~kpti-global-text-option arch/x86/mm/init_64.c
--- a/arch/x86/mm/init_64.c~kpti-global-text-option	2018-04-02 16:41:18.310605165 -0700
+++ b/arch/x86/mm/init_64.c	2018-04-02 16:41:18.316605165 -0700
@@ -1294,6 +1294,12 @@ void mark_rodata_ro(void)
 			(unsigned long) __va(__pa_symbol(_sdata)));
 
 	debug_checkwx();
+
+	/*
+	 * Do this after all of the manipulation of the
+	 * kernel text page tables are complete.
+	 */
+	pti_clone_kernel_text();
 }
 
 int kern_addr_valid(unsigned long addr)
diff -puN arch/x86/mm/pti.c~kpti-global-text-option arch/x86/mm/pti.c
--- a/arch/x86/mm/pti.c~kpti-global-text-option	2018-04-02 16:41:18.312605165 -0700
+++ b/arch/x86/mm/pti.c	2018-04-02 16:41:18.317605165 -0700
@@ -66,12 +66,22 @@ static void __init pti_print_if_secure(c
 		pr_info("%s\n", reason);
 }
 
+enum pti_mode {
+	PTI_AUTO = 0,
+	PTI_FORCE_OFF,
+	PTI_FORCE_ON
+} pti_mode;
+
 void __init pti_check_boottime_disable(void)
 {
 	char arg[5];
 	int ret;
 
+	/* Assume mode is auto unless overridden. */
+	pti_mode = PTI_AUTO;
+
 	if (hypervisor_is_type(X86_HYPER_XEN_PV)) {
+		pti_mode = PTI_FORCE_OFF;
 		pti_print_if_insecure("disabled on XEN PV.");
 		return;
 	}
@@ -79,18 +89,23 @@ void __init pti_check_boottime_disable(v
 	ret = cmdline_find_option(boot_command_line, "pti", arg, sizeof(arg));
 	if (ret > 0)  {
 		if (ret == 3 && !strncmp(arg, "off", 3)) {
+			pti_mode = PTI_FORCE_OFF;
 			pti_print_if_insecure("disabled on command line.");
 			return;
 		}
 		if (ret == 2 && !strncmp(arg, "on", 2)) {
+			pti_mode = PTI_FORCE_ON;
 			pti_print_if_secure("force enabled on command line.");
 			goto enable;
 		}
-		if (ret == 4 && !strncmp(arg, "auto", 4))
+		if (ret == 4 && !strncmp(arg, "auto", 4)) {
+			pti_mode = PTI_AUTO;
 			goto autosel;
+		}
 	}
 
 	if (cmdline_find_option_bool(boot_command_line, "nopti")) {
+		pti_mode = PTI_FORCE_OFF;
 		pti_print_if_insecure("disabled on command line.");
 		return;
 	}
@@ -149,7 +164,7 @@ pgd_t __pti_set_user_pgd(pgd_t *pgdp, pg
  *
  * Returns a pointer to a P4D on success, or NULL on failure.
  */
-static __init p4d_t *pti_user_pagetable_walk_p4d(unsigned long address)
+static p4d_t *pti_user_pagetable_walk_p4d(unsigned long address)
 {
 	pgd_t *pgd = kernel_to_user_pgdp(pgd_offset_k(address));
 	gfp_t gfp = (GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO);
@@ -177,7 +192,7 @@ static __init p4d_t *pti_user_pagetable_
  *
  * Returns a pointer to a PMD on success, or NULL on failure.
  */
-static __init pmd_t *pti_user_pagetable_walk_pmd(unsigned long address)
+static pmd_t *pti_user_pagetable_walk_pmd(unsigned long address)
 {
 	gfp_t gfp = (GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO);
 	p4d_t *p4d = pti_user_pagetable_walk_p4d(address);
@@ -267,7 +282,7 @@ static void __init pti_setup_vsyscall(vo
 static void __init pti_setup_vsyscall(void) { }
 #endif
 
-static void __init
+void
 pti_clone_pmds(unsigned long start, unsigned long end, pmdval_t clear)
 {
 	unsigned long addr;
@@ -364,10 +379,63 @@ static void __init pti_clone_entry_text(
 }
 
 /*
+ * Global pages and PCIDs are both ways to make kernel TLB entries
+ * live longer, reduce TLB misses and improve kernel performance.
+ * But, leaving all kernel text Global makes it potentially accessible
+ * to Meltdown-style attacks which make it trivial to find gadgets or
+ * defeat KASLR.
+ *
+ * Only use global pages when it is really worth it.
+ */
+static inline bool pti_kernel_image_global_ok(void)
+{
+	/*
+	 * Systems with PCIDs get litlle benefit from global
+	 * kernel text and are not worth the downsides.
+	 */
+	if (cpu_feature_enabled(X86_FEATURE_PCID))
+		return false;
+
+	/*
+	 * Only do global kernel image for pti=auto.  Do the most
+	 * secure thing (not global) if pti=on specified.
+	 */
+	if (pti_mode != PTI_AUTO)
+		return false;
+
+	/*
+	 * K8 may not tolerate the cleared _PAGE_RW on the userspace
+	 * global kernel image pages.  Do the safe thing (disable
+	 * global kernel image).  This is unlikely to ever be
+	 * noticed because PTI is disabled by default on AMD CPUs.
+	 */
+	if (boot_cpu_has(X86_FEATURE_K8))
+		return false;
+
+	return true;
+}
+
+/*
+ * For some configurations, map all of kernel text into the user page
+ * tables.  This reduces TLB misses, especially on non-PCID systems.
+ */
+void pti_clone_kernel_text(void)
+{
+	unsigned long start = PFN_ALIGN(_text);
+	unsigned long end = ALIGN((unsigned long)_end, PMD_PAGE_SIZE);
+
+	if (!pti_kernel_image_global_ok())
+		return;
+
+	pti_clone_pmds(start, end, _PAGE_RW);
+}
+
+/*
  * This is the only user for it and it is not arch-generic like
  * the other set_memory.h functions.  Just extern it.
  */
 extern int set_memory_nonglobal(unsigned long addr, int numpages);
+
 void pti_set_kernel_image_nonglobal(void)
 {
 	/*
@@ -379,6 +447,9 @@ void pti_set_kernel_image_nonglobal(void
 	unsigned long start = PFN_ALIGN(_text);
 	unsigned long end = ALIGN((unsigned long)_end, PMD_PAGE_SIZE);
 
+	if (pti_kernel_image_global_ok())
+		return;
+
 	pr_debug("set kernel image non-global\n");
 
 	set_memory_nonglobal(start, (end - start) >> PAGE_SHIFT);
_
