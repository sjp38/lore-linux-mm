Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7720C6B02FE
	for <linux-mm@kvack.org>; Tue,  8 May 2018 20:42:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z5so13729027pfz.6
        for <linux-mm@kvack.org>; Tue, 08 May 2018 17:42:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor5114620pfo.145.2018.05.08.17.42.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 17:42:55 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 12/13] treewide: Use array_size() for devm_*alloc()-like
Date: Tue,  8 May 2018 17:42:28 -0700
Message-Id: <20180509004229.36341-13-keescook@chromium.org>
In-Reply-To: <20180509004229.36341-1-keescook@chromium.org>
References: <20180509004229.36341-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

As done for kmalloc()-family, this handles 2 and 3 factor products in
devm_*alloc(), sock_*alloc(), and f2fs_*alloc(), with the following
Coccinelle script:

// 2-factor product with sizeof(variable)
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP, THING;
identifier COUNT;
@@

- alloc(HANDLE, sizeof(THING) * COUNT, GFP)
+ alloc(HANDLE, array_size(COUNT, sizeof(THING)), GFP)

// 2-factor product with sizeof(type)
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP;
identifier COUNT;
type TYPE;
@@

- alloc(HANDLE, sizeof(TYPE) * COUNT, GFP)
+ alloc(HANDLE, array_size(COUNT, sizeof(TYPE)), GFP)

// 2-factor product with sizeof(variable) and constant
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP, THING;
constant COUNT;
@@

- alloc(HANDLE, sizeof(THING) * COUNT, GFP)
+ alloc(HANDLE, array_size(COUNT, sizeof(THING)), GFP)

// 2-factor product with sizeof(type) and constant
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP;
constant COUNT;
type TYPE;
@@

- alloc(HANDLE, sizeof(TYPE) * COUNT, GFP)
+ alloc(HANDLE, array_size(COUNT, sizeof(TYPE)), GFP)

// 3-factor product with 1 sizeof(variable)
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP, THING;
identifier STRIDE, COUNT;
@@

- alloc(HANDLE, sizeof(THING) * COUNT * STRIDE, GFP)
+ alloc(HANDLE, array3_size(COUNT, STRIDE, sizeof(THING)), GFP)

// 3-factor product with 2 sizeof(variable)
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP, THING1, THING2;
identifier COUNT;
@@

- alloc(HANDLE, sizeof(THING1) * sizeof(THING2) * COUNT, GFP)
+ alloc(HANDLE, array3_size(COUNT, sizeof(THING1), sizeof(THING2)), GFP)

// 3-factor product with 1 sizeof(type)
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP;
identifier STRIDE, COUNT;
type TYPE;
@@

- alloc(HANDLE, sizeof(TYPE) * COUNT * STRIDE, GFP)
+ alloc(HANDLE, array3_size(COUNT, STRIDE, sizeof(TYPE)), GFP)

// 3-factor product with 2 sizeof(type)
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP;
identifier COUNT;
type TYPE1, TYPE2;
@@

- alloc(HANDLE, sizeof(TYPE1) * sizeof(TYPE2) * COUNT, GFP)
+ alloc(HANDLE, array3_size(COUNT, sizeof(TYPE1), sizeof(TYPE2)), GFP)

// 3-factor product with mixed sizeof() type/variable
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP, THING;
identifier COUNT;
type TYPE;
@@

- alloc(HANDLE, sizeof(TYPE) * sizeof(THING) * COUNT, GFP)
+ alloc(HANDLE, array3_size(COUNT, sizeof(TYPE), sizeof(THING)), GFP)

// 2-factor product, only identifiers
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP;
identifier SIZE, COUNT;
@@

- alloc(HANDLE, SIZE * COUNT, GFP)
+ alloc(HANDLE, array_size(COUNT, SIZE), GFP)

// 3-factor product, only identifiers
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP;
identifier STRIDE, SIZE, COUNT;
@@

- alloc(HANDLE, COUNT * STRIDE * SIZE, GFP)
+ alloc(HANDLE, array3_size(COUNT, STRIDE, SIZE), GFP)

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/ata/sata_mv.c                         |  4 +--
 drivers/bus/fsl-mc/fsl-mc-allocator.c         |  5 ++--
 drivers/clk/bcm/clk-bcm2835.c                 |  6 ++--
 drivers/clk/ti/adpll.c                        |  8 +++---
 drivers/cpufreq/imx6q-cpufreq.c               |  4 ++-
 drivers/devfreq/event/exynos-ppmu.c           |  2 +-
 drivers/dma/mv_xor_v2.c                       |  5 ++--
 drivers/firmware/arm_scpi.c                   |  3 +-
 drivers/gpio/gpio-davinci.c                   |  2 +-
 drivers/gpio/gpio-thunderx.c                  |  6 ++--
 drivers/gpu/drm/exynos/exynos_hdmi.c          |  2 +-
 drivers/hid/hid-sensor-hub.c                  |  4 +--
 drivers/hid/wacom_sys.c                       |  6 ++--
 drivers/hwmon/aspeed-pwm-tacho.c              |  3 +-
 drivers/hwmon/nct6683.c                       |  2 +-
 drivers/hwmon/nct6775.c                       |  4 +--
 drivers/hwmon/pmbus/ucd9000.c                 |  2 +-
 drivers/hwmon/pwm-fan.c                       |  3 +-
 drivers/i2c/busses/i2c-qup.c                  |  4 +--
 drivers/iio/multiplexer/iio-mux.c             |  4 +--
 drivers/input/keyboard/samsung-keypad.c       |  3 +-
 drivers/input/matrix-keymap.c                 |  2 +-
 drivers/input/rmi4/rmi_f54.c                  |  2 +-
 drivers/iommu/arm-smmu.c                      |  3 +-
 drivers/iommu/rockchip-iommu.c                |  3 +-
 drivers/leds/leds-lp55xx-common.c             |  3 +-
 drivers/leds/leds-netxbig.c                   | 14 ++++++----
 drivers/leds/leds-ns2.c                       |  4 +--
 drivers/leds/leds-tca6507.c                   |  3 +-
 drivers/mailbox/mailbox-sti.c                 |  3 +-
 drivers/mailbox/omap-mailbox.c                |  9 ++++--
 drivers/mailbox/ti-msgmgr.c                   |  6 ++--
 drivers/media/i2c/s5k5baf.c                   |  2 +-
 drivers/media/platform/davinci/vpif_capture.c |  8 +++---
 drivers/media/platform/vsp1/vsp1_entity.c     |  3 +-
 drivers/media/platform/xilinx/xilinx-vipp.c   |  3 +-
 drivers/memory/of_memory.c                    |  5 ++--
 drivers/mfd/ab8500-debugfs.c                  |  9 ++++--
 drivers/mfd/twl-core.c                        |  4 +--
 drivers/misc/sram.c                           |  4 +--
 drivers/mtd/devices/docg3.c                   |  3 +-
 drivers/mtd/nand/raw/qcom_nandc.c             |  4 +--
 drivers/net/ethernet/amazon/ena/ena_ethtool.c |  4 +--
 drivers/net/ethernet/ethoc.c                  |  4 ++-
 .../net/ethernet/freescale/dpaa/dpaa_eth.c    |  2 +-
 drivers/net/ethernet/ni/nixge.c               |  3 +-
 drivers/net/wireless/mediatek/mt76/mac80211.c |  3 +-
 drivers/nfc/fdp/i2c.c                         |  2 +-
 drivers/pci/dwc/pci-dra7xx.c                  |  6 ++--
 drivers/pinctrl/berlin/berlin.c               |  2 +-
 drivers/pinctrl/freescale/pinctrl-imx1-core.c |  6 ++--
 drivers/pinctrl/mvebu/pinctrl-armada-xp.c     |  3 +-
 drivers/pinctrl/mvebu/pinctrl-mvebu.c         |  5 ++--
 drivers/pinctrl/pinctrl-at91.c                |  8 ++++--
 drivers/pinctrl/pinctrl-axp209.c              |  5 ++--
 drivers/pinctrl/pinctrl-digicolor.c           |  5 ++--
 drivers/pinctrl/pinctrl-lpc18xx.c             |  5 ++--
 drivers/pinctrl/pinctrl-ocelot.c              |  6 ++--
 drivers/pinctrl/pinctrl-rockchip.c            |  5 ++--
 drivers/pinctrl/pinctrl-single.c              | 28 +++++++++++--------
 drivers/pinctrl/pinctrl-st.c                  |  9 ++++--
 drivers/pinctrl/samsung/pinctrl-exynos5440.c  | 16 +++++++----
 drivers/pinctrl/samsung/pinctrl-samsung.c     |  8 ++++--
 drivers/pinctrl/sh-pfc/core.c                 |  9 ++++--
 drivers/pinctrl/sh-pfc/gpio.c                 |  3 +-
 drivers/pinctrl/ti/pinctrl-ti-iodelay.c       |  9 ++++--
 drivers/pinctrl/zte/pinctrl-zx.c              |  3 +-
 drivers/platform/mellanox/mlxreg-hotplug.c    |  4 +--
 drivers/pwm/pwm-lp3943.c                      |  3 +-
 drivers/regulator/act8865-regulator.c         |  4 +--
 drivers/regulator/as3711-regulator.c          |  5 ++--
 drivers/regulator/bcm590xx-regulator.c        |  5 ++--
 drivers/regulator/da9063-regulator.c          |  4 +--
 drivers/regulator/max1586.c                   |  5 ++--
 drivers/regulator/max8660.c                   |  5 ++--
 drivers/regulator/pbias-regulator.c           |  5 ++--
 drivers/regulator/rc5t583-regulator.c         |  5 ++--
 drivers/regulator/s2mps11.c                   |  4 +--
 drivers/regulator/ti-abb-regulator.c          |  6 ++--
 drivers/regulator/tps65090-regulator.c        | 10 ++++---
 drivers/regulator/tps65217-regulator.c        |  5 ++--
 drivers/regulator/tps65218-regulator.c        |  5 ++--
 drivers/regulator/tps80031-regulator.c        |  3 +-
 drivers/reset/reset-ti-syscon.c               |  4 ++-
 drivers/scsi/isci/init.c                      |  4 +--
 drivers/scsi/ufs/ufshcd-pltfrm.c              |  4 +--
 drivers/soc/bcm/raspberrypi-power.c           |  5 ++--
 drivers/soc/mediatek/mtk-scpsys.c             |  6 ++--
 drivers/soc/ti/knav_qmss_acc.c                |  6 ++--
 drivers/spi/spi-pl022.c                       |  3 +-
 drivers/staging/greybus/audio_topology.c      |  3 +-
 drivers/staging/media/imx/imx-media-dev.c     |  3 +-
 drivers/thermal/thermal-generic-adc.c         |  5 ++--
 drivers/video/backlight/lp855x_bl.c           |  3 +-
 drivers/video/fbdev/au1100fb.c                |  3 +-
 drivers/video/fbdev/mxsfb.c                   |  3 +-
 drivers/video/fbdev/omap2/omapfb/vrfb.c       |  4 +--
 fs/f2fs/checkpoint.c                          |  3 +-
 fs/f2fs/segment.c                             |  3 +-
 fs/f2fs/super.c                               | 14 ++++++----
 sound/soc/au1x/dbdma2.c                       |  2 +-
 sound/soc/codecs/hdmi-codec.c                 |  3 +-
 sound/soc/codecs/rt5645.c                     |  3 +-
 sound/soc/generic/audio-graph-card.c          |  6 ++--
 sound/soc/generic/audio-graph-scu-card.c      |  6 ++--
 sound/soc/generic/simple-card.c               |  9 ++++--
 sound/soc/generic/simple-scu-card.c           |  6 ++--
 sound/soc/intel/skylake/skl-topology.c        | 10 ++++---
 sound/soc/pxa/mmp-sspa.c                      |  4 +--
 sound/soc/rockchip/rk3399_gru_sound.c         |  2 +-
 sound/soc/sh/rcar/cmd.c                       |  2 +-
 sound/soc/sh/rcar/core.c                      |  4 +--
 sound/soc/sh/rcar/ctu.c                       |  2 +-
 sound/soc/sh/rcar/dvc.c                       |  3 +-
 sound/soc/sh/rcar/mix.c                       |  3 +-
 sound/soc/sh/rcar/src.c                       |  3 +-
 sound/soc/sh/rcar/ssi.c                       |  3 +-
 sound/soc/sh/rcar/ssiu.c                      |  3 +-
 sound/soc/soc-core.c                          |  5 ++--
 119 files changed, 347 insertions(+), 224 deletions(-)

diff --git a/drivers/ata/sata_mv.c b/drivers/ata/sata_mv.c
index 42d4589b43d4..37b87985659c 100644
--- a/drivers/ata/sata_mv.c
+++ b/drivers/ata/sata_mv.c
@@ -4115,12 +4115,12 @@ static int mv_platform_probe(struct platform_device *pdev)
 	if (!host || !hpriv)
 		return -ENOMEM;
 	hpriv->port_clks = devm_kzalloc(&pdev->dev,
-					sizeof(struct clk *) * n_ports,
+					array_size(n_ports, sizeof(struct clk *)),
 					GFP_KERNEL);
 	if (!hpriv->port_clks)
 		return -ENOMEM;
 	hpriv->port_phys = devm_kzalloc(&pdev->dev,
-					sizeof(struct phy *) * n_ports,
+					array_size(n_ports, sizeof(struct phy *)),
 					GFP_KERNEL);
 	if (!hpriv->port_phys)
 		return -ENOMEM;
