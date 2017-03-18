Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2D046B0396
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:55:42 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j30so80173276qta.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:42 -0700 (PDT)
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com. [209.85.220.180])
        by mx.google.com with ESMTPS id a49si7682973qta.233.2017.03.17.17.55.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:55:40 -0700 (PDT)
Received: by mail-qk0-f180.google.com with SMTP id v127so77345241qkb.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:40 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 12/21] staging: android: ion: Remove old platform support
Date: Fri, 17 Mar 2017 17:54:44 -0700
Message-Id: <1489798493-16600-13-git-send-email-labbott@redhat.com>
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>


Device specific platform support has been haphazard for Ion. There have
been several independent attempts and there are still objections to
what bindings exist right now. Just remove everything for a fresh start.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/Kconfig                |  42 ---
 drivers/staging/android/ion/Makefile               |   7 -
 drivers/staging/android/ion/hisilicon/Kconfig      |   5 -
 drivers/staging/android/ion/hisilicon/Makefile     |   1 -
 drivers/staging/android/ion/hisilicon/hi6220_ion.c | 113 --------
 drivers/staging/android/ion/ion_dummy_driver.c     | 156 -----------
 drivers/staging/android/ion/ion_of.c               | 184 -------------
 drivers/staging/android/ion/ion_of.h               |  37 ---
 drivers/staging/android/ion/ion_test.c             | 305 ---------------------
 drivers/staging/android/ion/tegra/Makefile         |   1 -
 drivers/staging/android/ion/tegra/tegra_ion.c      |  80 ------
 drivers/staging/android/uapi/ion_test.h            |  69 -----
 12 files changed, 1000 deletions(-)
 delete mode 100644 drivers/staging/android/ion/hisilicon/Kconfig
 delete mode 100644 drivers/staging/android/ion/hisilicon/Makefile
 delete mode 100644 drivers/staging/android/ion/hisilicon/hi6220_ion.c
 delete mode 100644 drivers/staging/android/ion/ion_dummy_driver.c
 delete mode 100644 drivers/staging/android/ion/ion_of.c
 delete mode 100644 drivers/staging/android/ion/ion_of.h
 delete mode 100644 drivers/staging/android/ion/ion_test.c
 delete mode 100644 drivers/staging/android/ion/tegra/Makefile
 delete mode 100644 drivers/staging/android/ion/tegra/tegra_ion.c
 delete mode 100644 drivers/staging/android/uapi/ion_test.h

diff --git a/drivers/staging/android/ion/Kconfig b/drivers/staging/android/ion/Kconfig
index c8fb413..206c4de 100644
--- a/drivers/staging/android/ion/Kconfig
+++ b/drivers/staging/android/ion/Kconfig
@@ -10,45 +10,3 @@ menuconfig ION
 	  If you're not using Android its probably safe to
 	  say N here.
 
-config ION_TEST
-	tristate "Ion Test Device"
-	depends on ION
-	help
-	  Choose this option to create a device that can be used to test the
-	  kernel and device side ION functions.
-
-config ION_DUMMY
-	bool "Dummy Ion driver"
-	depends on ION
-	help
-	  Provides a dummy ION driver that registers the
-	  /dev/ion device and some basic heaps. This can
-	  be used for testing the ION infrastructure if
-	  one doesn't have access to hardware drivers that
-	  use ION.
-
-config ION_TEGRA
-	tristate "Ion for Tegra"
-	depends on ARCH_TEGRA && ION
-	help
-	  Choose this option if you wish to use ion on an nVidia Tegra.
-
-config ION_HISI
-	tristate "Ion for Hisilicon"
-	depends on ARCH_HISI && ION
-	select ION_OF
-	help
-	  Choose this option if you wish to use ion on Hisilicon Platform.
-
-source "drivers/staging/android/ion/hisilicon/Kconfig"
-
-config ION_OF
-	bool "Devicetree support for Ion"
-	depends on ION && OF_ADDRESS
-	help
-	  Provides base support for defining Ion heaps in devicetree
-	  and setting them up. Also includes functions for platforms
-	  to parse the devicetree and expand for their own custom
-	  extensions
-
-	  If using Ion and devicetree, you should say Y here
diff --git a/drivers/staging/android/ion/Makefile b/drivers/staging/android/ion/Makefile
index 5d630a0..26672a0 100644
--- a/drivers/staging/android/ion/Makefile
+++ b/drivers/staging/android/ion/Makefile
@@ -1,13 +1,6 @@
 obj-$(CONFIG_ION) +=	ion.o ion-ioctl.o ion_heap.o \
 			ion_page_pool.o ion_system_heap.o \
 			ion_carveout_heap.o ion_chunk_heap.o ion_cma_heap.o
-obj-$(CONFIG_ION_TEST) += ion_test.o
 ifdef CONFIG_COMPAT
 obj-$(CONFIG_ION) += compat_ion.o
 endif
