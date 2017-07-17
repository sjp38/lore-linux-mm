Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF4FC6B04B7
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:12:45 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id v193so4714821itc.10
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:12:45 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0062.outbound.protection.outlook.com. [104.47.34.62])
        by mx.google.com with ESMTPS id 14si227364ioq.108.2017.07.17.14.12.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:12:44 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 28/38] x86, realmode: Check for memory encryption on the APs
Date: Mon, 17 Jul 2017 16:10:25 -0500
Message-Id: <37e29b99c395910f56ca9f8ecf7b0439b28827c8.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

Add support to check if memory encryption is active in the kernel and that
it has been enabled on the AP. If memory encryption is active in the kernel
but has not been enabled on the AP, then set the memory encryption bit (bit
23) of MSR_K8_SYSCFG to enable memory encryption on that AP and allow the
AP to continue start up.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/realmode.h      | 12 ++++++++++++
 arch/x86/realmode/init.c             |  4 ++++
 arch/x86/realmode/rm/trampoline_64.S | 24 ++++++++++++++++++++++++
 3 files changed, 40 insertions(+)

diff --git a/arch/x86/include/asm/realmode.h b/arch/x86/include/asm/realmode.h
index 230e190..90d9152 100644
--- a/arch/x86/include/asm/realmode.h
+++ b/arch/x86/include/asm/realmode.h
@@ -1,6 +1,15 @@
 #ifndef _ARCH_X86_REALMODE_H
 #define _ARCH_X86_REALMODE_H
 
+/*
+ * Flag bit definitions for use with the flags field of the trampoline header
+ * in the CONFIG_X86_64 variant.
+ */
+#define TH_FLAGS_SME_ACTIVE_BIT		0
+#define TH_FLAGS_SME_ACTIVE		BIT(TH_FLAGS_SME_ACTIVE_BIT)
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
index d6ddc7e..1f71980 100644
--- a/arch/x86/realmode/init.c
+++ b/arch/x86/realmode/init.c
@@ -108,6 +108,10 @@ static void __init setup_real_mode(void)
 	trampoline_cr4_features = &trampoline_header->cr4;
 	*trampoline_cr4_features = mmu_cr4_features;
 
+	trampoline_header->flags = 0;
+	if (sme_active())
+		trampoline_header->flags |= TH_FLAGS_SME_ACTIVE;
+
 	trampoline_pgd = (u64 *) __va(real_mode_header->trampoline_pgd);
 	trampoline_pgd[0] = trampoline_pgd_entry.pgd;
 	trampoline_pgd[511] = init_top_pgt[511].pgd;
diff --git a/arch/x86/realmode/rm/trampoline_64.S b/arch/x86/realmode/rm/trampoline_64.S
index dac7b20..614fd70 100644
--- a/arch/x86/realmode/rm/trampoline_64.S
+++ b/arch/x86/realmode/rm/trampoline_64.S
@@ -30,6 +30,7 @@
 #include <asm/msr.h>
 #include <asm/segment.h>
 #include <asm/processor-flags.h>
+#include <asm/realmode.h>
 #include "realmode.h"
 
 	.text
@@ -92,6 +93,28 @@ ENTRY(startup_32)
 	movl	%edx, %fs
 	movl	%edx, %gs
 
+	/*
+	 * Check for memory encryption support. This is a safety net in
+	 * case BIOS hasn't done the necessary step of setting the bit in
+	 * the MSR for this AP. If SME is active and we've gotten this far
+	 * then it is safe for us to set the MSR bit and continue. If we
+	 * don't we'll eventually crash trying to execute encrypted
+	 * instructions.
+	 */
+	bt	$TH_FLAGS_SME_ACTIVE_BIT, pa_tr_flags
+	jnc	.Ldone
+	movl	$MSR_K8_SYSCFG, %ecx
+	rdmsr
+	bts	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
+	jc	.Ldone
+
+	/*
+	 * Memory encryption is enabled but the SME enable bit for this
+	 * CPU has has not been set.  It is safe to set it, so do so.
+	 */
+	wrmsr
+.Ldone:
+
 	movl	pa_tr_cr4, %eax
 	movl	%eax, %cr4		# Enable PAE mode
 
@@ -147,6 +170,7 @@ GLOBAL(trampoline_header)
 	tr_start:		.space	8
 	GLOBAL(tr_efer)		.space	8
 	GLOBAL(tr_cr4)		.space	4
+	GLOBAL(tr_flags)	.space	4
 END(trampoline_header)
 
 #include "trampoline_common.S"
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
