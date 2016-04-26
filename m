Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99ADB6B0268
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:58:44 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so42321334pac.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:58:44 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0087.outbound.protection.outlook.com. [157.56.110.87])
        by mx.google.com with ESMTPS id rq15si5695676pab.43.2016.04.26.15.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:58:43 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 15/18] x86: Enable memory encryption on the APs
Date: Tue, 26 Apr 2016 17:58:33 -0500
Message-ID: <20160426225833.13567.55695.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander
 Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry
 Vyukov <dvyukov@google.com>

Add support to set the memory encryption enable flag on the APs during
realmode initialization. When an AP is started it checks this flag, and
if set, enables memory encryption on its core.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/msr-index.h     |    2 ++
 arch/x86/include/asm/realmode.h      |   12 ++++++++++++
 arch/x86/realmode/init.c             |    4 ++++
 arch/x86/realmode/rm/trampoline_64.S |   14 ++++++++++++++
 4 files changed, 32 insertions(+)

diff --git a/arch/x86/include/asm/msr-index.h b/arch/x86/include/asm/msr-index.h
index 94555b4..b73182b 100644
--- a/arch/x86/include/asm/msr-index.h
+++ b/arch/x86/include/asm/msr-index.h
@@ -349,6 +349,8 @@
 #define MSR_K8_TOP_MEM1			0xc001001a
 #define MSR_K8_TOP_MEM2			0xc001001d
 #define MSR_K8_SYSCFG			0xc0010010
+#define MSR_K8_SYSCFG_MEM_ENCRYPT_BIT	23
+#define MSR_K8_SYSCFG_MEM_ENCRYPT	(1ULL << MSR_K8_SYSCFG_MEM_ENCRYPT_BIT)
 #define MSR_K8_INT_PENDING_MSG		0xc0010055
 /* C1E active bits in int pending message */
 #define K8_INTP_C1E_ACTIVE_MASK		0x18000000
diff --git a/arch/x86/include/asm/realmode.h b/arch/x86/include/asm/realmode.h
index 9c6b890..e24d2ec 100644
--- a/arch/x86/include/asm/realmode.h
+++ b/arch/x86/include/asm/realmode.h
@@ -1,6 +1,15 @@
 #ifndef _ARCH_X86_REALMODE_H
 #define _ARCH_X86_REALMODE_H
 
+/*
+ * Flag bit definitions for use with the flags field of the trampoline header
+ * when configured for X86_64
+ */
+#define TH_FLAGS_MEM_ENCRYPT_BIT	0
+#define TH_FLAGS_MEM_ENCRYPT		(1ULL << TH_FLAGS_MEM_ENCRYPT_BIT)
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
 
@@ -61,4 +71,6 @@ extern unsigned char secondary_startup_64[];
 void reserve_real_mode(void);
 void setup_real_mode(void);
 
+#endif /* __ASSEMBLY__ */
+
 #endif /* _ARCH_X86_REALMODE_H */
diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
index 85b145c..657532b 100644
--- a/arch/x86/realmode/init.c
+++ b/arch/x86/realmode/init.c
@@ -84,6 +84,10 @@ void __init setup_real_mode(void)
 	trampoline_cr4_features = &trampoline_header->cr4;
 	*trampoline_cr4_features = __read_cr4();
 
+	trampoline_header->flags = 0;
+	if (sme_me_mask)
+		trampoline_header->flags |= TH_FLAGS_MEM_ENCRYPT;
+
 	trampoline_pgd = (u64 *) __va(real_mode_header->trampoline_pgd);
 	trampoline_pgd[0] = init_level4_pgt[pgd_index(__PAGE_OFFSET)].pgd;
 	trampoline_pgd[511] = init_level4_pgt[511].pgd;
diff --git a/arch/x86/realmode/rm/trampoline_64.S b/arch/x86/realmode/rm/trampoline_64.S
index dac7b20..8d84167 100644
--- a/arch/x86/realmode/rm/trampoline_64.S
+++ b/arch/x86/realmode/rm/trampoline_64.S
@@ -30,6 +30,7 @@
 #include <asm/msr.h>
 #include <asm/segment.h>
 #include <asm/processor-flags.h>
+#include <asm/realmode.h>
 #include "realmode.h"
 
 	.text
@@ -109,6 +110,18 @@ ENTRY(startup_32)
 	movl	$(X86_CR0_PG | X86_CR0_WP | X86_CR0_PE), %eax
 	movl	%eax, %cr0
 
+	# Check for and enable memory encryption support
+	movl	pa_tr_flags, %eax
+	bt	$TH_FLAGS_MEM_ENCRYPT_BIT, pa_tr_flags
+	jnc	.Ldone
+	movl	$MSR_K8_SYSCFG, %ecx
+	rdmsr
+	bt	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
+	jc	.Ldone
+	bts	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
+	wrmsr
+.Ldone:
+
 	/*
 	 * At this point we're in long mode but in 32bit compatibility mode
 	 * with EFER.LME = 1, CS.L = 0, CS.D = 1 (and in turn
@@ -147,6 +160,7 @@ GLOBAL(trampoline_header)
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
