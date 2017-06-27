Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7826C83296
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:14:58 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m84so21133525ita.15
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:14:58 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0042.outbound.protection.outlook.com. [104.47.34.42])
        by mx.google.com with ESMTPS id m202si2658802ita.81.2017.06.27.08.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:14:57 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 RESEND 38/38] x86/mm: Add support to make use of Secure
 Memory Encryption
Date: Tue, 27 Jun 2017 10:14:48 -0500
Message-ID: <20170627151447.17428.56826.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
References: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Add support to check if SME has been enabled and if memory encryption
should be activated (checking of command line option based on the
configuration of the default state).  If memory encryption is to be
activated, then the encryption mask is set and the kernel is encrypted
"in place."

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |    6 ++-
 arch/x86/kernel/head64.c           |    5 +-
 arch/x86/mm/mem_encrypt.c          |   77 ++++++++++++++++++++++++++++++++++++
 3 files changed, 83 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 7122c36..8e618fc 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -17,6 +17,8 @@
 
 #include <linux/init.h>
 
+#include <asm/bootparam.h>
+
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
 extern unsigned long sme_me_mask;
@@ -38,7 +40,7 @@ void __init sme_early_decrypt(resource_size_t paddr,
 void __init sme_early_init(void);
 
 void __init sme_encrypt_kernel(void);
-void __init sme_enable(void);
+void __init sme_enable(struct boot_params *bp);
 
 /* Architecture __weak replacement functions */
 void __init mem_encrypt_init(void);
@@ -60,7 +62,7 @@ static inline void __init sme_unmap_bootdata(char *real_mode_data) { }
 static inline void __init sme_early_init(void) { }
 
 static inline void __init sme_encrypt_kernel(void) { }
-static inline void __init sme_enable(void) { }
+static inline void __init sme_enable(struct boot_params *bp) { }
 
 #endif	/* CONFIG_AMD_MEM_ENCRYPT */
 
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 0cdb53b..925b292 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -45,7 +45,8 @@ static void __head *fixup_pointer(void *ptr, unsigned long physaddr)
 	return ptr - (void *)_text + (void *)physaddr;
 }
 
-unsigned long __head __startup_64(unsigned long physaddr)
+unsigned long __head __startup_64(unsigned long physaddr,
+				  struct boot_params *bp)
 {
 	unsigned long load_delta, *p;
 	unsigned long pgtable_flags;
@@ -70,7 +71,7 @@ unsigned long __head __startup_64(unsigned long physaddr)
 		for (;;);
 
 	/* Activate Secure Memory Encryption (SME) if supported and enabled */
-	sme_enable();
+	sme_enable(bp);
 
 	/* Include the SME encryption mask in the fixup value */
 	load_delta += sme_get_me_mask();
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index e5d5439..053d540 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -15,6 +15,7 @@
 #include <linux/mm.h>
 #include <linux/dma-mapping.h>
 #include <linux/swiotlb.h>
+#include <linux/mem_encrypt.h>
 
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
@@ -23,6 +24,13 @@
 #include <asm/set_memory.h>
 #include <asm/cacheflush.h>
 #include <asm/sections.h>
+#include <asm/processor-flags.h>
+#include <asm/msr.h>
+#include <asm/cmdline.h>
+
+static char sme_cmdline_arg[] __initdata = "mem_encrypt";
+static char sme_cmdline_on[]  __initdata = "on";
+static char sme_cmdline_off[] __initdata = "off";
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -190,6 +198,8 @@ void __init mem_encrypt_init(void)
 
 	/* Call into SWIOTLB to update the SWIOTLB DMA buffers */
 	swiotlb_update_mem_attributes();
+
+	pr_info("AMD Secure Memory Encryption (SME) active\n");
 }
 
 void swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
@@ -513,6 +523,71 @@ void __init sme_encrypt_kernel(void)
 	native_write_cr3(__native_read_cr3());
 }
 
-void __init sme_enable(void)
+void __init __nostackp sme_enable(struct boot_params *bp)
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
+		return;
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
+		return;
+
+	me_mask = 1UL << (ebx & 0x3f);
+
+	/* Check if SME is enabled */
+	msr = __rdmsr(MSR_K8_SYSCFG);
+	if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
+		return;
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
+	if (!strncmp(buffer, cmdline_on, sizeof(buffer)))
+		sme_me_mask = me_mask;
+	else if (!strncmp(buffer, cmdline_off, sizeof(buffer)))
+		sme_me_mask = 0;
+	else
+		sme_me_mask = active_by_default ? me_mask : 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
