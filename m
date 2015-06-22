Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id F3A866B0070
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:30:20 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so134261482pdj.0
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 01:30:20 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id k4si28436996pbq.230.2015.06.22.01.30.19
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 01:30:19 -0700 (PDT)
Subject: [PATCH v5 3/6] cleanup IORESOURCE_CACHEABLE vs ioremap()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 22 Jun 2015 04:24:33 -0400
Message-ID: <20150622082433.35954.44513.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org
Cc: jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, hch@lst.de

Quoting Arnd:
    I was thinking the opposite approach and basically removing all uses
    of IORESOURCE_CACHEABLE from the kernel. There are only a handful of
    them.and we can probably replace them all with hardcoded
    ioremap_cached() calls in the cases they are actually useful.

All existing usages of IORESOURCE_CACHEABLE call ioremap() instead of
ioremap_nocache() if the resource is cacheable, however ioremap() is
uncached by default.  Clearly none of the existing usages care about the
cacheability, so let's clean that up before introducing generic
ioremap_cache() support across architectures.

Suggested-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/arm/mach-clps711x/board-cdb89712.c |    2 +-
 arch/powerpc/kernel/pci_of_scan.c       |    2 +-
 arch/sparc/kernel/pci.c                 |    3 +--
 drivers/pci/probe.c                     |    3 +--
 drivers/pnp/manager.c                   |    2 --
 drivers/scsi/aic94xx/aic94xx_init.c     |    7 +------
 drivers/scsi/arcmsr/arcmsr_hba.c        |    5 +----
 drivers/scsi/mvsas/mv_init.c            |   15 ++++-----------
 drivers/video/fbdev/ocfb.c              |    1 -
 lib/devres.c                            |    7 ++-----
 lib/pci_iomap.c                         |    7 ++-----
 11 files changed, 14 insertions(+), 40 deletions(-)

diff --git a/arch/arm/mach-clps711x/board-cdb89712.c b/arch/arm/mach-clps711x/board-cdb89712.c
index 1ec378c334e5..972abdb10028 100644
--- a/arch/arm/mach-clps711x/board-cdb89712.c
+++ b/arch/arm/mach-clps711x/board-cdb89712.c
@@ -95,7 +95,7 @@ static struct physmap_flash_data cdb89712_bootrom_pdata __initdata = {
 
 static struct resource cdb89712_bootrom_resources[] __initdata = {
 	DEFINE_RES_NAMED(CS7_PHYS_BASE, SZ_128, "BOOTROM", IORESOURCE_MEM |
-			 IORESOURCE_CACHEABLE | IORESOURCE_READONLY),
+			 IORESOURCE_READONLY),
 };
 
 static struct platform_device cdb89712_bootrom_pdev __initdata = {
diff --git a/arch/powerpc/kernel/pci_of_scan.c b/arch/powerpc/kernel/pci_of_scan.c
index 42e02a2d570b..d4726addff0b 100644
--- a/arch/powerpc/kernel/pci_of_scan.c
+++ b/arch/powerpc/kernel/pci_of_scan.c
@@ -102,7 +102,7 @@ static void of_pci_parse_addrs(struct device_node *node, struct pci_dev *dev)
 			res = &dev->resource[(i - PCI_BASE_ADDRESS_0) >> 2];
 		} else if (i == dev->rom_base_reg) {
 			res = &dev->resource[PCI_ROM_RESOURCE];
-			flags |= IORESOURCE_READONLY | IORESOURCE_CACHEABLE;
+			flags |= IORESOURCE_READONLY;
 		} else {
 			printk(KERN_ERR "PCI: bad cfg reg num 0x%x\n", i);
 			continue;
diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index c928bc64b4ba..04da147e0712 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -231,8 +231,7 @@ static void pci_parse_of_addrs(struct platform_device *op,
 			res = &dev->resource[(i - PCI_BASE_ADDRESS_0) >> 2];
 		} else if (i == dev->rom_base_reg) {
 			res = &dev->resource[PCI_ROM_RESOURCE];
-			flags |= IORESOURCE_READONLY | IORESOURCE_CACHEABLE
-			      | IORESOURCE_SIZEALIGN;
+			flags |= IORESOURCE_READONLY | IORESOURCE_SIZEALIGN;
 		} else {
 			printk(KERN_ERR "PCI: bad cfg reg num 0x%x\n", i);
 			continue;
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 6675a7a1b9fc..bbc7f8f86051 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -326,8 +326,7 @@ static void pci_read_bases(struct pci_dev *dev, unsigned int howmany, int rom)
 		struct resource *res = &dev->resource[PCI_ROM_RESOURCE];
 		dev->rom_base_reg = rom;
 		res->flags = IORESOURCE_MEM | IORESOURCE_PREFETCH |
-				IORESOURCE_READONLY | IORESOURCE_CACHEABLE |
-				IORESOURCE_SIZEALIGN;
+				IORESOURCE_READONLY | IORESOURCE_SIZEALIGN;
 		__pci_read_base(dev, pci_bar_mem32, res, rom);
 	}
 }
