Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6306B02B4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 10:58:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 86so27891832pfq.11
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:58:56 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0053.outbound.protection.outlook.com. [104.47.38.53])
        by mx.google.com with ESMTPS id d23si2248208plj.559.2017.06.27.07.58.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 07:58:55 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 14/38] x86/mm: Insure that boot memory areas are mapped
 properly
Date: Tue, 27 Jun 2017 09:58:44 -0500
Message-ID: <20170627145844.15908.49837.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
References: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

The boot data and command line data are present in memory in a decrypted
state and are copied early in the boot process.  The early page fault
support will map these areas as encrypted, so before attempting to copy
them, add decrypted mappings so the data is accessed properly when copied.

For the initrd, encrypt this data in place. Since the future mapping of
the initrd area will be mapped as encrypted the data will be accessed
properly.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |    6 +++
 arch/x86/include/asm/pgtable.h     |    3 ++
 arch/x86/kernel/head64.c           |   30 +++++++++++++++--
 arch/x86/kernel/setup.c            |    9 +++++
 arch/x86/mm/kasan_init_64.c        |    2 +
 arch/x86/mm/mem_encrypt.c          |   63 ++++++++++++++++++++++++++++++++++++
 6 files changed, 108 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 8baa35b..ab1fe77 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -26,6 +26,9 @@ void __init sme_early_encrypt(resource_size_t paddr,
 void __init sme_early_decrypt(resource_size_t paddr,
 			      unsigned long size);
 
+void __init sme_map_bootdata(char *real_mode_data);
+void __init sme_unmap_bootdata(char *real_mode_data);
+
 void __init sme_early_init(void);
 
 void __init sme_encrypt_kernel(void);
@@ -40,6 +43,9 @@ static inline void __init sme_early_encrypt(resource_size_t paddr,
 static inline void __init sme_early_decrypt(resource_size_t paddr,
 					    unsigned long size) { }
 
+static inline void __init sme_map_bootdata(char *real_mode_data) { }
+static inline void __init sme_unmap_bootdata(char *real_mode_data) { }
+
 static inline void __init sme_early_init(void) { }
 
 static inline void __init sme_encrypt_kernel(void) { }
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index c6452cb..bbeae4a 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -23,6 +23,9 @@
 #ifndef __ASSEMBLY__
 #include <asm/x86_init.h>
 
+extern pgd_t early_top_pgt[PTRS_PER_PGD];
+int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
+
 void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
 void ptdump_walk_pgd_level_checkwx(void);
 
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 5cd0b72..0cdb53b 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -34,7 +34,6 @@
 /*
  * Manage page tables very early on.
  */
-extern pgd_t early_top_pgt[PTRS_PER_PGD];
 extern pmd_t early_dynamic_pgts[EARLY_DYNAMIC_PAGE_TABLES][PTRS_PER_PMD];
 static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
@@ -181,13 +180,13 @@ static void __init reset_early_page_tables(void)
 }
 
 /* Create a new PMD entry */
-int __init early_make_pgtable(unsigned long address)
+int __init __early_make_pgtable(unsigned long address, pmdval_t pmd)
 {
 	unsigned long physaddr = address - __PAGE_OFFSET;
 	pgdval_t pgd, *pgd_p;
 	p4dval_t p4d, *p4d_p;
 	pudval_t pud, *pud_p;
-	pmdval_t pmd, *pmd_p;
+	pmdval_t *pmd_p;
 
 	/* Invalid address or early pgt is done ?  */
 	if (physaddr >= MAXMEM || read_cr3_pa() != __pa_nodebug(early_top_pgt))
@@ -246,12 +245,21 @@ int __init early_make_pgtable(unsigned long address)
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
@@ -274,6 +282,12 @@ static void __init copy_bootdata(char *real_mode_data)
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
@@ -281,6 +295,14 @@ static void __init copy_bootdata(char *real_mode_data)
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
index 65622f0..31ae85e 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -69,6 +69,7 @@
 #include <linux/crash_dump.h>
 #include <linux/tboot.h>
 #include <linux/jiffies.h>
+#include <linux/mem_encrypt.h>
 
 #include <linux/usb/xhci-dbgp.h>
 #include <video/edid.h>
@@ -374,6 +375,14 @@ static void __init reserve_initrd(void)
 	    !ramdisk_image || !ramdisk_size)
 		return;		/* No initrd provided by bootloader */
 
+	/*
+	 * If SME is active, this memory will be marked encrypted by the
+	 * kernel when it is accessed (including relocation). However, the
+	 * ramdisk image was loaded decrypted by the bootloader, so make
+	 * sure that it is encrypted before accessing it.
+	 */
+	sme_early_encrypt(ramdisk_image, ramdisk_end - ramdisk_image);
+
 	initrd_start = 0;
 
 	mapped_size = memblock_mem_size(max_pfn_mapped);
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index d7cc830..1b8791f 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -11,8 +11,8 @@
 #include <asm/e820/types.h>
 #include <asm/tlbflush.h>
 #include <asm/sections.h>
+#include <asm/pgtable.h>
 
-extern pgd_t early_top_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
 static int __init map_range(struct range *range)
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 54bb73c..0843d02 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -16,6 +16,8 @@
 
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
+#include <asm/setup.h>
+#include <asm/bootparam.h>
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -98,6 +100,67 @@ void __init sme_early_decrypt(resource_size_t paddr, unsigned long size)
 	__sme_early_enc_dec(paddr, size, false);
 }
 
