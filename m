Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8F26B0261
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:35:22 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b123so794472itb.3
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:35:22 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0058.outbound.protection.outlook.com. [104.47.32.58])
        by mx.google.com with ESMTPS id y2si1478707itb.15.2016.11.09.16.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:35:21 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v3 04/20] x86: Handle reduction in physical address size
 with SME
Date: Wed, 9 Nov 2016 18:35:13 -0600
Message-ID: <20161110003513.3280.12104.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo
 Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas
 Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

When System Memory Encryption (SME) is enabled, the physical address
space is reduced. Adjust the x86_phys_bits value to reflect this
reduction.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/msr-index.h |    2 ++
 arch/x86/kernel/cpu/common.c     |   30 ++++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/arch/x86/include/asm/msr-index.h b/arch/x86/include/asm/msr-index.h
index 56f4c66..4949259 100644
--- a/arch/x86/include/asm/msr-index.h
+++ b/arch/x86/include/asm/msr-index.h
@@ -336,6 +336,8 @@
 #define MSR_K8_TOP_MEM1			0xc001001a
 #define MSR_K8_TOP_MEM2			0xc001001d
 #define MSR_K8_SYSCFG			0xc0010010
+#define MSR_K8_SYSCFG_MEM_ENCRYPT_BIT	23
+#define MSR_K8_SYSCFG_MEM_ENCRYPT	BIT_ULL(MSR_K8_SYSCFG_MEM_ENCRYPT_BIT)
 #define MSR_K8_INT_PENDING_MSG		0xc0010055
 /* C1E active bits in int pending message */
 #define K8_INTP_C1E_ACTIVE_MASK		0x18000000
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 9bd910a..82c64a6 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -604,6 +604,35 @@ out:
 #endif
 }
 
+/*
+ * AMD Secure Memory Encryption (SME) can reduce the size of the physical
+ * address space if it is enabled, even if memory encryption is not active.
+ * Adjust x86_phys_bits if SME is enabled.
+ */
+static void phys_bits_adjust(struct cpuinfo_x86 *c)
+{
+	u32 eax, ebx, ecx, edx;
+	u64 msr;
+
+	if (c->x86_vendor != X86_VENDOR_AMD)
+		return;
+
+	if (c->extended_cpuid_level < 0x8000001f)
+		return;
+
+	/* Check for SME feature */
+	cpuid(0x8000001f, &eax, &ebx, &ecx, &edx);
+	if (!(eax & 0x01))
+		return;
+
+	/* Check if SME is enabled */
+	rdmsrl(MSR_K8_SYSCFG, msr);
+	if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
+		return;
+
+	c->x86_phys_bits -= (ebx >> 6) & 0x3f;
+}
+
 static void get_cpu_vendor(struct cpuinfo_x86 *c)
 {
 	char *v = c->x86_vendor_id;
@@ -736,6 +765,7 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 
 		c->x86_virt_bits = (eax >> 8) & 0xff;
 		c->x86_phys_bits = eax & 0xff;
+		phys_bits_adjust(c);
 		c->x86_capability[CPUID_8000_0008_EBX] = ebx;
 	}
 #ifdef CONFIG_X86_32

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
