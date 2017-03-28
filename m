Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE2916B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 06:45:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v4so98824114pgc.20
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 03:45:31 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y5si3841156pgh.6.2017.03.28.03.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 03:45:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 1/8] x86/boot: Detect 5-level paging support
Date: Tue, 28 Mar 2017 13:45:20 +0300
Message-Id: <20170328104520.31122-1-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170328060604.GA20135@gmail.com>
References: <20170328060604.GA20135@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

5-level paging support is required from hardware when compiled with
CONFIG_X86_5LEVEL=y.

We will implement boot-time switch between 4- and 5-level paging later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/cpucheck.c                 |  9 +++++++++
 arch/x86/boot/cpuflags.c                 | 12 ++++++++++--
 arch/x86/include/asm/disabled-features.h |  8 +++++++-
 arch/x86/include/asm/required-features.h |  8 +++++++-
 4 files changed, 33 insertions(+), 4 deletions(-)

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
index 6687ab953257..9e77c23c2422 100644
--- a/arch/x86/boot/cpuflags.c
+++ b/arch/x86/boot/cpuflags.c
@@ -70,16 +70,19 @@ int has_eflag(unsigned long mask)
 # define EBX_REG "=b"
 #endif
 
-static inline void cpuid(u32 id, u32 *a, u32 *b, u32 *c, u32 *d)
+static inline void cpuid_count(u32 id, u32 count,
+		u32 *a, u32 *b, u32 *c, u32 *d)
 {
 	asm volatile(".ifnc %%ebx,%3 ; movl  %%ebx,%3 ; .endif	\n\t"
 		     "cpuid					\n\t"
 		     ".ifnc %%ebx,%3 ; xchgl %%ebx,%3 ; .endif	\n\t"
 		    : "=a" (*a), "=c" (*c), "=d" (*d), EBX_REG (*b)
-		    : "a" (id)
+		    : "a" (id), "c" (count)
 	);
 }
 
+#define cpuid(id, a, b, c, d) cpuid_count(id, 0, a, b, c, d)
+
 void get_cpuflags(void)
 {
 	u32 max_intel_level, max_amd_level;
@@ -108,6 +111,11 @@ void get_cpuflags(void)
 				cpu.model += ((tfms >> 16) & 0xf) << 4;
 		}
 
+		if (max_intel_level >= 0x00000007) {
+			cpuid_count(0x00000007, 0, &ignored, &ignored,
+					&cpu.flags[16], &ignored);
+		}
+
 		cpuid(0x80000000, &max_amd_level, &ignored, &ignored,
 		      &ignored);
 
diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index 85599ad4d024..5dff775af7cd 100644
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -36,6 +36,12 @@
 # define DISABLE_OSPKE		(1<<(X86_FEATURE_OSPKE & 31))
 #endif /* CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS */
 
+#ifdef CONFIG_X86_5LEVEL
+# define DISABLE_LA57	0
+#else
+# define DISABLE_LA57	(1<<(X86_FEATURE_LA57 & 31))
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
