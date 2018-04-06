Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78BFF6B0022
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 16:58:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 2so1310386pft.4
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 13:58:15 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id w3si7534052pge.719.2018.04.06.13.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 13:58:14 -0700 (PDT)
Subject: [PATCH 10/11] x86/pti: never implicitly clear _PAGE_GLOBAL for kernel image
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 06 Apr 2018 13:55:17 -0700
References: <20180406205501.24A1A4E7@viggo.jf.intel.com>
In-Reply-To: <20180406205501.24A1A4E7@viggo.jf.intel.com>
Message-Id: <20180406205517.C80FBE05@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Summary:

In current kernels, with PTI enabled, no pages are marked Global. This
potentially increases TLB misses.  But, the mechanism by which the Global
bit is set and cleared is rather haphazard.  This patch makes the process
more explicit.  In the end, it leaves us with Global entries in the page
tables for the areas truly shared by userspace and kernel and increases
TLB hit rates.

The place this patch really shines in on systems without PCIDs.  In this
case, we are using an lseek microbenchmark[1] to see how a reasonably
non-trivial syscall behaves.  Higher is better:

No Global pages (baseline): 6077741 lseeks/sec
88 Global Pages (this set): 7528609 lseeks/sec (+23.9%)

On a modern Skylake desktop with PCIDs, the benefits are tangible, but not
huge for a kernel compile (lower is better):

No Global pages (baseline): 186.951 seconds time elapsed  ( +-  0.35% )
28 Global pages (this set): 185.756 seconds time elapsed  ( +-  0.09% )
                             -1.195 seconds (-0.64%)

I also re-checked everything using the lseek1 test[1]:

No Global pages (baseline): 15783951 lseeks/sec
28 Global pages (this set): 16054688 lseeks/sec
			     +270737 lseeks/sec (+1.71%)

The effect is more visible, but still modest.

Details:

The kernel page tables are inherited from head_64.S which rudely marks
them as _PAGE_GLOBAL.  For PTI, we have been relying on the grace of
$DEITY and some insane behavior in pageattr.c to clear _PAGE_GLOBAL.
This patch tries to do better.

First, stop filtering out "unsupported" bits from being cleared in the
pageattr code.  It's fine to filter out *setting* these bits but it
is insane to keep us from clearing them.

Then, *explicitly* go clear _PAGE_GLOBAL from the kernel identity map.
Do not rely on pageattr to do it magically.

After this patch, we can see that "GLB" shows up in each copy of the
page tables, that we have the same number of global entries in each
and that they are the *same* entries.

# grep -c GLB /sys/kernel/debug/page_tables/*
/sys/kernel/debug/page_tables/current_kernel:11
/sys/kernel/debug/page_tables/current_user:11
/sys/kernel/debug/page_tables/kernel:11

# for f in `ls /sys/kernel/debug/page_tables/`; do grep GLB /sys/kernel/debug/page_tables/$f > $f.GLB; done
# md5sum *.GLB
9caae8ad6a1fb53aca2407ec037f612d  current_kernel.GLB
9caae8ad6a1fb53aca2407ec037f612d  current_user.GLB
9caae8ad6a1fb53aca2407ec037f612d  kernel.GLB

A quick visual audit also shows that all the entries make sense.
0xfffffe0000000000 is the cpu_entry_area and 0xffffffff81c00000
is the entry/exit text:

# grep -c GLB /sys/kernel/debug/page_tables/current_user
0xfffffe0000000000-0xfffffe0000002000           8K     ro                 GLB NX pte
0xfffffe0000002000-0xfffffe0000003000           4K     RW                 GLB NX pte
0xfffffe0000003000-0xfffffe0000006000          12K     ro                 GLB NX pte
0xfffffe0000006000-0xfffffe0000007000           4K     ro                 GLB x  pte
0xfffffe0000007000-0xfffffe000000d000          24K     RW                 GLB NX pte
0xfffffe000002d000-0xfffffe000002e000           4K     ro                 GLB NX pte
0xfffffe000002e000-0xfffffe000002f000           4K     RW                 GLB NX pte
0xfffffe000002f000-0xfffffe0000032000          12K     ro                 GLB NX pte
0xfffffe0000032000-0xfffffe0000033000           4K     ro                 GLB x  pte
0xfffffe0000033000-0xfffffe0000039000          24K     RW                 GLB NX pte
0xffffffff81c00000-0xffffffff81e00000           2M     ro         PSE     GLB x  pmd

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

 b/arch/x86/mm/init.c     |    8 +-------
 b/arch/x86/mm/pageattr.c |   12 +++++++++---
 b/arch/x86/mm/pti.c      |   25 +++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 10 deletions(-)

