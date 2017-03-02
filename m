Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 724656B039F
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:14:58 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id n76so74426011ioe.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:14:58 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0076.outbound.protection.outlook.com. [104.47.32.76])
        by mx.google.com with ESMTPS id i127si9235346ioi.55.2017.03.02.07.14.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:14:57 -0800 (PST)
Subject: [RFC PATCH v2 12/32] x86: Add early boot support when running with
 SEV active
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:14:48 -0500
Message-ID: <148846768878.2349.15757532025749214650.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

Early in the boot process, add checks to determine if the kernel is
running with Secure Encrypted Virtualization (SEV) active by issuing
a CPUID instruction.

During early compressed kernel booting, if SEV is active the pagetables are
updated so that data is accessed and decompressed with encryption.

During uncompressed kernel booting, if SEV is the memory encryption mask is
set and a flag is set to indicate that SEV is enabled.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/boot/compressed/Makefile      |    2 +
 arch/x86/boot/compressed/head_64.S     |   16 +++++++
 arch/x86/boot/compressed/mem_encrypt.S |   75 ++++++++++++++++++++++++++++++++
 arch/x86/include/uapi/asm/hyperv.h     |    4 ++
 arch/x86/include/uapi/asm/kvm_para.h   |    3 +
 arch/x86/kernel/mem_encrypt_init.c     |   24 ++++++++++
 6 files changed, 124 insertions(+)
 create mode 100644 arch/x86/boot/compressed/mem_encrypt.S

diff --git a/arch/x86/boot/compressed/Makefile b/arch/x86/boot/compressed/Makefile
index 44163e8..51f9cd0 100644
--- a/arch/x86/boot/compressed/Makefile
+++ b/arch/x86/boot/compressed/Makefile
@@ -72,6 +72,8 @@ vmlinux-objs-y := $(obj)/vmlinux.lds $(obj)/head_$(BITS).o $(obj)/misc.o \
 	$(obj)/string.o $(obj)/cmdline.o $(obj)/error.o \
 	$(obj)/piggy.o $(obj)/cpuflags.o
 
+vmlinux-objs-$(CONFIG_X86_64) += $(obj)/mem_encrypt.o
+
 vmlinux-objs-$(CONFIG_EARLY_PRINTK) += $(obj)/early_serial_console.o
 vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/kaslr.o
 ifdef CONFIG_X86_64
diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index d2ae1f8..625b5380 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -130,6 +130,19 @@ ENTRY(startup_32)
  /*
   * Build early 4G boot pagetable
   */
+	/*
+	 * If SEV is active set the encryption mask in the page tables. This
+	 * will insure that when the kernel is copied and decompressed it
+	 * will be done so encrypted.
+	 */
+	call	sev_enabled
+	xorl	%edx, %edx
+	testl	%eax, %eax
+	jz	1f
+	subl	$32, %eax	/* Encryption bit is always above bit 31 */
+	bts	%eax, %edx	/* Set encryption mask for page tables */
+1:
+
 	/* Initialize Page tables to 0 */
 	leal	pgtable(%ebx), %edi
 	xorl	%eax, %eax
@@ -140,12 +153,14 @@ ENTRY(startup_32)
 	leal	pgtable + 0(%ebx), %edi
 	leal	0x1007 (%edi), %eax
 	movl	%eax, 0(%edi)
+	addl	%edx, 4(%edi)
 
 	/* Build Level 3 */
 	leal	pgtable + 0x1000(%ebx), %edi
 	leal	0x1007(%edi), %eax
 	movl	$4, %ecx
 1:	movl	%eax, 0x00(%edi)
+	addl	%edx, 0x04(%edi)
 	addl	$0x00001000, %eax
 	addl	$8, %edi
 	decl	%ecx
@@ -156,6 +171,7 @@ ENTRY(startup_32)
 	movl	$0x00000183, %eax
 	movl	$2048, %ecx
 1:	movl	%eax, 0(%edi)
+	addl	%edx, 4(%edi)
 	addl	$0x00200000, %eax
 	addl	$8, %edi
 	decl	%ecx
