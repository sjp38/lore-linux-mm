Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 389866B039A
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:14:32 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id m124so61966935oig.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:14:32 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0078.outbound.protection.outlook.com. [104.47.37.78])
        by mx.google.com with ESMTPS id y9si3536455otd.290.2017.03.02.07.14.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:14:31 -0800 (PST)
Subject: [RFC PATCH v2 10/32] x86: DMA support for SEV memory encryption
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:14:25 -0500
Message-ID: <148846766532.2349.4832844575566575886.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

DMA access to memory mapped as encrypted while SEV is active can not be
encrypted during device write or decrypted during device read. In order
for DMA to properly work when SEV is active, the swiotlb bounce buffers
must be used.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/mem_encrypt.c |   77 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)

diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 090419b..7df5f4c 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -197,8 +197,81 @@ void __init sme_early_init(void)
 	/* Update the protection map with memory encryption mask */
 	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
 		protection_map[i] = pgprot_encrypted(protection_map[i]);
+
+	if (sev_active())
+		swiotlb_force = SWIOTLB_FORCE;
+}
+
+static void *sme_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		       gfp_t gfp, unsigned long attrs)
+{
+	unsigned long dma_mask;
+	unsigned int order;
+	struct page *page;
+	void *vaddr = NULL;
+
+	dma_mask = dma_alloc_coherent_mask(dev, gfp);
+	order = get_order(size);
+
+	gfp &= ~__GFP_ZERO;
+
+	page = alloc_pages_node(dev_to_node(dev), gfp, order);
+	if (page) {
+		dma_addr_t addr;
+
+		/*
+		 * Since we will be clearing the encryption bit, check the
+		 * mask with it already cleared.
+		 */
+		addr = phys_to_dma(dev, page_to_phys(page)) & ~sme_me_mask;
+		if ((addr + size) > dma_mask) {
+			__free_pages(page, get_order(size));
+		} else {
+			vaddr = page_address(page);
+			*dma_handle = addr;
+		}
+	}
+
+	if (!vaddr)
+		vaddr = swiotlb_alloc_coherent(dev, size, dma_handle, gfp);
+
+	if (!vaddr)
+		return NULL;
+
+	/* Clear the SME encryption bit for DMA use if not swiotlb area */
+	if (!is_swiotlb_buffer(dma_to_phys(dev, *dma_handle))) {
+		set_memory_decrypted((unsigned long)vaddr, 1 << order);
+		*dma_handle &= ~sme_me_mask;
+	}
+
+	return vaddr;
 }
 
+static void sme_free(struct device *dev, size_t size, void *vaddr,
+		     dma_addr_t dma_handle, unsigned long attrs)
+{
+	/* Set the SME encryption bit for re-use if not swiotlb area */
+	if (!is_swiotlb_buffer(dma_to_phys(dev, dma_handle)))
+		set_memory_encrypted((unsigned long)vaddr,
+				     1 << get_order(size));
+
+	swiotlb_free_coherent(dev, size, vaddr, dma_handle);
+}
+
+static struct dma_map_ops sme_dma_ops = {
+	.alloc                  = sme_alloc,
+	.free                   = sme_free,
+	.map_page               = swiotlb_map_page,
+	.unmap_page             = swiotlb_unmap_page,
+	.map_sg                 = swiotlb_map_sg_attrs,
+	.unmap_sg               = swiotlb_unmap_sg_attrs,
+	.sync_single_for_cpu    = swiotlb_sync_single_for_cpu,
+	.sync_single_for_device = swiotlb_sync_single_for_device,
+	.sync_sg_for_cpu        = swiotlb_sync_sg_for_cpu,
+	.sync_sg_for_device     = swiotlb_sync_sg_for_device,
+	.mapping_error          = swiotlb_dma_mapping_error,
+};
+
 /* Architecture __weak replacement functions */
 void __init mem_encrypt_init(void)
 {
@@ -208,6 +281,10 @@ void __init mem_encrypt_init(void)
 	/* Call into SWIOTLB to update the SWIOTLB DMA buffers */
 	swiotlb_update_mem_attributes();
 
+	/* Use SEV DMA operations if SEV is active */
+	if (sev_active())
+		dma_ops = &sme_dma_ops;
+
 	pr_info("AMD Secure Memory Encryption (SME) active\n");
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
