Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8048E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:18:51 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b8so6819515pfe.10
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 00:18:51 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t9si1086983pfk.35.2019.01.17.00.18.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 00:18:50 -0800 (PST)
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal
 RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181905.12E102B4@viggo.jf.intel.com>
From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Message-ID: <5ef5d5e9-9d35-fb84-b69e-7456dcf4c241@linux.intel.com>
Date: Thu, 17 Jan 2019 16:19:06 +0800
MIME-Version: 1.0
In-Reply-To: <20190116181905.12E102B4@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, dave@sr71.net
Cc: dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On 2019/1/17 上午2:19, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Currently, a persistent memory region is "owned" by a device driver,
> either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
> allow applications to explicitly use persistent memory, generally
> by being modified to use special, new libraries.
> 
> However, this limits persistent memory use to applications which
> *have* been modified.  To make it more broadly usable, this driver
> "hotplugs" memory into the kernel, to be managed ad used just like
> normal RAM would be.
> 
> To make this work, management software must remove the device from
> being controlled by the "Device DAX" infrastructure:
> 
> 	echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
> 	echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
> 
> and then bind it to this new driver:
> 
> 	echo -n dax0.0 > /sys/bus/dax/drivers/kmem/new_id
> 	echo -n dax0.0 > /sys/bus/dax/drivers/kmem/bind
> 
> After this, there will be a number of new memory sections visible
> in sysfs that can be onlined, or that may get onlined by existing
> udev-initiated memory hotplug rules.
> 
> Note: this inherits any existing NUMA information for the newly-
> added memory from the persistent memory device that came from the
> firmware.  On Intel platforms, the firmware has guarantees that
> require each socket's persistent memory to be in a separate
> memory-only NUMA node.  That means that this patch is not expected
> to create NUMA nodes, but will simply hotplug memory into existing
> nodes.
> 
> There is currently some metadata at the beginning of pmem regions.
> The section-size memory hotplug restrictions, plus this small
> reserved area can cause the "loss" of a section or two of capacity.
> This should be fixable in follow-on patches.  But, as a first step,
> losing 256MB of memory (worst case) out of hundreds of gigabytes
> is a good tradeoff vs. the required code to fix this up precisely.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Vishal Verma <vishal.l.verma@intel.com>
> Cc: Tom Lendacky <thomas.lendacky@amd.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: linux-nvdimm@lists.01.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> Cc: Takashi Iwai <tiwai@suse.de>
> ---
> 
>   b/drivers/dax/Kconfig  |    5 ++
>   b/drivers/dax/Makefile |    1
>   b/drivers/dax/kmem.c   |   93 +++++++++++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 99 insertions(+)
> 
> diff -puN drivers/dax/Kconfig~dax-kmem-try-4 drivers/dax/Kconfig
> --- a/drivers/dax/Kconfig~dax-kmem-try-4	2019-01-08 09:54:44.051694874 -0800
> +++ b/drivers/dax/Kconfig	2019-01-08 09:54:44.056694874 -0800
> @@ -32,6 +32,11 @@ config DEV_DAX_PMEM
>   
>   	  Say M if unsure
>   
> +config DEV_DAX_KMEM
> +	def_bool y
> +	depends on DEV_DAX_PMEM   # Needs DEV_DAX_PMEM infrastructure
> +	depends on MEMORY_HOTPLUG # for add_memory() and friends
> +
>   config DEV_DAX_PMEM_COMPAT
>   	tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
>   	depends on DEV_DAX_PMEM
> diff -puN /dev/null drivers/dax/kmem.c
> --- /dev/null	2018-12-03 08:41:47.355756491 -0800
> +++ b/drivers/dax/kmem.c	2019-01-08 09:54:44.056694874 -0800
> @@ -0,0 +1,93 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/* Copyright(c) 2016-2018 Intel Corporation. All rights reserved. */
> +#include <linux/memremap.h>
> +#include <linux/pagemap.h>
> +#include <linux/memory.h>
> +#include <linux/module.h>
> +#include <linux/device.h>
> +#include <linux/pfn_t.h>
> +#include <linux/slab.h>
> +#include <linux/dax.h>
> +#include <linux/fs.h>
> +#include <linux/mm.h>
> +#include <linux/mman.h>
> +#include "dax-private.h"
> +#include "bus.h"
> +
> +int dev_dax_kmem_probe(struct device *dev)
> +{
> +	struct dev_dax *dev_dax = to_dev_dax(dev);
> +	struct resource *res = &dev_dax->region->res;
> +	resource_size_t kmem_start;
> +	resource_size_t kmem_size;
> +	struct resource *new_res;
> +	int numa_node;
> +	int rc;
> +
> +	/* Hotplug starting at the beginning of the next block: */
> +	kmem_start = ALIGN(res->start, memory_block_size_bytes());
> +
> +	kmem_size = resource_size(res);
> +	/* Adjust the size down to compensate for moving up kmem_start: */
> +        kmem_size -= kmem_start - res->start;
> +	/* Align the size down to cover only complete blocks: */
> +	kmem_size &= ~(memory_block_size_bytes() - 1);
> +
> +	new_res = devm_request_mem_region(dev, kmem_start, kmem_size,
> +					  dev_name(dev));
> +
> +	if (!new_res) {
> +		printk("could not reserve region %016llx -> %016llx\n",
> +				kmem_start, kmem_start+kmem_size);
> +		return -EBUSY;
> +	}
> +
> +	/*
> +	 * Set flags appropriate for System RAM.  Leave ..._BUSY clear
> +	 * so that add_memory() can add a child resource.
> +	 */
> +	new_res->flags = IORESOURCE_SYSTEM_RAM;
> +	new_res->name = dev_name(dev);
> +
> +	numa_node = dev_dax->target_node;
> +	if (numa_node < 0) {
> +		pr_warn_once("bad numa_node: %d, forcing to 0\n", numa_node);
> +		numa_node = 0;
> +	}
> +
> +	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
I didn't try pmem and I am wondering it's slower than DRAM.
Should a flag, such like _GFP_PMEM, be added to distinguish it from
DRAM?

If it's used for DMA, perhaps it might not satisfy device DMA request on 
time?
