Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD986B026E
	for <linux-mm@kvack.org>; Thu, 31 May 2018 20:43:54 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f35-v6so14228036plb.10
        for <linux-mm@kvack.org>; Thu, 31 May 2018 17:43:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v41-v6sor15228455plg.73.2018.05.31.17.43.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 17:43:52 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 09/16] treewide: Use struct_size() for kmalloc()-family
Date: Thu, 31 May 2018 17:42:26 -0700
Message-Id: <20180601004233.37822-10-keescook@chromium.org>
In-Reply-To: <20180601004233.37822-1-keescook@chromium.org>
References: <20180601004233.37822-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

Automatic conversion with manual review for non-standard cases, using
the following Coccinelle script:

// pkey_cache = kmalloc(sizeof *pkey_cache + tprops->pkey_tbl_len *
//                      sizeof *pkey_cache->table, GFP_KERNEL);
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP;
identifier VAR, ELEMENT;
expression COUNT;
@@

- alloc(sizeof(*VAR) + COUNT * sizeof(*VAR->ELEMENT), GFP)
+ alloc(struct_size(VAR, ELEMENT, COUNT), GFP)

// mr = kzalloc(sizeof(*mr) + m * sizeof(mr->map[0]), GFP_KERNEL);
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP;
identifier VAR, ELEMENT;
expression COUNT;
@@

- alloc(sizeof(*VAR) + COUNT * sizeof(VAR->ELEMENT[0]), GFP)
+ alloc(struct_size(VAR, ELEMENT, COUNT), GFP)

// Same pattern, but can't trivially locate the trailing element name,
// or variable name.
@@
identifier alloc =~ "kmalloc|kzalloc|kvmalloc|kvzalloc";
expression GFP;
expression SOMETHING, COUNT, ELEMENT;
@@

- alloc(sizeof(SOMETHING) + COUNT * sizeof(ELEMENT), GFP)
+ alloc(CHECKME_struct_size(&SOMETHING, ELEMENT, COUNT), GFP)

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/clk/bcm/clk-iproc-asiu.c                |  4 ++--
 drivers/clk/bcm/clk-iproc-pll.c                 |  3 +--
 drivers/clk/berlin/bg2.c                        |  3 +--
 drivers/clk/berlin/bg2q.c                       |  3 +--
 drivers/clk/clk-asm9260.c                       |  3 +--
 drivers/clk/clk-aspeed.c                        |  5 ++---
 drivers/clk/clk-clps711x.c                      |  5 ++---
 drivers/clk/clk-efm32gg.c                       |  4 ++--
 drivers/clk/clk-gemini.c                        |  5 ++---
 drivers/clk/clk-stm32h7.c                       |  5 ++---
 drivers/clk/clk-stm32mp1.c                      |  5 ++---
 drivers/clk/samsung/clk-exynos-clkout.c         |  3 +--
 drivers/dax/device.c                            |  2 +-
 drivers/dma/edma.c                              |  9 +++------
 drivers/dma/moxart-dma.c                        |  2 +-
 drivers/dma/omap-dma.c                          |  2 +-
 drivers/dma/sa11x0-dma.c                        |  4 ++--
 drivers/dma/sh/usb-dmac.c                       |  2 +-
 drivers/firewire/core-topology.c                |  3 +--
 drivers/gpio/gpiolib.c                          |  3 +--
 drivers/gpu/drm/nouveau/nvkm/engine/pm/base.c   |  4 ++--
 drivers/hwspinlock/omap_hwspinlock.c            |  2 +-
 drivers/hwspinlock/u8500_hsem.c                 |  2 +-
 drivers/infiniband/core/cache.c                 |  4 ++--
 drivers/infiniband/core/cm.c                    |  4 ++--
 drivers/infiniband/core/multicast.c             |  2 +-
 drivers/infiniband/core/uverbs_cmd.c            |  4 ++--
 drivers/infiniband/core/uverbs_ioctl_merge.c    | 17 ++++++-----------
 drivers/infiniband/hw/mthca/mthca_memfree.c     |  4 ++--
 drivers/infiniband/sw/rdmavt/mr.c               |  4 ++--
 drivers/input/input-leds.c                      |  3 +--
 drivers/input/input-mt.c                        |  2 +-
 drivers/md/dm-raid.c                            |  2 +-
 drivers/misc/vexpress-syscfg.c                  |  3 +--
 .../net/ethernet/mellanox/mlx5/core/debugfs.c   |  2 +-
 .../net/ethernet/mellanox/mlx5/core/fs_core.c   |  3 +--
 .../net/wireless/intel/iwlwifi/mvm/mac80211.c   |  4 +---
 drivers/net/wireless/mediatek/mt76/agg-rx.c     |  3 +--
 drivers/reset/core.c                            |  3 +--
 drivers/s390/cio/ccwgroup.c                     |  3 +--
 drivers/staging/greybus/module.c                |  4 ++--
 drivers/usb/gadget/function/f_midi.c            |  5 ++---
 drivers/zorro/zorro.c                           |  3 +--
 fs/afs/addr_list.c                              |  3 +--
 kernel/cgroup/cgroup.c                          |  4 ++--
 kernel/module.c                                 |  3 +--
 kernel/workqueue.c                              |  3 +--
 net/ceph/mon_client.c                           |  5 ++---
 net/ceph/osd_client.c                           |  3 +--
 net/netfilter/xt_recent.c                       |  3 +--
 net/sctp/endpointola.c                          |  4 ++--
 sound/core/vmaster.c                            |  4 ++--
 sound/soc/soc-dapm.c                            |  2 +-
 53 files changed, 80 insertions(+), 116 deletions(-)

