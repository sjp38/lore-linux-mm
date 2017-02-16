Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F057680FFC
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:44:28 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id j49so21766788otb.7
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:44:28 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0054.outbound.protection.outlook.com. [104.47.38.54])
        by mx.google.com with ESMTPS id p36si17759otc.1.2017.02.16.07.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:44:27 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 10/28] x86: Insure that boot memory areas are mapped
 properly
Date: Thu, 16 Feb 2017 09:44:11 -0600
Message-ID: <20170216154411.19244.99258.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

The boot data and command line data are present in memory in a decrypted
state and are copied early in the boot process.  The early page fault
support will map these areas as encrypted, so before attempting to copy
them, add decrypted mappings so the data is accessed properly when copied.

For the initrd, encrypt this data in place. Since the future mapping of the
initrd area will be mapped as encrypted the data will be accessed properly.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |   11 +++++
 arch/x86/kernel/head64.c           |   34 +++++++++++++++--
 arch/x86/kernel/setup.c            |   10 +++++
 arch/x86/mm/mem_encrypt.c          |   74 ++++++++++++++++++++++++++++++++++++
 4 files changed, 126 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 3c9052c..e2b7364 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -31,6 +31,9 @@ void __init sme_early_encrypt(resource_size_t paddr,
 void __init sme_early_decrypt(resource_size_t paddr,
 			      unsigned long size);
 
+void __init sme_map_bootdata(char *real_mode_data);
+void __init sme_unmap_bootdata(char *real_mode_data);
+
 void __init sme_early_init(void);
 
 #define __sme_pa(x)		(__pa((x)) | sme_me_mask)
@@ -57,6 +60,14 @@ static inline void __init sme_early_decrypt(resource_size_t paddr,
 {
 }
 
+static inline void __init sme_map_bootdata(char *real_mode_data)
+{
+}
+
+static inline void __init sme_unmap_bootdata(char *real_mode_data)
+{
+}
+
 static inline void __init sme_early_init(void)
 {
 }
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 182a4c7..03f8e74 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -46,13 +46,18 @@ static void __init reset_early_page_tables(void)
 	write_cr3(__sme_pa_nodebug(early_level4_pgt));
 }
 
+void __init __early_pgtable_flush(void)
+{
+	write_cr3(__sme_pa_nodebug(early_level4_pgt));
+}
+
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
@@ -94,12 +99,21 @@ int __init early_make_pgtable(unsigned long address)
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
@@ -122,6 +136,12 @@ static void __init copy_bootdata(char *real_mode_data)
 	char * command_line;
 	unsigned long cmd_line_ptr;
 
+	/*
+	 * If SME is active, this will create decrypted mappings of the
+	 * boot data in advance of the copy operations.
+	 */
+	sme_map_bootdata(real_mode_data);
+
 	memcpy(&boot_params, real_mode_data, sizeof boot_params);
 	sanitize_boot_params(&boot_params);
 	cmd_line_ptr = get_cmd_line_ptr();
@@ -129,6 +149,14 @@ static void __init copy_bootdata(char *real_mode_data)
 		command_line = __va(cmd_line_ptr);
 		memcpy(boot_command_line, command_line, COMMAND_LINE_SIZE);
 	}
+
+	/*
+	 * The old boot data is no longer needed and won't be reserved,
+	 * freeing up that memory for use by the system. If SME is active,
+	 * we need to remove the mappings that were created so that the
+	 * memory doesn't remain mapped as decrypted.
+	 */
+	sme_unmap_bootdata(real_mode_data);
 }
 
 asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index cab13f7..bd5b9a7 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -114,6 +114,7 @@
 #include <asm/microcode.h>
 #include <asm/mmu_context.h>
 #include <asm/kaslr.h>
+#include <asm/mem_encrypt.h>
 
 /*
  * max_low_pfn_mapped: highest direct mapped pfn under 4GB
@@ -376,6 +377,15 @@ static void __init reserve_initrd(void)
 	    !ramdisk_image || !ramdisk_size)
 		return;		/* No initrd provided by bootloader */
 
+	/*
+	 * If SME is active, this memory will be marked encrypted by the
+	 * kernel when it is accessed (including relocation). However, the
+	 * ramdisk image was loaded decrypted by the bootloader, so make
+	 * sure that it is encrypted before accessing it.
+	 */
+	if (sme_active())
+		sme_early_encrypt(ramdisk_image, ramdisk_end - ramdisk_image);
+
 	initrd_start = 0;
 
 	mapped_size = memblock_mem_size(max_pfn_mapped);
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index ac3565c..ec548e9 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -16,8 +16,12 @@
 
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
+#include <asm/setup.h>
+#include <asm/bootparam.h>
 
 extern pmdval_t early_pmd_flags;
+int __init __early_make_pgtable(unsigned long, pmdval_t);
+void __init __early_pgtable_flush(void);
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -103,6 +107,76 @@ void __init sme_early_decrypt(resource_size_t paddr, unsigned long size)
 	__sme_early_enc_dec(paddr, size, false);
 }
 
+static void __init __sme_early_map_unmap_mem(void *vaddr, unsigned long size,
+					     bool map)
+{
+	unsigned long paddr = (unsigned long)vaddr - __PAGE_OFFSET;
+	pmdval_t pmd_flags, pmd;
+
+	/* Use early_pmd_flags but remove the encryption mask */
+	pmd_flags = early_pmd_flags & ~sme_me_mask;
+
+	do {
+		pmd = map ? (paddr & PMD_MASK) + pmd_flags : 0;
+		__early_make_pgtable((unsigned long)vaddr, pmd);
+
+		vaddr += PMD_SIZE;
+		paddr += PMD_SIZE;
+		size = (size <= PMD_SIZE) ? 0 : size - PMD_SIZE;
+	} while (size);
+}
+
+static void __init __sme_map_unmap_bootdata(char *real_mode_data, bool map)
+{
+	struct boot_params *boot_data;
+	unsigned long cmdline_paddr;
+
+	__sme_early_map_unmap_mem(real_mode_data, sizeof(boot_params), map);
+	boot_data = (struct boot_params *)real_mode_data;
+
+	/*
+	 * Determine the command line address only after having established
+	 * the decrypted mapping.
+	 */
+	cmdline_paddr = boot_data->hdr.cmd_line_ptr |
+			((u64)boot_data->ext_cmd_line_ptr << 32);
+
+	if (cmdline_paddr)
+		__sme_early_map_unmap_mem(__va(cmdline_paddr),
+					  COMMAND_LINE_SIZE, map);
+}
+
+void __init sme_unmap_bootdata(char *real_mode_data)
+{
+	/* If SME is not active, the bootdata is in the correct state */
+	if (!sme_active())
+		return;
+
+	/*
+	 * The bootdata and command line aren't needed anymore so clear
+	 * any mapping of them.
+	 */
+	__sme_map_unmap_bootdata(real_mode_data, false);
+
+	__early_pgtable_flush();
+}
+
+void __init sme_map_bootdata(char *real_mode_data)
+{
+	/* If SME is not active, the bootdata is in the correct state */
+	if (!sme_active())
+		return;
+
+	/*
+	 * The bootdata and command line will not be encrypted, so they
+	 * need to be mapped as decrypted memory so they can be copied
+	 * properly.
+	 */
+	__sme_map_unmap_bootdata(real_mode_data, true);
+
+	__early_pgtable_flush();
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
