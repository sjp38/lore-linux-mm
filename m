Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEB06B0278
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:22:34 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c4so652060667pfb.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:22:34 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n11si29469613plg.334.2016.12.08.08.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:22:33 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
Date: Thu,  8 Dec 2016 19:21:37 +0300
Message-Id: <20161208162150.148763-17-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

5-level paging support is required from hardware when compiled with
CONFIG_X86_5LEVEL=y. We may implement runtime switch support later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/cpucheck.c                 |  9 +++++++++
 arch/x86/boot/cpuflags.c                 | 16 ++++++++++++++++
 arch/x86/include/asm/cpufeatures.h       |  1 +
 arch/x86/include/asm/disabled-features.h |  8 +++++++-
 arch/x86/include/asm/required-features.h |  8 +++++++-
 5 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/arch/x86/boot/cpucheck.c b/arch/x86/boot/cpucheck.c
index 4ad7d70e8739..8f0c4c9fc904 100644
--- a/arch/x86/boot/cpucheck.c
+++ b/arch/x86/boot/cpucheck.c
@@ -44,6 +44,15 @@ static const u32 req_flags[NCAPINTS] =
 	0, /* REQUIRED_MASK5 not implemented in this file */
 	REQUIRED_MASK6,
 	0, /* REQUIRED_MASK7 not implemented in this file */
+	0, /* REQUIRED_MASK8 not implemented in this file */
+	0, /* REQUIRED_MASK9 not implemented in this file */
+	0, /* REQUIRED_MASK10 not implemented in this file */
+	0, /* REQUIRED_MASK11 not implemented in this file */
+	0, /* REQUIRED_MASK12 not implemented in this file */
+	0, /* REQUIRED_MASK13 not implemented in this file */
+	0, /* REQUIRED_MASK14 not implemented in this file */
+	0, /* REQUIRED_MASK15 not implemented in this file */
+	REQUIRED_MASK16,
 };
 
 #define A32(a, b, c, d) (((d) << 24)+((c) << 16)+((b) << 8)+(a))
diff --git a/arch/x86/boot/cpuflags.c b/arch/x86/boot/cpuflags.c
index 6687ab953257..26e9a287805f 100644
--- a/arch/x86/boot/cpuflags.c
+++ b/arch/x86/boot/cpuflags.c
@@ -80,6 +80,17 @@ static inline void cpuid(u32 id, u32 *a, u32 *b, u32 *c, u32 *d)
 	);
 }
 
+static inline void cpuid_count(u32 id, u32 count,
+		u32 *a, u32 *b, u32 *c, u32 *d)
+{
+	asm volatile(".ifnc %%ebx,%3 ; movl  %%ebx,%3 ; .endif	\n\t"
+		     "cpuid					\n\t"
+		     ".ifnc %%ebx,%3 ; xchgl %%ebx,%3 ; .endif	\n\t"
+		    : "=a" (*a), "=c" (*c), "=d" (*d), EBX_REG (*b)
+		    : "a" (id), "c" (count)
+	);
+}
+
 void get_cpuflags(void)
 {
 	u32 max_intel_level, max_amd_level;
@@ -108,6 +119,11 @@ void get_cpuflags(void)
 				cpu.model += ((tfms >> 16) & 0xf) << 4;
 		}
 
+		if (max_intel_level >= 0x00000007) {
+			cpuid_count(0x00000007, 0, &ignored, &ignored,
+					&cpu.flags[16], &ignored);
+		}
+
 		cpuid(0x80000000, &max_amd_level, &ignored, &ignored,
 		      &ignored);
 
diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index 92a8308b96f6..388f1277880f 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -280,6 +280,7 @@
 /* Intel-defined CPU features, CPUID level 0x00000007:0 (ecx), word 16 */
 #define X86_FEATURE_PKU		(16*32+ 3) /* Protection Keys for Userspace */
 #define X86_FEATURE_OSPKE	(16*32+ 4) /* OS Protection Keys Enable */
+#define X86_FEATURE_LA57	(16*32+16) /* 5-level page tables */
 
 /* AMD-defined CPU features, CPUID level 0x80000007 (ebx), word 17 */
 #define X86_FEATURE_OVERFLOW_RECOV (17*32+0) /* MCA overflow recovery support */
diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index 85599ad4d024..fc0960236fc3 100644
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -36,6 +36,12 @@
 # define DISABLE_OSPKE		(1<<(X86_FEATURE_OSPKE & 31))
 #endif /* CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS */
 
+#ifdef CONFIG_X86_5LEVEL
+#define DISABLE_LA57	0
+#else
+#define DISABLE_LA57	(1<<(X86_FEATURE_LA57 & 31))
+#endif
+
 /*
  * Make sure to add features to the correct mask
  */
@@ -55,7 +61,7 @@
 #define DISABLED_MASK13	0
 #define DISABLED_MASK14	0
 #define DISABLED_MASK15	0
-#define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE)
+#define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE|DISABLE_LA57)
 #define DISABLED_MASK17	0
 #define DISABLED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 18)
 
diff --git a/arch/x86/include/asm/required-features.h b/arch/x86/include/asm/required-features.h
index fac9a5c0abe9..d91ba04dd007 100644
--- a/arch/x86/include/asm/required-features.h
+++ b/arch/x86/include/asm/required-features.h
@@ -53,6 +53,12 @@
 # define NEED_MOVBE	0
 #endif
 
+#ifdef CONFIG_X86_5LEVEL
+# define NEED_LA57	(1<<(X86_FEATURE_LA57 & 31))
+#else
+# define NEED_LA57	0
+#endif
+
 #ifdef CONFIG_X86_64
 #ifdef CONFIG_PARAVIRT
 /* Paravirtualized systems may not have PSE or PGE available */
@@ -98,7 +104,7 @@
 #define REQUIRED_MASK13	0
 #define REQUIRED_MASK14	0
 #define REQUIRED_MASK15	0
-#define REQUIRED_MASK16	0
+#define REQUIRED_MASK16	(NEED_LA57)
 #define REQUIRED_MASK17	0
 #define REQUIRED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 18)
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
