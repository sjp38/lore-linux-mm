Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 997B36B03AB
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:01:21 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r145so20607978itr.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:01:21 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0079.outbound.protection.outlook.com. [104.47.41.79])
        by mx.google.com with ESMTPS id 77si2556099itw.98.2017.06.27.08.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:01:20 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 28/38] x86,
 realmode: Check for memory encryption on the APs
Date: Tue, 27 Jun 2017 10:01:10 -0500
Message-ID: <20170627150110.15908.65796.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
References: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Add support to check if memory encryption is active in the kernel and that
it has been enabled on the AP. If memory encryption is active in the kernel
but has not been enabled on the AP, then set the memory encryption bit (bit
23) of MSR_K8_SYSCFG to enable memory encryption on that AP and allow the
AP to continue start up.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/realmode.h      |   12 ++++++++++++
 arch/x86/realmode/init.c             |    4 ++++
 arch/x86/realmode/rm/trampoline_64.S |   24 ++++++++++++++++++++++++
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