-
-obj-$(CONFIG_ION_DUMMY) += ion_dummy_driver.o
-obj-$(CONFIG_ION_TEGRA) += tegra/
-obj-$(CONFIG_ION_HISI) += hisilicon/
-obj-$(CONFIG_ION_OF) += ion_of.o
-
diff --git a/drivers/staging/android/ion/hisilicon/Kconfig b/drivers/staging/android/ion/hisilicon/Kconfig
deleted file mode 100644
index 2b4bd07..0000000
--- a/drivers/staging/android/ion/hisilicon/Kconfig
+++ /dev/null
@@ -1,5 +0,0 @@
-config HI6220_ION
-        bool "Hi6220 ION Driver"
-        depends on ARCH_HISI && ION
-        help
-          Build the Hisilicon Hi6220 ion driver.
diff --git a/drivers/staging/android/ion/hisilicon/Makefile b/drivers/staging/android/ion/hisilicon/Makefile
deleted file mode 100644
index 2a89414..0000000
--- a/drivers/staging/android/ion/hisilicon/Makefile
+++ /dev/null
@@ -1 +0,0 @@
-obj-$(CONFIG_HI6220_ION) += hi6220_ion.o
diff --git a/drivers/staging/android/ion/hisilicon/hi6220_ion.c b/drivers/staging/android/ion/hisilicon/hi6220_ion.c
deleted file mode 100644
index 0de7897..0000000
--- a/drivers/staging/android/ion/hisilicon/hi6220_ion.c
+++ /dev/null
@@ -1,113 +0,0 @@
-/*
- * Hisilicon Hi6220 ION Driver
- *
- * Copyright (c) 2015 Hisilicon Limited.
- *
- * Author: Chen Feng <puck.chen@hisilicon.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#define pr_fmt(fmt) "Ion: " fmt
-
-#include <linux/err.h>
-#include <linux/platform_device.h>
-#include <linux/slab.h>
-#include <linux/of.h>
-#include <linux/mm.h>
-#include "../ion_priv.h"
-#include "../ion.h"
-#include "../ion_of.h"
-
-struct hisi_ion_dev {
-	struct ion_heap	**heaps;
-	struct ion_device *idev;
-	struct ion_platform_data *data;
-};
-
-static struct ion_of_heap hisi_heaps[] = {
-	PLATFORM_HEAP("hisilicon,sys_user", 0,
-		      ION_HEAP_TYPE_SYSTEM, "sys_user"),
-	PLATFORM_HEAP("hisilicon,sys_contig", 1,
-		      ION_HEAP_TYPE_SYSTEM_CONTIG, "sys_contig"),
-	PLATFORM_HEAP("hisilicon,cma", ION_HEAP_TYPE_DMA, ION_HEAP_TYPE_DMA,
-		      "cma"),
-	{}
-};
-
-static int hi6220_ion_probe(struct platform_device *pdev)
-{
-	struct hisi_ion_dev *ipdev;
-	int i;
-
-	ipdev = devm_kzalloc(&pdev->dev, sizeof(*ipdev), GFP_KERNEL);
-	if (!ipdev)
-		return -ENOMEM;
-
-	platform_set_drvdata(pdev, ipdev);
-
-	ipdev->idev = ion_device_create(NULL);
-	if (IS_ERR(ipdev->idev))
-		return PTR_ERR(ipdev->idev);
-
-	ipdev->data = ion_parse_dt(pdev, hisi_heaps);
-	if (IS_ERR(ipdev->data))
-		return PTR_ERR(ipdev->data);
-
-	ipdev->heaps = devm_kzalloc(&pdev->dev,
-				sizeof(struct ion_heap) * ipdev->data->nr,
-				GFP_KERNEL);
-	if (!ipdev->heaps) {
-		ion_destroy_platform_data(ipdev->data);
-		return -ENOMEM;
-	}
-
-	for (i = 0; i < ipdev->data->nr; i++) {
-		ipdev->heaps[i] = ion_heap_create(&ipdev->data->heaps[i]);
-		if (!ipdev->heaps) {
-			ion_destroy_platform_data(ipdev->data);
-			return -ENOMEM;
-		}
-		ion_device_add_heap(ipdev->idev, ipdev->heaps[i]);
-	}
-	return 0;
-}
-
-static int hi6220_ion_remove(struct platform_device *pdev)
-{
-	struct hisi_ion_dev *ipdev;
-	int i;
-
-	ipdev = platform_get_drvdata(pdev);
-
-	for (i = 0; i < ipdev->data->nr; i++)
-		ion_heap_destroy(ipdev->heaps[i]);
-
-	ion_destroy_platform_data(ipdev->data);
-	ion_device_destroy(ipdev->idev);
-
-	return 0;
-}
-
-static const struct of_device_id hi6220_ion_match_table[] = {
-	{.compatible = "hisilicon,hi6220-ion"},
-	{},
-};
-
-static struct platform_driver hi6220_ion_driver = {
-	.probe = hi6220_ion_probe,
-	.remove = hi6220_ion_remove,
-	.driver = {
-		.name = "ion-hi6220",
-		.of_match_table = hi6220_ion_match_table,
-	},
-};
-
-static int __init hi6220_ion_init(void)
-{
-	return platform_driver_register(&hi6220_ion_driver);
-}
-
-subsys_initcall(hi6220_ion_init);
diff --git a/drivers/staging/android/ion/ion_dummy_driver.c b/drivers/staging/android/ion/ion_dummy_driver.c
deleted file mode 100644
index cf5c010..0000000
--- a/drivers/staging/android/ion/ion_dummy_driver.c
+++ /dev/null
@@ -1,156 +0,0 @@
-/*
- * drivers/gpu/ion/ion_dummy_driver.c
- *
- * Copyright (C) 2013 Linaro, Inc
- *
- * This software is licensed under the terms of the GNU General Public
- * License version 2, as published by the Free Software Foundation, and
- * may be copied, distributed, and modified under those terms.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- */
-
-#include <linux/err.h>
-#include <linux/platform_device.h>
-#include <linux/slab.h>
-#include <linux/init.h>
-#include <linux/bootmem.h>
-#include <linux/memblock.h>
-#include <linux/sizes.h>
-#include <linux/io.h>
-#include "ion.h"
-#include "ion_priv.h"
-
-static struct ion_device *idev;
-static struct ion_heap **heaps;
-
-static void *carveout_ptr;
-static void *chunk_ptr;
-
-static struct ion_platform_heap dummy_heaps[] = {
-		{
-			.id	= ION_HEAP_TYPE_SYSTEM,
-			.type	= ION_HEAP_TYPE_SYSTEM,
-			.name	= "system",
-		},
-		{
-			.id	= ION_HEAP_TYPE_SYSTEM_CONTIG,
-			.type	= ION_HEAP_TYPE_SYSTEM_CONTIG,
-			.name	= "system contig",
-		},
-		{
-			.id	= ION_HEAP_TYPE_CARVEOUT,
-			.type	= ION_HEAP_TYPE_CARVEOUT,
-			.name	= "carveout",
-			.size	= SZ_4M,
-		},
-		{
-			.id	= ION_HEAP_TYPE_CHUNK,
-			.type	= ION_HEAP_TYPE_CHUNK,
-			.name	= "chunk",
-			.size	= SZ_4M,
-			.align	= SZ_16K,
-			.priv	= (void *)(SZ_16K),
-		},
-};
-
-static const struct ion_platform_data dummy_ion_pdata = {
-	.nr = ARRAY_SIZE(dummy_heaps),
-	.heaps = dummy_heaps,
-};
-
-static int __init ion_dummy_init(void)
-{
-	int i, err;
-
-	idev = ion_device_create(NULL);
-	if (IS_ERR(idev))
-		return PTR_ERR(idev);
-	heaps = kcalloc(dummy_ion_pdata.nr, sizeof(struct ion_heap *),
-			GFP_KERNEL);
-	if (!heaps)
-		return -ENOMEM;
-
-
-	/* Allocate a dummy carveout heap */
-	carveout_ptr = alloc_pages_exact(
-				dummy_heaps[ION_HEAP_TYPE_CARVEOUT].size,
-				GFP_KERNEL);
-	if (carveout_ptr)
-		dummy_heaps[ION_HEAP_TYPE_CARVEOUT].base =
-						virt_to_phys(carveout_ptr);
-	else
-		pr_err("ion_dummy: Could not allocate carveout\n");
-
-	/* Allocate a dummy chunk heap */
-	chunk_ptr = alloc_pages_exact(
-				dummy_heaps[ION_HEAP_TYPE_CHUNK].size,
-				GFP_KERNEL);
-	if (chunk_ptr)
-		dummy_heaps[ION_HEAP_TYPE_CHUNK].base = virt_to_phys(chunk_ptr);
-	else
-		pr_err("ion_dummy: Could not allocate chunk\n");
-
-	for (i = 0; i < dummy_ion_pdata.nr; i++) {
-		struct ion_platform_heap *heap_data = &dummy_ion_pdata.heaps[i];
-
-		if (heap_data->type == ION_HEAP_TYPE_CARVEOUT &&
-		    !heap_data->base)
-			continue;
-
-		if (heap_data->type == ION_HEAP_TYPE_CHUNK && !heap_data->base)
-			continue;
-
-		heaps[i] = ion_heap_create(heap_data);
-		if (IS_ERR_OR_NULL(heaps[i])) {
-			err = PTR_ERR(heaps[i]);
-			goto err;
-		}
-		ion_device_add_heap(idev, heaps[i]);
-	}
-	return 0;
-err:
-	for (i = 0; i < dummy_ion_pdata.nr; ++i)
-		ion_heap_destroy(heaps[i]);
-	kfree(heaps);
-
-	if (carveout_ptr) {
-		free_pages_exact(carveout_ptr,
-				 dummy_heaps[ION_HEAP_TYPE_CARVEOUT].size);
-		carveout_ptr = NULL;
-	}
-	if (chunk_ptr) {
-		free_pages_exact(chunk_ptr,
-				 dummy_heaps[ION_HEAP_TYPE_CHUNK].size);
-		chunk_ptr = NULL;
-	}
-	return err;
-}
-device_initcall(ion_dummy_init);
-
-static void __exit ion_dummy_exit(void)
-{
-	int i;
-
-	ion_device_destroy(idev);
-
-	for (i = 0; i < dummy_ion_pdata.nr; i++)
-		ion_heap_destroy(heaps[i]);
-	kfree(heaps);
-
-	if (carveout_ptr) {
-		free_pages_exact(carveout_ptr,
-				 dummy_heaps[ION_HEAP_TYPE_CARVEOUT].size);
-		carveout_ptr = NULL;
-	}
-	if (chunk_ptr) {
-		free_pages_exact(chunk_ptr,
-				 dummy_heaps[ION_HEAP_TYPE_CHUNK].size);
-		chunk_ptr = NULL;
-	}
-}
-__exitcall(ion_dummy_exit);
diff --git a/drivers/staging/android/ion/ion_of.c b/drivers/staging/android/ion/ion_of.c
deleted file mode 100644
index 7791c70..0000000
--- a/drivers/staging/android/ion/ion_of.c
+++ /dev/null
@@ -1,184 +0,0 @@
-/*
- * Based on work from:
- *   Andrew Andrianov <andrew@ncrmnt.org>
- *   Google
- *   The Linux Foundation
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/init.h>
-#include <linux/platform_device.h>
-#include <linux/slab.h>
-#include <linux/of.h>
-#include <linux/of_platform.h>
-#include <linux/of_address.h>
-#include <linux/clk.h>
-#include <linux/dma-mapping.h>
-#include <linux/cma.h>
-#include <linux/dma-contiguous.h>
-#include <linux/io.h>
-#include <linux/of_reserved_mem.h>
-#include "ion.h"
-#include "ion_priv.h"
-#include "ion_of.h"
-
-static int ion_parse_dt_heap_common(struct device_node *heap_node,
-				    struct ion_platform_heap *heap,
-				    struct ion_of_heap *compatible)
-{
-	int i;
-
-	for (i = 0; compatible[i].name; i++) {
-		if (of_device_is_compatible(heap_node, compatible[i].compat))
-			break;
-	}
-
-	if (!compatible[i].name)
-		return -ENODEV;
-
-	heap->id = compatible[i].heap_id;
-	heap->type = compatible[i].type;
-	heap->name = compatible[i].name;
-	heap->align = compatible[i].align;
-
-	/* Some kind of callback function pointer? */
-
-	pr_info("%s: id %d type %d name %s align %lx\n", __func__,
-		heap->id, heap->type, heap->name, heap->align);
-	return 0;
-}
-
-static int ion_setup_heap_common(struct platform_device *parent,
-				 struct device_node *heap_node,
-				 struct ion_platform_heap *heap)
-{
-	int ret = 0;
-
-	switch (heap->type) {
-	case ION_HEAP_TYPE_CARVEOUT:
-	case ION_HEAP_TYPE_CHUNK:
-		if (heap->base && heap->size)
-			return 0;
-
-		ret = of_reserved_mem_device_init(heap->priv);
-		break;
-	default:
-		break;
-	}
-
-	return ret;
-}
-
-struct ion_platform_data *ion_parse_dt(struct platform_device *pdev,
-				       struct ion_of_heap *compatible)
-{
-	int num_heaps, ret;
-	const struct device_node *dt_node = pdev->dev.of_node;
-	struct device_node *node;
-	struct ion_platform_heap *heaps;
-	struct ion_platform_data *data;
-	int i = 0;
-
-	num_heaps = of_get_available_child_count(dt_node);
-
-	if (!num_heaps)
-		return ERR_PTR(-EINVAL);
-
-	heaps = devm_kzalloc(&pdev->dev,
-			     sizeof(struct ion_platform_heap) * num_heaps,
-			     GFP_KERNEL);
-	if (!heaps)
-		return ERR_PTR(-ENOMEM);
-
-	data = devm_kzalloc(&pdev->dev, sizeof(struct ion_platform_data),
-			    GFP_KERNEL);
-	if (!data)
-		return ERR_PTR(-ENOMEM);
-
-	for_each_available_child_of_node(dt_node, node) {
-		struct platform_device *heap_pdev;
-
-		ret = ion_parse_dt_heap_common(node, &heaps[i], compatible);
-		if (ret)
-			return ERR_PTR(ret);
-
-		heap_pdev = of_platform_device_create(node, heaps[i].name,
-						      &pdev->dev);
-		if (!heap_pdev)
-			return ERR_PTR(-ENOMEM);
-		heap_pdev->dev.platform_data = &heaps[i];
-
-		heaps[i].priv = &heap_pdev->dev;
-
-		ret = ion_setup_heap_common(pdev, node, &heaps[i]);
-		if (ret)
-			goto out_err;
-		i++;
-	}
-
-	data->heaps = heaps;
-	data->nr = num_heaps;
-	return data;
-
-out_err:
-	for ( ; i >= 0; i--)
-		if (heaps[i].priv)
-			of_device_unregister(to_platform_device(heaps[i].priv));
-
-	return ERR_PTR(ret);
-}
-
-void ion_destroy_platform_data(struct ion_platform_data *data)
-{
-	int i;
-
-	for (i = 0; i < data->nr; i++)
-		if (data->heaps[i].priv)
-			of_device_unregister(to_platform_device(
-				data->heaps[i].priv));
-}
-
-#ifdef CONFIG_OF_RESERVED_MEM
-#include <linux/of.h>
-#include <linux/of_fdt.h>
-#include <linux/of_reserved_mem.h>
-
-static int rmem_ion_device_init(struct reserved_mem *rmem, struct device *dev)
-{
-	struct platform_device *pdev = to_platform_device(dev);
-	struct ion_platform_heap *heap = pdev->dev.platform_data;
-
-	heap->base = rmem->base;
-	heap->base = rmem->size;
-	pr_debug("%s: heap %s base %pa size %pa dev %p\n", __func__,
-		 heap->name, &rmem->base, &rmem->size, dev);
-	return 0;
-}
-
-static void rmem_ion_device_release(struct reserved_mem *rmem,
-				    struct device *dev)
-{
-}
-
-static const struct reserved_mem_ops rmem_dma_ops = {
-	.device_init	= rmem_ion_device_init,
-	.device_release	= rmem_ion_device_release,
-};
-
-static int __init rmem_ion_setup(struct reserved_mem *rmem)
-{
-	phys_addr_t size = rmem->size;
-
-	size = size / 1024;
-
-	pr_info("Ion memory setup at %pa size %pa MiB\n",
-		&rmem->base, &size);
-	rmem->ops = &rmem_dma_ops;
-	return 0;
-}
-
-RESERVEDMEM_OF_DECLARE(ion, "ion-region", rmem_ion_setup);
-#endif
diff --git a/drivers/staging/android/ion/ion_of.h b/drivers/staging/android/ion/ion_of.h
deleted file mode 100644
index 8241a17..0000000
--- a/drivers/staging/android/ion/ion_of.h
+++ /dev/null
@@ -1,37 +0,0 @@
-/*
- * Based on work from:
- *   Andrew Andrianov <andrew@ncrmnt.org>
- *   Google
- *   The Linux Foundation
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ION_OF_H
-#define _ION_OF_H
-
-struct ion_of_heap {
-	const char *compat;
-	int heap_id;
-	int type;
-	const char *name;
-	int align;
-};
-
-#define PLATFORM_HEAP(_compat, _id, _type, _name) \
-{ \
-	.compat = _compat, \
-	.heap_id = _id, \
-	.type = _type, \
-	.name = _name, \
-	.align = PAGE_SIZE, \
-}
-
-struct ion_platform_data *ion_parse_dt(struct platform_device *pdev,
-					struct ion_of_heap *compatible);
-
-void ion_destroy_platform_data(struct ion_platform_data *data);
-
-#endif
diff --git a/drivers/staging/android/ion/ion_test.c b/drivers/staging/android/ion/ion_test.c
deleted file mode 100644
index 5abf8320..0000000
--- a/drivers/staging/android/ion/ion_test.c
+++ /dev/null
@@ -1,305 +0,0 @@
-/*
- *
- * Copyright (C) 2013 Google, Inc.
- *
- * This software is licensed under the terms of the GNU General Public
- * License version 2, as published by the Free Software Foundation, and
- * may be copied, distributed, and modified under those terms.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- */
-
-#define pr_fmt(fmt) "ion-test: " fmt
-
-#include <linux/dma-buf.h>
-#include <linux/dma-direction.h>
-#include <linux/fs.h>
-#include <linux/miscdevice.h>
-#include <linux/mm.h>
-#include <linux/module.h>
-#include <linux/platform_device.h>
-#include <linux/sched.h>
-#include <linux/slab.h>
-#include <linux/uaccess.h>
-#include <linux/vmalloc.h>
-
-#include "ion.h"
-#include "../uapi/ion_test.h"
-
-#define u64_to_uptr(x) ((void __user *)(unsigned long)(x))
-
-struct ion_test_device {
-	struct miscdevice misc;
-};
-
-struct ion_test_data {
-	struct dma_buf *dma_buf;
-	struct device *dev;
-};
-
-static int ion_handle_test_dma(struct device *dev, struct dma_buf *dma_buf,
-			       void __user *ptr, size_t offset, size_t size,
-			       bool write)
-{
-	int ret = 0;
-	struct dma_buf_attachment *attach;
-	struct sg_table *table;
-	pgprot_t pgprot = pgprot_writecombine(PAGE_KERNEL);
-	enum dma_data_direction dir = write ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
-	struct sg_page_iter sg_iter;
-	unsigned long offset_page;
-
-	attach = dma_buf_attach(dma_buf, dev);
-	if (IS_ERR(attach))
-		return PTR_ERR(attach);
-
-	table = dma_buf_map_attachment(attach, dir);
-	if (IS_ERR(table))
-		return PTR_ERR(table);
-
-	offset_page = offset >> PAGE_SHIFT;
-	offset %= PAGE_SIZE;
-
-	for_each_sg_page(table->sgl, &sg_iter, table->nents, offset_page) {
-		struct page *page = sg_page_iter_page(&sg_iter);
-		void *vaddr = vmap(&page, 1, VM_MAP, pgprot);
-		size_t to_copy = PAGE_SIZE - offset;
-
-		to_copy = min(to_copy, size);
-		if (!vaddr) {
-			ret = -ENOMEM;
-			goto err;
-		}
-
-		if (write)
-			ret = copy_from_user(vaddr + offset, ptr, to_copy);
-		else
-			ret = copy_to_user(ptr, vaddr + offset, to_copy);
-
-		vunmap(vaddr);
-		if (ret) {
-			ret = -EFAULT;
-			goto err;
-		}
-		size -= to_copy;
-		if (!size)
-			break;
-		ptr += to_copy;
-		offset = 0;
-	}
-
-err:
-	dma_buf_unmap_attachment(attach, table, dir);
-	dma_buf_detach(dma_buf, attach);
-	return ret;
-}
-
-static int ion_handle_test_kernel(struct dma_buf *dma_buf, void __user *ptr,
-				  size_t offset, size_t size, bool write)
-{
-	int ret;
-	unsigned long page_offset = offset >> PAGE_SHIFT;
-	size_t copy_offset = offset % PAGE_SIZE;
-	size_t copy_size = size;
-	enum dma_data_direction dir = write ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
-
-	if (offset > dma_buf->size || size > dma_buf->size - offset)
-		return -EINVAL;
-
-	ret = dma_buf_begin_cpu_access(dma_buf, dir);
-	if (ret)
-		return ret;
-
-	while (copy_size > 0) {
-		size_t to_copy;
-		void *vaddr = dma_buf_kmap(dma_buf, page_offset);
-
-		if (!vaddr)
-			goto err;
-
-		to_copy = min_t(size_t, PAGE_SIZE - copy_offset, copy_size);
-
-		if (write)
-			ret = copy_from_user(vaddr + copy_offset, ptr, to_copy);
-		else
-			ret = copy_to_user(ptr, vaddr + copy_offset, to_copy);
-
-		dma_buf_kunmap(dma_buf, page_offset, vaddr);
-		if (ret) {
-			ret = -EFAULT;
-			goto err;
-		}
-
-		copy_size -= to_copy;
-		ptr += to_copy;
-		page_offset++;
-		copy_offset = 0;
-	}
-err:
-	dma_buf_end_cpu_access(dma_buf, dir);
-	return ret;
-}
-
-static long ion_test_ioctl(struct file *filp, unsigned int cmd,
-			   unsigned long arg)
-{
-	struct ion_test_data *test_data = filp->private_data;
-	int ret = 0;
-
-	union {
-		struct ion_test_rw_data test_rw;
-	} data;
-
-	if (_IOC_SIZE(cmd) > sizeof(data))
-		return -EINVAL;
-
-	if (_IOC_DIR(cmd) & _IOC_WRITE)
-		if (copy_from_user(&data, (void __user *)arg, _IOC_SIZE(cmd)))
-			return -EFAULT;
-
-	switch (cmd) {
-	case ION_IOC_TEST_SET_FD:
-	{
-		struct dma_buf *dma_buf = NULL;
-		int fd = arg;
-
-		if (fd >= 0) {
-			dma_buf = dma_buf_get((int)arg);
-			if (IS_ERR(dma_buf))
-				return PTR_ERR(dma_buf);
-		}
-		if (test_data->dma_buf)
-			dma_buf_put(test_data->dma_buf);
-		test_data->dma_buf = dma_buf;
-		break;
-	}
-	case ION_IOC_TEST_DMA_MAPPING:
-	{
-		ret = ion_handle_test_dma(test_data->dev, test_data->dma_buf,
-					  u64_to_uptr(data.test_rw.ptr),
-					  data.test_rw.offset,
-					  data.test_rw.size,
-					  data.test_rw.write);
-		break;
-	}
-	case ION_IOC_TEST_KERNEL_MAPPING:
-	{
-		ret = ion_handle_test_kernel(test_data->dma_buf,
-					     u64_to_uptr(data.test_rw.ptr),
-					     data.test_rw.offset,
-					     data.test_rw.size,
-					     data.test_rw.write);
-		break;
-	}
-	default:
-		return -ENOTTY;
-	}
-
-	if (_IOC_DIR(cmd) & _IOC_READ) {
-		if (copy_to_user((void __user *)arg, &data, sizeof(data)))
-			return -EFAULT;
-	}
-	return ret;
-}
-
-static int ion_test_open(struct inode *inode, struct file *file)
-{
-	struct ion_test_data *data;
-	struct miscdevice *miscdev = file->private_data;
-
-	data = kzalloc(sizeof(*data), GFP_KERNEL);
-	if (!data)
-		return -ENOMEM;
-
-	data->dev = miscdev->parent;
-
-	file->private_data = data;
-
-	return 0;
-}
-
-static int ion_test_release(struct inode *inode, struct file *file)
-{
-	struct ion_test_data *data = file->private_data;
-
-	kfree(data);
-
-	return 0;
-}
-
-static const struct file_operations ion_test_fops = {
-	.owner = THIS_MODULE,
-	.unlocked_ioctl = ion_test_ioctl,
-	.compat_ioctl = ion_test_ioctl,
-	.open = ion_test_open,
-	.release = ion_test_release,
-};
-
-static int __init ion_test_probe(struct platform_device *pdev)
-{
-	int ret;
-	struct ion_test_device *testdev;
-
-	testdev = devm_kzalloc(&pdev->dev, sizeof(struct ion_test_device),
-			       GFP_KERNEL);
-	if (!testdev)
-		return -ENOMEM;
-
-	testdev->misc.minor = MISC_DYNAMIC_MINOR;
-	testdev->misc.name = "ion-test";
-	testdev->misc.fops = &ion_test_fops;
-	testdev->misc.parent = &pdev->dev;
-	ret = misc_register(&testdev->misc);
-	if (ret) {
-		pr_err("failed to register misc device.\n");
-		return ret;
-	}
-
-	platform_set_drvdata(pdev, testdev);
-
-	return 0;
-}
-
-static int ion_test_remove(struct platform_device *pdev)
-{
-	struct ion_test_device *testdev;
-
-	testdev = platform_get_drvdata(pdev);
-	if (!testdev)
-		return -ENODATA;
-
-	misc_deregister(&testdev->misc);
-	return 0;
-}
-
-static struct platform_device *ion_test_pdev;
-static struct platform_driver ion_test_platform_driver = {
-	.remove = ion_test_remove,
-	.driver = {
-		.name = "ion-test",
-	},
-};
-
-static int __init ion_test_init(void)
-{
-	ion_test_pdev = platform_device_register_simple("ion-test",
-							-1, NULL, 0);
-	if (IS_ERR(ion_test_pdev))
-		return PTR_ERR(ion_test_pdev);
-
-	return platform_driver_probe(&ion_test_platform_driver, ion_test_probe);
-}
-
-static void __exit ion_test_exit(void)
-{
-	platform_driver_unregister(&ion_test_platform_driver);
-	platform_device_unregister(ion_test_pdev);
-}
-
-module_init(ion_test_init);
-module_exit(ion_test_exit);
-MODULE_LICENSE("GPL v2");
diff --git a/drivers/staging/android/ion/tegra/Makefile b/drivers/staging/android/ion/tegra/Makefile
deleted file mode 100644
index 808f1f5..0000000
--- a/drivers/staging/android/ion/tegra/Makefile
+++ /dev/null
@@ -1 +0,0 @@
-obj-$(CONFIG_ION_TEGRA) += tegra_ion.o
diff --git a/drivers/staging/android/ion/tegra/tegra_ion.c b/drivers/staging/android/ion/tegra/tegra_ion.c
deleted file mode 100644
index 49e55e5..0000000
--- a/drivers/staging/android/ion/tegra/tegra_ion.c
+++ /dev/null
@@ -1,80 +0,0 @@
-/*
- * drivers/gpu/tegra/tegra_ion.c
- *
- * Copyright (C) 2011 Google, Inc.
- *
- * This software is licensed under the terms of the GNU General Public
- * License version 2, as published by the Free Software Foundation, and
- * may be copied, distributed, and modified under those terms.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- */
-
-#include <linux/err.h>
-#include <linux/module.h>
-#include <linux/platform_device.h>
-#include <linux/slab.h>
-#include "../ion.h"
-#include "../ion_priv.h"
-
-static struct ion_device *idev;
-static int num_heaps;
-static struct ion_heap **heaps;
-
-static int tegra_ion_probe(struct platform_device *pdev)
-{
-	struct ion_platform_data *pdata = pdev->dev.platform_data;
-	int err;
-	int i;
-
-	num_heaps = pdata->nr;
-
-	heaps = devm_kcalloc(&pdev->dev, pdata->nr,
-			     sizeof(struct ion_heap *), GFP_KERNEL);
-
-	idev = ion_device_create(NULL);
-	if (IS_ERR(idev))
-		return PTR_ERR(idev);
-
-	/* create the heaps as specified in the board file */
-	for (i = 0; i < num_heaps; i++) {
-		struct ion_platform_heap *heap_data = &pdata->heaps[i];
-
-		heaps[i] = ion_heap_create(heap_data);
-		if (IS_ERR_OR_NULL(heaps[i])) {
-			err = PTR_ERR(heaps[i]);
-			goto err;
-		}
-		ion_device_add_heap(idev, heaps[i]);
-	}
-	platform_set_drvdata(pdev, idev);
-	return 0;
-err:
-	for (i = 0; i < num_heaps; ++i)
-		ion_heap_destroy(heaps[i]);
-	return err;
-}
-
-static int tegra_ion_remove(struct platform_device *pdev)
-{
-	struct ion_device *idev = platform_get_drvdata(pdev);
-	int i;
-
-	ion_device_destroy(idev);
-	for (i = 0; i < num_heaps; i++)
-		ion_heap_destroy(heaps[i]);
-	return 0;
-}
-
-static struct platform_driver ion_driver = {
-	.probe = tegra_ion_probe,
-	.remove = tegra_ion_remove,
-	.driver = { .name = "ion-tegra" }
-};
-
-module_platform_driver(ion_driver);
-
diff --git a/drivers/staging/android/uapi/ion_test.h b/drivers/staging/android/uapi/ion_test.h
deleted file mode 100644
index 480242e..0000000
--- a/drivers/staging/android/uapi/ion_test.h
+++ /dev/null
@@ -1,69 +0,0 @@
-/*
- * drivers/staging/android/uapi/ion.h
- *
- * Copyright (C) 2011 Google, Inc.
- *
- * This software is licensed under the terms of the GNU General Public
- * License version 2, as published by the Free Software Foundation, and
- * may be copied, distributed, and modified under those terms.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- */
-
-#ifndef _UAPI_LINUX_ION_TEST_H
-#define _UAPI_LINUX_ION_TEST_H
-
-#include <linux/ioctl.h>
-#include <linux/types.h>
-
-/**
- * struct ion_test_rw_data - metadata passed to the kernel to read handle
- * @ptr:	a pointer to an area at least as large as size
- * @offset:	offset into the ion buffer to start reading
- * @size:	size to read or write
- * @write:	1 to write, 0 to read
- */
-struct ion_test_rw_data {
-	__u64 ptr;
-	__u64 offset;
-	__u64 size;
-	int write;
-	int __padding;
-};
-
-#define ION_IOC_MAGIC		'I'
-
-/**
- * DOC: ION_IOC_TEST_SET_DMA_BUF - attach a dma buf to the test driver
- *
- * Attaches a dma buf fd to the test driver.  Passing a second fd or -1 will
- * release the first fd.
- */
-#define ION_IOC_TEST_SET_FD \
-			_IO(ION_IOC_MAGIC, 0xf0)
-
-/**
- * DOC: ION_IOC_TEST_DMA_MAPPING - read or write memory from a handle as DMA
- *
- * Reads or writes the memory from a handle using an uncached mapping.  Can be
- * used by unit tests to emulate a DMA engine as close as possible.  Only
- * expected to be used for debugging and testing, may not always be available.
- */
-#define ION_IOC_TEST_DMA_MAPPING \
-			_IOW(ION_IOC_MAGIC, 0xf1, struct ion_test_rw_data)
-
-/**
- * DOC: ION_IOC_TEST_KERNEL_MAPPING - read or write memory from a handle
- *
- * Reads or writes the memory from a handle using a kernel mapping.  Can be
- * used by unit tests to test heap map_kernel functions.  Only expected to be
- * used for debugging and testing, may not always be available.
- */
-#define ION_IOC_TEST_KERNEL_MAPPING \
-			_IOW(ION_IOC_MAGIC, 0xf2, struct ion_test_rw_data)
-
-#endif /* _UAPI_LINUX_ION_H */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
