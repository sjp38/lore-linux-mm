Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id F095C6B0267
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:26:10 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w136so39341988oie.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:26:10 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0056.outbound.protection.outlook.com. [104.47.34.56])
        by mx.google.com with ESMTPS id d39si157462otb.137.2016.08.22.16.26.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:26:10 -0700 (PDT)
Subject: [RFC PATCH v1 12/28] x86: DMA support for SEV memory encryption
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:26:02 -0400
Message-ID: <147190836254.9523.17071309814378405604.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

DMA access to memory mapped as encrypted while SEV is active can not be
encrypted during device write or decrypted during device read. In order
for DMA to properly work when SEV is active, the swiotlb bounce buffers
must be used.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/mem_encrypt.c |   48 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 1154353..ce6e3ea 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -173,8 +173,52 @@ void __init sme_early_init(void)
 	/* Update the protection map with memory encryption mask */
 	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
 		protection_map[i] = __pgprot(pgprot_val(protection_map[i]) | sme_me_mask);
+
+	if (sev_active)
+		swiotlb_force = 1;
 }
 
+static void *sme_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		       gfp_t gfp, unsigned long attrs)
+{
+	void *vaddr;
+
+	vaddr = x86_swiotlb_alloc_coherent(dev, size, dma_handle, gfp, attrs);
+	if (!vaddr)
+		return NULL;
+
+	/* Clear the SME encryption bit for DMA use */
+	sme_set_mem_dec(vaddr, size);
+
+	/* Remove the encryption bit from the DMA address */
+	*dma_handle &= ~sme_me_mask;
+
+	return vaddr;
+}
+
+static void sme_free(struct device *dev, size_t size, void *vaddr,
+		     dma_addr_t dma_handle, unsigned long attrs)
+{
+	/* Set the SME encryption bit for re-use as encrypted */
+	sme_set_mem_enc(vaddr, size);
+
+	x86_swiotlb_free_coherent(dev, size, vaddr, dma_handle, attrs);
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
@@ -184,6 +228,10 @@ void __init mem_encrypt_init(void)
 	/* Make SWIOTLB use an unencrypted DMA area */
 	swiotlb_clear_encryption();
 
+	/* Use SEV DMA operations if SEV is active */
+	if (sev_active)
+		dma_ops = &sme_dma_ops;
+
 	pr_info("memory encryption active\n");
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
