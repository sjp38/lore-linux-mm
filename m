Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AEE883293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 14:51:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s74so44195278pfe.10
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:51:27 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0089.outbound.protection.outlook.com. [104.47.33.89])
        by mx.google.com with ESMTPS id a27si2642885pgd.345.2017.06.16.11.51.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 11:51:25 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v7 08/36] x86/mm: Add support to enable SME in early boot
 processing
Date: Fri, 16 Jun 2017 13:51:15 -0500
Message-ID: <20170616185115.18967.79622.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Add support to the early boot code to use Secure Memory Encryption (SME).
Since the kernel has been loaded into memory in a decrypted state, encrypt
the kernel in place and update the early pagetables with the memory
encryption mask so that new pagetable entries will use memory encryption.

The routines to set the encryption mask and perform the encryption are
stub routines for now with functionality to be added in a later patch.

Because of the need to have the routines available to head_64.S, the
mem_encrypt.c is always built and #ifdefs in mem_encrypt.c will provide
functionality or stub routines depending on CONFIG_AMD_MEM_ENCRYPT.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |    8 +++++++
 arch/x86/kernel/head64.c           |   33 +++++++++++++++++++++---------
 arch/x86/kernel/head_64.S          |   39 ++++++++++++++++++++++++++++++++++--
 arch/x86/mm/Makefile               |    4 +---
 arch/x86/mm/mem_encrypt.c          |   24 ++++++++++++++++++++++
 5 files changed, 93 insertions(+), 15 deletions(-)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index a105796..988b336 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -15,16 +15,24 @@
 
 #ifndef __ASSEMBLY__
 
+#include <linux/init.h>
+
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
 extern unsigned long sme_me_mask;
 
+void __init sme_enable(void);
+
 #else	/* !CONFIG_AMD_MEM_ENCRYPT */
 
 #define sme_me_mask	0UL
 
+static inline void __init sme_enable(void) { }
+
 #endif	/* CONFIG_AMD_MEM_ENCRYPT */
 
+unsigned long sme_get_me_mask(void);
+
 #endif	/* __ASSEMBLY__ */
 
 #endif	/* __X86_MEM_ENCRYPT_H__ */
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 2b2ac38..95979c3 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -14,6 +14,7 @@
 #include <linux/start_kernel.h>
 #include <linux/io.h>
 #include <linux/memblock.h>
+#include <linux/mem_encrypt.h>
 
 #include <asm/processor.h>
 #include <asm/proto.h>
@@ -46,6 +47,7 @@ static void __init *fixup_pointer(void *ptr, unsigned long physaddr)
 void __init __startup_64(unsigned long physaddr)
 {
 	unsigned long load_delta, *p;
+	unsigned long pgtable_flags;
 	pgdval_t *pgd;
 	p4dval_t *p4d;
 	pudval_t *pud;
@@ -66,6 +68,12 @@ void __init __startup_64(unsigned long physaddr)
 	if (load_delta & ~PMD_PAGE_MASK)
 		for (;;);
 
+	/* Activate Secure Memory Encryption (SME) if supported and enabled */
+	sme_enable();
+
+	/* Include the SME encryption mask in the fixup value */
+	load_delta += sme_get_me_mask();
+
 	/* Fixup the physical addresses in the page table */
 
 	pgd = fixup_pointer(&early_top_pgt, physaddr);
@@ -92,28 +100,30 @@ void __init __startup_64(unsigned long physaddr)
 
 	pud = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 	pmd = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
+	pgtable_flags = _KERNPG_TABLE + sme_get_me_mask();
 
 	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
 		p4d = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 
 		i = (physaddr >> PGDIR_SHIFT) % PTRS_PER_PGD;
-		pgd[i + 0] = (pgdval_t)p4d + _KERNPG_TABLE;
-		pgd[i + 1] = (pgdval_t)p4d + _KERNPG_TABLE;
+		pgd[i + 0] = (pgdval_t)p4d + pgtable_flags;
+		pgd[i + 1] = (pgdval_t)p4d + pgtable_flags;
 
 		i = (physaddr >> P4D_SHIFT) % PTRS_PER_P4D;
-		p4d[i + 0] = (pgdval_t)pud + _KERNPG_TABLE;
-		p4d[i + 1] = (pgdval_t)pud + _KERNPG_TABLE;
+		p4d[i + 0] = (pgdval_t)pud + pgtable_flags;
+		p4d[i + 1] = (pgdval_t)pud + pgtable_flags;
 	} else {
 		i = (physaddr >> PGDIR_SHIFT) % PTRS_PER_PGD;
-		pgd[i + 0] = (pgdval_t)pud + _KERNPG_TABLE;
-		pgd[i + 1] = (pgdval_t)pud + _KERNPG_TABLE;
+		pgd[i + 0] = (pgdval_t)pud + pgtable_flags;
+		pgd[i + 1] = (pgdval_t)pud + pgtable_flags;
 	}
 
 	i = (physaddr >> PUD_SHIFT) % PTRS_PER_PUD;
