Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 814C16B004D
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 10:36:57 -0400 (EDT)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M2B00H8VKLFGZ@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 11 Apr 2012 15:36:51 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2B00EJFKLJ2Q@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 11 Apr 2012 15:36:55 +0100 (BST)
Date: Wed, 11 Apr 2012 16:36:44 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] ARM: Exynos4: integrate SYSMMU driver with DMA-mapping
 interface
In-reply-to: <1334155004-5700-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1334155004-5700-2-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1334155004-5700-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

This patch provides an provides setup code which assigns IOMMU controllers
to FIMC and MFC devices and enables IOMMU aware DMA-mapping for them.
It has been tested on Samsung Exynos4 platform, NURI board.

Most of the work is done in the s5p_sysmmu_late_init() function, which
first assigns SYSMMU controller to respective client device and then
creates IO address space mapping structures. In this example 128 MiB of
address space is created at 0x20000000 for most of the devices. IO address
allocation precision is set to 2^4 pages, so all small allocations will be
aligned to 64 pages. This reduces the size of the io address space bitmap
to 4 KiB.

To solve the clock dependency issues, parent clocks have been added to each
SYSMMU controller bus clock. This models the true hardware behavior,
because client's device bus clock also gates the respective sysmmu bus
clock.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/mach-exynos/Kconfig               |    1 +
 arch/arm/mach-exynos/clock-exynos4.c       |   64 +++++++++++++++-------------
 arch/arm/mach-exynos/dev-sysmmu.c          |   44 +++++++++++++++++++
 arch/arm/mach-exynos/include/mach/sysmmu.h |    3 +
 drivers/iommu/Kconfig                      |    1 +
 5 files changed, 84 insertions(+), 29 deletions(-)

diff --git a/arch/arm/mach-exynos/Kconfig b/arch/arm/mach-exynos/Kconfig
index 801c738..25b9ba5 100644
--- a/arch/arm/mach-exynos/Kconfig
+++ b/arch/arm/mach-exynos/Kconfig
@@ -288,6 +288,7 @@ config MACH_NURI
 	select S5P_DEV_USB_EHCI
 	select S5P_SETUP_MIPIPHY
 	select EXYNOS4_DEV_DMA
+	select EXYNOS_DEV_SYSMMU
 	select EXYNOS4_SETUP_FIMC
 	select EXYNOS4_SETUP_FIMD0
 	select EXYNOS4_SETUP_I2C1
