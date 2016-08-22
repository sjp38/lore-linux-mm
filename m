Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47FDD6B0266
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:36:33 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id le9so231917194pab.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:36:33 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0074.outbound.protection.outlook.com. [104.47.42.74])
        by mx.google.com with ESMTPS id eg8si312372pac.40.2016.08.22.15.36.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 15:36:32 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v2 05/20] x86: Add the Secure Memory Encryption cpu
 feature
Date: Mon, 22 Aug 2016 17:36:22 -0500
Message-ID: <20160822223622.29880.17779.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy
 Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Update the cpu features to include identifying and reporting on the
Secure Memory Encryption feature.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cpufeature.h        |    7 +++++--
 arch/x86/include/asm/cpufeatures.h       |    5 ++++-
 arch/x86/include/asm/disabled-features.h |    3 ++-
 arch/x86/include/asm/required-features.h |    3 ++-
 arch/x86/kernel/cpu/scattered.c          |    1 +
 5 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
index 1d2b69f..de5bdb1 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -28,6 +28,7 @@ enum cpuid_leafs
 	CPUID_8000_000A_EDX,
 	CPUID_7_ECX,
 	CPUID_8000_0007_EBX,
+	CPUID_8000_001F_EAX,
 };
 
 #ifdef CONFIG_X86_FEATURE_NAMES
@@ -78,8 +79,9 @@ extern const char * const x86_bug_flags[NBUGINTS*32];
 	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 15, feature_bit) ||	\
 	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 16, feature_bit) ||	\
 	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 17, feature_bit) ||	\
+	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 18, feature_bit) ||	\
 	   REQUIRED_MASK_CHECK					  ||	\
-	   BUILD_BUG_ON_ZERO(NCAPINTS != 18))
+	   BUILD_BUG_ON_ZERO(NCAPINTS != 19))
 
 #define DISABLED_MASK_BIT_SET(feature_bit)				\
 	 ( CHECK_BIT_IN_MASK_WORD(DISABLED_MASK,  0, feature_bit) ||	\
@@ -100,8 +102,9 @@ extern const char * const x86_bug_flags[NBUGINTS*32];
 	   CHECK_BIT_IN_MASK_WORD(DISABLED_MASK, 15, feature_bit) ||	\
 	   CHECK_BIT_IN_MASK_WORD(DISABLED_MASK, 16, feature_bit) ||	\
 	   CHECK_BIT_IN_MASK_WORD(DISABLED_MASK, 17, feature_bit) ||	\
+	   CHECK_BIT_IN_MASK_WORD(DISABLED_MASK, 18, feature_bit) ||	\
 	   DISABLED_MASK_CHECK					  ||	\
-	   BUILD_BUG_ON_ZERO(NCAPINTS != 18))
+	   BUILD_BUG_ON_ZERO(NCAPINTS != 19))
 
 #define cpu_has(c, bit)							\
 	(__builtin_constant_p(bit) && REQUIRED_MASK_BIT_SET(bit) ? 1 :	\
diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index 92a8308..8babbd8 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -12,7 +12,7 @@
 /*
  * Defines x86 CPU feature bits
  */
-#define NCAPINTS	18	/* N 32-bit words worth of info */
+#define NCAPINTS	19	/* N 32-bit words worth of info */
 #define NBUGINTS	1	/* N 32-bit bug flags */
 
 /*
@@ -286,6 +286,9 @@
 #define X86_FEATURE_SUCCOR	(17*32+1) /* Uncorrectable error containment and recovery */
 #define X86_FEATURE_SMCA	(17*32+3) /* Scalable MCA */
 
+/* AMD SME Feature Identification, CPUID level 0x8000001f (eax), word 18 */
+#define X86_FEATURE_SME		(18*32+ 0) /* Secure Memory Encryption */
+
 /*
  * BUG word(s)
  */
diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index 85599ad..8b45e08 100644
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -57,6 +57,7 @@
 #define DISABLED_MASK15	0
 #define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE)
 #define DISABLED_MASK17	0
-#define DISABLED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 18)
+#define DISABLED_MASK18	0
+#define DISABLED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 19)
 
 #endif /* _ASM_X86_DISABLED_FEATURES_H */
diff --git a/arch/x86/include/asm/required-features.h b/arch/x86/include/asm/required-features.h
index fac9a5c..6847d85 100644
--- a/arch/x86/include/asm/required-features.h
+++ b/arch/x86/include/asm/required-features.h
@@ -100,6 +100,7 @@
 #define REQUIRED_MASK15	0
 #define REQUIRED_MASK16	0
 #define REQUIRED_MASK17	0
-#define REQUIRED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 18)
+#define REQUIRED_MASK18	0
+#define REQUIRED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 19)
 
 #endif /* _ASM_X86_REQUIRED_FEATURES_H */
diff --git a/arch/x86/kernel/cpu/scattered.c b/arch/x86/kernel/cpu/scattered.c
index 8cb57df..d86d9a5 100644
--- a/arch/x86/kernel/cpu/scattered.c
+++ b/arch/x86/kernel/cpu/scattered.c
@@ -37,6 +37,7 @@ void init_scattered_cpuid_features(struct cpuinfo_x86 *c)
 		{ X86_FEATURE_HW_PSTATE,	CR_EDX, 7, 0x80000007, 0 },
 		{ X86_FEATURE_CPB,		CR_EDX, 9, 0x80000007, 0 },
 		{ X86_FEATURE_PROC_FEEDBACK,	CR_EDX,11, 0x80000007, 0 },
+		{ X86_FEATURE_SME,		CR_EAX, 0, 0x8000001f, 0 },
 		{ 0, 0, 0, 0, 0 }
 	};
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