diff --git a/drivers/pnp/manager.c b/drivers/pnp/manager.c
index 9357aa779048..7ad3295752ef 100644
--- a/drivers/pnp/manager.c
+++ b/drivers/pnp/manager.c
@@ -97,8 +97,6 @@ static int pnp_assign_mem(struct pnp_dev *dev, struct pnp_mem *rule, int idx)
 	/* ??? rule->flags restricted to 8 bits, all tests bogus ??? */
 	if (!(rule->flags & IORESOURCE_MEM_WRITEABLE))
 		res->flags |= IORESOURCE_READONLY;
-	if (rule->flags & IORESOURCE_MEM_CACHEABLE)
-		res->flags |= IORESOURCE_CACHEABLE;
 	if (rule->flags & IORESOURCE_MEM_RANGELENGTH)
 		res->flags |= IORESOURCE_RANGELENGTH;
 	if (rule->flags & IORESOURCE_MEM_SHADOWABLE)
diff --git a/drivers/scsi/aic94xx/aic94xx_init.c b/drivers/scsi/aic94xx/aic94xx_init.c
index 02a2512b76a8..1058a7b1e334 100644
--- a/drivers/scsi/aic94xx/aic94xx_init.c
+++ b/drivers/scsi/aic94xx/aic94xx_init.c
@@ -101,12 +101,7 @@ static int asd_map_memio(struct asd_ha_struct *asd_ha)
 				   pci_name(asd_ha->pcidev));
 			goto Err;
 		}