diff --git a/arch/x86/boot/compressed/mem_encrypt.S b/arch/x86/boot/compressed/mem_encrypt.S
new file mode 100644
index 0000000..8313c31
--- /dev/null
+++ b/arch/x86/boot/compressed/mem_encrypt.S
@@ -0,0 +1,75 @@
+/*
+ * AMD Memory Encryption Support
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/linkage.h>
+
+#include <asm/processor-flags.h>
+#include <asm/msr.h>
+#include <asm/asm-offsets.h>
+#include <uapi/asm/kvm_para.h>
+
+	.text
+	.code32
+ENTRY(sev_enabled)
+	xor	%eax, %eax
+
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+	push	%ebx
+	push	%ecx
+	push	%edx
+
+	/* Check if running under a hypervisor */
+	movl	$0x40000000, %eax
+	cpuid
+	cmpl	$0x40000001, %eax
+	jb	.Lno_sev
+
+	movl	$0x40000001, %eax
+	cpuid
+	bt	$KVM_FEATURE_SEV, %eax
+	jnc	.Lno_sev
+
+	/*
+	 * Check for memory encryption feature:
+	 *   CPUID Fn8000_001F[EAX] - Bit 0
+	 */
+	movl	$0x8000001f, %eax
+	cpuid
+	bt	$0, %eax
+	jnc	.Lno_sev
+
+	/*
+	 * Get memory encryption information:
+	 *   CPUID Fn8000_001F[EBX] - Bits 5:0
+	 *     Pagetable bit position used to indicate encryption
+	 */
+	movl	%ebx, %eax
+	andl	$0x3f, %eax
+	movl	%eax, sev_enc_bit(%ebp)
+	jmp	.Lsev_exit
+
+.Lno_sev:
+	xor	%eax, %eax
+
+.Lsev_exit:
+	pop	%edx
+	pop	%ecx
+	pop	%ebx
+
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */
+
+	ret
+ENDPROC(sev_enabled)
+
+	.bss
+sev_enc_bit:
+	.word	0
diff --git a/arch/x86/include/uapi/asm/hyperv.h b/arch/x86/include/uapi/asm/hyperv.h
index 9b1a918..8278161 100644
--- a/arch/x86/include/uapi/asm/hyperv.h
+++ b/arch/x86/include/uapi/asm/hyperv.h
@@ -3,6 +3,8 @@
 
 #include <linux/types.h>
 
+#ifndef __ASSEMBLY__
+
 /*
  * The below CPUID leaves are present if VersionAndFeatures.HypervisorPresent
  * is set by CPUID(HvCpuIdFunctionVersionAndFeatures).
@@ -363,4 +365,6 @@ struct hv_timer_message_payload {
 #define HV_STIMER_AUTOENABLE		(1ULL << 3)
 #define HV_STIMER_SINT(config)		(__u8)(((config) >> 16) & 0x0F)
 
+#endif	/* __ASSEMBLY__ */
+
 #endif
diff --git a/arch/x86/include/uapi/asm/kvm_para.h b/arch/x86/include/uapi/asm/kvm_para.h
index bc2802f..e81b74a 100644
--- a/arch/x86/include/uapi/asm/kvm_para.h
+++ b/arch/x86/include/uapi/asm/kvm_para.h
@@ -26,6 +26,8 @@
 #define KVM_FEATURE_PV_UNHALT		7
 #define KVM_FEATURE_SEV			8
 
+#ifndef __ASSEMBLY__
+
 /* The last 8 bits are used to indicate how to interpret the flags field
  * in pvclock structure. If no bits are set, all flags are ignored.
  */
@@ -100,5 +102,6 @@ struct kvm_vcpu_pv_apf_data {
 #define KVM_PV_EOI_ENABLED KVM_PV_EOI_MASK
 #define KVM_PV_EOI_DISABLED 0x0
 
+#endif	/* __ASSEMBLY__ */
 
 #endif /* _UAPI_ASM_X86_KVM_PARA_H */
diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
index 35c5e3d..5d514e6 100644
--- a/arch/x86/kernel/mem_encrypt_init.c
+++ b/arch/x86/kernel/mem_encrypt_init.c
@@ -22,6 +22,7 @@
 #include <asm/processor-flags.h>
 #include <asm/msr.h>
 #include <asm/cmdline.h>
+#include <asm/kvm_para.h>
 
 static char sme_cmdline_arg_on[] __initdata = "mem_encrypt=on";
 static char sme_cmdline_arg_off[] __initdata = "mem_encrypt=off";
@@ -232,6 +233,29 @@ unsigned long __init sme_enable(void *boot_data)
 	void *cmdline_arg;
 	u64 msr;
 
+	/* Check if running under a hypervisor */
+	eax = 0x40000000;
+	ecx = 0;
+	native_cpuid(&eax, &ebx, &ecx, &edx);
+	if (eax > 0x40000000) {
+		eax = 0x40000001;
+		ecx = 0;
+		native_cpuid(&eax, &ebx, &ecx, &edx);
+		if (!(eax & BIT(KVM_FEATURE_SEV)))
+			goto out;
+
+		eax = 0x8000001f;
+		ecx = 0;
+		native_cpuid(&eax, &ebx, &ecx, &edx);
+		if (!(eax & 1))
+			goto out;
+
+		sme_me_mask = 1UL << (ebx & 0x3f);
+		sev_enabled = 1;
+
+		goto out;
+	}
+
 	/* Check for an AMD processor */
 	eax = 0;
 	ecx = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
