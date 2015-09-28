Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 431A482F65
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:25:43 -0400 (EDT)
Received: by ioii196 with SMTP id i196so187618501ioi.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:25:43 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 92si13714949iok.118.2015.09.28.12.18.19
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:19 -0700 (PDT)
Subject: [PATCH 03/25] x86, pkeys: cpuid bit definition
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:18 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191818.CD319CCA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

There are two CPUID bits for protection keys.  One is for whether
the CPU contains the feature, and the other will appear set once
the OS enables protection keys.  Specifically:

	Bit 04: OSPKE. If 1, OS has set CR4.PKE to enable
	Protection keys (and the RDPKRU/WRPKRU instructions)

This is because userspace can not see CR4 contents, but it can
see CPUID contents.

X86_FEATURE_PKU is referred to as "PKU" in the hardware documentation:

	CPUID.(EAX=07H,ECX=0H):ECX.PKU [bit 3]

X86_FEATURE_OSPKE is "OSPKU":

	CPUID.(EAX=07H,ECX=0H):ECX.OSPKE [bit 4]

These are the first CPU features which need to look at the
ECX word in CPUID leaf 0x7, so this patch also includes
fetching that word in to the cpuinfo->x86_capability[] array.

Add it to the disabled-features mask when its config option is
off.  Even though we are not using it here, we also extend the
REQUIRED_MASK_BIT_SET() macro to keep it mirroring the
DISABLED_MASK_BIT_SET() version.

This means that in almost all code, you should use:

	cpu_has(X86_FEATURE_PKU)

and *not* the CONFIG option.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/cpufeature.h        |   54 +++++++++++++++++------------
 b/arch/x86/include/asm/disabled-features.h |   12 ++++++
 b/arch/x86/include/asm/required-features.h |    4 ++
 b/arch/x86/kernel/cpu/common.c             |    1 
 4 files changed, 50 insertions(+), 21 deletions(-)

diff -puN arch/x86/include/asm/cpufeature.h~pkeys-01-cpuid arch/x86/include/asm/cpufeature.h
--- a/arch/x86/include/asm/cpufeature.h~pkeys-01-cpuid	2015-09-28 11:39:42.296016728 -0700
+++ b/arch/x86/include/asm/cpufeature.h	2015-09-28 11:39:42.305017137 -0700
@@ -12,7 +12,7 @@
 #include <asm/disabled-features.h>
 #endif
 
-#define NCAPINTS	13	/* N 32-bit words worth of info */
+#define NCAPINTS	14	/* N 32-bit words worth of info */
 #define NBUGINTS	1	/* N 32-bit bug flags */
 
 /*
@@ -254,6 +254,10 @@
 /* Intel-defined CPU QoS Sub-leaf, CPUID level 0x0000000F:1 (edx), word 12 */
 #define X86_FEATURE_CQM_OCCUP_LLC (12*32+ 0) /* LLC occupancy monitoring if 1 */
 
+/* Intel-defined CPU features, CPUID level 0x00000007:0 (ecx), word 13 */
+#define X86_FEATURE_PKU		(13*32+ 3) /* Protection Keys for Userspace */
+#define X86_FEATURE_OSPKE	(13*32+ 4) /* OS Protection Keys Enable */
+
 /*
  * BUG word(s)
  */
