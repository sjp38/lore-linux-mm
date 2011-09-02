Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6834C90013C
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 09:56:36 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LQW0060BEQ8XN30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 02 Sep 2011 14:56:32 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LQW00214EQ748@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 02 Sep 2011 14:56:32 +0100 (BST)
Date: Fri, 02 Sep 2011 15:56:26 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 2/2] ARM: Samsung: update/rewrite Samsung SYSMMU (IOMMU) driver
In-reply-to: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1314971786-15140-3-git-send-email-m.szyprowski@samsung.com>
References: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

This patch performs a complete rewrite of sysmmu driver for Samsung platform:
- simplified the resource management: no more single platform
  device with 32 resources is needed, better fits into linux driver model,
  each sysmmu instance has it's own resource definition
- the new version uses kernel wide common iommu api defined in include/iommu.h
- cleaned support for sysmmu clocks
- added support for automatic registration together with client device
- added support for newly introduced dma-mapping interface

Signed-off-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
[m.szyprowski: rebased onto v3.1-rc4, added automatic IOMMU device registration
 and support for proof-of-concept ARM DMA-mapping IOMMU mapper, added support
 for runtime_pm]
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 arch/arm/mach-exynos4/Kconfig                  |    5 -
 arch/arm/mach-exynos4/Makefile                 |    2 +-
 arch/arm/mach-exynos4/clock.c                  |   47 +-
 arch/arm/mach-exynos4/dev-sysmmu.c             |  609 +++++++++++------
 arch/arm/mach-exynos4/include/mach/irqs.h      |   34 +-
 arch/arm/mach-exynos4/include/mach/sysmmu.h    |   46 --
 arch/arm/plat-s5p/Kconfig                      |   21 +-
 arch/arm/plat-s5p/include/plat/sysmmu.h        |  119 ++--
 arch/arm/plat-s5p/sysmmu.c                     |  855 ++++++++++++++++++------
 arch/arm/plat-samsung/include/plat/devs.h      |    1 -
 arch/arm/plat-samsung/include/plat/fimc-core.h |   25 +
 11 files changed, 1197 insertions(+), 567 deletions(-)
 delete mode 100644 arch/arm/mach-exynos4/include/mach/sysmmu.h

diff --git a/arch/arm/mach-exynos4/Kconfig b/arch/arm/mach-exynos4/Kconfig
index 0c77ab9..3b3029b 100644
--- a/arch/arm/mach-exynos4/Kconfig
+++ b/arch/arm/mach-exynos4/Kconfig
@@ -36,11 +36,6 @@ config EXYNOS4_DEV_PD
 	help
 	  Compile in platform device definitions for Power Domain
 
-config EXYNOS4_DEV_SYSMMU
-	bool
-	help
-	  Common setup code for SYSTEM MMU in EXYNOS4
-
 config EXYNOS4_DEV_DWMCI
 	bool
 	help
diff --git a/arch/arm/mach-exynos4/Makefile b/arch/arm/mach-exynos4/Makefile
index b7fe1d7..0ab09da 100644
--- a/arch/arm/mach-exynos4/Makefile
+++ b/arch/arm/mach-exynos4/Makefile
@@ -36,7 +36,7 @@ obj-$(CONFIG_MACH_NURI)			+= mach-nuri.o
 obj-y					+= dev-audio.o
 obj-$(CONFIG_EXYNOS4_DEV_AHCI)		+= dev-ahci.o
 obj-$(CONFIG_EXYNOS4_DEV_PD)		+= dev-pd.o
-obj-$(CONFIG_EXYNOS4_DEV_SYSMMU)	+= dev-sysmmu.o
+obj-$(CONFIG_S5P_SYSTEM_MMU)		+= dev-sysmmu.o
 obj-$(CONFIG_EXYNOS4_DEV_DWMCI)	+= dev-dwmci.o
 
 obj-$(CONFIG_EXYNOS4_SETUP_FIMC)	+= setup-fimc.o
diff --git a/arch/arm/mach-exynos4/clock.c b/arch/arm/mach-exynos4/clock.c
index 851dea0..2ee1143 100644
--- a/arch/arm/mach-exynos4/clock.c
+++ b/arch/arm/mach-exynos4/clock.c
@@ -23,7 +23,6 @@
 
 #include <mach/map.h>
 #include <mach/regs-clock.h>
