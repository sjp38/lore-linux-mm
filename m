Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1974783296
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:12:07 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s4so29985077pgr.3
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:12:07 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0066.outbound.protection.outlook.com. [104.47.40.66])
        by mx.google.com with ESMTPS id 206si2049814pfb.354.2017.06.27.08.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:12:05 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 RESEND 24/38] x86, swiotlb: Add memory encryption support
Date: Tue, 27 Jun 2017 10:11:53 -0500
Message-ID: <20170627151152.17428.46131.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
References: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Since DMA addresses will effectively look like 48-bit addresses when the
memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
device performing the DMA does not support 48-bits. SWIOTLB will be
initialized to create decrypted bounce buffers for use by these devices.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/dma-mapping.h |    5 ++-
 arch/x86/include/asm/mem_encrypt.h |    5 +++
 arch/x86/kernel/pci-dma.c          |   11 +++++--
 arch/x86/kernel/pci-nommu.c        |    2 +
 arch/x86/kernel/pci-swiotlb.c      |   15 +++++++++-
 arch/x86/mm/mem_encrypt.c          |   22 +++++++++++++++
 include/linux/swiotlb.h            |    1 +
 init/main.c                        |   10 +++++++
 lib/swiotlb.c                      |   54 +++++++++++++++++++++++++++++++-----
 9 files changed, 108 insertions(+), 17 deletions(-)

diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 08a0838..191f9a5 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -12,6 +12,7 @@
 #include <asm/io.h>
 #include <asm/swiotlb.h>
 #include <linux/dma-contiguous.h>
+#include <linux/mem_encrypt.h>
 
 #ifdef CONFIG_ISA
 # define ISA_DMA_BIT_MASK DMA_BIT_MASK(24)
@@ -62,12 +63,12 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 
 static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
-	return paddr;
+	return __sme_set(paddr);
 }
 
 static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 {
-	return daddr;
+	return __sme_clr(daddr);
 }
 #endif /* CONFIG_X86_DMA_REMAP */
 
diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index ab1fe77..70e55f6 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -34,6 +34,11 @@ void __init sme_early_decrypt(resource_size_t paddr,
 void __init sme_encrypt_kernel(void);
 void __init sme_enable(void);
 
+/* Architecture __weak replacement functions */
+void __init mem_encrypt_init(void);
+
+void swiotlb_set_mem_attributes(void *vaddr, unsigned long size);
+
 #else	/* !CONFIG_AMD_MEM_ENCRYPT */
 
 #define sme_me_mask	0UL
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 3a216ec..72d96d4 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -93,9 +93,12 @@ void *dma_generic_alloc_coherent(struct device *dev, size_t size,
 	if (gfpflags_allow_blocking(flag)) {
 		page = dma_alloc_from_contiguous(dev, count, get_order(size),
 						 flag);
-		if (page && page_to_phys(page) + size > dma_mask) {
-			dma_release_from_contiguous(dev, page, count);
-			page = NULL;
+		if (page) {
+			addr = phys_to_dma(dev, page_to_phys(page));
+			if (addr + size > dma_mask) {
+				dma_release_from_contiguous(dev, page, count);
+				page = NULL;
+			}
 		}
 	}
 	/* fallback */
@@ -104,7 +107,7 @@ void *dma_generic_alloc_coherent(struct device *dev, size_t size,
 	if (!page)
 		return NULL;
 
-	addr = page_to_phys(page);
+	addr = phys_to_dma(dev, page_to_phys(page));
 	if (addr + size > dma_mask) {
 		__free_pages(page, get_order(size));
 
diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
index a88952e..98b576a 100644
--- a/arch/x86/kernel/pci-nommu.c
+++ b/arch/x86/kernel/pci-nommu.c
@@ -30,7 +30,7 @@ static dma_addr_t nommu_map_page(struct device *dev, struct page *page,
 				 enum dma_data_direction dir,
 				 unsigned long attrs)
 {
-	dma_addr_t bus = page_to_phys(page) + offset;
+	dma_addr_t bus = phys_to_dma(dev, page_to_phys(page)) + offset;
 	WARN_ON(size == 0);
 	if (!check_addr("map_single", dev, bus, size))
 		return DMA_ERROR_CODE;
diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index 1e23577..6770775 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -6,12 +6,14 @@
 #include <linux/swiotlb.h>
 #include <linux/bootmem.h>
 #include <linux/dma-mapping.h>
+#include <linux/mem_encrypt.h>
 
 #include <asm/iommu.h>
 #include <asm/swiotlb.h>
 #include <asm/dma.h>
 #include <asm/xen/swiotlb-xen.h>
 #include <asm/iommu_table.h>
+
 int swiotlb __read_mostly;
 
 void *x86_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
@@ -79,8 +81,8 @@ int __init pci_swiotlb_detect_override(void)
 		  pci_swiotlb_late_init);
 
 /*
- * if 4GB or more detected (and iommu=off not set) return 1
- * and set swiotlb to 1.
+ * If 4GB or more detected (and iommu=off not set) or if SME is active
+ * then set swiotlb to 1 and return 1.
  */
 int __init pci_swiotlb_detect_4gb(void)
 {
@@ -89,6 +91,15 @@ int __init pci_swiotlb_detect_4gb(void)
 	if (!no_iommu && max_possible_pfn > MAX_DMA32_PFN)
 		swiotlb = 1;
 #endif
+
+	/*
+	 * If SME is active then swiotlb will be set to 1 so that bounce
+	 * buffers are allocated and used for devices that do not support
+	 * the addressing range required for the encryption mask.
+	 */
+	if (sme_active())
+		swiotlb = 1;
+
 	return swiotlb;
 }
 IOMMU_INIT(pci_swiotlb_detect_4gb,
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 0843d02..a7400ec 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -13,11 +13,14 @@
 #include <linux/linkage.h>
 #include <linux/init.h>
 #include <linux/mm.h>
+#include <linux/dma-mapping.h>
+#include <linux/swiotlb.h>
 
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
 #include <asm/setup.h>
 #include <asm/bootparam.h>
+#include <asm/set_memory.h>
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -177,6 +180,25 @@ void __init sme_early_init(void)
 		protection_map[i] = pgprot_encrypted(protection_map[i]);
 }
 
+/* Architecture __weak replacement functions */
+void __init mem_encrypt_init(void)
+{
+	if (!sme_me_mask)
+		return;
+
+	/* Call into SWIOTLB to update the SWIOTLB DMA buffers */
+	swiotlb_update_mem_attributes();
+}
+
+void swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
+{
+	WARN(PAGE_ALIGN(size) != size,
+	     "size is not page-aligned (%#lx)\n", size);
+
+	/* Make the SWIOTLB buffer area decrypted */
+	set_memory_decrypted((unsigned long)vaddr, size >> PAGE_SHIFT);
+}
+
 void __init sme_encrypt_kernel(void)
 {
 }
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 4ee479f..15e7160 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -35,6 +35,7 @@ enum swiotlb_force {
 extern unsigned long swiotlb_nr_tbl(void);
 unsigned long swiotlb_size_or_default(void);
 extern int swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs);
+extern void __init swiotlb_update_mem_attributes(void);
 
 /*
  * Enumeration for sync targets
diff --git a/init/main.c b/init/main.c
index df58a41..5013cbc 100644
--- a/init/main.c
+++ b/init/main.c
@@ -488,6 +488,8 @@ void __init __weak thread_stack_cache_init(void)
 }
 #endif
 
+void __init __weak mem_encrypt_init(void) { }
+
 /*
  * Set up kernel memory allocators
  */
@@ -640,6 +642,14 @@ asmlinkage __visible void __init start_kernel(void)
 	 */
 	locking_selftest();
 
+	/*
+	 * This needs to be called before any devices perform DMA
+	 * operations that might use the SWIOTLB bounce buffers. It will
+	 * mark the bounce buffers as decrypted so that their usage will
+	 * not cause "plain-text" data to be decrypted when accessed.
+	 */
+	mem_encrypt_init();
+
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (initrd_start && !initrd_below_start_ok &&
 	    page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index a8d74a7..04ac91a 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -30,6 +30,7 @@
 #include <linux/highmem.h>
 #include <linux/gfp.h>
 #include <linux/scatterlist.h>
+#include <linux/mem_encrypt.h>
 
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -155,6 +156,15 @@ unsigned long swiotlb_size_or_default(void)
 	return size ? size : (IO_TLB_DEFAULT_SIZE);
 }
 
+void __weak swiotlb_set_mem_attributes(void *vaddr, unsigned long size) { }
+
+/* For swiotlb, clear memory encryption mask from dma addresses */
+static dma_addr_t swiotlb_phys_to_dma(struct device *hwdev,
+				      phys_addr_t address)
+{
+	return __sme_clr(phys_to_dma(hwdev, address));
+}
+
 /* Note that this doesn't work with highmem page */
 static dma_addr_t swiotlb_virt_to_bus(struct device *hwdev,
 				      volatile void *address)
@@ -183,6 +193,31 @@ void swiotlb_print_info(void)
 	       bytes >> 20, vstart, vend - 1);
 }
 
+/*
+ * Early SWIOTLB allocation may be too early to allow an architecture to
+ * perform the desired operations.  This function allows the architecture to
+ * call SWIOTLB when the operations are possible.  It needs to be called
+ * before the SWIOTLB memory is used.
+ */
+void __init swiotlb_update_mem_attributes(void)
+{
+	void *vaddr;
+	unsigned long bytes;
+
+	if (no_iotlb_memory || late_alloc)
+		return;
+
+	vaddr = phys_to_virt(io_tlb_start);
+	bytes = PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT);
+	swiotlb_set_mem_attributes(vaddr, bytes);
+	memset(vaddr, 0, bytes);
+
+	vaddr = phys_to_virt(io_tlb_overflow_buffer);
+	bytes = PAGE_ALIGN(io_tlb_overflow);
+	swiotlb_set_mem_attributes(vaddr, bytes);
+	memset(vaddr, 0, bytes);
+}
+
 int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 {
 	void *v_overflow_buffer;
@@ -320,6 +355,7 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 	io_tlb_start = virt_to_phys(tlb);
 	io_tlb_end = io_tlb_start + bytes;
 
+	swiotlb_set_mem_attributes(tlb, bytes);
 	memset(tlb, 0, bytes);
 
 	/*
@@ -330,6 +366,8 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 	if (!v_overflow_buffer)
 		goto cleanup2;
 
+	swiotlb_set_mem_attributes(v_overflow_buffer, io_tlb_overflow);
+	memset(v_overflow_buffer, 0, io_tlb_overflow);
 	io_tlb_overflow_buffer = virt_to_phys(v_overflow_buffer);
 
 	/*
@@ -581,7 +619,7 @@ phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
 		return SWIOTLB_MAP_ERROR;
 	}
 
-	start_dma_addr = phys_to_dma(hwdev, io_tlb_start);
+	start_dma_addr = swiotlb_phys_to_dma(hwdev, io_tlb_start);
 	return swiotlb_tbl_map_single(hwdev, start_dma_addr, phys, size,
 				      dir, attrs);
 }
@@ -702,7 +740,7 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
 			goto err_warn;
 
 		ret = phys_to_virt(paddr);
-		dev_addr = phys_to_dma(hwdev, paddr);
+		dev_addr = swiotlb_phys_to_dma(hwdev, paddr);
 
 		/* Confirm address can be DMA'd by device */
 		if (dev_addr + size - 1 > dma_mask) {
@@ -812,10 +850,10 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 	map = map_single(dev, phys, size, dir, attrs);
 	if (map == SWIOTLB_MAP_ERROR) {
 		swiotlb_full(dev, size, dir, 1);
-		return phys_to_dma(dev, io_tlb_overflow_buffer);
+		return swiotlb_phys_to_dma(dev, io_tlb_overflow_buffer);
 	}
 
-	dev_addr = phys_to_dma(dev, map);
+	dev_addr = swiotlb_phys_to_dma(dev, map);
 
 	/* Ensure that the address returned is DMA'ble */
 	if (dma_capable(dev, dev_addr, size))
@@ -824,7 +862,7 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 	attrs |= DMA_ATTR_SKIP_CPU_SYNC;
 	swiotlb_tbl_unmap_single(dev, map, size, dir, attrs);
 
-	return phys_to_dma(dev, io_tlb_overflow_buffer);
+	return swiotlb_phys_to_dma(dev, io_tlb_overflow_buffer);
 }
 EXPORT_SYMBOL_GPL(swiotlb_map_page);
 
@@ -958,7 +996,7 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 				sg_dma_len(sgl) = 0;
 				return 0;
 			}
-			sg->dma_address = phys_to_dma(hwdev, map);
+			sg->dma_address = swiotlb_phys_to_dma(hwdev, map);
 		} else
 			sg->dma_address = dev_addr;
 		sg_dma_len(sg) = sg->length;
@@ -1026,7 +1064,7 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 int
 swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
 {
-	return (dma_addr == phys_to_dma(hwdev, io_tlb_overflow_buffer));
+	return (dma_addr == swiotlb_phys_to_dma(hwdev, io_tlb_overflow_buffer));
 }
 EXPORT_SYMBOL(swiotlb_dma_mapping_error);
 
@@ -1039,6 +1077,6 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 int
 swiotlb_dma_supported(struct device *hwdev, u64 mask)
 {
-	return phys_to_dma(hwdev, io_tlb_end - 1) <= mask;
+	return swiotlb_phys_to_dma(hwdev, io_tlb_end - 1) <= mask;
 }
 EXPORT_SYMBOL(swiotlb_dma_supported);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