diff --git a/drivers/clk/bcm/clk-iproc-asiu.c b/drivers/clk/bcm/clk-iproc-asiu.c
index 4360e481368b..6fb8af506777 100644
--- a/drivers/clk/bcm/clk-iproc-asiu.c
+++ b/drivers/clk/bcm/clk-iproc-asiu.c
@@ -197,8 +197,8 @@ void __init iproc_asiu_setup(struct device_node *node,
 	if (WARN_ON(!asiu))
 		return;
 
-	asiu->clk_data = kzalloc(sizeof(*asiu->clk_data->hws) * num_clks +
-				 sizeof(*asiu->clk_data), GFP_KERNEL);
+	asiu->clk_data = kzalloc(struct_size(asiu->clk_data, hws, num_clks),
+				 GFP_KERNEL);
 	if (WARN_ON(!asiu->clk_data))
 		goto err_clks;
 	asiu->clk_data->num = num_clks;
diff --git a/drivers/clk/bcm/clk-iproc-pll.c b/drivers/clk/bcm/clk-iproc-pll.c
index 43a58ae5a89d..274441e2ddb2 100644
--- a/drivers/clk/bcm/clk-iproc-pll.c
+++ b/drivers/clk/bcm/clk-iproc-pll.c
@@ -744,8 +744,7 @@ void iproc_pll_clk_setup(struct device_node *node,
 	if (WARN_ON(!pll))
 		return;
 
-	clk_data = kzalloc(sizeof(*clk_data->hws) * num_clks +
-				sizeof(*clk_data), GFP_KERNEL);
+	clk_data = kzalloc(struct_size(clk_data, hws, num_clks), GFP_KERNEL);
 	if (WARN_ON(!clk_data))
 		goto err_clk_data;
 	clk_data->num = num_clks;
diff --git a/drivers/clk/berlin/bg2.c b/drivers/clk/berlin/bg2.c
index e7331ace0337..45fb888bf0a0 100644
--- a/drivers/clk/berlin/bg2.c
+++ b/drivers/clk/berlin/bg2.c
@@ -509,8 +509,7 @@ static void __init berlin2_clock_setup(struct device_node *np)
 	u8 avpll_flags = 0;
 	int n, ret;
 
-	clk_data = kzalloc(sizeof(*clk_data) +
-			   sizeof(*clk_data->hws) * MAX_CLKS, GFP_KERNEL);
+	clk_data = kzalloc(struct_size(clk_data, hws, MAX_CLKS), GFP_KERNEL);
 	if (!clk_data)
 		return;
 	clk_data->num = MAX_CLKS;
diff --git a/drivers/clk/berlin/bg2q.c b/drivers/clk/berlin/bg2q.c
index 67c270b143f7..db7364e15c8b 100644
--- a/drivers/clk/berlin/bg2q.c
+++ b/drivers/clk/berlin/bg2q.c
@@ -295,8 +295,7 @@ static void __init berlin2q_clock_setup(struct device_node *np)
 	struct clk_hw **hws;
 	int n, ret;
 
-	clk_data = kzalloc(sizeof(*clk_data) +
-			   sizeof(*clk_data->hws) * MAX_CLKS, GFP_KERNEL);
+	clk_data = kzalloc(struct_size(clk_data, hws, MAX_CLKS), GFP_KERNEL);
 	if (!clk_data)
 		return;
 	clk_data->num = MAX_CLKS;
diff --git a/drivers/clk/clk-asm9260.c b/drivers/clk/clk-asm9260.c
index bf0582cbbf38..44b544157121 100644
--- a/drivers/clk/clk-asm9260.c
+++ b/drivers/clk/clk-asm9260.c
@@ -273,8 +273,7 @@ static void __init asm9260_acc_init(struct device_node *np)
 	int n;
 	u32 accuracy = 0;
 
-	clk_data = kzalloc(sizeof(*clk_data) +
-			   sizeof(*clk_data->hws) * MAX_CLKS, GFP_KERNEL);
+	clk_data = kzalloc(struct_size(clk_data, hws, MAX_CLKS), GFP_KERNEL);
 	if (!clk_data)
 		return;
 	clk_data->num = MAX_CLKS;
diff --git a/drivers/clk/clk-aspeed.c b/drivers/clk/clk-aspeed.c
index 5eb50c31e455..7e93bfdf999c 100644
--- a/drivers/clk/clk-aspeed.c
+++ b/drivers/clk/clk-aspeed.c
@@ -627,9 +627,8 @@ static void __init aspeed_cc_init(struct device_node *np)
 	if (!scu_base)
 		return;
 
-	aspeed_clk_data = kzalloc(sizeof(*aspeed_clk_data) +
-			sizeof(*aspeed_clk_data->hws) * ASPEED_NUM_CLKS,
-			GFP_KERNEL);
+	aspeed_clk_data = kzalloc(struct_size(aspeed_clk_data, hws, ASPEED_NUM_CLKS),
+				  GFP_KERNEL);
 	if (!aspeed_clk_data)
 		return;
 
diff --git a/drivers/clk/clk-clps711x.c b/drivers/clk/clk-clps711x.c
index 9193f64561f6..068b563bf2c5 100644
--- a/drivers/clk/clk-clps711x.c
+++ b/drivers/clk/clk-clps711x.c
@@ -54,9 +54,8 @@ static struct clps711x_clk * __init _clps711x_clk_init(void __iomem *base,
 	if (!base)
 		return ERR_PTR(-ENOMEM);
 
-	clps711x_clk = kzalloc(sizeof(*clps711x_clk) +
-			sizeof(*clps711x_clk->clk_data.hws) * CLPS711X_CLK_MAX,
-			GFP_KERNEL);
+	clps711x_clk = kzalloc(struct_size(clps711x_clk, clk_data.hws, CLPS711X_CLK_MAX),
+			       GFP_KERNEL);
 	if (!clps711x_clk)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/clk/clk-efm32gg.c b/drivers/clk/clk-efm32gg.c
index f674778fb3ac..f37cf08ff7aa 100644
--- a/drivers/clk/clk-efm32gg.c
+++ b/drivers/clk/clk-efm32gg.c
@@ -25,8 +25,8 @@ static void __init efm32gg_cmu_init(struct device_node *np)
 	void __iomem *base;
 	struct clk_hw **hws;
 
-	clk_data = kzalloc(sizeof(*clk_data) +
-			   sizeof(*clk_data->hws) * CMU_MAX_CLKS, GFP_KERNEL);
+	clk_data = kzalloc(struct_size(clk_data, hws, CMU_MAX_CLKS),
+			   GFP_KERNEL);
 
 	if (!clk_data)
 		return;
diff --git a/drivers/clk/clk-gemini.c b/drivers/clk/clk-gemini.c
index 5e66e6c0205e..5f044063f410 100644
--- a/drivers/clk/clk-gemini.c
+++ b/drivers/clk/clk-gemini.c
@@ -399,9 +399,8 @@ static void __init gemini_cc_init(struct device_node *np)
 	int ret;
 	int i;
 
-	gemini_clk_data = kzalloc(sizeof(*gemini_clk_data) +
-			sizeof(*gemini_clk_data->hws) * GEMINI_NUM_CLKS,
-			GFP_KERNEL);
+	gemini_clk_data = kzalloc(struct_size(gemini_clk_data, hws, GEMINI_NUM_CLKS),
+				  GFP_KERNEL);
 	if (!gemini_clk_data)
 		return;
 
diff --git a/drivers/clk/clk-stm32h7.c b/drivers/clk/clk-stm32h7.c
index db2b162c0d4c..d3271eca3779 100644
--- a/drivers/clk/clk-stm32h7.c
+++ b/drivers/clk/clk-stm32h7.c
@@ -1201,9 +1201,8 @@ static void __init stm32h7_rcc_init(struct device_node *np)
 	const char *hse_clk, *lse_clk, *i2s_clk;
 	struct regmap *pdrm;
 
-	clk_data = kzalloc(sizeof(*clk_data) +
-			sizeof(*clk_data->hws) * STM32H7_MAX_CLKS,
-			GFP_KERNEL);
+	clk_data = kzalloc(struct_size(clk_data, hws, STM32H7_MAX_CLKS),
+			   GFP_KERNEL);
 	if (!clk_data)
 		return;
 
diff --git a/drivers/clk/clk-stm32mp1.c b/drivers/clk/clk-stm32mp1.c
index edd3cf451401..83e8cd81674f 100644
--- a/drivers/clk/clk-stm32mp1.c
+++ b/drivers/clk/clk-stm32mp1.c
@@ -2060,9 +2060,8 @@ static int stm32_rcc_init(struct device_node *np,
 
 	max_binding =  data->maxbinding;
 
-	clk_data = kzalloc(sizeof(*clk_data) +
-				  sizeof(*clk_data->hws) * max_binding,
-				  GFP_KERNEL);
+	clk_data = kzalloc(struct_size(clk_data, hws, max_binding),
+			   GFP_KERNEL);
 	if (!clk_data)
 		return -ENOMEM;
 
diff --git a/drivers/clk/samsung/clk-exynos-clkout.c b/drivers/clk/samsung/clk-exynos-clkout.c
index f29fb5824005..9c95390d2d77 100644
--- a/drivers/clk/samsung/clk-exynos-clkout.c
+++ b/drivers/clk/samsung/clk-exynos-clkout.c
@@ -61,8 +61,7 @@ static void __init exynos_clkout_init(struct device_node *node, u32 mux_mask)
 	int ret;
 	int i;
 
-	clkout = kzalloc(sizeof(*clkout) +
-			 sizeof(*clkout->data.hws) * EXYNOS_CLKOUT_NR_CLKS,
+	clkout = kzalloc(struct_size(clkout, data.hws, EXYNOS_CLKOUT_NR_CLKS),
 			 GFP_KERNEL);
 	if (!clkout)
 		return;
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index aff2c1594220..de2f8297a210 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -594,7 +594,7 @@ struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region,
 	if (!count)
 		return ERR_PTR(-EINVAL);
 
-	dev_dax = kzalloc(sizeof(*dev_dax) + sizeof(*res) * count, GFP_KERNEL);
+	dev_dax = kzalloc(struct_size(dev_dax, res, count), GFP_KERNEL);
 	if (!dev_dax)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/dma/edma.c b/drivers/dma/edma.c
index 85ea92fcea54..9bc722ca8329 100644
--- a/drivers/dma/edma.c
+++ b/drivers/dma/edma.c
@@ -1074,8 +1074,7 @@ static struct dma_async_tx_descriptor *edma_prep_slave_sg(
 		return NULL;
 	}
 
-	edesc = kzalloc(sizeof(*edesc) + sg_len * sizeof(edesc->pset[0]),
-			GFP_ATOMIC);
+	edesc = kzalloc(struct_size(edesc, pset, sg_len), GFP_ATOMIC);
 	if (!edesc)
 		return NULL;
 
@@ -1192,8 +1191,7 @@ static struct dma_async_tx_descriptor *edma_prep_dma_memcpy(
 			nslots = 2;
 	}
 
-	edesc = kzalloc(sizeof(*edesc) + nslots * sizeof(edesc->pset[0]),
-			GFP_ATOMIC);
+	edesc = kzalloc(struct_size(edesc, pset, nslots), GFP_ATOMIC);
 	if (!edesc)
 		return NULL;
 
@@ -1315,8 +1313,7 @@ static struct dma_async_tx_descriptor *edma_prep_dma_cyclic(
 		}
 	}
 
-	edesc = kzalloc(sizeof(*edesc) + nslots * sizeof(edesc->pset[0]),
-			GFP_ATOMIC);
+	edesc = kzalloc(struct_size(edesc, pset, nslots), GFP_ATOMIC);
 	if (!edesc)
 		return NULL;
 
diff --git a/drivers/dma/moxart-dma.c b/drivers/dma/moxart-dma.c
index e1a5c2242f6f..e04499c1f27f 100644
--- a/drivers/dma/moxart-dma.c
+++ b/drivers/dma/moxart-dma.c
@@ -309,7 +309,7 @@ static struct dma_async_tx_descriptor *moxart_prep_slave_sg(
 		return NULL;
 	}
 
-	d = kzalloc(sizeof(*d) + sg_len * sizeof(d->sg[0]), GFP_ATOMIC);
+	d = kzalloc(struct_size(d, sg, sg_len), GFP_ATOMIC);
 	if (!d)
 		return NULL;
 
diff --git a/drivers/dma/omap-dma.c b/drivers/dma/omap-dma.c
index d21c19822feb..9483000fcf79 100644
--- a/drivers/dma/omap-dma.c
+++ b/drivers/dma/omap-dma.c
@@ -917,7 +917,7 @@ static struct dma_async_tx_descriptor *omap_dma_prep_slave_sg(
 	}
 
 	/* Now allocate and setup the descriptor. */
-	d = kzalloc(sizeof(*d) + sglen * sizeof(d->sg[0]), GFP_ATOMIC);
+	d = kzalloc(struct_size(d, sg, sglen), GFP_ATOMIC);
 	if (!d)
 		return NULL;
 
diff --git a/drivers/dma/sa11x0-dma.c b/drivers/dma/sa11x0-dma.c
index c7a89c22890e..b31d07c7d93c 100644
--- a/drivers/dma/sa11x0-dma.c
+++ b/drivers/dma/sa11x0-dma.c
@@ -557,7 +557,7 @@ static struct dma_async_tx_descriptor *sa11x0_dma_prep_slave_sg(
 		}
 	}
 
-	txd = kzalloc(sizeof(*txd) + j * sizeof(txd->sg[0]), GFP_ATOMIC);
+	txd = kzalloc(struct_size(txd, sg, j), GFP_ATOMIC);
 	if (!txd) {
 		dev_dbg(chan->device->dev, "vchan %p: kzalloc failed\n", &c->vc);
 		return NULL;
@@ -627,7 +627,7 @@ static struct dma_async_tx_descriptor *sa11x0_dma_prep_dma_cyclic(
 	if (sglen == 0)
 		return NULL;
 
-	txd = kzalloc(sizeof(*txd) + sglen * sizeof(txd->sg[0]), GFP_ATOMIC);
+	txd = kzalloc(struct_size(txd, sg, sglen), GFP_ATOMIC);
 	if (!txd) {
 		dev_dbg(chan->device->dev, "vchan %p: kzalloc failed\n", &c->vc);
 		return NULL;
diff --git a/drivers/dma/sh/usb-dmac.c b/drivers/dma/sh/usb-dmac.c
index 31a145154e9f..1bb1a8e09025 100644
--- a/drivers/dma/sh/usb-dmac.c
+++ b/drivers/dma/sh/usb-dmac.c
@@ -269,7 +269,7 @@ static int usb_dmac_desc_alloc(struct usb_dmac_chan *chan, unsigned int sg_len,
 	struct usb_dmac_desc *desc;
 	unsigned long flags;
 
-	desc = kzalloc(sizeof(*desc) + sg_len * sizeof(desc->sg[0]), gfp);
+	desc = kzalloc(struct_size(desc, sg, sg_len), gfp);
 	if (!desc)
 		return -ENOMEM;
 
diff --git a/drivers/firewire/core-topology.c b/drivers/firewire/core-topology.c
index 939d259ddf19..7db234d3fbdd 100644
--- a/drivers/firewire/core-topology.c
+++ b/drivers/firewire/core-topology.c
@@ -112,8 +112,7 @@ static struct fw_node *fw_node_create(u32 sid, int port_count, int color)
 {
 	struct fw_node *node;
 
-	node = kzalloc(sizeof(*node) + port_count * sizeof(node->ports[0]),
-		       GFP_ATOMIC);
+	node = kzalloc(struct_size(node, ports, port_count), GFP_ATOMIC);
 	if (node == NULL)
 		return NULL;
 
diff --git a/drivers/gpio/gpiolib.c b/drivers/gpio/gpiolib.c
index 43aeb07343ec..c4518fa9070f 100644
--- a/drivers/gpio/gpiolib.c
+++ b/drivers/gpio/gpiolib.c
@@ -4022,8 +4022,7 @@ struct gpio_descs *__must_check gpiod_get_array(struct device *dev,
 	if (count < 0)
 		return ERR_PTR(count);
 
-	descs = kzalloc(sizeof(*descs) + sizeof(descs->desc[0]) * count,
-			GFP_KERNEL);
+	descs = kzalloc(struct_size(descs, desc, count), GFP_KERNEL);
 	if (!descs)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/pm/base.c b/drivers/gpu/drm/nouveau/nvkm/engine/pm/base.c
index 53859b6254d6..b2785bee418e 100644
--- a/drivers/gpu/drm/nouveau/nvkm/engine/pm/base.c
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/pm/base.c
@@ -779,8 +779,8 @@ nvkm_perfdom_new(struct nvkm_pm *pm, const char *name, u32 mask,
 
 		sdom = spec;
 		while (sdom->signal_nr) {
-			dom = kzalloc(sizeof(*dom) + sdom->signal_nr *
-				      sizeof(*dom->signal), GFP_KERNEL);
+			dom = kzalloc(struct_size(dom, signal, sdom->signal_nr),
+				      GFP_KERNEL);
 			if (!dom)
 				return -ENOMEM;
 
diff --git a/drivers/hwspinlock/omap_hwspinlock.c b/drivers/hwspinlock/omap_hwspinlock.c
index ad2f8cac8487..d897e5251c36 100644
--- a/drivers/hwspinlock/omap_hwspinlock.c
+++ b/drivers/hwspinlock/omap_hwspinlock.c
@@ -132,7 +132,7 @@ static int omap_hwspinlock_probe(struct platform_device *pdev)
 
 	num_locks = i * 32; /* actual number of locks in this device */
 
-	bank = kzalloc(sizeof(*bank) + num_locks * sizeof(*hwlock), GFP_KERNEL);
+	bank = kzalloc(struct_size(bank, lock, num_locks), GFP_KERNEL);
 	if (!bank) {
 		ret = -ENOMEM;
 		goto iounmap_base;
diff --git a/drivers/hwspinlock/u8500_hsem.c b/drivers/hwspinlock/u8500_hsem.c
index e93eabbd660f..0128d8fb905e 100644
--- a/drivers/hwspinlock/u8500_hsem.c
+++ b/drivers/hwspinlock/u8500_hsem.c
@@ -119,7 +119,7 @@ static int u8500_hsem_probe(struct platform_device *pdev)
 	/* clear all interrupts */
 	writel(0xFFFF, io_base + HSEM_ICRALL);
 
-	bank = kzalloc(sizeof(*bank) + num_locks * sizeof(*hwlock), GFP_KERNEL);
+	bank = kzalloc(struct_size(bank, lock, num_locks), GFP_KERNEL);
 	if (!bank) {
 		ret = -ENOMEM;
 		goto iounmap_base;
diff --git a/drivers/infiniband/core/cache.c b/drivers/infiniband/core/cache.c
index fb2d347f760f..e804c8586820 100644
--- a/drivers/infiniband/core/cache.c
+++ b/drivers/infiniband/core/cache.c
@@ -1157,8 +1157,8 @@ static void ib_cache_update(struct ib_device *device,
 			goto err;
 	}
 
-	pkey_cache = kmalloc(sizeof *pkey_cache + tprops->pkey_tbl_len *
-			     sizeof *pkey_cache->table, GFP_KERNEL);
+	pkey_cache = kmalloc(struct_size(pkey_cache, table, tprops->pkey_tbl_len),
+			     GFP_KERNEL);
 	if (!pkey_cache)
 		goto err;
 
diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index a92e1a5c202b..36a4d90a7b47 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -4298,8 +4298,8 @@ static void cm_add_one(struct ib_device *ib_device)
 	int count = 0;
 	u8 i;
 
-	cm_dev = kzalloc(sizeof(*cm_dev) + sizeof(*port) *
-			 ib_device->phys_port_cnt, GFP_KERNEL);
+	cm_dev = kzalloc(struct_size(cm_dev, port, ib_device->phys_port_cnt),
+			 GFP_KERNEL);
 	if (!cm_dev)
 		return;
 
diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
index 4eb72ff539fc..6c48f4193dda 100644
--- a/drivers/infiniband/core/multicast.c
+++ b/drivers/infiniband/core/multicast.c
@@ -813,7 +813,7 @@ static void mcast_add_one(struct ib_device *device)
 	int i;
 	int count = 0;
 
-	dev = kmalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
+	dev = kmalloc(struct_size(dev, port, device->phys_port_cnt),
 		      GFP_KERNEL);
 	if (!dev)
 		return;
diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
index 21a887c9523b..e3662a8ee465 100644
--- a/drivers/infiniband/core/uverbs_cmd.c
+++ b/drivers/infiniband/core/uverbs_cmd.c
@@ -2756,8 +2756,8 @@ static struct ib_uflow_resources *flow_resources_alloc(size_t num_specs)
 	struct ib_uflow_resources *resources;
 
 	resources =
-		kmalloc(sizeof(*resources) +
-			num_specs * sizeof(*resources->collection), GFP_KERNEL);
+		kmalloc(struct_size(resources, collection, num_specs),
+			GFP_KERNEL);
 
 	if (!resources)
 		return NULL;
diff --git a/drivers/infiniband/core/uverbs_ioctl_merge.c b/drivers/infiniband/core/uverbs_ioctl_merge.c
index 0f88a1919d51..3172043b5b33 100644
--- a/drivers/infiniband/core/uverbs_ioctl_merge.c
+++ b/drivers/infiniband/core/uverbs_ioctl_merge.c
@@ -297,8 +297,7 @@ static struct uverbs_method_spec *build_method_with_attrs(const struct uverbs_me
 	if (max_attr_buckets >= 0)
 		num_attr_buckets = max_attr_buckets + 1;
 
-	method = kzalloc(sizeof(*method) +
-			 num_attr_buckets * sizeof(*method->attr_buckets),
+	method = kzalloc(struct_size(method, attr_buckets, num_attr_buckets),
 			 GFP_KERNEL);
 	if (!method)
 		return ERR_PTR(-ENOMEM);
@@ -446,9 +445,8 @@ static struct uverbs_object_spec *build_object_with_methods(const struct uverbs_
 	if (max_method_buckets >= 0)
 		num_method_buckets = max_method_buckets + 1;
 
-	object = kzalloc(sizeof(*object) +
-			 num_method_buckets *
-			 sizeof(*object->method_buckets), GFP_KERNEL);
+	object = kzalloc(struct_size(object, method_buckets, num_method_buckets),
+			 GFP_KERNEL);
 	if (!object)
 		return ERR_PTR(-ENOMEM);
 
@@ -469,8 +467,7 @@ static struct uverbs_object_spec *build_object_with_methods(const struct uverbs_
 		if (methods_max_bucket < 0)
 			continue;
 
-		hash = kzalloc(sizeof(*hash) +
-			       sizeof(*hash->methods) * (methods_max_bucket + 1),
+		hash = kzalloc(struct_size(hash, methods, (methods_max_bucket + 1)),
 			       GFP_KERNEL);
 		if (!hash) {
 			res = -ENOMEM;
@@ -579,8 +576,7 @@ struct uverbs_root_spec *uverbs_alloc_spec_tree(unsigned int num_trees,
 	if (max_object_buckets >= 0)
 		num_objects_buckets = max_object_buckets + 1;
 
-	root_spec = kzalloc(sizeof(*root_spec) +
-			    num_objects_buckets * sizeof(*root_spec->object_buckets),
+	root_spec = kzalloc(struct_size(root_spec, object_buckets, num_objects_buckets),
 			    GFP_KERNEL);
 	if (!root_spec)
 		return ERR_PTR(-ENOMEM);
@@ -603,8 +599,7 @@ struct uverbs_root_spec *uverbs_alloc_spec_tree(unsigned int num_trees,
 		if (objects_max_bucket < 0)
 			continue;
 
-		hash = kzalloc(sizeof(*hash) +
-			       sizeof(*hash->objects) * (objects_max_bucket + 1),
+		hash = kzalloc(struct_size(hash, objects, (objects_max_bucket + 1)),
 			       GFP_KERNEL);
 		if (!hash) {
 			res = -ENOMEM;
diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index 2fe503e86c1d..7a31be3c3e73 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -367,7 +367,7 @@ struct mthca_icm_table *mthca_alloc_icm_table(struct mthca_dev *dev,
 	obj_per_chunk = MTHCA_TABLE_CHUNK_SIZE / obj_size;
 	num_icm = DIV_ROUND_UP(nobj, obj_per_chunk);
 
-	table = kmalloc(sizeof *table + num_icm * sizeof *table->icm, GFP_KERNEL);
+	table = kmalloc(struct_size(table, icm, num_icm), GFP_KERNEL);
 	if (!table)
 		return NULL;
 
@@ -529,7 +529,7 @@ struct mthca_user_db_table *mthca_init_user_db_tab(struct mthca_dev *dev)
 		return NULL;
 
 	npages = dev->uar_table.uarc_size / MTHCA_ICM_PAGE_SIZE;
-	db_tab = kmalloc(sizeof *db_tab + npages * sizeof *db_tab->page, GFP_KERNEL);
+	db_tab = kmalloc(struct_size(db_tab, page, npages), GFP_KERNEL);
 	if (!db_tab)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/infiniband/sw/rdmavt/mr.c b/drivers/infiniband/sw/rdmavt/mr.c
index cc429b567d0a..49c9541050d4 100644
--- a/drivers/infiniband/sw/rdmavt/mr.c
+++ b/drivers/infiniband/sw/rdmavt/mr.c
@@ -283,7 +283,7 @@ static struct rvt_mr *__rvt_alloc_mr(int count, struct ib_pd *pd)
 
 	/* Allocate struct plus pointers to first level page tables. */
 	m = (count + RVT_SEGSZ - 1) / RVT_SEGSZ;
-	mr = kzalloc(sizeof(*mr) + m * sizeof(mr->mr.map[0]), GFP_KERNEL);
+	mr = kzalloc(struct_size(mr, mr.map, m), GFP_KERNEL);
 	if (!mr)
 		goto bail;
 
@@ -730,7 +730,7 @@ struct ib_fmr *rvt_alloc_fmr(struct ib_pd *pd, int mr_access_flags,
 
 	/* Allocate struct plus pointers to first level page tables. */
 	m = (fmr_attr->max_pages + RVT_SEGSZ - 1) / RVT_SEGSZ;
-	fmr = kzalloc(sizeof(*fmr) + m * sizeof(fmr->mr.map[0]), GFP_KERNEL);
+	fmr = kzalloc(struct_size(fmr, mr.map, m), GFP_KERNEL);
 	if (!fmr)
 		goto bail;
 
diff --git a/drivers/input/input-leds.c b/drivers/input/input-leds.c
index 5f04b2d94635..99cc784e1264 100644
--- a/drivers/input/input-leds.c
+++ b/drivers/input/input-leds.c
@@ -98,8 +98,7 @@ static int input_leds_connect(struct input_handler *handler,
 	if (!num_leds)
 		return -ENXIO;
 
-	leds = kzalloc(sizeof(*leds) + num_leds * sizeof(*leds->leds),
-		       GFP_KERNEL);
+	leds = kzalloc(struct_size(leds, leds, num_leds), GFP_KERNEL);
 	if (!leds)
 		return -ENOMEM;
 
diff --git a/drivers/input/input-mt.c b/drivers/input/input-mt.c
index a1bbec9cda8d..cf30523c6ef6 100644
--- a/drivers/input/input-mt.c
+++ b/drivers/input/input-mt.c
@@ -49,7 +49,7 @@ int input_mt_init_slots(struct input_dev *dev, unsigned int num_slots,
 	if (mt)
 		return mt->num_slots != num_slots ? -EINVAL : 0;
 
-	mt = kzalloc(sizeof(*mt) + num_slots * sizeof(*mt->slots), GFP_KERNEL);
+	mt = kzalloc(struct_size(mt, slots, num_slots), GFP_KERNEL);
 	if (!mt)
 		goto err_mem;
 
diff --git a/drivers/md/dm-raid.c b/drivers/md/dm-raid.c
index 6f823f44b4aa..ab13fcec3fca 100644
--- a/drivers/md/dm-raid.c
+++ b/drivers/md/dm-raid.c
@@ -756,7 +756,7 @@ static struct raid_set *raid_set_alloc(struct dm_target *ti, struct raid_type *r
 		return ERR_PTR(-EINVAL);
 	}
 
-	rs = kzalloc(sizeof(*rs) + raid_devs * sizeof(rs->dev[0]), GFP_KERNEL);
+	rs = kzalloc(struct_size(rs, dev, raid_devs), GFP_KERNEL);
 	if (!rs) {
 		ti->error = "Cannot allocate raid context";
 		return ERR_PTR(-ENOMEM);
diff --git a/drivers/misc/vexpress-syscfg.c b/drivers/misc/vexpress-syscfg.c
index 9eea30f54fd6..80a6f199077c 100644
--- a/drivers/misc/vexpress-syscfg.c
+++ b/drivers/misc/vexpress-syscfg.c
@@ -182,8 +182,7 @@ static struct regmap *vexpress_syscfg_regmap_init(struct device *dev,
 		val = energy_quirk;
 	}
 
-	func = kzalloc(sizeof(*func) + sizeof(*func->template) * num,
-			GFP_KERNEL);
+	func = kzalloc(struct_size(func, template, num), GFP_KERNEL);
 	if (!func)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
index 7ecadb501743..413080a312a7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
@@ -494,7 +494,7 @@ static int add_res_tree(struct mlx5_core_dev *dev, enum dbg_rsc_type type,
 	int err;
 	int i;
 
-	d = kzalloc(sizeof(*d) + nfile * sizeof(d->fields[0]), GFP_KERNEL);
+	d = kzalloc(struct_size(d, fields, nfile), GFP_KERNEL);
 	if (!d)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index c39c1692e674..56e275199256 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1191,8 +1191,7 @@ static struct mlx5_flow_handle *alloc_handle(int num_rules)
 {
 	struct mlx5_flow_handle *handle;
 
-	handle = kzalloc(sizeof(*handle) + sizeof(handle->rule[0]) *
-			  num_rules, GFP_KERNEL);
+	handle = kzalloc(struct_size(handle, rule, num_rules), GFP_KERNEL);
 	if (!handle)
 		return NULL;
 
diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c b/drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c
index 90f8c89ea59c..ea65d6523ea4 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c
@@ -2987,9 +2987,7 @@ static int iwl_mvm_mac_set_key(struct ieee80211_hw *hw,
 
 			mvmsta = iwl_mvm_sta_from_mac80211(sta);
 			WARN_ON(rcu_access_pointer(mvmsta->ptk_pn[keyidx]));
-			ptk_pn = kzalloc(sizeof(*ptk_pn) +
-					 mvm->trans->num_rx_queues *
-						sizeof(ptk_pn->q[0]),
+			ptk_pn = kzalloc(struct_size(ptk_pn, q, mvm->trans->num_rx_queues),
 					 GFP_KERNEL);
 			if (!ptk_pn) {
 				ret = -ENOMEM;
diff --git a/drivers/net/wireless/mediatek/mt76/agg-rx.c b/drivers/net/wireless/mediatek/mt76/agg-rx.c
index fcb208d1f276..89c7d8c7eb48 100644
--- a/drivers/net/wireless/mediatek/mt76/agg-rx.c
+++ b/drivers/net/wireless/mediatek/mt76/agg-rx.c
@@ -236,8 +236,7 @@ int mt76_rx_aggr_start(struct mt76_dev *dev, struct mt76_wcid *wcid, u8 tidno,
 
 	mt76_rx_aggr_stop(dev, wcid, tidno);
 
-	tid = kzalloc(sizeof(*tid) + size * sizeof(tid->reorder_buf[0]),
-		      GFP_KERNEL);
+	tid = kzalloc(struct_size(tid, reorder_buf, size), GFP_KERNEL);
 	if (!tid)
 		return -ENOMEM;
 
diff --git a/drivers/reset/core.c b/drivers/reset/core.c
index 6488292e129c..225e34c56b94 100644
--- a/drivers/reset/core.c
+++ b/drivers/reset/core.c
@@ -730,8 +730,7 @@ of_reset_control_array_get(struct device_node *np, bool shared, bool optional)
 	if (num < 0)
 		return optional ? NULL : ERR_PTR(num);
 
-	resets = kzalloc(sizeof(*resets) + sizeof(resets->rstc[0]) * num,
-			 GFP_KERNEL);
+	resets = kzalloc(struct_size(resets, rstc, num), GFP_KERNEL);
 	if (!resets)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/s390/cio/ccwgroup.c b/drivers/s390/cio/ccwgroup.c
index 5535312602af..838752efc1c0 100644
--- a/drivers/s390/cio/ccwgroup.c
+++ b/drivers/s390/cio/ccwgroup.c
@@ -326,8 +326,7 @@ int ccwgroup_create_dev(struct device *parent, struct ccwgroup_driver *gdrv,
 	if (num_devices < 1)
 		return -EINVAL;
 
-	gdev = kzalloc(sizeof(*gdev) + num_devices * sizeof(gdev->cdev[0]),
-		       GFP_KERNEL);
+	gdev = kzalloc(struct_size(gdev, cdev, num_devices), GFP_KERNEL);
 	if (!gdev)
 		return -ENOMEM;
 
diff --git a/drivers/staging/greybus/module.c b/drivers/staging/greybus/module.c
index b785382192de..894d02e8d8b7 100644
--- a/drivers/staging/greybus/module.c
+++ b/drivers/staging/greybus/module.c
@@ -94,8 +94,8 @@ struct gb_module *gb_module_create(struct gb_host_device *hd, u8 module_id,
 	struct gb_module *module;
 	int i;
 
-	module = kzalloc(sizeof(*module) + num_interfaces * sizeof(intf),
-				GFP_KERNEL);
+	module = kzalloc(struct_size(module, interfaces, num_interfaces),
+			 GFP_KERNEL);
 	if (!module)
 		return NULL;
 
diff --git a/drivers/usb/gadget/function/f_midi.c b/drivers/usb/gadget/function/f_midi.c
index e8f35db42394..3fcc8aaaa446 100644
--- a/drivers/usb/gadget/function/f_midi.c
+++ b/drivers/usb/gadget/function/f_midi.c
@@ -1287,9 +1287,8 @@ static struct usb_function *f_midi_alloc(struct usb_function_instance *fi)
 	}
 
 	/* allocate and initialize one new instance */
-	midi = kzalloc(
-		sizeof(*midi) + opts->in_ports * sizeof(*midi->in_ports_array),
-		GFP_KERNEL);
+	midi = kzalloc(struct_size(midi, in_ports_array, opts->in_ports),
+		       GFP_KERNEL);
 	if (!midi) {
 		status = -ENOMEM;
 		goto setup_fail;
diff --git a/drivers/zorro/zorro.c b/drivers/zorro/zorro.c
index 47728477297e..875e569bf123 100644
--- a/drivers/zorro/zorro.c
+++ b/drivers/zorro/zorro.c
@@ -136,8 +136,7 @@ static int __init amiga_zorro_probe(struct platform_device *pdev)
 	int error;
 
 	/* Initialize the Zorro bus */
-	bus = kzalloc(sizeof(*bus) +
-		      zorro_num_autocon * sizeof(bus->devices[0]),
+	bus = kzalloc(struct_size(bus, devices, zorro_num_autocon),
 		      GFP_KERNEL);
 	if (!bus)
 		return -ENOMEM;
diff --git a/fs/afs/addr_list.c b/fs/afs/addr_list.c
index 3bedfed608a2..4131fad044c9 100644
--- a/fs/afs/addr_list.c
+++ b/fs/afs/addr_list.c
@@ -43,8 +43,7 @@ struct afs_addr_list *afs_alloc_addrlist(unsigned int nr,
 
 	_enter("%u,%u,%u", nr, service, port);
 
-	alist = kzalloc(sizeof(*alist) + sizeof(alist->addrs[0]) * nr,
-			GFP_KERNEL);
+	alist = kzalloc(struct_size(alist, addrs, nr), GFP_KERNEL);
 	if (!alist)
 		return NULL;
 
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index a662bfcbea0e..2238661bf878 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -4775,8 +4775,8 @@ static struct cgroup *cgroup_create(struct cgroup *parent)
 	int ret;
 
 	/* allocate the cgroup and its ID, 0 is reserved for the root */
-	cgrp = kzalloc(sizeof(*cgrp) +
-		       sizeof(cgrp->ancestor_ids[0]) * (level + 1), GFP_KERNEL);
+	cgrp = kzalloc(struct_size(cgrp, ancestor_ids, (level + 1)),
+		       GFP_KERNEL);
 	if (!cgrp)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/kernel/module.c b/kernel/module.c
index ce8066b88178..307272679a55 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -1604,8 +1604,7 @@ static void add_notes_attrs(struct module *mod, const struct load_info *info)
 	if (notes == 0)
 		return;
 
-	notes_attrs = kzalloc(sizeof(*notes_attrs)
-			      + notes * sizeof(notes_attrs->attrs[0]),
+	notes_attrs = kzalloc(struct_size(notes_attrs, attrs, notes),
 			      GFP_KERNEL);
 	if (notes_attrs == NULL)
 		return;
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index ca7959be8aaa..c976e2bfbac5 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -3700,8 +3700,7 @@ apply_wqattrs_prepare(struct workqueue_struct *wq,
 
 	lockdep_assert_held(&wq_pool_mutex);
 
-	ctx = kzalloc(sizeof(*ctx) + nr_node_ids * sizeof(ctx->pwq_tbl[0]),
-		      GFP_KERNEL);
+	ctx = kzalloc(struct_size(ctx, pwq_tbl, nr_node_ids), GFP_KERNEL);
 
 	new_attrs = alloc_workqueue_attrs(GFP_KERNEL);
 	tmp_attrs = alloc_workqueue_attrs(GFP_KERNEL);
diff --git a/net/ceph/mon_client.c b/net/ceph/mon_client.c
index 21ac6e3b96bb..d7a7a2330ef7 100644
--- a/net/ceph/mon_client.c
+++ b/net/ceph/mon_client.c
@@ -62,7 +62,7 @@ struct ceph_monmap *ceph_monmap_decode(void *p, void *end)
 
 	if (num_mon > CEPH_MAX_MON)
 		goto bad;
-	m = kmalloc(sizeof(*m) + sizeof(m->mon_inst[0])*num_mon, GFP_NOFS);
+	m = kmalloc(struct_size(m, mon_inst, num_mon), GFP_NOFS);
 	if (m == NULL)
 		return ERR_PTR(-ENOMEM);
 	m->fsid = fsid;
@@ -1000,8 +1000,7 @@ static int build_initial_monmap(struct ceph_mon_client *monc)
 	int i;
 
 	/* build initial monmap */
-	monc->monmap = kzalloc(sizeof(*monc->monmap) +
-			       num_mon*sizeof(monc->monmap->mon_inst[0]),
+	monc->monmap = kzalloc(struct_size(monc->monmap, mon_inst, num_mon),
 			       GFP_KERNEL);
 	if (!monc->monmap)
 		return -ENOMEM;
diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index ea2a6c9fb7ce..4959260e19fe 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -565,8 +565,7 @@ struct ceph_osd_request *ceph_osdc_alloc_request(struct ceph_osd_client *osdc,
 		req = kmem_cache_alloc(ceph_osd_request_cache, gfp_flags);
 	} else {
 		BUG_ON(num_ops > CEPH_OSD_MAX_OPS);
-		req = kmalloc(sizeof(*req) + num_ops * sizeof(req->r_ops[0]),
-			      gfp_flags);
+		req = kmalloc(struct_size(req, r_ops, num_ops), gfp_flags);
 	}
 	if (unlikely(!req))
 		return NULL;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 9bbfc17ce3ec..07085c22b19c 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -184,8 +184,7 @@ recent_entry_init(struct recent_table *t, const union nf_inet_addr *addr,
 	}
 
 	nstamps_max += 1;
-	e = kmalloc(sizeof(*e) + sizeof(e->stamps[0]) * nstamps_max,
-		    GFP_ATOMIC);
+	e = kmalloc(struct_size(e, stamps, nstamps_max), GFP_ATOMIC);
 	if (e == NULL)
 		return NULL;
 	memcpy(&e->addr, addr, sizeof(e->addr));
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index e2f5a3ee41a7..40c7eb941bc9 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -73,8 +73,8 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 		 * variables.  There are arrays that we encode directly
 		 * into parameters to make the rest of the operations easier.
 		 */
-		auth_hmacs = kzalloc(sizeof(*auth_hmacs) +
-				     sizeof(__u16) * SCTP_AUTH_NUM_HMACS, gfp);
+		auth_hmacs = kzalloc(struct_size(auth_hmacs, hmac_ids,
+						 SCTP_AUTH_NUM_HMACS), gfp);
 		if (!auth_hmacs)
 			goto nomem;
 
diff --git a/sound/core/vmaster.c b/sound/core/vmaster.c
index 9e96186742d0..40447395f0de 100644
--- a/sound/core/vmaster.c
+++ b/sound/core/vmaster.c
@@ -259,8 +259,8 @@ int _snd_ctl_add_slave(struct snd_kcontrol *master, struct snd_kcontrol *slave,
 	struct link_master *master_link = snd_kcontrol_chip(master);
 	struct link_slave *srec;
 
-	srec = kzalloc(sizeof(*srec) +
-		       slave->count * sizeof(*slave->vd), GFP_KERNEL);
+	srec = kzalloc(struct_size(srec, slave.vd, slave->count),
+		       GFP_KERNEL);
 	if (!srec)
 		return -ENOMEM;
 	srec->kctl = slave;
diff --git a/sound/soc/soc-dapm.c b/sound/soc/soc-dapm.c
index 2d9709104ec5..fadf9896bf2c 100644
--- a/sound/soc/soc-dapm.c
+++ b/sound/soc/soc-dapm.c
@@ -1088,7 +1088,7 @@ static int dapm_widget_list_create(struct snd_soc_dapm_widget_list **list,
 	list_for_each(it, widgets)
 		size++;
 
-	*list = kzalloc(sizeof(**list) + size * sizeof(*w), GFP_KERNEL);
+	*list = kzalloc(struct_size(*list, widgets, size), GFP_KERNEL);
 	if (*list == NULL)
 		return -ENOMEM;
 
-- 
2.17.0