-#include <mach/sysmmu.h>
 
 static struct clk clk_sclk_hdmi27m = {
 	.name		= "sclk_hdmi27m",
@@ -581,59 +580,77 @@ static struct clk init_clocks_off[] = {
 		.enable		= exynos4_clk_ip_peril_ctrl,
 		.ctrlbit	= (1 << 13),
 	}, {
-		.name		= "SYSMMU_MDMA",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.0",
 		.enable		= exynos4_clk_ip_image_ctrl,
 		.ctrlbit	= (1 << 5),
 	}, {
-		.name		= "SYSMMU_FIMC0",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.2",
 		.enable		= exynos4_clk_ip_cam_ctrl,
+		.parent		= &init_clocks_off[3],
 		.ctrlbit	= (1 << 7),
 	}, {
-		.name		= "SYSMMU_FIMC1",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.3",
 		.enable		= exynos4_clk_ip_cam_ctrl,
+		.parent		= &init_clocks_off[4],
 		.ctrlbit	= (1 << 8),
 	}, {
-		.name		= "SYSMMU_FIMC2",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.4",
 		.enable		= exynos4_clk_ip_cam_ctrl,
+		.parent		= &init_clocks_off[5],
 		.ctrlbit	= (1 << 9),
 	}, {
-		.name		= "SYSMMU_FIMC3",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.5",
 		.enable		= exynos4_clk_ip_cam_ctrl,
+		.parent		= &init_clocks_off[6],
 		.ctrlbit	= (1 << 10),
 	}, {
-		.name		= "SYSMMU_JPEG",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.6",
 		.enable		= exynos4_clk_ip_cam_ctrl,
 		.ctrlbit	= (1 << 11),
 	}, {
-		.name		= "SYSMMU_FIMD0",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.7",
 		.enable		= exynos4_clk_ip_lcd0_ctrl,
 		.ctrlbit	= (1 << 4),
 	}, {
-		.name		= "SYSMMU_FIMD1",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.8",
 		.enable		= exynos4_clk_ip_lcd1_ctrl,
 		.ctrlbit	= (1 << 4),
 	}, {
-		.name		= "SYSMMU_PCIe",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.9",
 		.enable		= exynos4_clk_ip_fsys_ctrl,
 		.ctrlbit	= (1 << 18),
 	}, {
-		.name		= "SYSMMU_G2D",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.10",
 		.enable		= exynos4_clk_ip_image_ctrl,
 		.ctrlbit	= (1 << 3),
 	}, {
-		.name		= "SYSMMU_ROTATOR",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.11",
 		.enable		= exynos4_clk_ip_image_ctrl,
 		.ctrlbit	= (1 << 4),
 	}, {
-		.name		= "SYSMMU_TV",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.13",
 		.enable		= exynos4_clk_ip_tv_ctrl,
 		.ctrlbit	= (1 << 4),
 	}, {
-		.name		= "SYSMMU_MFC_L",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.14",
 		.enable		= exynos4_clk_ip_mfc_ctrl,
 		.ctrlbit	= (1 << 1),
 	}, {
-		.name		= "SYSMMU_MFC_R",
+		.name		= "sysmmu",
+		.devname	= "s5p-sysmmu.15",
 		.enable		= exynos4_clk_ip_mfc_ctrl,
 		.ctrlbit	= (1 << 2),
 	}
diff --git a/arch/arm/mach-exynos4/dev-sysmmu.c b/arch/arm/mach-exynos4/dev-sysmmu.c
index 3b7cae0..b49c922 100644
--- a/arch/arm/mach-exynos4/dev-sysmmu.c
+++ b/arch/arm/mach-exynos4/dev-sysmmu.c
@@ -13,220 +13,427 @@
 #include <linux/platform_device.h>
 #include <linux/dma-mapping.h>
 
+#include <asm/dma-iommu.h>
+
 #include <mach/map.h>
 #include <mach/irqs.h>
-#include <mach/sysmmu.h>
-#include <plat/s5p-clock.h>
-
-/* These names must be equal to the clock names in mach-exynos4/clock.c */
-const char *sysmmu_ips_name[EXYNOS4_SYSMMU_TOTAL_IPNUM] = {
-	"SYSMMU_MDMA"	,
-	"SYSMMU_SSS"	,
-	"SYSMMU_FIMC0"	,
-	"SYSMMU_FIMC1"	,
-	"SYSMMU_FIMC2"	,
-	"SYSMMU_FIMC3"	,
-	"SYSMMU_JPEG"	,
-	"SYSMMU_FIMD0"	,
-	"SYSMMU_FIMD1"	,
-	"SYSMMU_PCIe"	,
-	"SYSMMU_G2D"	,
-	"SYSMMU_ROTATOR",
-	"SYSMMU_MDMA2"	,
-	"SYSMMU_TV"	,
-	"SYSMMU_MFC_L"	,
-	"SYSMMU_MFC_R"	,
-};
 
-static struct resource exynos4_sysmmu_resource[] = {
-	[0] = {
-		.start	= EXYNOS4_PA_SYSMMU_MDMA,
-		.end	= EXYNOS4_PA_SYSMMU_MDMA + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[1] = {
-		.start	= IRQ_SYSMMU_MDMA0_0,
-		.end	= IRQ_SYSMMU_MDMA0_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[2] = {
-		.start	= EXYNOS4_PA_SYSMMU_SSS,
-		.end	= EXYNOS4_PA_SYSMMU_SSS + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[3] = {
-		.start	= IRQ_SYSMMU_SSS_0,
-		.end	= IRQ_SYSMMU_SSS_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[4] = {
-		.start	= EXYNOS4_PA_SYSMMU_FIMC0,
-		.end	= EXYNOS4_PA_SYSMMU_FIMC0 + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[5] = {
-		.start	= IRQ_SYSMMU_FIMC0_0,
-		.end	= IRQ_SYSMMU_FIMC0_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[6] = {
-		.start	= EXYNOS4_PA_SYSMMU_FIMC1,
-		.end	= EXYNOS4_PA_SYSMMU_FIMC1 + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[7] = {
-		.start	= IRQ_SYSMMU_FIMC1_0,
-		.end	= IRQ_SYSMMU_FIMC1_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[8] = {
-		.start	= EXYNOS4_PA_SYSMMU_FIMC2,
-		.end	= EXYNOS4_PA_SYSMMU_FIMC2 + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[9] = {
-		.start	= IRQ_SYSMMU_FIMC2_0,
-		.end	= IRQ_SYSMMU_FIMC2_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[10] = {
-		.start	= EXYNOS4_PA_SYSMMU_FIMC3,
-		.end	= EXYNOS4_PA_SYSMMU_FIMC3 + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[11] = {
-		.start	= IRQ_SYSMMU_FIMC3_0,
-		.end	= IRQ_SYSMMU_FIMC3_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[12] = {
-		.start	= EXYNOS4_PA_SYSMMU_JPEG,
-		.end	= EXYNOS4_PA_SYSMMU_JPEG + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[13] = {
-		.start	= IRQ_SYSMMU_JPEG_0,
-		.end	= IRQ_SYSMMU_JPEG_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[14] = {
-		.start	= EXYNOS4_PA_SYSMMU_FIMD0,
-		.end	= EXYNOS4_PA_SYSMMU_FIMD0 + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[15] = {
-		.start	= IRQ_SYSMMU_LCD0_M0_0,
-		.end	= IRQ_SYSMMU_LCD0_M0_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[16] = {
-		.start	= EXYNOS4_PA_SYSMMU_FIMD1,
-		.end	= EXYNOS4_PA_SYSMMU_FIMD1 + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[17] = {
-		.start	= IRQ_SYSMMU_LCD1_M1_0,
-		.end	= IRQ_SYSMMU_LCD1_M1_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[18] = {
-		.start	= EXYNOS4_PA_SYSMMU_PCIe,
-		.end	= EXYNOS4_PA_SYSMMU_PCIe + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[19] = {
-		.start	= IRQ_SYSMMU_PCIE_0,
-		.end	= IRQ_SYSMMU_PCIE_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[20] = {
-		.start	= EXYNOS4_PA_SYSMMU_G2D,
-		.end	= EXYNOS4_PA_SYSMMU_G2D + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[21] = {
-		.start	= IRQ_SYSMMU_2D_0,
-		.end	= IRQ_SYSMMU_2D_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[22] = {
-		.start	= EXYNOS4_PA_SYSMMU_ROTATOR,
-		.end	= EXYNOS4_PA_SYSMMU_ROTATOR + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[23] = {
-		.start	= IRQ_SYSMMU_ROTATOR_0,
-		.end	= IRQ_SYSMMU_ROTATOR_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[24] = {
-		.start	= EXYNOS4_PA_SYSMMU_MDMA2,
-		.end	= EXYNOS4_PA_SYSMMU_MDMA2 + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[25] = {
-		.start	= IRQ_SYSMMU_MDMA1_0,
-		.end	= IRQ_SYSMMU_MDMA1_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[26] = {
-		.start	= EXYNOS4_PA_SYSMMU_TV,
-		.end	= EXYNOS4_PA_SYSMMU_TV + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[27] = {
-		.start	= IRQ_SYSMMU_TV_M0_0,
-		.end	= IRQ_SYSMMU_TV_M0_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[28] = {
-		.start	= EXYNOS4_PA_SYSMMU_MFC_L,
-		.end	= EXYNOS4_PA_SYSMMU_MFC_L + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[29] = {
-		.start	= IRQ_SYSMMU_MFC_M0_0,
-		.end	= IRQ_SYSMMU_MFC_M0_0,
-		.flags	= IORESOURCE_IRQ,
-	},
-	[30] = {
-		.start	= EXYNOS4_PA_SYSMMU_MFC_R,
-		.end	= EXYNOS4_PA_SYSMMU_MFC_R + SZ_64K - 1,
-		.flags	= IORESOURCE_MEM,
-	},
-	[31] = {
-		.start	= IRQ_SYSMMU_MFC_M1_0,
-		.end	= IRQ_SYSMMU_MFC_M1_0,
-		.flags	= IORESOURCE_IRQ,
+#include <plat/devs.h>
+#include <plat/cpu.h>
+#include <plat/sysmmu.h>
+
+#include <plat/fimc-core.h>
+
+#define EXYNOS4_NUM_RESOURCES (2)
+
+static struct resource exynos4_sysmmu_resource[][EXYNOS4_NUM_RESOURCES] = {
+	[S5P_SYSMMU_MDMA] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_MDMA,
+			.end	= EXYNOS4_PA_SYSMMU_MDMA + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_MDMA0,
+			.end	= IRQ_SYSMMU_MDMA0,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_SSS] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_SSS,
+			.end	= EXYNOS4_PA_SYSMMU_SSS + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_SSS,
+			.end	= IRQ_SYSMMU_SSS,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_FIMC0] = {
+		[0] = {
+			.start = EXYNOS4_PA_SYSMMU_FIMC0,
+			.end   = EXYNOS4_PA_SYSMMU_FIMC0 + SZ_4K - 1,
+			.flags = IORESOURCE_MEM,
+		},
+		[1] = {
+			.start = IRQ_SYSMMU_FIMC0,
+			.end   = IRQ_SYSMMU_FIMC0,
+			.flags = IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_FIMC1] = {
+		[0] = {
+			.start = EXYNOS4_PA_SYSMMU_FIMC1,
+			.end   = EXYNOS4_PA_SYSMMU_FIMC1 + SZ_4K - 1,
+			.flags = IORESOURCE_MEM,
+		},
+		[1] = {
+			.start = IRQ_SYSMMU_FIMC1,
+			.end   = IRQ_SYSMMU_FIMC1,
+			.flags = IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_FIMC2] = {
+		[0] = {
+			.start = EXYNOS4_PA_SYSMMU_FIMC2,
+			.end   = EXYNOS4_PA_SYSMMU_FIMC2 + SZ_4K - 1,
+			.flags = IORESOURCE_MEM,
+		},
+		[1] = {
+			.start = IRQ_SYSMMU_FIMC2,
+			.end   = IRQ_SYSMMU_FIMC2,
+			.flags = IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_FIMC3] = {
+		[0] = {
+			.start = EXYNOS4_PA_SYSMMU_FIMC3,
+			.end   = EXYNOS4_PA_SYSMMU_FIMC3 + SZ_4K - 1,
+			.flags = IORESOURCE_MEM,
+		},
+		[1] = {
+			.start = IRQ_SYSMMU_FIMC3,
+			.end   = IRQ_SYSMMU_FIMC3,
+			.flags = IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_JPEG] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_JPEG,
+			.end	= EXYNOS4_PA_SYSMMU_JPEG + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_JPEG,
+			.end	= IRQ_SYSMMU_JPEG,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_FIMD0] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_FIMD0,
+			.end	= EXYNOS4_PA_SYSMMU_FIMD0 + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_FIMD0,
+			.end	= IRQ_SYSMMU_FIMD0,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_FIMD1] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_FIMD1,
+			.end	= EXYNOS4_PA_SYSMMU_FIMD1 + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_FIMD1,
+			.end	= IRQ_SYSMMU_FIMD1,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_PCIe] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_PCIe,
+			.end	= EXYNOS4_PA_SYSMMU_PCIe + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_PCIE,
+			.end	= IRQ_SYSMMU_PCIE,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_G2D] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_G2D,
+			.end	= EXYNOS4_PA_SYSMMU_G2D + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_G2D,
+			.end	= IRQ_SYSMMU_G2D,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_ROTATOR] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_ROTATOR,
+			.end	= EXYNOS4_PA_SYSMMU_ROTATOR + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_ROTATOR,
+			.end	= IRQ_SYSMMU_ROTATOR,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_MDMA2] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_MDMA2,
+			.end	= EXYNOS4_PA_SYSMMU_MDMA2 + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_MDMA1,
+			.end	= IRQ_SYSMMU_MDMA1,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_TV] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_TV,
+			.end	= EXYNOS4_PA_SYSMMU_TV + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_TV,
+			.end	= IRQ_SYSMMU_TV,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_MFC_L] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_MFC_L,
+			.end	= EXYNOS4_PA_SYSMMU_MFC_L + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_MFC_L,
+			.end	= IRQ_SYSMMU_MFC_L,
+			.flags	= IORESOURCE_IRQ,
+		},
+	},
+	[S5P_SYSMMU_MFC_R] = {
+		[0] = {
+			.start	= EXYNOS4_PA_SYSMMU_MFC_R,
+			.end	= EXYNOS4_PA_SYSMMU_MFC_R + SZ_4K - 1,
+			.flags	= IORESOURCE_MEM,
+		},
+		[1] = {
+			.start	= IRQ_SYSMMU_MFC_R,
+			.end	= IRQ_SYSMMU_MFC_R,
+			.flags	= IORESOURCE_IRQ,
+		},
 	},
 };
 
-struct platform_device exynos4_device_sysmmu = {
-	.name		= "s5p-sysmmu",
-	.id		= 32,
-	.num_resources	= ARRAY_SIZE(exynos4_sysmmu_resource),
-	.resource	= exynos4_sysmmu_resource,
+static u64 exynos4_sysmmu_dma_mask = DMA_BIT_MASK(32);
+
+struct platform_device exynos4_device_sysmmu[] = {
+	[S5P_SYSMMU_MDMA] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_MDMA,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_MDMA],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_SSS] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_SSS,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_SSS],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_FIMC0] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_FIMC0,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_FIMC0],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_FIMC1] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_FIMC1,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_FIMC1],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_FIMC2] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_FIMC2,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_FIMC2],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_FIMC3] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_FIMC3,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_FIMC3],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_JPEG] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_JPEG,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_JPEG],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_FIMD0] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_FIMD0,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_FIMD0],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_FIMD1] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_FIMD1,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_FIMD1],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_PCIe] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_PCIe,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_PCIe],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_G2D] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_G2D,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_G2D],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_ROTATOR] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_ROTATOR,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_ROTATOR],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_MDMA2] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_MDMA2,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_MDMA2],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_TV] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_TV,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_TV],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_MFC_L] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_MFC_L,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_MFC_L],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
+	[S5P_SYSMMU_MFC_R] = {
+		.name		= "s5p-sysmmu",
+		.id		= S5P_SYSMMU_MFC_R,
+		.num_resources	= EXYNOS4_NUM_RESOURCES,
+		.resource	= exynos4_sysmmu_resource[S5P_SYSMMU_MFC_R],
+		.dev		= {
+			.dma_mask		= &exynos4_sysmmu_dma_mask,
+			.coherent_dma_mask	= DMA_BIT_MASK(32),
+		},
+	},
 };
