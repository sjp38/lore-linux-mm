Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 689966B0257
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:05:51 -0500 (EST)
Received: by pfbo64 with SMTP id o64so31298657pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:05:51 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id v76si18785919pfa.183.2015.12.14.11.05.49
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:05:50 -0800 (PST)
Subject: [PATCH 04/32] x86, pkeys: cpuid bit definition
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:05:48 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190548.CB664316@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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

 b/arch/x86/include/asm/cpufeature.h        |   56 ++++++++++++++++++-----------
 b/arch/x86/include/asm/disabled-features.h |   13 ++++++
 b/arch/x86/include/asm/required-features.h |    5 ++
 b/arch/x86/kernel/cpu/common.c             |    1 
 4 files changed, 54 insertions(+), 21 deletions(-)

diff -puN arch/x86/include/asm/cpufeature.h~pkeys-01-cpuid arch/x86/include/asm/cpufeature.h
--- a/arch/x86/include/asm/cpufeature.h~pkeys-01-cpuid	2015-12-14 10:42:40.495699616 -0800
+++ b/arch/x86/include/asm/cpufeature.h	2015-12-14 10:42:40.503699975 -0800
@@ -12,7 +12,7 @@
 #include <asm/disabled-features.h>
 #endif
 
-#define NCAPINTS	14	/* N 32-bit words worth of info */
+#define NCAPINTS	15	/* N 32-bit words worth of info */
 #define NBUGINTS	1	/* N 32-bit bug flags */
 
 /*
@@ -258,6 +258,10 @@
 /* AMD-defined CPU features, CPUID level 0x80000008 (ebx), word 13 */
 #define X86_FEATURE_CLZERO	(13*32+0) /* CLZERO instruction */
 
+/* Intel-defined CPU features, CPUID level 0x00000007:0 (ecx), word 13 */
+#define X86_FEATURE_PKU		(14*32+ 3) /* Protection Keys for Userspace */
+#define X86_FEATURE_OSPKE	(14*32+ 4) /* OS Protection Keys Enable */
+
 /*
  * BUG word(s)
  */
@@ -298,28 +302,38 @@ extern const char * const x86_bug_flags[
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
+	   (((bit)>>5)==12 && (1UL<<((bit)&31) & REQUIRED_MASK13)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & REQUIRED_MASK14)) )
 
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
+	   (((bit)>>5)==12 && (1UL<<((bit)&31) & DISABLED_MASK13)) ||	\
+	   (((bit)>>5)==13 && (1UL<<((bit)&31) & DISABLED_MASK14)) )
 
 #define cpu_has(c, bit)							\
 	(__builtin_constant_p(bit) && REQUIRED_MASK_BIT_SET(bit) ? 1 :	\
diff -puN arch/x86/include/asm/disabled-features.h~pkeys-01-cpuid arch/x86/include/asm/disabled-features.h
--- a/arch/x86/include/asm/disabled-features.h~pkeys-01-cpuid	2015-12-14 10:42:40.496699661 -0800
+++ b/arch/x86/include/asm/disabled-features.h	2015-12-14 10:42:40.503699975 -0800
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
@@ -41,5 +49,10 @@
 #define DISABLED_MASK7	0
 #define DISABLED_MASK8	0
 #define DISABLED_MASK9	(DISABLE_MPX)
+#define DISABLED_MASK10	0
+#define DISABLED_MASK11	0
+#define DISABLED_MASK12	0
+#define DISABLED_MASK13	0
+#define DISABLED_MASK14	(DISABLE_PKU|DISABLE_OSPKE)
 
 #endif /* _ASM_X86_DISABLED_FEATURES_H */
diff -puN arch/x86/include/asm/required-features.h~pkeys-01-cpuid arch/x86/include/asm/required-features.h
--- a/arch/x86/include/asm/required-features.h~pkeys-01-cpuid	2015-12-14 10:42:40.498699751 -0800
+++ b/arch/x86/include/asm/required-features.h	2015-12-14 10:42:40.503699975 -0800
@@ -92,5 +92,10 @@
 #define REQUIRED_MASK7	0
 #define REQUIRED_MASK8	0
 #define REQUIRED_MASK9	0
+#define REQUIRED_MASK10	0
+#define REQUIRED_MASK11	0
+#define REQUIRED_MASK12	0
+#define REQUIRED_MASK13	0
+#define REQUIRED_MASK14	0
 
 #endif /* _ASM_X86_REQUIRED_FEATURES_H */
diff -puN arch/x86/kernel/cpu/common.c~pkeys-01-cpuid arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~pkeys-01-cpuid	2015-12-14 10:42:40.499699796 -0800
+++ b/arch/x86/kernel/cpu/common.c	2015-12-14 10:42:40.504700020 -0800
@@ -619,6 +619,7 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 		cpuid_count(0x00000007, 0, &eax, &ebx, &ecx, &edx);
 
 		c->x86_capability[9] = ebx;
+		c->x86_capability[14] = ecx;
 	}
 
 	/* Extended state features: level 0x0000000d */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
