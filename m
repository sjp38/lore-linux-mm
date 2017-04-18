Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29B052806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:19:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c2so2686620pfd.9
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:19:27 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0061.outbound.protection.outlook.com. [104.47.40.61])
        by mx.google.com with ESMTPS id s21si278667pgi.287.2017.04.18.14.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:19:26 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 17/32] x86/mm: Add support to access boot related data in
 the clear
Date: Tue, 18 Apr 2017 16:19:21 -0500
Message-ID: <20170418211921.10190.1537.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Boot data (such as EFI related data) is not encrypted when the system is
booted because UEFI/BIOS does not run with SME active. In order to access
this data properly it needs to be mapped decrypted.

The early_memremap() support is updated to provide an arch specific
routine to modify the pagetable protection attributes before they are
applied to the new mapping. This is used to remove the encryption mask
for boot related data.

The memremap() support is updated to provide an arch specific routine
to determine if RAM remapping is allowed.  RAM remapping will cause an
encrypted mapping to be generated. By preventing RAM remapping,
ioremap_cache() will be used instead, which will provide a decrypted
mapping of the boot related data.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/io.h |    4 +
 arch/x86/mm/ioremap.c     |  182 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/io.h        |    2 
 kernel/memremap.c         |   20 ++++-
 mm/early_ioremap.c        |   18 ++++
 5 files changed, 219 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 7afb0e2..75f2858 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -381,4 +381,8 @@ extern int __must_check arch_phys_wc_add(unsigned long base,
 #define arch_io_reserve_memtype_wc arch_io_reserve_memtype_wc
 #endif
 
+extern bool arch_memremap_do_ram_remap(resource_size_t offset, size_t size,
+				       unsigned long flags);
+#define arch_memremap_do_ram_remap arch_memremap_do_ram_remap
+
 #endif /* _ASM_X86_IO_H */
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 9bfcb1f..bce0604 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -13,6 +13,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/mmiotrace.h>
+#include <linux/efi.h>
 
 #include <asm/cacheflush.h>
 #include <asm/e820/api.h>
@@ -21,6 +22,7 @@
 #include <asm/tlbflush.h>
 #include <asm/pgalloc.h>
 #include <asm/pat.h>
+#include <asm/setup.h>
 
 #include "physaddr.h"
 
@@ -419,6 +421,186 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
 	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
 }
 