-EXPORT_SYMBOL(exynos4_device_sysmmu);
 
-static struct clk *sysmmu_clk[S5P_SYSMMU_TOTAL_IPNUM];
-void sysmmu_clk_init(struct device *dev, sysmmu_ips ips)
+static void __init s5p_register_sysmmu(struct platform_device *pdev,
+				       struct device *client)
 {
-	sysmmu_clk[ips] = clk_get(dev, sysmmu_ips_name[ips]);
-	if (IS_ERR(sysmmu_clk[ips]))
-		sysmmu_clk[ips] = NULL;
-	else
-		clk_put(sysmmu_clk[ips]);
+	if (!client)
+		return;
+	if (client->parent)
+		pdev->dev.parent = client->parent;
+	client->parent = &pdev->dev;
+	platform_device_register(pdev);
+	s5p_sysmmu_assign_dev(client, pdev);
 }
 
-void sysmmu_clk_enable(sysmmu_ips ips)
+/**
+ * s5p_sysmmu_core_init
+ * Register respective SYSMMU controller platform device and assign it to
+ * client device.
+ * Must be called before client device is registered by the board code.
+ */
+static int __init s5p_sysmmu_core_init(void)
 {
-	if (sysmmu_clk[ips])
-		clk_enable(sysmmu_clk[ips]);
+	struct platform_device *pdev;
+	int i;
+
+	for (i=0; i < S5P_MAX_FIMC_NUM; i++) {
+		pdev = &exynos4_device_sysmmu[S5P_SYSMMU_FIMC0 + i];
+		s5p_register_sysmmu(pdev, s3c_fimc_getdevice(i));
+	}
+
+	return 0;
 }
+core_initcall(s5p_sysmmu_core_init);
 
-void sysmmu_clk_disable(sysmmu_ips ips)
+/**
+ * s5p_sysmmu_late_init
+ * Register all client devices to IOMMU aware DMA-mapping subsystem.
+ * Must be called after SYSMMU driver is registered in the system.
+ */
+static int __init s5p_sysmmu_late_init(void)
 {
-	if (sysmmu_clk[ips])
-		clk_disable(sysmmu_clk[ips]);
+	int i;
+
+	for (i=0; i < S5P_MAX_FIMC_NUM; i++) {
+		struct device *client = s3c_fimc_getdevice(i);
+		if (!client)
+			continue;
+		arm_iommu_attach_device(client, 0x20000000, SZ_128M, 4);
+	}
+
+	return 0;
 }
+arch_initcall(s5p_sysmmu_late_init);
diff --git a/arch/arm/mach-exynos4/include/mach/irqs.h b/arch/arm/mach-exynos4/include/mach/irqs.h
index 934d2a4..89889a1 100644
--- a/arch/arm/mach-exynos4/include/mach/irqs.h
+++ b/arch/arm/mach-exynos4/include/mach/irqs.h
@@ -120,23 +120,23 @@
 #define COMBINER_GROUP(x)	((x) * MAX_IRQ_IN_COMBINER + IRQ_SPI(128))
 #define COMBINER_IRQ(x, y)	(COMBINER_GROUP(x) + y)
 
-#define IRQ_SYSMMU_MDMA0_0	COMBINER_IRQ(4, 0)
-#define IRQ_SYSMMU_SSS_0	COMBINER_IRQ(4, 1)
-#define IRQ_SYSMMU_FIMC0_0	COMBINER_IRQ(4, 2)
-#define IRQ_SYSMMU_FIMC1_0	COMBINER_IRQ(4, 3)
-#define IRQ_SYSMMU_FIMC2_0	COMBINER_IRQ(4, 4)
-#define IRQ_SYSMMU_FIMC3_0	COMBINER_IRQ(4, 5)
-#define IRQ_SYSMMU_JPEG_0	COMBINER_IRQ(4, 6)
-#define IRQ_SYSMMU_2D_0		COMBINER_IRQ(4, 7)
-
-#define IRQ_SYSMMU_ROTATOR_0	COMBINER_IRQ(5, 0)
-#define IRQ_SYSMMU_MDMA1_0	COMBINER_IRQ(5, 1)
-#define IRQ_SYSMMU_LCD0_M0_0	COMBINER_IRQ(5, 2)
-#define IRQ_SYSMMU_LCD1_M1_0	COMBINER_IRQ(5, 3)
-#define IRQ_SYSMMU_TV_M0_0	COMBINER_IRQ(5, 4)
-#define IRQ_SYSMMU_MFC_M0_0	COMBINER_IRQ(5, 5)
-#define IRQ_SYSMMU_MFC_M1_0	COMBINER_IRQ(5, 6)
-#define IRQ_SYSMMU_PCIE_0	COMBINER_IRQ(5, 7)
+#define IRQ_SYSMMU_MDMA0	COMBINER_IRQ(4, 0)
+#define IRQ_SYSMMU_SSS		COMBINER_IRQ(4, 1)
+#define IRQ_SYSMMU_FIMC0	COMBINER_IRQ(4, 2)
+#define IRQ_SYSMMU_FIMC1	COMBINER_IRQ(4, 3)
+#define IRQ_SYSMMU_FIMC2	COMBINER_IRQ(4, 4)
+#define IRQ_SYSMMU_FIMC3	COMBINER_IRQ(4, 5)
+#define IRQ_SYSMMU_JPEG		COMBINER_IRQ(4, 6)
+#define IRQ_SYSMMU_G2D		COMBINER_IRQ(4, 7)
+
+#define IRQ_SYSMMU_ROTATOR	COMBINER_IRQ(5, 0)
+#define IRQ_SYSMMU_MDMA1	COMBINER_IRQ(5, 1)
+#define IRQ_SYSMMU_FIMD0	COMBINER_IRQ(5, 2)
+#define IRQ_SYSMMU_FIMD1	COMBINER_IRQ(5, 3)
+#define IRQ_SYSMMU_TV		COMBINER_IRQ(5, 4)
+#define IRQ_SYSMMU_MFC_L	COMBINER_IRQ(5, 5)
+#define IRQ_SYSMMU_MFC_R	COMBINER_IRQ(5, 6)
+#define IRQ_SYSMMU_PCIE		COMBINER_IRQ(5, 7)
 
 #define IRQ_FIMD0_FIFO		COMBINER_IRQ(11, 0)
 #define IRQ_FIMD0_VSYNC		COMBINER_IRQ(11, 1)
diff --git a/arch/arm/mach-exynos4/include/mach/sysmmu.h b/arch/arm/mach-exynos4/include/mach/sysmmu.h
deleted file mode 100644
index 6a5fbb5..0000000
--- a/arch/arm/mach-exynos4/include/mach/sysmmu.h
+++ /dev/null
@@ -1,46 +0,0 @@
-/* linux/arch/arm/mach-exynos4/include/mach/sysmmu.h
- *
- * Copyright (c) 2010-2011 Samsung Electronics Co., Ltd.
- *		http://www.samsung.com
- *
- * Samsung sysmmu driver for EXYNOS4
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
-*/
-
-#ifndef __ASM_ARM_ARCH_SYSMMU_H
-#define __ASM_ARM_ARCH_SYSMMU_H __FILE__
-
-enum exynos4_sysmmu_ips {
-	SYSMMU_MDMA,
-	SYSMMU_SSS,
-	SYSMMU_FIMC0,
-	SYSMMU_FIMC1,
-	SYSMMU_FIMC2,
-	SYSMMU_FIMC3,
-	SYSMMU_JPEG,
-	SYSMMU_FIMD0,
-	SYSMMU_FIMD1,
-	SYSMMU_PCIe,
-	SYSMMU_G2D,
-	SYSMMU_ROTATOR,
-	SYSMMU_MDMA2,
-	SYSMMU_TV,
-	SYSMMU_MFC_L,
-	SYSMMU_MFC_R,
-	EXYNOS4_SYSMMU_TOTAL_IPNUM,
-};
-
-#define S5P_SYSMMU_TOTAL_IPNUM		EXYNOS4_SYSMMU_TOTAL_IPNUM
-
-extern const char *sysmmu_ips_name[EXYNOS4_SYSMMU_TOTAL_IPNUM];
-
-typedef enum exynos4_sysmmu_ips sysmmu_ips;
-
-void sysmmu_clk_init(struct device *dev, sysmmu_ips ips);
-void sysmmu_clk_enable(sysmmu_ips ips);
-void sysmmu_clk_disable(sysmmu_ips ips);
-
-#endif /* __ASM_ARM_ARCH_SYSMMU_H */
diff --git a/arch/arm/plat-s5p/Kconfig b/arch/arm/plat-s5p/Kconfig
index 9843c95..9013cb3 100644
--- a/arch/arm/plat-s5p/Kconfig
+++ b/arch/arm/plat-s5p/Kconfig
@@ -43,14 +43,6 @@ config S5P_HRT
 	help
 	  Use the High Resolution timer support
 
