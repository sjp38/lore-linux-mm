Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5694403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 15:52:10 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 65so55795329pfd.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 12:52:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yq2si18836319pac.19.2016.02.04.12.52.09
        for <linux-mm@kvack.org>;
        Thu, 04 Feb 2016 12:52:09 -0800 (PST)
Message-Id: <97426a50c5667bb81a28340b820b371d7fadb6fa.1454618190.git.tony.luck@intel.com>
In-Reply-To: <cover.1454618190.git.tony.luck@intel.com>
References: <cover.1454618190.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Fri, 29 Jan 2016 16:00:19 -0800
Subject: [PATCH v10 4/4] x86: Create a new synthetic cpu capability for
 machine check recovery
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

The Intel Software Developer Manual describes bit 24 in the MCG_CAP
MSR:
   MCG_SER_P (software error recovery support present) flag,
   bit 24 a?? Indicates (when set) that the processor supports
   software error recovery
But only some models with this capability bit set will actually
generate recoverable machine checks.

Check the model name and set a synthetic capability bit. Provide
a command line option to set this bit anyway in case the kernel
doesn't recognise the model name.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 Documentation/x86/x86_64/boot-options.txt |  4 ++++
 arch/x86/include/asm/cpufeature.h         |  1 +
 arch/x86/include/asm/mce.h                |  1 +
 arch/x86/kernel/cpu/mcheck/mce.c          | 11 +++++++++++
 4 files changed, 17 insertions(+)

diff --git a/Documentation/x86/x86_64/boot-options.txt b/Documentation/x86/x86_64/boot-options.txt
index 68ed3114c363..8423c04ae7b3 100644
--- a/Documentation/x86/x86_64/boot-options.txt
+++ b/Documentation/x86/x86_64/boot-options.txt
@@ -60,6 +60,10 @@ Machine check
 		threshold to 1. Enabling this may make memory predictive failure
 		analysis less effective if the bios sets thresholds for memory
 		errors since we will not see details for all errors.
+   mce=recovery
+		Tell the kernel that this system can generate recoverable
+		machine checks (useful when the kernel doesn't recognize
+		the cpuid x86_model_id[])
 
    nomce (for compatibility with i386): same as mce=off
 
diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
index 7ad8c9464297..06c6c2d2fea0 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -106,6 +106,7 @@
 #define X86_FEATURE_APERFMPERF	( 3*32+28) /* APERFMPERF */
 #define X86_FEATURE_EAGER_FPU	( 3*32+29) /* "eagerfpu" Non lazy FPU restore */
 #define X86_FEATURE_NONSTOP_TSC_S3 ( 3*32+30) /* TSC doesn't stop in S3 state */
+#define X86_FEATURE_MCE_RECOVERY ( 3*32+31) /* cpu has recoverable machine checks */
 
 /* Intel-defined CPU features, CPUID level 0x00000001 (ecx), word 4 */
 #define X86_FEATURE_XMM3	( 4*32+ 0) /* "pni" SSE-3 */
diff --git a/arch/x86/include/asm/mce.h b/arch/x86/include/asm/mce.h
index 2ea4527e462f..18d2ba9c8e44 100644
--- a/arch/x86/include/asm/mce.h
+++ b/arch/x86/include/asm/mce.h
@@ -113,6 +113,7 @@ struct mca_config {
 	bool ignore_ce;
 	bool disabled;
 	bool ser;
+	bool recovery;
 	bool bios_cmci_threshold;
 	u8 banks;
 	s8 bootlog;
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 905f3070f412..16a3d0e29f84 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -1696,6 +1696,15 @@ void mcheck_cpu_init(struct cpuinfo_x86 *c)
 		return;
 	}
 
+	/*
+	 * MCG_CAP.MCG_SER_P is necessary but not sufficient to know
+	 * whether this processor will actually generate recoverable
+	 * machine checks. Check to see if this is an E7 model Xeon.
+	 */
+	if (mca_cfg.recovery || (mca_cfg.ser &&
+		!strncmp(c->x86_model_id, "Intel(R) Xeon(R) CPU E7-", 24)))
+		set_cpu_cap(c, X86_FEATURE_MCE_RECOVERY);
+
 	if (mce_gen_pool_init()) {
 		mca_cfg.disabled = true;
 		pr_emerg("Couldn't allocate MCE records pool!\n");
@@ -2030,6 +2039,8 @@ static int __init mcheck_enable(char *str)
 		cfg->bootlog = (str[0] == 'b');
 	else if (!strcmp(str, "bios_cmci_threshold"))
 		cfg->bios_cmci_threshold = true;
+	else if (!strcmp(str, "recovery"))
+		cfg->recovery = true;
 	else if (isdigit(str[0])) {
 		if (get_option(&str, &cfg->tolerant) == 2)
 			get_option(&str, &(cfg->monarch_timeout));
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