diff --git a/arch/arm/mach-exynos/clock-exynos4.c b/arch/arm/mach-exynos/clock-exynos4.c
index 29ae4df..fe459a3 100644
--- a/arch/arm/mach-exynos/clock-exynos4.c
+++ b/arch/arm/mach-exynos/clock-exynos4.c
@@ -497,29 +497,6 @@ static struct clk *exynos4_gate_clocks[] = {
 
 static struct clk exynos4_init_clocks_off[] = {
 	{
-		.name		= "timers",
-		.parent		= &exynos4_clk_aclk_100.clk,
-		.enable		= exynos4_clk_ip_peril_ctrl,
-		.ctrlbit	= (1<<24),
-	}, {
-		.name		= "csis",
-		.devname	= "s5p-mipi-csis.0",
-		.enable		= exynos4_clk_ip_cam_ctrl,
-		.ctrlbit	= (1 << 4),
-		.parent		= &exynos4_clk_gate_cam,
-	}, {
-		.name		= "csis",
-		.devname	= "s5p-mipi-csis.1",
-		.enable		= exynos4_clk_ip_cam_ctrl,
-		.ctrlbit	= (1 << 5),
-		.parent		= &exynos4_clk_gate_cam,
-	}, {
-		.name		= "jpeg",
-		.id		= 0,
-		.enable		= exynos4_clk_ip_cam_ctrl,
-		.ctrlbit	= (1 << 6),
-		.parent		= &exynos4_clk_gate_cam,
-	}, {
 		.name		= "fimc",
 		.devname	= "exynos4-fimc.0",
 		.enable		= exynos4_clk_ip_cam_ctrl,
@@ -544,6 +521,35 @@ static struct clk exynos4_init_clocks_off[] = {
 		.ctrlbit	= (1 << 3),
 		.parent		= &exynos4_clk_gate_cam,
 	}, {
+		.name		= "mfc",
+		.devname	= "s5p-mfc",
+		.enable		= exynos4_clk_ip_mfc_ctrl,
+		.ctrlbit	= (1 << 0),
+		.parent		= &exynos4_clk_gate_mfc,
+	}, {
+		.name		= "timers",
+		.parent		= &exynos4_clk_aclk_100.clk,
+		.enable		= exynos4_clk_ip_peril_ctrl,
+		.ctrlbit	= (1<<24),
+	}, {
+		.name		= "csis",
+		.devname	= "s5p-mipi-csis.0",
+		.enable		= exynos4_clk_ip_cam_ctrl,
+		.ctrlbit	= (1 << 4),
+		.parent		= &exynos4_clk_gate_cam,
+	}, {
+		.name		= "csis",
+		.devname	= "s5p-mipi-csis.1",
+		.enable		= exynos4_clk_ip_cam_ctrl,
+		.ctrlbit	= (1 << 5),
+		.parent		= &exynos4_clk_gate_cam,
+	}, {
+		.name		= "jpeg",
+		.id		= 0,
+		.enable		= exynos4_clk_ip_cam_ctrl,
+		.ctrlbit	= (1 << 6),
+		.parent		= &exynos4_clk_gate_cam,
+	}, {
 		.name		= "hsmmc",
 		.devname	= "exynos4-sdhci.0",
 		.parent		= &exynos4_clk_aclk_133.clk,
@@ -674,12 +680,6 @@ static struct clk exynos4_init_clocks_off[] = {
 		.ctrlbit	= (1 << 0),
 		.parent		= &exynos4_clk_gate_lcd0,
 	}, {
-		.name		= "mfc",
-		.devname	= "s5p-mfc",
-		.enable		= exynos4_clk_ip_mfc_ctrl,
-		.ctrlbit	= (1 << 0),
-		.parent		= &exynos4_clk_gate_mfc,
-	}, {
 		.name		= "i2c",
 		.devname	= "s3c2440-i2c.0",
 		.parent		= &exynos4_clk_aclk_100.clk,
@@ -738,11 +738,13 @@ static struct clk exynos4_init_clocks_off[] = {
 		.devname	= SYSMMU_CLOCK_DEVNAME(mfc_l, 0),
 		.enable		= exynos4_clk_ip_mfc_ctrl,
 		.ctrlbit	= (1 << 1),
+		.parent		= &exynos4_init_clocks_off[4],
 	}, {
 		.name		= SYSMMU_CLOCK_NAME,
 		.devname	= SYSMMU_CLOCK_DEVNAME(mfc_r, 1),
 		.enable		= exynos4_clk_ip_mfc_ctrl,
 		.ctrlbit	= (1 << 2),
+		.parent		= &exynos4_init_clocks_off[4],
 	}, {
 		.name		= SYSMMU_CLOCK_NAME,
 		.devname	= SYSMMU_CLOCK_DEVNAME(tv, 2),
@@ -763,21 +765,25 @@ static struct clk exynos4_init_clocks_off[] = {
 		.devname	= SYSMMU_CLOCK_DEVNAME(fimc0, 5),
 		.enable		= exynos4_clk_ip_cam_ctrl,
 		.ctrlbit	= (1 << 7),
+		.parent		= &exynos4_init_clocks_off[0],
 	}, {
 		.name		= SYSMMU_CLOCK_NAME,
 		.devname	= SYSMMU_CLOCK_DEVNAME(fimc1, 6),
 		.enable		= exynos4_clk_ip_cam_ctrl,
 		.ctrlbit	= (1 << 8),
+		.parent		= &exynos4_init_clocks_off[1],
 	}, {
 		.name		= SYSMMU_CLOCK_NAME,
 		.devname	= SYSMMU_CLOCK_DEVNAME(fimc2, 7),
 		.enable		= exynos4_clk_ip_cam_ctrl,
 		.ctrlbit	= (1 << 9),
+		.parent		= &exynos4_init_clocks_off[2],
 	}, {
 		.name		= SYSMMU_CLOCK_NAME,
 		.devname	= SYSMMU_CLOCK_DEVNAME(fimc3, 8),
 		.enable		= exynos4_clk_ip_cam_ctrl,
 		.ctrlbit	= (1 << 10),
+		.parent		= &exynos4_init_clocks_off[3],
 	}, {
 		.name		= SYSMMU_CLOCK_NAME,
 		.devname	= SYSMMU_CLOCK_DEVNAME(fimd0, 10),
diff --git a/arch/arm/mach-exynos/dev-sysmmu.c b/arch/arm/mach-exynos/dev-sysmmu.c
index 3544638..31f2d6ca 100644
--- a/arch/arm/mach-exynos/dev-sysmmu.c
+++ b/arch/arm/mach-exynos/dev-sysmmu.c
@@ -12,12 +12,15 @@
 
 #include <linux/platform_device.h>
 #include <linux/dma-mapping.h>
+#include <linux/slab.h>
 
 #include <plat/cpu.h>
+#include <plat/devs.h>
 
 #include <mach/map.h>
 #include <mach/irqs.h>
 #include <mach/sysmmu.h>
+#include <asm/dma-iommu.h>
 
 static u64 exynos_sysmmu_dma_mask = DMA_BIT_MASK(32);
 
@@ -276,3 +279,44 @@ static int __init init_sysmmu_platform_device(void)
  * see pm_domain.c, which use arch_initcall()
  */
 core_initcall(init_sysmmu_platform_device);
+#ifdef CONFIG_ARM_DMA_USE_IOMMU
+int __init s5p_create_iommu_mapping(struct device *client, dma_addr_t base,
+				    unsigned int size, int order)
+{
+	struct dma_iommu_mapping *mapping;
+	if (!client)
+		return 0;
+	mapping = arm_iommu_create_mapping(&platform_bus_type, base, size, order);
+	if (!mapping)
+		return -ENOMEM;
+	client->dma_parms = kzalloc(sizeof(*client->dma_parms), GFP_KERNEL);
+	dma_set_max_seg_size(client, 0xffffffffu);
+	arm_iommu_attach_device(client, mapping);
+	return 0;
+}
+
+/*
+ * s5p_sysmmu_late_init
+ * Create DMA-mapping IOMMU context for specified devices. This function must
+ * be called later, once SYSMMU driver gets registered and probed.
+ */
+static int __init s5p_sysmmu_late_init(void)
+{
+	platform_set_sysmmu(&SYSMMU_PLATDEV(fimc0).dev, &s5p_device_fimc0.dev);
+	platform_set_sysmmu(&SYSMMU_PLATDEV(fimc1).dev, &s5p_device_fimc1.dev);
+	platform_set_sysmmu(&SYSMMU_PLATDEV(fimc2).dev, &s5p_device_fimc2.dev);
+	platform_set_sysmmu(&SYSMMU_PLATDEV(fimc3).dev, &s5p_device_fimc3.dev);
+	platform_set_sysmmu(&SYSMMU_PLATDEV(mfc_l).dev, &s5p_device_mfc_l.dev);
+	platform_set_sysmmu(&SYSMMU_PLATDEV(mfc_r).dev, &s5p_device_mfc_r.dev);
+
+	s5p_create_iommu_mapping(&s5p_device_fimc0.dev, 0x20000000, SZ_128M, 4);
+	s5p_create_iommu_mapping(&s5p_device_fimc1.dev, 0x20000000, SZ_128M, 4);
+	s5p_create_iommu_mapping(&s5p_device_fimc2.dev, 0x20000000, SZ_128M, 4);
+	s5p_create_iommu_mapping(&s5p_device_fimc3.dev, 0x20000000, SZ_128M, 4);
+	s5p_create_iommu_mapping(&s5p_device_mfc_l.dev, 0x20000000, SZ_128M, 4);
+	s5p_create_iommu_mapping(&s5p_device_mfc_r.dev, 0x40000000, SZ_128M, 4);
+
+	return 0;
+}
+device_initcall(s5p_sysmmu_late_init);
+#endif
diff --git a/arch/arm/mach-exynos/include/mach/sysmmu.h b/arch/arm/mach-exynos/include/mach/sysmmu.h
index 998daf2..07cae3a 100644
--- a/arch/arm/mach-exynos/include/mach/sysmmu.h
+++ b/arch/arm/mach-exynos/include/mach/sysmmu.h
@@ -57,6 +57,9 @@ static inline void platform_set_sysmmu(
 }
 #endif
 
+int __init s5p_create_iommu_mapping(struct device *client, dma_addr_t base,
+				    unsigned int size, int order);
+
 #else /* !CONFIG_EXYNOS_DEV_SYSMMU */
 #define platform_set_sysmmu(dev, sysmmu) do { } while (0)
 #endif
diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index 3b745bb..223e31e 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -166,6 +166,7 @@ config EXYNOS_IOMMU
 	bool "Exynos IOMMU Support"
 	depends on EXYNOS_DEV_SYSMMU
 	select IOMMU_API
+	select ARM_DMA_USE_IOMMU
 	help
 	  Support for the IOMMU(System MMU) of Samsung Exynos application
 	  processor family. This enables H/W multimedia accellerators to see
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
