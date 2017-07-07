Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1918A6B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 01:53:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a2so24224744pgn.15
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 22:53:42 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id r7si1681880plj.437.2017.07.06.22.53.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 22:53:41 -0700 (PDT)
Subject: Re: [RFC v2 3/5] hmem: add heterogeneous memory sysfs support
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
 <20170706215233.11329-4-ross.zwisler@linux.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9ea40a37-3549-2294-8605-036b37aec023@nvidia.com>
Date: Thu, 6 Jul 2017 22:53:39 -0700
MIME-Version: 1.0
In-Reply-To: <20170706215233.11329-4-ross.zwisler@linux.intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jerome Glisse <jglisse@redhat.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On 07/06/2017 02:52 PM, Ross Zwisler wrote:
[...]
> diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
> index b1aacfc..31e3f20 100644
> --- a/drivers/acpi/Makefile
> +++ b/drivers/acpi/Makefile
> @@ -72,6 +72,7 @@ obj-$(CONFIG_ACPI_PROCESSOR)	+= processor.o
>  obj-$(CONFIG_ACPI)		+= container.o
>  obj-$(CONFIG_ACPI_THERMAL)	+= thermal.o
>  obj-$(CONFIG_ACPI_NFIT)		+= nfit/
> +obj-$(CONFIG_ACPI_HMEM)		+= hmem/
>  obj-$(CONFIG_ACPI)		+= acpi_memhotplug.o
>  obj-$(CONFIG_ACPI_HOTPLUG_IOAPIC) += ioapic.o
>  obj-$(CONFIG_ACPI_BATTERY)	+= battery.o

Hi Ross,

Following are a series of suggestions, intended to clarify naming just
enough so that, when Jerome's HMM patchset lands, we'll be able to
tell the difference between the two types of Heterogeneous Memory.


> diff --git a/drivers/acpi/hmem/Kconfig b/drivers/acpi/hmem/Kconfig
> new file mode 100644
> index 0000000..09282be
> --- /dev/null
> +++ b/drivers/acpi/hmem/Kconfig
> @@ -0,0 +1,7 @@
> +config ACPI_HMEM
> +	bool "ACPI Heterogeneous Memory Support"

How about:

   bool "ACPI Heterogeneous Memory Attribute Table Support"

The idea here, and throughout, is that this type of 
Heterogeneous Memory support is all about "the Heterogeneous Memory
that you found via ACPI's Heterogeneous Memory Attribute Table".

That's different from "the Heterogeneous Memory that you found
when you installed a PCIe device that supports HMM". Or, at least
it is different, until the day that someone decides to burn in
support for an HMM device, into the ACPI tables. Seems unlikely,
though. :) And even so, I think it would still work.


> +	depends on ACPI_NUMA
> +	depends on SYSFS
> +	help
> +	  Exports a sysfs representation of the ACPI Heterogeneous Memory
> +	  Attributes Table (HMAT).
> diff --git a/drivers/acpi/hmem/Makefile b/drivers/acpi/hmem/Makefile
> new file mode 100644
> index 0000000..d2aa546
> --- /dev/null
> +++ b/drivers/acpi/hmem/Makefile
> @@ -0,0 +1,2 @@
> +obj-$(CONFIG_ACPI_HMEM) := hmem.o
> +hmem-y := core.o initiator.o target.o
> diff --git a/drivers/acpi/hmem/core.c b/drivers/acpi/hmem/core.c
> new file mode 100644
> index 0000000..f7638db
> --- /dev/null
> +++ b/drivers/acpi/hmem/core.c
> @@ -0,0 +1,569 @@
> +/*
> + * Heterogeneous memory representation in sysfs

Heterogeneous memory, as discovered via ACPI's Heterogeneous Memory
Attribute Table: representation in sysfs

> + *
> + * Copyright (c) 2017, Intel Corporation.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + */
> +
> +#include <acpi/acpi_numa.h>

[...]

