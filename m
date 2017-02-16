Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 32945680FF1
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:42:51 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id d9so42430391itc.4
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:42:51 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0089.outbound.protection.outlook.com. [104.47.41.89])
        by mx.google.com with ESMTPS id c10si7615433itd.43.2017.02.16.07.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:42:50 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 03/28] x86: Add the Secure Memory Encryption CPU
 feature
Date: Thu, 16 Feb 2017 09:42:36 -0600
Message-ID: <20170216154236.19244.7580.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

Update the CPU features to include identifying and reporting on the
Secure Memory Encryption (SME) feature.  SME is identified by CPUID
0x8000001f, but requires BIOS support to enable it (set bit 23 of
SYS_CFG MSR).  Only show the SME feature as available if reported by
CPUID and enabled by BIOS.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cpufeature.h        |    7 +++++--
 arch/x86/include/asm/cpufeatures.h       |    5 ++++-
 arch/x86/include/asm/disabled-features.h |    3 ++-
 arch/x86/include/asm/msr-index.h         |    2 ++
 arch/x86/include/asm/required-features.h |    3 ++-
 arch/x86/kernel/cpu/common.c             |   19 +++++++++++++++++++
 6 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
index d59c15c..ea2de6a 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -28,6 +28,7 @@ enum cpuid_leafs
 	CPUID_8000_000A_EDX,
 	CPUID_7_ECX,
 	CPUID_8000_0007_EBX,
+	CPUID_8000_001F_EAX,
 };
 
 #ifdef CONFIG_X86_FEATURE_NAMES
@@ -78,8 +79,9 @@ enum cpuid_leafs
 	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 15, feature_bit) ||	\
 	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 16, feature_bit) ||	\
 	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 17, feature_bit) ||	\
+	   CHECK_BIT_IN_MASK_WORD(REQUIRED_MASK, 18, feature_bit) ||	\
 	   REQUIRED_MASK_CHECK					  ||	\
-	   BUILD_BUG_ON_ZERO(NCAPINTS != 18))
+	   BUILD_BUG_ON_ZERO(NCAPINTS != 19))
 
 #define DISABLED_MASK_BIT_SET(feature_bit)				\
 	 ( CHECK_BIT_IN_MASK_WORD(DISABLED_MASK,  0, feature_bit) ||	\
@@ -100,8 +102,9 @@ enum cpuid_leafs
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
index d45ab4b..331fb81 100644
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
@@ -296,6 +296,9 @@
 #define X86_FEATURE_SUCCOR	(17*32+1) /* Uncorrectable error containment and recovery */
 #define X86_FEATURE_SMCA	(17*32+3) /* Scalable MCA */
 
+/* AMD-defined CPU features, CPUID level 0x8000001f (eax), word 18 */
+#define X86_FEATURE_SME		(18*32+0) /* Secure Memory Encryption */
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
diff --git a/arch/x86/include/asm/msr-index.h b/arch/x86/include/asm/msr-index.h
index 00293a9..e2d0503 100644
--- a/arch/x86/include/asm/msr-index.h
+++ b/arch/x86/include/asm/msr-index.h
@@ -339,6 +339,8 @@
 #define MSR_K8_TOP_MEM1			0xc001001a
 #define MSR_K8_TOP_MEM2			0xc001001d
 #define MSR_K8_SYSCFG			0xc0010010
+#define MSR_K8_SYSCFG_MEM_ENCRYPT_BIT	23
+#define MSR_K8_SYSCFG_MEM_ENCRYPT	BIT_ULL(MSR_K8_SYSCFG_MEM_ENCRYPT_BIT)
 #define MSR_K8_INT_PENDING_MSG		0xc0010055
 /* C1E active bits in int pending message */
 #define K8_INTP_C1E_ACTIVE_MASK		0x18000000
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
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index c188ae5..b33bc06 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -763,6 +763,25 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 	if (c->extended_cpuid_level >= 0x8000000a)
 		c->x86_capability[CPUID_8000_000A_EDX] = cpuid_edx(0x8000000a);
 
+	if (c->extended_cpuid_level >= 0x8000001f) {
+		cpuid(0x8000001f, &eax, &ebx, &ecx, &edx);
+
+		/* SME feature support */
+		if ((c->x86_vendor == X86_VENDOR_AMD) && (eax & 0x01)) {
+			u64 msr;
+
+			/*
+			 * For SME, BIOS support is required. If BIOS has not
+			 * enabled SME don't advertise the feature.
+			 */
+			rdmsrl(MSR_K8_SYSCFG, msr);
+			if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
+				eax &= ~0x01;
+		}
+
+		c->x86_capability[CPUID_8000_001F_EAX] = eax;
+	}
+
 	init_scattered_cpuid_features(c);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