@@ -294,28 +298,36 @@ extern const char * const x86_bug_flags[
 	 test_bit(bit, (unsigned long *)((c)->x86_capability))
 
 #define REQUIRED_MASK_BIT_SET(bit)					\
-	 ( (((bit)>>5)==0 && (1UL<<((bit)&31) & REQUIRED_MASK0)) ||	\
-	   (((bit)>>5)==1 && (1UL<<((bit)&31) & REQUIRED_MASK1)) ||	\
-	   (((bit)>>5)==2 && (1UL<<((bit)&31) & REQUIRED_MASK2)) ||	\
-	   (((bit)>>5)==3 && (1UL<<((bit)&31) & REQUIRED_MASK3)) ||	\
-	   (((bit)>>5)==4 && (1UL<<((bit)&31) & REQUIRED_MASK4)) ||	\
-	   (((bit)>>5)==5 && (1UL<<((bit)&31) & REQUIRED_MASK5)) ||	\
-	   (((bit)>>5)==6 && (1UL<<((bit)&31) & REQUIRED_MASK6)) ||	\
-	   (((bit)>>5)==7 && (1UL<<((bit)&31) & REQUIRED_MASK7)) ||	\
-	   (((bit)>>5)==8 && (1UL<<((bit)&31) & REQUIRED_MASK8)) ||	\
-	   (((bit)>>5)==9 && (1UL<<((bit)&31) & REQUIRED_MASK9)) )
+	 ( (((bit)>>5)==0  && (1UL<<((bit)&31) & REQUIRED_MASK0 )) ||	\
+	   (((bit)>>5)==1  && (1UL<<((bit)&31) & REQUIRED_MASK1 )) ||	\
+	   (((bit)>>5)==2  && (1UL<<((bit)&31) & REQUIRED_MASK2 )) ||	\
+	   (((bit)>>5)==3  && (1UL<<((bit)&31) & REQUIRED_MASK3 )) ||	\
+	   (((bit)>>5)==4  && (1UL<<((bit)&31) & REQUIRED_MASK4 )) ||	\
+	   (((bit)>>5)==5  && (1UL<<((bit)&31) & REQUIRED_MASK5 )) ||	\
+	   (((bit)>>5)==6  && (1UL<<((bit)&31) & REQUIRED_MASK6 )) ||	\
+	   (((bit)>>5)==7  && (1UL<<((bit)&31) & REQUIRED_MASK7 )) ||	\
+	   (((bit)>>5)==8  && (1UL<<((bit)&31) & REQUIRED_MASK8 )) ||	\
+	   (((bit)>>5)==9  && (1UL<<((bit)&31) & REQUIRED_MASK9 )) ||	\
+	   (((bit)>>5)==10 && (1UL<<((bit)&31) & REQUIRED_MASK10)) ||	\
+	   (((bit)>>5)==11 && (1UL<<((bit)&31) & REQUIRED_MASK11)) ||	\
+	   (((bit)>>5)==12 && (1UL<<((bit)&31) & REQUIRED_MASK12)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & REQUIRED_MASK13)) )
 
 #define DISABLED_MASK_BIT_SET(bit)					\
