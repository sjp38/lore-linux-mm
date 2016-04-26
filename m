Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51A186B0264
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:47:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id t184so66395664qkh.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:47:13 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0056.outbound.protection.outlook.com. [65.55.169.56])
        by mx.google.com with ESMTPS id w10si684386qge.23.2016.04.26.15.47.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:47:12 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the clear
Date: Tue, 26 Apr 2016 17:47:01 -0500
Message-ID: <20160426224701.13079.81848.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160426224508.13079.90373.stgit@tlendack-t1.amdoffice.net>
References: <20160426224508.13079.90373.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander
 Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry
 Vyukov <dvyukov@google.com>

The EFI tables are not encrypted and need to be accessed as such. Be sure
to memmap them without the encryption attribute set. For EFI support that
lives outside of the arch/x86 tree, create a routine that uses the __weak
attribute so that it can be overridden by an architecture specific routine.

When freeing boot services related memory, since it has been mapped as
un-encrypted, be sure to change the mapping to encrypted for future use.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cacheflush.h  |    3 +
 arch/x86/include/asm/mem_encrypt.h |   22 +++++++++++
 arch/x86/kernel/setup.c            |    6 +--
 arch/x86/mm/mem_encrypt.c          |   56 +++++++++++++++++++++++++++
 arch/x86/mm/pageattr.c             |   75 ++++++++++++++++++++++++++++++++++++
 arch/x86/platform/efi/efi.c        |   26 +++++++-----
 arch/x86/platform/efi/efi_64.c     |    9 +++-
 arch/x86/platform/efi/quirks.c     |   12 +++++-
 drivers/firmware/efi/efi.c         |   18 +++++++--
 drivers/firmware/efi/esrt.c        |   12 +++---
 include/linux/efi.h                |    3 +
 11 files changed, 212 insertions(+), 30 deletions(-)

diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
index 61518cf..bfb08e5 100644
--- a/arch/x86/include/asm/cacheflush.h
+++ b/arch/x86/include/asm/cacheflush.h
@@ -13,6 +13,7 @@
  * Executability : eXeutable, NoteXecutable
  * Read/Write    : ReadOnly, ReadWrite
  * Presence      : NotPresent
+ * Encryption    : ENCrypted, DECrypted
  *
  * Within a category, the attributes are mutually exclusive.
  *
@@ -48,6 +49,8 @@ int set_memory_ro(unsigned long addr, int numpages);
 int set_memory_rw(unsigned long addr, int numpages);
 int set_memory_np(unsigned long addr, int numpages);
 int set_memory_4k(unsigned long addr, int numpages);
+int set_memory_enc(unsigned long addr, int numpages);
+int set_memory_dec(unsigned long addr, int numpages);
 
 int set_memory_array_uc(unsigned long *addr, int addrinarray);
 int set_memory_array_wc(unsigned long *addr, int addrinarray);
diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 2785493..42868f5 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -23,13 +23,23 @@ extern unsigned long sme_me_mask;
 
 u8 sme_get_me_loss(void);
 
+int sme_set_mem_enc(void *vaddr, unsigned long size);
+int sme_set_mem_dec(void *vaddr, unsigned long size);
+
 void __init sme_early_mem_enc(resource_size_t paddr,
 			      unsigned long size);
 void __init sme_early_mem_dec(resource_size_t paddr,
 			      unsigned long size);
 
+void __init *sme_early_memremap(resource_size_t paddr,
+				unsigned long size);
+
 void __init sme_early_init(void);
 
+/* Architecture __weak replacement functions */
+void __init *efi_me_early_memremap(resource_size_t paddr,
+				   unsigned long size);
+
 #define __sme_pa(x)		(__pa((x)) | sme_me_mask)
 #define __sme_pa_nodebug(x)	(__pa_nodebug((x)) | sme_me_mask)
 
@@ -44,6 +54,16 @@ static inline u8 sme_get_me_loss(void)
 	return 0;
 }
 
