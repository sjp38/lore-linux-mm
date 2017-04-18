Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9572F6B03A1
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:14:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q189so2873368pgq.17
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:14:51 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0064.outbound.protection.outlook.com. [104.47.36.64])
        by mx.google.com with ESMTPS id a65si275474pge.215.2017.04.18.14.14.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:14:50 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 04/32] x86/CPU/AMD: Add the Secure Memory Encryption CPU
 feature
Date: Tue, 18 Apr 2017 16:14:40 -0500
Message-ID: <20170418211440.9689.24028.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211400.9689.10175.stgit@tlendack-t1.amdoffice.net>
References: <20170418211400.9689.10175.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Update the CPU features to include identifying and reporting on the
Secure Memory Encryption (SME) feature.  SME is identified by CPUID
0x8000001f, but requires BIOS support to enable it (set bit 23 of
MSR_K8_SYSCFG).  Only show the SME feature as available if reported by
CPUID and enabled by BIOS.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cpufeatures.h |    1 +
 arch/x86/include/asm/msr-index.h   |    2 ++
 arch/x86/kernel/cpu/amd.c          |   15 +++++++++++++++
 arch/x86/kernel/cpu/scattered.c    |    1 +
 4 files changed, 19 insertions(+)

diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index 2701e5f..2b692df 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -196,6 +196,7 @@
 
 #define X86_FEATURE_HW_PSTATE	( 7*32+ 8) /* AMD HW-PState */
 #define X86_FEATURE_PROC_FEEDBACK ( 7*32+ 9) /* AMD ProcFeedbackInterface */
+#define X86_FEATURE_SME		( 7*32+10) /* AMD Secure Memory Encryption */
 
 #define X86_FEATURE_INTEL_PPIN	( 7*32+14) /* Intel Processor Inventory Number */
 #define X86_FEATURE_INTEL_PT	( 7*32+15) /* Intel Processor Trace */
diff --git a/arch/x86/include/asm/msr-index.h b/arch/x86/include/asm/msr-index.h
index 673f9ac..8ff4aaa 100644
--- a/arch/x86/include/asm/msr-index.h
+++ b/arch/x86/include/asm/msr-index.h
@@ -350,6 +350,8 @@
 #define MSR_K8_TOP_MEM1			0xc001001a
 #define MSR_K8_TOP_MEM2			0xc001001d
 #define MSR_K8_SYSCFG			0xc0010010
+#define MSR_K8_SYSCFG_MEM_ENCRYPT_BIT	23
+#define MSR_K8_SYSCFG_MEM_ENCRYPT	BIT_ULL(MSR_K8_SYSCFG_MEM_ENCRYPT_BIT)
 #define MSR_K8_INT_PENDING_MSG		0xc0010055
 /* C1E active bits in int pending message */
 #define K8_INTP_C1E_ACTIVE_MASK		0x18000000
diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index c36140d..5fc5232 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -611,6 +611,21 @@ static void early_init_amd(struct cpuinfo_x86 *c)
 	 */
 	if (cpu_has_amd_erratum(c, amd_erratum_400))
 		set_cpu_bug(c, X86_BUG_AMD_E400);
+
+	/*
+	 * BIOS support is required for SME. If BIOS has not enabled SME
+	 * then don't advertise the feature (set in scattered.c)
+	 */
+	if (c->extended_cpuid_level >= 0x8000001f) {
+		if (cpu_has(c, X86_FEATURE_SME)) {
+			u64 msr;
+
+			/* Check if SME is enabled */
+			rdmsrl(MSR_K8_SYSCFG, msr);
+			if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
+				clear_cpu_cap(c, X86_FEATURE_SME);
+		}
+	}
 }
 
 static void init_amd_k8(struct cpuinfo_x86 *c)
diff --git a/arch/x86/kernel/cpu/scattered.c b/arch/x86/kernel/cpu/scattered.c
index 23c2350..05459ad 100644
--- a/arch/x86/kernel/cpu/scattered.c
+++ b/arch/x86/kernel/cpu/scattered.c
@@ -31,6 +31,7 @@ struct cpuid_bit {
 	{ X86_FEATURE_HW_PSTATE,	CPUID_EDX,  7, 0x80000007, 0 },
 	{ X86_FEATURE_CPB,		CPUID_EDX,  9, 0x80000007, 0 },
 	{ X86_FEATURE_PROC_FEEDBACK,    CPUID_EDX, 11, 0x80000007, 0 },
+	{ X86_FEATURE_SME,		CPUID_EAX,  0, 0x8000001f, 0 },
 	{ 0, 0, 0, 0, 0 }
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
