Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D16F6B027A
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:38:49 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id ro13so84000838pac.7
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:38:49 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0086.outbound.protection.outlook.com. [104.47.41.86])
        by mx.google.com with ESMTPS id r64si1869763pfa.128.2016.11.09.16.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:38:48 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v3 20/20] x86: Add support to make use of Secure Memory
 Encryption
Date: Wed, 9 Nov 2016 18:38:38 -0600
Message-ID: <20161110003838.3280.23327.stgit@tlendack-t1.amdoffice.net>
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

This patch adds the support to check if SME has been enabled and if the
mem_encrypt=on command line option is set. If both of these conditions
are true, then the encryption mask is set and the kernel is encrypted
"in place."

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/head_64.S          |    1 +
 arch/x86/kernel/mem_encrypt_init.c |   60 +++++++++++++++++++++++++++++++++++-
 arch/x86/mm/mem_encrypt.c          |    2 +
 3 files changed, 62 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index e8a7272..c225433 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -100,6 +100,7 @@ startup_64:
 	 * to include it in the page table fixups.
 	 */
 	push	%rsi
+	movq	%rsi, %rdi
 	call	sme_enable
 	pop	%rsi
 	movq	%rax, %r12
diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
index 7bdd159..c94ceb8 100644
--- a/arch/x86/kernel/mem_encrypt_init.c
+++ b/arch/x86/kernel/mem_encrypt_init.c
@@ -16,9 +16,14 @@
 #include <linux/mm.h>
 
 #include <asm/sections.h>
+#include <asm/processor-flags.h>
+#include <asm/msr.h>
+#include <asm/cmdline.h>
 
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
+static char sme_cmdline_arg[] __initdata = "mem_encrypt=on";
+
 extern void sme_encrypt_execute(unsigned long, unsigned long, unsigned long,
 				void *, pgd_t *);
 
@@ -219,7 +224,60 @@ unsigned long __init sme_get_me_mask(void)
 	return sme_me_mask;
 }
 
-unsigned long __init sme_enable(void)
+unsigned long __init sme_enable(void *boot_data)
 {
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+	struct boot_params *bp = boot_data;
+	unsigned int eax, ebx, ecx, edx;
+	u64 msr;
+	unsigned long cmdline_ptr;
+	void *cmdline_arg;
+
+	/* Check for an AMD processor */
+	eax = 0;
+	ecx = 0;
+	native_cpuid(&eax, &ebx, &ecx, &edx);
+	if ((ebx != 0x68747541) || (edx != 0x69746e65) || (ecx != 0x444d4163))
+		goto out;
+
+	/* Check for the SME support leaf */
+	eax = 0x80000000;
+	ecx = 0;
+	native_cpuid(&eax, &ebx, &ecx, &edx);
+	if (eax < 0x8000001f)
+		goto out;
+
+	/*
+	 * Check for the SME feature:
+	 *   CPUID Fn8000_001F[EAX] - Bit 0
+	 *     Secure Memory Encryption support
+	 *   CPUID Fn8000_001F[EBX] - Bits 5:0
+	 *     Pagetable bit position used to indicate encryption
+	 */
+	eax = 0x8000001f;
+	ecx = 0;
+	native_cpuid(&eax, &ebx, &ecx, &edx);
+	if (!(eax & 1))
+		goto out;
+
+	/* Check if SME is enabled */
+	msr = native_read_msr(MSR_K8_SYSCFG);
+	if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
+		goto out;
+
+	/*
+	 * Fixups have not been to applied phys_base yet, so we must obtain
+	 * the address to the SME command line option in the following way.
+	 */
+	asm ("lea sme_cmdline_arg(%%rip), %0"
+	     : "=r" (cmdline_arg)
+	     : "p" (sme_cmdline_arg));
+	cmdline_ptr = bp->hdr.cmd_line_ptr | ((u64)bp->ext_cmd_line_ptr << 32);
+	if (cmdline_find_option_bool((char *)cmdline_ptr, cmdline_arg))
+		sme_me_mask = 1UL << (ebx & 0x3f);
+
+out:
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */
+
 	return sme_me_mask;
 }
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index e351003..d0bc3f5 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -251,6 +251,8 @@ void __init mem_encrypt_init(void)
 
 	/* Make SWIOTLB use an unencrypted DMA area */
 	swiotlb_clear_encryption();
+
+	pr_info("AMD Secure Memory Encryption active\n");
 }
 
 void swiotlb_set_mem_unenc(void *vaddr, unsigned long size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
