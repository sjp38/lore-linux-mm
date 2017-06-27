Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC806B03B6
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:08:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g7so29966610pgp.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:08:13 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0061.outbound.protection.outlook.com. [104.47.40.61])
        by mx.google.com with ESMTPS id z73si2060210pgz.402.2017.06.27.08.08.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:08:12 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 RESEND 04/38] x86/CPU/AMD: Add the Secure Memory
 Encryption CPU feature
Date: Tue, 27 Jun 2017 10:08:02 -0500
Message-ID: <20170627150802.17428.331.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
References: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Update the CPU features to include identifying and reporting on the
Secure Memory Encryption (SME) feature.  SME is identified by CPUID
0x8000001f, but requires BIOS support to enable it (set bit 23 of
MSR_K8_SYSCFG).  Only show the SME feature as available if reported by
CPUID and enabled by BIOS.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cpufeatures.h |    1 +
 arch/x86/include/asm/msr-index.h   |    2 ++
 arch/x86/kernel/cpu/amd.c          |   13 +++++++++++++
 arch/x86/kernel/cpu/scattered.c    |    1 +
 4 files changed, 17 insertions(+)

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
index 18b1623..460ac01 100644
--- a/arch/x86/include/asm/msr-index.h
+++ b/arch/x86/include/asm/msr-index.h
@@ -352,6 +352,8 @@
 #define MSR_K8_TOP_MEM1			0xc001001a
 #define MSR_K8_TOP_MEM2			0xc001001d
 #define MSR_K8_SYSCFG			0xc0010010
+#define MSR_K8_SYSCFG_MEM_ENCRYPT_BIT	23
+#define MSR_K8_SYSCFG_MEM_ENCRYPT	BIT_ULL(MSR_K8_SYSCFG_MEM_ENCRYPT_BIT)
 #define MSR_K8_INT_PENDING_MSG		0xc0010055
 /* C1E active bits in int pending message */
 #define K8_INTP_C1E_ACTIVE_MASK		0x18000000
diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index bb5abe8..c47ceee 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -611,6 +611,19 @@ static void early_init_amd(struct cpuinfo_x86 *c)
 	 */
 	if (cpu_has_amd_erratum(c, amd_erratum_400))
 		set_cpu_bug(c, X86_BUG_AMD_E400);
+
+	/*
+	 * BIOS support is required for SME. If BIOS has not enabled SME
+	 * then don't advertise the feature (set in scattered.c)
+	 */
+	if (cpu_has(c, X86_FEATURE_SME)) {
+		u64 msr;
+
+		/* Check if SME is enabled */
+		rdmsrl(MSR_K8_SYSCFG, msr);
+		if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
+			clear_cpu_cap(c, X86_FEATURE_SME);
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
