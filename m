Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 41608828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:41 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id n128so45587088pfn.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:41 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id l9si2100720pfi.44.2016.01.29.10.17.17
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:17:17 -0800 (PST)
Subject: [PATCH 24/31] x86, pkeys: actually enable Memory Protection Keys in CPU
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:17:17 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181717.CC979913@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This sets the bit in 'cr4' to actually enable the protection
keys feature.  We also include a boot-time disable for the
feature "nopku".

Seting X86_CR4_PKE will cause the X86_FEATURE_OSPKE cpuid
bit to appear set.  At this point in boot, identify_cpu()
has already run the actual CPUID instructions and populated
the "cpu features" structures.  We need to go back and
re-run identify_cpu() to make sure it gets updated values.

We *could* simply re-populate the 11th word of the cpuid
data, but this is probably quick enough.

Also note that with the cpu_has() check and X86_FEATURE_PKU
present in disabled-features.h, we do not need an #ifdef
for setup_pku().

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/Documentation/kernel-parameters.txt |    3 ++
 b/arch/x86/kernel/cpu/common.c        |   41 ++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff -puN arch/x86/kernel/cpu/common.c~pkeys-50-should-be-last-patch arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~pkeys-50-should-be-last-patch	2016-01-28 15:52:27.274720912 -0800
+++ b/arch/x86/kernel/cpu/common.c	2016-01-28 15:52:27.279721142 -0800
@@ -288,6 +288,46 @@ static __always_inline void setup_smap(s
 }
 
 /*
+ * Protection Keys are not available in 32-bit mode.
+ */
+static bool pku_disabled;
+static __always_inline void setup_pku(struct cpuinfo_x86 *c)
+{
+	if (!cpu_has(c, X86_FEATURE_PKU))
+		return;
+	if (pku_disabled)
+		return;
+
+	cr4_set_bits(X86_CR4_PKE);
+	/*
+	 * Seting X86_CR4_PKE will cause the X86_FEATURE_OSPKE
+	 * cpuid bit to be set.  We need to ensure that we
+	 * update that bit in this CPU's "cpu_info".
+	 */
+	get_cpu_cap(c);
+}
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+static __init int setup_disable_pku(char *arg)
+{
+	/*
+	 * Do not clear the X86_FEATURE_PKU bit.  All of the
+	 * runtime checks are against OSPKE so clearing the
+	 * bit does nothing.
+	 *
+	 * This way, we will see "pku" in cpuinfo, but not
+	 * "ospke", which is exactly what we want.  It shows
+	 * that the CPU has PKU, but the OS has not enabled it.
+	 * This happens to be exactly how a system would look
+	 * if we disabled the config option.
+	 */
+	pr_info("x86: 'nopku' specified, disabling Memory Protection Keys\n");
+	pku_disabled = true;
+	return 1;
+}
+__setup("nopku", setup_disable_pku);
+#endif /* CONFIG_X86_64 */
+
+/*
  * Some CPU features depend on higher CPUID levels, which may not always
  * be available due to CPUID level capping or broken virtualization
  * software.  Add those features to this table to auto-disable them.
@@ -944,6 +984,7 @@ static void identify_cpu(struct cpuinfo_
 	init_hypervisor(c);
 	x86_init_rdrand(c);
 	x86_init_cache_qos(c);
+	setup_pku(c);
 
 	/*
 	 * Clear/Set all flags overriden by options, need do it
diff -puN Documentation/kernel-parameters.txt~pkeys-50-should-be-last-patch Documentation/kernel-parameters.txt
--- a/Documentation/kernel-parameters.txt~pkeys-50-should-be-last-patch	2016-01-28 15:52:27.276721004 -0800
+++ b/Documentation/kernel-parameters.txt	2016-01-28 15:52:27.280721187 -0800
@@ -976,6 +976,9 @@ bytes respectively. Such letter suffixes
 			See Documentation/x86/intel_mpx.txt for more
 			information about the feature.
 
+	nopku		[X86] Disable Memory Protection Keys CPU feature found
+			in some Intel CPUs.
+
 	eagerfpu=	[X86]
 			on	enable eager fpu restore
 			off	disable eager fpu restore
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