-comment "System MMU"
-
-config S5P_SYSTEM_MMU
-	bool "S5P SYSTEM MMU"
-	depends on ARCH_EXYNOS4
-	help
-	  Say Y here if you want to enable System MMU
-
 config S5P_DEV_FIMC0
 	bool
 	help
@@ -105,3 +97,16 @@ config S5P_SETUP_MIPIPHY
 	bool
 	help
 	  Compile in common setup code for MIPI-CSIS and MIPI-DSIM devices
+
+comment "System MMU"
+
+config IOMMU_API
+	bool
+
+config S5P_SYSTEM_MMU
+	bool "S5P SYSTEM MMU"
+	depends on ARCH_EXYNOS4
+	select IOMMU_API
+	select ARM_DMA_USE_IOMMU
+	help
+	  Say Y here if you want to enable System MMU
diff --git a/arch/arm/plat-s5p/include/plat/sysmmu.h b/arch/arm/plat-s5p/include/plat/sysmmu.h
index bf5283c..91e9293 100644
--- a/arch/arm/plat-s5p/include/plat/sysmmu.h
+++ b/arch/arm/plat-s5p/include/plat/sysmmu.h
@@ -2,6 +2,7 @@
  *
  * Copyright (c) 2010-2011 Samsung Electronics Co., Ltd.
  *		http://www.samsung.com
+ * Author: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
  *
  * Samsung System MMU driver for S5P platform
  *
@@ -13,83 +14,57 @@
 #ifndef __ASM__PLAT_SYSMMU_H
 #define __ASM__PLAT_SYSMMU_H __FILE__
 
-enum S5P_SYSMMU_INTERRUPT_TYPE {
-	SYSMMU_PAGEFAULT,
-	SYSMMU_AR_MULTIHIT,
-	SYSMMU_AW_MULTIHIT,
-	SYSMMU_BUSERROR,
-	SYSMMU_AR_SECURITY,
-	SYSMMU_AR_ACCESS,
-	SYSMMU_AW_SECURITY,
-	SYSMMU_AW_PROTECTION, /* 7 */
-	SYSMMU_FAULTS_NUM
-};
-
-#ifdef CONFIG_S5P_SYSTEM_MMU
-
-#include <mach/sysmmu.h>
-
-/**
- * s5p_sysmmu_enable() - enable system mmu of ip
- * @ips: The ip connected system mmu.
- * #pgd: Base physical address of the 1st level page table
- *
- * This function enable system mmu to transfer address
- * from virtual address to physical address
- */
-void s5p_sysmmu_enable(sysmmu_ips ips, unsigned long pgd);
-
-/**
- * s5p_sysmmu_disable() - disable sysmmu mmu of ip
- * @ips: The ip connected system mmu.
- *
- * This function disable system mmu to transfer address
- * from virtual address to physical address
- */
-void s5p_sysmmu_disable(sysmmu_ips ips);
+struct device;
 
 /**
- * s5p_sysmmu_set_tablebase_pgd() - set page table base address to refer page table
- * @ips: The ip connected system mmu.
- * @pgd: The page table base address.
- *
- * This function set page table base address
- * When system mmu transfer address from virtaul address to physical address,
- * system mmu refer address information from page table
+ * enum s5p_sysmmu_ip - integrated peripherals identifiers
+ * @S5P_SYSMMU_MDMA:	MDMA
+ * @S5P_SYSMMU_SSS:	SSS
+ * @S5P_SYSMMU_FIMC0:	FIMC0
+ * @S5P_SYSMMU_FIMC1:	FIMC1
+ * @S5P_SYSMMU_FIMC2:	FIMC2
+ * @S5P_SYSMMU_FIMC3:	FIMC3
+ * @S5P_SYSMMU_JPEG:	JPEG
+ * @S5P_SYSMMU_FIMD0:	FIMD0
+ * @S5P_SYSMMU_FIMD1:	FIMD1
+ * @S5P_SYSMMU_PCIe:	PCIe
+ * @S5P_SYSMMU_G2D:	G2D
+ * @S5P_SYSMMU_ROTATOR:	ROTATOR
+ * @S5P_SYSMMU_MDMA2:	MDMA2
+ * @S5P_SYSMMU_TV:	TV
+ * @S5P_SYSMMU_MFC_L:	MFC_L
+ * @S5P_SYSMMU_MFC_R:	MFC_R
  */
-void s5p_sysmmu_set_tablebase_pgd(sysmmu_ips ips, unsigned long pgd);
+enum s5p_sysmmu_ip {
+	S5P_SYSMMU_MDMA,
+	S5P_SYSMMU_SSS,
+	S5P_SYSMMU_FIMC0,
+	S5P_SYSMMU_FIMC1,
+	S5P_SYSMMU_FIMC2,
+	S5P_SYSMMU_FIMC3,
+	S5P_SYSMMU_JPEG,
+	S5P_SYSMMU_FIMD0,
+	S5P_SYSMMU_FIMD1,
+	S5P_SYSMMU_PCIe,
+	S5P_SYSMMU_G2D,
+	S5P_SYSMMU_ROTATOR,
+	S5P_SYSMMU_MDMA2,
+	S5P_SYSMMU_TV,
+	S5P_SYSMMU_MFC_L,
+	S5P_SYSMMU_MFC_R,
+	S5P_SYSMMU_TOTAL_IP_NUM,
+};
 
 /**
- * s5p_sysmmu_tlb_invalidate() - flush all TLB entry in system mmu
- * @ips: The ip connected system mmu.
- *
- * This function flush all TLB entry in system mmu
+ * s5p_sysmmu_assign_dev() - assign sysmmu controller to client device
+ * @dev:	client device
+ * @iommu_pdev:	platform device of sysmmu controller
  */
-void s5p_sysmmu_tlb_invalidate(sysmmu_ips ips);
+static inline void s5p_sysmmu_assign_dev(struct device *dev,
+					 struct platform_device *iommu_pdev)
+{
+	BUG_ON(dev->archdata.iommu_priv);
+	dev->archdata.iommu_priv = iommu_pdev;
+}
 
-/** s5p_sysmmu_set_fault_handler() - Fault handler for System MMUs
- * @itype: type of fault.
- * @pgtable_base: the physical address of page table base. This is 0 if @ips is
- *               SYSMMU_BUSERROR.
- * @fault_addr: the device (virtual) address that the System MMU tried to
- *             translated. This is 0 if @ips is SYSMMU_BUSERROR.
- * Called when interrupt occurred by the System MMUs
- * The device drivers of peripheral devices that has a System MMU can implement
- * a fault handler to resolve address translation fault by System MMU.
- * The meanings of return value and parameters are described below.
-
- * return value: non-zero if the fault is correctly resolved.
- *         zero if the fault is not handled.
- */
-void s5p_sysmmu_set_fault_handler(sysmmu_ips ips,
-			int (*handler)(enum S5P_SYSMMU_INTERRUPT_TYPE itype,
-					unsigned long pgtable_base,
-					unsigned long fault_addr));
-#else
-#define s5p_sysmmu_enable(ips, pgd) do { } while (0)
-#define s5p_sysmmu_disable(ips) do { } while (0)
-#define s5p_sysmmu_set_tablebase_pgd(ips, pgd) do { } while (0)
-#define s5p_sysmmu_tlb_invalidate(ips) do { } while (0)
-#define s5p_sysmmu_set_fault_handler(ips, handler) do { } while (0)
-#endif
 #endif /* __ASM_PLAT_SYSMMU_H */
