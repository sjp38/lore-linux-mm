Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5528E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:16:32 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id v16so3579572wru.8
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:16:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z8sor54789122wrh.0.2019.01.16.13.16.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 13:16:30 -0800 (PST)
MIME-Version: 1.0
References: <20190116181859.D1504459@viggo.jf.intel.com> <20190116181905.12E102B4@viggo.jf.intel.com>
In-Reply-To: <20190116181905.12E102B4@viggo.jf.intel.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 16 Jan 2019 15:16:16 -0600
Message-ID: <CAErSpo55j7odYf-B-KSoogabD9Qqt605oUGYe6td9wZdYNq_Hg@mail.gmail.com>
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal RAM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: dave@sr71.net, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>

On Wed, Jan 16, 2019 at 12:25 PM Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> Currently, a persistent memory region is "owned" by a device driver,
> either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
> allow applications to explicitly use persistent memory, generally
> by being modified to use special, new libraries.

Is there any documentation about exactly what persistent memory is?
In Documentation/, I see references to pstore and pmem, which sound
sort of similar, but maybe not quite the same?

> However, this limits persistent memory use to applications which
> *have* been modified.  To make it more broadly usable, this driver
> "hotplugs" memory into the kernel, to be managed ad used just like
> normal RAM would be.

s/ad/and/

> To make this work, management software must remove the device from
> being controlled by the "Device DAX" infrastructure:
>
>         echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
>         echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
>
> and then bind it to this new driver:
>
>         echo -n dax0.0 > /sys/bus/dax/drivers/kmem/new_id
>         echo -n dax0.0 > /sys/bus/dax/drivers/kmem/bind
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
>  b/drivers/dax/Kconfig  |    5 ++
>  b/drivers/dax/Makefile |    1
>  b/drivers/dax/kmem.c   |   93 +++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 99 insertions(+)
>
> diff -puN drivers/dax/Kconfig~dax-kmem-try-4 drivers/dax/Kconfig
> --- a/drivers/dax/Kconfig~dax-kmem-try-4        2019-01-08 09:54:44.051694874 -0800
> +++ b/drivers/dax/Kconfig       2019-01-08 09:54:44.056694874 -0800
> @@ -32,6 +32,11 @@ config DEV_DAX_PMEM
>
>           Say M if unsure
>
> +config DEV_DAX_KMEM
> +       def_bool y

Is "y" the right default here?  I periodically see Linus complain
about new things defaulting to "on", but I admit I haven't paid enough
attention to know whether that would apply here.

> +       depends on DEV_DAX_PMEM   # Needs DEV_DAX_PMEM infrastructure
> +       depends on MEMORY_HOTPLUG # for add_memory() and friends
> +
>  config DEV_DAX_PMEM_COMPAT
>         tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
>         depends on DEV_DAX_PMEM
> diff -puN /dev/null drivers/dax/kmem.c
> --- /dev/null   2018-12-03 08:41:47.355756491 -0800
> +++ b/drivers/dax/kmem.c        2019-01-08 09:54:44.056694874 -0800
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
> +       struct dev_dax *dev_dax = to_dev_dax(dev);
> +       struct resource *res = &dev_dax->region->res;
> +       resource_size_t kmem_start;
> +       resource_size_t kmem_size;
> +       struct resource *new_res;
> +       int numa_node;
> +       int rc;
> +
> +       /* Hotplug starting at the beginning of the next block: */
> +       kmem_start = ALIGN(res->start, memory_block_size_bytes());
> +
> +       kmem_size = resource_size(res);
> +       /* Adjust the size down to compensate for moving up kmem_start: */
> +        kmem_size -= kmem_start - res->start;
> +       /* Align the size down to cover only complete blocks: */
> +       kmem_size &= ~(memory_block_size_bytes() - 1);
> +
> +       new_res = devm_request_mem_region(dev, kmem_start, kmem_size,
> +                                         dev_name(dev));
> +
> +       if (!new_res) {
> +               printk("could not reserve region %016llx -> %016llx\n",
> +                               kmem_start, kmem_start+kmem_size);

1) It'd be nice to have some sort of module tag in the output that
ties it to this driver.

2) It might be nice to print the range in the same format as %pR,
i.e., "[mem %#010x-%#010x]" with the end included (start + size -1 ).

> +               return -EBUSY;
> +       }
> +
> +       /*
> +        * Set flags appropriate for System RAM.  Leave ..._BUSY clear
> +        * so that add_memory() can add a child resource.
> +        */
> +       new_res->flags = IORESOURCE_SYSTEM_RAM;

IIUC, new_res->flags was set to "IORESOURCE_MEM | ..." in the
devm_request_mem_region() path.  I think you should keep at least
IORESOURCE_MEM so the iomem_resource tree stays consistent.

> +       new_res->name = dev_name(dev);
> +
> +       numa_node = dev_dax->target_node;
> +       if (numa_node < 0) {
> +               pr_warn_once("bad numa_node: %d, forcing to 0\n", numa_node);

It'd be nice to again have a module tag and an indication of what
range is affected, e.g., %pR of new_res.

You don't save the new_res pointer anywhere, which I guess you intend
for now since there's no remove or anything else to do with this
resource?  I thought maybe devm_request_mem_region() would implicitly
save it, but it doesn't; it only saves the parent (iomem_resource, the
start (kmem_start), and the size (kmem_size)).

> +               numa_node = 0;
> +       }
> +
> +       rc = add_memory(numa_node, new_res->start, resource_size(new_res));
> +       if (rc)
> +               return rc;
> +
> +       return 0;

Doesn't this mean "return rc" or even just "return add_memory(...)"?

> +}
> +EXPORT_SYMBOL_GPL(dev_dax_kmem_probe);
> +
> +static int dev_dax_kmem_remove(struct device *dev)
> +{
> +       /* Assume that hot-remove will fail for now */
> +       return -EBUSY;
> +}
> +
> +static struct dax_device_driver device_dax_kmem_driver = {
> +       .drv = {
> +               .probe = dev_dax_kmem_probe,
> +               .remove = dev_dax_kmem_remove,
> +       },
> +};
> +
> +static int __init dax_kmem_init(void)
> +{
> +       return dax_driver_register(&device_dax_kmem_driver);
> +}
> +
> +static void __exit dax_kmem_exit(void)
> +{
> +       dax_driver_unregister(&device_dax_kmem_driver);
> +}
> +
> +MODULE_AUTHOR("Intel Corporation");
> +MODULE_LICENSE("GPL v2");
> +module_init(dax_kmem_init);
> +module_exit(dax_kmem_exit);
> +MODULE_ALIAS_DAX_DEVICE(0);
> diff -puN drivers/dax/Makefile~dax-kmem-try-4 drivers/dax/Makefile
> --- a/drivers/dax/Makefile~dax-kmem-try-4       2019-01-08 09:54:44.053694874 -0800
> +++ b/drivers/dax/Makefile      2019-01-08 09:54:44.056694874 -0800
> @@ -1,6 +1,7 @@
>  # SPDX-License-Identifier: GPL-2.0
>  obj-$(CONFIG_DAX) += dax.o
>  obj-$(CONFIG_DEV_DAX) += device_dax.o
> +obj-$(CONFIG_DEV_DAX_KMEM) += kmem.o
>
>  dax-y := super.o
>  dax-y += bus.o
> _