+/*
+ * Examine the physical address to determine if it is an area of memory
+ * that should be mapped decrypted.  If the memory is not part of the
+ * kernel usable area it was accessed and created decrypted, so these
+ * areas should be mapped decrypted.
+ */
+static bool memremap_should_map_decrypted(resource_size_t phys_addr,
+					  unsigned long size)
+{
+	/* Check if the address is outside kernel usable area */
+	switch (e820__get_entry_type(phys_addr, phys_addr + size - 1)) {
+	case E820_TYPE_RESERVED:
+	case E820_TYPE_ACPI:
+	case E820_TYPE_NVS:
+	case E820_TYPE_UNUSABLE:
+		return true;
+	default:
+		break;
+	}
+
+	return false;
+}
+
+/*
+ * Examine the physical address to determine if it is EFI data. Check
+ * it against the boot params structure and EFI tables and memory types.
+ */
+static bool memremap_is_efi_data(resource_size_t phys_addr,
+				 unsigned long size)
+{
+	u64 paddr;
+
+	/* Check if the address is part of EFI boot/runtime data */
+	if (efi_enabled(EFI_BOOT)) {
+		paddr = boot_params.efi_info.efi_memmap_hi;
+		paddr <<= 32;
+		paddr |= boot_params.efi_info.efi_memmap;
+		if (phys_addr == paddr)
+			return true;
+
+		paddr = boot_params.efi_info.efi_systab_hi;
+		paddr <<= 32;
+		paddr |= boot_params.efi_info.efi_systab;
+		if (phys_addr == paddr)
+			return true;
+
+		if (efi_table_address_match(phys_addr))
+			return true;
+
+		switch (efi_mem_type(phys_addr)) {
+		case EFI_BOOT_SERVICES_DATA:
+		case EFI_RUNTIME_SERVICES_DATA:
+			return true;
+		default:
+			break;
+		}
+	}
+
+	return false;
+}
+
+/*
+ * Examine the physical address to determine if it is boot data by checking
+ * it against the boot params setup_data chain.
+ */
+static bool memremap_is_setup_data(resource_size_t phys_addr,
+				   unsigned long size)
+{
+	struct setup_data *data;
+	u64 paddr, paddr_next;
+
+	paddr = boot_params.hdr.setup_data;
+	while (paddr) {
+		bool is_setup_data = false;
+
+		if (phys_addr == paddr)
+			return true;
+
+		data = memremap(paddr, sizeof(*data),
+				MEMREMAP_WB | MEMREMAP_DEC);
+
+		paddr_next = data->next;
+
+		if ((phys_addr > paddr) && (phys_addr < (paddr + data->len)))
+			is_setup_data = true;
+
+		memunmap(data);
+
+		if (is_setup_data)
+			return true;
+
+		paddr = paddr_next;
+	}
+
+	return false;
+}
+
+/*
+ * Examine the physical address to determine if it is boot data by checking
+ * it against the boot params setup_data chain (early boot version).
+ */
+static bool __init early_memremap_is_setup_data(resource_size_t phys_addr,
+						unsigned long size)
+{
+	struct setup_data *data;
+	u64 paddr, paddr_next;
+
+	paddr = boot_params.hdr.setup_data;
+	while (paddr) {
+		bool is_setup_data = false;
+
+		if (phys_addr == paddr)
+			return true;
+
+		data = early_memremap_decrypted(paddr, sizeof(*data));
+
+		paddr_next = data->next;
+
+		if ((phys_addr > paddr) && (phys_addr < (paddr + data->len)))
+			is_setup_data = true;
+
+		early_memunmap(data, sizeof(*data));
+
+		if (is_setup_data)
+			return true;
+
+		paddr = paddr_next;
+	}
+
+	return false;
+}
+
+/*
+ * Architecture function to determine if RAM remap is allowed. By default, a
+ * RAM remap will map the data as encrypted. Determine if a RAM remap should
+ * not be done so that the data will be mapped decrypted.
+ */
+bool arch_memremap_do_ram_remap(resource_size_t phys_addr, unsigned long size,
+				unsigned long flags)
+{
+	if (!sme_active())
+		return true;
+
+	if (flags & MEMREMAP_ENC)
+		return true;
+
+	if (flags & MEMREMAP_DEC)
+		return false;
+
+	if (memremap_is_setup_data(phys_addr, size) ||
+	    memremap_is_efi_data(phys_addr, size) ||
+	    memremap_should_map_decrypted(phys_addr, size))
+		return false;
+
+	return true;
+}
+
+/*
+ * Architecture override of __weak function to adjust the protection attributes
+ * used when remapping memory. By default, early_memremp() will map the data
+ * as encrypted. Determine if an encrypted mapping should not be done and set
+ * the appropriate protection attributes.
+ */
+pgprot_t __init early_memremap_pgprot_adjust(resource_size_t phys_addr,
+					     unsigned long size,
+					     pgprot_t prot)
+{
+	if (!sme_active())
+		return prot;
+
+	if (early_memremap_is_setup_data(phys_addr, size) ||
+	    memremap_is_efi_data(phys_addr, size) ||
+	    memremap_should_map_decrypted(phys_addr, size))
+		prot = pgprot_decrypted(prot);
+	else
+		prot = pgprot_encrypted(prot);
+
+	return prot;
+}
+
 #ifdef CONFIG_ARCH_USE_MEMREMAP_PROT
 /* Remap memory with encryption */
 void __init *early_memremap_encrypted(resource_size_t phys_addr,
diff --git a/include/linux/io.h b/include/linux/io.h
index 82ef36e..deaeb1d 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -136,6 +136,8 @@ enum {
 	MEMREMAP_WB = 1 << 0,
 	MEMREMAP_WT = 1 << 1,
 	MEMREMAP_WC = 1 << 2,
+	MEMREMAP_ENC = 1 << 3,
+	MEMREMAP_DEC = 1 << 4,
 };
 
 void *memremap(resource_size_t offset, size_t size, unsigned long flags);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 07e85e5..2361bf7 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -34,13 +34,24 @@ static void *arch_memremap_wb(resource_size_t offset, unsigned long size)
 }
 #endif
 
