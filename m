Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id D94A46B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 16:05:47 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hq7so2803539wib.8
        for <linux-mm@kvack.org>; Mon, 05 Nov 2012 13:05:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1351958865-24394-2-git-send-email-jiang.liu@huawei.com>
References: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com> <1351958865-24394-2-git-send-email-jiang.liu@huawei.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 5 Nov 2012 14:05:24 -0700
Message-ID: <CAErSpo6RQk+sdeOF7c+G2qp5iYgrnQcx+rD0f8eVNRPLRoLpdg@mail.gmail.com>
Subject: Re: [ACPIHP PATCH part1 1/4] ACPIHP: introduce a framework for ACPI
 based system device hotplug
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Gaohuai Han <hangaohuai@huawei.com>

On Sat, Nov 3, 2012 at 10:07 AM, Jiang Liu <liuj97@gmail.com> wrote:
> Modern high-end servers may support advanced RAS features, such as
> system device dynamic reconfiguration. On x86 and IA64 platforms,
> system device means processor(CPU), memory device, PCI host bridge
> and even computer node.
>
> The ACPI specifications have provided standard interfaces between
> firmware and OS to support device dynamic reconfiguraiton at runtime.
> This patch series introduces a new framework for system device
> dynamic reconfiguration based on ACPI specification, which will
> replace current existing system device hotplug logic embedded in
> ACPI processor/memory/container device drivers.
>
> The new ACPI based hotplug framework is modelled after the PCI hotplug
> architecture and target to achieve following goals:
> 1) Optimize device configuration order to achieve best performance for
>    hot-added system devices. For best perforamnce, system device should
>    be configured in order of memory -> CPU -> IOAPIC/IOMMU -> PCI HB.
> 2) Resolve dependencies among hotplug slots. You need first to remove
>    the memory device before removing a physical processor if a
>    hotpluggable memory device is connected to a hotpluggable physical
>    processor.

Doesn't the namespace already have a way to communicate these dependencies?

> 3) Provide interface to cancel ongoing hotplug operations. It may take
>    a very long time to remove a memory device, so provide interface to
>    cancel the inprogress hotplug operations.
> 4) Support new advanced RAS features, such as socket/memory migration.
> 5) Provide better user interfaces to access the hotplug functionalities.
> 6) Provide a mechanism to detect hotplug slots by checking existence
>    of ACPI _EJ0 method or by other hardware platform specific methods.

I don't know what "hotplug slot" means for ACPI.  ACPI allows hotplug
of arbitrary devices in the namespace, whether they have EJ0 or not.

> 7) Unify the way to enumerate ACPI based hotplug slots. All hotplug
>    slots will be enumerated by the enumeration driver (acpihp_slot),
>    instead of by individual ACPI device drivers.

Why do we need to enumerate these "slots" specifically?

I think this patch adds things in /sys.  It might help if you
described what they are.

> 8) Unify the way to handle ACPI hotplug events. All ACPI hotplug events
>    for system devices will be handled by a generic ACPI hotplug driver
>    (acpihp_drv) instead of by individual ACPI device drivers.
> 9) Provide better error handling and error recovery.
> 10) Trigger hotplug events/operations by software. This feature is useful
>    for hardware fault management and/or power saving.
>
> The new framework is composed up of three major components:
> 1) A system device hotplug slot enumerator driver, which enumerates
>    hotplug slots in the system and provides platform specific methods
>    to control those slots.
> 2) A system device hotplug driver, which is a platform independent
>    driver to manage all hotplug slots created by the slot enumerator.
>    The hotplug driver implements a state machine for hotplug slots and
>    provides user interfaces to manage hotplug slots.
> 3) Several ACPI device drivers to configure/unconfigure system devices
>    at runtime.
>
> To get rid of inter dependengcy between the slot enumerator and hotplug
> driver, common code shared by them will be built into the kernel. The
> shared code provides some helper routines and a device class named
> acpihp_slot_class with following default sysfs properties:
>         capabilities: RAS capabilities of the hotplug slot
>         state: current state of the hotplug slot state machine
>         status: current health status of the hotplug slot
>         object: ACPI object corresponding to the hotplug slot
>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Signed-off-by: Gaohuai Han <hangaohuai@huawei.com>

...
> +static char *acpihp_dev_mem_ids[] = {
> +       "PNP0C80",
> +       NULL
> +};
> +
> +static char *acpihp_dev_pcihb_ids[] = {
> +       "PNP0A03",
> +       NULL
> +};

Why should this driver need to know about these PNP IDs?  We ought to
be able to support hotplug of any device in the namespace, no matter
what its ID.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