+static void __init __sme_early_map_unmap_mem(void *vaddr, unsigned long size,
+					     bool map)
+{
+	unsigned long paddr = (unsigned long)vaddr - __PAGE_OFFSET;
+	pmdval_t pmd_flags, pmd;
+
+	/* Use early_pmd_flags but remove the encryption mask */
+	pmd_flags = __sme_clr(early_pmd_flags);
+
+	do {
+		pmd = map ? (paddr & PMD_MASK) + pmd_flags : 0;
+		__early_make_pgtable((unsigned long)vaddr, pmd);
+
+		vaddr += PMD_SIZE;
+		paddr += PMD_SIZE;
+		size = (size <= PMD_SIZE) ? 0 : size - PMD_SIZE;
+	} while (size);
+
+	__native_flush_tlb();
+}
+
+void __init sme_unmap_bootdata(char *real_mode_data)
+{
+	struct boot_params *boot_data;
+	unsigned long cmdline_paddr;
+
+	if (!sme_active())
+		return;
+
+	/* Get the command line address before unmapping the real_mode_data */
+	boot_data = (struct boot_params *)real_mode_data;
+	cmdline_paddr = boot_data->hdr.cmd_line_ptr | ((u64)boot_data->ext_cmd_line_ptr << 32);
+
+	__sme_early_map_unmap_mem(real_mode_data, sizeof(boot_params), false);
+
+	if (!cmdline_paddr)
+		return;
+
+	__sme_early_map_unmap_mem(__va(cmdline_paddr), COMMAND_LINE_SIZE, false);
+}
+
+void __init sme_map_bootdata(char *real_mode_data)
+{
+	struct boot_params *boot_data;
+	unsigned long cmdline_paddr;
+
+	if (!sme_active())
+		return;
+
+	__sme_early_map_unmap_mem(real_mode_data, sizeof(boot_params), true);
+
+	/* Get the command line address after mapping the real_mode_data */
+	boot_data = (struct boot_params *)real_mode_data;
+	cmdline_paddr = boot_data->hdr.cmd_line_ptr | ((u64)boot_data->ext_cmd_line_ptr << 32);
+
+	if (!cmdline_paddr)
+		return;
+
+	__sme_early_map_unmap_mem(__va(cmdline_paddr), COMMAND_LINE_SIZE, true);
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
