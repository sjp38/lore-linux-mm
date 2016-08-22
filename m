Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F11082F66
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:27:05 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m184so262809433qkb.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:27:05 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0089.outbound.protection.outlook.com. [104.47.33.89])
        by mx.google.com with ESMTPS id 19si334910qku.247.2016.08.22.16.27.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:27:04 -0700 (PDT)
Subject: [RFC PATCH v1 16/28] x86: Add support to determine if running with
 SEV enabled
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:26:53 -0400
Message-ID: <147190841304.9523.5026893722385181494.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

Early in the boot process, add a check to determine if the kernel is
running with Secure Encrypted Virtualization (SEV) enabled. If active,
the kernel will perform steps necessary to insure the proper kernel
initialization process is performed.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/boot/compressed/Makefile      |    2 +
 arch/x86/boot/compressed/head_64.S     |   19 +++++
 arch/x86/boot/compressed/mem_encrypt.S |  123 ++++++++++++++++++++++++++++++++
 arch/x86/include/uapi/asm/hyperv.h     |    4 +
 arch/x86/include/uapi/asm/kvm_para.h   |    3 +
 arch/x86/kernel/mem_encrypt.S          |   36 +++++++++
 6 files changed, 187 insertions(+)
 create mode 100644 arch/x86/boot/compressed/mem_encrypt.S

diff --git a/arch/x86/boot/compressed/Makefile b/arch/x86/boot/compressed/Makefile
index 536ccfc..4888df9 100644
--- a/arch/x86/boot/compressed/Makefile
+++ b/arch/x86/boot/compressed/Makefile
@@ -73,6 +73,8 @@ vmlinux-objs-y := $(obj)/vmlinux.lds $(obj)/head_$(BITS).o $(obj)/misc.o \
 	$(obj)/string.o $(obj)/cmdline.o $(obj)/error.o \
 	$(obj)/piggy.o $(obj)/cpuflags.o
 
+vmlinux-objs-$(CONFIG_X86_64) += $(obj)/mem_encrypt.o
+
 vmlinux-objs-$(CONFIG_EARLY_PRINTK) += $(obj)/early_serial_console.o
 vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/kaslr.o
 ifdef CONFIG_X86_64
diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index 0d80a7a..acb907a 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -131,6 +131,19 @@ ENTRY(startup_32)
  /*
   * Build early 4G boot pagetable
   */
+	/*
+	 * If SEV is active set the encryption mask in the page tables. This
+	 * will insure that when the kernel is copied and decompressed it
+	 * will be done so encrypted.
+	 */
+	call	sev_active
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
@@ -141,12 +154,14 @@ ENTRY(startup_32)
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
@@ -157,6 +172,7 @@ ENTRY(startup_32)
 	movl	$0x00000183, %eax
 	movl	$2048, %ecx
 1:	movl	%eax, 0(%edi)
+	addl	%edx, 4(%edi)
 	addl	$0x00200000, %eax
 	addl	$8, %edi
 	decl	%ecx
@@ -344,6 +360,9 @@ preferred_addr:
 	subl	$_end, %ebx
 	addq	%rbp, %rbx
 
+	/* Check for SEV and adjust page tables as necessary */
+	call	sev_adjust
+
 	/* Set up the stack */
 	leaq	boot_stack_end(%rbx), %rsp
 
diff --git a/arch/x86/boot/compressed/mem_encrypt.S b/arch/x86/boot/compressed/mem_encrypt.S
new file mode 100644
index 0000000..56e19f6
--- /dev/null
+++ b/arch/x86/boot/compressed/mem_encrypt.S
@@ -0,0 +1,123 @@
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
+ENTRY(sev_active)
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
+ENDPROC(sev_active)
+
+	.code64
+ENTRY(sev_adjust)
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+	push	%rax
+	push	%rbx
+	push	%rcx
+	push	%rdx
+
+	/* Check if running under a hypervisor */
+	movl	$0x40000000, %eax
+	cpuid
+	cmpl	$0x40000001, %eax
+	jb	.Lno_adjust
+
+	movl	$0x40000001, %eax
+	cpuid
+	bt	$KVM_FEATURE_SEV, %eax
+	jnc	.Lno_adjust
+
+	/*
+	 * Check for memory encryption feature:
+	 *   CPUID Fn8000_001F[EAX] - Bit 0
+	 */
+	movl	$0x8000001f, %eax
+	cpuid
+	bt	$0, %eax
+	jnc	.Lno_adjust
+
+	/*
+	 * Get memory encryption information:
+	 *   CPUID Fn8000_001F[EBX] - Bits 5:0
+	 *     Pagetable bit position used to indicate encryption
+	 */
+	movl	%ebx, %ecx
+	andl	$0x3f, %ecx
+	jz	.Lno_adjust
+
+	/*
+	 * Adjust/verify the page table entries to include the encryption
+	 * mask for the area where the compressed kernel is copied and
+	 * the area the kernel is decompressed into
+	 */
+
+.Lno_adjust:
+	pop	%rdx
+	pop	%rcx
+	pop	%rbx
+	pop	%rax
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */
+
+	ret
+ENDPROC(sev_adjust)
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
index 67dd610f..5788561 100644
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
@@ -98,5 +100,6 @@ struct kvm_vcpu_pv_apf_data {
 #define KVM_PV_EOI_ENABLED KVM_PV_EOI_MASK
 #define KVM_PV_EOI_DISABLED 0x0
 
+#endif	/* __ASSEMBLY__ */
 
 #endif /* _UAPI_ASM_X86_KVM_PARA_H */
diff --git a/arch/x86/kernel/mem_encrypt.S b/arch/x86/kernel/mem_encrypt.S
index 6a8cd18..78fc608 100644
--- a/arch/x86/kernel/mem_encrypt.S
+++ b/arch/x86/kernel/mem_encrypt.S
@@ -17,11 +17,47 @@
 #include <asm/page.h>
 #include <asm/msr.h>
 #include <asm/asm-offsets.h>
+#include <uapi/asm/kvm_para.h>
 
 	.text
 	.code64
 ENTRY(sme_enable)
 #ifdef CONFIG_AMD_MEM_ENCRYPT
+	/* Check if running under a hypervisor */
+	movl	$0x40000000, %eax
+	cpuid
+	cmpl	$0x40000001, %eax
+	jb	.Lno_hyp
+
+	movl	$0x40000001, %eax
+	cpuid
+	bt	$KVM_FEATURE_SEV, %eax
+	jnc	.Lno_mem_encrypt
+
+	/*
+	 * Check for memory encryption feature:
+	 *   CPUID Fn8000_001F[EAX] - Bit 0
+	 */
+	movl	$0x8000001f, %eax
+	cpuid
+	bt	$0, %eax
+	jnc	.Lno_mem_encrypt
+
+	/*
+	 * Get memory encryption information:
+	 *   CPUID Fn8000_001F[EBX] - Bits 5:0
+	 *     Pagetable bit position used to indicate encryption
+	 */
+	movl	%ebx, %ecx
+	andl	$0x3f, %ecx
+	jz	.Lno_mem_encrypt
+	bts	%ecx, sme_me_mask(%rip)
+
+	/* Indicate that SEV is active */
+	movl	$1, sev_active(%rip)
+	jmp	.Lmem_encrypt_exit
+
+.Lno_hyp:
 	/* Check for AMD processor */
 	xorl	%eax, %eax
 	cpuid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
