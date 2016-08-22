Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 141AC6B0278
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:38:36 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f6so2623573ith.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:38:36 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0062.outbound.protection.outlook.com. [104.47.36.62])
        by mx.google.com with ESMTPS id j62si103515oif.4.2016.08.22.15.38.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 15:38:35 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v2 16/20] x86: Check for memory encryption on the APs
Date: Mon, 22 Aug 2016 17:38:29 -0500
Message-ID: <20160822223829.29880.10341.stgit@tlendack-t1.amdoffice.net>
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

Add support to check if memory encryption is active in the kernel and that
it has been enabled on the AP. If memory encryption is active in the kernel
but has not been enabled on the AP then do not allow the AP to continue
start up.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/msr-index.h     |    2 ++
 arch/x86/include/asm/realmode.h      |   12 ++++++++++++
 arch/x86/realmode/init.c             |    4 ++++
 arch/x86/realmode/rm/trampoline_64.S |   19 +++++++++++++++++++
 4 files changed, 37 insertions(+)

diff --git a/arch/x86/include/asm/msr-index.h b/arch/x86/include/asm/msr-index.h
index 56f4c66..797d228 100644
--- a/arch/x86/include/asm/msr-index.h
+++ b/arch/x86/include/asm/msr-index.h
@@ -336,6 +336,8 @@
 #define MSR_K8_TOP_MEM1			0xc001001a
 #define MSR_K8_TOP_MEM2			0xc001001d
 #define MSR_K8_SYSCFG			0xc0010010
+#define MSR_K8_SYSCFG_MEM_ENCRYPT_BIT	23
+#define MSR_K8_SYSCFG_MEM_ENCRYPT	(1ULL << MSR_K8_SYSCFG_MEM_ENCRYPT_BIT)
 #define MSR_K8_INT_PENDING_MSG		0xc0010055
 /* C1E active bits in int pending message */
 #define K8_INTP_C1E_ACTIVE_MASK		0x18000000
diff --git a/arch/x86/include/asm/realmode.h b/arch/x86/include/asm/realmode.h
index 230e190..c89e326 100644
--- a/arch/x86/include/asm/realmode.h
+++ b/arch/x86/include/asm/realmode.h
@@ -1,6 +1,15 @@
 #ifndef _ARCH_X86_REALMODE_H
 #define _ARCH_X86_REALMODE_H
 
+/*
+ * Flag bit definitions for use with the flags field of the trampoline header
+ * when configured for X86_64
+ */
+#define TH_FLAGS_SME_ENABLE_BIT		0
+#define TH_FLAGS_SME_ENABLE		(1ULL << TH_FLAGS_SME_ENABLE_BIT)
+
+#ifndef __ASSEMBLY__
+
 #include <linux/types.h>
 #include <asm/io.h>
 
@@ -38,6 +47,7 @@ struct trampoline_header {
 	u64 start;
 	u64 efer;
 	u32 cr4;
+	u32 flags;
 #endif
 };
 
@@ -69,4 +79,6 @@ static inline size_t real_mode_size_needed(void)
 void set_real_mode_mem(phys_addr_t mem, size_t size);
 void reserve_real_mode(void);
 
+#endif /* __ASSEMBLY__ */
+
 #endif /* _ARCH_X86_REALMODE_H */
diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
index f74925f..c3edb49 100644
--- a/arch/x86/realmode/init.c
+++ b/arch/x86/realmode/init.c
@@ -101,6 +101,10 @@ static void __init setup_real_mode(void)
 	trampoline_cr4_features = &trampoline_header->cr4;
 	*trampoline_cr4_features = mmu_cr4_features;
 
+	trampoline_header->flags = 0;
+	if (sme_me_mask)
+		trampoline_header->flags |= TH_FLAGS_SME_ENABLE;
+
 	trampoline_pgd = (u64 *) __va(real_mode_header->trampoline_pgd);
 	trampoline_pgd[0] = trampoline_pgd_entry.pgd;
 	trampoline_pgd[511] = init_level4_pgt[511].pgd;
diff --git a/arch/x86/realmode/rm/trampoline_64.S b/arch/x86/realmode/rm/trampoline_64.S
index dac7b20..94e29f4 100644
--- a/arch/x86/realmode/rm/trampoline_64.S
+++ b/arch/x86/realmode/rm/trampoline_64.S
@@ -30,6 +30,7 @@
 #include <asm/msr.h>
 #include <asm/segment.h>
 #include <asm/processor-flags.h>
+#include <asm/realmode.h>
 #include "realmode.h"
 
 	.text
@@ -92,6 +93,23 @@ ENTRY(startup_32)
 	movl	%edx, %fs
 	movl	%edx, %gs
 
+	/* Check for memory encryption support */
+	bt	$TH_FLAGS_SME_ENABLE_BIT, pa_tr_flags
+	jnc	.Ldone
+	movl	$MSR_K8_SYSCFG, %ecx
+	rdmsr
+	bt	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
+	jc	.Ldone
+
+	/*
+	 * Memory encryption is enabled but the MSR has not been set on this
+	 * CPU so we can't continue
+	 */
+.Lno_sme:
+	hlt
+	jmp	.Lno_sme
+.Ldone:
+
 	movl	pa_tr_cr4, %eax
 	movl	%eax, %cr4		# Enable PAE mode
 
@@ -147,6 +165,7 @@ GLOBAL(trampoline_header)
 	tr_start:		.space	8
 	GLOBAL(tr_efer)		.space	8
 	GLOBAL(tr_cr4)		.space	4
+	GLOBAL(tr_flags)	.space	4
 END(trampoline_header)
 
 #include "trampoline_common.S"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
