Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71AF86B03B9
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 15:19:23 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k93so6174630ioi.1
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 12:19:23 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0050.outbound.protection.outlook.com. [104.47.41.50])
        by mx.google.com with ESMTPS id e7si2855039ioe.204.2017.06.07.12.19.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 12:19:22 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v6 34/34] x86/mm: Add support to make use of Secure Memory
 Encryption
Date: Wed, 07 Jun 2017 14:19:16 -0500
Message-ID: <20170607191916.28645.87015.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Add support to check if SME has been enabled and if memory encryption
should be activated (checking of command line option based on the
configuration of the default state).  If memory encryption is to be
activated, then the encryption mask is set and the kernel is encrypted
"in place."

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/head_64.S |    1 
 arch/x86/mm/mem_encrypt.c |   93 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 89 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 1fe944b..660bf8e 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -97,6 +97,7 @@ startup_64:
 	 * Save the returned mask in %r12 for later use.
 	 */
 	push	%rsi
+	movq	%rsi, %rdi
 	call	sme_enable
 	pop	%rsi
 	movq	%rax, %r12
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 6129477..d624058 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -12,6 +12,7 @@
 
 #include <linux/linkage.h>
 #include <linux/init.h>
+#include <asm/bootparam.h>
 
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
@@ -22,10 +23,23 @@
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
 #include <asm/setup.h>
-#include <asm/bootparam.h>
 #include <asm/set_memory.h>
 #include <asm/cacheflush.h>
 #include <asm/sections.h>
+#include <asm/mem_encrypt.h>
+#include <asm/processor-flags.h>
+#include <asm/msr.h>
+#include <asm/cmdline.h>
+
+static char sme_cmdline_arg[] __initdata = "mem_encrypt";
+static char sme_cmdline_on[]  __initdata = "on";
+static char sme_cmdline_off[] __initdata = "off";
+
+/*
+ * Some SME functions run very early causing issues with the stack-protector
+ * support. Provide a way to turn off this support on a per-function basis.
+ */
+#define SME_NOSTACKP __attribute__((__optimize__("no-stack-protector")))
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -237,6 +251,8 @@ void __init mem_encrypt_init(void)
 
 	/* Call into SWIOTLB to update the SWIOTLB DMA buffers */
 	swiotlb_update_mem_attributes();
+
+	pr_info("AMD Secure Memory Encryption (SME) active\n");
 }
 
 void swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
@@ -564,8 +580,75 @@ void __init sme_encrypt_kernel(void)
 	native_write_cr3(native_read_cr3());
 }
 
-unsigned long __init sme_enable(void)
+unsigned long __init SME_NOSTACKP sme_enable(struct boot_params *bp)
 {
+	const char *cmdline_ptr, *cmdline_arg, *cmdline_on, *cmdline_off;
+	unsigned int eax, ebx, ecx, edx;
+	bool active_by_default;
+	unsigned long me_mask;
+	char buffer[16];
+	u64 msr;
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
+	me_mask = 1UL << (ebx & 0x3f);
+
+	/* Check if SME is enabled */
+	msr = __rdmsr(MSR_K8_SYSCFG);
+	if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
+		goto out;
+
+	/*
+	 * Fixups have not been applied to phys_base yet and we're running
+	 * identity mapped, so we must obtain the address to the SME command
+	 * line argument data using rip-relative addressing.
+	 */
+	asm ("lea sme_cmdline_arg(%%rip), %0"
+	     : "=r" (cmdline_arg)
+	     : "p" (sme_cmdline_arg));
+	asm ("lea sme_cmdline_on(%%rip), %0"
+	     : "=r" (cmdline_on)
+	     : "p" (sme_cmdline_on));
+	asm ("lea sme_cmdline_off(%%rip), %0"
+	     : "=r" (cmdline_off)
+	     : "p" (sme_cmdline_off));
+
+	if (IS_ENABLED(CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT))
+		active_by_default = true;
+	else
+		active_by_default = false;
+
+	cmdline_ptr = (const char *)((u64)bp->hdr.cmd_line_ptr |
+				     ((u64)bp->ext_cmd_line_ptr << 32));
+
+	cmdline_find_option(cmdline_ptr, cmdline_arg, buffer, sizeof(buffer));
+
+	if (strncmp(buffer, cmdline_on, sizeof(buffer)) == 0)
+		sme_me_mask = me_mask;
+	else if (strncmp(buffer, cmdline_off, sizeof(buffer)) == 0)
+		sme_me_mask = 0;
+	else
+		sme_me_mask = active_by_default ? me_mask : 0;
+
+out:
 	return sme_me_mask;
 }
 
@@ -576,9 +659,9 @@ unsigned long sme_get_me_mask(void)
 
 #else	/* !CONFIG_AMD_MEM_ENCRYPT */
 
-void __init sme_encrypt_kernel(void)	{ }
-unsigned long __init sme_enable(void)	{ return 0; }
+void __init sme_encrypt_kernel(void)			{ }
+unsigned long __init sme_enable(struct boot_params *bp)	{ return 0; }
 
-unsigned long sme_get_me_mask(void)	{ return 0; }
+unsigned long sme_get_me_mask(void)			{ return 0; }
 
 #endif	/* CONFIG_AMD_MEM_ENCRYPT */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
