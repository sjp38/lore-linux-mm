Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A33536B02F6
	for <linux-mm@kvack.org>; Tue,  8 May 2018 20:42:48 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s7-v6so19017178pgp.15
        for <linux-mm@kvack.org>; Tue, 08 May 2018 17:42:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u17-v6sor10445289plj.121.2018.05.08.17.42.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 17:42:46 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 08/13] treewide: Use struct_size() for devm_kmalloc() and friends
Date: Tue,  8 May 2018 17:42:24 -0700
Message-Id: <20180509004229.36341-9-keescook@chromium.org>
In-Reply-To: <20180509004229.36341-1-keescook@chromium.org>
References: <20180509004229.36341-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Replaces open-coded struct size calculations with struct_size() for
devm_*, f2fs_*, and sock_* allocations. Automatically generated (and
manually adjusted) from the following Coccinelle script:

// Direct reference to struct field.
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP;
identifier VAR, ELEMENT;
expression COUNT;
@@

- alloc(HANDLE, sizeof(*VAR) + COUNT * sizeof(*VAR->ELEMENT), GFP)
+ alloc(HANDLE, struct_size(VAR, ELEMENT, COUNT), GFP)

// mr = kzalloc(sizeof(*mr) + m * sizeof(mr->map[0]), GFP_KERNEL);
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP;
identifier VAR, ELEMENT;
expression COUNT;
@@

- alloc(HANDLE, sizeof(*VAR) + COUNT * sizeof(VAR->ELEMENT[0]), GFP)
+ alloc(HANDLE, struct_size(VAR, ELEMENT, COUNT), GFP)

// Same pattern, but can't trivially locate the trailing element name,
// or variable name.
@@
identifier alloc =~ "devm_kmalloc|devm_kzalloc|sock_kmalloc|f2fs_kmalloc|f2fs_kzalloc";
expression HANDLE;
expression GFP;
expression SOMETHING, COUNT, ELEMENT;
@@

