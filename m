Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB1466B0285
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:26:19 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m3-v6so985835plt.9
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:26:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g189-v6si19667977pgc.204.2018.10.09.06.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:26:18 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 22/33] powerpc/dma: move pci_dma_dev_setup_swiotlb to fsl_pci.c
Date: Tue,  9 Oct 2018 15:24:49 +0200
Message-Id: <20181009132500.17643-23-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

pci_dma_dev_setup_swiotlb is only used by the fsl_pci code, and closely
related to it, so fsl_pci.c seems like a better place for it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/swiotlb.h |  2 --
 arch/powerpc/kernel/dma-swiotlb.c  | 11 -----------
 arch/powerpc/sysdev/fsl_pci.c      |  9 +++++++++
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/arch/powerpc/include/asm/swiotlb.h b/arch/powerpc/include/asm/swiotlb.h
index f65ecf57b66c..26a0f12b835b 100644
--- a/arch/powerpc/include/asm/swiotlb.h
+++ b/arch/powerpc/include/asm/swiotlb.h
@@ -18,8 +18,6 @@ extern const struct dma_map_ops powerpc_swiotlb_dma_ops;
 extern unsigned int ppc_swiotlb_enable;
 int __init swiotlb_setup_bus_notifier(void);
 
-extern void pci_dma_dev_setup_swiotlb(struct pci_dev *pdev);
-
 #ifdef CONFIG_SWIOTLB
 void swiotlb_detect_4g(void);
 #else
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 93a4622563c6..60cb86338233 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -63,17 +63,6 @@ const struct dma_map_ops powerpc_swiotlb_dma_ops = {
 	.get_required_mask = swiotlb_powerpc_get_required,
 };
 
-void pci_dma_dev_setup_swiotlb(struct pci_dev *pdev)
-{
-	struct pci_controller *hose;
-	struct dev_archdata *sd;
-
-	hose = pci_bus_to_host(pdev->bus);
-	sd = &pdev->dev.archdata;
-	sd->max_direct_dma_addr =
-		hose->dma_window_base_cur + hose->dma_window_size;
-}
-
 static int ppc_swiotlb_bus_notify(struct notifier_block *nb,
 				  unsigned long action, void *data)
 {
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index 918be816b097..561f97d698cc 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -114,6 +114,15 @@ static struct pci_ops fsl_indirect_pcie_ops =
 static u64 pci64_dma_offset;
 
 #ifdef CONFIG_SWIOTLB
+static void pci_dma_dev_setup_swiotlb(struct pci_dev *pdev)
+{
+	struct pci_controller *hose = pci_bus_to_host(pdev->bus);
+	struct dev_archdata *sd = &pdev->dev.archdata;
+
+	sd->max_direct_dma_addr =
+		hose->dma_window_base_cur + hose->dma_window_size;
+}
+
 static void setup_swiotlb_ops(struct pci_controller *hose)
 {
 	if (ppc_swiotlb_enable) {
-- 
2.19.0
