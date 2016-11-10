Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB376B0253
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:36:28 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id hc3so75967641pac.4
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:36:28 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0058.outbound.protection.outlook.com. [104.47.40.58])
        by mx.google.com with ESMTPS id 8si1773218pgc.318.2016.11.09.16.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:36:27 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v3 09/20] x86: Insure that boot memory areas are mapped
 properly
Date: Wed, 9 Nov 2016 18:36:20 -0600
Message-ID: <20161110003620.3280.20613.stgit@tlendack-t1.amdoffice.net>
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

The boot data and command line data are present in memory in an
un-encrypted state and are copied early in the boot process.  The early
page fault support will map these areas as encrypted, so before attempting
to copy them, add unencrypted mappings so the data is accessed properly
when copied.

For the initrd, encrypt this data in place. Since the future mapping of the
initrd area will be mapped as encrypted the data will be accessed properly.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |   13 ++++++++
 arch/x86/kernel/head64.c           |   21 ++++++++++++--
 arch/x86/kernel/setup.c            |    9 ++++++
 arch/x86/mm/mem_encrypt.c          |   56 ++++++++++++++++++++++++++++++++++++
 4 files changed, 96 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 2a8e186..0b40f79 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -26,6 +26,10 @@ void __init sme_early_mem_enc(resource_size_t paddr,
 void __init sme_early_mem_dec(resource_size_t paddr,
 			      unsigned long size);
 
+void __init sme_map_bootdata(char *real_mode_data);
+void __init sme_encrypt_ramdisk(resource_size_t paddr,
+				unsigned long size);
+
 void __init sme_early_init(void);
 
 #define __sme_pa(x)		(__pa((x)) | sme_me_mask)
@@ -45,6 +49,15 @@ static inline void __init sme_early_mem_dec(resource_size_t paddr,
 {
 }
 
+static inline void __init sme_map_bootdata(char *real_mode_data)
+{
+}
+
+static inline void __init sme_encrypt_ramdisk(resource_size_t paddr,
+					      unsigned long size)
+{
+}
+
 static inline void __init sme_early_init(void)
 {
 }
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 0540789..88d137e 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -47,12 +47,12 @@ static void __init reset_early_page_tables(void)
 }
 
 /* Create a new PMD entry */
-int __init early_make_pgtable(unsigned long address)
+int __init __early_make_pgtable(unsigned long address, pmdval_t pmd)
 {
 	unsigned long physaddr = address - __PAGE_OFFSET;
 	pgdval_t pgd, *pgd_p;
 	pudval_t pud, *pud_p;
-	pmdval_t pmd, *pmd_p;
+	pmdval_t *pmd_p;
 
 	/* Invalid address or early pgt is done ?  */
 	if (physaddr >= MAXMEM || read_cr3() != __sme_pa_nodebug(early_level4_pgt))
@@ -94,12 +94,21 @@ again:
 		memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
 		*pud_p = (pudval_t)pmd_p - __START_KERNEL_map + phys_base + _KERNPG_TABLE;
 	}
-	pmd = (physaddr & PMD_MASK) + early_pmd_flags;
 	pmd_p[pmd_index(address)] = pmd;
 
 	return 0;
 }
 
+int __init early_make_pgtable(unsigned long address)
+{
+	unsigned long physaddr = address - __PAGE_OFFSET;
+	pmdval_t pmd;
+
+	pmd = (physaddr & PMD_MASK) + early_pmd_flags;
+
+	return __early_make_pgtable(address, pmd);
+}
+
 /* Don't add a printk in there. printk relies on the PDA which is not initialized 
    yet. */
 static void __init clear_bss(void)
@@ -122,6 +131,12 @@ static void __init copy_bootdata(char *real_mode_data)
 	char * command_line;
 	unsigned long cmd_line_ptr;
 
+	/*
+	 * If SME is active, this will create un-encrypted mappings of the
+	 * boot data in advance of the copy operations
+	 */
+	sme_map_bootdata(real_mode_data);
+
 	memcpy(&boot_params, real_mode_data, sizeof boot_params);
 	sanitize_boot_params(&boot_params);
 	cmd_line_ptr = get_cmd_line_ptr();
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index bbfbca5..6a991adb 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -114,6 +114,7 @@
 #include <asm/microcode.h>
 #include <asm/mmu_context.h>
 #include <asm/kaslr.h>
+#include <asm/mem_encrypt.h>
 
 /*
  * max_low_pfn_mapped: highest direct mapped pfn under 4GB
@@ -376,6 +377,14 @@ static void __init reserve_initrd(void)
 	    !ramdisk_image || !ramdisk_size)
 		return;		/* No initrd provided by bootloader */
 
+	/*
+	 * This memory will be marked encrypted by the kernel when it is
+	 * accessed (including relocation). However, the ramdisk image was
+	 * loaded un-encrypted by the bootloader, so make sure that it is
+	 * encrypted before accessing it.
+	 */
+	sme_encrypt_ramdisk(ramdisk_image, ramdisk_end - ramdisk_image);
+
 	initrd_start = 0;
 
 	mapped_size = memblock_mem_size(max_pfn_mapped);
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 06235b4..411210d 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -16,8 +16,11 @@
 
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
+#include <asm/setup.h>
+#include <asm/bootparam.h>
 
 extern pmdval_t early_pmd_flags;
+int __init __early_make_pgtable(unsigned long, pmdval_t);
 
 /*
  * Since sme_me_mask is set early in the boot process it must reside in
@@ -126,6 +129,59 @@ void __init sme_early_mem_dec(resource_size_t paddr, unsigned long size)
 	}
 }
 
+static void __init *sme_bootdata_mapping(void *vaddr, unsigned long size)
+{
+	unsigned long paddr = (unsigned long)vaddr - __PAGE_OFFSET;
+	pmdval_t pmd_flags, pmd;
+	void *ret = vaddr;
+
+	/* Use early_pmd_flags but remove the encryption mask */
+	pmd_flags = early_pmd_flags & ~sme_me_mask;
+
+	do {
+		pmd = (paddr & PMD_MASK) + pmd_flags;
+		__early_make_pgtable((unsigned long)vaddr, pmd);
+
+		vaddr += PMD_SIZE;
+		paddr += PMD_SIZE;
+		size = (size < PMD_SIZE) ? 0 : size - PMD_SIZE;
+	} while (size);
+
+	return ret;
+}
+
+void __init sme_map_bootdata(char *real_mode_data)
+{
+	struct boot_params *boot_data;
+	unsigned long cmdline_paddr;
+
+	if (!sme_me_mask)
+		return;
+
+	/*
+	 * The bootdata will not be encrypted, so it needs to be mapped
+	 * as unencrypted data so it can be copied properly.
+	 */
+	boot_data = sme_bootdata_mapping(real_mode_data, sizeof(boot_params));
+
+	/*
+	 * Determine the command line address only after having established
+	 * the unencrypted mapping.
+	 */
+	cmdline_paddr = boot_data->hdr.cmd_line_ptr |
+			((u64)boot_data->ext_cmd_line_ptr << 32);
+	if (cmdline_paddr)
+		sme_bootdata_mapping(__va(cmdline_paddr), COMMAND_LINE_SIZE);
+}
+
+void __init sme_encrypt_ramdisk(resource_size_t paddr, unsigned long size)
+{
+	if (!sme_me_mask)
+		return;
+
+	sme_early_mem_enc(paddr, size);
+}
+
 void __init sme_early_init(void)
 {
 	unsigned int i;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
