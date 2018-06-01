Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9831F6B0273
	for <linux-mm@kvack.org>; Thu, 31 May 2018 20:44:05 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q16-v6so14267180pls.15
        for <linux-mm@kvack.org>; Thu, 31 May 2018 17:44:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc12-v6sor15377910plb.102.2018.05.31.17.44.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 17:44:00 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 16/16] treewide: Use array_size() for devm_*alloc()-like, leftovers
Date: Thu, 31 May 2018 17:42:33 -0700
Message-Id: <20180601004233.37822-17-keescook@chromium.org>
In-Reply-To: <20180601004233.37822-1-keescook@chromium.org>
References: <20180601004233.37822-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

This swaps the remaining multi-factor products in handle-based allocators
like devm_*alloc(), sock_*alloc(), and f2fs_*alloc(). Generated with the
following Coccinelle script:

// Any remaining multi-factor products, first at least 3-factor products...
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP, E1, E2, E3;
@@

- alloc(HANDLE, E1 * E2 * E3, GFP)
+ alloc(HANDLE, array3_size(E1, E2, E3), GFP)

// ... and then all remaining 2 factors products.
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP, E1, E2;
@@

- alloc(HANDLE, E1 * E2, GFP)
+ alloc(HANDLE, array_size(E1, E2), GFP)

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 crypto/algif_aead.c                           |  4 +--
 crypto/algif_skcipher.c                       |  3 +-
 drivers/acpi/fan.c                            |  2 +-
 drivers/acpi/nfit/core.c                      |  4 +--
 drivers/char/tpm/tpm2-cmd.c                   |  3 +-
 drivers/cpufreq/brcmstb-avs-cpufreq.c         |  3 +-
 drivers/crypto/axis/artpec6_crypto.c          |  8 +++--
 drivers/crypto/marvell/cesa.c                 |  3 +-
 drivers/crypto/talitos.c                      |  9 +++---
 drivers/devfreq/devfreq.c                     | 11 +++----
 drivers/dma/k3dma.c                           |  6 ++--
 drivers/dma/s3c24xx-dma.c                     |  5 ++-
 drivers/dma/zx_dma.c                          |  6 ++--
 drivers/firmware/ti_sci.c                     |  3 +-
 drivers/gpio/gpio-adnp.c                      |  2 +-
 drivers/gpio/gpio-bcm-kona.c                  |  4 +--
 drivers/gpio/gpio-htc-egpio.c                 |  2 +-
 drivers/gpu/drm/exynos/exynos_drm_dsi.c       |  4 +--
 drivers/gpu/drm/msm/hdmi/hdmi.c               | 20 +++++++-----
 drivers/gpu/drm/msm/hdmi/hdmi_phy.c           |  6 ++--
 drivers/hid/intel-ish-hid/ishtp-hid-client.c  |  8 ++---
 drivers/hwmon/gpio-fan.c                      |  6 ++--
 drivers/hwmon/ibmpowernv.c                    |  8 ++---
 drivers/hwmon/iio_hwmon.c                     |  2 +-
 drivers/hwmon/nct6683.c                       |  3 +-
 drivers/hwmon/nct6775.c                       |  3 +-
 drivers/hwmon/pmbus/pmbus_core.c              |  2 +-
 drivers/hwtracing/coresight/coresight-etb10.c |  4 +--
 drivers/hwtracing/coresight/of_coresight.c    | 12 +++----
 drivers/i2c/muxes/i2c-mux-gpio.c              |  5 +--
 drivers/i2c/muxes/i2c-mux-reg.c               |  2 +-
 drivers/iio/adc/at91_adc.c                    |  6 ++--
 drivers/iio/adc/max1027.c                     |  2 +-
 drivers/iio/adc/max1363.c                     |  4 +--
 drivers/iio/adc/twl6030-gpadc.c               |  4 +--
 drivers/iio/dac/ad5592r-base.c                |  3 +-
 drivers/input/keyboard/clps711x-keypad.c      |  4 +--
 drivers/input/keyboard/matrix_keypad.c        |  3 +-
 drivers/input/misc/rotary_encoder.c           |  2 +-
 drivers/input/rmi4/rmi_driver.c               |  8 ++---
 drivers/input/rmi4/rmi_f11.c                  | 11 ++++---
 drivers/input/rmi4/rmi_f12.c                  | 11 ++++---
 drivers/input/rmi4/rmi_spi.c                  |  8 ++---
 drivers/iommu/mtk_iommu.c                     |  3 +-
 drivers/iommu/mtk_iommu_v1.c                  |  4 +--
 drivers/irqchip/irq-imgpdc.c                  |  3 +-
 drivers/irqchip/irq-mvebu-gicp.c              |  7 ++--
 drivers/leds/leds-adp5520.c                   |  5 +--
 drivers/leds/leds-apu.c                       |  4 +--
 drivers/leds/leds-da9052.c                    |  2 +-
 drivers/leds/leds-lp5521.c                    |  3 +-
 drivers/leds/leds-lp5523.c                    |  3 +-
 drivers/leds/leds-lp5562.c                    |  3 +-
 drivers/leds/leds-lp8501.c                    |  3 +-
 drivers/leds/leds-lt3593.c                    |  4 +--
 drivers/leds/leds-mc13783.c                   |  6 ++--
 drivers/leds/leds-mlxcpld.c                   |  5 +--
 drivers/leds/leds-netxbig.c                   |  2 +-
 drivers/leds/leds-pca955x.c                   |  5 +--
 drivers/leds/leds-pca963x.c                   |  8 +++--
 drivers/mailbox/hi6220-mailbox.c              |  6 ++--
 drivers/mailbox/omap-mailbox.c                |  6 ++--
 drivers/media/platform/am437x/am437x-vpfe.c   |  5 +--
 .../platform/qcom/camss-8x16/camss-csid.c     | 10 +++---
 .../platform/qcom/camss-8x16/camss-csiphy.c   | 10 +++---
 .../platform/qcom/camss-8x16/camss-ispif.c    |  8 +++--
 .../platform/qcom/camss-8x16/camss-vfe.c      |  8 +++--
 .../media/platform/qcom/camss-8x16/camss.c    |  3 +-
 .../media/v4l2-core/v4l2-flash-led-class.c    |  4 +--
 drivers/mfd/htc-i2cpld.c                      |  3 +-
 drivers/mfd/motorola-cpcap.c                  |  4 +--
 drivers/mfd/omap-usb-tll.c                    |  5 +--
 drivers/mfd/sprd-sc27xx-spi.c                 |  5 +--
 drivers/mfd/wm8994-core.c                     |  4 +--
 drivers/mmc/host/sdhci-omap.c                 |  5 +--
 drivers/mtd/nand/raw/s3c2410.c                |  3 +-
 drivers/net/dsa/b53/b53_common.c              |  4 +--
 .../net/ethernet/hisilicon/hns3/hns3_enet.c   |  4 +--
 drivers/net/ethernet/ti/cpsw.c                |  6 ++--
 drivers/net/ethernet/ti/netcp_ethss.c         | 12 +++----
 drivers/net/phy/phy_led_triggers.c            |  5 ++-
 drivers/pci/cadence/pcie-cadence-ep.c         |  3 +-
 drivers/pci/dwc/pcie-designware-ep.c          | 11 ++++---
 drivers/pinctrl/berlin/berlin.c               |  2 +-
 drivers/pinctrl/freescale/pinctrl-imx.c       | 15 +++++----
 drivers/pinctrl/freescale/pinctrl-imx1-core.c |  9 ++++--
 drivers/pinctrl/freescale/pinctrl-mxs.c       | 20 +++++++-----
 drivers/pinctrl/mvebu/pinctrl-armada-37xx.c   | 18 ++++++-----
 drivers/pinctrl/mvebu/pinctrl-mvebu.c         |  9 +++---
 drivers/pinctrl/pinctrl-at91-pio4.c           | 32 +++++++++++--------
 drivers/pinctrl/pinctrl-at91.c                | 30 ++++++++++-------
 drivers/pinctrl/pinctrl-ingenic.c             |  3 +-
 drivers/pinctrl/pinctrl-rockchip.c            | 31 ++++++++++--------
 drivers/pinctrl/pinctrl-st.c                  | 15 ++++++---
 drivers/pinctrl/pinctrl-xway.c                |  4 +--
 drivers/pinctrl/samsung/pinctrl-exynos.c      |  5 +--
 drivers/pinctrl/samsung/pinctrl-exynos5440.c  |  8 +++--
 drivers/pinctrl/samsung/pinctrl-samsung.c     | 15 +++++----
 drivers/pinctrl/sh-pfc/gpio.c                 |  5 +--
 drivers/pinctrl/sh-pfc/pinctrl.c              |  4 +--
 drivers/pinctrl/spear/pinctrl-plgpio.c        |  5 ++-
 drivers/pinctrl/sprd/pinctrl-sprd.c           | 17 +++++-----
 drivers/pinctrl/sunxi/pinctrl-sunxi.c         |  8 ++---
 drivers/pinctrl/tegra/pinctrl-tegra.c         |  7 ++--
 drivers/pinctrl/zte/pinctrl-zx.c              |  5 ++-
 drivers/power/supply/charger-manager.c        | 23 ++++++-------
 drivers/power/supply/power_supply_core.c      |  2 +-
 drivers/regulator/gpio-regulator.c            |  9 +++---
 drivers/regulator/max8997-regulator.c         |  5 +--
 drivers/regulator/max8998.c                   |  5 +--
 drivers/regulator/mc13xxx-regulator-core.c    |  3 +-
 drivers/regulator/s5m8767.c                   | 10 +++---
 drivers/regulator/tps65910-regulator.c        | 15 +++++----
 drivers/scsi/ufs/ufshcd.c                     |  2 +-
 drivers/spi/spi-davinci.c                     |  4 +--
 drivers/spi/spi-ep93xx.c                      |  2 +-
 drivers/spi/spi-gpio.c                        |  4 +--
 drivers/spi/spi-imx.c                         |  3 +-
 drivers/spi/spi-oc-tiny.c                     |  4 +--
 drivers/spi/spi.c                             |  3 +-
 .../atomisp/pci/atomisp2/atomisp_subdev.c     |  5 +--
 drivers/staging/media/imx/imx-media-dev.c     |  7 ++--
 .../staging/mt7621-pinctrl/pinctrl-rt2880.c   | 25 ++++++++++-----
 drivers/thermal/tegra/soctherm.c              |  4 +--
 drivers/tty/serial/rp2.c                      |  3 +-
 drivers/usb/gadget/udc/atmel_usba_udc.c       |  3 +-
 drivers/usb/gadget/udc/pch_udc.c              |  3 +-
 drivers/usb/gadget/udc/renesas_usb3.c         |  3 +-
 drivers/video/backlight/adp8860_bl.c          |  5 +--
 drivers/video/backlight/adp8870_bl.c          |  5 +--
 fs/f2fs/node.c                                |  5 +--
 sound/soc/codecs/wm8994.c                     |  3 +-
 sound/soc/davinci/davinci-mcasp.c             | 12 +++----
 sound/soc/img/img-i2s-in.c                    |  3 +-
 sound/soc/img/img-i2s-out.c                   |  3 +-
 sound/soc/uniphier/aio-cpu.c                  |  7 ++--
 136 files changed, 503 insertions(+), 387 deletions(-)

diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
index 4b07edd5a9ff..b8f238b70b3b 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -255,8 +255,8 @@ static int _aead_recvmsg(struct socket *sock, struct msghdr *msg,
 						       processed - as);
 		if (!areq->tsgl_entries)
 			areq->tsgl_entries = 1;
-		areq->tsgl = sock_kmalloc(sk, sizeof(*areq->tsgl) *
-					      areq->tsgl_entries,
+		areq->tsgl = sock_kmalloc(sk,
+					  array_size(sizeof(*areq->tsgl), areq->tsgl_entries),
 					  GFP_KERNEL);
 		if (!areq->tsgl) {
 			err = -ENOMEM;
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index c4e885df4564..8d923fe36158 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -100,7 +100,8 @@ static int _skcipher_recvmsg(struct socket *sock, struct msghdr *msg,
 	areq->tsgl_entries = af_alg_count_tsgl(sk, len, 0);
 	if (!areq->tsgl_entries)
 		areq->tsgl_entries = 1;
-	areq->tsgl = sock_kmalloc(sk, sizeof(*areq->tsgl) * areq->tsgl_entries,
+	areq->tsgl = sock_kmalloc(sk,
+				  array_size(sizeof(*areq->tsgl), areq->tsgl_entries),
 				  GFP_KERNEL);
 	if (!areq->tsgl) {
 		err = -ENOMEM;
diff --git a/drivers/acpi/fan.c b/drivers/acpi/fan.c
index 3563103590c6..8efb5111c334 100644
--- a/drivers/acpi/fan.c
+++ b/drivers/acpi/fan.c
@@ -299,7 +299,7 @@ static int acpi_fan_get_fps(struct acpi_device *device)
 
 	fan->fps_count = obj->package.count - 1; /* minus revision field */
 	fan->fps = devm_kzalloc(&device->dev,
-				fan->fps_count * sizeof(struct acpi_fan_fps),
+				array_size(fan->fps_count, sizeof(struct acpi_fan_fps)),
 				GFP_KERNEL);
 	if (!fan->fps) {
 		dev_err(&device->dev, "Not enough memory\n");
diff --git a/drivers/acpi/nfit/core.c b/drivers/acpi/nfit/core.c
index e2235ed3e4be..edd29f8a0839 100644
--- a/drivers/acpi/nfit/core.c
+++ b/drivers/acpi/nfit/core.c
@@ -1083,8 +1083,8 @@ static int __nfit_mem_init(struct acpi_nfit_desc *acpi_desc,
 			nfit_mem->nfit_flush = nfit_flush;
 			flush = nfit_flush->flush;
 			nfit_mem->flush_wpq = devm_kzalloc(acpi_desc->dev,
-					flush->hint_count
-					* sizeof(struct resource), GFP_KERNEL);
+							   array_size(flush->hint_count, sizeof(struct resource)),
+							   GFP_KERNEL);
 			if (!nfit_mem->flush_wpq)
 				return -ENOMEM;
 			for (i = 0; i < flush->hint_count; i++) {
diff --git a/drivers/char/tpm/tpm2-cmd.c b/drivers/char/tpm/tpm2-cmd.c
index 96c77c8e7f40..0c76bd90bb55 100644
--- a/drivers/char/tpm/tpm2-cmd.c
+++ b/drivers/char/tpm/tpm2-cmd.c
@@ -980,7 +980,8 @@ static int tpm2_get_cc_attrs_tbl(struct tpm_chip *chip)
 		goto out;
 	}
 
-	chip->cc_attrs_tbl = devm_kzalloc(&chip->dev, 4 * nr_commands,
+	chip->cc_attrs_tbl = devm_kzalloc(&chip->dev,
+					  array_size(4, nr_commands),
 					  GFP_KERNEL);
 
 	rc = tpm_buf_init(&buf, TPM2_ST_NO_SESSIONS, TPM2_CC_GET_CAPABILITY);
diff --git a/drivers/cpufreq/brcmstb-avs-cpufreq.c b/drivers/cpufreq/brcmstb-avs-cpufreq.c
index b07559b9ed99..282641e42644 100644
--- a/drivers/cpufreq/brcmstb-avs-cpufreq.c
+++ b/drivers/cpufreq/brcmstb-avs-cpufreq.c
@@ -410,7 +410,8 @@ brcm_avs_get_freq_table(struct device *dev, struct private_data *priv)
 	if (ret)
 		return ERR_PTR(ret);
 
-	table = devm_kzalloc(dev, (AVS_PSTATE_MAX + 1) * sizeof(*table),
+	table = devm_kzalloc(dev,
+			     array_size((AVS_PSTATE_MAX + 1), sizeof(*table)),
 			     GFP_KERNEL);
 	if (!table)
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/crypto/axis/artpec6_crypto.c b/drivers/crypto/axis/artpec6_crypto.c
index 0fb8bbf41a8d..3337ab66db81 100644
--- a/drivers/crypto/axis/artpec6_crypto.c
+++ b/drivers/crypto/axis/artpec6_crypto.c
@@ -3080,14 +3080,16 @@ static int artpec6_crypto_probe(struct platform_device *pdev)
 	tasklet_init(&ac->task, artpec6_crypto_task,
 		     (unsigned long)ac);
 
-	ac->pad_buffer = devm_kzalloc(&pdev->dev, 2 * ARTPEC_CACHE_LINE_MAX,
+	ac->pad_buffer = devm_kzalloc(&pdev->dev,
+				      array_size(2, ARTPEC_CACHE_LINE_MAX),
 				      GFP_KERNEL);
 	if (!ac->pad_buffer)
 		return -ENOMEM;
 	ac->pad_buffer = PTR_ALIGN(ac->pad_buffer, ARTPEC_CACHE_LINE_MAX);
 
-	ac->zero_buffer = devm_kzalloc(&pdev->dev, 2 * ARTPEC_CACHE_LINE_MAX,
-				      GFP_KERNEL);
+	ac->zero_buffer = devm_kzalloc(&pdev->dev,
+				       array_size(2, ARTPEC_CACHE_LINE_MAX),
+				       GFP_KERNEL);
 	if (!ac->zero_buffer)
 		return -ENOMEM;
 	ac->zero_buffer = PTR_ALIGN(ac->zero_buffer, ARTPEC_CACHE_LINE_MAX);
diff --git a/drivers/crypto/marvell/cesa.c b/drivers/crypto/marvell/cesa.c
index f81fa4a3e66b..47d324ead0eb 100644
--- a/drivers/crypto/marvell/cesa.c
+++ b/drivers/crypto/marvell/cesa.c
@@ -471,7 +471,8 @@ static int mv_cesa_probe(struct platform_device *pdev)
 		sram_size = CESA_SA_MIN_SRAM_SIZE;
 
 	cesa->sram_size = sram_size;
-	cesa->engines = devm_kzalloc(dev, caps->nengines * sizeof(*engines),
+	cesa->engines = devm_kzalloc(dev,
+				     array_size(caps->nengines, sizeof(*engines)),
 				     GFP_KERNEL);
 	if (!cesa->engines)
 		return -ENOMEM;
diff --git a/drivers/crypto/talitos.c b/drivers/crypto/talitos.c
index 7cebf0a6ffbc..82c46eb1aa3e 100644
--- a/drivers/crypto/talitos.c
+++ b/drivers/crypto/talitos.c
@@ -3393,8 +3393,9 @@ static int talitos_probe(struct platform_device *ofdev)
 		}
 	}
 
-	priv->chan = devm_kzalloc(dev, sizeof(struct talitos_channel) *
-				       priv->num_channels, GFP_KERNEL);
+	priv->chan = devm_kzalloc(dev,
+				  array_size(sizeof(struct talitos_channel), priv->num_channels),
+				  GFP_KERNEL);
 	if (!priv->chan) {
 		dev_err(dev, "failed to allocate channel management space\n");
 		err = -ENOMEM;
@@ -3412,8 +3413,8 @@ static int talitos_probe(struct platform_device *ofdev)
 		spin_lock_init(&priv->chan[i].tail_lock);
 
 		priv->chan[i].fifo = devm_kzalloc(dev,
-						sizeof(struct talitos_request) *
-						priv->fifo_len, GFP_KERNEL);
+						  array_size(sizeof(struct talitos_request), priv->fifo_len),
+						  GFP_KERNEL);
 		if (!priv->chan[i].fifo) {
 			dev_err(dev, "failed to allocate request fifo %d\n", i);
 			err = -ENOMEM;
diff --git a/drivers/devfreq/devfreq.c b/drivers/devfreq/devfreq.c
index fe2af6aa88fc..674a077a42c0 100644
--- a/drivers/devfreq/devfreq.c
+++ b/drivers/devfreq/devfreq.c
@@ -629,14 +629,11 @@ struct devfreq *devfreq_add_device(struct device *dev,
 	}
 
 	devfreq->trans_table =	devm_kzalloc(&devfreq->dev,
-						sizeof(unsigned int) *
-						devfreq->profile->max_state *
-						devfreq->profile->max_state,
-						GFP_KERNEL);
+						   array3_size(sizeof(unsigned int), devfreq->profile->max_state, devfreq->profile->max_state),
+						   GFP_KERNEL);
 	devfreq->time_in_state = devm_kzalloc(&devfreq->dev,
-						sizeof(unsigned long) *
-						devfreq->profile->max_state,
-						GFP_KERNEL);
+					      array_size(sizeof(unsigned long), devfreq->profile->max_state),
+					      GFP_KERNEL);
 	devfreq->last_stat_updated = jiffies;
 
 	srcu_init_notifier_head(&devfreq->transition_notifier_list);
diff --git a/drivers/dma/k3dma.c b/drivers/dma/k3dma.c
index 26b67455208f..e281cb9faeff 100644
--- a/drivers/dma/k3dma.c
+++ b/drivers/dma/k3dma.c
@@ -849,7 +849,8 @@ static int k3_dma_probe(struct platform_device *op)
 
 	/* init phy channel */
 	d->phy = devm_kzalloc(&op->dev,
-		d->dma_channels * sizeof(struct k3_dma_phy), GFP_KERNEL);
+			      array_size(d->dma_channels, sizeof(struct k3_dma_phy)),
+			      GFP_KERNEL);
 	if (d->phy == NULL)
 		return -ENOMEM;
 
@@ -880,7 +881,8 @@ static int k3_dma_probe(struct platform_device *op)
 
 	/* init virtual channel */
 	d->chans = devm_kzalloc(&op->dev,
-		d->dma_requests * sizeof(struct k3_dma_chan), GFP_KERNEL);
+				array_size(d->dma_requests, sizeof(struct k3_dma_chan)),
+				GFP_KERNEL);
 	if (d->chans == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/dma/s3c24xx-dma.c b/drivers/dma/s3c24xx-dma.c
index cd92d696bcf9..e42749737842 100644
--- a/drivers/dma/s3c24xx-dma.c
+++ b/drivers/dma/s3c24xx-dma.c
@@ -1224,9 +1224,8 @@ static int s3c24xx_dma_probe(struct platform_device *pdev)
 		return PTR_ERR(s3cdma->base);
 
 	s3cdma->phy_chans = devm_kzalloc(&pdev->dev,
-					      sizeof(struct s3c24xx_dma_phy) *
-							pdata->num_phy_channels,
-					      GFP_KERNEL);
+					 array_size(sizeof(struct s3c24xx_dma_phy), pdata->num_phy_channels),
+					 GFP_KERNEL);
 	if (!s3cdma->phy_chans)
 		return -ENOMEM;
 
diff --git a/drivers/dma/zx_dma.c b/drivers/dma/zx_dma.c
index 2bb695315300..b2fad0c5fbec 100644
--- a/drivers/dma/zx_dma.c
+++ b/drivers/dma/zx_dma.c
@@ -799,7 +799,8 @@ static int zx_dma_probe(struct platform_device *op)
 
 	/* init phy channel */
 	d->phy = devm_kzalloc(&op->dev,
-		d->dma_channels * sizeof(struct zx_dma_phy), GFP_KERNEL);
+			      array_size(d->dma_channels, sizeof(struct zx_dma_phy)),
+			      GFP_KERNEL);
 	if (!d->phy)
 		return -ENOMEM;
 
@@ -835,7 +836,8 @@ static int zx_dma_probe(struct platform_device *op)
 
 	/* init virtual channel */
 	d->chans = devm_kzalloc(&op->dev,
-		d->dma_requests * sizeof(struct zx_dma_chan), GFP_KERNEL);
+				array_size(d->dma_requests, sizeof(struct zx_dma_chan)),
+				GFP_KERNEL);
 	if (!d->chans)
 		return -ENOMEM;
 
diff --git a/drivers/firmware/ti_sci.c b/drivers/firmware/ti_sci.c
index 5229036dcfbf..56a021c713c9 100644
--- a/drivers/firmware/ti_sci.c
+++ b/drivers/firmware/ti_sci.c
@@ -1863,8 +1863,7 @@ static int ti_sci_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	minfo->xfer_alloc_table = devm_kzalloc(dev,
-					       BITS_TO_LONGS(desc->max_msgs)
-					       * sizeof(unsigned long),
+					       array_size(BITS_TO_LONGS(desc->max_msgs), sizeof(unsigned long)),
 					       GFP_KERNEL);
 	if (!minfo->xfer_alloc_table)
 		return -ENOMEM;
diff --git a/drivers/gpio/gpio-adnp.c b/drivers/gpio/gpio-adnp.c
index 44c09904daa6..8bb74da1105c 100644
--- a/drivers/gpio/gpio-adnp.c
+++ b/drivers/gpio/gpio-adnp.c
@@ -427,7 +427,7 @@ static int adnp_irq_setup(struct adnp *adnp)
 	 * is chosen to match the register layout of the hardware in that
 	 * each segment contains the corresponding bits for all interrupts.
 	 */
-	adnp->irq_enable = devm_kzalloc(chip->parent, num_regs * 6,
+	adnp->irq_enable = devm_kzalloc(chip->parent, array_size(num_regs, 6),
 					GFP_KERNEL);
 	if (!adnp->irq_enable)
 		return -ENOMEM;
diff --git a/drivers/gpio/gpio-bcm-kona.c b/drivers/gpio/gpio-bcm-kona.c
index eb8369b21e90..240e5123bbf8 100644
--- a/drivers/gpio/gpio-bcm-kona.c
+++ b/drivers/gpio/gpio-bcm-kona.c
@@ -602,8 +602,8 @@ static int bcm_kona_gpio_probe(struct platform_device *pdev)
 		return -ENXIO;
 	}
 	kona_gpio->banks = devm_kzalloc(dev,
-					kona_gpio->num_bank *
-					sizeof(*kona_gpio->banks), GFP_KERNEL);
+					array_size(kona_gpio->num_bank, sizeof(*kona_gpio->banks)),
+					GFP_KERNEL);
 	if (!kona_gpio->banks)
 		return -ENOMEM;
 
diff --git a/drivers/gpio/gpio-htc-egpio.c b/drivers/gpio/gpio-htc-egpio.c
index 516383934945..13a53a9797b8 100644
--- a/drivers/gpio/gpio-htc-egpio.c
+++ b/drivers/gpio/gpio-htc-egpio.c
@@ -322,7 +322,7 @@ static int __init egpio_probe(struct platform_device *pdev)
 
 	ei->nchips = pdata->num_chips;
 	ei->chip = devm_kzalloc(&pdev->dev,
-				sizeof(struct egpio_chip) * ei->nchips,
+				array_size(sizeof(struct egpio_chip), ei->nchips),
 				GFP_KERNEL);
 	if (!ei->chip) {
 		ret = -ENOMEM;
diff --git a/drivers/gpu/drm/exynos/exynos_drm_dsi.c b/drivers/gpu/drm/exynos/exynos_drm_dsi.c
index 7904ffa9abfb..09b1dc8877a2 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_dsi.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_dsi.c
@@ -1744,8 +1744,8 @@ static int exynos_dsi_probe(struct platform_device *pdev)
 	}
 
 	dsi->clks = devm_kzalloc(dev,
-			sizeof(*dsi->clks) * dsi->driver_data->num_clks,
-			GFP_KERNEL);
+				 array_size(sizeof(*dsi->clks), dsi->driver_data->num_clks),
+				 GFP_KERNEL);
 	if (!dsi->clks)
 		return -ENOMEM;
 
diff --git a/drivers/gpu/drm/msm/hdmi/hdmi.c b/drivers/gpu/drm/msm/hdmi/hdmi.c
index e63dc0fb55f8..fe04e2ad8ed7 100644
--- a/drivers/gpu/drm/msm/hdmi/hdmi.c
+++ b/drivers/gpu/drm/msm/hdmi/hdmi.c
@@ -157,8 +157,9 @@ static struct hdmi *msm_hdmi_init(struct platform_device *pdev)
 		hdmi->qfprom_mmio = NULL;
 	}
 
