Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CD7DD828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:16:59 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id yy13so44975544pab.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:16:59 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ez9si4715510pab.20.2016.01.29.10.16.49
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:16:49 -0800 (PST)
Subject: [PATCH 04/31] x86, pkeys: cpuid bit definition
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:16:48 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181648.AD5ECA30@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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

	cpu_has(c, X86_FEATURE_PKU)

and *not* the CONFIG option.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/asm/cpufeature.h        |   61 +++++++++++++++++++----------
 b/arch/x86/include/asm/disabled-features.h |   15 +++++++
 b/arch/x86/include/asm/required-features.h |    7 +++
 b/arch/x86/kernel/cpu/common.c             |    1 
 4 files changed, 63 insertions(+), 21 deletions(-)

diff -puN arch/x86/include/asm/cpufeature.h~pkeys-01-cpuid arch/x86/include/asm/cpufeature.h
--- a/arch/x86/include/asm/cpufeature.h~pkeys-01-cpuid	2016-01-28 15:52:18.028297008 -0800
+++ b/arch/x86/include/asm/cpufeature.h	2016-01-28 15:52:18.036297374 -0800
@@ -12,7 +12,7 @@
 #include <asm/disabled-features.h>
 #endif
 
-#define NCAPINTS	16	/* N 32-bit words worth of info */
+#define NCAPINTS	17	/* N 32-bit words worth of info */
 #define NBUGINTS	1	/* N 32-bit bug flags */
 
 /*
@@ -269,6 +269,10 @@
 #define X86_FEATURE_PAUSEFILTER (15*32+10) /* filtered pause intercept */
 #define X86_FEATURE_PFTHRESHOLD (15*32+12) /* pause filter threshold */
 
+/* Intel-defined CPU features, CPUID level 0x00000007:0 (ecx), word 16 */
+#define X86_FEATURE_PKU		(16*32+ 3) /* Protection Keys for Userspace */
+#define X86_FEATURE_OSPKE	(16*32+ 4) /* OS Protection Keys Enable */
+
 /*
  * BUG word(s)
  */
@@ -307,6 +311,7 @@ enum cpuid_leafs
 	CPUID_8000_0008_EBX,
 	CPUID_6_EAX,
 	CPUID_8000_000A_EDX,
+	CPUID_7_ECX,
 };
 
 #ifdef CONFIG_X86_FEATURE_NAMES
@@ -329,28 +334,42 @@ extern const char * const x86_bug_flags[
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
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & REQUIRED_MASK13)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & REQUIRED_MASK14)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & REQUIRED_MASK15)) ||	\
+	   (((bit)>>5)==14 && (1UL<<((bit)&31) & REQUIRED_MASK16)) )
 
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
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & DISABLED_MASK13)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & DISABLED_MASK14)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & DISABLED_MASK15)) ||	\
+	   (((bit)>>5)==14 && (1UL<<((bit)&31) & DISABLED_MASK16)) )
 
 #define cpu_has(c, bit)							\
 	(__builtin_constant_p(bit) && REQUIRED_MASK_BIT_SET(bit) ? 1 :	\
diff -puN arch/x86/include/asm/disabled-features.h~pkeys-01-cpuid arch/x86/include/asm/disabled-features.h
--- a/arch/x86/include/asm/disabled-features.h~pkeys-01-cpuid	2016-01-28 15:52:18.029297053 -0800
+++ b/arch/x86/include/asm/disabled-features.h	2016-01-28 15:52:18.036297374 -0800
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
@@ -41,5 +49,12 @@
 #define DISABLED_MASK7	0
 #define DISABLED_MASK8	0
 #define DISABLED_MASK9	(DISABLE_MPX)
+#define DISABLED_MASK10	0
+#define DISABLED_MASK11	0
+#define DISABLED_MASK12	0
+#define DISABLED_MASK13	0
+#define DISABLED_MASK14	0
+#define DISABLED_MASK15	0
+#define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE)
 
 #endif /* _ASM_X86_DISABLED_FEATURES_H */
diff -puN arch/x86/include/asm/required-features.h~pkeys-01-cpuid arch/x86/include/asm/required-features.h
--- a/arch/x86/include/asm/required-features.h~pkeys-01-cpuid	2016-01-28 15:52:18.031297145 -0800
+++ b/arch/x86/include/asm/required-features.h	2016-01-28 15:52:18.036297374 -0800
@@ -92,5 +92,12 @@
 #define REQUIRED_MASK7	0
 #define REQUIRED_MASK8	0
 #define REQUIRED_MASK9	0
+#define REQUIRED_MASK10	0
+#define REQUIRED_MASK11	0
+#define REQUIRED_MASK12	0
+#define REQUIRED_MASK13	0
+#define REQUIRED_MASK14	0
+#define REQUIRED_MASK15	0
+#define REQUIRED_MASK16	0
 
 #endif /* _ASM_X86_REQUIRED_FEATURES_H */
diff -puN arch/x86/kernel/cpu/common.c~pkeys-01-cpuid arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~pkeys-01-cpuid	2016-01-28 15:52:18.032297191 -0800
+++ b/arch/x86/kernel/cpu/common.c	2016-01-28 15:52:18.037297420 -0800
@@ -611,6 +611,7 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 		c->x86_capability[CPUID_7_0_EBX] = ebx;
 
 		c->x86_capability[CPUID_6_EAX] = cpuid_eax(0x00000006);
+		c->x86_capability[CPUID_7_ECX] = ecx;
 	}
 
 	/* Extended state features: level 0x0000000d */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