diff -puN arch/x86/mm/init.c~clear-global-for-pti arch/x86/mm/init.c
--- a/arch/x86/mm/init.c~clear-global-for-pti	2018-04-06 10:47:58.807796117 -0700
+++ b/arch/x86/mm/init.c	2018-04-06 10:47:58.815796117 -0700
@@ -161,12 +161,6 @@ struct map_range {
 
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
@@ -187,7 +181,7 @@ static void __init probe_page_size_mask(
 	__supported_pte_mask &= ~_PAGE_GLOBAL;
 	if (boot_cpu_has(X86_FEATURE_PGE)) {
 		cr4_set_bits_and_update_boot(X86_CR4_PGE);
-		enable_global_pages();
+		__supported_pte_mask |= _PAGE_GLOBAL;
 	}
 
 	/* By the default is everything supported: */
diff -puN arch/x86/mm/pageattr.c~clear-global-for-pti arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~clear-global-for-pti	2018-04-06 10:47:58.809796117 -0700
+++ b/arch/x86/mm/pageattr.c	2018-04-06 10:47:58.815796117 -0700
@@ -1411,11 +1411,11 @@ static int change_page_attr_set_clr(unsi
 	memset(&cpa, 0, sizeof(cpa));
 
 	/*
-	 * Check, if we are requested to change a not supported
-	 * feature:
+	 * Check, if we are requested to set a not supported
+	 * feature.  Clearing non-supported features is OK.
 	 */
 	mask_set = canon_pgprot(mask_set);
-	mask_clr = canon_pgprot(mask_clr);
+
 	if (!pgprot_val(mask_set) && !pgprot_val(mask_clr) && !force_split)
 		return 0;
 
@@ -1758,6 +1758,12 @@ int set_memory_4k(unsigned long addr, in
 					__pgprot(0), 1, 0, NULL);
 }
 
+int set_memory_nonglobal(unsigned long addr, int numpages)
+{
+	return change_page_attr_clear(&addr, numpages,
+				      __pgprot(_PAGE_GLOBAL), 0);
+}
+
 static int __set_memory_enc_dec(unsigned long addr, int numpages, bool enc)
 {
 	struct cpa_data cpa;
diff -puN arch/x86/mm/pti.c~clear-global-for-pti arch/x86/mm/pti.c
--- a/arch/x86/mm/pti.c~clear-global-for-pti	2018-04-06 10:47:58.811796117 -0700
+++ b/arch/x86/mm/pti.c	2018-04-06 10:47:58.816796117 -0700
@@ -373,6 +373,27 @@ static void __init pti_clone_entry_text(
 }
 
 /*
+ * This is the only user for it and it is not arch-generic like
+ * the other set_memory.h functions.  Just extern it.
+ */
+extern int set_memory_nonglobal(unsigned long addr, int numpages);
+void pti_set_kernel_image_nonglobal(void)
+{
+	/*
+	 * The identity map is created with PMDs, regardless of the
+	 * actual length of the kernel.  We need to clear
+	 * _PAGE_GLOBAL up to a PMD boundary, not just to the end
+	 * of the image.
+	 */
+	unsigned long start = PFN_ALIGN(_text);
+	unsigned long end = ALIGN((unsigned long)_end, PMD_PAGE_SIZE);
+
+	pr_debug("set kernel image non-global\n");
+
+	set_memory_nonglobal(start, (end - start) >> PAGE_SHIFT);
+}
+
+/*
  * Initialize kernel page table isolation
  */
 void __init pti_init(void)
@@ -383,6 +404,10 @@ void __init pti_init(void)
 	pr_info("enabled\n");
 
 	pti_clone_user_shared();
+
+	/* Undo all global bits from the init pagetables in head_64.S: */
+	pti_set_kernel_image_nonglobal();
+	/* Replace some of the global bits just for shared entry text: */
 	pti_clone_entry_text();
 	pti_setup_espfix64();
 	pti_setup_vsyscall();
_
