Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 54FC76B03B9
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:08:54 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id p135so20894686ita.11
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:08:54 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0046.outbound.protection.outlook.com. [104.47.41.46])
        by mx.google.com with ESMTPS id t206si3108664iod.121.2017.06.27.08.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:08:53 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 RESEND 08/38] x86/mm: Add support to enable SME in early
 boot processing
Date: Tue, 27 Jun 2017 10:08:43 -0500
Message-ID: <20170627150843.17428.77939.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
References: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
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

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |    8 +++++
 arch/x86/kernel/head64.c           |   53 +++++++++++++++++++++++++++++-------
 arch/x86/kernel/head_64.S          |   20 ++++++++++++--
 arch/x86/mm/mem_encrypt.c          |    9 ++++++
 include/linux/mem_encrypt.h        |    5 +++
 5 files changed, 82 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index a105796..475e34f 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -15,14 +15,22 @@
 
 #ifndef __ASSEMBLY__
 
+#include <linux/init.h>
+
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
 extern unsigned long sme_me_mask;
 
+void __init sme_encrypt_kernel(void);
+void __init sme_enable(void);
+
 #else	/* !CONFIG_AMD_MEM_ENCRYPT */
 
 #define sme_me_mask	0UL
 
+static inline void __init sme_encrypt_kernel(void) { }
+static inline void __init sme_enable(void) { }
+
 #endif	/* CONFIG_AMD_MEM_ENCRYPT */
 
 #endif	/* __ASSEMBLY__ */
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 46c3c73..1f0ddcc 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -14,6 +14,7 @@
 #include <linux/start_kernel.h>
 #include <linux/io.h>
 #include <linux/memblock.h>
+#include <linux/mem_encrypt.h>
 
 #include <asm/processor.h>
 #include <asm/proto.h>
@@ -45,9 +46,10 @@ static void __head *fixup_pointer(void *ptr, unsigned long physaddr)
 	return ptr - (void *)_text + (void *)physaddr;
 }
 
-void __head __startup_64(unsigned long physaddr)
+unsigned long __head __startup_64(unsigned long physaddr)
 {
 	unsigned long load_delta, *p;
+	unsigned long pgtable_flags;
 	pgdval_t *pgd;
 	p4dval_t *p4d;
 	pudval_t *pud;
@@ -68,6 +70,12 @@ void __head __startup_64(unsigned long physaddr)
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
@@ -94,28 +102,30 @@ void __head __startup_64(unsigned long physaddr)
 
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
@@ -136,9 +146,30 @@ void __head __startup_64(unsigned long physaddr)
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
+
+	/* Encrypt the kernel (if SME is active) */
+	sme_encrypt_kernel();
+
+	/*
+	 * Return the SME encryption mask (if SME is active) to be used as a
+	 * modifier for the initial pgdir entry programmed into CR3.
+	 */
+	return sme_get_me_mask();
+}
+
+unsigned long __startup_secondary_64(void)
+{
+	/*
+	 * Return the SME encryption mask (if SME is active) to be used as a
+	 * modifier for the initial pgdir entry programmed into CR3.
+	 */
+	return sme_get_me_mask();
 }
 
 /* Wipe all early page tables except for the kernel symbol map */
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 6225550..ec5d5e9 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -73,12 +73,19 @@ startup_64:
 	/* Sanitize CPU configuration */
 	call verify_cpu
 
+	/*
+	 * Perform pagetable fixups. Additionally, if SME is active, encrypt
+	 * the kernel and retrieve the modifier (SME encryption mask if SME
+	 * is active) to be added to the initial pgdir entry that will be
+	 * programmed into CR3.
+	 */
 	leaq	_text(%rip), %rdi
 	pushq	%rsi
 	call	__startup_64
 	popq	%rsi
 
-	movq	$(early_top_pgt - __START_KERNEL_map), %rax
+	/* Form the CR3 value being sure to include the CR3 modifier */
+	addq	$(early_top_pgt - __START_KERNEL_map), %rax
 	jmp 1f
 ENTRY(secondary_startup_64)
 	/*
@@ -98,7 +105,16 @@ ENTRY(secondary_startup_64)
 	/* Sanitize CPU configuration */
 	call verify_cpu
 
-	movq	$(init_top_pgt - __START_KERNEL_map), %rax
+	/*
+	 * Retrieve the modifier (SME encryption mask if SME is active) to be
+	 * added to the initial pgdir entry that will be programmed into CR3.
+	 */
+	pushq	%rsi
+	call	__startup_secondary_64
+	popq	%rsi
+
+	/* Form the CR3 value being sure to include the CR3 modifier */
+	addq	$(init_top_pgt - __START_KERNEL_map), %rax
 1:
 
 	/* Enable PAE mode, PGE and LA57 */
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index b99d469..3ac6f99 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -11,6 +11,7 @@
  */
 
 #include <linux/linkage.h>
+#include <linux/init.h>
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -19,3 +20,11 @@
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
diff --git a/include/linux/mem_encrypt.h b/include/linux/mem_encrypt.h
index 59769f7..570f4fc 100644
--- a/include/linux/mem_encrypt.h
+++ b/include/linux/mem_encrypt.h
@@ -30,6 +30,11 @@ static inline bool sme_active(void)
 	return !!sme_me_mask;
 }
 
+static inline unsigned long sme_get_me_mask(void)
+{
+	return sme_me_mask;
+}
+
 #endif	/* __ASSEMBLY__ */
 
 #endif	/* __MEM_ENCRYPT_H__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
