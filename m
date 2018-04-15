Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 105B16B0024
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 11:00:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q22so7877540pfh.20
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 08:00:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g12-v6si10299687pll.184.2018.04.15.08.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 15 Apr 2018 08:00:37 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/12] PCI: remove CONFIG_PCI_BUS_ADDR_T_64BIT
Date: Sun, 15 Apr 2018 16:59:44 +0200
Message-Id: <20180415145947.1248-10-hch@lst.de>
In-Reply-To: <20180415145947.1248-1-hch@lst.de>
References: <20180415145947.1248-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

This symbol is now always identical to CONFIG_ARCH_DMA_ADDR_T_64BIT, so
remove it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/pci/Kconfig | 4 ----
 drivers/pci/bus.c   | 4 ++--
 include/linux/pci.h | 2 +-
 3 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/pci/Kconfig b/drivers/pci/Kconfig
index 34b56a8f8480..29a487f31dae 100644
--- a/drivers/pci/Kconfig
+++ b/drivers/pci/Kconfig
@@ -5,10 +5,6 @@
 
 source "drivers/pci/pcie/Kconfig"
 
-config PCI_BUS_ADDR_T_64BIT
-	def_bool y if (ARCH_DMA_ADDR_T_64BIT || 64BIT)
-	depends on PCI
-
 config PCI_MSI
 	bool "Message Signaled Interrupts (MSI and MSI-X)"
 	depends on PCI
diff --git a/drivers/pci/bus.c b/drivers/pci/bus.c
index bc2ded4c451f..35b7fc87eac5 100644
--- a/drivers/pci/bus.c
+++ b/drivers/pci/bus.c
@@ -120,7 +120,7 @@ int devm_request_pci_bus_resources(struct device *dev,
 EXPORT_SYMBOL_GPL(devm_request_pci_bus_resources);
 
 static struct pci_bus_region pci_32_bit = {0, 0xffffffffULL};
-#ifdef CONFIG_PCI_BUS_ADDR_T_64BIT
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
 static struct pci_bus_region pci_64_bit = {0,
 				(pci_bus_addr_t) 0xffffffffffffffffULL};
 static struct pci_bus_region pci_high = {(pci_bus_addr_t) 0x100000000ULL,
@@ -230,7 +230,7 @@ int pci_bus_alloc_resource(struct pci_bus *bus, struct resource *res,
 					  resource_size_t),
 		void *alignf_data)
 {
-#ifdef CONFIG_PCI_BUS_ADDR_T_64BIT
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
 	int rc;
 
 	if (res->flags & IORESOURCE_MEM_64) {
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 73178a2fcee0..55371cb827ad 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -670,7 +670,7 @@ int raw_pci_read(unsigned int domain, unsigned int bus, unsigned int devfn,
 int raw_pci_write(unsigned int domain, unsigned int bus, unsigned int devfn,
 		  int reg, int len, u32 val);
 
-#ifdef CONFIG_PCI_BUS_ADDR_T_64BIT
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
 typedef u64 pci_bus_addr_t;
 #else
 typedef u32 pci_bus_addr_t;
-- 
2.17.0
