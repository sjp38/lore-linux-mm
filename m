Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EAEB16B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 05:31:07 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y51so38272090wry.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 02:31:07 -0800 (PST)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id l73si2359887wmd.112.2017.03.03.02.31.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 02:31:06 -0800 (PST)
Received: by mail-wr0-x241.google.com with SMTP id g10so12747835wrg.0
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 02:31:06 -0800 (PST)
Date: Fri, 3 Mar 2017 11:31:02 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC PATCH 07/12] staging: android: ion: Remove old platform
 support
Message-ID: <20170303103102.iwe36f7hdiyxr3yn@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1488491084-17252-8-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488491084-17252-8-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org

On Thu, Mar 02, 2017 at 01:44:39PM -0800, Laura Abbott wrote:
> 
> Device specific platform support has been haphazard for Ion. There have
> been several independent attempts and there are still objections to
> what bindings exist right now. Just remove everything for a fresh start.
> 
> Signed-off-by: Laura Abbott <labbott@redhat.com>

It looks like with this we could remove a lot of the EXPORT_SYMBOL
statements from the ion code. Might be good to follow up with a patch to
clean those out.

Otherwise a patch that only removes code, what's not to love!

Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>

> ---
>  drivers/staging/android/ion/Kconfig                |  35 ----
>  drivers/staging/android/ion/Makefile               |   6 -
>  drivers/staging/android/ion/hisilicon/Kconfig      |   5 -
>  drivers/staging/android/ion/hisilicon/Makefile     |   1 -
>  drivers/staging/android/ion/hisilicon/hi6220_ion.c | 113 -------------
>  drivers/staging/android/ion/ion_dummy_driver.c     | 156 -----------------
>  drivers/staging/android/ion/ion_of.c               | 184 ---------------------
>  drivers/staging/android/ion/ion_of.h               |  37 -----
>  drivers/staging/android/ion/tegra/Makefile         |   1 -
>  drivers/staging/android/ion/tegra/tegra_ion.c      |  80 ---------
>  10 files changed, 618 deletions(-)
>  delete mode 100644 drivers/staging/android/ion/hisilicon/Kconfig
>  delete mode 100644 drivers/staging/android/ion/hisilicon/Makefile
>  delete mode 100644 drivers/staging/android/ion/hisilicon/hi6220_ion.c
>  delete mode 100644 drivers/staging/android/ion/ion_dummy_driver.c
>  delete mode 100644 drivers/staging/android/ion/ion_of.c
>  delete mode 100644 drivers/staging/android/ion/ion_of.h
>  delete mode 100644 drivers/staging/android/ion/tegra/Makefile
>  delete mode 100644 drivers/staging/android/ion/tegra/tegra_ion.c
> 
> diff --git a/drivers/staging/android/ion/Kconfig b/drivers/staging/android/ion/Kconfig
> index c8fb413..0c91b2b 100644
> --- a/drivers/staging/android/ion/Kconfig
> +++ b/drivers/staging/android/ion/Kconfig
> @@ -17,38 +17,3 @@ config ION_TEST
>  	  Choose this option to create a device that can be used to test the
>  	  kernel and device side ION functions.
>  
> -config ION_DUMMY
> -	bool "Dummy Ion driver"
> -	depends on ION
> -	help
> -	  Provides a dummy ION driver that registers the
> -	  /dev/ion device and some basic heaps. This can
> -	  be used for testing the ION infrastructure if
> -	  one doesn't have access to hardware drivers that
> -	  use ION.
> -
> -config ION_TEGRA
> -	tristate "Ion for Tegra"
> -	depends on ARCH_TEGRA && ION
> -	help
> -	  Choose this option if you wish to use ion on an nVidia Tegra.
> -
> -config ION_HISI
> -	tristate "Ion for Hisilicon"
> -	depends on ARCH_HISI && ION
> -	select ION_OF
> -	help
> -	  Choose this option if you wish to use ion on Hisilicon Platform.
> -
> -source "drivers/staging/android/ion/hisilicon/Kconfig"
> -
> -config ION_OF
> -	bool "Devicetree support for Ion"
> -	depends on ION && OF_ADDRESS
> -	help
> -	  Provides base support for defining Ion heaps in devicetree
> -	  and setting them up. Also includes functions for platforms
> -	  to parse the devicetree and expand for their own custom
> -	  extensions
> -
> -	  If using Ion and devicetree, you should say Y here
> diff --git a/drivers/staging/android/ion/Makefile b/drivers/staging/android/ion/Makefile
> index 5d630a0..9457090 100644
> --- a/drivers/staging/android/ion/Makefile
> +++ b/drivers/staging/android/ion/Makefile
> @@ -5,9 +5,3 @@ obj-$(CONFIG_ION_TEST) += ion_test.o
>  ifdef CONFIG_COMPAT
>  obj-$(CONFIG_ION) += compat_ion.o
>  endif
> -
> -obj-$(CONFIG_ION_DUMMY) += ion_dummy_driver.o
> -obj-$(CONFIG_ION_TEGRA) += tegra/
> -obj-$(CONFIG_ION_HISI) += hisilicon/
> -obj-$(CONFIG_ION_OF) += ion_of.o
> -
> diff --git a/drivers/staging/android/ion/hisilicon/Kconfig b/drivers/staging/android/ion/hisilicon/Kconfig
> deleted file mode 100644
> index 2b4bd07..0000000
> --- a/drivers/staging/android/ion/hisilicon/Kconfig
> +++ /dev/null
> @@ -1,5 +0,0 @@
> -config HI6220_ION
> -        bool "Hi6220 ION Driver"
> -        depends on ARCH_HISI && ION
> -        help
> -          Build the Hisilicon Hi6220 ion driver.
> diff --git a/drivers/staging/android/ion/hisilicon/Makefile b/drivers/staging/android/ion/hisilicon/Makefile
> deleted file mode 100644
> index 2a89414..0000000
> --- a/drivers/staging/android/ion/hisilicon/Makefile
> +++ /dev/null
> @@ -1 +0,0 @@
> -obj-$(CONFIG_HI6220_ION) += hi6220_ion.o
> diff --git a/drivers/staging/android/ion/hisilicon/hi6220_ion.c b/drivers/staging/android/ion/hisilicon/hi6220_ion.c
> deleted file mode 100644
> index 0de7897..0000000
> --- a/drivers/staging/android/ion/hisilicon/hi6220_ion.c
> +++ /dev/null
> @@ -1,113 +0,0 @@
> -/*
> - * Hisilicon Hi6220 ION Driver
> - *
> - * Copyright (c) 2015 Hisilicon Limited.
> - *
> - * Author: Chen Feng <puck.chen@hisilicon.com>
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 as
> - * published by the Free Software Foundation.
> - */
> -
> -#define pr_fmt(fmt) "Ion: " fmt
> -
> -#include <linux/err.h>
> -#include <linux/platform_device.h>
> -#include <linux/slab.h>
> -#include <linux/of.h>
> -#include <linux/mm.h>
> -#include "../ion_priv.h"
> -#include "../ion.h"
> -#include "../ion_of.h"
> -
> -struct hisi_ion_dev {
> -	struct ion_heap	**heaps;
> -	struct ion_device *idev;
> -	struct ion_platform_data *data;
> -};
> -
> -static struct ion_of_heap hisi_heaps[] = {
> -	PLATFORM_HEAP("hisilicon,sys_user", 0,
> -		      ION_HEAP_TYPE_SYSTEM, "sys_user"),
> -	PLATFORM_HEAP("hisilicon,sys_contig", 1,
> -		      ION_HEAP_TYPE_SYSTEM_CONTIG, "sys_contig"),
> -	PLATFORM_HEAP("hisilicon,cma", ION_HEAP_TYPE_DMA, ION_HEAP_TYPE_DMA,
> -		      "cma"),
> -	{}
> -};
> -
> -static int hi6220_ion_probe(struct platform_device *pdev)
> -{
> -	struct hisi_ion_dev *ipdev;
> -	int i;
> -
> -	ipdev = devm_kzalloc(&pdev->dev, sizeof(*ipdev), GFP_KERNEL);
> -	if (!ipdev)
> -		return -ENOMEM;
> -
> -	platform_set_drvdata(pdev, ipdev);
> -
> -	ipdev->idev = ion_device_create(NULL);
> -	if (IS_ERR(ipdev->idev))
> -		return PTR_ERR(ipdev->idev);
> -
> -	ipdev->data = ion_parse_dt(pdev, hisi_heaps);
> -	if (IS_ERR(ipdev->data))
> -		return PTR_ERR(ipdev->data);
> -
> -	ipdev->heaps = devm_kzalloc(&pdev->dev,
> -				sizeof(struct ion_heap) * ipdev->data->nr,
> -				GFP_KERNEL);
> -	if (!ipdev->heaps) {
> -		ion_destroy_platform_data(ipdev->data);
> -		return -ENOMEM;
> -	}
> -
> -	for (i = 0; i < ipdev->data->nr; i++) {
> -		ipdev->heaps[i] = ion_heap_create(&ipdev->data->heaps[i]);
> -		if (!ipdev->heaps) {
> -			ion_destroy_platform_data(ipdev->data);
> -			return -ENOMEM;
> -		}
> -		ion_device_add_heap(ipdev->idev, ipdev->heaps[i]);
> -	}
> -	return 0;
> -}
> -
> -static int hi6220_ion_remove(struct platform_device *pdev)
> -{
> -	struct hisi_ion_dev *ipdev;
> -	int i;
> -
> -	ipdev = platform_get_drvdata(pdev);
> -
> -	for (i = 0; i < ipdev->data->nr; i++)
> -		ion_heap_destroy(ipdev->heaps[i]);
> -
> -	ion_destroy_platform_data(ipdev->data);
> -	ion_device_destroy(ipdev->idev);
> -
> -	return 0;
> -}
> -
> -static const struct of_device_id hi6220_ion_match_table[] = {
> -	{.compatible = "hisilicon,hi6220-ion"},
> -	{},
> -};
> -
> -static struct platform_driver hi6220_ion_driver = {
> -	.probe = hi6220_ion_probe,
> -	.remove = hi6220_ion_remove,
> -	.driver = {
> -		.name = "ion-hi6220",
> -		.of_match_table = hi6220_ion_match_table,
> -	},
> -};
> -
> -static int __init hi6220_ion_init(void)
> -{
> -	return platform_driver_register(&hi6220_ion_driver);
> -}
> -
> -subsys_initcall(hi6220_ion_init);
> diff --git a/drivers/staging/android/ion/ion_dummy_driver.c b/drivers/staging/android/ion/ion_dummy_driver.c
> deleted file mode 100644
> index cf5c010..0000000
> --- a/drivers/staging/android/ion/ion_dummy_driver.c
> +++ /dev/null
> @@ -1,156 +0,0 @@
> -/*
> - * drivers/gpu/ion/ion_dummy_driver.c
> - *
> - * Copyright (C) 2013 Linaro, Inc
> - *
> - * This software is licensed under the terms of the GNU General Public
> - * License version 2, as published by the Free Software Foundation, and
> - * may be copied, distributed, and modified under those terms.
> - *
> - * This program is distributed in the hope that it will be useful,
> - * but WITHOUT ANY WARRANTY; without even the implied warranty of
> - * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> - * GNU General Public License for more details.
> - *
> - */
> -
> -#include <linux/err.h>
> -#include <linux/platform_device.h>
> -#include <linux/slab.h>
> -#include <linux/init.h>
> -#include <linux/bootmem.h>
> -#include <linux/memblock.h>
> -#include <linux/sizes.h>
> -#include <linux/io.h>
> -#include "ion.h"
> -#include "ion_priv.h"
> -
> -static struct ion_device *idev;
> -static struct ion_heap **heaps;
> -
> -static void *carveout_ptr;
> -static void *chunk_ptr;
> -
> -static struct ion_platform_heap dummy_heaps[] = {
> -		{
> -			.id	= ION_HEAP_TYPE_SYSTEM,
> -			.type	= ION_HEAP_TYPE_SYSTEM,
> -			.name	= "system",
> -		},
> -		{
> -			.id	= ION_HEAP_TYPE_SYSTEM_CONTIG,
> -			.type	= ION_HEAP_TYPE_SYSTEM_CONTIG,
> -			.name	= "system contig",
> -		},
> -		{
> -			.id	= ION_HEAP_TYPE_CARVEOUT,
> -			.type	= ION_HEAP_TYPE_CARVEOUT,
> -			.name	= "carveout",
> -			.size	= SZ_4M,
> -		},
> -		{
> -			.id	= ION_HEAP_TYPE_CHUNK,
> -			.type	= ION_HEAP_TYPE_CHUNK,
> -			.name	= "chunk",
> -			.size	= SZ_4M,
> -			.align	= SZ_16K,
> -			.priv	= (void *)(SZ_16K),
> -		},
> -};
> -
> -static const struct ion_platform_data dummy_ion_pdata = {
> -	.nr = ARRAY_SIZE(dummy_heaps),
> -	.heaps = dummy_heaps,
> -};
> -
> -static int __init ion_dummy_init(void)
> -{
> -	int i, err;
> -
> -	idev = ion_device_create(NULL);
> -	if (IS_ERR(idev))
> -		return PTR_ERR(idev);
> -	heaps = kcalloc(dummy_ion_pdata.nr, sizeof(struct ion_heap *),
> -			GFP_KERNEL);
> -	if (!heaps)
> -		return -ENOMEM;
> -
> -
> -	/* Allocate a dummy carveout heap */
> -	carveout_ptr = alloc_pages_exact(
> -				dummy_heaps[ION_HEAP_TYPE_CARVEOUT].size,
> -				GFP_KERNEL);
> -	if (carveout_ptr)
> -		dummy_heaps[ION_HEAP_TYPE_CARVEOUT].base =
> -						virt_to_phys(carveout_ptr);
> -	else
> -		pr_err("ion_dummy: Could not allocate carveout\n");
> -
> -	/* Allocate a dummy chunk heap */
> -	chunk_ptr = alloc_pages_exact(
> -				dummy_heaps[ION_HEAP_TYPE_CHUNK].size,
> -				GFP_KERNEL);
> -	if (chunk_ptr)
> -		dummy_heaps[ION_HEAP_TYPE_CHUNK].base = virt_to_phys(chunk_ptr);
> -	else
> -		pr_err("ion_dummy: Could not allocate chunk\n");
> -
> -	for (i = 0; i < dummy_ion_pdata.nr; i++) {
> -		struct ion_platform_heap *heap_data = &dummy_ion_pdata.heaps[i];
> -
> -		if (heap_data->type == ION_HEAP_TYPE_CARVEOUT &&
> -		    !heap_data->base)
> -			continue;
> -
> -		if (heap_data->type == ION_HEAP_TYPE_CHUNK && !heap_data->base)
> -			continue;
> -
> -		heaps[i] = ion_heap_create(heap_data);
> -		if (IS_ERR_OR_NULL(heaps[i])) {
> -			err = PTR_ERR(heaps[i]);
> -			goto err;
> -		}
> -		ion_device_add_heap(idev, heaps[i]);
> -	}
> -	return 0;
> -err:
> -	for (i = 0; i < dummy_ion_pdata.nr; ++i)
> -		ion_heap_destroy(heaps[i]);
> -	kfree(heaps);
> -
> -	if (carveout_ptr) {
> -		free_pages_exact(carveout_ptr,
> -				 dummy_heaps[ION_HEAP_TYPE_CARVEOUT].size);
> -		carveout_ptr = NULL;
> -	}
> -	if (chunk_ptr) {
> -		free_pages_exact(chunk_ptr,
> -				 dummy_heaps[ION_HEAP_TYPE_CHUNK].size);
> -		chunk_ptr = NULL;
> -	}
> -	return err;
> -}
> -device_initcall(ion_dummy_init);
> -
> -static void __exit ion_dummy_exit(void)
> -{
> -	int i;
> -
> -	ion_device_destroy(idev);
> -
> -	for (i = 0; i < dummy_ion_pdata.nr; i++)
> -		ion_heap_destroy(heaps[i]);
> -	kfree(heaps);
> -
> -	if (carveout_ptr) {
> -		free_pages_exact(carveout_ptr,
> -				 dummy_heaps[ION_HEAP_TYPE_CARVEOUT].size);
> -		carveout_ptr = NULL;
> -	}
> -	if (chunk_ptr) {
> -		free_pages_exact(chunk_ptr,
> -				 dummy_heaps[ION_HEAP_TYPE_CHUNK].size);
> -		chunk_ptr = NULL;
> -	}
> -}
> -__exitcall(ion_dummy_exit);
> diff --git a/drivers/staging/android/ion/ion_of.c b/drivers/staging/android/ion/ion_of.c
> deleted file mode 100644
> index 7791c70..0000000
> --- a/drivers/staging/android/ion/ion_of.c
> +++ /dev/null
> @@ -1,184 +0,0 @@
> -/*
> - * Based on work from:
> - *   Andrew Andrianov <andrew@ncrmnt.org>
> - *   Google
> - *   The Linux Foundation
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 as
> - * published by the Free Software Foundation.
> - */
> -
> -#include <linux/init.h>
> -#include <linux/platform_device.h>
> -#include <linux/slab.h>
> -#include <linux/of.h>
> -#include <linux/of_platform.h>
> -#include <linux/of_address.h>
> -#include <linux/clk.h>
> -#include <linux/dma-mapping.h>
> -#include <linux/cma.h>
> -#include <linux/dma-contiguous.h>
> -#include <linux/io.h>
> -#include <linux/of_reserved_mem.h>
> -#include "ion.h"
> -#include "ion_priv.h"
> -#include "ion_of.h"
> -
> -static int ion_parse_dt_heap_common(struct device_node *heap_node,
> -				    struct ion_platform_heap *heap,
> -				    struct ion_of_heap *compatible)
> -{
> -	int i;
> -
> -	for (i = 0; compatible[i].name; i++) {
> -		if (of_device_is_compatible(heap_node, compatible[i].compat))
> -			break;
> -	}
> -
> -	if (!compatible[i].name)
> -		return -ENODEV;
> -
> -	heap->id = compatible[i].heap_id;
> -	heap->type = compatible[i].type;
> -	heap->name = compatible[i].name;
> -	heap->align = compatible[i].align;
> -
> -	/* Some kind of callback function pointer? */
> -
> -	pr_info("%s: id %d type %d name %s align %lx\n", __func__,
> -		heap->id, heap->type, heap->name, heap->align);
> -	return 0;
> -}
> -
> -static int ion_setup_heap_common(struct platform_device *parent,
> -				 struct device_node *heap_node,
> -				 struct ion_platform_heap *heap)
> -{
> -	int ret = 0;
> -
> -	switch (heap->type) {
> -	case ION_HEAP_TYPE_CARVEOUT:
> -	case ION_HEAP_TYPE_CHUNK:
> -		if (heap->base && heap->size)
> -			return 0;
> -
> -		ret = of_reserved_mem_device_init(heap->priv);
> -		break;
> -	default:
> -		break;
> -	}
> -
> -	return ret;
> -}
> -
> -struct ion_platform_data *ion_parse_dt(struct platform_device *pdev,
> -				       struct ion_of_heap *compatible)
> -{
> -	int num_heaps, ret;
> -	const struct device_node *dt_node = pdev->dev.of_node;
> -	struct device_node *node;
> -	struct ion_platform_heap *heaps;
> -	struct ion_platform_data *data;
> -	int i = 0;
> -
> -	num_heaps = of_get_available_child_count(dt_node);
> -
> -	if (!num_heaps)
> -		return ERR_PTR(-EINVAL);
> -
> -	heaps = devm_kzalloc(&pdev->dev,
> -			     sizeof(struct ion_platform_heap) * num_heaps,
> -			     GFP_KERNEL);
> -	if (!heaps)
> -		return ERR_PTR(-ENOMEM);
> -
> -	data = devm_kzalloc(&pdev->dev, sizeof(struct ion_platform_data),
> -			    GFP_KERNEL);
> -	if (!data)
> -		return ERR_PTR(-ENOMEM);
> -
> -	for_each_available_child_of_node(dt_node, node) {
> -		struct platform_device *heap_pdev;
> -
> -		ret = ion_parse_dt_heap_common(node, &heaps[i], compatible);
> -		if (ret)
> -			return ERR_PTR(ret);
> -
> -		heap_pdev = of_platform_device_create(node, heaps[i].name,
> -						      &pdev->dev);
> -		if (!heap_pdev)
> -			return ERR_PTR(-ENOMEM);
> -		heap_pdev->dev.platform_data = &heaps[i];
> -
> -		heaps[i].priv = &heap_pdev->dev;
> -
> -		ret = ion_setup_heap_common(pdev, node, &heaps[i]);
> -		if (ret)
> -			goto out_err;
> -		i++;
> -	}
> -
> -	data->heaps = heaps;
> -	data->nr = num_heaps;
> -	return data;
> -
> -out_err:
> -	for ( ; i >= 0; i--)
> -		if (heaps[i].priv)
> -			of_device_unregister(to_platform_device(heaps[i].priv));
> -
> -	return ERR_PTR(ret);
> -}
> -
> -void ion_destroy_platform_data(struct ion_platform_data *data)
> -{
> -	int i;
> -
> -	for (i = 0; i < data->nr; i++)
> -		if (data->heaps[i].priv)
> -			of_device_unregister(to_platform_device(
> -				data->heaps[i].priv));
> -}
> -
> -#ifdef CONFIG_OF_RESERVED_MEM
> -#include <linux/of.h>
> -#include <linux/of_fdt.h>
> -#include <linux/of_reserved_mem.h>
> -
> -static int rmem_ion_device_init(struct reserved_mem *rmem, struct device *dev)
> -{
> -	struct platform_device *pdev = to_platform_device(dev);
> -	struct ion_platform_heap *heap = pdev->dev.platform_data;
> -
> -	heap->base = rmem->base;
> -	heap->base = rmem->size;
> -	pr_debug("%s: heap %s base %pa size %pa dev %p\n", __func__,
> -		 heap->name, &rmem->base, &rmem->size, dev);
> -	return 0;
> -}
> -
> -static void rmem_ion_device_release(struct reserved_mem *rmem,
> -				    struct device *dev)
> -{
> -}
> -
> -static const struct reserved_mem_ops rmem_dma_ops = {
> -	.device_init	= rmem_ion_device_init,
> -	.device_release	= rmem_ion_device_release,
> -};
> -
> -static int __init rmem_ion_setup(struct reserved_mem *rmem)
> -{
> -	phys_addr_t size = rmem->size;
> -
> -	size = size / 1024;
> -
> -	pr_info("Ion memory setup at %pa size %pa MiB\n",
> -		&rmem->base, &size);
> -	rmem->ops = &rmem_dma_ops;
> -	return 0;
> -}
> -
> -RESERVEDMEM_OF_DECLARE(ion, "ion-region", rmem_ion_setup);
> -#endif
> diff --git a/drivers/staging/android/ion/ion_of.h b/drivers/staging/android/ion/ion_of.h
> deleted file mode 100644
> index 8241a17..0000000
> --- a/drivers/staging/android/ion/ion_of.h
> +++ /dev/null
> @@ -1,37 +0,0 @@
> -/*
> - * Based on work from:
> - *   Andrew Andrianov <andrew@ncrmnt.org>
> - *   Google
> - *   The Linux Foundation
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 as
> - * published by the Free Software Foundation.
> - */
> -
> -#ifndef _ION_OF_H
> -#define _ION_OF_H
> -
> -struct ion_of_heap {
> -	const char *compat;
> -	int heap_id;
> -	int type;
> -	const char *name;
> -	int align;
> -};
> -
> -#define PLATFORM_HEAP(_compat, _id, _type, _name) \
> -{ \
> -	.compat = _compat, \
> -	.heap_id = _id, \
> -	.type = _type, \
> -	.name = _name, \
> -	.align = PAGE_SIZE, \
> -}
> -
> -struct ion_platform_data *ion_parse_dt(struct platform_device *pdev,
> -					struct ion_of_heap *compatible);
> -
> -void ion_destroy_platform_data(struct ion_platform_data *data);
> -
> -#endif
> diff --git a/drivers/staging/android/ion/tegra/Makefile b/drivers/staging/android/ion/tegra/Makefile
> deleted file mode 100644
> index 808f1f5..0000000
> --- a/drivers/staging/android/ion/tegra/Makefile
> +++ /dev/null
> @@ -1 +0,0 @@
> -obj-$(CONFIG_ION_TEGRA) += tegra_ion.o
> diff --git a/drivers/staging/android/ion/tegra/tegra_ion.c b/drivers/staging/android/ion/tegra/tegra_ion.c
> deleted file mode 100644
> index 49e55e5..0000000
> --- a/drivers/staging/android/ion/tegra/tegra_ion.c
> +++ /dev/null
> @@ -1,80 +0,0 @@
> -/*
> - * drivers/gpu/tegra/tegra_ion.c
> - *
> - * Copyright (C) 2011 Google, Inc.
> - *
> - * This software is licensed under the terms of the GNU General Public
> - * License version 2, as published by the Free Software Foundation, and
> - * may be copied, distributed, and modified under those terms.
> - *
> - * This program is distributed in the hope that it will be useful,
> - * but WITHOUT ANY WARRANTY; without even the implied warranty of
> - * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> - * GNU General Public License for more details.
> - *
> - */
> -
> -#include <linux/err.h>
> -#include <linux/module.h>
> -#include <linux/platform_device.h>
> -#include <linux/slab.h>
> -#include "../ion.h"
> -#include "../ion_priv.h"
> -
> -static struct ion_device *idev;
> -static int num_heaps;
> -static struct ion_heap **heaps;
> -
> -static int tegra_ion_probe(struct platform_device *pdev)
> -{
> -	struct ion_platform_data *pdata = pdev->dev.platform_data;
> -	int err;
> -	int i;
> -
> -	num_heaps = pdata->nr;
> -
> -	heaps = devm_kcalloc(&pdev->dev, pdata->nr,
> -			     sizeof(struct ion_heap *), GFP_KERNEL);
> -
> -	idev = ion_device_create(NULL);
> -	if (IS_ERR(idev))
> -		return PTR_ERR(idev);
> -
> -	/* create the heaps as specified in the board file */
> -	for (i = 0; i < num_heaps; i++) {
> -		struct ion_platform_heap *heap_data = &pdata->heaps[i];
> -
> -		heaps[i] = ion_heap_create(heap_data);
> -		if (IS_ERR_OR_NULL(heaps[i])) {
> -			err = PTR_ERR(heaps[i]);
> -			goto err;
> -		}
> -		ion_device_add_heap(idev, heaps[i]);
> -	}
> -	platform_set_drvdata(pdev, idev);
> -	return 0;
> -err:
> -	for (i = 0; i < num_heaps; ++i)
> -		ion_heap_destroy(heaps[i]);
> -	return err;
> -}
> -
> -static int tegra_ion_remove(struct platform_device *pdev)
> -{
> -	struct ion_device *idev = platform_get_drvdata(pdev);
> -	int i;
> -
> -	ion_device_destroy(idev);
> -	for (i = 0; i < num_heaps; i++)
> -		ion_heap_destroy(heaps[i]);
> -	return 0;
> -}
> -
> -static struct platform_driver ion_driver = {
> -	.probe = tegra_ion_probe,
> -	.remove = tegra_ion_remove,
> -	.driver = { .name = "ion-tegra" }
> -};
> -
> -module_platform_driver(ion_driver);
> -
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