diff --git a/arch/arm/plat-s5p/sysmmu.c b/arch/arm/plat-s5p/sysmmu.c
index e1cbc72..b537e1c 100644
--- a/arch/arm/plat-s5p/sysmmu.c
+++ b/arch/arm/plat-s5p/sysmmu.c
@@ -1,312 +1,765 @@
 /* linux/arch/arm/plat-s5p/sysmmu.c
  *
- * Copyright (c) 2010 Samsung Electronics Co., Ltd.
+ * Copyright (c) 2010-2011 Samsung Electronics Co., Ltd.
  *		http://www.samsung.com
  *
+ * Author: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
 
-#include <linux/io.h>
-#include <linux/interrupt.h>
+#include <linux/gfp.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
 #include <linux/platform_device.h>
-
-#include <asm/pgtable.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/module.h>
+#include <linux/clk.h>
+#include <linux/pm_runtime.h>
+#include <linux/iommu.h>
+
+#include <asm/memory.h>
+
+#include <plat/irqs.h>
+#include <plat/devs.h>
+#include <plat/cpu.h>
+#include <plat/sysmmu.h>
 
 #include <mach/map.h>
 #include <mach/regs-sysmmu.h>
-#include <plat/sysmmu.h>
 
-#define CTRL_ENABLE	0x5
-#define CTRL_BLOCK	0x7
-#define CTRL_DISABLE	0x0
-
-static struct device *dev;
-
-static unsigned short fault_reg_offset[SYSMMU_FAULTS_NUM] = {
-	S5P_PAGE_FAULT_ADDR,
-	S5P_AR_FAULT_ADDR,
-	S5P_AW_FAULT_ADDR,
-	S5P_DEFAULT_SLAVE_ADDR,
-	S5P_AR_FAULT_ADDR,
-	S5P_AR_FAULT_ADDR,
-	S5P_AW_FAULT_ADDR,
-	S5P_AW_FAULT_ADDR
+static int debug;
+module_param(debug, int, 0644);
+
+#define sysmmu_debug(level, fmt, arg...)				 \
+	do {								 \
+		if (debug >= level)					 \
+			printk(KERN_DEBUG "[%s] " fmt, __func__, ## arg);\
+	} while (0)
+
+#define FLPT_ENTRIES		4096
+#define FLPT_4K_64K_MASK	(~0x3FF)
+#define FLPT_1M_MASK		(~0xFFFFF)
+#define FLPT_16M_MASK		(~0xFFFFFF)
+#define SLPT_4K_MASK		(~0xFFF)
+#define SLPT_64K_MASK		(~0xFFFF)
+#define PAGE_4K_64K		0x1
+#define PAGE_1M			0x2
+#define PAGE_16M		0x40002
+#define PAGE_4K			0x2
+#define PAGE_64K		0x1
+#define FLPT_IDX_SHIFT		20
+#define FLPT_IDX_MASK		0xFFF
+#define FLPT_OFFS_SHIFT		(FLPT_IDX_SHIFT - 2)
+#define FLPT_OFFS_MASK		(FLPT_IDX_MASK << 2)
+#define SLPT_IDX_SHIFT		12
+#define SLPT_IDX_MASK		0xFF
+#define SLPT_OFFS_SHIFT		(SLPT_IDX_SHIFT - 2)
+#define SLPT_OFFS_MASK		(SLPT_IDX_MASK << 2)
+
+#define deref_va(va)		(*((unsigned long *)(va)))
+
+#define generic_extract(l, s, entry) \
+				((entry) & l##LPT_##s##_MASK)
+#define flpt_get_1m(entry)	generic_extract(F, 1M, deref_va(entry))
+#define flpt_get_16m(entry)	generic_extract(F, 16M, deref_va(entry))
+#define slpt_get_4k(entry)	generic_extract(S, 4K, deref_va(entry))
+#define slpt_get_64k(entry)	generic_extract(S, 64K, deref_va(entry))
+
+#define generic_entry(l, s, entry) \
+				(generic_extract(l, s, entry)  | PAGE_##s)
+#define flpt_ent_4k_64k(entry)	generic_entry(F, 4K_64K, entry)
+#define flpt_ent_1m(entry)	generic_entry(F, 1M, entry)
+#define flpt_ent_16m(entry)	generic_entry(F, 16M, entry)
+#define slpt_ent_4k(entry)	generic_entry(S, 4K, entry)
+#define slpt_ent_64k(entry)	generic_entry(S, 64K, entry)
+
+#define page_4k_64k(entry)	(deref_va(entry) & PAGE_4K_64K)
+#define page_1m(entry)		(deref_va(entry) & PAGE_1M)
+#define page_16m(entry)		((deref_va(entry) & PAGE_16M) == PAGE_16M)
+#define page_4k(entry)		(deref_va(entry) & PAGE_4K)
+#define page_64k(entry)		(deref_va(entry) & PAGE_64K)
+
+#define generic_pg_offs(l, s, va) \
+				(va & ~l##LPT_##s##_MASK)
+#define pg_offs_1m(va)		generic_pg_offs(F, 1M, va)
+#define pg_offs_16m(va)		generic_pg_offs(F, 16M, va)
+#define pg_offs_4k(va)		generic_pg_offs(S, 4K, va)
+#define pg_offs_64k(va)		generic_pg_offs(S, 64K, va)
+
+#define flpt_index(va)		(((va) >> FLPT_IDX_SHIFT) & FLPT_IDX_MASK)
+
+#define generic_offset(l, va)	(((va) >> l##LPT_OFFS_SHIFT) & l##LPT_OFFS_MASK)
+#define flpt_offs(va)		generic_offset(F, va)
+#define slpt_offs(va)		generic_offset(S, va)
+
+#define invalidate_slpt_ent(slpt_va) (deref_va(slpt_va) = 0UL)
+
+struct s5p_sysmmu_info {
+	struct resource		*ioarea;
+	void __iomem		*regs;
+	unsigned int		irq;
+	struct clk		*clk;
+	bool			enabled;
+	enum s5p_sysmmu_ip	ip;
+
+	struct device		*dev;
+	struct s5p_sysmmu_domain *domain;
 };
 
-static char *sysmmu_fault_name[SYSMMU_FAULTS_NUM] = {
-	"PAGE FAULT",
-	"AR MULTI-HIT FAULT",
-	"AW MULTI-HIT FAULT",
-	"BUS ERROR",
-	"AR SECURITY PROTECTION FAULT",
-	"AR ACCESS PROTECTION FAULT",
-	"AW SECURITY PROTECTION FAULT",
-	"AW ACCESS PROTECTION FAULT"
-};
-
-static int (*fault_handlers[S5P_SYSMMU_TOTAL_IPNUM])(
-		enum S5P_SYSMMU_INTERRUPT_TYPE itype,
-		unsigned long pgtable_base,
-		unsigned long fault_addr);
+static struct s5p_sysmmu_info *sysmmu_table[S5P_SYSMMU_TOTAL_IP_NUM];
+static DEFINE_SPINLOCK(sysmmu_slock);
 
 /*
- * If adjacent 2 bits are true, the system MMU is enabled.
- * The system MMU is disabled, otherwise.
+ * iommu domain is a virtual address space of an I/O device driver.
+ * It contains kernel virtual and physical addresses of the first level
+ * page table and owns the memory in which the page tables are stored.
+ * It contains a table of kernel virtual addresses of second level
+ * page tables.
+ *
+ * In order to be used the iommu domain must be bound to an iommu device.
+ * This is accomplished with s5p_sysmmu_attach_dev, which is called through
+ * s5p_sysmmu_ops by drivers/base/iommu.c.
  */
-static unsigned long sysmmu_states;
+struct s5p_sysmmu_domain {
+	unsigned long		flpt;
+	void			*flpt_va;
+	void			**slpt_va;
+	unsigned short		*refcount;
+	struct s5p_sysmmu_info	*sysmmu;
+};
 
-static inline void set_sysmmu_active(sysmmu_ips ips)
-{
-	sysmmu_states |= 3 << (ips * 2);
-}
+static struct kmem_cache *slpt_cache;
 
-static inline void set_sysmmu_inactive(sysmmu_ips ips)
+static void flush_cache(const void *start, unsigned long size)
 {
-	sysmmu_states &= ~(3 << (ips * 2));
+	dmac_flush_range(start, start + size);
+	outer_flush_range(virt_to_phys(start), virt_to_phys(start + size));
 }
 
-static inline int is_sysmmu_active(sysmmu_ips ips)
+static int s5p_sysmmu_domain_init(struct iommu_domain *domain)
 {
-	return sysmmu_states & (3 << (ips * 2));
-}
+	struct s5p_sysmmu_domain *s5p_domain;
 
-static void __iomem *sysmmusfrs[S5P_SYSMMU_TOTAL_IPNUM];
+	s5p_domain = kzalloc(sizeof(struct s5p_sysmmu_domain), GFP_KERNEL);
+	if (!s5p_domain) {
+		sysmmu_debug(3, "no memory for state\n");
+		return -ENOMEM;
+	}
+	domain->priv = s5p_domain;
+
+	/*
+	 * first-level page table holds
+	 * 4k second-level descriptors == 16kB == 4 pages
+	 */
+	s5p_domain->flpt_va = kzalloc(FLPT_ENTRIES * sizeof(unsigned long),
+					 GFP_KERNEL);
+	if (!s5p_domain->flpt_va)
+		return -ENOMEM;
+	s5p_domain->flpt = virt_to_phys(s5p_domain->flpt_va);
+
+	s5p_domain->refcount = kzalloc(FLPT_ENTRIES * sizeof(u16), GFP_KERNEL);
+	if (!s5p_domain->refcount) {
+		kfree(s5p_domain->flpt_va);
+		return -ENOMEM;
+	}
 
-static inline void sysmmu_block(sysmmu_ips ips)
-{
-	__raw_writel(CTRL_BLOCK, sysmmusfrs[ips] + S5P_MMU_CTRL);
-	dev_dbg(dev, "%s is blocked.\n", sysmmu_ips_name[ips]);
+	s5p_domain->slpt_va = kzalloc(FLPT_ENTRIES * sizeof(void *),
+				      GFP_KERNEL);
+	if (!s5p_domain->slpt_va) {
+		kfree(s5p_domain->refcount);
+		kfree(s5p_domain->flpt_va);
+		return -ENOMEM;
+	}
+	flush_cache(s5p_domain->flpt_va, 4 * PAGE_SIZE);
+	return 0;
 }
 
-static inline void sysmmu_unblock(sysmmu_ips ips)
+static void s5p_sysmmu_domain_destroy(struct iommu_domain *domain)
 {
-	__raw_writel(CTRL_ENABLE, sysmmusfrs[ips] + S5P_MMU_CTRL);
-	dev_dbg(dev, "%s is unblocked.\n", sysmmu_ips_name[ips]);
+	struct s5p_sysmmu_domain *s5p_domain = domain->priv;
+	int i;
+	for (i = FLPT_ENTRIES - 1; i >= 0; --i)
+		if (s5p_domain->refcount[i])
+			kmem_cache_free(slpt_cache, s5p_domain->slpt_va[i]);
+
+	kfree(s5p_domain->slpt_va);
+	kfree(s5p_domain->refcount);
+	kfree(s5p_domain->flpt_va);
+	kfree(domain->priv);
+	domain->priv = NULL;
 }
 
-static inline void __sysmmu_tlb_invalidate(sysmmu_ips ips)
+static void s5p_enable_iommu(struct s5p_sysmmu_info *sysmmu)
 {
-	__raw_writel(0x1, sysmmusfrs[ips] + S5P_MMU_FLUSH);
-	dev_dbg(dev, "TLB of %s is invalidated.\n", sysmmu_ips_name[ips]);
+	struct s5p_sysmmu_domain *s5p_domain = sysmmu->domain;
+	u32 reg;
+	WARN_ON(sysmmu->enabled);
+
+	clk_enable(sysmmu->clk);
+
+	/* configure first level page table base address */
+	writel(s5p_domain->flpt, sysmmu->regs + S5P_PT_BASE_ADDR);
+
+	reg = readl(sysmmu->regs + S5P_MMU_CFG);
+	reg |= (0x1<<0);		/* replacement policy : LRU */
+	writel(reg, sysmmu->regs + S5P_MMU_CFG);
+
+	reg = readl(sysmmu->regs + S5P_MMU_CTRL);
+	reg |= ((0x1<<2)|(0x1<<0));	/* Enable interrupt, Enable MMU */
+	writel(reg, sysmmu->regs + S5P_MMU_CTRL);
+
+	sysmmu->enabled = true;
 }
 