diff --git a/drivers/bus/fsl-mc/fsl-mc-allocator.c b/drivers/bus/fsl-mc/fsl-mc-allocator.c
index fb1442b08962..1f569d3ff200 100644
--- a/drivers/bus/fsl-mc/fsl-mc-allocator.c
+++ b/drivers/bus/fsl-mc/fsl-mc-allocator.c
@@ -355,7 +355,7 @@ int fsl_mc_populate_irq_pool(struct fsl_mc_bus *mc_bus,
 		return error;
 
 	irq_resources = devm_kzalloc(&mc_bus_dev->dev,
-				     sizeof(*irq_resources) * irq_count,
+				     array_size(irq_count, sizeof(*irq_resources)),
 				     GFP_KERNEL);
 	if (!irq_resources) {
 		error = -ENOMEM;
@@ -455,7 +455,8 @@ int __must_check fsl_mc_allocate_irqs(struct fsl_mc_device *mc_dev)
 		return -ENOSPC;
 	}
 
-	irqs = devm_kzalloc(&mc_dev->dev, irq_count * sizeof(irqs[0]),
+	irqs = devm_kzalloc(&mc_dev->dev,
+			    array_size(irq_count, sizeof(irqs[0])),
 			    GFP_KERNEL);
 	if (!irqs)
 		return -ENOMEM;
diff --git a/drivers/clk/bcm/clk-bcm2835.c b/drivers/clk/bcm/clk-bcm2835.c
index c228bd6f6314..a5cefbdd4734 100644
--- a/drivers/clk/bcm/clk-bcm2835.c
+++ b/drivers/clk/bcm/clk-bcm2835.c
@@ -738,7 +738,8 @@ static int bcm2835_pll_debug_init(struct clk_hw *hw,
 	const struct bcm2835_pll_data *data = pll->data;
 	struct debugfs_reg32 *regs;
 
-	regs = devm_kzalloc(cprman->dev, 7 * sizeof(*regs), GFP_KERNEL);
+	regs = devm_kzalloc(cprman->dev, array_size(7, sizeof(*regs)),
+			    GFP_KERNEL);
 	if (!regs)
 		return -ENOMEM;
 
@@ -869,7 +870,8 @@ static int bcm2835_pll_divider_debug_init(struct clk_hw *hw,
 	const struct bcm2835_pll_divider_data *data = divider->data;
 	struct debugfs_reg32 *regs;
 
-	regs = devm_kzalloc(cprman->dev, 7 * sizeof(*regs), GFP_KERNEL);
+	regs = devm_kzalloc(cprman->dev, array_size(7, sizeof(*regs)),
+			    GFP_KERNEL);
 	if (!regs)
 		return -ENOMEM;
 
diff --git a/drivers/clk/ti/adpll.c b/drivers/clk/ti/adpll.c
index d6036c788fab..86dc421b6356 100644
--- a/drivers/clk/ti/adpll.c
+++ b/drivers/clk/ti/adpll.c
@@ -501,8 +501,8 @@ static int ti_adpll_init_dco(struct ti_adpll_data *d)
 	const char *postfix;
 	int width, err;
 
-	d->outputs.clks = devm_kzalloc(d->dev, sizeof(struct clk *) *
-				       MAX_ADPLL_OUTPUTS,
+	d->outputs.clks = devm_kzalloc(d->dev,
+				       array_size(MAX_ADPLL_OUTPUTS, sizeof(struct clk *)),
 				       GFP_KERNEL);
 	if (!d->outputs.clks)
 		return -ENOMEM;
@@ -915,8 +915,8 @@ static int ti_adpll_probe(struct platform_device *pdev)
 	if (err)
 		return err;
 
-	d->clocks = devm_kzalloc(d->dev, sizeof(struct ti_adpll_clock) *
-				 TI_ADPLL_NR_CLOCKS,
+	d->clocks = devm_kzalloc(d->dev,
+				 array_size(TI_ADPLL_NR_CLOCKS, sizeof(struct ti_adpll_clock)),
 				 GFP_KERNEL);
 	if (!d->clocks)
 		return -ENOMEM;
diff --git a/drivers/cpufreq/imx6q-cpufreq.c b/drivers/cpufreq/imx6q-cpufreq.c
index 83cf631fc9bc..4f5dcfd86932 100644
--- a/drivers/cpufreq/imx6q-cpufreq.c
+++ b/drivers/cpufreq/imx6q-cpufreq.c
@@ -377,7 +377,9 @@ static int imx6q_cpufreq_probe(struct platform_device *pdev)
 	}
 
 	/* Make imx6_soc_volt array's size same as arm opp number */
-	imx6_soc_volt = devm_kzalloc(cpu_dev, sizeof(*imx6_soc_volt) * num, GFP_KERNEL);
+	imx6_soc_volt = devm_kzalloc(cpu_dev,
+				     array_size(num, sizeof(*imx6_soc_volt)),
+				     GFP_KERNEL);
 	if (imx6_soc_volt == NULL) {
 		ret = -ENOMEM;
 		goto free_freq_table;
diff --git a/drivers/devfreq/event/exynos-ppmu.c b/drivers/devfreq/event/exynos-ppmu.c
index d96e3dc71cf8..a90217e2448e 100644
--- a/drivers/devfreq/event/exynos-ppmu.c
+++ b/drivers/devfreq/event/exynos-ppmu.c
@@ -518,7 +518,7 @@ static int of_get_devfreq_events(struct device_node *np,
 	event_ops = exynos_bus_get_ops(np);
 
 	count = of_get_child_count(events_np);
-	desc = devm_kzalloc(dev, sizeof(*desc) * count, GFP_KERNEL);
+	desc = devm_kzalloc(dev, array_size(count, sizeof(*desc)), GFP_KERNEL);
 	if (!desc)
 		return -ENOMEM;
 	info->num_events = count;
diff --git a/drivers/dma/mv_xor_v2.c b/drivers/dma/mv_xor_v2.c
index 3548caa9e933..651f07546d50 100644
--- a/drivers/dma/mv_xor_v2.c
+++ b/drivers/dma/mv_xor_v2.c
@@ -809,8 +809,9 @@ static int mv_xor_v2_probe(struct platform_device *pdev)
 	}
 
 	/* alloc memory for the SW descriptors */
-	xor_dev->sw_desq = devm_kzalloc(&pdev->dev, sizeof(*sw_desc) *
-					MV_XOR_V2_DESC_NUM, GFP_KERNEL);
+	xor_dev->sw_desq = devm_kzalloc(&pdev->dev,
+					array_size(MV_XOR_V2_DESC_NUM, sizeof(*sw_desc)),
+					GFP_KERNEL);
 	if (!xor_dev->sw_desq) {
 		ret = -ENOMEM;
 		goto free_hw_desq;
diff --git a/drivers/firmware/arm_scpi.c b/drivers/firmware/arm_scpi.c
index 6d7a6c0a5e07..ac264d848ac5 100644
--- a/drivers/firmware/arm_scpi.c
+++ b/drivers/firmware/arm_scpi.c
@@ -890,7 +890,8 @@ static int scpi_alloc_xfer_list(struct device *dev, struct scpi_chan *ch)
 	int i;
 	struct scpi_xfer *xfers;
 
-	xfers = devm_kzalloc(dev, MAX_SCPI_XFERS * sizeof(*xfers), GFP_KERNEL);
+	xfers = devm_kzalloc(dev, array_size(MAX_SCPI_XFERS, sizeof(*xfers)),
+			     GFP_KERNEL);
 	if (!xfers)
 		return -ENOMEM;
 
diff --git a/drivers/gpio/gpio-davinci.c b/drivers/gpio/gpio-davinci.c
index 987126c4c6f6..7527eb87105a 100644
--- a/drivers/gpio/gpio-davinci.c
+++ b/drivers/gpio/gpio-davinci.c
@@ -199,7 +199,7 @@ static int davinci_gpio_probe(struct platform_device *pdev)
 
 	nbank = DIV_ROUND_UP(ngpio, 32);
 	chips = devm_kzalloc(dev,
-			     nbank * sizeof(struct davinci_gpio_controller),
+			     array_size(nbank, sizeof(struct davinci_gpio_controller)),
 			     GFP_KERNEL);
 	if (!chips)
 		return -ENOMEM;
diff --git a/drivers/gpio/gpio-thunderx.c b/drivers/gpio/gpio-thunderx.c
index d16e9d4a129b..f0a53fc27653 100644
--- a/drivers/gpio/gpio-thunderx.c
+++ b/drivers/gpio/gpio-thunderx.c
@@ -505,15 +505,15 @@ static int thunderx_gpio_probe(struct pci_dev *pdev,
 	}
 
 	txgpio->msix_entries = devm_kzalloc(dev,
-					  sizeof(struct msix_entry) * ngpio,
-					  GFP_KERNEL);
+					    array_size(ngpio, sizeof(struct msix_entry)),
+					    GFP_KERNEL);
 	if (!txgpio->msix_entries) {
 		err = -ENOMEM;
 		goto out;
 	}
 
 	txgpio->line_entries = devm_kzalloc(dev,
-					    sizeof(struct thunderx_line) * ngpio,
+					    array_size(ngpio, sizeof(struct thunderx_line)),
 					    GFP_KERNEL);
 	if (!txgpio->line_entries) {
 		err = -ENOMEM;
diff --git a/drivers/gpu/drm/exynos/exynos_hdmi.c b/drivers/gpu/drm/exynos/exynos_hdmi.c
index abd84cbcf1c2..68ec5ae80380 100644
--- a/drivers/gpu/drm/exynos/exynos_hdmi.c
+++ b/drivers/gpu/drm/exynos/exynos_hdmi.c
@@ -1694,7 +1694,7 @@ static int hdmi_clk_init(struct hdmi_context *hdata)
 	if (!count)
 		return 0;
 
-	clks = devm_kzalloc(dev, sizeof(*clks) * count, GFP_KERNEL);
+	clks = devm_kzalloc(dev, array_size(count, sizeof(*clks)), GFP_KERNEL);
 	if (!clks)
 		return -ENOMEM;
 
diff --git a/drivers/hid/hid-sensor-hub.c b/drivers/hid/hid-sensor-hub.c
index 25363fc571bc..0377c6536f25 100644
--- a/drivers/hid/hid-sensor-hub.c
+++ b/drivers/hid/hid-sensor-hub.c
@@ -624,8 +624,8 @@ static int sensor_hub_probe(struct hid_device *hdev,
 		ret = -EINVAL;
 		goto err_stop_hw;
 	}
-	sd->hid_sensor_hub_client_devs = devm_kzalloc(&hdev->dev, dev_cnt *
-						      sizeof(struct mfd_cell),
+	sd->hid_sensor_hub_client_devs = devm_kzalloc(&hdev->dev,
+						      array_size(dev_cnt, sizeof(struct mfd_cell)),
 						      GFP_KERNEL);
 	if (sd->hid_sensor_hub_client_devs == NULL) {
 		hid_err(hdev, "Failed to allocate memory for mfd cells\n");
diff --git a/drivers/hid/wacom_sys.c b/drivers/hid/wacom_sys.c
index b54ef1ffcbec..e8ce80a8d64f 100644
--- a/drivers/hid/wacom_sys.c
+++ b/drivers/hid/wacom_sys.c
@@ -1361,7 +1361,8 @@ static int wacom_led_groups_alloc_and_register_one(struct device *dev,
 	if (!devres_open_group(dev, &wacom->led.groups[group_id], GFP_KERNEL))
 		return -ENOMEM;
 
-	leds = devm_kzalloc(dev, sizeof(struct wacom_led) * count, GFP_KERNEL);
+	leds = devm_kzalloc(dev, array_size(count, sizeof(struct wacom_led)),
+			    GFP_KERNEL);
 	if (!leds) {
 		error = -ENOMEM;
 		goto err;
@@ -1461,7 +1462,8 @@ static int wacom_led_groups_allocate(struct wacom *wacom, int count)
 	struct wacom_group_leds *groups;
 	int error;
 
-	groups = devm_kzalloc(dev, sizeof(struct wacom_group_leds) * count,
+	groups = devm_kzalloc(dev,
+			      array_size(count, sizeof(struct wacom_group_leds)),
 			      GFP_KERNEL);
 	if (!groups)
 		return -ENOMEM;
diff --git a/drivers/hwmon/aspeed-pwm-tacho.c b/drivers/hwmon/aspeed-pwm-tacho.c
index 693a3d53cab5..c931b906d078 100644
--- a/drivers/hwmon/aspeed-pwm-tacho.c
+++ b/drivers/hwmon/aspeed-pwm-tacho.c
@@ -894,7 +894,8 @@ static int aspeed_create_fan(struct device *dev,
 	count = of_property_count_u8_elems(child, "aspeed,fan-tach-ch");
 	if (count < 1)
 		return -EINVAL;
-	fan_tach_ch = devm_kzalloc(dev, sizeof(*fan_tach_ch) * count,
+	fan_tach_ch = devm_kzalloc(dev,
+				   array_size(count, sizeof(*fan_tach_ch)),
 				   GFP_KERNEL);
 	if (!fan_tach_ch)
 		return -ENOMEM;
diff --git a/drivers/hwmon/nct6683.c b/drivers/hwmon/nct6683.c
index 8b0bc4fc06e8..9ad14471f618 100644
--- a/drivers/hwmon/nct6683.c
+++ b/drivers/hwmon/nct6683.c
@@ -431,7 +431,7 @@ nct6683_create_attr_group(struct device *dev,
 	if (attrs == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	su = devm_kzalloc(dev, sizeof(*su) * repeat * count,
+	su = devm_kzalloc(dev, array3_size(repeat, count, sizeof(*su)),
 			  GFP_KERNEL);
 	if (su == NULL)
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/hwmon/nct6775.c b/drivers/hwmon/nct6775.c
index aebce560bfaf..d421b121a0eb 100644
--- a/drivers/hwmon/nct6775.c
+++ b/drivers/hwmon/nct6775.c
@@ -1195,8 +1195,8 @@ nct6775_create_attr_group(struct device *dev,
 	if (attrs == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	su = devm_kzalloc(dev, sizeof(*su) * repeat * count,
-			       GFP_KERNEL);
+	su = devm_kzalloc(dev, array3_size(repeat, count, sizeof(*su)),
+			  GFP_KERNEL);
 	if (su == NULL)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/hwmon/pmbus/ucd9000.c b/drivers/hwmon/pmbus/ucd9000.c
index 70cecb06f93c..2a661fed38d0 100644
--- a/drivers/hwmon/pmbus/ucd9000.c
+++ b/drivers/hwmon/pmbus/ucd9000.c
@@ -455,7 +455,7 @@ static int ucd9000_init_debugfs(struct i2c_client *client,
 	if (mid->driver_data == ucd9090 || mid->driver_data == ucd90160 ||
 	    mid->driver_data == ucd90910) {
 		entries = devm_kzalloc(&client->dev,
-				       sizeof(*entries) * UCD9000_GPI_COUNT,
+				       array_size(UCD9000_GPI_COUNT, sizeof(*entries)),
 				       GFP_KERNEL);
 		if (!entries)
 			return -ENOMEM;
diff --git a/drivers/hwmon/pwm-fan.c b/drivers/hwmon/pwm-fan.c
index 70cc0d134f3c..5bd0ec7fcee9 100644
--- a/drivers/hwmon/pwm-fan.c
+++ b/drivers/hwmon/pwm-fan.c
@@ -180,7 +180,8 @@ static int pwm_fan_of_get_cooling_data(struct device *dev,
 	}
 
 	num = ret;
-	ctx->pwm_fan_cooling_levels = devm_kzalloc(dev, num * sizeof(u32),
+	ctx->pwm_fan_cooling_levels = devm_kzalloc(dev,
+						   array_size(num, sizeof(u32)),
 						   GFP_KERNEL);
 	if (!ctx->pwm_fan_cooling_levels)
 		return -ENOMEM;
diff --git a/drivers/i2c/busses/i2c-qup.c b/drivers/i2c/busses/i2c-qup.c
index 904dfec7ab96..e6434197bbff 100644
--- a/drivers/i2c/busses/i2c-qup.c
+++ b/drivers/i2c/busses/i2c-qup.c
@@ -1692,7 +1692,7 @@ static int qup_i2c_probe(struct platform_device *pdev)
 		qup->max_xfer_sg_len = (MX_BLOCKS << 1);
 		blocks = (MX_DMA_BLOCKS << 1) + 1;
 		qup->btx.sg = devm_kzalloc(&pdev->dev,
-					   sizeof(*qup->btx.sg) * blocks,
+					   array_size(blocks, sizeof(*qup->btx.sg)),
 					   GFP_KERNEL);
 		if (!qup->btx.sg) {
 			ret = -ENOMEM;
@@ -1701,7 +1701,7 @@ static int qup_i2c_probe(struct platform_device *pdev)
 		sg_init_table(qup->btx.sg, blocks);
 
 		qup->brx.sg = devm_kzalloc(&pdev->dev,
-					   sizeof(*qup->brx.sg) * blocks,
+					   array_size(blocks, sizeof(*qup->brx.sg)),
 					   GFP_KERNEL);
 		if (!qup->brx.sg) {
 			ret = -ENOMEM;
diff --git a/drivers/iio/multiplexer/iio-mux.c b/drivers/iio/multiplexer/iio-mux.c
index 60621ccd67e4..b476ee17b1b1 100644
--- a/drivers/iio/multiplexer/iio-mux.c
+++ b/drivers/iio/multiplexer/iio-mux.c
@@ -282,8 +282,8 @@ static int mux_configure_channel(struct device *dev, struct mux *mux,
 			return -ENOMEM;
 	}
 	child->ext_info_cache = devm_kzalloc(dev,
-					     sizeof(*child->ext_info_cache) *
-					     num_ext_info, GFP_KERNEL);
+					     array_size(num_ext_info, sizeof(*child->ext_info_cache)),
+					     GFP_KERNEL);
 	if (!child->ext_info_cache)
 		return -ENOMEM;
 
diff --git a/drivers/input/keyboard/samsung-keypad.c b/drivers/input/keyboard/samsung-keypad.c
index 316414465c77..d8a7af370e6d 100644
--- a/drivers/input/keyboard/samsung-keypad.c
+++ b/drivers/input/keyboard/samsung-keypad.c
@@ -281,7 +281,8 @@ samsung_keypad_parse_dt(struct device *dev)
 
 	key_count = of_get_child_count(np);
 	keymap_data->keymap_size = key_count;
-	keymap = devm_kzalloc(dev, sizeof(uint32_t) * key_count, GFP_KERNEL);
+	keymap = devm_kzalloc(dev, array_size(key_count, sizeof(uint32_t)),
+			      GFP_KERNEL);
 	if (!keymap) {
 		dev_err(dev, "could not allocate memory for keymap\n");
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/input/matrix-keymap.c b/drivers/input/matrix-keymap.c
index 8ccefc15c7a4..a4e1cad251b5 100644
--- a/drivers/input/matrix-keymap.c
+++ b/drivers/input/matrix-keymap.c
@@ -171,7 +171,7 @@ int matrix_keypad_build_keymap(const struct matrix_keymap_data *keymap_data,
 
 	if (!keymap) {
 		keymap = devm_kzalloc(input_dev->dev.parent,
-				      max_keys * sizeof(*keymap),
+				      array_size(max_keys, sizeof(*keymap)),
 				      GFP_KERNEL);
 		if (!keymap) {
 			dev_err(input_dev->dev.parent,
diff --git a/drivers/input/rmi4/rmi_f54.c b/drivers/input/rmi4/rmi_f54.c
index 5343f2c08f15..e8a59d164019 100644
--- a/drivers/input/rmi4/rmi_f54.c
+++ b/drivers/input/rmi4/rmi_f54.c
@@ -685,7 +685,7 @@ static int rmi_f54_probe(struct rmi_function *fn)
 	rx = f54->num_rx_electrodes;
 	tx = f54->num_tx_electrodes;
 	f54->report_data = devm_kzalloc(&fn->dev,
-					sizeof(u16) * tx * rx,
+					array3_size(tx, rx, sizeof(u16)),
 					GFP_KERNEL);
 	if (f54->report_data == NULL)
 		return -ENOMEM;
diff --git a/drivers/iommu/arm-smmu.c b/drivers/iommu/arm-smmu.c
index 69e7c60792a8..0d0e7ca608e1 100644
--- a/drivers/iommu/arm-smmu.c
+++ b/drivers/iommu/arm-smmu.c
@@ -2082,7 +2082,8 @@ static int arm_smmu_device_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	smmu->irqs = devm_kzalloc(dev, sizeof(*smmu->irqs) * num_irqs,
+	smmu->irqs = devm_kzalloc(dev,
+				  array_size(num_irqs, sizeof(*smmu->irqs)),
 				  GFP_KERNEL);
 	if (!smmu->irqs) {
 		dev_err(dev, "failed to allocate %d irqs\n", num_irqs);
diff --git a/drivers/iommu/rockchip-iommu.c b/drivers/iommu/rockchip-iommu.c
index 5fc8656c60f9..58380b4a17b3 100644
--- a/drivers/iommu/rockchip-iommu.c
+++ b/drivers/iommu/rockchip-iommu.c
@@ -1135,7 +1135,8 @@ static int rk_iommu_probe(struct platform_device *pdev)
 	iommu->dev = dev;
 	iommu->num_mmu = 0;
 
-	iommu->bases = devm_kzalloc(dev, sizeof(*iommu->bases) * num_res,
+	iommu->bases = devm_kzalloc(dev,
+				    array_size(num_res, sizeof(*iommu->bases)),
 				    GFP_KERNEL);
 	if (!iommu->bases)
 		return -ENOMEM;
diff --git a/drivers/leds/leds-lp55xx-common.c b/drivers/leds/leds-lp55xx-common.c
index 5377f22ff994..152ce2804a60 100644
--- a/drivers/leds/leds-lp55xx-common.c
+++ b/drivers/leds/leds-lp55xx-common.c
@@ -560,7 +560,8 @@ struct lp55xx_platform_data *lp55xx_of_populate_pdata(struct device *dev,
 		return ERR_PTR(-EINVAL);
 	}
 
-	cfg = devm_kzalloc(dev, sizeof(*cfg) * num_channels, GFP_KERNEL);
+	cfg = devm_kzalloc(dev, array_size(num_channels, sizeof(*cfg)),
+			   GFP_KERNEL);
 	if (!cfg)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/leds/leds-netxbig.c b/drivers/leds/leds-netxbig.c
index f48b1aed9b4e..ad47fac3ed4d 100644
--- a/drivers/leds/leds-netxbig.c
+++ b/drivers/leds/leds-netxbig.c
@@ -335,7 +335,8 @@ static int gpio_ext_get_of_pdata(struct device *dev, struct device_node *np,
 		return ret;
 	}
 	num_addr = ret;
-	addr = devm_kzalloc(dev, num_addr * sizeof(*addr), GFP_KERNEL);
+	addr = devm_kzalloc(dev, array_size(num_addr, sizeof(*addr)),
+			    GFP_KERNEL);
 	if (!addr)
 		return -ENOMEM;
 
@@ -355,7 +356,8 @@ static int gpio_ext_get_of_pdata(struct device *dev, struct device_node *np,
 		return ret;
 	}
 	num_data = ret;
-	data = devm_kzalloc(dev, num_data * sizeof(*data), GFP_KERNEL);
+	data = devm_kzalloc(dev, array_size(num_data, sizeof(*data)),
+			    GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
 
@@ -415,7 +417,8 @@ static int netxbig_leds_get_of_pdata(struct device *dev,
 		if (ret % 3)
 			return -EINVAL;
 		num_timers = ret / 3;
-		timers = devm_kzalloc(dev, num_timers * sizeof(*timers),
+		timers = devm_kzalloc(dev,
+				      array_size(num_timers, sizeof(*timers)),
 				      GFP_KERNEL);
 		if (!timers)
 			return -ENOMEM;
@@ -444,7 +447,8 @@ static int netxbig_leds_get_of_pdata(struct device *dev,
 		return -ENODEV;
 	}
 
-	leds = devm_kzalloc(dev, num_leds * sizeof(*leds), GFP_KERNEL);
+	leds = devm_kzalloc(dev, array_size(num_leds, sizeof(*leds)),
+			    GFP_KERNEL);
 	if (!leds)
 		return -ENOMEM;
 
@@ -471,7 +475,7 @@ static int netxbig_leds_get_of_pdata(struct device *dev,
 
 		mode_val =
 			devm_kzalloc(dev,
-				     NETXBIG_LED_MODE_NUM * sizeof(*mode_val),
+				     array_size(NETXBIG_LED_MODE_NUM, sizeof(*mode_val)),
 				     GFP_KERNEL);
 		if (!mode_val) {
 			ret = -ENOMEM;
diff --git a/drivers/leds/leds-ns2.c b/drivers/leds/leds-ns2.c
index 506b75b190e7..0d485920859f 100644
--- a/drivers/leds/leds-ns2.c
+++ b/drivers/leds/leds-ns2.c
@@ -264,7 +264,7 @@ ns2_leds_get_of_pdata(struct device *dev, struct ns2_led_platform_data *pdata)
 	if (!num_leds)
 		return -ENODEV;
 
-	leds = devm_kzalloc(dev, num_leds * sizeof(struct ns2_led),
+	leds = devm_kzalloc(dev, array_size(num_leds, sizeof(struct ns2_led)),
 			    GFP_KERNEL);
 	if (!leds)
 		return -ENOMEM;
@@ -299,7 +299,7 @@ ns2_leds_get_of_pdata(struct device *dev, struct ns2_led_platform_data *pdata)
 
 		num_modes = ret / 3;
 		modval = devm_kzalloc(dev,
-				      num_modes * sizeof(struct ns2_led_modval),
+				      array_size(num_modes, sizeof(struct ns2_led_modval)),
 				      GFP_KERNEL);
 		if (!modval)
 			return -ENOMEM;
diff --git a/drivers/leds/leds-tca6507.c b/drivers/leds/leds-tca6507.c
index c12c16fb1b9c..0ef429e8dfe7 100644
--- a/drivers/leds/leds-tca6507.c
+++ b/drivers/leds/leds-tca6507.c
@@ -698,7 +698,8 @@ tca6507_led_dt_init(struct i2c_client *client)
 		return ERR_PTR(-ENODEV);
 
 	tca_leds = devm_kzalloc(&client->dev,
-			sizeof(struct led_info) * NUM_LEDS, GFP_KERNEL);
+				array_size(NUM_LEDS, sizeof(struct led_info)),
+				GFP_KERNEL);
 	if (!tca_leds)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/mailbox/mailbox-sti.c b/drivers/mailbox/mailbox-sti.c
index 41bcd339b68a..2761d1089047 100644
--- a/drivers/mailbox/mailbox-sti.c
+++ b/drivers/mailbox/mailbox-sti.c
@@ -443,7 +443,8 @@ static int sti_mbox_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	chans = devm_kzalloc(&pdev->dev,
-			     sizeof(*chans) * STI_MBOX_CHAN_MAX, GFP_KERNEL);
+			     array_size(STI_MBOX_CHAN_MAX, sizeof(*chans)),
+			     GFP_KERNEL);
 	if (!chans)
 		return -ENOMEM;
 
diff --git a/drivers/mailbox/omap-mailbox.c b/drivers/mailbox/omap-mailbox.c
index 2517038a8452..d9709f32f578 100644
--- a/drivers/mailbox/omap-mailbox.c
+++ b/drivers/mailbox/omap-mailbox.c
@@ -729,7 +729,8 @@ static int omap_mbox_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	finfoblk = devm_kzalloc(&pdev->dev, info_count * sizeof(*finfoblk),
+	finfoblk = devm_kzalloc(&pdev->dev,
+				array_size(info_count, sizeof(*finfoblk)),
 				GFP_KERNEL);
 	if (!finfoblk)
 		return -ENOMEM;
@@ -773,7 +774,8 @@ static int omap_mbox_probe(struct platform_device *pdev)
 	if (IS_ERR(mdev->mbox_base))
 		return PTR_ERR(mdev->mbox_base);
 
-	mdev->irq_ctx = devm_kzalloc(&pdev->dev, num_users * sizeof(u32),
+	mdev->irq_ctx = devm_kzalloc(&pdev->dev,
+				     array_size(num_users, sizeof(u32)),
 				     GFP_KERNEL);
 	if (!mdev->irq_ctx)
 		return -ENOMEM;
@@ -789,7 +791,8 @@ static int omap_mbox_probe(struct platform_device *pdev)
 	if (!chnls)
 		return -ENOMEM;
 
-	mboxblk = devm_kzalloc(&pdev->dev, info_count * sizeof(*mbox),
+	mboxblk = devm_kzalloc(&pdev->dev,
+			       array_size(info_count, sizeof(*mbox)),
 			       GFP_KERNEL);
 	if (!mboxblk)
 		return -ENOMEM;
diff --git a/drivers/mailbox/ti-msgmgr.c b/drivers/mailbox/ti-msgmgr.c
index 78753a87ba4d..8237db43a204 100644
--- a/drivers/mailbox/ti-msgmgr.c
+++ b/drivers/mailbox/ti-msgmgr.c
@@ -568,12 +568,14 @@ static int ti_msgmgr_probe(struct platform_device *pdev)
 	}
 	inst->num_valid_queues = queue_count;
 
-	qinst = devm_kzalloc(dev, sizeof(*qinst) * queue_count, GFP_KERNEL);
+	qinst = devm_kzalloc(dev, array_size(queue_count, sizeof(*qinst)),
+			     GFP_KERNEL);
 	if (!qinst)
 		return -ENOMEM;
 	inst->qinsts = qinst;
 
-	chans = devm_kzalloc(dev, sizeof(*chans) * queue_count, GFP_KERNEL);
+	chans = devm_kzalloc(dev, array_size(queue_count, sizeof(*chans)),
+			     GFP_KERNEL);
 	if (!chans)
 		return -ENOMEM;
 	inst->chans = chans;
diff --git a/drivers/media/i2c/s5k5baf.c b/drivers/media/i2c/s5k5baf.c
index ff46d2c96cea..a3bb3841d6b7 100644
--- a/drivers/media/i2c/s5k5baf.c
+++ b/drivers/media/i2c/s5k5baf.c
@@ -373,7 +373,7 @@ static int s5k5baf_fw_parse(struct device *dev, struct s5k5baf_fw **fw,
 	data += S5K5BAG_FW_TAG_LEN;
 	count -= S5K5BAG_FW_TAG_LEN;
 
-	d = devm_kzalloc(dev, count * sizeof(u16), GFP_KERNEL);
+	d = devm_kzalloc(dev, array_size(count, sizeof(u16)), GFP_KERNEL);
 	if (!d)
 		return -ENOMEM;
 
diff --git a/drivers/media/platform/davinci/vpif_capture.c b/drivers/media/platform/davinci/vpif_capture.c
index 9364cdf62f54..244cac2eea6a 100644
--- a/drivers/media/platform/davinci/vpif_capture.c
+++ b/drivers/media/platform/davinci/vpif_capture.c
@@ -1528,8 +1528,9 @@ vpif_capture_get_pdata(struct platform_device *pdev)
 	if (!pdata)
 		return NULL;
 	pdata->subdev_info =
-		devm_kzalloc(&pdev->dev, sizeof(*pdata->subdev_info) *
-			     VPIF_CAPTURE_NUM_CHANNELS, GFP_KERNEL);
+		devm_kzalloc(&pdev->dev,
+			     array_size(VPIF_CAPTURE_NUM_CHANNELS, sizeof(*pdata->subdev_info)),
+			     GFP_KERNEL);
 
 	if (!pdata->subdev_info)
 		return NULL;
@@ -1547,8 +1548,7 @@ vpif_capture_get_pdata(struct platform_device *pdev)
 		sdinfo = &pdata->subdev_info[i];
 		chan = &pdata->chan_config[i];
 		chan->inputs = devm_kzalloc(&pdev->dev,
-					    sizeof(*chan->inputs) *
-					    VPIF_CAPTURE_NUM_CHANNELS,
+					    array_size(VPIF_CAPTURE_NUM_CHANNELS, sizeof(*chan->inputs)),
 					    GFP_KERNEL);
 		if (!chan->inputs)
 			return NULL;
diff --git a/drivers/media/platform/vsp1/vsp1_entity.c b/drivers/media/platform/vsp1/vsp1_entity.c
index 54de15095709..405388e0ec37 100644
--- a/drivers/media/platform/vsp1/vsp1_entity.c
+++ b/drivers/media/platform/vsp1/vsp1_entity.c
@@ -511,7 +511,8 @@ int vsp1_entity_init(struct vsp1_device *vsp1, struct vsp1_entity *entity,
 	entity->source_pad = num_pads - 1;
 
 	/* Allocate and initialize pads. */
-	entity->pads = devm_kzalloc(vsp1->dev, num_pads * sizeof(*entity->pads),
+	entity->pads = devm_kzalloc(vsp1->dev,
+				    array_size(num_pads, sizeof(*entity->pads)),
 				    GFP_KERNEL);
 	if (entity->pads == NULL)
 		return -ENOMEM;
diff --git a/drivers/media/platform/xilinx/xilinx-vipp.c b/drivers/media/platform/xilinx/xilinx-vipp.c
index 6bb28cd49dae..ef8eb8e32480 100644
--- a/drivers/media/platform/xilinx/xilinx-vipp.c
+++ b/drivers/media/platform/xilinx/xilinx-vipp.c
@@ -532,7 +532,8 @@ static int xvip_graph_init(struct xvip_composite_device *xdev)
 
 	/* Register the subdevices notifier. */
 	num_subdevs = xdev->num_subdevs;
-	subdevs = devm_kzalloc(xdev->dev, sizeof(*subdevs) * num_subdevs,
+	subdevs = devm_kzalloc(xdev->dev,
+			       array_size(num_subdevs, sizeof(*subdevs)),
 			       GFP_KERNEL);
 	if (subdevs == NULL) {
 		ret = -ENOMEM;
diff --git a/drivers/memory/of_memory.c b/drivers/memory/of_memory.c
index 568f05ed961a..c7c61418a354 100644
--- a/drivers/memory/of_memory.c
+++ b/drivers/memory/of_memory.c
@@ -126,8 +126,9 @@ const struct lpddr2_timings *of_get_ddr_timings(struct device_node *np_ddr,
 			arr_sz++;
 
 	if (arr_sz)
-		timings = devm_kzalloc(dev, sizeof(*timings) * arr_sz,
-			GFP_KERNEL);
+		timings = devm_kzalloc(dev,
+				       array_size(arr_sz, sizeof(*timings)),
+				       GFP_KERNEL);
 
 	if (!timings)
 		goto default_timings;
diff --git a/drivers/mfd/ab8500-debugfs.c b/drivers/mfd/ab8500-debugfs.c
index 8ba41073dd89..3e4a238f8583 100644
--- a/drivers/mfd/ab8500-debugfs.c
+++ b/drivers/mfd/ab8500-debugfs.c
@@ -2661,17 +2661,20 @@ static int ab8500_debug_probe(struct platform_device *plf)
 	num_irqs = ab8500->mask_size;
 
 	irq_count = devm_kzalloc(&plf->dev,
-				 sizeof(*irq_count)*num_irqs, GFP_KERNEL);
+				 array_size(num_irqs, sizeof(*irq_count)),
+				 GFP_KERNEL);
 	if (!irq_count)
 		return -ENOMEM;
 
 	dev_attr = devm_kzalloc(&plf->dev,
-				sizeof(*dev_attr)*num_irqs, GFP_KERNEL);
+				array_size(num_irqs, sizeof(*dev_attr)),
+				GFP_KERNEL);
 	if (!dev_attr)
 		return -ENOMEM;
 
 	event_name = devm_kzalloc(&plf->dev,
-				  sizeof(*event_name)*num_irqs, GFP_KERNEL);
+				  array_size(num_irqs, sizeof(*event_name)),
+				  GFP_KERNEL);
 	if (!event_name)
 		return -ENOMEM;
 
diff --git a/drivers/mfd/twl-core.c b/drivers/mfd/twl-core.c
index d3133a371e27..e5bb7d6d9d0f 100644
--- a/drivers/mfd/twl-core.c
+++ b/drivers/mfd/twl-core.c
@@ -1140,8 +1140,8 @@ twl_probe(struct i2c_client *client, const struct i2c_device_id *id)
 
 	num_slaves = twl_get_num_slaves();
 	twl_priv->twl_modules = devm_kzalloc(&client->dev,
-					 sizeof(struct twl_client) * num_slaves,
-					 GFP_KERNEL);
+					     array_size(num_slaves, sizeof(struct twl_client)),
+					     GFP_KERNEL);
 	if (!twl_priv->twl_modules) {
 		status = -ENOMEM;
 		goto free;
diff --git a/drivers/misc/sram.c b/drivers/misc/sram.c
index a9d217c9afcc..eff8eae3b005 100644
--- a/drivers/misc/sram.c
+++ b/drivers/misc/sram.c
@@ -265,8 +265,8 @@ static int sram_reserve_regions(struct sram_dev *sram, struct resource *res)
 
 	if (exports) {
 		sram->partition = devm_kzalloc(sram->dev,
-				       exports * sizeof(*sram->partition),
-				       GFP_KERNEL);
+					       array_size(exports, sizeof(*sram->partition)),
+					       GFP_KERNEL);
 		if (!sram->partition) {
 			ret = -ENOMEM;
 			goto err_chunks;
diff --git a/drivers/mtd/devices/docg3.c b/drivers/mtd/devices/docg3.c
index a1782ceae772..14608fa4400f 100644
--- a/drivers/mtd/devices/docg3.c
+++ b/drivers/mtd/devices/docg3.c
@@ -1995,7 +1995,8 @@ static int __init docg3_probe(struct platform_device *pdev)
 	base = devm_ioremap(dev, ress->start, DOC_IOSPACE_SIZE);
 
 	ret = -ENOMEM;
-	cascade = devm_kzalloc(dev, sizeof(*cascade) * DOC_MAX_NBFLOORS,
+	cascade = devm_kzalloc(dev,
+			       array_size(DOC_MAX_NBFLOORS, sizeof(*cascade)),
 			       GFP_KERNEL);
 	if (!cascade)
 		return ret;
diff --git a/drivers/mtd/nand/raw/qcom_nandc.c b/drivers/mtd/nand/raw/qcom_nandc.c
index b554fb6e609c..d5e22922d011 100644
--- a/drivers/mtd/nand/raw/qcom_nandc.c
+++ b/drivers/mtd/nand/raw/qcom_nandc.c
@@ -2511,8 +2511,8 @@ static int qcom_nandc_alloc(struct qcom_nand_controller *nandc)
 		return -ENOMEM;
 
 	nandc->reg_read_buf = devm_kzalloc(nandc->dev,
-				MAX_REG_RD * sizeof(*nandc->reg_read_buf),
-				GFP_KERNEL);
+					   array_size(MAX_REG_RD, sizeof(*nandc->reg_read_buf)),
+					   GFP_KERNEL);
 	if (!nandc->reg_read_buf)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/amazon/ena/ena_ethtool.c b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
index 060cb18fa659..5eca39bd674d 100644
--- a/drivers/net/ethernet/amazon/ena/ena_ethtool.c
+++ b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
@@ -839,7 +839,7 @@ static void ena_dump_stats_ex(struct ena_adapter *adapter, u8 *buf)
 	}
 
 	strings_buf = devm_kzalloc(&adapter->pdev->dev,
-				   strings_num * ETH_GSTRING_LEN,
+				   array_size(ETH_GSTRING_LEN, strings_num),
 				   GFP_ATOMIC);
 	if (!strings_buf) {
 		netif_err(adapter, drv, netdev,
@@ -848,7 +848,7 @@ static void ena_dump_stats_ex(struct ena_adapter *adapter, u8 *buf)
 	}
 
 	data_buf = devm_kzalloc(&adapter->pdev->dev,
-				strings_num * sizeof(u64),
+				array_size(strings_num, sizeof(u64)),
 				GFP_ATOMIC);
 	if (!data_buf) {
 		netif_err(adapter, drv, netdev,
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 8bb0db990c8f..828f39dc72ba 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1141,7 +1141,9 @@ static int ethoc_probe(struct platform_device *pdev)
 	dev_dbg(&pdev->dev, "ethoc: num_tx: %d num_rx: %d\n",
 		priv->num_tx, priv->num_rx);
 
-	priv->vma = devm_kzalloc(&pdev->dev, num_bd*sizeof(void *), GFP_KERNEL);
+	priv->vma = devm_kzalloc(&pdev->dev,
+				 array_size(num_bd, sizeof(void *)),
+				 GFP_KERNEL);
 	if (!priv->vma) {
 		ret = -ENOMEM;
 		goto free;
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index fd43f98ddbe7..91ab4ee50d67 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -664,7 +664,7 @@ static struct dpaa_fq *dpaa_fq_alloc(struct device *dev,
 	struct dpaa_fq *dpaa_fq;
 	int i;
 
-	dpaa_fq = devm_kzalloc(dev, sizeof(*dpaa_fq) * count,
+	dpaa_fq = devm_kzalloc(dev, array_size(count, sizeof(*dpaa_fq)),
 			       GFP_KERNEL);
 	if (!dpaa_fq)
 		return NULL;
diff --git a/drivers/net/ethernet/ni/nixge.c b/drivers/net/ethernet/ni/nixge.c
index 27364b7572fc..8c4fd186ac8b 100644
--- a/drivers/net/ethernet/ni/nixge.c
+++ b/drivers/net/ethernet/ni/nixge.c
@@ -248,8 +248,7 @@ static int nixge_hw_dma_bd_init(struct net_device *ndev)
 		goto out;
 
 	priv->tx_skb = devm_kzalloc(ndev->dev.parent,
-				    sizeof(*priv->tx_skb) *
-				    TX_BD_NUM,
+				    array_size(TX_BD_NUM, sizeof(*priv->tx_skb)),
 				    GFP_KERNEL);
 	if (!priv->tx_skb)
 		goto out;
diff --git a/drivers/net/wireless/mediatek/mt76/mac80211.c b/drivers/net/wireless/mediatek/mt76/mac80211.c
index 4f30cdcd2b53..12ff10d2f921 100644
--- a/drivers/net/wireless/mediatek/mt76/mac80211.c
+++ b/drivers/net/wireless/mediatek/mt76/mac80211.c
@@ -181,7 +181,8 @@ mt76_init_sband(struct mt76_dev *dev, struct mt76_sband *msband,
 	if (!chanlist)
 		return -ENOMEM;
 
-	msband->chan = devm_kzalloc(dev->dev, n_chan * sizeof(*msband->chan),
+	msband->chan = devm_kzalloc(dev->dev,
+				    array_size(n_chan, sizeof(*msband->chan)),
 				    GFP_KERNEL);
 	if (!msband->chan)
 		return -ENOMEM;
diff --git a/drivers/nfc/fdp/i2c.c b/drivers/nfc/fdp/i2c.c
index c4da50e07bbc..935728080c59 100644
--- a/drivers/nfc/fdp/i2c.c
+++ b/drivers/nfc/fdp/i2c.c
@@ -260,7 +260,7 @@ static void fdp_nci_i2c_read_device_properties(struct device *dev,
 		len++;
 
 		*fw_vsc_cfg = devm_kmalloc(dev,
-					   len * sizeof(**fw_vsc_cfg),
+					   array_size(len, sizeof(**fw_vsc_cfg)),
 					   GFP_KERNEL);
 
 		r = device_property_read_u8_array(dev, FDP_DP_FW_VSC_CFG_NAME,
diff --git a/drivers/pci/dwc/pci-dra7xx.c b/drivers/pci/dwc/pci-dra7xx.c
index ed8558d638e5..eea624066777 100644
--- a/drivers/pci/dwc/pci-dra7xx.c
+++ b/drivers/pci/dwc/pci-dra7xx.c
@@ -638,11 +638,13 @@ static int __init dra7xx_pcie_probe(struct platform_device *pdev)
 		return phy_count;
 	}
 
-	phy = devm_kzalloc(dev, sizeof(*phy) * phy_count, GFP_KERNEL);
+	phy = devm_kzalloc(dev, array_size(phy_count, sizeof(*phy)),
+			   GFP_KERNEL);
 	if (!phy)
 		return -ENOMEM;
 
-	link = devm_kzalloc(dev, sizeof(*link) * phy_count, GFP_KERNEL);
+	link = devm_kzalloc(dev, array_size(phy_count, sizeof(*link)),
+			    GFP_KERNEL);
 	if (!link)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/berlin/berlin.c b/drivers/pinctrl/berlin/berlin.c
index cc3bd2efafe3..4b710037cea6 100644
--- a/drivers/pinctrl/berlin/berlin.c
+++ b/drivers/pinctrl/berlin/berlin.c
@@ -220,7 +220,7 @@ static int berlin_pinctrl_build_state(struct platform_device *pdev)
 
 	/* we will reallocate later */
 	pctrl->functions = devm_kzalloc(&pdev->dev,
-					max_functions * sizeof(*pctrl->functions),
+					array_size(max_functions, sizeof(*pctrl->functions)),
 					GFP_KERNEL);
 	if (!pctrl->functions)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/freescale/pinctrl-imx1-core.c b/drivers/pinctrl/freescale/pinctrl-imx1-core.c
index 4eedd874bd02..ebf32b65d822 100644
--- a/drivers/pinctrl/freescale/pinctrl-imx1-core.c
+++ b/drivers/pinctrl/freescale/pinctrl-imx1-core.c
@@ -572,11 +572,13 @@ static int imx1_pinctrl_parse_dt(struct platform_device *pdev,
 
 	info->nfunctions = nfuncs;
 	info->functions = devm_kzalloc(&pdev->dev,
-			nfuncs * sizeof(struct imx1_pmx_func), GFP_KERNEL);
+				       array_size(nfuncs, sizeof(struct imx1_pmx_func)),
+				       GFP_KERNEL);
 
 	info->ngroups = ngroups;
 	info->groups = devm_kzalloc(&pdev->dev,
-			ngroups * sizeof(struct imx1_pin_group), GFP_KERNEL);
+				    array_size(ngroups, sizeof(struct imx1_pin_group)),
+				    GFP_KERNEL);
 
 
 	if (!info->functions || !info->groups)
diff --git a/drivers/pinctrl/mvebu/pinctrl-armada-xp.c b/drivers/pinctrl/mvebu/pinctrl-armada-xp.c
index b854f1ee5de5..7c07575819ea 100644
--- a/drivers/pinctrl/mvebu/pinctrl-armada-xp.c
+++ b/drivers/pinctrl/mvebu/pinctrl-armada-xp.c
@@ -630,7 +630,8 @@ static int armada_xp_pinctrl_probe(struct platform_device *pdev)
 
 	nregs = DIV_ROUND_UP(soc->nmodes, MVEBU_MPPS_PER_REG);
 
-	mpp_saved_regs = devm_kmalloc(&pdev->dev, nregs * sizeof(u32),
+	mpp_saved_regs = devm_kmalloc(&pdev->dev,
+				      array_size(nregs, sizeof(u32)),
 				      GFP_KERNEL);
 	if (!mpp_saved_regs)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/mvebu/pinctrl-mvebu.c b/drivers/pinctrl/mvebu/pinctrl-mvebu.c
index 9e05cfaf75f0..437345990da7 100644
--- a/drivers/pinctrl/mvebu/pinctrl-mvebu.c
+++ b/drivers/pinctrl/mvebu/pinctrl-mvebu.c
@@ -501,8 +501,9 @@ static int mvebu_pinctrl_build_functions(struct platform_device *pdev,
 
 	/* we allocate functions for number of pins and hope
 	 * there are fewer unique functions than pins available */
-	funcs = devm_kzalloc(&pdev->dev, funcsize *
-			     sizeof(struct mvebu_pinctrl_function), GFP_KERNEL);
+	funcs = devm_kzalloc(&pdev->dev,
+			     array_size(funcsize, sizeof(struct mvebu_pinctrl_function)),
+			     GFP_KERNEL);
 	if (!funcs)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-at91.c b/drivers/pinctrl/pinctrl-at91.c
index 297f1d161211..2e9224ad8d11 100644
--- a/drivers/pinctrl/pinctrl-at91.c
+++ b/drivers/pinctrl/pinctrl-at91.c
@@ -269,7 +269,9 @@ static int at91_dt_node_to_map(struct pinctrl_dev *pctldev,
 	}
 
 	map_num += grp->npins;
-	new_map = devm_kzalloc(pctldev->dev, sizeof(*new_map) * map_num, GFP_KERNEL);
+	new_map = devm_kzalloc(pctldev->dev,
+			       array_size(map_num, sizeof(*new_map)),
+			       GFP_KERNEL);
 	if (!new_map)
 		return -ENOMEM;
 
@@ -1049,7 +1051,9 @@ static int at91_pinctrl_mux_mask(struct at91_pinctrl *info,
 	}
 	info->nmux = size / gpio_banks;
 
-	info->mux_mask = devm_kzalloc(info->dev, sizeof(u32) * size, GFP_KERNEL);
+	info->mux_mask = devm_kzalloc(info->dev,
+				      array_size(size, sizeof(u32)),
+				      GFP_KERNEL);
 	if (!info->mux_mask)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-axp209.c b/drivers/pinctrl/pinctrl-axp209.c
index 1231bbbfa744..f81dc2e301d6 100644
--- a/drivers/pinctrl/pinctrl-axp209.c
+++ b/drivers/pinctrl/pinctrl-axp209.c
@@ -328,7 +328,8 @@ static void axp20x_funcs_groups_from_mask(struct device *dev, unsigned int mask,
 
 	func->ngroups = ngroups;
 	if (func->ngroups > 0) {
-		func->groups = devm_kzalloc(dev, ngroups * sizeof(const char *),
+		func->groups = devm_kzalloc(dev,
+					    array_size(ngroups, sizeof(const char *)),
 					    GFP_KERNEL);
 		group = func->groups;
 		for_each_set_bit(bit, &mask_cpy, mask_len) {
@@ -359,7 +360,7 @@ static void axp20x_build_funcs_groups(struct platform_device *pdev)
 	for (i = 0; i <= AXP20X_FUNC_GPIO_IN; i++) {
 		pctl->funcs[i].ngroups = npins;
 		pctl->funcs[i].groups = devm_kzalloc(&pdev->dev,
-						     npins * sizeof(char *),
+						     array_size(npins, sizeof(char *)),
 						     GFP_KERNEL);
 		for (pin = 0; pin < npins; pin++)
 			pctl->funcs[i].groups[pin] = pctl->desc->pins[pin].name;
diff --git a/drivers/pinctrl/pinctrl-digicolor.c b/drivers/pinctrl/pinctrl-digicolor.c
index ce269ced4d49..eeaa231e178b 100644
--- a/drivers/pinctrl/pinctrl-digicolor.c
+++ b/drivers/pinctrl/pinctrl-digicolor.c
@@ -291,10 +291,11 @@ static int dc_pinctrl_probe(struct platform_device *pdev)
 	if (IS_ERR(pmap->regs))
 		return PTR_ERR(pmap->regs);
 
-	pins = devm_kzalloc(&pdev->dev, sizeof(*pins)*PINS_COUNT, GFP_KERNEL);
+	pins = devm_kzalloc(&pdev->dev, array_size(PINS_COUNT, sizeof(*pins)),
+			    GFP_KERNEL);
 	if (!pins)
 		return -ENOMEM;
-	pin_names = devm_kzalloc(&pdev->dev, name_len * PINS_COUNT,
+	pin_names = devm_kzalloc(&pdev->dev, array_size(PINS_COUNT, name_len),
 				 GFP_KERNEL);
 	if (!pin_names)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/pinctrl-lpc18xx.c b/drivers/pinctrl/pinctrl-lpc18xx.c
index d090f37ca4a1..e15312add697 100644
--- a/drivers/pinctrl/pinctrl-lpc18xx.c
+++ b/drivers/pinctrl/pinctrl-lpc18xx.c
@@ -1308,8 +1308,9 @@ static int lpc18xx_create_group_func_map(struct device *dev,
 		}
 
 		scu->func[func].ngroups = ngroups;
-		scu->func[func].groups = devm_kzalloc(dev, ngroups *
-						      sizeof(char *), GFP_KERNEL);
+		scu->func[func].groups = devm_kzalloc(dev,
+						      array_size(ngroups, sizeof(char *)),
+						      GFP_KERNEL);
 		if (!scu->func[func].groups)
 			return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-ocelot.c b/drivers/pinctrl/pinctrl-ocelot.c
index b5b3547fdcb2..6bac629c57a7 100644
--- a/drivers/pinctrl/pinctrl-ocelot.c
+++ b/drivers/pinctrl/pinctrl-ocelot.c
@@ -330,9 +330,9 @@ static int ocelot_create_group_func_map(struct device *dev,
 		}
 
 		info->func[f].ngroups = npins;
-		info->func[f].groups = devm_kzalloc(dev, npins *
-							 sizeof(char *),
-							 GFP_KERNEL);
+		info->func[f].groups = devm_kzalloc(dev,
+						    array_size(npins, sizeof(char *)),
+						    GFP_KERNEL);
 		if (!info->func[f].groups)
 			return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-rockchip.c b/drivers/pinctrl/pinctrl-rockchip.c
index 3924779f5578..5f9e3e3b598c 100644
--- a/drivers/pinctrl/pinctrl-rockchip.c
+++ b/drivers/pinctrl/pinctrl-rockchip.c
@@ -506,8 +506,9 @@ static int rockchip_dt_node_to_map(struct pinctrl_dev *pctldev,
 	}
 
 	map_num += grp->npins;
-	new_map = devm_kzalloc(pctldev->dev, sizeof(*new_map) * map_num,
-								GFP_KERNEL);
+	new_map = devm_kzalloc(pctldev->dev,
+			       array_size(map_num, sizeof(*new_map)),
+			       GFP_KERNEL);
 	if (!new_map)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-single.c b/drivers/pinctrl/pinctrl-single.c
index a7c5eb39b1eb..d773f9cbef4f 100644
--- a/drivers/pinctrl/pinctrl-single.c
+++ b/drivers/pinctrl/pinctrl-single.c
@@ -710,8 +710,8 @@ static int pcs_allocate_pin_table(struct pcs_device *pcs)
 
 	dev_dbg(pcs->dev, "allocating %i pins\n", nr_pins);
 	pcs->pins.pa = devm_kzalloc(pcs->dev,
-				sizeof(*pcs->pins.pa) * nr_pins,
-				GFP_KERNEL);
+				    array_size(nr_pins, sizeof(*pcs->pins.pa)),
+				    GFP_KERNEL);
 	if (!pcs->pins.pa)
 		return -ENOMEM;
 
@@ -922,14 +922,15 @@ static int pcs_parse_pinconf(struct pcs_device *pcs, struct device_node *np,
 		return 0;
 
 	func->conf = devm_kzalloc(pcs->dev,
-				  sizeof(struct pcs_conf_vals) * nconfs,
+				  array_size(nconfs, sizeof(struct pcs_conf_vals)),
 				  GFP_KERNEL);
 	if (!func->conf)
 		return -ENOMEM;
 	func->nconfs = nconfs;
 	conf = &(func->conf[0]);
 	m++;
-	settings = devm_kzalloc(pcs->dev, sizeof(unsigned long) * nconfs,
+	settings = devm_kzalloc(pcs->dev,
+				array_size(nconfs, sizeof(unsigned long)),
 				GFP_KERNEL);
 	if (!settings)
 		return -ENOMEM;
@@ -985,11 +986,13 @@ static int pcs_parse_one_pinctrl_entry(struct pcs_device *pcs,
 		return -EINVAL;
 	}
 
-	vals = devm_kzalloc(pcs->dev, sizeof(*vals) * rows, GFP_KERNEL);
+	vals = devm_kzalloc(pcs->dev, array_size(rows, sizeof(*vals)),
+			    GFP_KERNEL);
 	if (!vals)
 		return -ENOMEM;
 
-	pins = devm_kzalloc(pcs->dev, sizeof(*pins) * rows, GFP_KERNEL);
+	pins = devm_kzalloc(pcs->dev, array_size(rows, sizeof(*pins)),
+			    GFP_KERNEL);
 	if (!pins)
 		goto free_vals;
 
@@ -1086,13 +1089,15 @@ static int pcs_parse_bits_in_pinctrl_entry(struct pcs_device *pcs,
 
 	npins_in_row = pcs->width / pcs->bits_per_pin;
 
-	vals = devm_kzalloc(pcs->dev, sizeof(*vals) * rows * npins_in_row,
-			GFP_KERNEL);
+	vals = devm_kzalloc(pcs->dev,
+			    array3_size(rows, npins_in_row, sizeof(*vals)),
+			    GFP_KERNEL);
 	if (!vals)
 		return -ENOMEM;
 
-	pins = devm_kzalloc(pcs->dev, sizeof(*pins) * rows * npins_in_row,
-			GFP_KERNEL);
+	pins = devm_kzalloc(pcs->dev,
+			    array3_size(rows, npins_in_row, sizeof(*pins)),
+			    GFP_KERNEL);
 	if (!pins)
 		goto free_vals;
 
@@ -1214,7 +1219,8 @@ static int pcs_dt_node_to_map(struct pinctrl_dev *pctldev,
 	pcs = pinctrl_dev_get_drvdata(pctldev);
 
 	/* create 2 maps. One is for pinmux, and the other is for pinconf. */
-	*map = devm_kzalloc(pcs->dev, sizeof(**map) * 2, GFP_KERNEL);
+	*map = devm_kzalloc(pcs->dev, array_size(2, sizeof(**map)),
+			    GFP_KERNEL);
 	if (!*map)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-st.c b/drivers/pinctrl/pinctrl-st.c
index 2081c67667a8..342fb4627006 100644
--- a/drivers/pinctrl/pinctrl-st.c
+++ b/drivers/pinctrl/pinctrl-st.c
@@ -824,7 +824,8 @@ static int st_pctl_dt_node_to_map(struct pinctrl_dev *pctldev,
 
 	map_num = grp->npins + 1;
 	new_map = devm_kzalloc(pctldev->dev,
-				sizeof(*new_map) * map_num, GFP_KERNEL);
+			       array_size(map_num, sizeof(*new_map)),
+			       GFP_KERNEL);
 	if (!new_map)
 		return -ENOMEM;
 
@@ -1191,9 +1192,11 @@ static int st_pctl_dt_parse_groups(struct device_node *np,
 
 	grp->npins = npins;
 	grp->name = np->name;
-	grp->pins = devm_kzalloc(info->dev, npins * sizeof(u32), GFP_KERNEL);
+	grp->pins = devm_kzalloc(info->dev, array_size(npins, sizeof(u32)),
+				 GFP_KERNEL);
 	grp->pin_conf = devm_kzalloc(info->dev,
-					npins * sizeof(*conf), GFP_KERNEL);
+				     array_size(npins, sizeof(*conf)),
+				     GFP_KERNEL);
 
 	if (!grp->pins || !grp->pin_conf)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/samsung/pinctrl-exynos5440.c b/drivers/pinctrl/samsung/pinctrl-exynos5440.c
index 832ba81e192e..3a962c3ae3f4 100644
--- a/drivers/pinctrl/samsung/pinctrl-exynos5440.c
+++ b/drivers/pinctrl/samsung/pinctrl-exynos5440.c
@@ -666,13 +666,15 @@ static int exynos5440_pinctrl_parse_dt(struct platform_device *pdev,
 	if (!grp_cnt)
 		return -EINVAL;
 
-	groups = devm_kzalloc(dev, grp_cnt * sizeof(*groups), GFP_KERNEL);
+	groups = devm_kzalloc(dev, array_size(grp_cnt, sizeof(*groups)),
+			      GFP_KERNEL);
 	if (!groups)
 		return -EINVAL;
 
 	grp = groups;
 
-	functions = devm_kzalloc(dev, grp_cnt * sizeof(*functions), GFP_KERNEL);
+	functions = devm_kzalloc(dev, array_size(grp_cnt, sizeof(*functions)),
+				 GFP_KERNEL);
 	if (!functions)
 		return -EINVAL;
 
@@ -754,8 +756,9 @@ static int exynos5440_pinctrl_register(struct platform_device *pdev,
 	ctrldesc->pmxops = &exynos5440_pinmux_ops;
 	ctrldesc->confops = &exynos5440_pinconf_ops;
 
-	pindesc = devm_kzalloc(&pdev->dev, sizeof(*pindesc) *
-				EXYNOS5440_MAX_PINS, GFP_KERNEL);
+	pindesc = devm_kzalloc(&pdev->dev,
+			       array_size(EXYNOS5440_MAX_PINS, sizeof(*pindesc)),
+			       GFP_KERNEL);
 	if (!pindesc)
 		return -ENOMEM;
 	ctrldesc->pins = pindesc;
@@ -909,8 +912,9 @@ static int exynos5440_gpio_irq_init(struct platform_device *pdev,
 	struct exynos5440_gpio_intr_data *intd;
 	int i, irq, ret;
 
-	intd = devm_kzalloc(dev, sizeof(*intd) * EXYNOS5440_MAX_GPIO_INT,
-					GFP_KERNEL);
+	intd = devm_kzalloc(dev,
+			    array_size(EXYNOS5440_MAX_GPIO_INT, sizeof(*intd)),
+			    GFP_KERNEL);
 	if (!intd)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/samsung/pinctrl-samsung.c b/drivers/pinctrl/samsung/pinctrl-samsung.c
index 336e88d7bdb9..dd9b17e1fbba 100644
--- a/drivers/pinctrl/samsung/pinctrl-samsung.c
+++ b/drivers/pinctrl/samsung/pinctrl-samsung.c
@@ -682,7 +682,8 @@ static int samsung_pinctrl_create_function(struct device *dev,
 
 	func->name = func_np->full_name;
 
-	func->groups = devm_kzalloc(dev, npins * sizeof(char *), GFP_KERNEL);
+	func->groups = devm_kzalloc(dev, array_size(npins, sizeof(char *)),
+				    GFP_KERNEL);
 	if (!func->groups)
 		return -ENOMEM;
 
@@ -739,8 +740,9 @@ static struct samsung_pmx_func *samsung_pinctrl_create_functions(
 		}
 	}
 
-	functions = devm_kzalloc(dev, func_cnt * sizeof(*functions),
-					GFP_KERNEL);
+	functions = devm_kzalloc(dev,
+				 array_size(func_cnt, sizeof(*functions)),
+				 GFP_KERNEL);
 	if (!functions)
 		return ERR_PTR(-ENOMEM);
 	func = functions;
diff --git a/drivers/pinctrl/sh-pfc/core.c b/drivers/pinctrl/sh-pfc/core.c
index 74861b7b5b0d..108dd21d08a6 100644
--- a/drivers/pinctrl/sh-pfc/core.c
+++ b/drivers/pinctrl/sh-pfc/core.c
@@ -57,7 +57,8 @@ static int sh_pfc_map_resources(struct sh_pfc *pfc,
 		return -EINVAL;
 
 	/* Allocate memory windows and IRQs arrays. */
-	windows = devm_kzalloc(pfc->dev, num_windows * sizeof(*windows),
+	windows = devm_kzalloc(pfc->dev,
+			       array_size(num_windows, sizeof(*windows)),
 			       GFP_KERNEL);
 	if (windows == NULL)
 		return -ENOMEM;
@@ -66,7 +67,8 @@ static int sh_pfc_map_resources(struct sh_pfc *pfc,
 	pfc->windows = windows;
 
 	if (num_irqs) {
-		irqs = devm_kzalloc(pfc->dev, num_irqs * sizeof(*irqs),
+		irqs = devm_kzalloc(pfc->dev,
+				    array_size(num_irqs, sizeof(*irqs)),
 				    GFP_KERNEL);
 		if (irqs == NULL)
 			return -ENOMEM;
@@ -444,7 +446,8 @@ static int sh_pfc_init_ranges(struct sh_pfc *pfc)
 	}
 
 	pfc->nr_ranges = nr_ranges;
-	pfc->ranges = devm_kzalloc(pfc->dev, sizeof(*pfc->ranges) * nr_ranges,
+	pfc->ranges = devm_kzalloc(pfc->dev,
+				   array_size(nr_ranges, sizeof(*pfc->ranges)),
 				   GFP_KERNEL);
 	if (pfc->ranges == NULL)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/sh-pfc/gpio.c b/drivers/pinctrl/sh-pfc/gpio.c
index 946d9be50b62..fe9b20cb7612 100644
--- a/drivers/pinctrl/sh-pfc/gpio.c
+++ b/drivers/pinctrl/sh-pfc/gpio.c
@@ -107,7 +107,8 @@ static int gpio_setup_data_regs(struct sh_pfc_chip *chip)
 	for (i = 0; pfc->info->data_regs[i].reg_width; ++i)
 		;
 
-	chip->regs = devm_kzalloc(pfc->dev, i * sizeof(*chip->regs),
+	chip->regs = devm_kzalloc(pfc->dev,
+				  array_size(i, sizeof(*chip->regs)),
 				  GFP_KERNEL);
 	if (chip->regs == NULL)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/ti/pinctrl-ti-iodelay.c b/drivers/pinctrl/ti/pinctrl-ti-iodelay.c
index a8a6510183b6..f77a7d124a75 100644
--- a/drivers/pinctrl/ti/pinctrl-ti-iodelay.c
+++ b/drivers/pinctrl/ti/pinctrl-ti-iodelay.c
@@ -510,11 +510,13 @@ static int ti_iodelay_dt_node_to_map(struct pinctrl_dev *pctldev,
 		goto free_map;
 	}
 
-	pins = devm_kzalloc(iod->dev, sizeof(*pins) * rows, GFP_KERNEL);
+	pins = devm_kzalloc(iod->dev, array_size(rows, sizeof(*pins)),
+			    GFP_KERNEL);
 	if (!pins)
 		goto free_group;
 
-	cfg = devm_kzalloc(iod->dev, sizeof(*cfg) * rows, GFP_KERNEL);
+	cfg = devm_kzalloc(iod->dev, array_size(rows, sizeof(*cfg)),
+			   GFP_KERNEL);
 	if (!cfg) {
 		error = -ENOMEM;
 		goto free_pins;
@@ -749,7 +751,8 @@ static int ti_iodelay_alloc_pins(struct device *dev,
 	nr_pins = ti_iodelay_offset_to_pin(iod, r->regmap_config->max_register);
 	dev_dbg(dev, "Allocating %i pins\n", nr_pins);
 
-	iod->pa = devm_kzalloc(dev, sizeof(*iod->pa) * nr_pins, GFP_KERNEL);
+	iod->pa = devm_kzalloc(dev, array_size(nr_pins, sizeof(*iod->pa)),
+			       GFP_KERNEL);
 	if (!iod->pa)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/zte/pinctrl-zx.c b/drivers/pinctrl/zte/pinctrl-zx.c
index ded366bb6564..f9fd665529c2 100644
--- a/drivers/pinctrl/zte/pinctrl-zx.c
+++ b/drivers/pinctrl/zte/pinctrl-zx.c
@@ -277,7 +277,8 @@ static int zx_pinctrl_build_state(struct platform_device *pdev)
 
 	/* Every single pin composes a group */
 	ngroups = info->npins;
-	groups = devm_kzalloc(&pdev->dev, ngroups * sizeof(*groups),
+	groups = devm_kzalloc(&pdev->dev,
+			      array_size(ngroups, sizeof(*groups)),
 			      GFP_KERNEL);
 	if (!groups)
 		return -ENOMEM;
diff --git a/drivers/platform/mellanox/mlxreg-hotplug.c b/drivers/platform/mellanox/mlxreg-hotplug.c
index ea9e7f4479ca..fe6770c5d793 100644
--- a/drivers/platform/mellanox/mlxreg-hotplug.c
+++ b/drivers/platform/mellanox/mlxreg-hotplug.c
@@ -217,8 +217,8 @@ static int mlxreg_hotplug_attr_init(struct mlxreg_hotplug_priv_data *priv)
 		}
 	}
 
-	priv->group.attrs = devm_kzalloc(&priv->pdev->dev, num_attrs *
-					 sizeof(struct attribute *),
+	priv->group.attrs = devm_kzalloc(&priv->pdev->dev,
+					 array_size(num_attrs, sizeof(struct attribute *)),
 					 GFP_KERNEL);
 	if (!priv->group.attrs)
 		return -ENOMEM;
diff --git a/drivers/pwm/pwm-lp3943.c b/drivers/pwm/pwm-lp3943.c
index 52584e9962ed..1129fad706d9 100644
--- a/drivers/pwm/pwm-lp3943.c
+++ b/drivers/pwm/pwm-lp3943.c
@@ -225,7 +225,8 @@ static int lp3943_pwm_parse_dt(struct device *dev,
 		if (num_outputs == 0)
 			continue;
 
-		output = devm_kzalloc(dev, sizeof(*output) * num_outputs,
+		output = devm_kzalloc(dev,
+				      array_size(num_outputs, sizeof(*output)),
 				      GFP_KERNEL);
 		if (!output)
 			return -ENOMEM;
diff --git a/drivers/regulator/act8865-regulator.c b/drivers/regulator/act8865-regulator.c
index 7652477e6a9d..ab6443b087ea 100644
--- a/drivers/regulator/act8865-regulator.c
+++ b/drivers/regulator/act8865-regulator.c
@@ -425,8 +425,8 @@ static int act8865_pdata_from_dt(struct device *dev,
 		return matched;
 
 	pdata->regulators = devm_kzalloc(dev,
-					 sizeof(struct act8865_regulator_data) *
-					 num_matches, GFP_KERNEL);
+					 array_size(num_matches, sizeof(struct act8865_regulator_data)),
+					 GFP_KERNEL);
 	if (!pdata->regulators)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/as3711-regulator.c b/drivers/regulator/as3711-regulator.c
index 874d415d6b4f..6b23a8fde872 100644
--- a/drivers/regulator/as3711-regulator.c
+++ b/drivers/regulator/as3711-regulator.c
@@ -239,8 +239,9 @@ static int as3711_regulator_probe(struct platform_device *pdev)
 		}
 	}
 
-	regs = devm_kzalloc(&pdev->dev, AS3711_REGULATOR_NUM *
-			sizeof(struct as3711_regulator), GFP_KERNEL);
+	regs = devm_kzalloc(&pdev->dev,
+			    array_size(AS3711_REGULATOR_NUM, sizeof(struct as3711_regulator)),
+			    GFP_KERNEL);
 	if (!regs)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/bcm590xx-regulator.c b/drivers/regulator/bcm590xx-regulator.c
index 9dd715407b39..19cdec081a9a 100644
--- a/drivers/regulator/bcm590xx-regulator.c
+++ b/drivers/regulator/bcm590xx-regulator.c
@@ -383,8 +383,9 @@ static int bcm590xx_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, pmu);
 
-	pmu->desc = devm_kzalloc(&pdev->dev, BCM590XX_NUM_REGS *
-			sizeof(struct regulator_desc), GFP_KERNEL);
+	pmu->desc = devm_kzalloc(&pdev->dev,
+				 array_size(BCM590XX_NUM_REGS, sizeof(struct regulator_desc)),
+				 GFP_KERNEL);
 	if (!pmu->desc)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/da9063-regulator.c b/drivers/regulator/da9063-regulator.c
index 6a8f9cd69f52..5bedf1a182ab 100644
--- a/drivers/regulator/da9063-regulator.c
+++ b/drivers/regulator/da9063-regulator.c
@@ -682,8 +682,8 @@ static struct da9063_regulators_pdata *da9063_parse_regulators_dt(
 		return ERR_PTR(-ENOMEM);
 
 	pdata->regulator_data = devm_kzalloc(&pdev->dev,
-					num * sizeof(*pdata->regulator_data),
-					GFP_KERNEL);
+					     array_size(num, sizeof(*pdata->regulator_data)),
+					     GFP_KERNEL);
 	if (!pdata->regulator_data)
 		return ERR_PTR(-ENOMEM);
 	pdata->n_regulators = num;
diff --git a/drivers/regulator/max1586.c b/drivers/regulator/max1586.c
index 66bbaa999433..40c5e8a1da47 100644
--- a/drivers/regulator/max1586.c
+++ b/drivers/regulator/max1586.c
@@ -194,8 +194,9 @@ static int of_get_max1586_platform_data(struct device *dev,
 	if (matched <= 0)
 		return matched;
 
-	pdata->subdevs = devm_kzalloc(dev, sizeof(struct max1586_subdev_data) *
-						matched, GFP_KERNEL);
+	pdata->subdevs = devm_kzalloc(dev,
+				      array_size(matched, sizeof(struct max1586_subdev_data)),
+				      GFP_KERNEL);
 	if (!pdata->subdevs)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/max8660.c b/drivers/regulator/max8660.c
index a6183425f27d..f0e88e0f9b10 100644
--- a/drivers/regulator/max8660.c
+++ b/drivers/regulator/max8660.c
@@ -351,8 +351,9 @@ static int max8660_pdata_from_dt(struct device *dev,
 	if (matched <= 0)
 		return matched;
 
-	pdata->subdevs = devm_kzalloc(dev, sizeof(struct max8660_subdev_data) *
-						matched, GFP_KERNEL);
+	pdata->subdevs = devm_kzalloc(dev,
+				      array_size(matched, sizeof(struct max8660_subdev_data)),
+				      GFP_KERNEL);
 	if (!pdata->subdevs)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/pbias-regulator.c b/drivers/regulator/pbias-regulator.c
index 8f782d22fdbe..750d06a9f61a 100644
--- a/drivers/regulator/pbias-regulator.c
+++ b/drivers/regulator/pbias-regulator.c
@@ -173,8 +173,9 @@ static int pbias_regulator_probe(struct platform_device *pdev)
 	if (count < 0)
 		return count;
 
-	drvdata = devm_kzalloc(&pdev->dev, sizeof(struct pbias_regulator_data)
-			       * count, GFP_KERNEL);
+	drvdata = devm_kzalloc(&pdev->dev,
+			       array_size(count, sizeof(struct pbias_regulator_data)),
+			       GFP_KERNEL);
 	if (!drvdata)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/rc5t583-regulator.c b/drivers/regulator/rc5t583-regulator.c
index d0f1340168b1..70551a66aaa1 100644
--- a/drivers/regulator/rc5t583-regulator.c
+++ b/drivers/regulator/rc5t583-regulator.c
@@ -132,8 +132,9 @@ static int rc5t583_regulator_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	regs = devm_kzalloc(&pdev->dev, RC5T583_REGULATOR_MAX *
-			sizeof(struct rc5t583_regulator), GFP_KERNEL);
+	regs = devm_kzalloc(&pdev->dev,
+			    array_size(RC5T583_REGULATOR_MAX, sizeof(struct rc5t583_regulator)),
+			    GFP_KERNEL);
 	if (!regs)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/s2mps11.c b/drivers/regulator/s2mps11.c
index afc6518b3680..ec8913380cc4 100644
--- a/drivers/regulator/s2mps11.c
+++ b/drivers/regulator/s2mps11.c
@@ -1140,8 +1140,8 @@ static int s2mps11_pmic_probe(struct platform_device *pdev)
 	}
 
 	s2mps11->ext_control_gpio = devm_kmalloc(&pdev->dev,
-			sizeof(*s2mps11->ext_control_gpio) * rdev_num,
-			GFP_KERNEL);
+						 array_size(rdev_num, sizeof(*s2mps11->ext_control_gpio)),
+						 GFP_KERNEL);
 	if (!s2mps11->ext_control_gpio)
 		return -ENOMEM;
 	/*
diff --git a/drivers/regulator/ti-abb-regulator.c b/drivers/regulator/ti-abb-regulator.c
index d2f994298753..e46937f7eb0e 100644
--- a/drivers/regulator/ti-abb-regulator.c
+++ b/drivers/regulator/ti-abb-regulator.c
@@ -532,13 +532,15 @@ static int ti_abb_init_table(struct device *dev, struct ti_abb *abb,
 	}
 	num_entries /= num_values;
 
-	info = devm_kzalloc(dev, sizeof(*info) * num_entries, GFP_KERNEL);
+	info = devm_kzalloc(dev, array_size(num_entries, sizeof(*info)),
+			    GFP_KERNEL);
 	if (!info)
 		return -ENOMEM;
 
 	abb->info = info;
 
-	volt_table = devm_kzalloc(dev, sizeof(unsigned int) * num_entries,
+	volt_table = devm_kzalloc(dev,
+				  array_size(num_entries, sizeof(unsigned int)),
 				  GFP_KERNEL);
 	if (!volt_table)
 		return -ENOMEM;
diff --git a/drivers/regulator/tps65090-regulator.c b/drivers/regulator/tps65090-regulator.c
index 395f35dc8cdb..d68086912942 100644
--- a/drivers/regulator/tps65090-regulator.c
+++ b/drivers/regulator/tps65090-regulator.c
@@ -351,8 +351,9 @@ static struct tps65090_platform_data *tps65090_parse_dt_reg_data(
 	if (!tps65090_pdata)
 		return ERR_PTR(-ENOMEM);
 
-	reg_pdata = devm_kzalloc(&pdev->dev, TPS65090_REGULATOR_MAX *
-				sizeof(*reg_pdata), GFP_KERNEL);
+	reg_pdata = devm_kzalloc(&pdev->dev,
+				 array_size(TPS65090_REGULATOR_MAX, sizeof(*reg_pdata)),
+				 GFP_KERNEL);
 	if (!reg_pdata)
 		return ERR_PTR(-ENOMEM);
 
@@ -432,8 +433,9 @@ static int tps65090_regulator_probe(struct platform_device *pdev)
 		return tps65090_pdata ? PTR_ERR(tps65090_pdata) : -EINVAL;
 	}
 
-	pmic = devm_kzalloc(&pdev->dev, TPS65090_REGULATOR_MAX * sizeof(*pmic),
-			GFP_KERNEL);
+	pmic = devm_kzalloc(&pdev->dev,
+			    array_size(TPS65090_REGULATOR_MAX, sizeof(*pmic)),
+			    GFP_KERNEL);
 	if (!pmic)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/tps65217-regulator.c b/drivers/regulator/tps65217-regulator.c
index 7b12e880d1ea..e865895c8ab5 100644
--- a/drivers/regulator/tps65217-regulator.c
+++ b/drivers/regulator/tps65217-regulator.c
@@ -229,8 +229,9 @@ static int tps65217_regulator_probe(struct platform_device *pdev)
 	unsigned int val;
 
 	/* Allocate memory for strobes */
-	tps->strobes = devm_kzalloc(&pdev->dev, sizeof(u8) *
-				    TPS65217_NUM_REGULATOR, GFP_KERNEL);
+	tps->strobes = devm_kzalloc(&pdev->dev,
+				    array_size(TPS65217_NUM_REGULATOR, sizeof(u8)),
+				    GFP_KERNEL);
 
 	platform_set_drvdata(pdev, tps);
 
diff --git a/drivers/regulator/tps65218-regulator.c b/drivers/regulator/tps65218-regulator.c
index 1827185beacc..f8056fb5a41c 100644
--- a/drivers/regulator/tps65218-regulator.c
+++ b/drivers/regulator/tps65218-regulator.c
@@ -324,8 +324,9 @@ static int tps65218_regulator_probe(struct platform_device *pdev)
 	config.regmap = tps->regmap;
 
 	/* Allocate memory for strobes */
-	tps->strobes = devm_kzalloc(&pdev->dev, sizeof(u8) *
-				    TPS65218_NUM_REGULATOR, GFP_KERNEL);
+	tps->strobes = devm_kzalloc(&pdev->dev,
+				    array_size(TPS65218_NUM_REGULATOR, sizeof(u8)),
+				    GFP_KERNEL);
 	if (!tps->strobes)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/tps80031-regulator.c b/drivers/regulator/tps80031-regulator.c
index d4cc60ad18ae..f5a4647e67cb 100644
--- a/drivers/regulator/tps80031-regulator.c
+++ b/drivers/regulator/tps80031-regulator.c
@@ -692,7 +692,8 @@ static int tps80031_regulator_probe(struct platform_device *pdev)
 	}
 
 	pmic = devm_kzalloc(&pdev->dev,
-			TPS80031_REGULATOR_MAX * sizeof(*pmic), GFP_KERNEL);
+			    array_size(TPS80031_REGULATOR_MAX, sizeof(*pmic)),
+			    GFP_KERNEL);
 	if (!pmic)
 		return -ENOMEM;
 
diff --git a/drivers/reset/reset-ti-syscon.c b/drivers/reset/reset-ti-syscon.c
index 99520b0a1329..3f3cc2567363 100644
--- a/drivers/reset/reset-ti-syscon.c
+++ b/drivers/reset/reset-ti-syscon.c
@@ -189,7 +189,9 @@ static int ti_syscon_reset_probe(struct platform_device *pdev)
 	}
 
 	nr_controls = (size / sizeof(*list)) / 7;
-	controls = devm_kzalloc(dev, nr_controls * sizeof(*controls), GFP_KERNEL);
+	controls = devm_kzalloc(dev,
+				array_size(nr_controls, sizeof(*controls)),
+				GFP_KERNEL);
 	if (!controls)
 		return -ENOMEM;
 
diff --git a/drivers/scsi/isci/init.c b/drivers/scsi/isci/init.c
index 922e3e56c90d..8b64c5831e8a 100644
--- a/drivers/scsi/isci/init.c
+++ b/drivers/scsi/isci/init.c
@@ -233,13 +233,13 @@ static int isci_register_sas_ha(struct isci_host *isci_host)
 	struct asd_sas_port **sas_ports;
 
 	sas_phys = devm_kzalloc(&isci_host->pdev->dev,
-				SCI_MAX_PHYS * sizeof(void *),
+				array_size(SCI_MAX_PHYS, sizeof(void *)),
 				GFP_KERNEL);
 	if (!sas_phys)
 		return -ENOMEM;
 
 	sas_ports = devm_kzalloc(&isci_host->pdev->dev,
-				 SCI_MAX_PORTS * sizeof(void *),
+				 array_size(SCI_MAX_PORTS, sizeof(void *)),
 				 GFP_KERNEL);
 	if (!sas_ports)
 		return -ENOMEM;
diff --git a/drivers/scsi/ufs/ufshcd-pltfrm.c b/drivers/scsi/ufs/ufshcd-pltfrm.c
index e82bde077296..024bdf2449be 100644
--- a/drivers/scsi/ufs/ufshcd-pltfrm.c
+++ b/drivers/scsi/ufs/ufshcd-pltfrm.c
@@ -86,8 +86,8 @@ static int ufshcd_parse_clock_info(struct ufs_hba *hba)
 		goto out;
 	}
 
-	clkfreq = devm_kzalloc(dev, sz * sizeof(*clkfreq),
-			GFP_KERNEL);
+	clkfreq = devm_kzalloc(dev, array_size(sz, sizeof(*clkfreq)),
+			       GFP_KERNEL);
 	if (!clkfreq) {
 		ret = -ENOMEM;
 		goto out;
diff --git a/drivers/soc/bcm/raspberrypi-power.c b/drivers/soc/bcm/raspberrypi-power.c
index fe96a8b956fb..d7fd987a8e42 100644
--- a/drivers/soc/bcm/raspberrypi-power.c
+++ b/drivers/soc/bcm/raspberrypi-power.c
@@ -165,8 +165,9 @@ static int rpi_power_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	rpi_domains->xlate.domains =
-		devm_kzalloc(dev, sizeof(*rpi_domains->xlate.domains) *
-			     RPI_POWER_DOMAIN_COUNT, GFP_KERNEL);
+		devm_kzalloc(dev,
+			     array_size(RPI_POWER_DOMAIN_COUNT, sizeof(*rpi_domains->xlate.domains)),
+			     GFP_KERNEL);
 	if (!rpi_domains->xlate.domains)
 		return -ENOMEM;
 
diff --git a/drivers/soc/mediatek/mtk-scpsys.c b/drivers/soc/mediatek/mtk-scpsys.c
index d762a46d434f..be1e3a80260a 100644
--- a/drivers/soc/mediatek/mtk-scpsys.c
+++ b/drivers/soc/mediatek/mtk-scpsys.c
@@ -408,14 +408,16 @@ static struct scp *init_scp(struct platform_device *pdev,
 		return ERR_CAST(scp->base);
 
 	scp->domains = devm_kzalloc(&pdev->dev,
-				sizeof(*scp->domains) * num, GFP_KERNEL);
+				    array_size(num, sizeof(*scp->domains)),
+				    GFP_KERNEL);
 	if (!scp->domains)
 		return ERR_PTR(-ENOMEM);
 
 	pd_data = &scp->pd_data;
 
 	pd_data->domains = devm_kzalloc(&pdev->dev,
-			sizeof(*pd_data->domains) * num, GFP_KERNEL);
+					array_size(num, sizeof(*pd_data->domains)),
+					GFP_KERNEL);
 	if (!pd_data->domains)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/soc/ti/knav_qmss_acc.c b/drivers/soc/ti/knav_qmss_acc.c
index 3d7225f4e77f..91a3511155d2 100644
--- a/drivers/soc/ti/knav_qmss_acc.c
+++ b/drivers/soc/ti/knav_qmss_acc.c
@@ -406,7 +406,8 @@ static int knav_acc_init_queue(struct knav_range_info *range,
 	unsigned id = kq->id - range->queue_base;
 
 	kq->descs = devm_kzalloc(range->kdev->dev,
-				 ACC_DESCS_MAX * sizeof(u32), GFP_KERNEL);
+				 array_size(ACC_DESCS_MAX, sizeof(u32)),
+				 GFP_KERNEL);
 	if (!kq->descs)
 		return -ENOMEM;
 
@@ -552,7 +553,8 @@ int knav_init_acc_range(struct knav_device *kdev,
 	info->list_size = list_size;
 	mem_size   = PAGE_ALIGN(list_size * 2);
 	info->mem_size  = mem_size;
-	range->acc = devm_kzalloc(kdev->dev, channels * sizeof(*range->acc),
+	range->acc = devm_kzalloc(kdev->dev,
+				  array_size(channels, sizeof(*range->acc)),
 				  GFP_KERNEL);
 	if (!range->acc)
 		return -ENOMEM;
diff --git a/drivers/spi/spi-pl022.c b/drivers/spi/spi-pl022.c
index 4797c57f4263..885d7e5a31e0 100644
--- a/drivers/spi/spi-pl022.c
+++ b/drivers/spi/spi-pl022.c
@@ -2135,7 +2135,8 @@ static int pl022_probe(struct amba_device *adev, const struct amba_id *id)
 	pl022->master_info = platform_info;
 	pl022->adev = adev;
 	pl022->vendor = id->data;
-	pl022->chipselects = devm_kzalloc(dev, num_cs * sizeof(int),
+	pl022->chipselects = devm_kzalloc(dev,
+					  array_size(num_cs, sizeof(int)),
 					  GFP_KERNEL);
 	if (!pl022->chipselects) {
 		status = -ENOMEM;
diff --git a/drivers/staging/greybus/audio_topology.c b/drivers/staging/greybus/audio_topology.c
index de4b1b2b12f3..1044e510af03 100644
--- a/drivers/staging/greybus/audio_topology.c
+++ b/drivers/staging/greybus/audio_topology.c
@@ -144,7 +144,8 @@ static const char **gb_generate_enum_strings(struct gbaudio_module_info *gb,
 	__u8 *data;
 
 	items = le32_to_cpu(gbenum->items);
-	strings = devm_kzalloc(gb->dev, sizeof(char *) * items, GFP_KERNEL);
+	strings = devm_kzalloc(gb->dev, array_size(items, sizeof(char *)),
+			       GFP_KERNEL);
 	data = gbenum->names;
 
 	for (i = 0; i < items; i++) {
diff --git a/drivers/staging/media/imx/imx-media-dev.c b/drivers/staging/media/imx/imx-media-dev.c
index 289d775c4820..f2801e0c447c 100644
--- a/drivers/staging/media/imx/imx-media-dev.c
+++ b/drivers/staging/media/imx/imx-media-dev.c
@@ -544,7 +544,8 @@ static int imx_media_probe(struct platform_device *pdev)
 		goto unreg_dev;
 	}
 
-	subdevs = devm_kzalloc(imxmd->md.dev, sizeof(*subdevs) * num_subdevs,
+	subdevs = devm_kzalloc(imxmd->md.dev,
+			       array_size(num_subdevs, sizeof(*subdevs)),
 			       GFP_KERNEL);
 	if (!subdevs) {
 		ret = -ENOMEM;
diff --git a/drivers/thermal/thermal-generic-adc.c b/drivers/thermal/thermal-generic-adc.c
index 46d3005335c7..e29724b1adf7 100644
--- a/drivers/thermal/thermal-generic-adc.c
+++ b/drivers/thermal/thermal-generic-adc.c
@@ -87,8 +87,9 @@ static int gadc_thermal_read_linear_lookup_table(struct device *dev,
 		return -EINVAL;
 	}
 
-	gti->lookup_table = devm_kzalloc(dev, sizeof(*gti->lookup_table) *
-					 ntable, GFP_KERNEL);
+	gti->lookup_table = devm_kzalloc(dev,
+					 array_size(ntable, sizeof(*gti->lookup_table)),
+					 GFP_KERNEL);
 	if (!gti->lookup_table)
 		return -ENOMEM;
 
diff --git a/drivers/video/backlight/lp855x_bl.c b/drivers/video/backlight/lp855x_bl.c
index 939f057836e1..af3e3cc87493 100644
--- a/drivers/video/backlight/lp855x_bl.c
+++ b/drivers/video/backlight/lp855x_bl.c
@@ -374,7 +374,8 @@ static int lp855x_parse_dt(struct lp855x *lp)
 		struct device_node *child;
 		int i = 0;
 
-		rom = devm_kzalloc(dev, sizeof(*rom) * rom_length, GFP_KERNEL);
+		rom = devm_kzalloc(dev, array_size(rom_length, sizeof(*rom)),
+				   GFP_KERNEL);
 		if (!rom)
 			return -ENOMEM;
 
diff --git a/drivers/video/fbdev/au1100fb.c b/drivers/video/fbdev/au1100fb.c
index 7c9a672e9811..27f99e380735 100644
--- a/drivers/video/fbdev/au1100fb.c
+++ b/drivers/video/fbdev/au1100fb.c
@@ -501,7 +501,8 @@ static int au1100fb_drv_probe(struct platform_device *dev)
 	fbdev->info.fix = au1100fb_fix;
 
 	fbdev->info.pseudo_palette =
-		devm_kzalloc(&dev->dev, sizeof(u32) * 16, GFP_KERNEL);
+		devm_kzalloc(&dev->dev, array_size(16, sizeof(u32)),
+			     GFP_KERNEL);
 	if (!fbdev->info.pseudo_palette)
 		return -ENOMEM;
 
diff --git a/drivers/video/fbdev/mxsfb.c b/drivers/video/fbdev/mxsfb.c
index 246bea3a7d9b..21fc17081f59 100644
--- a/drivers/video/fbdev/mxsfb.c
+++ b/drivers/video/fbdev/mxsfb.c
@@ -931,7 +931,8 @@ static int mxsfb_probe(struct platform_device *pdev)
 	if (IS_ERR(host->reg_lcd))
 		host->reg_lcd = NULL;
 
-	fb_info->pseudo_palette = devm_kzalloc(&pdev->dev, sizeof(u32) * 16,
+	fb_info->pseudo_palette = devm_kzalloc(&pdev->dev,
+					       array_size(16, sizeof(u32)),
 					       GFP_KERNEL);
 	if (!fb_info->pseudo_palette) {
 		ret = -ENOMEM;
diff --git a/drivers/video/fbdev/omap2/omapfb/vrfb.c b/drivers/video/fbdev/omap2/omapfb/vrfb.c
index f346b02eee1d..c0b72e798074 100644
--- a/drivers/video/fbdev/omap2/omapfb/vrfb.c
+++ b/drivers/video/fbdev/omap2/omapfb/vrfb.c
@@ -360,8 +360,8 @@ static int __init vrfb_probe(struct platform_device *pdev)
 	num_ctxs = pdev->num_resources - 1;
 
 	ctxs = devm_kzalloc(&pdev->dev,
-			sizeof(struct vrfb_ctx) * num_ctxs,
-			GFP_KERNEL);
+			    array_size(num_ctxs, sizeof(struct vrfb_ctx)),
+			    GFP_KERNEL);
 
 	if (!ctxs)
 		return -ENOMEM;
diff --git a/fs/f2fs/checkpoint.c b/fs/f2fs/checkpoint.c
index bf779461df13..dfa11f47eda6 100644
--- a/fs/f2fs/checkpoint.c
+++ b/fs/f2fs/checkpoint.c
@@ -802,7 +802,8 @@ int get_valid_checkpoint(struct f2fs_sb_info *sbi)
 	block_t cp_blk_no;
 	int i;
 
-	sbi->ckpt = f2fs_kzalloc(sbi, cp_blks * blk_size, GFP_KERNEL);
+	sbi->ckpt = f2fs_kzalloc(sbi, array_size(blk_size, cp_blks),
+				 GFP_KERNEL);
 	if (!sbi->ckpt)
 		return -ENOMEM;
 	/*
diff --git a/fs/f2fs/segment.c b/fs/f2fs/segment.c
index 5854cc4e1d67..ae06ab1c387c 100644
--- a/fs/f2fs/segment.c
+++ b/fs/f2fs/segment.c
@@ -3564,7 +3564,8 @@ static int build_curseg(struct f2fs_sb_info *sbi)
 	struct curseg_info *array;
 	int i;
 
-	array = f2fs_kzalloc(sbi, sizeof(*array) * NR_CURSEG_TYPE, GFP_KERNEL);
+	array = f2fs_kzalloc(sbi, array_size(NR_CURSEG_TYPE, sizeof(*array)),
+			     GFP_KERNEL);
 	if (!array)
 		return -ENOMEM;
 
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 42d564c5ccd0..0cf47f3c149a 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -2359,8 +2359,9 @@ static int init_blkz_info(struct f2fs_sb_info *sbi, int devi)
 
 #define F2FS_REPORT_NR_ZONES   4096
 
-	zones = f2fs_kzalloc(sbi, sizeof(struct blk_zone) *
-				F2FS_REPORT_NR_ZONES, GFP_KERNEL);
+	zones = f2fs_kzalloc(sbi,
+			     array_size(F2FS_REPORT_NR_ZONES, sizeof(struct blk_zone)),
+			     GFP_KERNEL);
 	if (!zones)
 		return -ENOMEM;
 
@@ -2500,8 +2501,9 @@ static int f2fs_scan_devices(struct f2fs_sb_info *sbi)
 	 * Initialize multiple devices information, or single
 	 * zoned block device information.
 	 */
-	sbi->devs = f2fs_kzalloc(sbi, sizeof(struct f2fs_dev_info) *
-						max_devices, GFP_KERNEL);
+	sbi->devs = f2fs_kzalloc(sbi,
+				 array_size(max_devices, sizeof(struct f2fs_dev_info)),
+				 GFP_KERNEL);
 	if (!sbi->devs)
 		return -ENOMEM;
 
@@ -2724,8 +2726,8 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
 		int j;
 
 		sbi->write_io[i] = f2fs_kmalloc(sbi,
-					n * sizeof(struct f2fs_bio_info),
-					GFP_KERNEL);
+						array_size(n, sizeof(struct f2fs_bio_info)),
+						GFP_KERNEL);
 		if (!sbi->write_io[i]) {
 			err = -ENOMEM;
 			goto free_options;
diff --git a/sound/soc/au1x/dbdma2.c b/sound/soc/au1x/dbdma2.c
index fb650659c3a3..2b182e65e131 100644
--- a/sound/soc/au1x/dbdma2.c
+++ b/sound/soc/au1x/dbdma2.c
@@ -340,7 +340,7 @@ static int au1xpsc_pcm_drvprobe(struct platform_device *pdev)
 	struct au1xpsc_audio_dmadata *dmadata;
 
 	dmadata = devm_kzalloc(&pdev->dev,
-			       2 * sizeof(struct au1xpsc_audio_dmadata),
+			       array_size(2, sizeof(struct au1xpsc_audio_dmadata)),
 			       GFP_KERNEL);
 	if (!dmadata)
 		return -ENOMEM;
diff --git a/sound/soc/codecs/hdmi-codec.c b/sound/soc/codecs/hdmi-codec.c
index 6fa11888672d..cc17643fbcad 100644
--- a/sound/soc/codecs/hdmi-codec.c
+++ b/sound/soc/codecs/hdmi-codec.c
@@ -771,7 +771,8 @@ static int hdmi_codec_probe(struct platform_device *pdev)
 	hcp->hcd = *hcd;
 	mutex_init(&hcp->current_stream_lock);
 
-	hcp->daidrv = devm_kzalloc(dev, dai_count * sizeof(*hcp->daidrv),
+	hcp->daidrv = devm_kzalloc(dev,
+				   array_size(dai_count, sizeof(*hcp->daidrv)),
 				   GFP_KERNEL);
 	if (!hcp->daidrv)
 		return -ENOMEM;
diff --git a/sound/soc/codecs/rt5645.c b/sound/soc/codecs/rt5645.c
index bc8d829ce45b..3a76e6f6ba4f 100644
--- a/sound/soc/codecs/rt5645.c
+++ b/sound/soc/codecs/rt5645.c
@@ -3450,7 +3450,8 @@ static int rt5645_probe(struct snd_soc_component *component)
 		component->card->long_name = rt5645->pdata.long_name;
 
 	rt5645->eq_param = devm_kzalloc(component->dev,
-		RT5645_HWEQ_NUM * sizeof(struct rt5645_eq_param_s), GFP_KERNEL);
+					array_size(RT5645_HWEQ_NUM, sizeof(struct rt5645_eq_param_s)),
+					GFP_KERNEL);
 
 	return 0;
 }
diff --git a/sound/soc/generic/audio-graph-card.c b/sound/soc/generic/audio-graph-card.c
index 1b6164249341..529aa693644b 100644
--- a/sound/soc/generic/audio-graph-card.c
+++ b/sound/soc/generic/audio-graph-card.c
@@ -296,8 +296,10 @@ static int asoc_graph_card_probe(struct platform_device *pdev)
 	if (num == 0)
 		return -EINVAL;
 
-	dai_props = devm_kzalloc(dev, sizeof(*dai_props) * num, GFP_KERNEL);
-	dai_link  = devm_kzalloc(dev, sizeof(*dai_link)  * num, GFP_KERNEL);
+	dai_props = devm_kzalloc(dev, array_size(num, sizeof(*dai_props)),
+				 GFP_KERNEL);
+	dai_link  = devm_kzalloc(dev, array_size(num, sizeof(*dai_link)),
+				 GFP_KERNEL);
 	if (!dai_props || !dai_link)
 		return -ENOMEM;
 
diff --git a/sound/soc/generic/audio-graph-scu-card.c b/sound/soc/generic/audio-graph-scu-card.c
index a967aa143d51..e1f133563b6c 100644
--- a/sound/soc/generic/audio-graph-scu-card.c
+++ b/sound/soc/generic/audio-graph-scu-card.c
@@ -348,8 +348,10 @@ static int asoc_graph_card_probe(struct platform_device *pdev)
 	if (num == 0)
 		return -EINVAL;
 
-	dai_props = devm_kzalloc(dev, sizeof(*dai_props) * num, GFP_KERNEL);
-	dai_link  = devm_kzalloc(dev, sizeof(*dai_link)  * num, GFP_KERNEL);
+	dai_props = devm_kzalloc(dev, array_size(num, sizeof(*dai_props)),
+				 GFP_KERNEL);
+	dai_link  = devm_kzalloc(dev, array_size(num, sizeof(*dai_link)),
+				 GFP_KERNEL);
 	if (!dai_props || !dai_link)
 		return -ENOMEM;
 
diff --git a/sound/soc/generic/simple-card.c b/sound/soc/generic/simple-card.c
index 6959a74a6f49..c01a97ad724c 100644
--- a/sound/soc/generic/simple-card.c
+++ b/sound/soc/generic/simple-card.c
@@ -320,7 +320,8 @@ static int asoc_simple_card_parse_aux_devs(struct device_node *node,
 		return -EINVAL;
 
 	card->aux_dev = devm_kzalloc(dev,
-			n * sizeof(*card->aux_dev), GFP_KERNEL);
+				     array_size(n, sizeof(*card->aux_dev)),
+				     GFP_KERNEL);
 	if (!card->aux_dev)
 		return -ENOMEM;
 
@@ -414,8 +415,10 @@ static int asoc_simple_card_probe(struct platform_device *pdev)
 	if (!priv)
 		return -ENOMEM;
 
-	dai_props = devm_kzalloc(dev, sizeof(*dai_props) * num, GFP_KERNEL);
-	dai_link  = devm_kzalloc(dev, sizeof(*dai_link)  * num, GFP_KERNEL);
+	dai_props = devm_kzalloc(dev, array_size(num, sizeof(*dai_props)),
+				 GFP_KERNEL);
+	dai_link  = devm_kzalloc(dev, array_size(num, sizeof(*dai_link)),
+				 GFP_KERNEL);
 	if (!dai_props || !dai_link)
 		return -ENOMEM;
 
diff --git a/sound/soc/generic/simple-scu-card.c b/sound/soc/generic/simple-scu-card.c
index 48606c63562a..adad35b8c250 100644
--- a/sound/soc/generic/simple-scu-card.c
+++ b/sound/soc/generic/simple-scu-card.c
@@ -246,8 +246,10 @@ static int asoc_simple_card_probe(struct platform_device *pdev)
 
 	num = of_get_child_count(np);
 
-	dai_props = devm_kzalloc(dev, sizeof(*dai_props) * num, GFP_KERNEL);
-	dai_link  = devm_kzalloc(dev, sizeof(*dai_link)  * num, GFP_KERNEL);
+	dai_props = devm_kzalloc(dev, array_size(num, sizeof(*dai_props)),
+				 GFP_KERNEL);
+	dai_link  = devm_kzalloc(dev, array_size(num, sizeof(*dai_link)),
+				 GFP_KERNEL);
 	if (!dai_props || !dai_link)
 		return -ENOMEM;
 
diff --git a/sound/soc/intel/skylake/skl-topology.c b/sound/soc/intel/skylake/skl-topology.c
index 3b1dca419883..d67a08528fb0 100644
--- a/sound/soc/intel/skylake/skl-topology.c
+++ b/sound/soc/intel/skylake/skl-topology.c
@@ -2427,8 +2427,9 @@ static int skl_tplg_get_token(struct device *dev,
 
 	case SKL_TKN_U8_DYN_IN_PIN:
 		if (!mconfig->m_in_pin)
-			mconfig->m_in_pin = devm_kzalloc(dev, MAX_IN_QUEUE *
-					sizeof(*mconfig->m_in_pin), GFP_KERNEL);
+			mconfig->m_in_pin = devm_kzalloc(dev,
+							 array_size(MAX_IN_QUEUE, sizeof(*mconfig->m_in_pin)),
+							 GFP_KERNEL);
 		if (!mconfig->m_in_pin)
 			return -ENOMEM;
 
@@ -2438,8 +2439,9 @@ static int skl_tplg_get_token(struct device *dev,
 
 	case SKL_TKN_U8_DYN_OUT_PIN:
 		if (!mconfig->m_out_pin)
-			mconfig->m_out_pin = devm_kzalloc(dev, MAX_IN_QUEUE *
-					sizeof(*mconfig->m_in_pin), GFP_KERNEL);
+			mconfig->m_out_pin = devm_kzalloc(dev,
+							  array_size(MAX_IN_QUEUE, sizeof(*mconfig->m_in_pin)),
+							  GFP_KERNEL);
 		if (!mconfig->m_out_pin)
 			return -ENOMEM;
 
diff --git a/sound/soc/pxa/mmp-sspa.c b/sound/soc/pxa/mmp-sspa.c
index 7c998ea4ebee..4ccbb72db83d 100644
--- a/sound/soc/pxa/mmp-sspa.c
+++ b/sound/soc/pxa/mmp-sspa.c
@@ -426,8 +426,8 @@ static int asoc_mmp_sspa_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	priv->dma_params = devm_kzalloc(&pdev->dev,
-			2 * sizeof(struct snd_dmaengine_dai_dma_data),
-			GFP_KERNEL);
+					array_size(2, sizeof(struct snd_dmaengine_dai_dma_data)),
+					GFP_KERNEL);
 	if (priv->dma_params == NULL)
 		return -ENOMEM;
 
diff --git a/sound/soc/rockchip/rk3399_gru_sound.c b/sound/soc/rockchip/rk3399_gru_sound.c
index 9a10181a0811..af35991314b9 100644
--- a/sound/soc/rockchip/rk3399_gru_sound.c
+++ b/sound/soc/rockchip/rk3399_gru_sound.c
@@ -506,7 +506,7 @@ static int rockchip_sound_of_parse_dais(struct device *dev,
 	num_routes = 0;
 	for (i = 0; i < ARRAY_SIZE(rockchip_routes); i++)
 		num_routes += rockchip_routes[i].num_routes;
-	routes = devm_kzalloc(dev, num_routes * sizeof(*routes),
+	routes = devm_kzalloc(dev, array_size(num_routes, sizeof(*routes)),
 			      GFP_KERNEL);
 	if (!routes)
 		return -ENOMEM;
diff --git a/sound/soc/sh/rcar/cmd.c b/sound/soc/sh/rcar/cmd.c
index f1d4fb566892..a676fa246519 100644
--- a/sound/soc/sh/rcar/cmd.c
+++ b/sound/soc/sh/rcar/cmd.c
@@ -156,7 +156,7 @@ int rsnd_cmd_probe(struct rsnd_priv *priv)
 	if (!nr)
 		return 0;
 
-	cmd = devm_kzalloc(dev, sizeof(*cmd) * nr, GFP_KERNEL);
+	cmd = devm_kzalloc(dev, array_size(nr, sizeof(*cmd)), GFP_KERNEL);
 	if (!cmd)
 		return -ENOMEM;
 
diff --git a/sound/soc/sh/rcar/core.c b/sound/soc/sh/rcar/core.c
index 6a76688a8ba9..9900fac9ad04 100644
--- a/sound/soc/sh/rcar/core.c
+++ b/sound/soc/sh/rcar/core.c
@@ -1110,8 +1110,8 @@ static int rsnd_dai_probe(struct rsnd_priv *priv)
 	if (!nr)
 		return -EINVAL;
 
-	rdrv = devm_kzalloc(dev, sizeof(*rdrv) * nr, GFP_KERNEL);
-	rdai = devm_kzalloc(dev, sizeof(*rdai) * nr, GFP_KERNEL);
+	rdrv = devm_kzalloc(dev, array_size(nr, sizeof(*rdrv)), GFP_KERNEL);
+	rdai = devm_kzalloc(dev, array_size(nr, sizeof(*rdai)), GFP_KERNEL);
 	if (!rdrv || !rdai)
 		return -ENOMEM;
 
diff --git a/sound/soc/sh/rcar/ctu.c b/sound/soc/sh/rcar/ctu.c
index d201d551866d..4cea8f278136 100644
--- a/sound/soc/sh/rcar/ctu.c
+++ b/sound/soc/sh/rcar/ctu.c
@@ -378,7 +378,7 @@ int rsnd_ctu_probe(struct rsnd_priv *priv)
 		goto rsnd_ctu_probe_done;
 	}
 
-	ctu = devm_kzalloc(dev, sizeof(*ctu) * nr, GFP_KERNEL);
+	ctu = devm_kzalloc(dev, array_size(nr, sizeof(*ctu)), GFP_KERNEL);
 	if (!ctu) {
 		ret = -ENOMEM;
 		goto rsnd_ctu_probe_done;
diff --git a/sound/soc/sh/rcar/dvc.c b/sound/soc/sh/rcar/dvc.c
index dbe54f024d68..e97e46a6c32d 100644
--- a/sound/soc/sh/rcar/dvc.c
+++ b/sound/soc/sh/rcar/dvc.c
@@ -344,7 +344,8 @@ int rsnd_dvc_probe(struct rsnd_priv *priv)
 		goto rsnd_dvc_probe_done;
 	}
 
-	dvc	= devm_kzalloc(dev, sizeof(*dvc) * nr, GFP_KERNEL);
+	dvc	= devm_kzalloc(dev, array_size(nr, sizeof(*dvc)),
+				  GFP_KERNEL);
 	if (!dvc) {
 		ret = -ENOMEM;
 		goto rsnd_dvc_probe_done;
diff --git a/sound/soc/sh/rcar/mix.c b/sound/soc/sh/rcar/mix.c
index 7998380766f6..387f2a2ca6e0 100644
--- a/sound/soc/sh/rcar/mix.c
+++ b/sound/soc/sh/rcar/mix.c
@@ -294,7 +294,8 @@ int rsnd_mix_probe(struct rsnd_priv *priv)
 		goto rsnd_mix_probe_done;
 	}
 
-	mix	= devm_kzalloc(dev, sizeof(*mix) * nr, GFP_KERNEL);
+	mix	= devm_kzalloc(dev, array_size(nr, sizeof(*mix)),
+				  GFP_KERNEL);
 	if (!mix) {
 		ret = -ENOMEM;
 		goto rsnd_mix_probe_done;
diff --git a/sound/soc/sh/rcar/src.c b/sound/soc/sh/rcar/src.c
index a727e71587b6..651a6d7c677f 100644
--- a/sound/soc/sh/rcar/src.c
+++ b/sound/soc/sh/rcar/src.c
@@ -575,7 +575,8 @@ int rsnd_src_probe(struct rsnd_priv *priv)
 		goto rsnd_src_probe_done;
 	}
 
-	src	= devm_kzalloc(dev, sizeof(*src) * nr, GFP_KERNEL);
+	src	= devm_kzalloc(dev, array_size(nr, sizeof(*src)),
+				  GFP_KERNEL);
 	if (!src) {
 		ret = -ENOMEM;
 		goto rsnd_src_probe_done;
diff --git a/sound/soc/sh/rcar/ssi.c b/sound/soc/sh/rcar/ssi.c
index 333b802681ad..46532f538d59 100644
--- a/sound/soc/sh/rcar/ssi.c
+++ b/sound/soc/sh/rcar/ssi.c
@@ -1109,7 +1109,8 @@ int rsnd_ssi_probe(struct rsnd_priv *priv)
 		goto rsnd_ssi_probe_done;
 	}
 
-	ssi	= devm_kzalloc(dev, sizeof(*ssi) * nr, GFP_KERNEL);
+	ssi	= devm_kzalloc(dev, array_size(nr, sizeof(*ssi)),
+				  GFP_KERNEL);
 	if (!ssi) {
 		ret = -ENOMEM;
 		goto rsnd_ssi_probe_done;
diff --git a/sound/soc/sh/rcar/ssiu.c b/sound/soc/sh/rcar/ssiu.c
index 6ff8a36c2c82..8c3d2d369ac4 100644
--- a/sound/soc/sh/rcar/ssiu.c
+++ b/sound/soc/sh/rcar/ssiu.c
@@ -258,7 +258,8 @@ int rsnd_ssiu_probe(struct rsnd_priv *priv)
 
 	/* same number to SSI */
 	nr	= priv->ssi_nr;
-	ssiu	= devm_kzalloc(dev, sizeof(*ssiu) * nr, GFP_KERNEL);
+	ssiu	= devm_kzalloc(dev, array_size(nr, sizeof(*ssiu)),
+				   GFP_KERNEL);
 	if (!ssiu)
 		return -ENOMEM;
 
diff --git a/sound/soc/soc-core.c b/sound/soc/soc-core.c
index ae5d7f515697..fd447baef465 100644
--- a/sound/soc/soc-core.c
+++ b/sound/soc/soc-core.c
@@ -4085,7 +4085,8 @@ int snd_soc_of_parse_audio_routing(struct snd_soc_card *card,
 		return -EINVAL;
 	}
 
-	routes = devm_kzalloc(card->dev, num_routes * sizeof(*routes),
+	routes = devm_kzalloc(card->dev,
+			      array_size(num_routes, sizeof(*routes)),
 			      GFP_KERNEL);
 	if (!routes) {
 		dev_err(card->dev,
@@ -4410,7 +4411,7 @@ int snd_soc_of_get_dai_link_codecs(struct device *dev,
 		return num_codecs;
 	}
 	component = devm_kzalloc(dev,
-				 sizeof *component * num_codecs,
+				 array_size(num_codecs, sizeof(*component)),
 				 GFP_KERNEL);
 	if (!component)
 		return -ENOMEM;
-- 
2.17.0