- alloc(HANDLE, sizeof(SOMETHING) + COUNT * sizeof(ELEMENT), GFP)
+ alloc(HANDLE, CHECKME_struct_size(&SOMETHING, ELEMENT, COUNT), GFP)

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 crypto/af_alg.c                                  | 4 ++--
 drivers/clk/bcm/clk-bcm2835-aux.c                | 5 +++--
 drivers/clk/bcm/clk-bcm2835.c                    | 4 ++--
 drivers/clk/clk-s2mps11.c                        | 4 ++--
 drivers/clk/clk-scmi.c                           | 4 ++--
 drivers/clk/davinci/da8xx-cfgchip.c              | 4 ++--
 drivers/clk/mvebu/armada-37xx-periph.c           | 7 ++++---
 drivers/clk/mvebu/armada-37xx-tbg.c              | 4 ++--
 drivers/clk/qcom/clk-spmi-pmic-div.c             | 3 +--
 drivers/clk/samsung/clk-exynos-audss.c           | 3 +--
 drivers/clk/samsung/clk-exynos5433.c             | 4 ++--
 drivers/clk/samsung/clk-s3c2410-dclk.c           | 6 +++---
 drivers/clk/samsung/clk-s5pv210-audss.c          | 3 +--
 drivers/dma/bcm-sba-raid.c                       | 5 ++---
 drivers/dma/nbpfaxi.c                            | 4 ++--
 drivers/dma/sprd-dma.c                           | 4 ++--
 drivers/gpio/gpio-uniphier.c                     | 3 +--
 drivers/hwspinlock/sirf_hwspinlock.c             | 5 +++--
 drivers/input/keyboard/cap11xx.c                 | 3 +--
 drivers/mfd/qcom-pm8xxx.c                        | 4 ++--
 drivers/misc/cb710/core.c                        | 4 ++--
 drivers/mtd/spi-nor/aspeed-smc.c                 | 5 +++--
 drivers/net/can/peak_canfd/peak_pciefd_main.c    | 3 +--
 drivers/pinctrl/samsung/pinctrl-s3c64xx.c        | 4 ++--
 drivers/pinctrl/uniphier/pinctrl-uniphier-core.c | 3 +--
 drivers/regulator/mc13783-regulator.c            | 6 +++---
 drivers/regulator/mc13892-regulator.c            | 6 +++---
 drivers/rtc/rtc-ac100.c                          | 7 +++----
 drivers/soc/actions/owl-sps.c                    | 4 ++--
 drivers/soc/rockchip/pm_domains.c                | 3 +--
 drivers/thermal/qcom/tsens.c                     | 6 +++---
 sound/soc/qcom/apq8016_sbc.c                     | 3 ++-
 32 files changed, 66 insertions(+), 71 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 7846c0c20cfe..bcbf6774f431 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -501,8 +501,8 @@ int af_alg_alloc_tsgl(struct sock *sk)
 		sg = sgl->sg;
 
 	if (!sg || sgl->cur >= MAX_SGL_ENTS) {
-		sgl = sock_kmalloc(sk, sizeof(*sgl) +
-				       sizeof(sgl->sg[0]) * (MAX_SGL_ENTS + 1),
+		sgl = sock_kmalloc(sk,
+				   struct_size(sgl, sg, (MAX_SGL_ENTS + 1)),
 				   GFP_KERNEL);
 		if (!sgl)
 			return -ENOMEM;
diff --git a/drivers/clk/bcm/clk-bcm2835-aux.c b/drivers/clk/bcm/clk-bcm2835-aux.c
index 77e276d61702..3e105c85e8a7 100644
--- a/drivers/clk/bcm/clk-bcm2835-aux.c
+++ b/drivers/clk/bcm/clk-bcm2835-aux.c
@@ -40,8 +40,9 @@ static int bcm2835_aux_clk_probe(struct platform_device *pdev)
 	if (IS_ERR(reg))
 		return PTR_ERR(reg);
 
-	onecell = devm_kmalloc(dev, sizeof(*onecell) + sizeof(*onecell->hws) *
-			       BCM2835_AUX_CLOCK_COUNT, GFP_KERNEL);
+	onecell = devm_kmalloc(dev,
+			       struct_size(onecell, hws, BCM2835_AUX_CLOCK_COUNT),
+			       GFP_KERNEL);
 	if (!onecell)
 		return -ENOMEM;
 	onecell->num = BCM2835_AUX_CLOCK_COUNT;
diff --git a/drivers/clk/bcm/clk-bcm2835.c b/drivers/clk/bcm/clk-bcm2835.c
index fa0d5c8611a0..c228bd6f6314 100644
--- a/drivers/clk/bcm/clk-bcm2835.c
+++ b/drivers/clk/bcm/clk-bcm2835.c
@@ -2147,8 +2147,8 @@ static int bcm2835_clk_probe(struct platform_device *pdev)
 	size_t i;
 	int ret;
 
-	cprman = devm_kzalloc(dev, sizeof(*cprman) +
-			      sizeof(*cprman->onecell.hws) * asize,
+	cprman = devm_kzalloc(dev,
+			      CHECKME_struct_size(cprman, onecell.hws, asize),
 			      GFP_KERNEL);
 	if (!cprman)
 		return -ENOMEM;
diff --git a/drivers/clk/clk-s2mps11.c b/drivers/clk/clk-s2mps11.c
index fbaa84a33c46..d44e0eea31ec 100644
--- a/drivers/clk/clk-s2mps11.c
+++ b/drivers/clk/clk-s2mps11.c
@@ -147,8 +147,8 @@ static int s2mps11_clk_probe(struct platform_device *pdev)
 	if (!s2mps11_clks)
 		return -ENOMEM;
 
-	clk_data = devm_kzalloc(&pdev->dev, sizeof(*clk_data) +
-				sizeof(*clk_data->hws) * S2MPS11_CLKS_NUM,
+	clk_data = devm_kzalloc(&pdev->dev,
+				struct_size(clk_data, hws, S2MPS11_CLKS_NUM),
 				GFP_KERNEL);
 	if (!clk_data)
 		return -ENOMEM;
diff --git a/drivers/clk/clk-scmi.c b/drivers/clk/clk-scmi.c
index 488c21376b55..bb2a6f2f5516 100644
--- a/drivers/clk/clk-scmi.c
+++ b/drivers/clk/clk-scmi.c
@@ -137,8 +137,8 @@ static int scmi_clocks_probe(struct scmi_device *sdev)
 		return -EINVAL;
 	}
 
-	clk_data = devm_kzalloc(dev, sizeof(*clk_data) +
-				sizeof(*clk_data->hws) * count, GFP_KERNEL);
+	clk_data = devm_kzalloc(dev, struct_size(clk_data, hws, count),
+				GFP_KERNEL);
 	if (!clk_data)
 		return -ENOMEM;
 
diff --git a/drivers/clk/davinci/da8xx-cfgchip.c b/drivers/clk/davinci/da8xx-cfgchip.c
index c971111d2601..aae62a5b8734 100644
--- a/drivers/clk/davinci/da8xx-cfgchip.c
+++ b/drivers/clk/davinci/da8xx-cfgchip.c
@@ -650,8 +650,8 @@ static int of_da8xx_usb_phy_clk_init(struct device *dev, struct regmap *regmap)
 	struct da8xx_usb0_clk48 *usb0;
 	struct da8xx_usb1_clk48 *usb1;
 
-	clk_data = devm_kzalloc(dev, sizeof(*clk_data) + 2 *
-				sizeof(*clk_data->hws), GFP_KERNEL);
+	clk_data = devm_kzalloc(dev, struct_size(clk_data, hws, 2),
+				GFP_KERNEL);
 	if (!clk_data)
 		return -ENOMEM;
 
diff --git a/drivers/clk/mvebu/armada-37xx-periph.c b/drivers/clk/mvebu/armada-37xx-periph.c
index 87213ea7fc84..6860bd5a37c5 100644
--- a/drivers/clk/mvebu/armada-37xx-periph.c
+++ b/drivers/clk/mvebu/armada-37xx-periph.c
@@ -667,9 +667,10 @@ static int armada_3700_periph_clock_probe(struct platform_device *pdev)
 	if (!driver_data)
 		return -ENOMEM;
 
-	driver_data->hw_data = devm_kzalloc(dev, sizeof(*driver_data->hw_data) +
-			    sizeof(*driver_data->hw_data->hws) * num_periph,
-			    GFP_KERNEL);
+	driver_data->hw_data = devm_kzalloc(dev,
+					    struct_size(driver_data->hw_data,
+							hws, num_periph),
+					    GFP_KERNEL);
 	if (!driver_data->hw_data)
 		return -ENOMEM;
 	driver_data->hw_data->num = num_periph;
diff --git a/drivers/clk/mvebu/armada-37xx-tbg.c b/drivers/clk/mvebu/armada-37xx-tbg.c
index aa80db11f543..7ff041f73b55 100644
--- a/drivers/clk/mvebu/armada-37xx-tbg.c
+++ b/drivers/clk/mvebu/armada-37xx-tbg.c
@@ -91,8 +91,8 @@ static int armada_3700_tbg_clock_probe(struct platform_device *pdev)
 	void __iomem *reg;
 	int i, ret;
 
-	hw_tbg_data = devm_kzalloc(&pdev->dev, sizeof(*hw_tbg_data)
-				   + sizeof(*hw_tbg_data->hws) * NUM_TBG,
+	hw_tbg_data = devm_kzalloc(&pdev->dev,
+				   struct_size(hw_tbg_data, hws, NUM_TBG),
 				   GFP_KERNEL);
 	if (!hw_tbg_data)
 		return -ENOMEM;
diff --git a/drivers/clk/qcom/clk-spmi-pmic-div.c b/drivers/clk/qcom/clk-spmi-pmic-div.c
index 8672ab84746f..c90dfdd6c147 100644
--- a/drivers/clk/qcom/clk-spmi-pmic-div.c
+++ b/drivers/clk/qcom/clk-spmi-pmic-div.c
@@ -239,8 +239,7 @@ static int spmi_pmic_clkdiv_probe(struct platform_device *pdev)
 	if (!nclks)
 		return -EINVAL;
 
-	cc = devm_kzalloc(dev, sizeof(*cc) + sizeof(*cc->clks) * nclks,
-			  GFP_KERNEL);
+	cc = devm_kzalloc(dev, struct_size(cc, clks, nclks), GFP_KERNEL);
 	if (!cc)
 		return -ENOMEM;
 	cc->nclks = nclks;
diff --git a/drivers/clk/samsung/clk-exynos-audss.c b/drivers/clk/samsung/clk-exynos-audss.c
index b4b057c7301c..3eb2828283a5 100644
--- a/drivers/clk/samsung/clk-exynos-audss.c
+++ b/drivers/clk/samsung/clk-exynos-audss.c
@@ -149,8 +149,7 @@ static int exynos_audss_clk_probe(struct platform_device *pdev)
 	epll = ERR_PTR(-ENODEV);
 
 	clk_data = devm_kzalloc(dev,
-				sizeof(*clk_data) +
-				sizeof(*clk_data->hws) * EXYNOS_AUDSS_MAX_CLKS,
+				struct_size(clk_data, hws, EXYNOS_AUDSS_MAX_CLKS),
 				GFP_KERNEL);
 	if (!clk_data)
 		return -ENOMEM;
diff --git a/drivers/clk/samsung/clk-exynos5433.c b/drivers/clk/samsung/clk-exynos5433.c
index 5305ace514b2..162de44df099 100644
--- a/drivers/clk/samsung/clk-exynos5433.c
+++ b/drivers/clk/samsung/clk-exynos5433.c
@@ -5505,8 +5505,8 @@ static int __init exynos5433_cmu_probe(struct platform_device *pdev)
 
 	info = of_device_get_match_data(dev);
 
-	data = devm_kzalloc(dev, sizeof(*data) +
-			    sizeof(*data->ctx.clk_data.hws) * info->nr_clk_ids,
+	data = devm_kzalloc(dev,
+			    struct_size(data, ctx.clk_data.hws, info->nr_clk_ids),
 			    GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
diff --git a/drivers/clk/samsung/clk-s3c2410-dclk.c b/drivers/clk/samsung/clk-s3c2410-dclk.c
index 077df3e539a7..98e05e9b22c8 100644
--- a/drivers/clk/samsung/clk-s3c2410-dclk.c
+++ b/drivers/clk/samsung/clk-s3c2410-dclk.c
@@ -247,9 +247,9 @@ static int s3c24xx_dclk_probe(struct platform_device *pdev)
 	struct clk_hw **clk_table;
 	int ret, i;
 
-	s3c24xx_dclk = devm_kzalloc(&pdev->dev, sizeof(*s3c24xx_dclk) +
-			    sizeof(*s3c24xx_dclk->clk_data.hws) * DCLK_MAX_CLKS,
-			    GFP_KERNEL);
+	s3c24xx_dclk = devm_kzalloc(&pdev->dev,
+				    struct_size(s3c24xx_dclk, clk_data.hws, DCLK_MAX_CLKS),
+				    GFP_KERNEL);
 	if (!s3c24xx_dclk)
 		return -ENOMEM;
 
diff --git a/drivers/clk/samsung/clk-s5pv210-audss.c b/drivers/clk/samsung/clk-s5pv210-audss.c
index b9641414ddc6..22b18e728b88 100644
--- a/drivers/clk/samsung/clk-s5pv210-audss.c
+++ b/drivers/clk/samsung/clk-s5pv210-audss.c
@@ -81,8 +81,7 @@ static int s5pv210_audss_clk_probe(struct platform_device *pdev)
 	}
 
 	clk_data = devm_kzalloc(&pdev->dev,
-				sizeof(*clk_data) +
-				sizeof(*clk_data->hws) * AUDSS_MAX_CLKS,
+				struct_size(clk_data, hws, AUDSS_MAX_CLKS),
 				GFP_KERNEL);
 
 	if (!clk_data)
diff --git a/drivers/dma/bcm-sba-raid.c b/drivers/dma/bcm-sba-raid.c
index 3956a018bf5a..72878ac5c78d 100644
--- a/drivers/dma/bcm-sba-raid.c
+++ b/drivers/dma/bcm-sba-raid.c
@@ -1499,9 +1499,8 @@ static int sba_prealloc_channel_resources(struct sba_device *sba)
 
 	for (i = 0; i < sba->max_req; i++) {
 		req = devm_kzalloc(sba->dev,
-				sizeof(*req) +
-				sba->max_cmd_per_req * sizeof(req->cmds[0]),
-				GFP_KERNEL);
+				   struct_size(req, cmds, sba->max_cmd_per_req),
+				   GFP_KERNEL);
 		if (!req) {
 			ret = -ENOMEM;
 			goto fail_free_cmds_pool;
diff --git a/drivers/dma/nbpfaxi.c b/drivers/dma/nbpfaxi.c
index 50559338239b..2f9974ddfbb2 100644
--- a/drivers/dma/nbpfaxi.c
+++ b/drivers/dma/nbpfaxi.c
@@ -1305,8 +1305,8 @@ static int nbpf_probe(struct platform_device *pdev)
 	cfg = of_device_get_match_data(dev);
 	num_channels = cfg->num_channels;
 
-	nbpf = devm_kzalloc(dev, sizeof(*nbpf) + num_channels *
-			    sizeof(nbpf->chan[0]), GFP_KERNEL);
+	nbpf = devm_kzalloc(dev, struct_size(nbpf, chan, num_channels),
+			    GFP_KERNEL);
 	if (!nbpf)
 		return -ENOMEM;
 
diff --git a/drivers/dma/sprd-dma.c b/drivers/dma/sprd-dma.c
index b106e8a60af6..52ebccb483be 100644
--- a/drivers/dma/sprd-dma.c
+++ b/drivers/dma/sprd-dma.c
@@ -805,8 +805,8 @@ static int sprd_dma_probe(struct platform_device *pdev)
 		return ret;
 	}
 
-	sdev = devm_kzalloc(&pdev->dev, sizeof(*sdev) +
-			    sizeof(*dma_chn) * chn_count,
+	sdev = devm_kzalloc(&pdev->dev,
+			    struct_size(sdev, channels, chn_count),
 			    GFP_KERNEL);
 	if (!sdev)
 		return -ENOMEM;
diff --git a/drivers/gpio/gpio-uniphier.c b/drivers/gpio/gpio-uniphier.c
index 761d8279abca..d3cf9502e7e7 100644
--- a/drivers/gpio/gpio-uniphier.c
+++ b/drivers/gpio/gpio-uniphier.c
@@ -371,8 +371,7 @@ static int uniphier_gpio_probe(struct platform_device *pdev)
 		return ret;
 
 	nregs = uniphier_gpio_get_nbanks(ngpios) * 2 + 3;
-	priv = devm_kzalloc(dev,
-			    sizeof(*priv) + sizeof(priv->saved_vals[0]) * nregs,
+	priv = devm_kzalloc(dev, struct_size(priv, saved_vals, nregs),
 			    GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
diff --git a/drivers/hwspinlock/sirf_hwspinlock.c b/drivers/hwspinlock/sirf_hwspinlock.c
index 16018544d431..67909c3e2beb 100644
--- a/drivers/hwspinlock/sirf_hwspinlock.c
+++ b/drivers/hwspinlock/sirf_hwspinlock.c
@@ -62,8 +62,9 @@ static int sirf_hwspinlock_probe(struct platform_device *pdev)
 	if (!pdev->dev.of_node)
 		return -ENODEV;
 
-	hwspin = devm_kzalloc(&pdev->dev, sizeof(*hwspin) +
-			sizeof(*hwlock) * HW_SPINLOCK_NUMBER, GFP_KERNEL);
+	hwspin = devm_kzalloc(&pdev->dev,
+			      struct_size(hwspin, lock, HW_SPINLOCK_NUMBER),
+			      GFP_KERNEL);
 	if (!hwspin)
 		return -ENOMEM;
 
diff --git a/drivers/input/keyboard/cap11xx.c b/drivers/input/keyboard/cap11xx.c
index 1a1eacae3ea1..312916f99597 100644
--- a/drivers/input/keyboard/cap11xx.c
+++ b/drivers/input/keyboard/cap11xx.c
@@ -357,8 +357,7 @@ static int cap11xx_i2c_probe(struct i2c_client *i2c_client,
 	}
 
 	priv = devm_kzalloc(dev,
-			    sizeof(*priv) +
-				cap->num_channels * sizeof(priv->keycodes[0]),
+			    struct_size(priv, keycodes, cap->num_channels),
 			    GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
diff --git a/drivers/mfd/qcom-pm8xxx.c b/drivers/mfd/qcom-pm8xxx.c
index f08758f6b418..e6e8d81c15fd 100644
--- a/drivers/mfd/qcom-pm8xxx.c
+++ b/drivers/mfd/qcom-pm8xxx.c
@@ -563,8 +563,8 @@ static int pm8xxx_probe(struct platform_device *pdev)
 	pr_info("PMIC revision 2: %02X\n", val);
 	rev |= val << BITS_PER_BYTE;
 
-	chip = devm_kzalloc(&pdev->dev, sizeof(*chip) +
-			    sizeof(chip->config[0]) * data->num_irqs,
+	chip = devm_kzalloc(&pdev->dev,
+			    struct_size(chip, config, data->num_irqs),
 			    GFP_KERNEL);
 	if (!chip)
 		return -ENOMEM;
diff --git a/drivers/misc/cb710/core.c b/drivers/misc/cb710/core.c
index fb397e7d1cce..4d4acf763b65 100644
--- a/drivers/misc/cb710/core.c
+++ b/drivers/misc/cb710/core.c
@@ -232,8 +232,8 @@ static int cb710_probe(struct pci_dev *pdev,
 	if (val & CB710_SLOT_SM)
 		++n;
 
-	chip = devm_kzalloc(&pdev->dev,
-		sizeof(*chip) + n * sizeof(*chip->slot), GFP_KERNEL);
+	chip = devm_kzalloc(&pdev->dev, struct_size(chip, slot, n),
+			    GFP_KERNEL);
 	if (!chip)
 		return -ENOMEM;
 
diff --git a/drivers/mtd/spi-nor/aspeed-smc.c b/drivers/mtd/spi-nor/aspeed-smc.c
index 8d3cbe27efb6..95e54468cf7d 100644
--- a/drivers/mtd/spi-nor/aspeed-smc.c
+++ b/drivers/mtd/spi-nor/aspeed-smc.c
@@ -861,8 +861,9 @@ static int aspeed_smc_probe(struct platform_device *pdev)
 		return -ENODEV;
 	info = match->data;
 
-	controller = devm_kzalloc(&pdev->dev, sizeof(*controller) +
-		info->nce * sizeof(controller->chips[0]), GFP_KERNEL);
+	controller = devm_kzalloc(&pdev->dev,
+				  struct_size(controller, chips, info->nce),
+				  GFP_KERNEL);
 	if (!controller)
 		return -ENOMEM;
 	controller->info = info;
diff --git a/drivers/net/can/peak_canfd/peak_pciefd_main.c b/drivers/net/can/peak_canfd/peak_pciefd_main.c
index 3c51a884db87..b9e28578bc7b 100644
--- a/drivers/net/can/peak_canfd/peak_pciefd_main.c
+++ b/drivers/net/can/peak_canfd/peak_pciefd_main.c
@@ -752,8 +752,7 @@ static int peak_pciefd_probe(struct pci_dev *pdev,
 		can_count = 1;
 
 	/* allocate board structure object */
-	pciefd = devm_kzalloc(&pdev->dev, sizeof(*pciefd) +
-			      can_count * sizeof(*pciefd->can),
+	pciefd = devm_kzalloc(&pdev->dev, struct_size(pciefd, can, can_count),
 			      GFP_KERNEL);
 	if (!pciefd) {
 		err = -ENOMEM;
diff --git a/drivers/pinctrl/samsung/pinctrl-s3c64xx.c b/drivers/pinctrl/samsung/pinctrl-s3c64xx.c
index 288e6567ceb1..c399f0932af5 100644
--- a/drivers/pinctrl/samsung/pinctrl-s3c64xx.c
+++ b/drivers/pinctrl/samsung/pinctrl-s3c64xx.c
@@ -483,8 +483,8 @@ static int s3c64xx_eint_gpio_init(struct samsung_pinctrl_drv_data *d)
 		++nr_domains;
 	}
 
-	data = devm_kzalloc(dev, sizeof(*data)
-			+ nr_domains * sizeof(*data->domains), GFP_KERNEL);
+	data = devm_kzalloc(dev, struct_size(data, domains, nr_domains),
+			    GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
 	data->drvdata = d;
diff --git a/drivers/pinctrl/uniphier/pinctrl-uniphier-core.c b/drivers/pinctrl/uniphier/pinctrl-uniphier-core.c
index ec0f77afeaa4..add8e870667b 100644
--- a/drivers/pinctrl/uniphier/pinctrl-uniphier-core.c
+++ b/drivers/pinctrl/uniphier/pinctrl-uniphier-core.c
@@ -759,8 +759,7 @@ static int uniphier_pinctrl_add_reg_region(struct device *dev,
 
 	nregs = DIV_ROUND_UP(count * width, 32);
 
-	region = devm_kzalloc(dev,
-			      sizeof(*region) + sizeof(region->vals[0]) * nregs,
+	region = devm_kzalloc(dev, struct_size(region, vals, nregs),
 			      GFP_KERNEL);
 	if (!region)
 		return -ENOMEM;
diff --git a/drivers/regulator/mc13783-regulator.c b/drivers/regulator/mc13783-regulator.c
index fe4c7d677f9c..0e0277bd91a8 100644
--- a/drivers/regulator/mc13783-regulator.c
+++ b/drivers/regulator/mc13783-regulator.c
@@ -409,9 +409,9 @@ static int mc13783_regulator_probe(struct platform_device *pdev)
 	if (num_regulators <= 0)
 		return -EINVAL;
 
-	priv = devm_kzalloc(&pdev->dev, sizeof(*priv) +
-			num_regulators * sizeof(priv->regulators[0]),
-			GFP_KERNEL);
+	priv = devm_kzalloc(&pdev->dev,
+			    struct_size(priv, regulators, num_regulators),
+			    GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
 
diff --git a/drivers/regulator/mc13892-regulator.c b/drivers/regulator/mc13892-regulator.c
index 0d17c9206816..15dd7bc7b529 100644
--- a/drivers/regulator/mc13892-regulator.c
+++ b/drivers/regulator/mc13892-regulator.c
@@ -547,9 +547,9 @@ static int mc13892_regulator_probe(struct platform_device *pdev)
 	if (num_regulators <= 0)
 		return -EINVAL;
 
-	priv = devm_kzalloc(&pdev->dev, sizeof(*priv) +
-		num_regulators * sizeof(priv->regulators[0]),
-		GFP_KERNEL);
+	priv = devm_kzalloc(&pdev->dev,
+			    struct_size(priv, regulators, num_regulators),
+			    GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
 
diff --git a/drivers/rtc/rtc-ac100.c b/drivers/rtc/rtc-ac100.c
index 3fe576fdd45e..d3a7661ca720 100644
--- a/drivers/rtc/rtc-ac100.c
+++ b/drivers/rtc/rtc-ac100.c
@@ -317,10 +317,9 @@ static int ac100_rtc_register_clks(struct ac100_rtc_dev *chip)
 	const char *parents[2] = {AC100_RTC_32K_NAME};
 	int i, ret;
 
-	chip->clk_data = devm_kzalloc(chip->dev, sizeof(*chip->clk_data) +
-						 sizeof(*chip->clk_data->hws) *
-						 AC100_CLKOUT_NUM,
-						 GFP_KERNEL);
+	chip->clk_data = devm_kzalloc(chip->dev,
+				      struct_size(chip->clk_data, hws, AC100_CLKOUT_NUM),
+				      GFP_KERNEL);
 	if (!chip->clk_data)
 		return -ENOMEM;
 
diff --git a/drivers/soc/actions/owl-sps.c b/drivers/soc/actions/owl-sps.c
index 8477f0f18e24..032921d8d41f 100644
--- a/drivers/soc/actions/owl-sps.c
+++ b/drivers/soc/actions/owl-sps.c
@@ -117,8 +117,8 @@ static int owl_sps_probe(struct platform_device *pdev)
 
 	sps_info = match->data;
 
-	sps = devm_kzalloc(&pdev->dev, sizeof(*sps) +
-			   sps_info->num_domains * sizeof(sps->domains[0]),
+	sps = devm_kzalloc(&pdev->dev,
+			   struct_size(sps, domains, sps_info->num_domains),
 			   GFP_KERNEL);
 	if (!sps)
 		return -ENOMEM;
diff --git a/drivers/soc/rockchip/pm_domains.c b/drivers/soc/rockchip/pm_domains.c
index 53efc386b1ad..111c44fc1c12 100644
--- a/drivers/soc/rockchip/pm_domains.c
+++ b/drivers/soc/rockchip/pm_domains.c
@@ -626,8 +626,7 @@ static int rockchip_pm_domain_probe(struct platform_device *pdev)
 	pmu_info = match->data;
 
 	pmu = devm_kzalloc(dev,
-			   sizeof(*pmu) +
-				pmu_info->num_domains * sizeof(pmu->domains[0]),
+			   struct_size(pmu, domains, pmu_info->num_domains),
 			   GFP_KERNEL);
 	if (!pmu)
 		return -ENOMEM;
diff --git a/drivers/thermal/qcom/tsens.c b/drivers/thermal/qcom/tsens.c
index 3f9fe6aa51cc..c2c34425279d 100644
--- a/drivers/thermal/qcom/tsens.c
+++ b/drivers/thermal/qcom/tsens.c
@@ -112,7 +112,6 @@ static int tsens_probe(struct platform_device *pdev)
 	int ret, i;
 	struct device *dev;
 	struct device_node *np;
-	struct tsens_sensor *s;
 	struct tsens_device *tmdev;
 	const struct tsens_data *data;
 	const struct of_device_id *id;
@@ -135,8 +134,9 @@ static int tsens_probe(struct platform_device *pdev)
 		return -EINVAL;
 	}
 
-	tmdev = devm_kzalloc(dev, sizeof(*tmdev) +
-			     data->num_sensors * sizeof(*s), GFP_KERNEL);
+	tmdev = devm_kzalloc(dev,
+			     struct_size(tmdev, sensor, data->num_sensors),
+			     GFP_KERNEL);
 	if (!tmdev)
 		return -ENOMEM;
 
diff --git a/sound/soc/qcom/apq8016_sbc.c b/sound/soc/qcom/apq8016_sbc.c
index 704428735e3c..1dd23bba1bed 100644
--- a/sound/soc/qcom/apq8016_sbc.c
+++ b/sound/soc/qcom/apq8016_sbc.c
@@ -147,7 +147,8 @@ static struct apq8016_sbc_data *apq8016_sbc_parse_of(struct snd_soc_card *card)
 	num_links = of_get_child_count(node);
 
 	/* Allocate the private data and the DAI link array */
-	data = devm_kzalloc(dev, sizeof(*data) + sizeof(*link) * num_links,
+	data = devm_kzalloc(dev,
+			    struct_size(data, dai_link, num_links),
 			    GFP_KERNEL);
 	if (!data)
 		return ERR_PTR(-ENOMEM);
-- 
2.17.0