-static inline void __sysmmu_set_ptbase(sysmmu_ips ips, unsigned long pgd)
+static void s5p_disable_iommu(struct s5p_sysmmu_info *sysmmu)
 {
-	if (unlikely(pgd == 0)) {
-		pgd = (unsigned long)ZERO_PAGE(0);
-		__raw_writel(0x20, sysmmusfrs[ips] + S5P_MMU_CFG); /* 4KB LV1 */
-	} else {
-		__raw_writel(0x0, sysmmusfrs[ips] + S5P_MMU_CFG); /* 16KB LV1 */
-	}
+	u32 reg;
+	WARN_ON(!sysmmu->domain);
 
-	__raw_writel(pgd, sysmmusfrs[ips] + S5P_PT_BASE_ADDR);
+	reg = readl(sysmmu->regs + S5P_MMU_CTRL);
+	reg &= ~(0x1);			/* Disable MMU */
+	writel(reg, sysmmu->regs + S5P_MMU_CTRL);
 
-	dev_dbg(dev, "Page table base of %s is initialized with 0x%08lX.\n",
-						sysmmu_ips_name[ips], pgd);
-	__sysmmu_tlb_invalidate(ips);
+	clk_disable(sysmmu->clk);
+	sysmmu->enabled = false;
 }
 
-void sysmmu_set_fault_handler(sysmmu_ips ips,
-			int (*handler)(enum S5P_SYSMMU_INTERRUPT_TYPE itype,
-					unsigned long pgtable_base,
-					unsigned long fault_addr))
+static int s5p_sysmmu_attach_dev(struct iommu_domain *domain,
+				 struct device *dev)
 {
-	BUG_ON(!((ips >= SYSMMU_MDMA) && (ips < S5P_SYSMMU_TOTAL_IPNUM)));
-	fault_handlers[ips] = handler;
+	struct s5p_sysmmu_domain *s5p_domain = domain->priv;
+	struct platform_device *iommu_dev;
+	struct s5p_sysmmu_info *sysmmu;
+
+	iommu_dev = dev->archdata.iommu_priv;
+	BUG_ON(!iommu_dev);
+
+	sysmmu = platform_get_drvdata(iommu_dev);
+	BUG_ON(!sysmmu);
+
+	s5p_domain->sysmmu = sysmmu;
+	sysmmu->domain = s5p_domain;
+
+	return 0;
 }
 
-static irqreturn_t s5p_sysmmu_irq(int irq, void *dev_id)
+static void s5p_sysmmu_detach_dev(struct iommu_domain *domain,
+				  struct device *dev)
 {
-	/* SYSMMU is in blocked when interrupt occurred. */
-	unsigned long base = 0;
-	sysmmu_ips ips = (sysmmu_ips)dev_id;
-	enum S5P_SYSMMU_INTERRUPT_TYPE itype;
+	struct platform_device *pdev =
+		container_of(dev, struct platform_device, dev);
+	struct s5p_sysmmu_info *sysmmu = platform_get_drvdata(pdev);
+	struct s5p_sysmmu_domain *s5p_domain = domain->priv;
+
+	s5p_disable_iommu(sysmmu);
+	s5p_domain->sysmmu = NULL;
+	sysmmu->domain = NULL;
+}
 
-	itype = (enum S5P_SYSMMU_INTERRUPT_TYPE)
-		__ffs(__raw_readl(sysmmusfrs[ips] + S5P_INT_STATUS));
+#define bug_mapping_prohibited(iova, len) \
+		s5p_mapping_prohibited_impl(iova, len, __FILE__, __LINE__)
 
-	BUG_ON(!((itype >= 0) && (itype < 8)));
+static void s5p_mapping_prohibited_impl(unsigned long iova, size_t len,
+				   const char *file, int line)
+{
+	sysmmu_debug(3, "%s:%d Attempting to map %d@0x%lx over existing\
+mapping\n", file, line, len, iova);
+	BUG();
+}
 