-static void *try_ram_remap(resource_size_t offset, size_t size)
+#ifndef arch_memremap_do_ram_remap
+static bool arch_memremap_do_ram_remap(resource_size_t offset, size_t size,
+				       unsigned long flags)
+{
+	return true;
+}
+#endif
+
+static void *try_ram_remap(resource_size_t offset, size_t size,
+			   unsigned long flags)
 {
 	unsigned long pfn = PHYS_PFN(offset);
 
 	/* In the simple case just return the existing linear address */
-	if (pfn_valid(pfn) && !PageHighMem(pfn_to_page(pfn)))
+	if (pfn_valid(pfn) && !PageHighMem(pfn_to_page(pfn)) &&
+	    arch_memremap_do_ram_remap(offset, size, flags))
 		return __va(offset);
+
 	return NULL; /* fallback to arch_memremap_wb */
 }
 
@@ -48,7 +59,8 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
  * memremap() - remap an iomem_resource as cacheable memory
  * @offset: iomem resource start address
  * @size: size of remap
- * @flags: any of MEMREMAP_WB, MEMREMAP_WT and MEMREMAP_WC
+ * @flags: any of MEMREMAP_WB, MEMREMAP_WT, MEMREMAP_WC,
+ *		  MEMREMAP_ENC, MEMREMAP_DEC
  *
  * memremap() is "ioremap" for cases where it is known that the resource
  * being mapped does not have i/o side effects and the __iomem
@@ -95,7 +107,7 @@ void *memremap(resource_size_t offset, size_t size, unsigned long flags)
 		 * the requested range is potentially in System RAM.
 		 */
 		if (is_ram == REGION_INTERSECTS)
-			addr = try_ram_remap(offset, size);
+			addr = try_ram_remap(offset, size, flags);
 		if (!addr)
 			addr = arch_memremap_wb(offset, size);
 	}
diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index d7d30da..b1dd4a9 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -30,6 +30,13 @@ static int __init early_ioremap_debug_setup(char *str)
 
 static int after_paging_init __initdata;
 
+pgprot_t __init __weak early_memremap_pgprot_adjust(resource_size_t phys_addr,
+						    unsigned long size,
+						    pgprot_t prot)
+{
+	return prot;
+}
+
 void __init __weak early_ioremap_shutdown(void)
 {
 }
@@ -215,14 +222,19 @@ void __init early_iounmap(void __iomem *addr, unsigned long size)
 void __init *
 early_memremap(resource_size_t phys_addr, unsigned long size)
 {
-	return (__force void *)__early_ioremap(phys_addr, size,
-					       FIXMAP_PAGE_NORMAL);
+	pgprot_t prot = early_memremap_pgprot_adjust(phys_addr, size,
+						     FIXMAP_PAGE_NORMAL);
+
+	return (__force void *)__early_ioremap(phys_addr, size, prot);
 }
 #ifdef FIXMAP_PAGE_RO
 void __init *
 early_memremap_ro(resource_size_t phys_addr, unsigned long size)
 {
-	return (__force void *)__early_ioremap(phys_addr, size, FIXMAP_PAGE_RO);
+	pgprot_t prot = early_memremap_pgprot_adjust(phys_addr, size,
+						     FIXMAP_PAGE_RO);
+
+	return (__force void *)__early_ioremap(phys_addr, size, prot);
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