-	 ( (((bit)>>5)==0 && (1UL<<((bit)&31) & DISABLED_MASK0)) ||	\
-	   (((bit)>>5)==1 && (1UL<<((bit)&31) & DISABLED_MASK1)) ||	\
-	   (((bit)>>5)==2 && (1UL<<((bit)&31) & DISABLED_MASK2)) ||	\
-	   (((bit)>>5)==3 && (1UL<<((bit)&31) & DISABLED_MASK3)) ||	\
-	   (((bit)>>5)==4 && (1UL<<((bit)&31) & DISABLED_MASK4)) ||	\
-	   (((bit)>>5)==5 && (1UL<<((bit)&31) & DISABLED_MASK5)) ||	\
-	   (((bit)>>5)==6 && (1UL<<((bit)&31) & DISABLED_MASK6)) ||	\
-	   (((bit)>>5)==7 && (1UL<<((bit)&31) & DISABLED_MASK7)) ||	\
-	   (((bit)>>5)==8 && (1UL<<((bit)&31) & DISABLED_MASK8)) ||	\
-	   (((bit)>>5)==9 && (1UL<<((bit)&31) & DISABLED_MASK9)) )
+	 ( (((bit)>>5)==0  && (1UL<<((bit)&31) & DISABLED_MASK0 )) ||	\
+	   (((bit)>>5)==1  && (1UL<<((bit)&31) & DISABLED_MASK1 )) ||	\
+	   (((bit)>>5)==2  && (1UL<<((bit)&31) & DISABLED_MASK2 )) ||	\
+	   (((bit)>>5)==3  && (1UL<<((bit)&31) & DISABLED_MASK3 )) ||	\
+	   (((bit)>>5)==4  && (1UL<<((bit)&31) & DISABLED_MASK4 )) ||	\
+	   (((bit)>>5)==5  && (1UL<<((bit)&31) & DISABLED_MASK5 )) ||	\
+	   (((bit)>>5)==6  && (1UL<<((bit)&31) & DISABLED_MASK6 )) ||	\
+	   (((bit)>>5)==7  && (1UL<<((bit)&31) & DISABLED_MASK7 )) ||	\
+	   (((bit)>>5)==8  && (1UL<<((bit)&31) & DISABLED_MASK8 )) ||	\
+	   (((bit)>>5)==9  && (1UL<<((bit)&31) & DISABLED_MASK9 )) ||	\
+	   (((bit)>>5)==10 && (1UL<<((bit)&31) & DISABLED_MASK10)) ||	\
+	   (((bit)>>5)==11 && (1UL<<((bit)&31) & DISABLED_MASK11)) ||	\
+	   (((bit)>>5)==12 && (1UL<<((bit)&31) & DISABLED_MASK12)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & DISABLED_MASK13)) )
 
 #define cpu_has(c, bit)							\
 	(__builtin_constant_p(bit) && REQUIRED_MASK_BIT_SET(bit) ? 1 :	\
diff -puN arch/x86/include/asm/disabled-features.h~pkeys-01-cpuid arch/x86/include/asm/disabled-features.h
--- a/arch/x86/include/asm/disabled-features.h~pkeys-01-cpuid	2015-09-28 11:39:42.298016819 -0700
+++ b/arch/x86/include/asm/disabled-features.h	2015-09-28 11:39:42.305017137 -0700
@@ -28,6 +28,14 @@
 # define DISABLE_CENTAUR_MCR	0
 #endif /* CONFIG_X86_64 */
 
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+# define DISABLE_PKU		(1<<(X86_FEATURE_PKU))
+# define DISABLE_OSPKE		(1<<(X86_FEATURE_OSPKE))
+#else
+# define DISABLE_PKU		0
+# define DISABLE_OSPKE		0
+#endif /* CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS */
+
 /*
  * Make sure to add features to the correct mask
  */
@@ -41,5 +49,9 @@
 #define DISABLED_MASK7	0
 #define DISABLED_MASK8	0
 #define DISABLED_MASK9	(DISABLE_MPX)
+#define DISABLED_MASK10	0
+#define DISABLED_MASK11	0
+#define DISABLED_MASK12	0
+#define DISABLED_MASK13	(DISABLE_PKU|DISABLE_OSPKE)
 
 #endif /* _ASM_X86_DISABLED_FEATURES_H */
diff -puN arch/x86/include/asm/required-features.h~pkeys-01-cpuid arch/x86/include/asm/required-features.h
--- a/arch/x86/include/asm/required-features.h~pkeys-01-cpuid	2015-09-28 11:39:42.300016910 -0700
+++ b/arch/x86/include/asm/required-features.h	2015-09-28 11:39:42.306017183 -0700
@@ -92,5 +92,9 @@
 #define REQUIRED_MASK7	0
 #define REQUIRED_MASK8	0
 #define REQUIRED_MASK9	0
+#define REQUIRED_MASK10	0
+#define REQUIRED_MASK11	0
+#define REQUIRED_MASK12	0
+#define REQUIRED_MASK13	0
 
 #endif /* _ASM_X86_REQUIRED_FEATURES_H */
diff -puN arch/x86/kernel/cpu/common.c~pkeys-01-cpuid arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~pkeys-01-cpuid	2015-09-28 11:39:42.302017001 -0700
+++ b/arch/x86/kernel/cpu/common.c	2015-09-28 11:39:42.306017183 -0700
@@ -619,6 +619,7 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 		cpuid_count(0x00000007, 0, &eax, &ebx, &ecx, &edx);
 
 		c->x86_capability[9] = ebx;
+		c->x86_capability[13] = ecx;
 	}
 
 	/* Extended state features: level 0x0000000d */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