-	dev_alert(dev, "%s occurred by %s.\n", sysmmu_fault_name[itype],
-							sysmmu_ips_name[ips]);
+/*
+ * Map an area of length corresponding to gfp_order, starting at iova.
+ * gfp_order is an order of units of 4kB: 0 -> 1 unit, 1 -> 2 units,
+ * 2 -> 4 units, 3 -> 8 units and so on.
+ *
+ * The act of mapping is all about deciding how to interpret in the MMU the
+ * virtual addresses belonging to the mapped range. Mapping can be done with
+ * 4kB, 64kB, 1MB and 16MB pages, so only orders of 0, 4, 8, 12 are valid.
+ *
+ * iova must be aligned on a 4kB, 64kB, 1MB and 16MB boundaries, respectively.
+ */
+static int s5p_sysmmu_map(struct iommu_domain *domain, unsigned long iova,
+			  phys_addr_t paddr, int gfp_order, int prot)
+{
+	struct s5p_sysmmu_domain *s5p_domain = domain->priv;
+	int flpt_idx = flpt_index(iova);
+	size_t len = 0x1000UL << gfp_order;
+	void *flpt_va, *slpt_va;
+
+	if (len != SZ_16M && len != SZ_1M && len != SZ_64K && len != SZ_4K) {
+		sysmmu_debug(3, "bad order: %d\n", gfp_order);
+		return -EINVAL;
+	}
 
-	if (fault_handlers[ips]) {
-		unsigned long addr;
+	flpt_va = s5p_domain->flpt_va + flpt_offs(iova);
+
+	if (SZ_1M == len) {
+		if (deref_va(flpt_va))
+			bug_mapping_prohibited(iova, len);
+		deref_va(flpt_va) = flpt_ent_1m(paddr);
+		flush_cache(flpt_va, 4); /* one 4-byte entry */
+
+		return 0;
+	} else if (SZ_16M == len) {
+		int i = 0;
+		/* first loop to verify mapping allowed */
+		for (i = 0; i < 16; ++i)
+			if (deref_va(flpt_va + 4 * i))
+				bug_mapping_prohibited(iova, len);
+		/* actually map only if allowed */
+		for (i = 0; i < 16; ++i)
+			deref_va(flpt_va + 4 * i) = flpt_ent_16m(paddr);
+		flush_cache(flpt_va, 4 * 16); /* 16 4-byte entries */
+
+		return 0;
+	}
 
-		base = __raw_readl(sysmmusfrs[ips] + S5P_PT_BASE_ADDR);
-		addr = __raw_readl(sysmmusfrs[ips] + fault_reg_offset[itype]);
+	/* for 4K and 64K pages only */
+	if (page_1m(flpt_va) || page_16m(flpt_va))
+		bug_mapping_prohibited(iova, len);
 
-		if (fault_handlers[ips](itype, base, addr)) {
-			__raw_writel(1 << itype,
-					sysmmusfrs[ips] + S5P_INT_CLEAR);
-			dev_notice(dev, "%s from %s is resolved."
-					" Retrying translation.\n",
-				sysmmu_fault_name[itype], sysmmu_ips_name[ips]);
-		} else {
-			base = 0;
+	/* need to allocate a new second level page table */
+	if (0 == deref_va(flpt_va)) {
+		void *slpt = kmem_cache_zalloc(slpt_cache, GFP_KERNEL);
+		if (!slpt) {
+			sysmmu_debug(3, "cannot allocate slpt\n");
+			return -ENOMEM;
+		}
+
+		s5p_domain->slpt_va[flpt_idx] = slpt;
+		deref_va(flpt_va) = flpt_ent_4k_64k(virt_to_phys(slpt));
+		flush_cache(flpt_va, 4);
+	}
+	slpt_va = s5p_domain->slpt_va[flpt_idx] + slpt_offs(iova);
+
+	if (SZ_4K == len) {
+		if (deref_va(slpt_va))
+			bug_mapping_prohibited(iova, len);
+		deref_va(slpt_va) = slpt_ent_4k(paddr);
+		flush_cache(slpt_va, 4); /* one 4-byte entry */
+		s5p_domain->refcount[flpt_idx]++;
+	} else {
+		int i;
+		/* first loop to verify mapping allowed */
+		for (i = 0; i < 16; ++i)
+			if (deref_va(slpt_va + 4 * i))
+				bug_mapping_prohibited(iova, len);
+		/* actually map only if allowed */
+		for (i = 0; i < 16; ++i) {
+			deref_va(slpt_va + 4 * i) = slpt_ent_64k(paddr);
+			s5p_domain->refcount[flpt_idx]++;
 		}
+		flush_cache(slpt_va, 4 * 16); /* 16 4-byte entries */
 	}
 
-	sysmmu_unblock(ips);
+	return 0;
+}
 
-	if (!base)
-		dev_notice(dev, "%s from %s is not handled.\n",
-			sysmmu_fault_name[itype], sysmmu_ips_name[ips]);
+static void s5p_tlb_invalidate(struct s5p_sysmmu_domain *domain)
+{
+	unsigned int reg;
+	void __iomem *regs;
 
-	return IRQ_HANDLED;
+	if (!domain->sysmmu)
+		return;
+
+	if (!domain->sysmmu->enabled)
+		return;
+
+	regs = domain->sysmmu->regs;
+
+	/* TLB invalidate */
+	reg = readl(regs + S5P_MMU_CTRL);
+	reg |= (0x1<<1);		/* Block MMU */
+	writel(reg, regs + S5P_MMU_CTRL);
+
+	writel(0x1, regs + S5P_MMU_FLUSH);
+					/* Flush_entry */
+
+	reg = readl(regs + S5P_MMU_CTRL);
+	reg &= ~(0x1<<1);		/* Un-block MMU */
+	writel(reg, regs + S5P_MMU_CTRL);
 }
 
-void s5p_sysmmu_set_tablebase_pgd(sysmmu_ips ips, unsigned long pgd)
+#define bug_unmapping_prohibited(iova, len) \
+		s5p_unmapping_prohibited_impl(iova, len, __FILE__, __LINE__)
+
+static void s5p_unmapping_prohibited_impl(unsigned long iova, size_t len,
+				     const char *file, int line)
 {
-	if (is_sysmmu_active(ips)) {
-		sysmmu_block(ips);
-		__sysmmu_set_ptbase(ips, pgd);
-		sysmmu_unblock(ips);
-	} else {
-		dev_dbg(dev, "%s is disabled. "
-			"Skipping initializing page table base.\n",
-						sysmmu_ips_name[ips]);
-	}
+	sysmmu_debug(3, "%s:%d Attempting to unmap different size or \
+non-existing mapping %d@0x%lx\n", file, line, len, iova);
+	BUG();
 }
 
-void s5p_sysmmu_enable(sysmmu_ips ips, unsigned long pgd)
+static int s5p_sysmmu_unmap(struct iommu_domain *domain, unsigned long iova,
+			    int gfp_order)
 {
-	if (!is_sysmmu_active(ips)) {
-		sysmmu_clk_enable(ips);
+	struct s5p_sysmmu_domain *s5p_domain = domain->priv;
+	int flpt_idx = flpt_index(iova);
+	size_t len = 0x1000UL << gfp_order;
+	void *flpt_va, *slpt_va;
+
+	if (len != SZ_16M && len != SZ_1M && len != SZ_64K && len != SZ_4K) {
+		sysmmu_debug(3, "bad order: %d\n", gfp_order);
+		return -EINVAL;
+	}
+
+	flpt_va = s5p_domain->flpt_va + flpt_offs(iova);
+
+	/* check if there is any mapping at all */
+	if (!deref_va(flpt_va))
+		bug_unmapping_prohibited(iova, len);
+
+	if (SZ_1M == len) {
+		if (!page_1m(flpt_va))
+			bug_unmapping_prohibited(iova, len);
+		deref_va(flpt_va) = 0;
+		flush_cache(flpt_va, 4); /* one 4-byte entry */
+		s5p_tlb_invalidate(s5p_domain);
+
+		return 0;
+	} else if (SZ_16M == len) {
+		int i;
+		/* first loop to verify it actually is 16M mapping */
+		for (i = 0; i < 16; ++i)
+			if (!page_16m(flpt_va + 4 * i))
+				bug_unmapping_prohibited(iova, len);
+		/* actually unmap */
+		for (i = 0; i < 16; ++i)
+			deref_va(flpt_va + 4 * i) = 0;
+		flush_cache(flpt_va, 4 * 16); /* 16 4-byte entries */
+		s5p_tlb_invalidate(s5p_domain);
+
+		return 0;
+	}
 
-		__sysmmu_set_ptbase(ips, pgd);
+	if (!page_4k_64k(flpt_va))
+		bug_unmapping_prohibited(iova, len);
 
-		__raw_writel(CTRL_ENABLE, sysmmusfrs[ips] + S5P_MMU_CTRL);
+	slpt_va = s5p_domain->slpt_va[flpt_idx] + slpt_offs(iova);
 
-		set_sysmmu_active(ips);
-		dev_dbg(dev, "%s is enabled.\n", sysmmu_ips_name[ips]);
+	/* verify that we attempt to unmap a matching mapping */
+	if (SZ_4K == len) {
+		if (!page_4k(slpt_va))
+			bug_unmapping_prohibited(iova, len);
+	} else if (SZ_64K == len) {
+		int i;
+		for (i = 0; i < 16; ++i)
+			if (!page_64k(slpt_va + 4 * i))
+				bug_unmapping_prohibited(iova, len);
+	}
+
+	if (SZ_64K == len)
+		s5p_domain->refcount[flpt_idx] -= 15;
+
+	if (--s5p_domain->refcount[flpt_idx]) {
+		if (SZ_4K == len) {
+			invalidate_slpt_ent(slpt_va);
+			flush_cache(slpt_va, 4);
+		} else {
+			int i;
+			for (i = 0; i < 16; ++i)
+				invalidate_slpt_ent(slpt_va + 4 * i);
+			flush_cache(slpt_va, 4 * 16);
+		}
 	} else {
-		dev_dbg(dev, "%s is already enabled.\n", sysmmu_ips_name[ips]);
+		kmem_cache_free(slpt_cache, s5p_domain->slpt_va[flpt_idx]);
+		s5p_domain->slpt_va[flpt_idx] = 0;
+		memset(flpt_va, 0, 4);
+		flush_cache(flpt_va, 4);
 	}
+
+	s5p_tlb_invalidate(s5p_domain);
+
+	return 0;
 }
 
-void s5p_sysmmu_disable(sysmmu_ips ips)
+phys_addr_t s5p_iova_to_phys(struct iommu_domain *domain, unsigned long iova)
 {
-	if (is_sysmmu_active(ips)) {
-		__raw_writel(CTRL_DISABLE, sysmmusfrs[ips] + S5P_MMU_CTRL);
-		set_sysmmu_inactive(ips);
-		sysmmu_clk_disable(ips);
-		dev_dbg(dev, "%s is disabled.\n", sysmmu_ips_name[ips]);
-	} else {
-		dev_dbg(dev, "%s is already disabled.\n", sysmmu_ips_name[ips]);
-	}
+	struct s5p_sysmmu_domain *s5p_domain = domain->priv;
+	int flpt_idx = flpt_index(iova);
+	unsigned long flpt_va, slpt_va;
+
+	flpt_va = (unsigned long)s5p_domain->flpt_va + flpt_offs(iova);
+
+	if (!deref_va(flpt_va))
+		return 0;
+
+	if (page_16m(flpt_va))
+		return flpt_get_16m(flpt_va) | pg_offs_16m(iova);
+	else if (page_1m(flpt_va))
+		return flpt_get_1m(flpt_va) | pg_offs_1m(iova);
+
+	if (!page_4k_64k(flpt_va))
+		return 0;
+
+	slpt_va = (unsigned long)s5p_domain->slpt_va[flpt_idx] +
+		  slpt_offs(iova);
+
+	if (!deref_va(slpt_va))
+		return 0;
+
+	if (page_4k(slpt_va))
+		return slpt_get_4k(slpt_va) | pg_offs_4k(iova);
+	else if (page_64k(slpt_va))
+		return slpt_get_64k(slpt_va) | pg_offs_64k(iova);
+
+	return 0;
 }
 
-void s5p_sysmmu_tlb_invalidate(sysmmu_ips ips)
+static struct iommu_ops s5p_sysmmu_ops = {
+	.domain_init = s5p_sysmmu_domain_init,
+	.domain_destroy = s5p_sysmmu_domain_destroy,
+	.attach_dev = s5p_sysmmu_attach_dev,
+	.detach_dev = s5p_sysmmu_detach_dev,
+	.map = s5p_sysmmu_map,
+	.unmap = s5p_sysmmu_unmap,
+	.iova_to_phys = s5p_iova_to_phys,
+};
+
+static irqreturn_t s5p_sysmmu_irq(int irq, void *dev_id)
 {
-	if (is_sysmmu_active(ips)) {
-		sysmmu_block(ips);
-		__sysmmu_tlb_invalidate(ips);
-		sysmmu_unblock(ips);
-	} else {
-		dev_dbg(dev, "%s is disabled. "
-			"Skipping invalidating TLB.\n", sysmmu_ips_name[ips]);
+	struct s5p_sysmmu_info *sysmmu = dev_id;
+	unsigned int reg_INT_STATUS;
+	unsigned long fault;
+
+	if (false == sysmmu->enabled)
+		return IRQ_HANDLED;
+
+	reg_INT_STATUS = readl(sysmmu->regs + S5P_INT_STATUS);
+	if (reg_INT_STATUS & 0xFF) {
+		switch (reg_INT_STATUS & 0xFF) {
+		case 0x1:
+			/* page fault */
+			fault = readl(sysmmu->regs + S5P_PAGE_FAULT_ADDR);
+			sysmmu_debug(3, "Faulting virtual address: 0x%08lx\n",
+				     fault);
+			break;
+		case 0x2:
+			/* AR multi-hit fault */
+			sysmmu_debug(3, "irq:ar multi hit\n");
+			break;
+		case 0x4:
+			/* AW multi-hit fault */
+			sysmmu_debug(3, "irq:aw multi hit\n");
+			break;
+		case 0x8:
+			/* bus error */
+			sysmmu_debug(3, "irq:bus error\n");
+			break;
+		case 0x10:
+			/* AR security protection fault */
+			sysmmu_debug(3, "irq:ar security protection fault\n");
+			break;
+		case 0x20:
+			/* AR access protection fault */
+			sysmmu_debug(3, "irq:ar access protection fault\n");
+			break;
+		case 0x40:
+			/* AW security protection fault */
+			sysmmu_debug(3, "irq:aw security protection fault\n");
+			break;
+		case 0x80:
+			/* AW access protection fault */
+			sysmmu_debug(3, "irq:aw access protection fault\n");
+			break;
+		}
+		writel(reg_INT_STATUS, sysmmu->regs + S5P_INT_CLEAR);
 	}
+	return IRQ_HANDLED;
 }
 
 static int s5p_sysmmu_probe(struct platform_device *pdev)
 {
-	int i, ret;
-	struct resource *res, *mem;
+	struct s5p_sysmmu_info *sysmmu;
+	struct resource *res;
+	int ret;
+	unsigned long flags;
+
+	sysmmu = kzalloc(sizeof(struct s5p_sysmmu_info), GFP_KERNEL);
+	if (!sysmmu) {
+		dev_err(&pdev->dev, "no memory for state\n");
+		return -ENOMEM;
+	}
 
-	dev = &pdev->dev;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (NULL == res) {
+		dev_err(&pdev->dev, "cannot find IO resource\n");
+		ret = -ENOENT;
+		goto err_s5p_sysmmu_info_allocated;
+	}
 
-	for (i = 0; i < S5P_SYSMMU_TOTAL_IPNUM; i++) {
-		int irq;
+	sysmmu->ioarea = request_mem_region(res->start, resource_size(res),
+					 pdev->name);
 
-		sysmmu_clk_init(dev, i);
-		sysmmu_clk_disable(i);
+	if (NULL == sysmmu->ioarea) {
+		dev_err(&pdev->dev, "cannot request IO\n");
+		ret = -ENXIO;
+		goto err_s5p_sysmmu_info_allocated;
+	}
 
-		res = platform_get_resource(pdev, IORESOURCE_MEM, i);
-		if (!res) {
-			dev_err(dev, "Failed to get the resource of %s.\n",
-							sysmmu_ips_name[i]);
-			ret = -ENODEV;
-			goto err_res;
-		}
+	sysmmu->regs = ioremap(res->start, resource_size(res));
 
-		mem = request_mem_region(res->start, resource_size(res),
-					 pdev->name);
-		if (!mem) {
-			dev_err(dev, "Failed to request the memory region of %s.\n",
-							sysmmu_ips_name[i]);
-			ret = -EBUSY;
-			goto err_res;
-		}
+	if (NULL == sysmmu->regs) {
+		dev_err(&pdev->dev, "cannot map IO\n");
+		ret = -ENXIO;
+		goto err_ioarea_requested;
+	}
 
-		sysmmusfrs[i] = ioremap(res->start, resource_size(res));
-		if (!sysmmusfrs[i]) {
-			dev_err(dev, "Failed to ioremap() for %s.\n",
-							sysmmu_ips_name[i]);
-			ret = -ENXIO;
-			goto err_reg;
-		}
+	dev_dbg(&pdev->dev, "registers %p (%p, %p)\n",
+		sysmmu->regs, sysmmu->ioarea, res);
 
-		irq = platform_get_irq(pdev, i);
-		if (irq <= 0) {
-			dev_err(dev, "Failed to get the IRQ resource of %s.\n",
-							sysmmu_ips_name[i]);
-			ret = -ENOENT;
-			goto err_map;
-		}
+	sysmmu->irq = ret = platform_get_irq(pdev, 0);
+	if (ret <= 0) {
+		dev_err(&pdev->dev, "cannot find IRQ\n");
+		goto err_iomap_done;
+	}
 
-		if (request_irq(irq, s5p_sysmmu_irq, IRQF_DISABLED,
-						pdev->name, (void *)i)) {
-			dev_err(dev, "Failed to request IRQ for %s.\n",
-							sysmmu_ips_name[i]);
-			ret = -ENOENT;
-			goto err_map;
-		}
+	ret = request_irq(sysmmu->irq, s5p_sysmmu_irq, 0,
+			  dev_name(&pdev->dev), sysmmu);
+
+	if (ret != 0) {
+		dev_err(&pdev->dev, "cannot claim IRQ %d\n", sysmmu->irq);
+		goto err_iomap_done;
 	}
 
+	sysmmu->clk = clk_get(&pdev->dev, "sysmmu");
+	if (IS_ERR_OR_NULL(sysmmu->clk)) {
+		dev_err(&pdev->dev, "cannot get clock\n");
+		ret = -ENOENT;
+		goto err_request_irq_done;
+	}
+	dev_dbg(&pdev->dev, "clock source %p\n", sysmmu->clk);
+	sysmmu->ip = pdev->id;
+
+	spin_lock_irqsave(&sysmmu_slock, flags);
+	sysmmu_table[pdev->id] = sysmmu;
+	spin_unlock_irqrestore(&sysmmu_slock, flags);
+
+	sysmmu->dev = &pdev->dev;
+
+	platform_set_drvdata(pdev, sysmmu);
+
+	pm_runtime_set_active(&pdev->dev);
+	pm_runtime_enable(&pdev->dev);
+
+	dev_info(&pdev->dev, "Samsung S5P SYSMMU (IOMMU)\n");
 	return 0;
 
-err_map:
-	iounmap(sysmmusfrs[i]);
-err_reg:
-	release_mem_region(mem->start, resource_size(mem));
-err_res:
+err_request_irq_done:
+	free_irq(sysmmu->irq, sysmmu);
+
+err_iomap_done:
+	iounmap(sysmmu->regs);
+
+err_ioarea_requested:
+	release_resource(sysmmu->ioarea);
+	kfree(sysmmu->ioarea);
+
+err_s5p_sysmmu_info_allocated:
+	kfree(sysmmu);
 	return ret;
 }
 
 static int s5p_sysmmu_remove(struct platform_device *pdev)
 {
+	struct s5p_sysmmu_info *sysmmu = platform_get_drvdata(pdev);
+	unsigned long flags;
+
+	pm_runtime_disable(sysmmu->dev);
+
+	spin_lock_irqsave(&sysmmu_slock, flags);
+	sysmmu_table[pdev->id] = NULL;
+	spin_unlock_irqrestore(&sysmmu_slock, flags);
+
+	clk_put(sysmmu->clk);
+
+	free_irq(sysmmu->irq, sysmmu);
+
+	iounmap(sysmmu->regs);
+
+	release_resource(sysmmu->ioarea);
+	kfree(sysmmu->ioarea);
+
+	kfree(sysmmu);
+
 	return 0;
 }
-int s5p_sysmmu_runtime_suspend(struct device *dev)
+
+static int s5p_sysmmu_runtime_suspend(struct device *dev)
 {
+	struct platform_device *pdev = to_platform_device(dev);
+	struct s5p_sysmmu_info *sysmmu = platform_get_drvdata(pdev);
+
+	if (sysmmu->domain)
+		s5p_disable_iommu(sysmmu);
+
 	return 0;
 }
 
-int s5p_sysmmu_runtime_resume(struct device *dev)
+static int s5p_sysmmu_runtime_resume(struct device *dev)
 {
+	struct platform_device *pdev = to_platform_device(dev);
+	struct s5p_sysmmu_info *sysmmu = platform_get_drvdata(pdev);
+
+	if (sysmmu->domain)
+		s5p_enable_iommu(sysmmu);
+
 	return 0;
 }
 
-const struct dev_pm_ops s5p_sysmmu_pm_ops = {
-	.runtime_suspend	= s5p_sysmmu_runtime_suspend,
-	.runtime_resume		= s5p_sysmmu_runtime_resume,
+static const struct dev_pm_ops s5p_sysmmu_pm_ops = {
+	.runtime_suspend = s5p_sysmmu_runtime_suspend,
+	.runtime_resume	 = s5p_sysmmu_runtime_resume,
 };
 
 static struct platform_driver s5p_sysmmu_driver = {
-	.probe		= s5p_sysmmu_probe,
-	.remove		= s5p_sysmmu_remove,
-	.driver		= {
-		.owner		= THIS_MODULE,
-		.name		= "s5p-sysmmu",
-		.pm		= &s5p_sysmmu_pm_ops,
-	}
+	.probe = s5p_sysmmu_probe,
+	.remove = s5p_sysmmu_remove,
+	.driver = {
+		.owner = THIS_MODULE,
+		.name = "s5p-sysmmu",
+		.pm = &s5p_sysmmu_pm_ops,
+	},
 };
 
-static int __init s5p_sysmmu_init(void)
+static int __init s5p_sysmmu_register(void)
 {
-	return platform_driver_register(&s5p_sysmmu_driver);
+	int ret;
+
+	sysmmu_debug(3, "Registering sysmmu driver...\n");
+
+	slpt_cache = kmem_cache_create("slpt_cache", 1024, 1024,
+				       SLAB_HWCACHE_ALIGN, NULL);
+	if (!slpt_cache) {
+		printk(KERN_ERR
+			"%s: failed to allocated slpt cache\n", __func__);
+		return -ENOMEM;
+	}
+
+	ret = platform_driver_register(&s5p_sysmmu_driver);
+
+	if (ret) {
+		printk(KERN_ERR
+			"%s: failed to register sysmmu driver\n", __func__);
+		return -EINVAL;
+	}
+
+	register_iommu(&s5p_sysmmu_ops);
+
+	return ret;
 }
-arch_initcall(s5p_sysmmu_init);
+postcore_initcall(s5p_sysmmu_register);
+
+MODULE_AUTHOR("Andrzej Pietrasiewicz <andrzej.p@samsung.com>");
+MODULE_DESCRIPTION("Samsung System MMU (IOMMU) driver");
+MODULE_LICENSE("GPL");
diff --git a/arch/arm/plat-samsung/include/plat/devs.h b/arch/arm/plat-samsung/include/plat/devs.h
index 24ebb1e..4506902 100644
--- a/arch/arm/plat-samsung/include/plat/devs.h
+++ b/arch/arm/plat-samsung/include/plat/devs.h
@@ -147,7 +147,6 @@ extern struct platform_device s5p_device_mipi_csis1;
 
 extern struct platform_device s5p_device_ehci;
 
-extern struct platform_device exynos4_device_sysmmu;
 
 /* s3c2440 specific devices */
 
diff --git a/arch/arm/plat-samsung/include/plat/fimc-core.h b/arch/arm/plat-samsung/include/plat/fimc-core.h
index 945a99d..a5dfb82 100644
--- a/arch/arm/plat-samsung/include/plat/fimc-core.h
+++ b/arch/arm/plat-samsung/include/plat/fimc-core.h
@@ -46,4 +46,29 @@ static inline void s3c_fimc_setname(int id, char *name)
 	}
 }
 
+static inline struct device *s3c_fimc_getdevice(int id)
+{
+	switch (id) {
+#ifdef CONFIG_S5P_DEV_FIMC0
+	case 0:
+		return &s5p_device_fimc0.dev;
+#endif
+#ifdef CONFIG_S5P_DEV_FIMC1
+	case 1:
+		return &s5p_device_fimc1.dev;
+#endif
+#ifdef CONFIG_S5P_DEV_FIMC2
+	case 2:
+		return &s5p_device_fimc2.dev;
+#endif
+#ifdef CONFIG_S5P_DEV_FIMC3
+	case 3:
+		return &s5p_device_fimc3.dev;
+#endif
+	}
+	return NULL;
+}
+
+#define S5P_MAX_FIMC_NUM	(4)
+
 #endif /* __ASM_PLAT_FIMC_CORE_H */
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
