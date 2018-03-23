Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 134D76B0025
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 13:47:08 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t10-v6so8049466plr.12
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:47:08 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id g66si685228pfg.195.2018.03.23.10.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 10:47:06 -0700 (PDT)
Subject: [PATCH 11/11] x86/pti: leave kernel text global for !PCID
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 23 Mar 2018 10:45:04 -0700
References: <20180323174447.55F35636@viggo.jf.intel.com>
In-Reply-To: <20180323174447.55F35636@viggo.jf.intel.com>
Message-Id: <20180323174504.60B178AB@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


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

 b/arch/x86/mm/pti.c |   34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff -puN arch/x86/mm/pti.c~kpti-global-text-option arch/x86/mm/pti.c
--- a/arch/x86/mm/pti.c~kpti-global-text-option	2018-03-21 16:32:14.312192277 -0700
+++ b/arch/x86/mm/pti.c	2018-03-21 16:32:14.316192277 -0700
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
@@ -374,6 +389,23 @@ void pti_set_kernel_image_nonglobal(void
 	unsigned long start = PFN_ALIGN(_text);
 	unsigned long end = ALIGN((unsigned long)_end, PMD_PAGE_SIZE);
 
+	/*
+	 * Global pages and PCIDs are both ways to make kernel TLB
+	 * entries live longer, reduce TLB misses and improve kernel
+	 * performance.  But, leaving all kernel text Global makes
+	 * it potentially accessible to meltdown-style attacks which
+	 * make it trivial to find gadgets or defeat KASLR.
+	 *
+	 * Leave kernel text global, but only on systems that do not
+	 * have PCIDs and which have not explicitly enabled pti=on.
+	 */
+	if (!cpu_feature_enabled(X86_FEATURE_PCID) &&
+	    (pti_mode == PTI_AUTO)) {
+		pr_debug("processor does not support PCIDs, leaving "
+			 "kernel image global\n");
+		return;
+	}
+
 	pr_debug("set kernel image non-global\n");
 
 	set_memory_nonglobal(start, (end - start) >> PAGE_SHIFT);
_