+static inline int sme_set_mem_enc(void *vaddr, unsigned long size)
+{
+	return 0;
+}
+
+static inline int sme_set_mem_dec(void *vaddr, unsigned long size)
+{
+	return 0;
+}
+
 static inline void __init sme_early_mem_enc(resource_size_t paddr,
 					    unsigned long size)
 {
@@ -63,6 +83,8 @@ static inline void __init sme_early_init(void)
 
 #define __sme_va		__va
 
+#define sme_early_memremap	early_memremap
+
 #endif	/* CONFIG_AMD_MEM_ENCRYPT */
 
 #endif	/* __ASSEMBLY__ */
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 1d29cf9..2e460fb 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -424,7 +424,7 @@ static void __init parse_setup_data(void)
 	while (pa_data) {
 		u32 data_len, data_type;
 
-		data = early_memremap(pa_data, sizeof(*data));
+		data = sme_early_memremap(pa_data, sizeof(*data));
 		data_len = data->len + sizeof(struct setup_data);
 		data_type = data->type;
 		pa_next = data->next;
@@ -457,7 +457,7 @@ static void __init e820_reserve_setup_data(void)
 		return;
 
 	while (pa_data) {
-		data = early_memremap(pa_data, sizeof(*data));
+		data = sme_early_memremap(pa_data, sizeof(*data));
 		e820_update_range(pa_data, sizeof(*data)+data->len,
 			 E820_RAM, E820_RESERVED_KERN);
 		pa_data = data->next;
@@ -477,7 +477,7 @@ static void __init memblock_x86_reserve_range_setup_data(void)
 
 	pa_data = boot_params.hdr.setup_data;
 	while (pa_data) {
-		data = early_memremap(pa_data, sizeof(*data));
+		data = sme_early_memremap(pa_data, sizeof(*data));
 		memblock_reserve(pa_data, sizeof(*data) + data->len);
 		pa_data = data->next;
 		early_memunmap(data, sizeof(*data));
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 5f19ede..7d56d1b 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -14,12 +14,55 @@
 #include <linux/mm.h>
 
 #include <asm/mem_encrypt.h>
+#include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
 
 /* Buffer used for early in-place encryption by BSP, no locking needed */
 static char me_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
 
+int sme_set_mem_enc(void *vaddr, unsigned long size)
+{
+	unsigned long addr, numpages;
+
+	if (!sme_me_mask)
+		return 0;
+
+	addr = (unsigned long)vaddr & PAGE_MASK;
+	numpages = PAGE_ALIGN(size) >> PAGE_SHIFT;
+
+	/*
+	 * The set_memory_xxx functions take an integer for numpages, make
+	 * sure it doesn't exceed that.
+	 */
+	if (numpages > INT_MAX)
+		return -EINVAL;
+
+	return set_memory_enc(addr, numpages);
+}
+EXPORT_SYMBOL_GPL(sme_set_mem_enc);
+
+int sme_set_mem_dec(void *vaddr, unsigned long size)
+{
+	unsigned long addr, numpages;
+
+	if (!sme_me_mask)
+		return 0;
+
+	addr = (unsigned long)vaddr & PAGE_MASK;
+	numpages = PAGE_ALIGN(size) >> PAGE_SHIFT;
+
+	/*
+	 * The set_memory_xxx functions take an integer for numpages, make
+	 * sure it doesn't exceed that.
+	 */
+	if (numpages > INT_MAX)
+		return -EINVAL;
+
+	return set_memory_dec(addr, numpages);
+}
+EXPORT_SYMBOL_GPL(sme_set_mem_dec);
+
 void __init sme_early_mem_enc(resource_size_t paddr, unsigned long size)
 {
 	void *src, *dst;
@@ -104,6 +147,12 @@ void __init sme_early_mem_dec(resource_size_t paddr, unsigned long size)
 	}
 }
 
+void __init *sme_early_memremap(resource_size_t paddr,
+				unsigned long size)
+{
+	return early_memremap_dec(paddr, size);
+}
+
 void __init sme_early_init(void)
 {
 	unsigned int i;
@@ -117,3 +166,10 @@ void __init sme_early_init(void)
 	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
 		protection_map[i] = __pgprot(pgprot_val(protection_map[i]) | sme_me_mask);
 }
+
+/* Architecture __weak replacement functions */
+void __init *efi_me_early_memremap(resource_size_t paddr,
+				   unsigned long size)
+{
+	return sme_early_memremap(paddr, size);
+}
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index c055302..0384fb3 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1731,6 +1731,81 @@ int set_memory_4k(unsigned long addr, int numpages)
 					__pgprot(0), 1, 0, NULL);
 }
 
+static int __set_memory_enc_dec(struct cpa_data *cpa)
+{
+	unsigned long addr;
+	int numpages;
+	int ret;
+
+	if (*cpa->vaddr & ~PAGE_MASK) {
+		*cpa->vaddr &= PAGE_MASK;
+
+		/* People should not be passing in unaligned addresses */
+		WARN_ON_ONCE(1);
+	}
+
+	addr = *cpa->vaddr;
+	numpages = cpa->numpages;
+
+	/* Must avoid aliasing mappings in the highmem code */
+	kmap_flush_unused();
+	vm_unmap_aliases();
+
+	ret = __change_page_attr_set_clr(cpa, 1);
+
+	/* Check whether we really changed something */
+	if (!(cpa->flags & CPA_FLUSHTLB))
+		goto out;
+
+	/*
+	 * On success we use CLFLUSH, when the CPU supports it to
+	 * avoid the WBINVD.
+	 */
+	if (!ret && static_cpu_has(X86_FEATURE_CLFLUSH))
+		cpa_flush_range(addr, numpages, 1);
+	else
+		cpa_flush_all(1);
+
+out:
+	return ret;
+}
+
+int set_memory_enc(unsigned long addr, int numpages)
+{
+	struct cpa_data cpa;
+
+	if (!sme_me_mask)
+		return 0;
+
+	memset(&cpa, 0, sizeof(cpa));
+	cpa.vaddr = &addr;
+	cpa.numpages = numpages;
+	cpa.mask_set = __pgprot(_PAGE_ENC);
+	cpa.mask_clr = __pgprot(0);
+	cpa.pgd = init_mm.pgd;
+
+	return __set_memory_enc_dec(&cpa);
+}
+EXPORT_SYMBOL(set_memory_enc);
+
+int set_memory_dec(unsigned long addr, int numpages)
+{
+	struct cpa_data cpa;
+
+	if (!sme_me_mask)
+		return 0;
+
+	memset(&cpa, 0, sizeof(cpa));
+	cpa.vaddr = &addr;
+	cpa.numpages = numpages;
+	cpa.mask_set = __pgprot(0);
+	cpa.mask_clr = __pgprot(_PAGE_ENC);
+	cpa.pgd = init_mm.pgd;
+
+	return __set_memory_enc_dec(&cpa);
+}
+EXPORT_SYMBOL(set_memory_dec);
+
 int set_pages_uc(struct page *page, int numpages)
 {
 	unsigned long addr = (unsigned long)page_address(page);
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index 994a7df8..871b213 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -53,6 +53,7 @@
 #include <asm/x86_init.h>
 #include <asm/rtc.h>
 #include <asm/uv/uv.h>
+#include <asm/mem_encrypt.h>
 
 #define EFI_DEBUG
 
@@ -261,12 +262,12 @@ static int __init efi_systab_init(void *phys)
 		u64 tmp = 0;
 
 		if (efi_setup) {
-			data = early_memremap(efi_setup, sizeof(*data));
+			data = sme_early_memremap(efi_setup, sizeof(*data));
 			if (!data)
 				return -ENOMEM;
 		}
-		systab64 = early_memremap((unsigned long)phys,
-					 sizeof(*systab64));
+		systab64 = sme_early_memremap((unsigned long)phys,
+					      sizeof(*systab64));
 		if (systab64 == NULL) {
 			pr_err("Couldn't map the system table!\n");
 			if (data)
@@ -314,8 +315,8 @@ static int __init efi_systab_init(void *phys)
 	} else {
 		efi_system_table_32_t *systab32;
 
-		systab32 = early_memremap((unsigned long)phys,
-					 sizeof(*systab32));
+		systab32 = sme_early_memremap((unsigned long)phys,
+					      sizeof(*systab32));
 		if (systab32 == NULL) {
 			pr_err("Couldn't map the system table!\n");
 			return -ENOMEM;
@@ -361,8 +362,8 @@ static int __init efi_runtime_init32(void)
 {
 	efi_runtime_services_32_t *runtime;
 
-	runtime = early_memremap((unsigned long)efi.systab->runtime,
-			sizeof(efi_runtime_services_32_t));
+	runtime = sme_early_memremap((unsigned long)efi.systab->runtime,
+				     sizeof(efi_runtime_services_32_t));
 	if (!runtime) {
 		pr_err("Could not map the runtime service table!\n");
 		return -ENOMEM;
@@ -385,8 +386,8 @@ static int __init efi_runtime_init64(void)
 {
 	efi_runtime_services_64_t *runtime;
 
-	runtime = early_memremap((unsigned long)efi.systab->runtime,
-			sizeof(efi_runtime_services_64_t));
+	runtime = sme_early_memremap((unsigned long)efi.systab->runtime,
+				     sizeof(efi_runtime_services_64_t));
 	if (!runtime) {
 		pr_err("Could not map the runtime service table!\n");
 		return -ENOMEM;
@@ -444,8 +445,8 @@ static int __init efi_memmap_init(void)
 		return 0;
 
 	/* Map the EFI memory map */
-	memmap.map = early_memremap((unsigned long)memmap.phys_map,
-				   memmap.nr_map * memmap.desc_size);
+	memmap.map = sme_early_memremap((unsigned long)memmap.phys_map,
+					memmap.nr_map * memmap.desc_size);
 	if (memmap.map == NULL) {
 		pr_err("Could not map the memory map!\n");
 		return -ENOMEM;
@@ -490,7 +491,7 @@ void __init efi_init(void)
 	/*
 	 * Show what we know for posterity
 	 */
-	c16 = tmp = early_memremap(efi.systab->fw_vendor, 2);
+	c16 = tmp = sme_early_memremap(efi.systab->fw_vendor, 2);
 	if (c16) {
 		for (i = 0; i < sizeof(vendor) - 1 && *c16; ++i)
 			vendor[i] = *c16++;
@@ -690,6 +691,7 @@ static void *realloc_pages(void *old_memmap, int old_shift)
 	ret = (void *)__get_free_pages(GFP_KERNEL, old_shift + 1);
 	if (!ret)
 		goto out;
+	sme_set_mem_dec(ret, PAGE_SIZE << (old_shift + 1));
 
 	/*
 	 * A first-time allocation doesn't have anything to copy.
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 49e4dd4..834a992 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -223,7 +223,7 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	if (efi_enabled(EFI_OLD_MEMMAP))
 		return 0;
 
-	efi_scratch.efi_pgt = (pgd_t *)__pa(efi_pgd);
+	efi_scratch.efi_pgt = (pgd_t *)__sme_pa(efi_pgd);
 	pgd = efi_pgd;
 
 	/*
@@ -262,7 +262,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 		pfn = md->phys_addr >> PAGE_SHIFT;
 		npages = md->num_pages;
 
-		if (kernel_map_pages_in_pgd(pgd, pfn, md->phys_addr, npages, _PAGE_RW)) {
+		if (kernel_map_pages_in_pgd(pgd, pfn, md->phys_addr, npages,
+					    _PAGE_RW | _PAGE_ENC)) {
 			pr_err("Failed to map 1:1 memory\n");
 			return 1;
 		}
@@ -272,6 +273,7 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	if (!page)
 		panic("Unable to allocate EFI runtime stack < 4GB\n");
 
+	sme_set_mem_dec(page_address(page), PAGE_SIZE);
 	efi_scratch.phys_stack = virt_to_phys(page_address(page));
 	efi_scratch.phys_stack += PAGE_SIZE; /* stack grows down */
 
@@ -279,7 +281,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	text = __pa(_text);
 	pfn = text >> PAGE_SHIFT;
 
-	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages, _PAGE_RW)) {
+	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages,
+				    _PAGE_RW | _PAGE_ENC)) {
 		pr_err("Failed to map kernel text 1:1\n");
 		return 1;
 	}
diff --git a/arch/x86/platform/efi/quirks.c b/arch/x86/platform/efi/quirks.c
index ab50ada..dde4fb6b 100644
--- a/arch/x86/platform/efi/quirks.c
+++ b/arch/x86/platform/efi/quirks.c
@@ -13,6 +13,7 @@
 #include <linux/dmi.h>
 #include <asm/efi.h>
 #include <asm/uv/uv.h>
+#include <asm/mem_encrypt.h>
 
 #define EFI_MIN_RESERVE 5120
 
@@ -265,6 +266,13 @@ void __init efi_free_boot_services(void)
 		if (md->attribute & EFI_MEMORY_RUNTIME)
 			continue;
 
+		/*
+		 * Change the mapping to encrypted memory before freeing.
+		 * This insures any future allocations of this mapped area
+		 * are used encrypted.
+		 */
+		sme_set_mem_enc(__va(start), size);
+
 		free_bootmem_late(start, size);
 	}
 
@@ -292,7 +300,7 @@ int __init efi_reuse_config(u64 tables, int nr_tables)
 	if (!efi_enabled(EFI_64BIT))
 		return 0;
 
-	data = early_memremap(efi_setup, sizeof(*data));
+	data = sme_early_memremap(efi_setup, sizeof(*data));
 	if (!data) {
 		ret = -ENOMEM;
 		goto out;
@@ -303,7 +311,7 @@ int __init efi_reuse_config(u64 tables, int nr_tables)
 
 	sz = sizeof(efi_config_table_64_t);
 
-	p = tablep = early_memremap(tables, nr_tables * sz);
+	p = tablep = sme_early_memremap(tables, nr_tables * sz);
 	if (!p) {
 		pr_err("Could not map Configuration table!\n");
 		ret = -ENOMEM;
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 3a69ed5..25010c7 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -76,6 +76,16 @@ static int __init parse_efi_cmdline(char *str)
 }
 early_param("efi", parse_efi_cmdline);
 
+/*
+ * If memory encryption is supported, then an override to this function
+ * will be provided.
+ */
+void __weak __init *efi_me_early_memremap(resource_size_t phys_addr,
+					  unsigned long size)
+{
+	return early_memremap(phys_addr, size);
+}
+
 struct kobject *efi_kobj;
 
 /*
@@ -289,9 +299,9 @@ int __init efi_mem_desc_lookup(u64 phys_addr, efi_memory_desc_t *out_md)
 		 * So just always get our own virtual map on the CPU.
 		 *
 		 */
-		md = early_memremap(p, sizeof (*md));
+		md = efi_me_early_memremap(p, sizeof (*md));
 		if (!md) {
-			pr_err_once("early_memremap(%pa, %zu) failed.\n",
+			pr_err_once("efi_me_early_memremap(%pa, %zu) failed.\n",
 				    &p, sizeof (*md));
 			return -ENOMEM;
 		}
@@ -431,8 +441,8 @@ int __init efi_config_init(efi_config_table_type_t *arch_tables)
 	/*
 	 * Let's see what config tables the firmware passed to us.
 	 */
-	config_tables = early_memremap(efi.systab->tables,
-				       efi.systab->nr_tables * sz);
+	config_tables = efi_me_early_memremap(efi.systab->tables,
+					      efi.systab->nr_tables * sz);
 	if (config_tables == NULL) {
 		pr_err("Could not map Configuration table!\n");
 		return -ENOMEM;
diff --git a/drivers/firmware/efi/esrt.c b/drivers/firmware/efi/esrt.c
index 75feb3f..7a96bc6 100644
--- a/drivers/firmware/efi/esrt.c
+++ b/drivers/firmware/efi/esrt.c
@@ -273,10 +273,10 @@ void __init efi_esrt_init(void)
 		return;
 	}
 
-	va = early_memremap(efi.esrt, size);
+	va = efi_me_early_memremap(efi.esrt, size);
 	if (!va) {
-		pr_err("early_memremap(%p, %zu) failed.\n", (void *)efi.esrt,
-		       size);
+		pr_err("efi_me_early_memremap(%p, %zu) failed.\n",
+		       (void *)efi.esrt, size);
 		return;
 	}
 
@@ -323,10 +323,10 @@ void __init efi_esrt_init(void)
 	/* remap it with our (plausible) new pages */
 	early_memunmap(va, size);
 	size += entries_size;
-	va = early_memremap(efi.esrt, size);
+	va = efi_me_early_memremap(efi.esrt, size);
 	if (!va) {
-		pr_err("early_memremap(%p, %zu) failed.\n", (void *)efi.esrt,
-		       size);
+		pr_err("efi_me_early_memremap(%p, %zu) failed.\n",
+		       (void *)efi.esrt, size);
 		return;
 	}
 
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 1626474..557c774 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -957,6 +957,9 @@ extern void __init efi_fake_memmap(void);
 static inline void efi_fake_memmap(void) { }
 #endif
 
+extern void __weak __init *efi_me_early_memremap(resource_size_t phys_addr,
+						 unsigned long size);
+
 /* Iterate through an efi_memory_map */
 #define for_each_efi_memory_desc(m, md)					   \
 	for ((md) = (m)->map;						   \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