-	hdmi->hpd_regs = devm_kzalloc(&pdev->dev, sizeof(hdmi->hpd_regs[0]) *
-			config->hpd_reg_cnt, GFP_KERNEL);
+	hdmi->hpd_regs = devm_kzalloc(&pdev->dev,
+				      array_size(sizeof(hdmi->hpd_regs[0]), config->hpd_reg_cnt),
+				      GFP_KERNEL);
 	if (!hdmi->hpd_regs) {
 		ret = -ENOMEM;
 		goto fail;
@@ -178,8 +179,9 @@ static struct hdmi *msm_hdmi_init(struct platform_device *pdev)
 		hdmi->hpd_regs[i] = reg;
 	}
 
-	hdmi->pwr_regs = devm_kzalloc(&pdev->dev, sizeof(hdmi->pwr_regs[0]) *
-			config->pwr_reg_cnt, GFP_KERNEL);
+	hdmi->pwr_regs = devm_kzalloc(&pdev->dev,
+				      array_size(sizeof(hdmi->pwr_regs[0]), config->pwr_reg_cnt),
+				      GFP_KERNEL);
 	if (!hdmi->pwr_regs) {
 		ret = -ENOMEM;
 		goto fail;
@@ -199,8 +201,9 @@ static struct hdmi *msm_hdmi_init(struct platform_device *pdev)
 		hdmi->pwr_regs[i] = reg;
 	}
 
-	hdmi->hpd_clks = devm_kzalloc(&pdev->dev, sizeof(hdmi->hpd_clks[0]) *
-			config->hpd_clk_cnt, GFP_KERNEL);
+	hdmi->hpd_clks = devm_kzalloc(&pdev->dev,
+				      array_size(sizeof(hdmi->hpd_clks[0]), config->hpd_clk_cnt),
+				      GFP_KERNEL);
 	if (!hdmi->hpd_clks) {
 		ret = -ENOMEM;
 		goto fail;
@@ -219,8 +222,9 @@ static struct hdmi *msm_hdmi_init(struct platform_device *pdev)
 		hdmi->hpd_clks[i] = clk;
 	}
 