-	pud[i + 0] = (pudval_t)pmd + _KERNPG_TABLE;
-	pud[i + 1] = (pudval_t)pmd + _KERNPG_TABLE;
+	pud[i + 0] = (pudval_t)pmd + pgtable_flags;
+	pud[i + 1] = (pudval_t)pmd + pgtable_flags;
 
 	pmd_entry = __PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL;
+	pmd_entry += sme_get_me_mask();
 	pmd_entry +=  physaddr;
 
 	for (i = 0; i < DIV_ROUND_UP(_end - _text, PMD_SIZE); i++) {
@@ -134,9 +144,12 @@ void __init __startup_64(unsigned long physaddr)
 			pmd[i] += load_delta;
 	}
 
-	/* Fixup phys_base */
+	/*
+	 * Fixup phys_base - remove the memory encryption mask to obtain
+	 * the true physical address.
+	 */
 	p = fixup_pointer(&phys_base, physaddr);
-	*p += load_delta;
+	*p += load_delta - sme_get_me_mask();
 }
 
 /* Wipe all early page tables except for the kernel symbol map */
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 6225550..ef12729 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -78,7 +78,29 @@ startup_64:
 	call	__startup_64
 	popq	%rsi
 
-	movq	$(early_top_pgt - __START_KERNEL_map), %rax
+	/*
+	 * Encrypt the kernel if SME is active.
+	 * The real_mode_data address is in %rsi and that register can be
+	 * clobbered by the called function so be sure to save it.
+	 */
+	push	%rsi
+	call	sme_encrypt_kernel
+	pop	%rsi
+
+	/*
+	 * Get the SME encryption mask.
+	 *  The encryption mask will be returned in %rax so we do an ADD
+	 *  below to be sure that the encryption mask is part of the
+	 *  value that will stored in %cr3.
+	 *
+	 * The real_mode_data address is in %rsi and that register can be
+	 * clobbered by the called function so be sure to save it.
+	 */
+	push	%rsi
+	call	sme_get_me_mask
+	pop	%rsi
+
+	addq	$(early_top_pgt - __START_KERNEL_map), %rax
 	jmp 1f
 ENTRY(secondary_startup_64)
 	/*
@@ -98,7 +120,20 @@ ENTRY(secondary_startup_64)
 	/* Sanitize CPU configuration */
 	call verify_cpu
 
-	movq	$(init_top_pgt - __START_KERNEL_map), %rax
+	/*
+	 * Get the SME encryption mask.
+	 *  The encryption mask will be returned in %rax so we do an ADD
+	 *  below to be sure that the encryption mask is part of the
+	 *  value that will stored in %cr3.
+	 *
+	 * The real_mode_data address is in %rsi and that register can be
+	 * clobbered by the called function so be sure to save it.
+	 */
+	push	%rsi
+	call	sme_get_me_mask
+	pop	%rsi
+
+	addq	$(init_top_pgt - __START_KERNEL_map), %rax
 1:
 
 	/* Enable PAE mode, PGE and LA57 */
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index a94a7b6..9e13841 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -2,7 +2,7 @@
 KCOV_INSTRUMENT_tlb.o	:= n
 
 obj-y	:=  init.o init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o \
-	    pat.o pgtable.o physaddr.o setup_nx.o tlb.o
+	    pat.o pgtable.o physaddr.o setup_nx.o tlb.o mem_encrypt.o
 
 # Make sure __phys_addr has no stackprotector
 nostackp := $(call cc-option, -fno-stack-protector)
@@ -38,5 +38,3 @@ obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
 obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
 obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
 obj-$(CONFIG_RANDOMIZE_MEMORY) += kaslr.o
-
-obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index b99d469..9a78277 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -11,6 +11,9 @@
  */
 
 #include <linux/linkage.h>
+#include <linux/init.h>
+
+#ifdef CONFIG_AMD_MEM_ENCRYPT
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -19,3 +22,24 @@
  */
 unsigned long sme_me_mask __section(.data) = 0;
 EXPORT_SYMBOL_GPL(sme_me_mask);
+
+void __init sme_encrypt_kernel(void)
+{
+}
+
+void __init sme_enable(void)
+{
+}
+
+unsigned long sme_get_me_mask(void)
+{
+	return sme_me_mask;
+}
+
+#else	/* !CONFIG_AMD_MEM_ENCRYPT */
+
+void __init sme_encrypt_kernel(void)	{ }
+
+unsigned long sme_get_me_mask(void)	{ return 0; }
+
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