> diff --git a/drivers/acpi/hmem/hmem.h b/drivers/acpi/hmem/hmem.h
> new file mode 100644
> index 0000000..38ff540
> --- /dev/null
> +++ b/drivers/acpi/hmem/hmem.h
> @@ -0,0 +1,47 @@
> +/*
> + * Heterogeneous memory representation in sysfs

Heterogeneous memory, as discovered via ACPI's Heterogeneous Memory
Attribute Table: representation in sysfs

> + *
> + * Copyright (c) 2017, Intel Corporation.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + */
> +
> +#ifndef _ACPI_HMEM_H_
> +#define _ACPI_HMEM_H_
> +
> +struct memory_initiator {
> +	struct list_head list;
> +	struct device dev;
> +
> +	/* only one of the following three will be set */
> +	struct acpi_srat_cpu_affinity *cpu;
> +	struct acpi_srat_x2apic_cpu_affinity *x2apic;
> +	struct acpi_srat_gicc_affinity *gicc;
> +
> +	int pxm;
> +	bool is_registered;
> +};
> +#define to_memory_initiator(d) container_of((d), struct memory_initiator, dev)
> +
> +struct memory_target {
> +	struct list_head list;
> +	struct device dev;
> +	struct acpi_srat_mem_affinity *ma;
> +	struct acpi_hmat_address_range *spa;
> +	struct memory_initiator *local_init;
> +
> +	bool is_cached;
> +	bool is_registered;
> +};
> +#define to_memory_target(d) container_of((d), struct memory_target, dev)
> +
> +extern const struct attribute_group *memory_initiator_attribute_groups[];
> +extern const struct attribute_group *memory_target_attribute_groups[];
> +#endif /* _ACPI_HMEM_H_ */
> diff --git a/drivers/acpi/hmem/initiator.c b/drivers/acpi/hmem/initiator.c
> new file mode 100644
> index 0000000..905f030
> --- /dev/null
> +++ b/drivers/acpi/hmem/initiator.c
> @@ -0,0 +1,61 @@
> +/*
> + * Heterogeneous memory initiator sysfs attributes

HMAT (Heterogeneous Memory Attribute Table)-based memory: initiator sysfs attributes

> + *
> + * Copyright (c) 2017, Intel Corporation.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + */
> +
> +#include <acpi/acpi_numa.h>
> +#include <linux/acpi.h>
> +#include <linux/device.h>
> +#include <linux/sysfs.h>
> +#include "hmem.h"
> +
> +static ssize_t firmware_id_show(struct device *dev,
> +			struct device_attribute *attr, char *buf)
> +{
> +	struct memory_initiator *init = to_memory_initiator(dev);
> +
> +	return sprintf(buf, "%d\n", init->pxm);
> +}
> +static DEVICE_ATTR_RO(firmware_id);
> +
> +static ssize_t is_enabled_show(struct device *dev,
> +		struct device_attribute *attr, char *buf)
> +{
> +	struct memory_initiator *init = to_memory_initiator(dev);
> +	int is_enabled;
> +
> +	if (init->cpu)
> +		is_enabled = !!(init->cpu->flags & ACPI_SRAT_CPU_ENABLED);
> +	else if (init->x2apic)
> +		is_enabled = !!(init->x2apic->flags & ACPI_SRAT_CPU_ENABLED);
> +	else
> +		is_enabled = !!(init->gicc->flags & ACPI_SRAT_GICC_ENABLED);
> +
> +	return sprintf(buf, "%d\n", is_enabled);
> +}
> +static DEVICE_ATTR_RO(is_enabled);
> +
> +static struct attribute *memory_initiator_attributes[] = {
> +	&dev_attr_firmware_id.attr,
> +	&dev_attr_is_enabled.attr,
> +	NULL,
> +};
> +
> +static struct attribute_group memory_initiator_attribute_group = {
> +	.attrs = memory_initiator_attributes,
> +};
> +
> +const struct attribute_group *memory_initiator_attribute_groups[] = {
> +	&memory_initiator_attribute_group,
> +	NULL,
> +};
> diff --git a/drivers/acpi/hmem/target.c b/drivers/acpi/hmem/target.c
> new file mode 100644
> index 0000000..dd57437
> --- /dev/null
> +++ b/drivers/acpi/hmem/target.c
> @@ -0,0 +1,97 @@
> +/*
> + * Heterogeneous memory target sysfs attributes

HMAT (Heterogeneous Memory Attribute Table)-based memory: target sysfs attributes

So, maybe those will help.

thanks
john h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