-		if (io_handle->flags & IORESOURCE_CACHEABLE)
-			io_handle->addr = ioremap(io_handle->start,
-						  io_handle->len);
-		else
-			io_handle->addr = ioremap_nocache(io_handle->start,
-							  io_handle->len);
+		io_handle->addr = ioremap(io_handle->start, io_handle->len);
 		if (!io_handle->addr) {
 			asd_printk("couldn't map MBAR%d of %s\n", i==0?0:1,
 				   pci_name(asd_ha->pcidev));
diff --git a/drivers/scsi/arcmsr/arcmsr_hba.c b/drivers/scsi/arcmsr/arcmsr_hba.c
index 914c39f9f388..e4f77cad9fd8 100644
--- a/drivers/scsi/arcmsr/arcmsr_hba.c
+++ b/drivers/scsi/arcmsr/arcmsr_hba.c
@@ -259,10 +259,7 @@ static bool arcmsr_remap_pciregion(struct AdapterControlBlock *acb)
 		addr = (unsigned long)pci_resource_start(pdev, 0);
 		range = pci_resource_len(pdev, 0);
 		flags = pci_resource_flags(pdev, 0);
-		if (flags & IORESOURCE_CACHEABLE)
-			mem_base0 = ioremap(addr, range);
-		else
-			mem_base0 = ioremap_nocache(addr, range);
+		mem_base0 = ioremap(addr, range);
 		if (!mem_base0) {
 			pr_notice("arcmsr%d: memory mapping region fail\n",
 				acb->host->host_no);
diff --git a/drivers/scsi/mvsas/mv_init.c b/drivers/scsi/mvsas/mv_init.c
index 53030b0e8015..c01ef5f538b1 100644
--- a/drivers/scsi/mvsas/mv_init.c
+++ b/drivers/scsi/mvsas/mv_init.c
@@ -325,13 +325,9 @@ int mvs_ioremap(struct mvs_info *mvi, int bar, int bar_ex)
 			goto err_out;
 
 		res_flag_ex = pci_resource_flags(pdev, bar_ex);
-		if (res_flag_ex & IORESOURCE_MEM) {
-			if (res_flag_ex & IORESOURCE_CACHEABLE)
-				mvi->regs_ex = ioremap(res_start, res_len);
-			else
-				mvi->regs_ex = ioremap_nocache(res_start,
-						res_len);
-		} else
+		if (res_flag_ex & IORESOURCE_MEM)
+			mvi->regs_ex = ioremap(res_start, res_len);
+		else
 			mvi->regs_ex = (void *)res_start;
 		if (!mvi->regs_ex)
 			goto err_out;
@@ -343,10 +339,7 @@ int mvs_ioremap(struct mvs_info *mvi, int bar, int bar_ex)
 		goto err_out;
 
 	res_flag = pci_resource_flags(pdev, bar);
-	if (res_flag & IORESOURCE_CACHEABLE)
-		mvi->regs = ioremap(res_start, res_len);
-	else
-		mvi->regs = ioremap_nocache(res_start, res_len);
+	mvi->regs = ioremap(res_start, res_len);
 
 	if (!mvi->regs) {
 		if (mvi->regs_ex && (res_flag_ex & IORESOURCE_MEM))
diff --git a/drivers/video/fbdev/ocfb.c b/drivers/video/fbdev/ocfb.c
index de9819660ca0..c9293aea8ec3 100644
--- a/drivers/video/fbdev/ocfb.c
+++ b/drivers/video/fbdev/ocfb.c
@@ -325,7 +325,6 @@ static int ocfb_probe(struct platform_device *pdev)
 		dev_err(&pdev->dev, "I/O resource request failed\n");
 		return -ENXIO;
 	}
-	res->flags &= ~IORESOURCE_CACHEABLE;
 	fbdev->regs = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(fbdev->regs))
 		return PTR_ERR(fbdev->regs);
diff --git a/lib/devres.c b/lib/devres.c
index fbe2aac522e6..f4001d90d24d 100644
--- a/lib/devres.c
+++ b/lib/devres.c
@@ -153,11 +153,8 @@ void __iomem *devm_ioremap_resource(struct device *dev, struct resource *res)
 		return IOMEM_ERR_PTR(-EBUSY);
 	}
 
-	if (res->flags & IORESOURCE_CACHEABLE)
-		dest_ptr = devm_ioremap(dev, res->start, size);
-	else
-		dest_ptr = devm_ioremap_nocache(dev, res->start, size);
-
+	/* FIXME: add devm_ioremap_cache support */
+	dest_ptr = devm_ioremap(dev, res->start, size);
 	if (!dest_ptr) {
 		dev_err(dev, "ioremap failed for resource %pR\n", res);
 		devm_release_mem_region(dev, res->start, size);
diff --git a/lib/pci_iomap.c b/lib/pci_iomap.c
index bcce5f149310..e1930dbab2da 100644
--- a/lib/pci_iomap.c
+++ b/lib/pci_iomap.c
@@ -41,11 +41,8 @@ void __iomem *pci_iomap_range(struct pci_dev *dev,
 		len = maxlen;
 	if (flags & IORESOURCE_IO)
 		return __pci_ioport_map(dev, start, len);
-	if (flags & IORESOURCE_MEM) {
-		if (flags & IORESOURCE_CACHEABLE)
-			return ioremap(start, len);
-		return ioremap_nocache(start, len);
-	}
+	if (flags & IORESOURCE_MEM)
+		return ioremap(start, len);
 	/* What? */
 	return NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