-	hdmi->pwr_clks = devm_kzalloc(&pdev->dev, sizeof(hdmi->pwr_clks[0]) *
-			config->pwr_clk_cnt, GFP_KERNEL);
+	hdmi->pwr_clks = devm_kzalloc(&pdev->dev,
+				      array_size(sizeof(hdmi->pwr_clks[0]), config->pwr_clk_cnt),
+				      GFP_KERNEL);
 	if (!hdmi->pwr_clks) {
 		ret = -ENOMEM;
 		goto fail;
diff --git a/drivers/gpu/drm/msm/hdmi/hdmi_phy.c b/drivers/gpu/drm/msm/hdmi/hdmi_phy.c
index 5e631392dc85..1cb3f9578783 100644
--- a/drivers/gpu/drm/msm/hdmi/hdmi_phy.c
+++ b/drivers/gpu/drm/msm/hdmi/hdmi_phy.c
@@ -21,12 +21,14 @@ static int msm_hdmi_phy_resource_init(struct hdmi_phy *phy)
 	struct device *dev = &phy->pdev->dev;
 	int i, ret;
 
-	phy->regs = devm_kzalloc(dev, sizeof(phy->regs[0]) * cfg->num_regs,
+	phy->regs = devm_kzalloc(dev,
+				 array_size(sizeof(phy->regs[0]), cfg->num_regs),
 				 GFP_KERNEL);
 	if (!phy->regs)
 		return -ENOMEM;
 
-	phy->clks = devm_kzalloc(dev, sizeof(phy->clks[0]) * cfg->num_clks,
+	phy->clks = devm_kzalloc(dev,
+				 array_size(sizeof(phy->clks[0]), cfg->num_clks),
 				 GFP_KERNEL);
 	if (!phy->clks)
 		return -ENOMEM;
diff --git a/drivers/hid/intel-ish-hid/ishtp-hid-client.c b/drivers/hid/intel-ish-hid/ishtp-hid-client.c
index 157b44aacdff..21d1cdc5e286 100644
--- a/drivers/hid/intel-ish-hid/ishtp-hid-client.c
+++ b/drivers/hid/intel-ish-hid/ishtp-hid-client.c
@@ -121,11 +121,9 @@ static void process_recv(struct ishtp_cl *hid_ishtp_cl, void *recv_buf,
 			}
 			client_data->hid_dev_count = (unsigned int)*payload;
 			if (!client_data->hid_devices)
-				client_data->hid_devices = devm_kzalloc(
-						&client_data->cl_device->dev,
-						client_data->hid_dev_count *
-						sizeof(struct device_info),
-						GFP_KERNEL);
+				client_data->hid_devices = devm_kzalloc(&client_data->cl_device->dev,
+									array_size(client_data->hid_dev_count, sizeof(struct device_info)),
+									GFP_KERNEL);
 			if (!client_data->hid_devices) {
 				dev_err(&client_data->cl_device->dev,
 				"Mem alloc failed for hid device info\n");
diff --git a/drivers/hwmon/gpio-fan.c b/drivers/hwmon/gpio-fan.c
index 5c9a52599cf6..cf83fe547494 100644
--- a/drivers/hwmon/gpio-fan.c
+++ b/drivers/hwmon/gpio-fan.c
@@ -442,7 +442,7 @@ static int gpio_fan_get_of_data(struct gpio_fan_data *fan_data)
 		return -ENODEV;
 	}
 	gpios = devm_kzalloc(dev,
-			     fan_data->num_gpios * sizeof(struct gpio_desc *),
+			     array_size(fan_data->num_gpios, sizeof(struct gpio_desc *)),
 			     GFP_KERNEL);
 	if (!gpios)
 		return -ENOMEM;
@@ -472,8 +472,8 @@ static int gpio_fan_get_of_data(struct gpio_fan_data *fan_data)
 	 * this needs splitting into pairs to create gpio_fan_speed structs
 	 */
 	speed = devm_kzalloc(dev,
-			fan_data->num_speed * sizeof(struct gpio_fan_speed),
-			GFP_KERNEL);
+			     array_size(fan_data->num_speed, sizeof(struct gpio_fan_speed)),
+			     GFP_KERNEL);
 	if (!speed)
 		return -ENOMEM;
 	p = NULL;
diff --git a/drivers/hwmon/ibmpowernv.c b/drivers/hwmon/ibmpowernv.c
index 5ccdd0b52650..83e14d21fe1e 100644
--- a/drivers/hwmon/ibmpowernv.c
+++ b/drivers/hwmon/ibmpowernv.c
@@ -324,9 +324,8 @@ static int populate_attr_groups(struct platform_device *pdev)
 
 	for (type = 0; type < MAX_SENSOR_TYPE; type++) {
 		sensor_groups[type].group.attrs = devm_kzalloc(&pdev->dev,
-					sizeof(struct attribute *) *
-					(sensor_groups[type].attr_count + 1),
-					GFP_KERNEL);
+							       array_size(sizeof(struct attribute *), (sensor_groups[type].attr_count + 1)),
+							       GFP_KERNEL);
 		if (!sensor_groups[type].group.attrs)
 			return -ENOMEM;
 
@@ -406,7 +405,8 @@ static int create_device_attrs(struct platform_device *pdev)
 	int err = 0;
 
 	opal = of_find_node_by_path("/ibm,opal/sensors");
-	sdata = devm_kzalloc(&pdev->dev, pdata->sensors_count * sizeof(*sdata),
+	sdata = devm_kzalloc(&pdev->dev,
+			     array_size(pdata->sensors_count, sizeof(*sdata)),
 			     GFP_KERNEL);
 	if (!sdata) {
 		err = -ENOMEM;
diff --git a/drivers/hwmon/iio_hwmon.c b/drivers/hwmon/iio_hwmon.c
index 5e5b32a1ec4b..3b579d7ea6fb 100644
--- a/drivers/hwmon/iio_hwmon.c
+++ b/drivers/hwmon/iio_hwmon.c
@@ -93,7 +93,7 @@ static int iio_hwmon_probe(struct platform_device *pdev)
 		st->num_channels++;
 
 	st->attrs = devm_kzalloc(dev,
-				 sizeof(*st->attrs) * (st->num_channels + 1),
+				 array_size(sizeof(*st->attrs), (st->num_channels + 1)),
 				 GFP_KERNEL);
 	if (st->attrs == NULL) {
 		ret = -ENOMEM;
diff --git a/drivers/hwmon/nct6683.c b/drivers/hwmon/nct6683.c
index e43c944c995b..39ba8057ae33 100644
--- a/drivers/hwmon/nct6683.c
+++ b/drivers/hwmon/nct6683.c
@@ -426,7 +426,8 @@ nct6683_create_attr_group(struct device *dev,
 	if (group == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	attrs = devm_kzalloc(dev, sizeof(*attrs) * (repeat * count + 1),
+	attrs = devm_kzalloc(dev,
+			     array_size(sizeof(*attrs), (repeat * count + 1)),
 			     GFP_KERNEL);
 	if (attrs == NULL)
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/hwmon/nct6775.c b/drivers/hwmon/nct6775.c
index d421b121a0eb..d5f9c76e4990 100644
--- a/drivers/hwmon/nct6775.c
+++ b/drivers/hwmon/nct6775.c
@@ -1190,7 +1190,8 @@ nct6775_create_attr_group(struct device *dev,
 	if (group == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	attrs = devm_kzalloc(dev, sizeof(*attrs) * (repeat * count + 1),
+	attrs = devm_kzalloc(dev,
+			     array_size(sizeof(*attrs), (repeat * count + 1)),
 			     GFP_KERNEL);
 	if (attrs == NULL)
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/hwmon/pmbus/pmbus_core.c b/drivers/hwmon/pmbus/pmbus_core.c
index f7c47d7994e7..6fac8138162b 100644
--- a/drivers/hwmon/pmbus/pmbus_core.c
+++ b/drivers/hwmon/pmbus/pmbus_core.c
@@ -2177,7 +2177,7 @@ static int pmbus_init_debugfs(struct i2c_client *client,
 
 	/* Allocate the max possible entries we need. */
 	entries = devm_kzalloc(data->dev,
-			       sizeof(*entries) * (data->info->pages * 10),
+			       array_size(sizeof(*entries), (data->info->pages * 10)),
 			       GFP_KERNEL);
 	if (!entries)
 		return -ENOMEM;
diff --git a/drivers/hwtracing/coresight/coresight-etb10.c b/drivers/hwtracing/coresight/coresight-etb10.c
index 580cd381adf3..064771c5fe83 100644
--- a/drivers/hwtracing/coresight/coresight-etb10.c
+++ b/drivers/hwtracing/coresight/coresight-etb10.c
@@ -690,8 +690,8 @@ static int etb_probe(struct amba_device *adev, const struct amba_id *id)
 	if (drvdata->buffer_depth & 0x80000000)
 		return -EINVAL;
 
-	drvdata->buf = devm_kzalloc(dev,
-				    drvdata->buffer_depth * 4, GFP_KERNEL);
+	drvdata->buf = devm_kzalloc(dev, array_size(drvdata->buffer_depth, 4),
+				    GFP_KERNEL);
 	if (!drvdata->buf)
 		return -ENOMEM;
 
diff --git a/drivers/hwtracing/coresight/of_coresight.c b/drivers/hwtracing/coresight/of_coresight.c
index 7c375443ede6..2cae0eab0341 100644
--- a/drivers/hwtracing/coresight/of_coresight.c
+++ b/drivers/hwtracing/coresight/of_coresight.c
@@ -78,22 +78,22 @@ static int of_coresight_alloc_memory(struct device *dev,
 			struct coresight_platform_data *pdata)
 {
 	/* List of output port on this component */
-	pdata->outports = devm_kzalloc(dev, pdata->nr_outport *
-				       sizeof(*pdata->outports),
+	pdata->outports = devm_kzalloc(dev,
+				       array_size(pdata->nr_outport, sizeof(*pdata->outports)),
 				       GFP_KERNEL);
 	if (!pdata->outports)
 		return -ENOMEM;
 
 	/* Children connected to this component via @outports */
-	pdata->child_names = devm_kzalloc(dev, pdata->nr_outport *
-					  sizeof(*pdata->child_names),
+	pdata->child_names = devm_kzalloc(dev,
+					  array_size(pdata->nr_outport, sizeof(*pdata->child_names)),
 					  GFP_KERNEL);
 	if (!pdata->child_names)
 		return -ENOMEM;
 
 	/* Port number on the child this component is connected to */
-	pdata->child_ports = devm_kzalloc(dev, pdata->nr_outport *
-					  sizeof(*pdata->child_ports),
+	pdata->child_ports = devm_kzalloc(dev,
+					  array_size(pdata->nr_outport, sizeof(*pdata->child_ports)),
 					  GFP_KERNEL);
 	if (!pdata->child_ports)
 		return -ENOMEM;
diff --git a/drivers/i2c/muxes/i2c-mux-gpio.c b/drivers/i2c/muxes/i2c-mux-gpio.c
index 1a9973ede443..d0ea53112ec3 100644
--- a/drivers/i2c/muxes/i2c-mux-gpio.c
+++ b/drivers/i2c/muxes/i2c-mux-gpio.c
@@ -89,7 +89,7 @@ static int i2c_mux_gpio_probe_dt(struct gpiomux *mux,
 	mux->data.n_values = of_get_child_count(np);
 
 	values = devm_kzalloc(&pdev->dev,
-			      sizeof(*mux->data.values) * mux->data.n_values,
+			      array_size(sizeof(*mux->data.values), mux->data.n_values),
 			      GFP_KERNEL);
 	if (!values) {
 		dev_err(&pdev->dev, "Cannot allocate values array");
@@ -112,7 +112,8 @@ static int i2c_mux_gpio_probe_dt(struct gpiomux *mux,
 	}
 
 	gpios = devm_kzalloc(&pdev->dev,
-			     sizeof(*mux->data.gpios) * mux->data.n_gpios, GFP_KERNEL);
+			     array_size(sizeof(*mux->data.gpios), mux->data.n_gpios),
+			     GFP_KERNEL);
 	if (!gpios) {
 		dev_err(&pdev->dev, "Cannot allocate gpios array");
 		return -ENOMEM;
diff --git a/drivers/i2c/muxes/i2c-mux-reg.c b/drivers/i2c/muxes/i2c-mux-reg.c
index c948e5a4cb04..2a0067885859 100644
--- a/drivers/i2c/muxes/i2c-mux-reg.c
+++ b/drivers/i2c/muxes/i2c-mux-reg.c
@@ -125,7 +125,7 @@ static int i2c_mux_reg_probe_dt(struct regmux *mux,
 	mux->data.write_only = of_property_read_bool(np, "write-only");
 
 	values = devm_kzalloc(&pdev->dev,
-			      sizeof(*mux->data.values) * mux->data.n_values,
+			      array_size(sizeof(*mux->data.values), mux->data.n_values),
 			      GFP_KERNEL);
 	if (!values) {
 		dev_err(&pdev->dev, "Cannot allocate values array");
diff --git a/drivers/iio/adc/at91_adc.c b/drivers/iio/adc/at91_adc.c
index 71a5ee652b79..a700ffd1cf6d 100644
--- a/drivers/iio/adc/at91_adc.c
+++ b/drivers/iio/adc/at91_adc.c
@@ -625,7 +625,7 @@ static int at91_adc_trigger_init(struct iio_dev *idev)
 	int i, ret;
 
 	st->trig = devm_kzalloc(&idev->dev,
-				st->trigger_number * sizeof(*st->trig),
+				array_size(st->trigger_number, sizeof(*st->trig)),
 				GFP_KERNEL);
 
 	if (st->trig == NULL) {
@@ -908,8 +908,8 @@ static int at91_adc_probe_dt(struct at91_adc_state *st,
 	st->registers = &st->caps->registers;
 	st->num_channels = st->caps->num_channels;
 	st->trigger_number = of_get_child_count(node);
-	st->trigger_list = devm_kzalloc(&idev->dev, st->trigger_number *
-					sizeof(struct at91_adc_trigger),
+	st->trigger_list = devm_kzalloc(&idev->dev,
+					array_size(st->trigger_number, sizeof(struct at91_adc_trigger)),
 					GFP_KERNEL);
 	if (!st->trigger_list) {
 		dev_err(&idev->dev, "Could not allocate trigger list memory.\n");
diff --git a/drivers/iio/adc/max1027.c b/drivers/iio/adc/max1027.c
index 375da6491499..b24739fa8de0 100644
--- a/drivers/iio/adc/max1027.c
+++ b/drivers/iio/adc/max1027.c
@@ -423,7 +423,7 @@ static int max1027_probe(struct spi_device *spi)
 	indio_dev->available_scan_masks = st->info->available_scan_masks;
 
 	st->buffer = devm_kmalloc(&indio_dev->dev,
-				  indio_dev->num_channels * 2,
+				  array_size(indio_dev->num_channels, 2),
 				  GFP_KERNEL);
 	if (st->buffer == NULL) {
 		dev_err(&indio_dev->dev, "Can't allocate buffer\n");
diff --git a/drivers/iio/adc/max1363.c b/drivers/iio/adc/max1363.c
index 7f1848dac9bf..9b80e752cb74 100644
--- a/drivers/iio/adc/max1363.c
+++ b/drivers/iio/adc/max1363.c
@@ -1453,8 +1453,8 @@ static int max1363_alloc_scan_masks(struct iio_dev *indio_dev)
 	int i;
 
 	masks = devm_kzalloc(&indio_dev->dev,
-			BITS_TO_LONGS(MAX1363_MAX_CHANNELS) * sizeof(long) *
-			(st->chip_info->num_modes + 1), GFP_KERNEL);
+			     array3_size(BITS_TO_LONGS(MAX1363_MAX_CHANNELS), sizeof(long), (st->chip_info->num_modes + 1)),
+			     GFP_KERNEL);
 	if (!masks)
 		return -ENOMEM;
 
diff --git a/drivers/iio/adc/twl6030-gpadc.c b/drivers/iio/adc/twl6030-gpadc.c
index dc83f8f6c3d3..cbd624d14cf8 100644
--- a/drivers/iio/adc/twl6030-gpadc.c
+++ b/drivers/iio/adc/twl6030-gpadc.c
@@ -899,8 +899,8 @@ static int twl6030_gpadc_probe(struct platform_device *pdev)
 	gpadc = iio_priv(indio_dev);
 
 	gpadc->twl6030_cal_tbl = devm_kzalloc(dev,
-					sizeof(*gpadc->twl6030_cal_tbl) *
-					pdata->nchannels, GFP_KERNEL);
+					      array_size(sizeof(*gpadc->twl6030_cal_tbl), pdata->nchannels),
+					      GFP_KERNEL);
 	if (!gpadc->twl6030_cal_tbl)
 		return -ENOMEM;
 
diff --git a/drivers/iio/dac/ad5592r-base.c b/drivers/iio/dac/ad5592r-base.c
index 9234c6a09a93..2869f18bfb84 100644
--- a/drivers/iio/dac/ad5592r-base.c
+++ b/drivers/iio/dac/ad5592r-base.c
@@ -537,7 +537,8 @@ static int ad5592r_alloc_channels(struct ad5592r_state *st)
 	}
 
 	channels = devm_kzalloc(st->dev,
-			(1 + 2 * num_channels) * sizeof(*channels), GFP_KERNEL);
+				array_size((1 + 2 * num_channels), sizeof(*channels)),
+				GFP_KERNEL);
 	if (!channels)
 		return -ENOMEM;
 
diff --git a/drivers/input/keyboard/clps711x-keypad.c b/drivers/input/keyboard/clps711x-keypad.c
index 997e3e97f573..ccec4ba51b26 100644
--- a/drivers/input/keyboard/clps711x-keypad.c
+++ b/drivers/input/keyboard/clps711x-keypad.c
@@ -110,8 +110,8 @@ static int clps711x_keypad_probe(struct platform_device *pdev)
 		return -EINVAL;
 
 	priv->gpio_data = devm_kzalloc(dev,
-				sizeof(*priv->gpio_data) * priv->row_count,
-				GFP_KERNEL);
+				       array_size(sizeof(*priv->gpio_data), priv->row_count),
+				       GFP_KERNEL);
 	if (!priv->gpio_data)
 		return -ENOMEM;
 
diff --git a/drivers/input/keyboard/matrix_keypad.c b/drivers/input/keyboard/matrix_keypad.c
index 41614c185918..0fb6f630692e 100644
--- a/drivers/input/keyboard/matrix_keypad.c
+++ b/drivers/input/keyboard/matrix_keypad.c
@@ -444,8 +444,7 @@ matrix_keypad_parse_dt(struct device *dev)
 						&pdata->col_scan_delay_us);
 
 	gpios = devm_kzalloc(dev,
-			     sizeof(unsigned int) *
-				(pdata->num_row_gpios + pdata->num_col_gpios),
+			     array_size(sizeof(unsigned int), (pdata->num_row_gpios + pdata->num_col_gpios)),
 			     GFP_KERNEL);
 	if (!gpios) {
 		dev_err(dev, "could not allocate memory for gpios\n");
diff --git a/drivers/input/misc/rotary_encoder.c b/drivers/input/misc/rotary_encoder.c
index 1588aecafff7..9b549cb8c193 100644
--- a/drivers/input/misc/rotary_encoder.c
+++ b/drivers/input/misc/rotary_encoder.c
@@ -284,7 +284,7 @@ static int rotary_encoder_probe(struct platform_device *pdev)
 
 	encoder->irq =
 		devm_kzalloc(dev,
-			     sizeof(*encoder->irq) * encoder->gpios->ndescs,
+			     array_size(sizeof(*encoder->irq), encoder->gpios->ndescs),
 			     GFP_KERNEL);
 	if (!encoder->irq)
 		return -ENOMEM;
diff --git a/drivers/input/rmi4/rmi_driver.c b/drivers/input/rmi4/rmi_driver.c
index f5954981e9ee..890ff95edf06 100644
--- a/drivers/input/rmi4/rmi_driver.c
+++ b/drivers/input/rmi4/rmi_driver.c
@@ -636,9 +636,9 @@ int rmi_read_register_desc(struct rmi_device *d, u16 addr,
 	rdesc->num_registers = bitmap_weight(rdesc->presense_map,
 						RMI_REG_DESC_PRESENSE_BITS);
 
-	rdesc->registers = devm_kzalloc(&d->dev, rdesc->num_registers *
-				sizeof(struct rmi_register_desc_item),
-				GFP_KERNEL);
+	rdesc->registers = devm_kzalloc(&d->dev,
+					array_size(rdesc->num_registers, sizeof(struct rmi_register_desc_item)),
+					GFP_KERNEL);
 	if (!rdesc->registers)
 		return -ENOMEM;
 
@@ -1061,7 +1061,7 @@ int rmi_probe_interrupts(struct rmi_driver_data *data)
 	data->num_of_irq_regs = (data->irq_count + 7) / 8;
 
 	size = BITS_TO_LONGS(data->irq_count) * sizeof(unsigned long);
-	data->irq_memory = devm_kzalloc(dev, size * 4, GFP_KERNEL);
+	data->irq_memory = devm_kzalloc(dev, array_size(size, 4), GFP_KERNEL);
 	if (!data->irq_memory) {
 		dev_err(dev, "Failed to allocate memory for irq masks.\n");
 		return -ENOMEM;
diff --git a/drivers/input/rmi4/rmi_f11.c b/drivers/input/rmi4/rmi_f11.c
index bc5e37f30ac1..afa27747d28a 100644
--- a/drivers/input/rmi4/rmi_f11.c
+++ b/drivers/input/rmi4/rmi_f11.c
@@ -1191,13 +1191,14 @@ static int rmi_f11_initialize(struct rmi_function *fn)
 
 	/* allocate the in-kernel tracking buffers */
 	sensor->tracking_pos = devm_kzalloc(&fn->dev,
-			sizeof(struct input_mt_pos) * sensor->nbr_fingers,
-			GFP_KERNEL);
+					    array_size(sizeof(struct input_mt_pos), sensor->nbr_fingers),
+					    GFP_KERNEL);
 	sensor->tracking_slots = devm_kzalloc(&fn->dev,
-			sizeof(int) * sensor->nbr_fingers, GFP_KERNEL);
+					      array_size(sizeof(int), sensor->nbr_fingers),
+					      GFP_KERNEL);
 	sensor->objs = devm_kzalloc(&fn->dev,
-			sizeof(struct rmi_2d_sensor_abs_object)
-			* sensor->nbr_fingers, GFP_KERNEL);
+				    array_size(sizeof(struct rmi_2d_sensor_abs_object), sensor->nbr_fingers),
+				    GFP_KERNEL);
 	if (!sensor->tracking_pos || !sensor->tracking_slots || !sensor->objs)
 		return -ENOMEM;
 
diff --git a/drivers/input/rmi4/rmi_f12.c b/drivers/input/rmi4/rmi_f12.c
index 8b0db086d68a..3982444d514e 100644
--- a/drivers/input/rmi4/rmi_f12.c
+++ b/drivers/input/rmi4/rmi_f12.c
@@ -503,13 +503,14 @@ static int rmi_f12_probe(struct rmi_function *fn)
 
 	/* allocate the in-kernel tracking buffers */
 	sensor->tracking_pos = devm_kzalloc(&fn->dev,
-			sizeof(struct input_mt_pos) * sensor->nbr_fingers,
-			GFP_KERNEL);
+					    array_size(sizeof(struct input_mt_pos), sensor->nbr_fingers),
+					    GFP_KERNEL);
 	sensor->tracking_slots = devm_kzalloc(&fn->dev,
-			sizeof(int) * sensor->nbr_fingers, GFP_KERNEL);
+					      array_size(sizeof(int), sensor->nbr_fingers),
+					      GFP_KERNEL);
 	sensor->objs = devm_kzalloc(&fn->dev,
-			sizeof(struct rmi_2d_sensor_abs_object)
-			* sensor->nbr_fingers, GFP_KERNEL);
+				    array_size(sizeof(struct rmi_2d_sensor_abs_object), sensor->nbr_fingers),
+				    GFP_KERNEL);
 	if (!sensor->tracking_pos || !sensor->tracking_slots || !sensor->objs)
 		return -ENOMEM;
 
diff --git a/drivers/input/rmi4/rmi_spi.c b/drivers/input/rmi4/rmi_spi.c
index 082defc329a8..26c25320cb1c 100644
--- a/drivers/input/rmi4/rmi_spi.c
+++ b/drivers/input/rmi4/rmi_spi.c
@@ -69,8 +69,8 @@ static int rmi_spi_manage_pools(struct rmi_spi_xport *rmi_spi, int len)
 		buf_size = RMI_SPI_XFER_SIZE_LIMIT;
 
 	tmp = rmi_spi->rx_buf;
-	buf = devm_kzalloc(&spi->dev, buf_size * 2,
-				GFP_KERNEL | GFP_DMA);
+	buf = devm_kzalloc(&spi->dev, array_size(buf_size, 2),
+			   GFP_KERNEL | GFP_DMA);
 	if (!buf)
 		return -ENOMEM;
 
@@ -97,8 +97,8 @@ static int rmi_spi_manage_pools(struct rmi_spi_xport *rmi_spi, int len)
 	 */
 	tmp = rmi_spi->rx_xfers;
 	xfer_buf = devm_kzalloc(&spi->dev,
-		(rmi_spi->rx_xfer_count + rmi_spi->tx_xfer_count)
-		* sizeof(struct spi_transfer), GFP_KERNEL);
+				array_size((rmi_spi->rx_xfer_count + rmi_spi->tx_xfer_count), sizeof(struct spi_transfer)),
+				GFP_KERNEL);
 	if (!xfer_buf)
 		return -ENOMEM;
 
diff --git a/drivers/iommu/mtk_iommu.c b/drivers/iommu/mtk_iommu.c
index f2832a10fcea..363c0c84753c 100644
--- a/drivers/iommu/mtk_iommu.c
+++ b/drivers/iommu/mtk_iommu.c
@@ -593,7 +593,8 @@ static int mtk_iommu_probe(struct platform_device *pdev)
 	data->m4u_plat = (enum mtk_iommu_plat)of_device_get_match_data(dev);
 
 	/* Protect memory. HW will access here while translation fault.*/
-	protect = devm_kzalloc(dev, MTK_PROTECT_PA_ALIGN * 2, GFP_KERNEL);
+	protect = devm_kzalloc(dev, array_size(MTK_PROTECT_PA_ALIGN, 2),
+			       GFP_KERNEL);
 	if (!protect)
 		return -ENOMEM;
 	data->protect_base = ALIGN(virt_to_phys(protect), MTK_PROTECT_PA_ALIGN);
diff --git a/drivers/iommu/mtk_iommu_v1.c b/drivers/iommu/mtk_iommu_v1.c
index a7c2a973784f..00787ab2ff0e 100644
--- a/drivers/iommu/mtk_iommu_v1.c
+++ b/drivers/iommu/mtk_iommu_v1.c
@@ -566,8 +566,8 @@ static int mtk_iommu_probe(struct platform_device *pdev)
 	data->dev = dev;
 
 	/* Protect memory. HW will access here while translation fault.*/
-	protect = devm_kzalloc(dev, MTK_PROTECT_PA_ALIGN * 2,
-			GFP_KERNEL | GFP_DMA);
+	protect = devm_kzalloc(dev, array_size(MTK_PROTECT_PA_ALIGN, 2),
+			       GFP_KERNEL | GFP_DMA);
 	if (!protect)
 		return -ENOMEM;
 	data->protect_base = ALIGN(virt_to_phys(protect), MTK_PROTECT_PA_ALIGN);
diff --git a/drivers/irqchip/irq-imgpdc.c b/drivers/irqchip/irq-imgpdc.c
index e80263e16c4c..ea276a033a96 100644
--- a/drivers/irqchip/irq-imgpdc.c
+++ b/drivers/irqchip/irq-imgpdc.c
@@ -354,7 +354,8 @@ static int pdc_intc_probe(struct platform_device *pdev)
 	priv->nr_syswakes = val;
 
 	/* Get peripheral IRQ numbers */
-	priv->perip_irqs = devm_kzalloc(&pdev->dev, 4 * priv->nr_perips,
+	priv->perip_irqs = devm_kzalloc(&pdev->dev,
+					array_size(4, priv->nr_perips),
 					GFP_KERNEL);
 	if (!priv->perip_irqs) {
 		dev_err(&pdev->dev, "cannot allocate perip IRQ list\n");
diff --git a/drivers/irqchip/irq-mvebu-gicp.c b/drivers/irqchip/irq-mvebu-gicp.c
index 17a4a7b6cdbb..05f3240169d3 100644
--- a/drivers/irqchip/irq-mvebu-gicp.c
+++ b/drivers/irqchip/irq-mvebu-gicp.c
@@ -208,8 +208,7 @@ static int mvebu_gicp_probe(struct platform_device *pdev)
 
 	gicp->spi_ranges =
 		devm_kzalloc(&pdev->dev,
-			     gicp->spi_ranges_cnt *
-			     sizeof(struct mvebu_gicp_spi_range),
+			     array_size(gicp->spi_ranges_cnt, sizeof(struct mvebu_gicp_spi_range)),
 			     GFP_KERNEL);
 	if (!gicp->spi_ranges)
 		return -ENOMEM;
@@ -227,8 +226,8 @@ static int mvebu_gicp_probe(struct platform_device *pdev)
 	}
 
 	gicp->spi_bitmap = devm_kzalloc(&pdev->dev,
-				BITS_TO_LONGS(gicp->spi_cnt) * sizeof(long),
-				GFP_KERNEL);
+					array_size(BITS_TO_LONGS(gicp->spi_cnt), sizeof(long)),
+					GFP_KERNEL);
 	if (!gicp->spi_bitmap)
 		return -ENOMEM;
 
diff --git a/drivers/leds/leds-adp5520.c b/drivers/leds/leds-adp5520.c
index 853b2d3bdb17..38ed03f6777e 100644
--- a/drivers/leds/leds-adp5520.c
+++ b/drivers/leds/leds-adp5520.c
@@ -108,8 +108,9 @@ static int adp5520_led_probe(struct platform_device *pdev)
 		return -EFAULT;
 	}
 
-	led = devm_kzalloc(&pdev->dev, sizeof(*led) * pdata->num_leds,
-				GFP_KERNEL);
+	led = devm_kzalloc(&pdev->dev,
+			   array_size(sizeof(*led), pdata->num_leds),
+			   GFP_KERNEL);
 	if (!led)
 		return -ENOMEM;
 
diff --git a/drivers/leds/leds-apu.c b/drivers/leds/leds-apu.c
index 90eeedcbf371..4913163eec4c 100644
--- a/drivers/leds/leds-apu.c
+++ b/drivers/leds/leds-apu.c
@@ -172,8 +172,8 @@ static int apu_led_config(struct device *dev, struct apu_led_pdata *apuld)
 	int err;
 
 	apu_led->pled = devm_kzalloc(dev,
-		sizeof(struct apu_led_priv) * apu_led->num_led_instances,
-		GFP_KERNEL);
+				     array_size(sizeof(struct apu_led_priv), apu_led->num_led_instances),
+				     GFP_KERNEL);
 
 	if (!apu_led->pled)
 		return -ENOMEM;
diff --git a/drivers/leds/leds-da9052.c b/drivers/leds/leds-da9052.c
index f8c7d82c2652..6724daf3b4c9 100644
--- a/drivers/leds/leds-da9052.c
+++ b/drivers/leds/leds-da9052.c
@@ -114,7 +114,7 @@ static int da9052_led_probe(struct platform_device *pdev)
 	}
 
 	led = devm_kzalloc(&pdev->dev,
-			   sizeof(struct da9052_led) * pled->num_leds,
+			   array_size(sizeof(struct da9052_led), pled->num_leds),
 			   GFP_KERNEL);
 	if (!led) {
 		error = -ENOMEM;
diff --git a/drivers/leds/leds-lp5521.c b/drivers/leds/leds-lp5521.c
index 55c0517fbe03..dc7e737e9d9a 100644
--- a/drivers/leds/leds-lp5521.c
+++ b/drivers/leds/leds-lp5521.c
@@ -534,7 +534,8 @@ static int lp5521_probe(struct i2c_client *client,
 		return -ENOMEM;
 
 	led = devm_kzalloc(&client->dev,
-			sizeof(*led) * pdata->num_channels, GFP_KERNEL);
+			   array_size(sizeof(*led), pdata->num_channels),
+			   GFP_KERNEL);
 	if (!led)
 		return -ENOMEM;
 
diff --git a/drivers/leds/leds-lp5523.c b/drivers/leds/leds-lp5523.c
index 52b6f529e278..0b811709b737 100644
--- a/drivers/leds/leds-lp5523.c
+++ b/drivers/leds/leds-lp5523.c
@@ -899,7 +899,8 @@ static int lp5523_probe(struct i2c_client *client,
 		return -ENOMEM;
 
 	led = devm_kzalloc(&client->dev,
-			sizeof(*led) * pdata->num_channels, GFP_KERNEL);
+			   array_size(sizeof(*led), pdata->num_channels),
+			   GFP_KERNEL);
 	if (!led)
 		return -ENOMEM;
 
diff --git a/drivers/leds/leds-lp5562.c b/drivers/leds/leds-lp5562.c
index 05ffa34fb6ad..cd333fda36c8 100644
--- a/drivers/leds/leds-lp5562.c
+++ b/drivers/leds/leds-lp5562.c
@@ -535,7 +535,8 @@ static int lp5562_probe(struct i2c_client *client,
 		return -ENOMEM;
 
 	led = devm_kzalloc(&client->dev,
-			sizeof(*led) * pdata->num_channels, GFP_KERNEL);
+			   array_size(sizeof(*led), pdata->num_channels),
+			   GFP_KERNEL);
 	if (!led)
 		return -ENOMEM;
 
diff --git a/drivers/leds/leds-lp8501.c b/drivers/leds/leds-lp8501.c
index 3adb113cf02e..80d8ac004959 100644
--- a/drivers/leds/leds-lp8501.c
+++ b/drivers/leds/leds-lp8501.c
@@ -328,7 +328,8 @@ static int lp8501_probe(struct i2c_client *client,
 		return -ENOMEM;
 
 	led = devm_kzalloc(&client->dev,
-			sizeof(*led) * pdata->num_channels, GFP_KERNEL);
+			   array_size(sizeof(*led), pdata->num_channels),
+			   GFP_KERNEL);
 	if (!led)
 		return -ENOMEM;
 
diff --git a/drivers/leds/leds-lt3593.c b/drivers/leds/leds-lt3593.c
index a7ff510cbdd0..1c2c94f810de 100644
--- a/drivers/leds/leds-lt3593.c
+++ b/drivers/leds/leds-lt3593.c
@@ -129,8 +129,8 @@ static int lt3593_led_probe(struct platform_device *pdev)
 		return -EBUSY;
 
 	leds_data = devm_kzalloc(&pdev->dev,
-			sizeof(struct lt3593_led_data) * pdata->num_leds,
-			GFP_KERNEL);
+				 array_size(sizeof(struct lt3593_led_data), pdata->num_leds),
+				 GFP_KERNEL);
 	if (!leds_data)
 		return -ENOMEM;
 
diff --git a/drivers/leds/leds-mc13783.c b/drivers/leds/leds-mc13783.c
index 2421cf104991..872d561cfc74 100644
--- a/drivers/leds/leds-mc13783.c
+++ b/drivers/leds/leds-mc13783.c
@@ -136,7 +136,8 @@ static struct mc13xxx_leds_platform_data __init *mc13xxx_led_probe_dt(
 
 	pdata->num_leds = of_get_child_count(parent);
 
-	pdata->led = devm_kzalloc(dev, pdata->num_leds * sizeof(*pdata->led),
+	pdata->led = devm_kzalloc(dev,
+				  array_size(pdata->num_leds, sizeof(*pdata->led)),
 				  GFP_KERNEL);
 	if (!pdata->led) {
 		ret = -ENOMEM;
@@ -210,7 +211,8 @@ static int __init mc13xxx_led_probe(struct platform_device *pdev)
 		return -EINVAL;
 	}
 
-	leds->led = devm_kzalloc(dev, leds->num_leds * sizeof(*leds->led),
+	leds->led = devm_kzalloc(dev,
+				 array_size(leds->num_leds, sizeof(*leds->led)),
 				 GFP_KERNEL);
 	if (!leds->led)
 		return -ENOMEM;
diff --git a/drivers/leds/leds-mlxcpld.c b/drivers/leds/leds-mlxcpld.c
index 281482e1d50f..523e69857351 100644
--- a/drivers/leds/leds-mlxcpld.c
+++ b/drivers/leds/leds-mlxcpld.c
@@ -329,8 +329,9 @@ static int mlxcpld_led_config(struct device *dev,
 	int i;
 	int err;
 
-	cpld->pled = devm_kzalloc(dev, sizeof(struct mlxcpld_led_priv) *
-				  cpld->num_led_instances, GFP_KERNEL);
+	cpld->pled = devm_kzalloc(dev,
+				  array_size(sizeof(struct mlxcpld_led_priv), cpld->num_led_instances),
+				  GFP_KERNEL);
 	if (!cpld->pled)
 		return -ENOMEM;
 
diff --git a/drivers/leds/leds-netxbig.c b/drivers/leds/leds-netxbig.c
index ad47fac3ed4d..1e23bb8c8332 100644
--- a/drivers/leds/leds-netxbig.c
+++ b/drivers/leds/leds-netxbig.c
@@ -565,7 +565,7 @@ static int netxbig_led_probe(struct platform_device *pdev)
 	}
 
 	leds_data = devm_kzalloc(&pdev->dev,
-				 pdata->num_leds * sizeof(*leds_data),
+				 array_size(pdata->num_leds, sizeof(*leds_data)),
 				 GFP_KERNEL);
 	if (!leds_data)
 		return -ENOMEM;
diff --git a/drivers/leds/leds-pca955x.c b/drivers/leds/leds-pca955x.c
index 78183f90820e..362ff1cb3dae 100644
--- a/drivers/leds/leds-pca955x.c
+++ b/drivers/leds/leds-pca955x.c
@@ -391,7 +391,7 @@ pca955x_pdata_of_init(struct i2c_client *client, struct pca955x_chipdef *chip)
 		return ERR_PTR(-ENOMEM);
 
 	pdata->leds = devm_kzalloc(&client->dev,
-				   sizeof(struct pca955x_led) * chip->bits,
+				   array_size(sizeof(struct pca955x_led), chip->bits),
 				   GFP_KERNEL);
 	if (!pdata->leds)
 		return ERR_PTR(-ENOMEM);
@@ -495,7 +495,8 @@ static int pca955x_probe(struct i2c_client *client,
 		return -ENOMEM;
 
 	pca955x->leds = devm_kzalloc(&client->dev,
-			sizeof(*pca955x_led) * chip->bits, GFP_KERNEL);
+				     array_size(sizeof(*pca955x_led), chip->bits),
+				     GFP_KERNEL);
 	if (!pca955x->leds)
 		return -ENOMEM;
 
diff --git a/drivers/leds/leds-pca963x.c b/drivers/leds/leds-pca963x.c
index 3bf9a1271819..38e9a832db21 100644
--- a/drivers/leds/leds-pca963x.c
+++ b/drivers/leds/leds-pca963x.c
@@ -301,7 +301,8 @@ pca963x_dt_init(struct i2c_client *client, struct pca963x_chipdef *chip)
 		return ERR_PTR(-ENODEV);
 
 	pca963x_leds = devm_kzalloc(&client->dev,
-			sizeof(struct led_info) * chip->n_leds, GFP_KERNEL);
+				    array_size(sizeof(struct led_info), chip->n_leds),
+				    GFP_KERNEL);
 	if (!pca963x_leds)
 		return ERR_PTR(-ENOMEM);
 
@@ -407,8 +408,9 @@ static int pca963x_probe(struct i2c_client *client,
 								GFP_KERNEL);
 	if (!pca963x_chip)
 		return -ENOMEM;
-	pca963x = devm_kzalloc(&client->dev, chip->n_leds * sizeof(*pca963x),
-								GFP_KERNEL);
+	pca963x = devm_kzalloc(&client->dev,
+			       array_size(chip->n_leds, sizeof(*pca963x)),
+			       GFP_KERNEL);
 	if (!pca963x)
 		return -ENOMEM;
 
diff --git a/drivers/mailbox/hi6220-mailbox.c b/drivers/mailbox/hi6220-mailbox.c
index 519376d3534c..cf84c120c3a9 100644
--- a/drivers/mailbox/hi6220-mailbox.c
+++ b/drivers/mailbox/hi6220-mailbox.c
@@ -283,12 +283,14 @@ static int hi6220_mbox_probe(struct platform_device *pdev)
 	mbox->dev = dev;
 	mbox->chan_num = MBOX_CHAN_MAX;
 	mbox->mchan = devm_kzalloc(dev,
-		mbox->chan_num * sizeof(*mbox->mchan), GFP_KERNEL);
+				   array_size(mbox->chan_num, sizeof(*mbox->mchan)),
+				   GFP_KERNEL);
 	if (!mbox->mchan)
 		return -ENOMEM;
 
 	mbox->chan = devm_kzalloc(dev,
-		mbox->chan_num * sizeof(*mbox->chan), GFP_KERNEL);
+				  array_size(mbox->chan_num, sizeof(*mbox->chan)),
+				  GFP_KERNEL);
 	if (!mbox->chan)
 		return -ENOMEM;
 
diff --git a/drivers/mailbox/omap-mailbox.c b/drivers/mailbox/omap-mailbox.c
index d9709f32f578..2ca04f1aa15b 100644
--- a/drivers/mailbox/omap-mailbox.c
+++ b/drivers/mailbox/omap-mailbox.c
@@ -781,12 +781,14 @@ static int omap_mbox_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	/* allocate one extra for marking end of list */
-	list = devm_kzalloc(&pdev->dev, (info_count + 1) * sizeof(*list),
+	list = devm_kzalloc(&pdev->dev,
+			    array_size((info_count + 1), sizeof(*list)),
 			    GFP_KERNEL);
 	if (!list)
 		return -ENOMEM;
 
-	chnls = devm_kzalloc(&pdev->dev, (info_count + 1) * sizeof(*chnls),
+	chnls = devm_kzalloc(&pdev->dev,
+			     array_size((info_count + 1), sizeof(*chnls)),
 			     GFP_KERNEL);
 	if (!chnls)
 		return -ENOMEM;
diff --git a/drivers/media/platform/am437x/am437x-vpfe.c b/drivers/media/platform/am437x/am437x-vpfe.c
index 601ae6487617..e9ecab990ff9 100644
--- a/drivers/media/platform/am437x/am437x-vpfe.c
+++ b/drivers/media/platform/am437x/am437x-vpfe.c
@@ -2586,8 +2586,9 @@ static int vpfe_probe(struct platform_device *pdev)
 
 	pm_runtime_put_sync(&pdev->dev);
 
-	vpfe->sd = devm_kzalloc(&pdev->dev, sizeof(struct v4l2_subdev *) *
-				ARRAY_SIZE(vpfe->cfg->asd), GFP_KERNEL);
+	vpfe->sd = devm_kzalloc(&pdev->dev,
+				array_size(sizeof(struct v4l2_subdev *), ARRAY_SIZE(vpfe->cfg->asd)),
+				GFP_KERNEL);
 	if (!vpfe->sd) {
 		ret = -ENOMEM;
 		goto probe_out_v4l2_unregister;
diff --git a/drivers/media/platform/qcom/camss-8x16/camss-csid.c b/drivers/media/platform/qcom/camss-8x16/camss-csid.c
index 64df82817de3..cee01659c431 100644
--- a/drivers/media/platform/qcom/camss-8x16/camss-csid.c
+++ b/drivers/media/platform/qcom/camss-8x16/camss-csid.c
@@ -845,8 +845,9 @@ int msm_csid_subdev_init(struct csid_device *csid,
 	while (res->clock[csid->nclocks])
 		csid->nclocks++;
 
-	csid->clock = devm_kzalloc(dev, csid->nclocks * sizeof(*csid->clock),
-				    GFP_KERNEL);
+	csid->clock = devm_kzalloc(dev,
+				   array_size(csid->nclocks, sizeof(*csid->clock)),
+				   GFP_KERNEL);
 	if (!csid->clock)
 		return -ENOMEM;
 
@@ -868,8 +869,9 @@ int msm_csid_subdev_init(struct csid_device *csid,
 			continue;
 		}
 
-		clock->freq = devm_kzalloc(dev, clock->nfreqs *
-					   sizeof(*clock->freq), GFP_KERNEL);
+		clock->freq = devm_kzalloc(dev,
+					   array_size(clock->nfreqs, sizeof(*clock->freq)),
+					   GFP_KERNEL);
 		if (!clock->freq)
 			return -ENOMEM;
 
diff --git a/drivers/media/platform/qcom/camss-8x16/camss-csiphy.c b/drivers/media/platform/qcom/camss-8x16/camss-csiphy.c
index 072c6cf053f6..522026f16853 100644
--- a/drivers/media/platform/qcom/camss-8x16/camss-csiphy.c
+++ b/drivers/media/platform/qcom/camss-8x16/camss-csiphy.c
@@ -732,8 +732,9 @@ int msm_csiphy_subdev_init(struct csiphy_device *csiphy,
 	while (res->clock[csiphy->nclocks])
 		csiphy->nclocks++;
 
-	csiphy->clock = devm_kzalloc(dev, csiphy->nclocks *
-				     sizeof(*csiphy->clock), GFP_KERNEL);
+	csiphy->clock = devm_kzalloc(dev,
+				     array_size(csiphy->nclocks, sizeof(*csiphy->clock)),
+				     GFP_KERNEL);
 	if (!csiphy->clock)
 		return -ENOMEM;
 
@@ -755,8 +756,9 @@ int msm_csiphy_subdev_init(struct csiphy_device *csiphy,
 			continue;
 		}
 
-		clock->freq = devm_kzalloc(dev, clock->nfreqs *
-					   sizeof(*clock->freq), GFP_KERNEL);
+		clock->freq = devm_kzalloc(dev,
+					   array_size(clock->nfreqs, sizeof(*clock->freq)),
+					   GFP_KERNEL);
 		if (!clock->freq)
 			return -ENOMEM;
 
diff --git a/drivers/media/platform/qcom/camss-8x16/camss-ispif.c b/drivers/media/platform/qcom/camss-8x16/camss-ispif.c
index 24da529397b5..b15afee3fd17 100644
--- a/drivers/media/platform/qcom/camss-8x16/camss-ispif.c
+++ b/drivers/media/platform/qcom/camss-8x16/camss-ispif.c
@@ -948,7 +948,8 @@ int msm_ispif_subdev_init(struct ispif_device *ispif,
 	while (res->clock[ispif->nclocks])
 		ispif->nclocks++;
 
-	ispif->clock = devm_kzalloc(dev, ispif->nclocks * sizeof(*ispif->clock),
+	ispif->clock = devm_kzalloc(dev,
+				    array_size(ispif->nclocks, sizeof(*ispif->clock)),
 				    GFP_KERNEL);
 	if (!ispif->clock)
 		return -ENOMEM;
@@ -968,8 +969,9 @@ int msm_ispif_subdev_init(struct ispif_device *ispif,
 	while (res->clock_for_reset[ispif->nclocks_for_reset])
 		ispif->nclocks_for_reset++;
 
-	ispif->clock_for_reset = devm_kzalloc(dev, ispif->nclocks_for_reset *
-			sizeof(*ispif->clock_for_reset), GFP_KERNEL);
+	ispif->clock_for_reset = devm_kzalloc(dev,
+					      array_size(ispif->nclocks_for_reset, sizeof(*ispif->clock_for_reset)),
+					      GFP_KERNEL);
 	if (!ispif->clock_for_reset)
 		return -ENOMEM;
 
diff --git a/drivers/media/platform/qcom/camss-8x16/camss-vfe.c b/drivers/media/platform/qcom/camss-8x16/camss-vfe.c
index 55232a912950..0d9a46004f58 100644
--- a/drivers/media/platform/qcom/camss-8x16/camss-vfe.c
+++ b/drivers/media/platform/qcom/camss-8x16/camss-vfe.c
@@ -2794,7 +2794,8 @@ int msm_vfe_subdev_init(struct vfe_device *vfe, const struct resources *res)
 	while (res->clock[vfe->nclocks])
 		vfe->nclocks++;
 
-	vfe->clock = devm_kzalloc(dev, vfe->nclocks * sizeof(*vfe->clock),
+	vfe->clock = devm_kzalloc(dev,
+				  array_size(vfe->nclocks, sizeof(*vfe->clock)),
 				  GFP_KERNEL);
 	if (!vfe->clock)
 		return -ENOMEM;
@@ -2817,8 +2818,9 @@ int msm_vfe_subdev_init(struct vfe_device *vfe, const struct resources *res)
 			continue;
 		}
 
-		clock->freq = devm_kzalloc(dev, clock->nfreqs *
-					   sizeof(*clock->freq), GFP_KERNEL);
+		clock->freq = devm_kzalloc(dev,
+					   array_size(clock->nfreqs, sizeof(*clock->freq)),
+					   GFP_KERNEL);
 		if (!clock->freq)
 			return -ENOMEM;
 
diff --git a/drivers/media/platform/qcom/camss-8x16/camss.c b/drivers/media/platform/qcom/camss-8x16/camss.c
index 05f06c98aa64..c6223c707432 100644
--- a/drivers/media/platform/qcom/camss-8x16/camss.c
+++ b/drivers/media/platform/qcom/camss-8x16/camss.c
@@ -271,7 +271,8 @@ static int camss_of_parse_endpoint_node(struct device *dev,
 	lncfg->clk.pol = mipi_csi2->lane_polarities[0];
 	lncfg->num_data = mipi_csi2->num_data_lanes;
 
-	lncfg->data = devm_kzalloc(dev, lncfg->num_data * sizeof(*lncfg->data),
+	lncfg->data = devm_kzalloc(dev,
+				   array_size(lncfg->num_data, sizeof(*lncfg->data)),
 				   GFP_KERNEL);
 	if (!lncfg->data)
 		return -ENOMEM;
diff --git a/drivers/media/v4l2-core/v4l2-flash-led-class.c b/drivers/media/v4l2-core/v4l2-flash-led-class.c
index 4ceef217de83..26a648e1c1df 100644
--- a/drivers/media/v4l2-core/v4l2-flash-led-class.c
+++ b/drivers/media/v4l2-core/v4l2-flash-led-class.c
@@ -413,8 +413,8 @@ static int v4l2_flash_init_controls(struct v4l2_flash *v4l2_flash,
 	int i, ret, num_ctrls = 0;
 
 	v4l2_flash->ctrls = devm_kzalloc(v4l2_flash->sd.dev,
-					sizeof(*v4l2_flash->ctrls) *
-					(STROBE_SOURCE + 1), GFP_KERNEL);
+					 array_size(sizeof(*v4l2_flash->ctrls), (STROBE_SOURCE + 1)),
+					 GFP_KERNEL);
 	if (!v4l2_flash->ctrls)
 		return -ENOMEM;
 
diff --git a/drivers/mfd/htc-i2cpld.c b/drivers/mfd/htc-i2cpld.c
index 3f9eee5f8fb9..ef9a1aabd1e0 100644
--- a/drivers/mfd/htc-i2cpld.c
+++ b/drivers/mfd/htc-i2cpld.c
@@ -477,7 +477,8 @@ static int htcpld_setup_chips(struct platform_device *pdev)
 
 	/* Setup each chip's output GPIOs */
 	htcpld->nchips = pdata->num_chip;
-	htcpld->chip = devm_kzalloc(dev, sizeof(struct htcpld_chip) * htcpld->nchips,
+	htcpld->chip = devm_kzalloc(dev,
+				    array_size(sizeof(struct htcpld_chip), htcpld->nchips),
 				    GFP_KERNEL);
 	if (!htcpld->chip) {
 		dev_warn(dev, "Unable to allocate memory for chips\n");
diff --git a/drivers/mfd/motorola-cpcap.c b/drivers/mfd/motorola-cpcap.c
index d2cc1eabac05..8198c9c25a9e 100644
--- a/drivers/mfd/motorola-cpcap.c
+++ b/drivers/mfd/motorola-cpcap.c
@@ -173,9 +173,7 @@ static int cpcap_init_irq(struct cpcap_ddata *cpcap)
 	int ret;
 
 	cpcap->irqs = devm_kzalloc(&cpcap->spi->dev,
-				   sizeof(*cpcap->irqs) *
-				   CPCAP_NR_IRQ_REG_BANKS *
-				   cpcap->regmap_conf->val_bits,
+				   array3_size(sizeof(*cpcap->irqs), CPCAP_NR_IRQ_REG_BANKS, cpcap->regmap_conf->val_bits),
 				   GFP_KERNEL);
 	if (!cpcap->irqs)
 		return -ENOMEM;
diff --git a/drivers/mfd/omap-usb-tll.c b/drivers/mfd/omap-usb-tll.c
index 44a5d66314c6..65b05566c381 100644
--- a/drivers/mfd/omap-usb-tll.c
+++ b/drivers/mfd/omap-usb-tll.c
@@ -254,8 +254,9 @@ static int usbtll_omap_probe(struct platform_device *pdev)
 		break;
 	}
 
-	tll->ch_clk = devm_kzalloc(dev, sizeof(struct clk *) * tll->nch,
-						GFP_KERNEL);
+	tll->ch_clk = devm_kzalloc(dev,
+				   array_size(sizeof(struct clk *), tll->nch),
+				   GFP_KERNEL);
 	if (!tll->ch_clk) {
 		ret = -ENOMEM;
 		dev_err(dev, "Couldn't allocate memory for channel clocks\n");
diff --git a/drivers/mfd/sprd-sc27xx-spi.c b/drivers/mfd/sprd-sc27xx-spi.c
index 56a4782f0569..36533a2bf18e 100644
--- a/drivers/mfd/sprd-sc27xx-spi.c
+++ b/drivers/mfd/sprd-sc27xx-spi.c
@@ -196,8 +196,9 @@ static int sprd_pmic_probe(struct spi_device *spi)
 	ddata->irq_chip.num_irqs = pdata->num_irqs;
 	ddata->irq_chip.mask_invert = true;
 
-	ddata->irqs = devm_kzalloc(&spi->dev, sizeof(struct regmap_irq) *
-				   pdata->num_irqs, GFP_KERNEL);
+	ddata->irqs = devm_kzalloc(&spi->dev,
+				   array_size(sizeof(struct regmap_irq), pdata->num_irqs),
+				   GFP_KERNEL);
 	if (!ddata->irqs)
 		return -ENOMEM;
 
diff --git a/drivers/mfd/wm8994-core.c b/drivers/mfd/wm8994-core.c
index 953d0790ffd5..9429c7c9d86b 100644
--- a/drivers/mfd/wm8994-core.c
+++ b/drivers/mfd/wm8994-core.c
@@ -369,8 +369,8 @@ static int wm8994_device_init(struct wm8994 *wm8994, int irq)
 	}
 
 	wm8994->supplies = devm_kzalloc(wm8994->dev,
-					sizeof(struct regulator_bulk_data) *
-					wm8994->num_supplies, GFP_KERNEL);
+					array_size(sizeof(struct regulator_bulk_data), wm8994->num_supplies),
+					GFP_KERNEL);
 	if (!wm8994->supplies) {
 		ret = -ENOMEM;
 		goto err;
diff --git a/drivers/mmc/host/sdhci-omap.c b/drivers/mmc/host/sdhci-omap.c
index 1456abd5eeb9..6a47fca6117b 100644
--- a/drivers/mmc/host/sdhci-omap.c
+++ b/drivers/mmc/host/sdhci-omap.c
@@ -762,8 +762,9 @@ static int sdhci_omap_config_iodelay_pinctrl_state(struct sdhci_omap_host
 	if (!(omap_host->flags & SDHCI_OMAP_REQUIRE_IODELAY))
 		return 0;
 
-	pinctrl_state = devm_kzalloc(dev, sizeof(*pinctrl_state) *
-				     (MMC_TIMING_MMC_HS200 + 1), GFP_KERNEL);
+	pinctrl_state = devm_kzalloc(dev,
+				     array_size(sizeof(*pinctrl_state), (MMC_TIMING_MMC_HS200 + 1)),
+				     GFP_KERNEL);
 	if (!pinctrl_state)
 		return -ENOMEM;
 
diff --git a/drivers/mtd/nand/raw/s3c2410.c b/drivers/mtd/nand/raw/s3c2410.c
index 1bc0458063d8..015abf1fc2a3 100644
--- a/drivers/mtd/nand/raw/s3c2410.c
+++ b/drivers/mtd/nand/raw/s3c2410.c
@@ -1038,7 +1038,8 @@ static int s3c24xx_nand_probe_dt(struct platform_device *pdev)
 	if (!pdata->nr_sets)
 		return 0;
 
-	sets = devm_kzalloc(&pdev->dev, sizeof(*sets) * pdata->nr_sets,
+	sets = devm_kzalloc(&pdev->dev,
+			    array_size(sizeof(*sets), pdata->nr_sets),
 			    GFP_KERNEL);
 	if (!sets)
 		return -ENOMEM;
diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 78616787f2a3..45623e705627 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1955,13 +1955,13 @@ static int b53_switch_init(struct b53_device *dev)
 	dev->enabled_ports |= BIT(dev->cpu_port);
 
 	dev->ports = devm_kzalloc(dev->dev,
-				  sizeof(struct b53_port) * dev->num_ports,
+				  array_size(sizeof(struct b53_port), dev->num_ports),
 				  GFP_KERNEL);
 	if (!dev->ports)
 		return -ENOMEM;
 
 	dev->vlans = devm_kzalloc(dev->dev,
-				  sizeof(struct b53_vlan) * dev->num_vlans,
+				  array_size(sizeof(struct b53_vlan), dev->num_vlans),
 				  GFP_KERNEL);
 	if (!dev->vlans)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3_enet.c
index 8c55965a66ac..c0b464299084 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3_enet.c
@@ -2879,8 +2879,8 @@ static int hns3_get_ring_config(struct hns3_nic_priv *priv)
 	struct pci_dev *pdev = h->pdev;
 	int i, ret;
 
-	priv->ring_data =  devm_kzalloc(&pdev->dev, h->kinfo.num_tqps *
-					sizeof(*priv->ring_data) * 2,
+	priv->ring_data =  devm_kzalloc(&pdev->dev,
+					array3_size(h->kinfo.num_tqps, sizeof(*priv->ring_data), 2),
 					GFP_KERNEL);
 	if (!priv->ring_data)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 28d893b93d30..38ab898a850d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2706,8 +2706,8 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->active_slave = prop;
 
-	data->slave_data = devm_kzalloc(&pdev->dev, data->slaves
-					* sizeof(struct cpsw_slave_data),
+	data->slave_data = devm_kzalloc(&pdev->dev,
+					array_size(data->slaves, sizeof(struct cpsw_slave_data)),
 					GFP_KERNEL);
 	if (!data->slave_data)
 		return -ENOMEM;
@@ -3036,7 +3036,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
 
 	cpsw->slaves = devm_kzalloc(&pdev->dev,
-				    sizeof(struct cpsw_slave) * data->slaves,
+				    array_size(sizeof(struct cpsw_slave), data->slaves),
 				    GFP_KERNEL);
 	if (!cpsw->slaves) {
 		ret = -ENOMEM;
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 56dbc0b9fedc..7912ae57d611 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -3171,7 +3171,7 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->num_et_stats = ARRAY_SIZE(xgbe10_et_stats);
 
 	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
-					 gbe_dev->num_et_stats * sizeof(u64),
+					 array_size(gbe_dev->num_et_stats, sizeof(u64)),
 					 GFP_KERNEL);
 	if (!gbe_dev->hw_stats) {
 		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
@@ -3180,7 +3180,7 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 
 	gbe_dev->hw_stats_prev =
 		devm_kzalloc(gbe_dev->dev,
-			     gbe_dev->num_et_stats * sizeof(u32),
+			     array_size(gbe_dev->num_et_stats, sizeof(u32)),
 			     GFP_KERNEL);
 	if (!gbe_dev->hw_stats_prev) {
 		dev_err(gbe_dev->dev,
@@ -3291,7 +3291,7 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->num_et_stats = ARRAY_SIZE(gbe13_et_stats);
 
 	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
-					 gbe_dev->num_et_stats * sizeof(u64),
+					 array_size(gbe_dev->num_et_stats, sizeof(u64)),
 					 GFP_KERNEL);
 	if (!gbe_dev->hw_stats) {
 		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
@@ -3300,7 +3300,7 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 
 	gbe_dev->hw_stats_prev =
 		devm_kzalloc(gbe_dev->dev,
-			     gbe_dev->num_et_stats * sizeof(u32),
+			     array_size(gbe_dev->num_et_stats, sizeof(u32)),
 			     GFP_KERNEL);
 	if (!gbe_dev->hw_stats_prev) {
 		dev_err(gbe_dev->dev,
@@ -3363,7 +3363,7 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 					GBENU_ET_STATS_PORT_SIZE;
 
 	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
-					 gbe_dev->num_et_stats * sizeof(u64),
+					 array_size(gbe_dev->num_et_stats, sizeof(u64)),
 					 GFP_KERNEL);
 	if (!gbe_dev->hw_stats) {
 		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
@@ -3372,7 +3372,7 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 
 	gbe_dev->hw_stats_prev =
 		devm_kzalloc(gbe_dev->dev,
-			     gbe_dev->num_et_stats * sizeof(u32),
+			     array_size(gbe_dev->num_et_stats, sizeof(u32)),
 			     GFP_KERNEL);
 	if (!gbe_dev->hw_stats_prev) {
 		dev_err(gbe_dev->dev,
diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
index 39ecad25b201..4375cab832d9 100644
--- a/drivers/net/phy/phy_led_triggers.c
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -129,9 +129,8 @@ int phy_led_triggers_register(struct phy_device *phy)
 		goto out_free_link;
 
 	phy->phy_led_triggers = devm_kzalloc(&phy->mdio.dev,
-					    sizeof(struct phy_led_trigger) *
-						   phy->phy_num_led_triggers,
-					    GFP_KERNEL);
+					     array_size(sizeof(struct phy_led_trigger), phy->phy_num_led_triggers),
+					     GFP_KERNEL);
 	if (!phy->phy_led_triggers) {
 		err = -ENOMEM;
 		goto out_unreg_link;
diff --git a/drivers/pci/cadence/pcie-cadence-ep.c b/drivers/pci/cadence/pcie-cadence-ep.c
index 3d8283e450a9..5699adafe491 100644
--- a/drivers/pci/cadence/pcie-cadence-ep.c
+++ b/drivers/pci/cadence/pcie-cadence-ep.c
@@ -467,7 +467,8 @@ static int cdns_pcie_ep_probe(struct platform_device *pdev)
 		dev_err(dev, "missing \"cdns,max-outbound-regions\"\n");
 		return ret;
 	}
-	ep->ob_addr = devm_kzalloc(dev, ep->max_regions * sizeof(*ep->ob_addr),
+	ep->ob_addr = devm_kzalloc(dev,
+				   array_size(ep->max_regions, sizeof(*ep->ob_addr)),
 				   GFP_KERNEL);
 	if (!ep->ob_addr)
 		return -ENOMEM;
diff --git a/drivers/pci/dwc/pcie-designware-ep.c b/drivers/pci/dwc/pcie-designware-ep.c
index f07678bf7cfc..58c108099d84 100644
--- a/drivers/pci/dwc/pcie-designware-ep.c
+++ b/drivers/pci/dwc/pcie-designware-ep.c
@@ -366,19 +366,20 @@ int dw_pcie_ep_init(struct dw_pcie_ep *ep)
 		return -EINVAL;
 	}
 
-	ep->ib_window_map = devm_kzalloc(dev, sizeof(long) *
-					 BITS_TO_LONGS(ep->num_ib_windows),
+	ep->ib_window_map = devm_kzalloc(dev,
+					 array_size(sizeof(long), BITS_TO_LONGS(ep->num_ib_windows)),
 					 GFP_KERNEL);
 	if (!ep->ib_window_map)
 		return -ENOMEM;
 
-	ep->ob_window_map = devm_kzalloc(dev, sizeof(long) *
-					 BITS_TO_LONGS(ep->num_ob_windows),
+	ep->ob_window_map = devm_kzalloc(dev,
+					 array_size(sizeof(long), BITS_TO_LONGS(ep->num_ob_windows)),
 					 GFP_KERNEL);
 	if (!ep->ob_window_map)
 		return -ENOMEM;
 
-	addr = devm_kzalloc(dev, sizeof(phys_addr_t) * ep->num_ob_windows,
+	addr = devm_kzalloc(dev,
+			    array_size(sizeof(phys_addr_t), ep->num_ob_windows),
 			    GFP_KERNEL);
 	if (!addr)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/berlin/berlin.c b/drivers/pinctrl/berlin/berlin.c
index 4b710037cea6..6c6012877c6f 100644
--- a/drivers/pinctrl/berlin/berlin.c
+++ b/drivers/pinctrl/berlin/berlin.c
@@ -265,7 +265,7 @@ static int berlin_pinctrl_build_state(struct platform_device *pdev)
 			if (!function->groups) {
 				function->groups =
 					devm_kzalloc(&pdev->dev,
-						     function->ngroups * sizeof(char *),
+						     array_size(function->ngroups, sizeof(char *)),
 						     GFP_KERNEL);
 
 				if (!function->groups)
diff --git a/drivers/pinctrl/freescale/pinctrl-imx.c b/drivers/pinctrl/freescale/pinctrl-imx.c
index 8734e5f05b46..1a31b8df3da3 100644
--- a/drivers/pinctrl/freescale/pinctrl-imx.c
+++ b/drivers/pinctrl/freescale/pinctrl-imx.c
@@ -475,10 +475,12 @@ static int imx_pinctrl_parse_groups(struct device_node *np,
 	config = imx_pinconf_parse_generic_config(np, ipctl);
 
 	grp->num_pins = size / pin_size;
-	grp->data = devm_kzalloc(ipctl->dev, grp->num_pins *
-				 sizeof(struct imx_pin), GFP_KERNEL);
-	grp->pins = devm_kzalloc(ipctl->dev, grp->num_pins *
-				 sizeof(unsigned int), GFP_KERNEL);
+	grp->data = devm_kzalloc(ipctl->dev,
+				 array_size(grp->num_pins, sizeof(struct imx_pin)),
+				 GFP_KERNEL);
+	grp->pins = devm_kzalloc(ipctl->dev,
+				 array_size(grp->num_pins, sizeof(unsigned int)),
+				 GFP_KERNEL);
 	if (!grp->pins || !grp->data)
 		return -ENOMEM;
 
@@ -696,8 +698,9 @@ int imx_pinctrl_probe(struct platform_device *pdev,
 	if (!ipctl)
 		return -ENOMEM;
 
-	ipctl->pin_regs = devm_kmalloc(&pdev->dev, sizeof(*ipctl->pin_regs) *
-				      info->npins, GFP_KERNEL);
+	ipctl->pin_regs = devm_kmalloc(&pdev->dev,
+				       array_size(sizeof(*ipctl->pin_regs), info->npins),
+				       GFP_KERNEL);
 	if (!ipctl->pin_regs)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/freescale/pinctrl-imx1-core.c b/drivers/pinctrl/freescale/pinctrl-imx1-core.c
index ebf32b65d822..730f7178414c 100644
--- a/drivers/pinctrl/freescale/pinctrl-imx1-core.c
+++ b/drivers/pinctrl/freescale/pinctrl-imx1-core.c
@@ -489,9 +489,11 @@ static int imx1_pinctrl_parse_groups(struct device_node *np,
 
 	grp->npins = size / 12;
 	grp->pins = devm_kzalloc(info->dev,
-			grp->npins * sizeof(struct imx1_pin), GFP_KERNEL);
+				 array_size(grp->npins, sizeof(struct imx1_pin)),
+				 GFP_KERNEL);
 	grp->pin_ids = devm_kzalloc(info->dev,
-			grp->npins * sizeof(unsigned int), GFP_KERNEL);
+				    array_size(grp->npins, sizeof(unsigned int)),
+				    GFP_KERNEL);
 
 	if (!grp->pins || !grp->pin_ids)
 		return -ENOMEM;
@@ -529,7 +531,8 @@ static int imx1_pinctrl_parse_functions(struct device_node *np,
 		return -EINVAL;
 
 	func->groups = devm_kzalloc(info->dev,
-			func->num_groups * sizeof(char *), GFP_KERNEL);
+				    array_size(func->num_groups, sizeof(char *)),
+				    GFP_KERNEL);
 
 	if (!func->groups)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/freescale/pinctrl-mxs.c b/drivers/pinctrl/freescale/pinctrl-mxs.c
index ea3bb26b0c3e..e9689b23b9a8 100644
--- a/drivers/pinctrl/freescale/pinctrl-mxs.c
+++ b/drivers/pinctrl/freescale/pinctrl-mxs.c
@@ -377,12 +377,14 @@ static int mxs_pinctrl_parse_group(struct platform_device *pdev,
 		return -EINVAL;
 	g->npins = length / sizeof(u32);
 
-	g->pins = devm_kzalloc(&pdev->dev, g->npins * sizeof(*g->pins),
+	g->pins = devm_kzalloc(&pdev->dev,
+			       array_size(g->npins, sizeof(*g->pins)),
 			       GFP_KERNEL);
 	if (!g->pins)
 		return -ENOMEM;
 
-	g->muxsel = devm_kzalloc(&pdev->dev, g->npins * sizeof(*g->muxsel),
+	g->muxsel = devm_kzalloc(&pdev->dev,
+				 array_size(g->npins, sizeof(*g->muxsel)),
 				 GFP_KERNEL);
 	if (!g->muxsel)
 		return -ENOMEM;
@@ -433,13 +435,15 @@ static int mxs_pinctrl_probe_dt(struct platform_device *pdev,
 		}
 	}
 
-	soc->functions = devm_kzalloc(&pdev->dev, soc->nfunctions *
-				      sizeof(*soc->functions), GFP_KERNEL);
+	soc->functions = devm_kzalloc(&pdev->dev,
+				      array_size(soc->nfunctions, sizeof(*soc->functions)),
+				      GFP_KERNEL);
 	if (!soc->functions)
 		return -ENOMEM;
 
-	soc->groups = devm_kzalloc(&pdev->dev, soc->ngroups *
-				   sizeof(*soc->groups), GFP_KERNEL);
+	soc->groups = devm_kzalloc(&pdev->dev,
+				   array_size(soc->ngroups, sizeof(*soc->groups)),
+				   GFP_KERNEL);
 	if (!soc->groups)
 		return -ENOMEM;
 
@@ -499,8 +503,8 @@ static int mxs_pinctrl_probe_dt(struct platform_device *pdev,
 
 		if (strcmp(fn, child->name)) {
 			f = &soc->functions[idxf++];
-			f->groups = devm_kzalloc(&pdev->dev, f->ngroups *
-						 sizeof(*f->groups),
+			f->groups = devm_kzalloc(&pdev->dev,
+						 array_size(f->ngroups, sizeof(*f->groups)),
 						 GFP_KERNEL);
 			if (!f->groups)
 				return -ENOMEM;
diff --git a/drivers/pinctrl/mvebu/pinctrl-armada-37xx.c b/drivers/pinctrl/mvebu/pinctrl-armada-37xx.c
index 5b63248c8209..d8baecb3890a 100644
--- a/drivers/pinctrl/mvebu/pinctrl-armada-37xx.c
+++ b/drivers/pinctrl/mvebu/pinctrl-armada-37xx.c
@@ -869,8 +869,8 @@ static int armada_37xx_fill_group(struct armada_37xx_pinctrl *info)
 		int i, j, f;
 
 		grp->pins = devm_kzalloc(info->dev,
-					 (grp->npins + grp->extra_npins) *
-					 sizeof(*grp->pins), GFP_KERNEL);
+					 array_size((grp->npins + grp->extra_npins), sizeof(*grp->pins)),
+					 GFP_KERNEL);
 		if (!grp->pins)
 			return -ENOMEM;
 
@@ -920,8 +920,8 @@ static int armada_37xx_fill_func(struct armada_37xx_pinctrl *info)
 		const char **groups;
 		int g;
 
-		funcs[n].groups = devm_kzalloc(info->dev, funcs[n].ngroups *
-					       sizeof(*(funcs[n].groups)),
+		funcs[n].groups = devm_kzalloc(info->dev,
+					       array_size(funcs[n].ngroups, sizeof(*(funcs[n].groups))),
 					       GFP_KERNEL);
 		if (!funcs[n].groups)
 			return -ENOMEM;
@@ -960,8 +960,9 @@ static int armada_37xx_pinctrl_register(struct platform_device *pdev,
 	ctrldesc->pmxops = &armada_37xx_pmx_ops;
 	ctrldesc->confops = &armada_37xx_pinconf_ops;
 
-	pindesc = devm_kzalloc(&pdev->dev, sizeof(*pindesc) *
-			       pin_data->nr_pins, GFP_KERNEL);
+	pindesc = devm_kzalloc(&pdev->dev,
+			       array_size(sizeof(*pindesc), pin_data->nr_pins),
+			       GFP_KERNEL);
 	if (!pindesc)
 		return -ENOMEM;
 
@@ -980,8 +981,9 @@ static int armada_37xx_pinctrl_register(struct platform_device *pdev,
 	 * we allocate functions for number of pins and hope there are
 	 * fewer unique functions than pins available
 	 */
-	info->funcs = devm_kzalloc(&pdev->dev, pin_data->nr_pins *
-			   sizeof(struct armada_37xx_pmx_func), GFP_KERNEL);
+	info->funcs = devm_kzalloc(&pdev->dev,
+				   array_size(pin_data->nr_pins, sizeof(struct armada_37xx_pmx_func)),
+				   GFP_KERNEL);
 	if (!info->funcs)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/mvebu/pinctrl-mvebu.c b/drivers/pinctrl/mvebu/pinctrl-mvebu.c
index 437345990da7..3b884fa9e180 100644
--- a/drivers/pinctrl/mvebu/pinctrl-mvebu.c
+++ b/drivers/pinctrl/mvebu/pinctrl-mvebu.c
@@ -551,8 +551,8 @@ static int mvebu_pinctrl_build_functions(struct platform_device *pdev,
 			/* allocate group name array if not done already */
 			if (!f->groups) {
 				f->groups = devm_kzalloc(&pdev->dev,
-						 f->num_groups * sizeof(char *),
-						 GFP_KERNEL);
+							 array_size(f->num_groups, sizeof(char *)),
+							 GFP_KERNEL);
 				if (!f->groups)
 					return -ENOMEM;
 			}
@@ -623,8 +623,9 @@ int mvebu_pinctrl_probe(struct platform_device *pdev)
 		}
 	}
 
-	pdesc = devm_kzalloc(&pdev->dev, pctl->desc.npins *
-			     sizeof(struct pinctrl_pin_desc), GFP_KERNEL);
+	pdesc = devm_kzalloc(&pdev->dev,
+			     array_size(pctl->desc.npins, sizeof(struct pinctrl_pin_desc)),
+			     GFP_KERNEL);
 	if (!pdesc)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-at91-pio4.c b/drivers/pinctrl/pinctrl-at91-pio4.c
index 4b57a13758a4..5287e07ccf37 100644
--- a/drivers/pinctrl/pinctrl-at91-pio4.c
+++ b/drivers/pinctrl/pinctrl-at91-pio4.c
@@ -943,28 +943,31 @@ static int atmel_pinctrl_probe(struct platform_device *pdev)
 		return PTR_ERR(atmel_pioctrl->clk);
 	}
 
-	atmel_pioctrl->pins = devm_kzalloc(dev, sizeof(*atmel_pioctrl->pins)
-			* atmel_pioctrl->npins, GFP_KERNEL);
+	atmel_pioctrl->pins = devm_kzalloc(dev,
+					   array_size(sizeof(*atmel_pioctrl->pins), atmel_pioctrl->npins),
+					   GFP_KERNEL);
 	if (!atmel_pioctrl->pins)
 		return -ENOMEM;
 
-	pin_desc = devm_kzalloc(dev, sizeof(*pin_desc)
-			* atmel_pioctrl->npins, GFP_KERNEL);
+	pin_desc = devm_kzalloc(dev,
+				array_size(sizeof(*pin_desc), atmel_pioctrl->npins),
+				GFP_KERNEL);
 	if (!pin_desc)
 		return -ENOMEM;
 	atmel_pinctrl_desc.pins = pin_desc;
 	atmel_pinctrl_desc.npins = atmel_pioctrl->npins;
 
 	/* One pin is one group since a pin can achieve all functions. */
-	group_names = devm_kzalloc(dev, sizeof(*group_names)
-			* atmel_pioctrl->npins, GFP_KERNEL);
+	group_names = devm_kzalloc(dev,
+				   array_size(sizeof(*group_names), atmel_pioctrl->npins),
+				   GFP_KERNEL);
 	if (!group_names)
 		return -ENOMEM;
 	atmel_pioctrl->group_names = group_names;
 
 	atmel_pioctrl->groups = devm_kzalloc(&pdev->dev,
-			sizeof(*atmel_pioctrl->groups) * atmel_pioctrl->npins,
-			GFP_KERNEL);
+					     array_size(sizeof(*atmel_pioctrl->groups), atmel_pioctrl->npins),
+					     GFP_KERNEL);
 	if (!atmel_pioctrl->groups)
 		return -ENOMEM;
 	for (i = 0 ; i < atmel_pioctrl->npins; i++) {
@@ -1000,19 +1003,20 @@ static int atmel_pinctrl_probe(struct platform_device *pdev)
 	atmel_pioctrl->gpio_chip->names = atmel_pioctrl->group_names;
 
 	atmel_pioctrl->pm_wakeup_sources = devm_kzalloc(dev,
-			sizeof(*atmel_pioctrl->pm_wakeup_sources)
-			* atmel_pioctrl->nbanks, GFP_KERNEL);
+							array_size(sizeof(*atmel_pioctrl->pm_wakeup_sources), atmel_pioctrl->nbanks),
+							GFP_KERNEL);
 	if (!atmel_pioctrl->pm_wakeup_sources)
 		return -ENOMEM;
 
 	atmel_pioctrl->pm_suspend_backup = devm_kzalloc(dev,
-			sizeof(*atmel_pioctrl->pm_suspend_backup)
-			* atmel_pioctrl->nbanks, GFP_KERNEL);
+							array_size(sizeof(*atmel_pioctrl->pm_suspend_backup), atmel_pioctrl->nbanks),
+							GFP_KERNEL);
 	if (!atmel_pioctrl->pm_suspend_backup)
 		return -ENOMEM;
 
-	atmel_pioctrl->irqs = devm_kzalloc(dev, sizeof(*atmel_pioctrl->irqs)
-			* atmel_pioctrl->nbanks, GFP_KERNEL);
+	atmel_pioctrl->irqs = devm_kzalloc(dev,
+					   array_size(sizeof(*atmel_pioctrl->irqs), atmel_pioctrl->nbanks),
+					   GFP_KERNEL);
 	if (!atmel_pioctrl->irqs)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-at91.c b/drivers/pinctrl/pinctrl-at91.c
index 2e9224ad8d11..cc04448375d3 100644
--- a/drivers/pinctrl/pinctrl-at91.c
+++ b/drivers/pinctrl/pinctrl-at91.c
@@ -1091,10 +1091,12 @@ static int at91_pinctrl_parse_groups(struct device_node *np,
 	}
 
 	grp->npins = size / 4;
-	pin = grp->pins_conf = devm_kzalloc(info->dev, grp->npins * sizeof(struct at91_pmx_pin),
-				GFP_KERNEL);
-	grp->pins = devm_kzalloc(info->dev, grp->npins * sizeof(unsigned int),
-				GFP_KERNEL);
+	pin = grp->pins_conf = devm_kzalloc(info->dev,
+					    array_size(grp->npins, sizeof(struct at91_pmx_pin)),
+					    GFP_KERNEL);
+	grp->pins = devm_kzalloc(info->dev,
+				 array_size(grp->npins, sizeof(unsigned int)),
+				 GFP_KERNEL);
 	if (!grp->pins_conf || !grp->pins)
 		return -ENOMEM;
 
@@ -1134,7 +1136,8 @@ static int at91_pinctrl_parse_functions(struct device_node *np,
 		return -EINVAL;
 	}
 	func->groups = devm_kzalloc(info->dev,
-			func->ngroups * sizeof(char *), GFP_KERNEL);
+				    array_size(func->ngroups, sizeof(char *)),
+				    GFP_KERNEL);
 	if (!func->groups)
 		return -ENOMEM;
 
@@ -1196,13 +1199,15 @@ static int at91_pinctrl_probe_dt(struct platform_device *pdev,
 
 	dev_dbg(&pdev->dev, "nfunctions = %d\n", info->nfunctions);
 	dev_dbg(&pdev->dev, "ngroups = %d\n", info->ngroups);
-	info->functions = devm_kzalloc(&pdev->dev, info->nfunctions * sizeof(struct at91_pmx_func),
-					GFP_KERNEL);
+	info->functions = devm_kzalloc(&pdev->dev,
+				       array_size(info->nfunctions, sizeof(struct at91_pmx_func)),
+				       GFP_KERNEL);
 	if (!info->functions)
 		return -ENOMEM;
 
-	info->groups = devm_kzalloc(&pdev->dev, info->ngroups * sizeof(struct at91_pin_group),
-					GFP_KERNEL);
+	info->groups = devm_kzalloc(&pdev->dev,
+				    array_size(info->ngroups, sizeof(struct at91_pin_group)),
+				    GFP_KERNEL);
 	if (!info->groups)
 		return -ENOMEM;
 
@@ -1260,7 +1265,9 @@ static int at91_pinctrl_probe(struct platform_device *pdev)
 	at91_pinctrl_desc.name = dev_name(&pdev->dev);
 	at91_pinctrl_desc.npins = gpio_banks * MAX_NB_GPIO_PER_BANK;
 	at91_pinctrl_desc.pins = pdesc =
-		devm_kzalloc(&pdev->dev, sizeof(*pdesc) * at91_pinctrl_desc.npins, GFP_KERNEL);
+		devm_kzalloc(&pdev->dev,
+			     array_size(sizeof(*pdesc), at91_pinctrl_desc.npins),
+			     GFP_KERNEL);
 
 	if (!at91_pinctrl_desc.pins)
 		return -ENOMEM;
@@ -1767,7 +1774,8 @@ static int at91_gpio_probe(struct platform_device *pdev)
 			chip->ngpio = ngpio;
 	}
 
-	names = devm_kzalloc(&pdev->dev, sizeof(char *) * chip->ngpio,
+	names = devm_kzalloc(&pdev->dev,
+			     array_size(sizeof(char *), chip->ngpio),
 			     GFP_KERNEL);
 
 	if (!names) {
diff --git a/drivers/pinctrl/pinctrl-ingenic.c b/drivers/pinctrl/pinctrl-ingenic.c
index ac38a3f9f86b..026b0fc45d8d 100644
--- a/drivers/pinctrl/pinctrl-ingenic.c
+++ b/drivers/pinctrl/pinctrl-ingenic.c
@@ -771,7 +771,8 @@ static int ingenic_pinctrl_probe(struct platform_device *pdev)
 	pctl_desc->confops = &ingenic_confops;
 	pctl_desc->npins = chip_info->num_chips * PINS_PER_GPIO_CHIP;
 	pctl_desc->pins = jzpc->pdesc = devm_kzalloc(&pdev->dev,
-			sizeof(*jzpc->pdesc) * pctl_desc->npins, GFP_KERNEL);
+						     array_size(sizeof(*jzpc->pdesc), pctl_desc->npins),
+						     GFP_KERNEL);
 	if (!jzpc->pdesc)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-rockchip.c b/drivers/pinctrl/pinctrl-rockchip.c
index 5f9e3e3b598c..0031aec54c30 100644
--- a/drivers/pinctrl/pinctrl-rockchip.c
+++ b/drivers/pinctrl/pinctrl-rockchip.c
@@ -2319,11 +2319,12 @@ static int rockchip_pinctrl_parse_groups(struct device_node *np,
 
 	grp->npins = size / 4;
 
-	grp->pins = devm_kzalloc(info->dev, grp->npins * sizeof(unsigned int),
-						GFP_KERNEL);
-	grp->data = devm_kzalloc(info->dev, grp->npins *
-					  sizeof(struct rockchip_pin_config),
-					GFP_KERNEL);
+	grp->pins = devm_kzalloc(info->dev,
+				 array_size(grp->npins, sizeof(unsigned int)),
+				 GFP_KERNEL);
+	grp->data = devm_kzalloc(info->dev,
+				 array_size(grp->npins, sizeof(struct rockchip_pin_config)),
+				 GFP_KERNEL);
 	if (!grp->pins || !grp->data)
 		return -ENOMEM;
 
@@ -2375,7 +2376,8 @@ static int rockchip_pinctrl_parse_functions(struct device_node *np,
 		return 0;
 
 	func->groups = devm_kzalloc(info->dev,
-			func->ngroups * sizeof(char *), GFP_KERNEL);
+				    array_size(func->ngroups, sizeof(char *)),
+				    GFP_KERNEL);
 	if (!func->groups)
 		return -ENOMEM;
 
@@ -2406,15 +2408,15 @@ static int rockchip_pinctrl_parse_dt(struct platform_device *pdev,
 	dev_dbg(&pdev->dev, "nfunctions = %d\n", info->nfunctions);
 	dev_dbg(&pdev->dev, "ngroups = %d\n", info->ngroups);
 
-	info->functions = devm_kzalloc(dev, info->nfunctions *
-					      sizeof(struct rockchip_pmx_func),
-					      GFP_KERNEL);
+	info->functions = devm_kzalloc(dev,
+				       array_size(info->nfunctions, sizeof(struct rockchip_pmx_func)),
+				       GFP_KERNEL);
 	if (!info->functions)
 		return -EINVAL;
 
-	info->groups = devm_kzalloc(dev, info->ngroups *
-					    sizeof(struct rockchip_pin_group),
-					    GFP_KERNEL);
+	info->groups = devm_kzalloc(dev,
+				    array_size(info->ngroups, sizeof(struct rockchip_pin_group)),
+				    GFP_KERNEL);
 	if (!info->groups)
 		return -EINVAL;
 
@@ -2450,8 +2452,9 @@ static int rockchip_pinctrl_register(struct platform_device *pdev,
 	ctrldesc->pmxops = &rockchip_pmx_ops;
 	ctrldesc->confops = &rockchip_pinconf_ops;
 
-	pindesc = devm_kzalloc(&pdev->dev, sizeof(*pindesc) *
-			info->ctrl->nr_pins, GFP_KERNEL);
+	pindesc = devm_kzalloc(&pdev->dev,
+			       array_size(sizeof(*pindesc), info->ctrl->nr_pins),
+			       GFP_KERNEL);
 	if (!pindesc)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-st.c b/drivers/pinctrl/pinctrl-st.c
index 342fb4627006..e3f608d7cf5b 100644
--- a/drivers/pinctrl/pinctrl-st.c
+++ b/drivers/pinctrl/pinctrl-st.c
@@ -1253,7 +1253,8 @@ static int st_pctl_parse_functions(struct device_node *np,
 		return -EINVAL;
 	}
 	func->groups = devm_kzalloc(info->dev,
-			func->ngroups * sizeof(char *), GFP_KERNEL);
+				    array_size(func->ngroups, sizeof(char *)),
+				    GFP_KERNEL);
 	if (!func->groups)
 		return -ENOMEM;
 
@@ -1577,13 +1578,16 @@ static int st_pctl_probe_dt(struct platform_device *pdev,
 	dev_info(&pdev->dev, "ngroups = %d\n", info->ngroups);
 
 	info->functions = devm_kzalloc(&pdev->dev,
-		info->nfunctions * sizeof(*info->functions), GFP_KERNEL);
+				       array_size(info->nfunctions, sizeof(*info->functions)),
+				       GFP_KERNEL);
 
 	info->groups = devm_kzalloc(&pdev->dev,
-			info->ngroups * sizeof(*info->groups) ,	GFP_KERNEL);
+				    array_size(info->ngroups, sizeof(*info->groups)),
+				    GFP_KERNEL);
 
 	info->banks = devm_kzalloc(&pdev->dev,
-			info->nbanks * sizeof(*info->banks), GFP_KERNEL);
+				   array_size(info->nbanks, sizeof(*info->banks)),
+				   GFP_KERNEL);
 
 	if (!info->functions || !info->groups || !info->banks)
 		return -ENOMEM;
@@ -1612,7 +1616,8 @@ static int st_pctl_probe_dt(struct platform_device *pdev,
 
 	pctl_desc->npins = info->nbanks * ST_GPIO_PINS_PER_BANK;
 	pdesc =	devm_kzalloc(&pdev->dev,
-			sizeof(*pdesc) * pctl_desc->npins, GFP_KERNEL);
+				    array_size(sizeof(*pdesc), pctl_desc->npins),
+				    GFP_KERNEL);
 	if (!pdesc)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/pinctrl-xway.c b/drivers/pinctrl/pinctrl-xway.c
index cd0f402c1164..9535c93f04fc 100644
--- a/drivers/pinctrl/pinctrl-xway.c
+++ b/drivers/pinctrl/pinctrl-xway.c
@@ -1728,8 +1728,8 @@ static int pinmux_xway_probe(struct platform_device *pdev)
 
 	/* load our pad descriptors */
 	xway_info.pads = devm_kzalloc(&pdev->dev,
-			sizeof(struct pinctrl_pin_desc) * xway_chip.ngpio,
-			GFP_KERNEL);
+				      array_size(sizeof(struct pinctrl_pin_desc), xway_chip.ngpio),
+				      GFP_KERNEL);
 	if (!xway_info.pads)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/samsung/pinctrl-exynos.c b/drivers/pinctrl/samsung/pinctrl-exynos.c
index 0a625a64ff5d..7158a71c7962 100644
--- a/drivers/pinctrl/samsung/pinctrl-exynos.c
+++ b/drivers/pinctrl/samsung/pinctrl-exynos.c
@@ -491,8 +491,9 @@ int exynos_eint_wkup_init(struct samsung_pinctrl_drv_data *d)
 			continue;
 		}
 
-		weint_data = devm_kzalloc(dev, bank->nr_pins
-					* sizeof(*weint_data), GFP_KERNEL);
+		weint_data = devm_kzalloc(dev,
+					  array_size(bank->nr_pins, sizeof(*weint_data)),
+					  GFP_KERNEL);
 		if (!weint_data)
 			return -ENOMEM;
 
diff --git a/drivers/pinctrl/samsung/pinctrl-exynos5440.c b/drivers/pinctrl/samsung/pinctrl-exynos5440.c
index 3a962c3ae3f4..41f0a8438afe 100644
--- a/drivers/pinctrl/samsung/pinctrl-exynos5440.c
+++ b/drivers/pinctrl/samsung/pinctrl-exynos5440.c
@@ -637,7 +637,8 @@ static int exynos5440_pinctrl_parse_dt_pins(struct platform_device *pdev,
 		return -EINVAL;
 	}
 
-	*pin_list = devm_kzalloc(dev, *npins * sizeof(**pin_list), GFP_KERNEL);
+	*pin_list = devm_kzalloc(dev, array_size(*npins, sizeof(**pin_list)),
+				 GFP_KERNEL);
 	if (!*pin_list)
 		return -ENOMEM;
 
@@ -772,8 +773,9 @@ static int exynos5440_pinctrl_register(struct platform_device *pdev,
 	 * allocate space for storing the dynamically generated names for all
 	 * the pins which belong to this pin-controller.
 	 */
-	pin_names = devm_kzalloc(&pdev->dev, sizeof(char) * PIN_NAME_LENGTH *
-					ctrldesc->npins, GFP_KERNEL);
+	pin_names = devm_kzalloc(&pdev->dev,
+				 array3_size(sizeof(char), PIN_NAME_LENGTH, ctrldesc->npins),
+				 GFP_KERNEL);
 	if (!pin_names)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/samsung/pinctrl-samsung.c b/drivers/pinctrl/samsung/pinctrl-samsung.c
index dd9b17e1fbba..ee245a36d72d 100644
--- a/drivers/pinctrl/samsung/pinctrl-samsung.c
+++ b/drivers/pinctrl/samsung/pinctrl-samsung.c
@@ -645,8 +645,9 @@ static struct samsung_pin_group *samsung_pinctrl_create_groups(
 	const struct pinctrl_pin_desc *pdesc;
 	int i;
 
-	groups = devm_kzalloc(dev, ctrldesc->npins * sizeof(*groups),
-				GFP_KERNEL);
+	groups = devm_kzalloc(dev,
+			      array_size(ctrldesc->npins, sizeof(*groups)),
+			      GFP_KERNEL);
 	if (!groups)
 		return ERR_PTR(-EINVAL);
 	grp = groups;
@@ -833,8 +834,9 @@ static int samsung_pinctrl_register(struct platform_device *pdev,
 	ctrldesc->pmxops = &samsung_pinmux_ops;
 	ctrldesc->confops = &samsung_pinconf_ops;
 
-	pindesc = devm_kzalloc(&pdev->dev, sizeof(*pindesc) *
-			drvdata->nr_pins, GFP_KERNEL);
+	pindesc = devm_kzalloc(&pdev->dev,
+			       array_size(sizeof(*pindesc), drvdata->nr_pins),
+			       GFP_KERNEL);
 	if (!pindesc)
 		return -ENOMEM;
 	ctrldesc->pins = pindesc;
@@ -848,8 +850,9 @@ static int samsung_pinctrl_register(struct platform_device *pdev,
 	 * allocate space for storing the dynamically generated names for all
 	 * the pins which belong to this pin-controller.
 	 */
-	pin_names = devm_kzalloc(&pdev->dev, sizeof(char) * PIN_NAME_LENGTH *
-					drvdata->nr_pins, GFP_KERNEL);
+	pin_names = devm_kzalloc(&pdev->dev,
+				 array3_size(sizeof(char), PIN_NAME_LENGTH, drvdata->nr_pins),
+				 GFP_KERNEL);
 	if (!pin_names)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/sh-pfc/gpio.c b/drivers/pinctrl/sh-pfc/gpio.c
index fe9b20cb7612..f5896bbb62b5 100644
--- a/drivers/pinctrl/sh-pfc/gpio.c
+++ b/drivers/pinctrl/sh-pfc/gpio.c
@@ -225,8 +225,9 @@ static int gpio_pin_setup(struct sh_pfc_chip *chip)
 	struct gpio_chip *gc = &chip->gpio_chip;
 	int ret;
 
-	chip->pins = devm_kzalloc(pfc->dev, pfc->info->nr_pins *
-				  sizeof(*chip->pins), GFP_KERNEL);
+	chip->pins = devm_kzalloc(pfc->dev,
+				  array_size(pfc->info->nr_pins, sizeof(*chip->pins)),
+				  GFP_KERNEL);
 	if (chip->pins == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/pinctrl/sh-pfc/pinctrl.c b/drivers/pinctrl/sh-pfc/pinctrl.c
index 70db21638901..6e89d45d0527 100644
--- a/drivers/pinctrl/sh-pfc/pinctrl.c
+++ b/drivers/pinctrl/sh-pfc/pinctrl.c
@@ -771,13 +771,13 @@ static int sh_pfc_map_pins(struct sh_pfc *pfc, struct sh_pfc_pinctrl *pmx)
 
 	/* Allocate and initialize the pins and configs arrays. */
 	pmx->pins = devm_kzalloc(pfc->dev,
-				 sizeof(*pmx->pins) * pfc->info->nr_pins,
+				 array_size(sizeof(*pmx->pins), pfc->info->nr_pins),
 				 GFP_KERNEL);
 	if (unlikely(!pmx->pins))
 		return -ENOMEM;
 
 	pmx->configs = devm_kzalloc(pfc->dev,
-				    sizeof(*pmx->configs) * pfc->info->nr_pins,
+				    array_size(sizeof(*pmx->configs), pfc->info->nr_pins),
 				    GFP_KERNEL);
 	if (unlikely(!pmx->configs))
 		return -ENOMEM;
diff --git a/drivers/pinctrl/spear/pinctrl-plgpio.c b/drivers/pinctrl/spear/pinctrl-plgpio.c
index d2123e396b29..9467a2c78a4c 100644
--- a/drivers/pinctrl/spear/pinctrl-plgpio.c
+++ b/drivers/pinctrl/spear/pinctrl-plgpio.c
@@ -539,9 +539,8 @@ static int plgpio_probe(struct platform_device *pdev)
 
 #ifdef CONFIG_PM_SLEEP
 	plgpio->csave_regs = devm_kzalloc(&pdev->dev,
-			sizeof(*plgpio->csave_regs) *
-			DIV_ROUND_UP(plgpio->chip.ngpio, MAX_GPIO_PER_REG),
-			GFP_KERNEL);
+					  array_size(sizeof(*plgpio->csave_regs), DIV_ROUND_UP(plgpio->chip.ngpio, MAX_GPIO_PER_REG)),
+					  GFP_KERNEL);
 	if (!plgpio->csave_regs)
 		return -ENOMEM;
 #endif
diff --git a/drivers/pinctrl/sprd/pinctrl-sprd.c b/drivers/pinctrl/sprd/pinctrl-sprd.c
index ba1c2ca406e4..200fbb66f91a 100644
--- a/drivers/pinctrl/sprd/pinctrl-sprd.c
+++ b/drivers/pinctrl/sprd/pinctrl-sprd.c
@@ -879,8 +879,9 @@ static int sprd_pinctrl_parse_groups(struct device_node *np,
 
 	grp->name = np->name;
 	grp->npins = ret;
-	grp->pins = devm_kzalloc(sprd_pctl->dev, grp->npins *
-				 sizeof(unsigned int), GFP_KERNEL);
+	grp->pins = devm_kzalloc(sprd_pctl->dev,
+				 array_size(grp->npins, sizeof(unsigned int)),
+				 GFP_KERNEL);
 	if (!grp->pins)
 		return -ENOMEM;
 
@@ -931,14 +932,14 @@ static int sprd_pinctrl_parse_dt(struct sprd_pinctrl *sprd_pctl)
 	if (!info->ngroups)
 		return 0;
 
-	info->groups = devm_kzalloc(sprd_pctl->dev, info->ngroups *
-				    sizeof(struct sprd_pin_group),
+	info->groups = devm_kzalloc(sprd_pctl->dev,
+				    array_size(info->ngroups, sizeof(struct sprd_pin_group)),
 				    GFP_KERNEL);
 	if (!info->groups)
 		return -ENOMEM;
 
 	info->grp_names = devm_kzalloc(sprd_pctl->dev,
-				       info->ngroups * sizeof(char *),
+				       array_size(info->ngroups, sizeof(char *)),
 				       GFP_KERNEL);
 	if (!info->grp_names)
 		return -ENOMEM;
@@ -981,7 +982,7 @@ static int sprd_pinctrl_add_pins(struct sprd_pinctrl *sprd_pctl,
 
 	info->npins = pins_cnt;
 	info->pins = devm_kzalloc(sprd_pctl->dev,
-				  info->npins * sizeof(struct sprd_pin),
+				  array_size(info->npins, sizeof(struct sprd_pin)),
 				  GFP_KERNEL);
 	if (!info->pins)
 		return -ENOMEM;
@@ -1057,8 +1058,8 @@ int sprd_pinctrl_core_probe(struct platform_device *pdev,
 		return ret;
 	}
 
-	pin_desc = devm_kzalloc(&pdev->dev, pinctrl_info->npins *
-				sizeof(struct pinctrl_pin_desc),
+	pin_desc = devm_kzalloc(&pdev->dev,
+				array_size(pinctrl_info->npins, sizeof(struct pinctrl_pin_desc)),
 				GFP_KERNEL);
 	if (!pin_desc)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/sunxi/pinctrl-sunxi.c b/drivers/pinctrl/sunxi/pinctrl-sunxi.c
index 14ccf7722d65..e87b3bb1e4f7 100644
--- a/drivers/pinctrl/sunxi/pinctrl-sunxi.c
+++ b/drivers/pinctrl/sunxi/pinctrl-sunxi.c
@@ -1058,7 +1058,7 @@ static int sunxi_pinctrl_build_state(struct platform_device *pdev)
 	 * number we will ever see.
 	 */
 	pctl->groups = devm_kzalloc(&pdev->dev,
-				    pctl->desc->npins * sizeof(*pctl->groups),
+				    array_size(pctl->desc->npins, sizeof(*pctl->groups)),
 				    GFP_KERNEL);
 	if (!pctl->groups)
 		return -ENOMEM;
@@ -1082,7 +1082,7 @@ static int sunxi_pinctrl_build_state(struct platform_device *pdev)
 	 * we'll reallocate that later anyway
 	 */
 	pctl->functions = devm_kzalloc(&pdev->dev,
-				       pctl->ngroups * sizeof(*pctl->functions),
+				       array_size(pctl->ngroups, sizeof(*pctl->functions)),
 				       GFP_KERNEL);
 	if (!pctl->functions)
 		return -ENOMEM;
@@ -1140,7 +1140,7 @@ static int sunxi_pinctrl_build_state(struct platform_device *pdev)
 			if (!func_item->groups) {
 				func_item->groups =
 					devm_kzalloc(&pdev->dev,
-						     func_item->ngroups * sizeof(*func_item->groups),
+						     array_size(func_item->ngroups, sizeof(*func_item->groups)),
 						     GFP_KERNEL);
 				if (!func_item->groups)
 					return -ENOMEM;
@@ -1284,7 +1284,7 @@ int sunxi_pinctrl_init_with_variant(struct platform_device *pdev,
 	}
 
 	pins = devm_kzalloc(&pdev->dev,
-			    pctl->desc->npins * sizeof(*pins),
+			    array_size(pctl->desc->npins, sizeof(*pins)),
 			    GFP_KERNEL);
 	if (!pins)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/tegra/pinctrl-tegra.c b/drivers/pinctrl/tegra/pinctrl-tegra.c
index 72c718e66ebb..a6cff5148445 100644
--- a/drivers/pinctrl/tegra/pinctrl-tegra.c
+++ b/drivers/pinctrl/tegra/pinctrl-tegra.c
@@ -677,8 +677,8 @@ int tegra_pinctrl_probe(struct platform_device *pdev,
 	 * This over-allocates slightly, since not all groups are mux groups.
 	 */
 	pmx->group_pins = devm_kzalloc(&pdev->dev,
-		soc_data->ngroups * 4 * sizeof(*pmx->group_pins),
-		GFP_KERNEL);
+				       array3_size(soc_data->ngroups, 4, sizeof(*pmx->group_pins)),
+				       GFP_KERNEL);
 	if (!pmx->group_pins)
 		return -ENOMEM;
 
@@ -719,7 +719,8 @@ int tegra_pinctrl_probe(struct platform_device *pdev,
 	}
 	pmx->nbanks = i;
 
-	pmx->regs = devm_kzalloc(&pdev->dev, pmx->nbanks * sizeof(*pmx->regs),
+	pmx->regs = devm_kzalloc(&pdev->dev,
+				 array_size(pmx->nbanks, sizeof(*pmx->regs)),
 				 GFP_KERNEL);
 	if (!pmx->regs)
 		return -ENOMEM;
diff --git a/drivers/pinctrl/zte/pinctrl-zx.c b/drivers/pinctrl/zte/pinctrl-zx.c
index f9fd665529c2..48b2e8d6a34e 100644
--- a/drivers/pinctrl/zte/pinctrl-zx.c
+++ b/drivers/pinctrl/zte/pinctrl-zx.c
@@ -364,9 +364,8 @@ static int zx_pinctrl_build_state(struct platform_device *pdev)
 			func = functions + j;
 			if (!func->group_names) {
 				func->group_names = devm_kzalloc(&pdev->dev,
-						func->num_group_names *
-						sizeof(*func->group_names),
-						GFP_KERNEL);
+								 array_size(func->num_group_names, sizeof(*func->group_names)),
+								 GFP_KERNEL);
 				if (!func->group_names) {
 					kfree(functions);
 					return -ENOMEM;
diff --git a/drivers/power/supply/charger-manager.c b/drivers/power/supply/charger-manager.c
index 1de4b4493824..8604e2034a05 100644
--- a/drivers/power/supply/charger-manager.c
+++ b/drivers/power/supply/charger-manager.c
@@ -1380,7 +1380,8 @@ static int charger_manager_register_sysfs(struct charger_manager *cm)
 
 		snprintf(buf, 10, "charger.%d", i);
 		str = devm_kzalloc(cm->dev,
-				sizeof(char) * (strlen(buf) + 1), GFP_KERNEL);
+				   array_size(sizeof(char), (strlen(buf) + 1)),
+				   GFP_KERNEL);
 		if (!str)
 			return -ENOMEM;
 
@@ -1522,8 +1523,9 @@ static struct charger_desc *of_cm_parse_desc(struct device *dev)
 	of_property_read_u32(np, "cm-num-chargers", &num_chgs);
 	if (num_chgs) {
 		/* Allocate empty bin at the tail of array */
-		desc->psy_charger_stat = devm_kzalloc(dev, sizeof(char *)
-						* (num_chgs + 1), GFP_KERNEL);
+		desc->psy_charger_stat = devm_kzalloc(dev,
+						      array_size(sizeof(char *), (num_chgs + 1)),
+						      GFP_KERNEL);
 		if (desc->psy_charger_stat) {
 			int i;
 			for (i = 0; i < num_chgs; i++)
@@ -1555,8 +1557,8 @@ static struct charger_desc *of_cm_parse_desc(struct device *dev)
 		struct charger_regulator *chg_regs;
 		struct device_node *child;
 
-		chg_regs = devm_kzalloc(dev, sizeof(*chg_regs)
-					* desc->num_charger_regulators,
+		chg_regs = devm_kzalloc(dev,
+					array_size(sizeof(*chg_regs), desc->num_charger_regulators),
 					GFP_KERNEL);
 		if (!chg_regs)
 			return ERR_PTR(-ENOMEM);
@@ -1573,9 +1575,9 @@ static struct charger_desc *of_cm_parse_desc(struct device *dev)
 			/* charger cables */
 			chg_regs->num_cables = of_get_child_count(child);
 			if (chg_regs->num_cables) {
-				cables = devm_kzalloc(dev, sizeof(*cables)
-						* chg_regs->num_cables,
-						GFP_KERNEL);
+				cables = devm_kzalloc(dev,
+						      array_size(sizeof(*cables), chg_regs->num_cables),
+						      GFP_KERNEL);
 				if (!cables) {
 					of_node_put(child);
 					return ERR_PTR(-ENOMEM);
@@ -1725,9 +1727,8 @@ static int charger_manager_probe(struct platform_device *pdev)
 
 	/* Allocate for psy properties because they may vary */
 	cm->charger_psy_desc.properties = devm_kzalloc(&pdev->dev,
-				sizeof(enum power_supply_property)
-				* (ARRAY_SIZE(default_charger_props) +
-				NUM_CHARGER_PSY_OPTIONAL), GFP_KERNEL);
+						       array_size(sizeof(enum power_supply_property), (ARRAY_SIZE(default_charger_props) + NUM_CHARGER_PSY_OPTIONAL)),
+						       GFP_KERNEL);
 	if (!cm->charger_psy_desc.properties)
 		return -ENOMEM;
 
diff --git a/drivers/power/supply/power_supply_core.c b/drivers/power/supply/power_supply_core.c
index feac7b066e6c..c55741ff23be 100644
--- a/drivers/power/supply/power_supply_core.c
+++ b/drivers/power/supply/power_supply_core.c
@@ -263,7 +263,7 @@ static int power_supply_check_supplies(struct power_supply *psy)
 		return -ENOMEM;
 
 	*psy->supplied_from = devm_kzalloc(&psy->dev,
-					   sizeof(char *) * (cnt - 1),
+					   array_size(sizeof(char *), (cnt - 1)),
 					   GFP_KERNEL);
 	if (!*psy->supplied_from)
 		return -ENOMEM;
diff --git a/drivers/regulator/gpio-regulator.c b/drivers/regulator/gpio-regulator.c
index a86b8997bb54..9f558b58d08d 100644
--- a/drivers/regulator/gpio-regulator.c
+++ b/drivers/regulator/gpio-regulator.c
@@ -173,8 +173,8 @@ of_get_gpio_regulator_config(struct device *dev, struct device_node *np,
 	if (ret > 0) {
 		config->nr_gpios = ret;
 		config->gpios = devm_kzalloc(dev,
-					sizeof(struct gpio) * config->nr_gpios,
-					GFP_KERNEL);
+					     array_size(sizeof(struct gpio), config->nr_gpios),
+					     GFP_KERNEL);
 		if (!config->gpios)
 			return ERR_PTR(-ENOMEM);
 
@@ -215,9 +215,8 @@ of_get_gpio_regulator_config(struct device *dev, struct device_node *np,
 	}
 
 	config->states = devm_kzalloc(dev,
-				sizeof(struct gpio_regulator_state)
-				* (proplen / 2),
-				GFP_KERNEL);
+				      array_size(sizeof(struct gpio_regulator_state), (proplen / 2)),
+				      GFP_KERNEL);
 	if (!config->states)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/regulator/max8997-regulator.c b/drivers/regulator/max8997-regulator.c
index 559b9ac45404..fb16b5ceac7d 100644
--- a/drivers/regulator/max8997-regulator.c
+++ b/drivers/regulator/max8997-regulator.c
@@ -929,8 +929,9 @@ static int max8997_pmic_dt_parse_pdata(struct platform_device *pdev,
 	/* count the number of regulators to be supported in pmic */
 	pdata->num_regulators = of_get_child_count(regulators_np);
 
-	rdata = devm_kzalloc(&pdev->dev, sizeof(*rdata) *
-				pdata->num_regulators, GFP_KERNEL);
+	rdata = devm_kzalloc(&pdev->dev,
+			     array_size(sizeof(*rdata), pdata->num_regulators),
+			     GFP_KERNEL);
 	if (!rdata) {
 		of_node_put(regulators_np);
 		return -ENOMEM;
diff --git a/drivers/regulator/max8998.c b/drivers/regulator/max8998.c
index 3027e7ce100b..d145e0c1e22c 100644
--- a/drivers/regulator/max8998.c
+++ b/drivers/regulator/max8998.c
@@ -671,8 +671,9 @@ static int max8998_pmic_dt_parse_pdata(struct max8998_dev *iodev,
 	/* count the number of regulators to be supported in pmic */
 	pdata->num_regulators = of_get_child_count(regulators_np);
 
-	rdata = devm_kzalloc(iodev->dev, sizeof(*rdata) *
-				pdata->num_regulators, GFP_KERNEL);
+	rdata = devm_kzalloc(iodev->dev,
+			     array_size(sizeof(*rdata), pdata->num_regulators),
+			     GFP_KERNEL);
 	if (!rdata) {
 		of_node_put(regulators_np);
 		return -ENOMEM;
diff --git a/drivers/regulator/mc13xxx-regulator-core.c b/drivers/regulator/mc13xxx-regulator-core.c
index 0281c31ae2ed..5c4325c54aae 100644
--- a/drivers/regulator/mc13xxx-regulator-core.c
+++ b/drivers/regulator/mc13xxx-regulator-core.c
@@ -175,7 +175,8 @@ struct mc13xxx_regulator_init_data *mc13xxx_parse_regulators_dt(
 	if (!parent)
 		return NULL;
 
-	data = devm_kzalloc(&pdev->dev, sizeof(*data) * priv->num_regulators,
+	data = devm_kzalloc(&pdev->dev,
+			    array_size(sizeof(*data), priv->num_regulators),
 			    GFP_KERNEL);
 	if (!data) {
 		of_node_put(parent);
diff --git a/drivers/regulator/s5m8767.c b/drivers/regulator/s5m8767.c
index 4836947e1521..0a22673d2c80 100644
--- a/drivers/regulator/s5m8767.c
+++ b/drivers/regulator/s5m8767.c
@@ -553,13 +553,15 @@ static int s5m8767_pmic_dt_parse_pdata(struct platform_device *pdev,
 	/* count the number of regulators to be supported in pmic */
 	pdata->num_regulators = of_get_child_count(regulators_np);
 
-	rdata = devm_kzalloc(&pdev->dev, sizeof(*rdata) *
-				pdata->num_regulators, GFP_KERNEL);
+	rdata = devm_kzalloc(&pdev->dev,
+			     array_size(sizeof(*rdata), pdata->num_regulators),
+			     GFP_KERNEL);
 	if (!rdata)
 		return -ENOMEM;
 
-	rmode = devm_kzalloc(&pdev->dev, sizeof(*rmode) *
-				pdata->num_regulators, GFP_KERNEL);
+	rmode = devm_kzalloc(&pdev->dev,
+			     array_size(sizeof(*rmode), pdata->num_regulators),
+			     GFP_KERNEL);
 	if (!rmode)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/tps65910-regulator.c b/drivers/regulator/tps65910-regulator.c
index 81672a58fcc2..55e43ee75653 100644
--- a/drivers/regulator/tps65910-regulator.c
+++ b/drivers/regulator/tps65910-regulator.c
@@ -1131,18 +1131,21 @@ static int tps65910_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	pmic->desc = devm_kzalloc(&pdev->dev, pmic->num_regulators *
-			sizeof(struct regulator_desc), GFP_KERNEL);
+	pmic->desc = devm_kzalloc(&pdev->dev,
+				  array_size(pmic->num_regulators, sizeof(struct regulator_desc)),
+				  GFP_KERNEL);
 	if (!pmic->desc)
 		return -ENOMEM;
 
-	pmic->info = devm_kzalloc(&pdev->dev, pmic->num_regulators *
-			sizeof(struct tps_info *), GFP_KERNEL);
+	pmic->info = devm_kzalloc(&pdev->dev,
+				  array_size(pmic->num_regulators, sizeof(struct tps_info *)),
+				  GFP_KERNEL);
 	if (!pmic->info)
 		return -ENOMEM;
 
-	pmic->rdev = devm_kzalloc(&pdev->dev, pmic->num_regulators *
-			sizeof(struct regulator_dev *), GFP_KERNEL);
+	pmic->rdev = devm_kzalloc(&pdev->dev,
+				  array_size(pmic->num_regulators, sizeof(struct regulator_dev *)),
+				  GFP_KERNEL);
 	if (!pmic->rdev)
 		return -ENOMEM;
 
diff --git a/drivers/scsi/ufs/ufshcd.c b/drivers/scsi/ufs/ufshcd.c
index 00e79057f870..1d58c82eeaf1 100644
--- a/drivers/scsi/ufs/ufshcd.c
+++ b/drivers/scsi/ufs/ufshcd.c
@@ -3270,7 +3270,7 @@ static int ufshcd_memory_alloc(struct ufs_hba *hba)
 
 	/* Allocate memory for local reference block */
 	hba->lrb = devm_kzalloc(hba->dev,
-				hba->nutrs * sizeof(struct ufshcd_lrb),
+				array_size(hba->nutrs, sizeof(struct ufshcd_lrb)),
 				GFP_KERNEL);
 	if (!hba->lrb) {
 		dev_err(hba->dev, "LRB Memory allocation failed\n");
diff --git a/drivers/spi/spi-davinci.c b/drivers/spi/spi-davinci.c
index 60d59b003aa4..afbc325bb467 100644
--- a/drivers/spi/spi-davinci.c
+++ b/drivers/spi/spi-davinci.c
@@ -924,8 +924,8 @@ static int davinci_spi_probe(struct platform_device *pdev)
 	pdata = &dspi->pdata;
 
 	dspi->bytes_per_word = devm_kzalloc(&pdev->dev,
-					    sizeof(*dspi->bytes_per_word) *
-					    pdata->num_chipselect, GFP_KERNEL);
+					    array_size(sizeof(*dspi->bytes_per_word), pdata->num_chipselect),
+					    GFP_KERNEL);
 	if (dspi->bytes_per_word == NULL) {
 		ret = -ENOMEM;
 		goto free_master;
diff --git a/drivers/spi/spi-ep93xx.c b/drivers/spi/spi-ep93xx.c
index e5cc07357746..b005f2682d9a 100644
--- a/drivers/spi/spi-ep93xx.c
+++ b/drivers/spi/spi-ep93xx.c
@@ -672,7 +672,7 @@ static int ep93xx_spi_probe(struct platform_device *pdev)
 
 	master->num_chipselect = info->num_chipselect;
 	master->cs_gpios = devm_kzalloc(&master->dev,
-					sizeof(int) * master->num_chipselect,
+					array_size(sizeof(int), master->num_chipselect),
 					GFP_KERNEL);
 	if (!master->cs_gpios) {
 		error = -ENOMEM;
diff --git a/drivers/spi/spi-gpio.c b/drivers/spi/spi-gpio.c
index b85a93cad44a..6dc13a23c81e 100644
--- a/drivers/spi/spi-gpio.c
+++ b/drivers/spi/spi-gpio.c
@@ -374,8 +374,8 @@ static int spi_gpio_probe(struct platform_device *pdev)
 	spi_gpio = spi_master_get_devdata(master);
 
 	spi_gpio->cs_gpios = devm_kzalloc(&pdev->dev,
-				pdata->num_chipselect * sizeof(*spi_gpio->cs_gpios),
-				GFP_KERNEL);
+					  array_size(pdata->num_chipselect, sizeof(*spi_gpio->cs_gpios)),
+					  GFP_KERNEL);
 	if (!spi_gpio->cs_gpios)
 		return -ENOMEM;
 
diff --git a/drivers/spi/spi-imx.c b/drivers/spi/spi-imx.c
index 6f57592a7f95..c8d561a031c3 100644
--- a/drivers/spi/spi-imx.c
+++ b/drivers/spi/spi-imx.c
@@ -1528,7 +1528,8 @@ static int spi_imx_probe(struct platform_device *pdev)
 		master->num_chipselect = mxc_platform_info->num_chipselect;
 		if (mxc_platform_info->chipselect) {
 			master->cs_gpios = devm_kzalloc(&master->dev,
-				sizeof(int) * master->num_chipselect, GFP_KERNEL);
+							array_size(sizeof(int), master->num_chipselect),
+							GFP_KERNEL);
 			if (!master->cs_gpios)
 				return -ENOMEM;
 
diff --git a/drivers/spi/spi-oc-tiny.c b/drivers/spi/spi-oc-tiny.c
index b5911282a611..7d0df916a0f9 100644
--- a/drivers/spi/spi-oc-tiny.c
+++ b/drivers/spi/spi-oc-tiny.c
@@ -214,8 +214,8 @@ static int tiny_spi_of_probe(struct platform_device *pdev)
 	hw->gpio_cs_count = of_gpio_count(np);
 	if (hw->gpio_cs_count > 0) {
 		hw->gpio_cs = devm_kzalloc(&pdev->dev,
-				hw->gpio_cs_count * sizeof(unsigned int),
-				GFP_KERNEL);
+					   array_size(hw->gpio_cs_count, sizeof(unsigned int)),
+					   GFP_KERNEL);
 		if (!hw->gpio_cs)
 			return -ENOMEM;
 	}
diff --git a/drivers/spi/spi.c b/drivers/spi/spi.c
index 7b213faa0a2b..c1a9e5e86727 100644
--- a/drivers/spi/spi.c
+++ b/drivers/spi/spi.c
@@ -2041,7 +2041,8 @@ static int of_spi_register_master(struct spi_controller *ctlr)
 	else if (nb < 0)
 		return nb;
 
-	cs = devm_kzalloc(&ctlr->dev, sizeof(int) * ctlr->num_chipselect,
+	cs = devm_kzalloc(&ctlr->dev,
+			  array_size(sizeof(int), ctlr->num_chipselect),
 			  GFP_KERNEL);
 	ctlr->cs_gpios = cs;
 
diff --git a/drivers/staging/media/atomisp/pci/atomisp2/atomisp_subdev.c b/drivers/staging/media/atomisp/pci/atomisp2/atomisp_subdev.c
index 49a9973b4289..57dca09652a5 100644
--- a/drivers/staging/media/atomisp/pci/atomisp2/atomisp_subdev.c
+++ b/drivers/staging/media/atomisp/pci/atomisp2/atomisp_subdev.c
@@ -1401,8 +1401,9 @@ int atomisp_subdev_init(struct atomisp_device *isp)
 	 * multiple streams
 	 */
 	isp->num_of_streams = 2;
-	isp->asd = devm_kzalloc(isp->dev, sizeof(struct atomisp_sub_device) *
-			       isp->num_of_streams, GFP_KERNEL);
+	isp->asd = devm_kzalloc(isp->dev,
+				array_size(sizeof(struct atomisp_sub_device), isp->num_of_streams),
+				GFP_KERNEL);
 	if (!isp->asd)
 		return -ENOMEM;
 	for (i = 0; i < isp->num_of_streams; i++) {
diff --git a/drivers/staging/media/imx/imx-media-dev.c b/drivers/staging/media/imx/imx-media-dev.c
index f2801e0c447c..f5a8db883a8d 100644
--- a/drivers/staging/media/imx/imx-media-dev.c
+++ b/drivers/staging/media/imx/imx-media-dev.c
@@ -303,10 +303,9 @@ static int imx_media_alloc_pad_vdev_lists(struct imx_media_dev *imxmd)
 
 	list_for_each_entry(sd, &imxmd->v4l2_dev.subdevs, list) {
 		entity = &sd->entity;
-		vdev_lists = devm_kzalloc(
-			imxmd->md.dev,
-			entity->num_pads * sizeof(*vdev_lists),
-			GFP_KERNEL);
+		vdev_lists = devm_kzalloc(imxmd->md.dev,
+					  array_size(entity->num_pads, sizeof(*vdev_lists)),
+					  GFP_KERNEL);
 		if (!vdev_lists)
 			return -ENOMEM;
 
diff --git a/drivers/staging/mt7621-pinctrl/pinctrl-rt2880.c b/drivers/staging/mt7621-pinctrl/pinctrl-rt2880.c
index cc8c4e2a9614..c86f8e0ba65f 100644
--- a/drivers/staging/mt7621-pinctrl/pinctrl-rt2880.c
+++ b/drivers/staging/mt7621-pinctrl/pinctrl-rt2880.c
@@ -288,7 +288,9 @@ static int rt2880_pinmux_index(struct rt2880_priv *p)
 	}
 
 	/* allocate the group names array needed by the gpio function */
-	p->group_names = devm_kzalloc(p->dev, sizeof(char *) * p->group_count, GFP_KERNEL);
+	p->group_names = devm_kzalloc(p->dev,
+				      array_size(sizeof(char *), p->group_count),
+				      GFP_KERNEL);
 	if (!p->group_names)
 		return -1;
 
@@ -301,8 +303,12 @@ static int rt2880_pinmux_index(struct rt2880_priv *p)
 	p->func_count++;
 
 	/* allocate our function and group mapping index buffers */
-	f = p->func = devm_kzalloc(p->dev, sizeof(struct rt2880_pmx_func) * p->func_count, GFP_KERNEL);
-	gpio_func.groups = devm_kzalloc(p->dev, sizeof(int) * p->group_count, GFP_KERNEL);
+	f = p->func = devm_kzalloc(p->dev,
+				   array_size(sizeof(struct rt2880_pmx_func), p->func_count),
+				   GFP_KERNEL);
+	gpio_func.groups = devm_kzalloc(p->dev,
+					array_size(sizeof(int), p->group_count),
+					GFP_KERNEL);
 	if (!f || !gpio_func.groups)
 		return -1;
 
@@ -338,7 +344,9 @@ static int rt2880_pinmux_pins(struct rt2880_priv *p)
 		if (!p->func[i]->pin_count)
 			continue;
 
-		p->func[i]->pins = devm_kzalloc(p->dev, sizeof(int) * p->func[i]->pin_count, GFP_KERNEL);
+		p->func[i]->pins = devm_kzalloc(p->dev,
+						array_size(sizeof(int), p->func[i]->pin_count),
+						GFP_KERNEL);
 		for (j = 0; j < p->func[i]->pin_count; j++)
 			p->func[i]->pins[j] = p->func[i]->pin_first + j;
 
@@ -348,12 +356,13 @@ static int rt2880_pinmux_pins(struct rt2880_priv *p)
 	}
 
 	/* the buffer that tells us which pins are gpio */
-	p->gpio = devm_kzalloc(p->dev,sizeof(uint8_t) * p->max_pins,
-		GFP_KERNEL);
+	p->gpio = devm_kzalloc(p->dev,
+			       array_size(sizeof(uint8_t), p->max_pins),
+			       GFP_KERNEL);
 	/* the pads needed to tell pinctrl about our pins */
 	p->pads = devm_kzalloc(p->dev,
-		sizeof(struct pinctrl_pin_desc) * p->max_pins,
-		GFP_KERNEL);
+			       array_size(sizeof(struct pinctrl_pin_desc), p->max_pins),
+			       GFP_KERNEL);
 	if (!p->pads || !p->gpio ) {
 		dev_err(p->dev, "Failed to allocate gpio data\n");
 		return -ENOMEM;
diff --git a/drivers/thermal/tegra/soctherm.c b/drivers/thermal/tegra/soctherm.c
index 455b58ce2652..727e8dc9b422 100644
--- a/drivers/thermal/tegra/soctherm.c
+++ b/drivers/thermal/tegra/soctherm.c
@@ -1344,7 +1344,7 @@ static int tegra_soctherm_probe(struct platform_device *pdev)
 	}
 
 	tegra->calib = devm_kzalloc(&pdev->dev,
-				    sizeof(u32) * soc->num_tsensors,
+				    array_size(sizeof(u32), soc->num_tsensors),
 				    GFP_KERNEL);
 	if (!tegra->calib)
 		return -ENOMEM;
@@ -1364,7 +1364,7 @@ static int tegra_soctherm_probe(struct platform_device *pdev)
 	}
 
 	tegra->thermctl_tzs = devm_kzalloc(&pdev->dev,
-					   sizeof(*z) * soc->num_ttgs,
+					   array_size(sizeof(*z), soc->num_ttgs),
 					   GFP_KERNEL);
 	if (!tegra->thermctl_tzs)
 		return -ENOMEM;
diff --git a/drivers/tty/serial/rp2.c b/drivers/tty/serial/rp2.c
index 520b43b23543..c096a55b57f0 100644
--- a/drivers/tty/serial/rp2.c
+++ b/drivers/tty/serial/rp2.c
@@ -774,7 +774,8 @@ static int rp2_probe(struct pci_dev *pdev,
 
 	rp2_init_card(card);
 
-	ports = devm_kzalloc(&pdev->dev, sizeof(*ports) * card->n_ports,
+	ports = devm_kzalloc(&pdev->dev,
+			     array_size(sizeof(*ports), card->n_ports),
 			     GFP_KERNEL);
 	if (!ports)
 		return -ENOMEM;
diff --git a/drivers/usb/gadget/udc/atmel_usba_udc.c b/drivers/usb/gadget/udc/atmel_usba_udc.c
index 27c16399c7e8..2c51bd71bdbe 100644
--- a/drivers/usb/gadget/udc/atmel_usba_udc.c
+++ b/drivers/usb/gadget/udc/atmel_usba_udc.c
@@ -2087,7 +2087,8 @@ static struct usba_ep * atmel_udc_of_init(struct platform_device *pdev,
 		udc->num_ep = usba_config_fifo_table(udc);
 	}
 
-	eps = devm_kzalloc(&pdev->dev, sizeof(struct usba_ep) * udc->num_ep,
+	eps = devm_kzalloc(&pdev->dev,
+			   array_size(sizeof(struct usba_ep), udc->num_ep),
 			   GFP_KERNEL);
 	if (!eps)
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/usb/gadget/udc/pch_udc.c b/drivers/usb/gadget/udc/pch_udc.c
index afaea11ec771..b372f761ba8f 100644
--- a/drivers/usb/gadget/udc/pch_udc.c
+++ b/drivers/usb/gadget/udc/pch_udc.c
@@ -2951,7 +2951,8 @@ static int init_dma_pools(struct pch_udc_dev *dev)
 	dev->ep[UDC_EP0IN_IDX].td_data = NULL;
 	dev->ep[UDC_EP0IN_IDX].td_data_phys = 0;
 
-	ep0out_buf = devm_kzalloc(&dev->pdev->dev, UDC_EP0OUT_BUFF_SIZE * 4,
+	ep0out_buf = devm_kzalloc(&dev->pdev->dev,
+				  array_size(UDC_EP0OUT_BUFF_SIZE, 4),
 				  GFP_KERNEL);
 	if (!ep0out_buf)
 		return -ENOMEM;
diff --git a/drivers/usb/gadget/udc/renesas_usb3.c b/drivers/usb/gadget/udc/renesas_usb3.c
index 409cde4e6a51..a8ad4ed0bdf2 100644
--- a/drivers/usb/gadget/udc/renesas_usb3.c
+++ b/drivers/usb/gadget/udc/renesas_usb3.c
@@ -2428,7 +2428,8 @@ static int renesas_usb3_init_ep(struct renesas_usb3 *usb3, struct device *dev,
 	if (usb3->num_usb3_eps > USB3_MAX_NUM_PIPES)
 		usb3->num_usb3_eps = USB3_MAX_NUM_PIPES;
 
-	usb3->usb3_ep = devm_kzalloc(dev, sizeof(*usb3_ep) * usb3->num_usb3_eps,
+	usb3->usb3_ep = devm_kzalloc(dev,
+				     array_size(sizeof(*usb3_ep), usb3->num_usb3_eps),
 				     GFP_KERNEL);
 	if (!usb3->usb3_ep)
 		return -ENOMEM;
diff --git a/drivers/video/backlight/adp8860_bl.c b/drivers/video/backlight/adp8860_bl.c
index e7315bf14d60..e8c1e75429cd 100644
--- a/drivers/video/backlight/adp8860_bl.c
+++ b/drivers/video/backlight/adp8860_bl.c
@@ -223,8 +223,9 @@ static int adp8860_led_probe(struct i2c_client *client)
 	struct led_info *cur_led;
 	int ret, i;
 
-	led = devm_kzalloc(&client->dev, sizeof(*led) * pdata->num_leds,
-				GFP_KERNEL);
+	led = devm_kzalloc(&client->dev,
+			   array_size(sizeof(*led), pdata->num_leds),
+			   GFP_KERNEL);
 	if (led == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/video/backlight/adp8870_bl.c b/drivers/video/backlight/adp8870_bl.c
index 058d1def2d1f..133edb92a439 100644
--- a/drivers/video/backlight/adp8870_bl.c
+++ b/drivers/video/backlight/adp8870_bl.c
@@ -246,8 +246,9 @@ static int adp8870_led_probe(struct i2c_client *client)
 	struct led_info *cur_led;
 	int ret, i;
 
-	led = devm_kzalloc(&client->dev, pdata->num_leds * sizeof(*led),
-				GFP_KERNEL);
+	led = devm_kzalloc(&client->dev,
+			   array_size(pdata->num_leds, sizeof(*led)),
+			   GFP_KERNEL);
 	if (led == NULL)
 		return -ENOMEM;
 
diff --git a/fs/f2fs/node.c b/fs/f2fs/node.c
index f202398e20ea..8646b7f3f4a9 100644
--- a/fs/f2fs/node.c
+++ b/fs/f2fs/node.c
@@ -2730,8 +2730,9 @@ static int init_free_nid_cache(struct f2fs_sb_info *sbi)
 	struct f2fs_nm_info *nm_i = NM_I(sbi);
 	int i;
 
-	nm_i->free_nid_bitmap = f2fs_kzalloc(sbi, nm_i->nat_blocks *
-				sizeof(unsigned char *), GFP_KERNEL);
+	nm_i->free_nid_bitmap = f2fs_kzalloc(sbi,
+					     array_size(nm_i->nat_blocks, sizeof(unsigned char *)),
+					     GFP_KERNEL);
 	if (!nm_i->free_nid_bitmap)
 		return -ENOMEM;
 
diff --git a/sound/soc/codecs/wm8994.c b/sound/soc/codecs/wm8994.c
index 6e9e32a07259..3febe7f1c35a 100644
--- a/sound/soc/codecs/wm8994.c
+++ b/sound/soc/codecs/wm8994.c
@@ -3299,7 +3299,8 @@ static void wm8994_handle_pdata(struct wm8994_priv *wm8994)
 
 		/* We need an array of texts for the enum API */
 		wm8994->drc_texts = devm_kzalloc(wm8994->hubs.component->dev,
-			    sizeof(char *) * pdata->num_drc_cfgs, GFP_KERNEL);
+						 array_size(sizeof(char *), pdata->num_drc_cfgs),
+						 GFP_KERNEL);
 		if (!wm8994->drc_texts)
 			return;
 
diff --git a/sound/soc/davinci/davinci-mcasp.c b/sound/soc/davinci/davinci-mcasp.c
index 03ba218160ca..41e0e37839c5 100644
--- a/sound/soc/davinci/davinci-mcasp.c
+++ b/sound/soc/davinci/davinci-mcasp.c
@@ -1869,8 +1869,8 @@ static int davinci_mcasp_probe(struct platform_device *pdev)
 	mcasp->num_serializer = pdata->num_serializer;
 #ifdef CONFIG_PM_SLEEP
 	mcasp->context.xrsr_regs = devm_kzalloc(&pdev->dev,
-					sizeof(u32) * mcasp->num_serializer,
-					GFP_KERNEL);
+						array_size(sizeof(u32), mcasp->num_serializer),
+						GFP_KERNEL);
 	if (!mcasp->context.xrsr_regs) {
 		ret = -ENOMEM;
 		goto err;
@@ -2004,13 +2004,13 @@ static int davinci_mcasp_probe(struct platform_device *pdev)
 	 * bytes.
 	 */
 	mcasp->chconstr[SNDRV_PCM_STREAM_PLAYBACK].list =
-		devm_kzalloc(mcasp->dev, sizeof(unsigned int) *
-			     (32 + mcasp->num_serializer - 1),
+		devm_kzalloc(mcasp->dev,
+			     array_size(sizeof(unsigned int), (32 + mcasp->num_serializer - 1)),
 			     GFP_KERNEL);
 
 	mcasp->chconstr[SNDRV_PCM_STREAM_CAPTURE].list =
-		devm_kzalloc(mcasp->dev, sizeof(unsigned int) *
-			     (32 + mcasp->num_serializer - 1),
+		devm_kzalloc(mcasp->dev,
+			     array_size(sizeof(unsigned int), (32 + mcasp->num_serializer - 1)),
 			     GFP_KERNEL);
 
 	if (!mcasp->chconstr[SNDRV_PCM_STREAM_PLAYBACK].list ||
diff --git a/sound/soc/img/img-i2s-in.c b/sound/soc/img/img-i2s-in.c
index d7fbb0a0a28b..dab6c6f50b34 100644
--- a/sound/soc/img/img-i2s-in.c
+++ b/sound/soc/img/img-i2s-in.c
@@ -510,7 +510,8 @@ static int img_i2s_in_probe(struct platform_device *pdev)
 	pm_runtime_put(&pdev->dev);
 
 	i2s->suspend_ch_ctl = devm_kzalloc(dev,
-		sizeof(*i2s->suspend_ch_ctl) * i2s->max_i2s_chan, GFP_KERNEL);
+					   array_size(sizeof(*i2s->suspend_ch_ctl), i2s->max_i2s_chan),
+					   GFP_KERNEL);
 	if (!i2s->suspend_ch_ctl) {
 		ret = -ENOMEM;
 		goto err_suspend;
diff --git a/sound/soc/img/img-i2s-out.c b/sound/soc/img/img-i2s-out.c
index 30a95bcef2db..5205607b0d7f 100644
--- a/sound/soc/img/img-i2s-out.c
+++ b/sound/soc/img/img-i2s-out.c
@@ -480,7 +480,8 @@ static int img_i2s_out_probe(struct platform_device *pdev)
 	}
 
 	i2s->suspend_ch_ctl = devm_kzalloc(dev,
-		sizeof(*i2s->suspend_ch_ctl) * i2s->max_i2s_chan, GFP_KERNEL);
+					   array_size(sizeof(*i2s->suspend_ch_ctl), i2s->max_i2s_chan),
+					   GFP_KERNEL);
 	if (!i2s->suspend_ch_ctl)
 		return -ENOMEM;
 
diff --git a/sound/soc/uniphier/aio-cpu.c b/sound/soc/uniphier/aio-cpu.c
index 1e5eb8e6f8c7..db781dbde2e9 100644
--- a/sound/soc/uniphier/aio-cpu.c
+++ b/sound/soc/uniphier/aio-cpu.c
@@ -498,14 +498,15 @@ int uniphier_aio_probe(struct platform_device *pdev)
 
 	chip->num_aios = chip->chip_spec->num_dais;
 	chip->aios = devm_kzalloc(dev,
-				  sizeof(struct uniphier_aio) * chip->num_aios,
+				  array_size(sizeof(struct uniphier_aio), chip->num_aios),
 				  GFP_KERNEL);
 	if (!chip->aios)
 		return -ENOMEM;
 
 	chip->num_plls = chip->chip_spec->num_plls;
-	chip->plls = devm_kzalloc(dev, sizeof(struct uniphier_aio_pll) *
-				  chip->num_plls, GFP_KERNEL);
+	chip->plls = devm_kzalloc(dev,
+				  array_size(sizeof(struct uniphier_aio_pll), chip->num_plls),
+				  GFP_KERNEL);
 	if (!chip->plls)
 		return -ENOMEM;
 	memcpy(chip->plls, chip->chip_spec->plls,
-- 
2.17.0
