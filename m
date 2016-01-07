Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1302B828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:08:38 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id xn1so39346341obc.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:08:38 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x66si10256902oif.123.2016.01.06.16.01.39
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:39 -0800 (PST)
Subject: [PATCH 24/31] x86, pkeys: actually enable Memory Protection Keys in CPU
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:38 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000138.E8A63FF9@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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
--- a/arch/x86/kernel/cpu/common.c~pkeys-50-should-be-last-patch	2016-01-06 15:50:13.522512707 -0800
+++ b/arch/x86/kernel/cpu/common.c	2016-01-06 15:50:13.528512977 -0800
@@ -289,6 +289,46 @@ static __always_inline void setup_smap(s
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
@@ -948,6 +988,7 @@ static void identify_cpu(struct cpuinfo_
 	init_hypervisor(c);
 	x86_init_rdrand(c);
 	x86_init_cache_qos(c);
+	setup_pku(c);
 
 	/*
 	 * Clear/Set all flags overriden by options, need do it
diff -puN Documentation/kernel-parameters.txt~pkeys-50-should-be-last-patch Documentation/kernel-parameters.txt
--- a/Documentation/kernel-parameters.txt~pkeys-50-should-be-last-patch	2016-01-06 15:50:13.524512797 -0800
+++ b/Documentation/kernel-parameters.txt	2016-01-06 15:50:13.529513023 -0800
@@ -958,6 +958,9 @@ bytes respectively. Such letter suffixes
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
