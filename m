Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 3C2ED6B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 16:30:48 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id dq12so3598901wgb.26
        for <linux-mm@kvack.org>; Mon, 05 Nov 2012 13:30:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1351958865-24394-3-git-send-email-jiang.liu@huawei.com>
References: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com> <1351958865-24394-3-git-send-email-jiang.liu@huawei.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 5 Nov 2012 14:30:25 -0700
Message-ID: <CAErSpo49kJm3x2K_FT6vLpUUD2pk9Hf62uXqzHt2Vod2PriY8Q@mail.gmail.com>
Subject: Re: [ACPIHP PATCH part1 2/4] ACPIHP: introduce acpihp_slot driver to
 enumerate hotplug slots
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Gaohuai Han <hangaohuai@huawei.com>

On Sat, Nov 3, 2012 at 10:07 AM, Jiang Liu <liuj97@gmail.com> wrote:
> An ACPI hotplug slot is an abstraction of receptacles, where a group of
> system devices could be connected to. This patch implements the skeleton
> of the ACPI system device hotplug slot enumerator. On loading, it scans
> the whole ACPI namespace for hotplug slots and creates a device node for
> each hotplug slot found. Every hotplug slot is associated with a device
> class named acpihp_slot_class. Later hotplug drivers will register onto
> acpihp_slot_class to manage all hotplug slots.
>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Signed-off-by: Gaohuai Han <hangaohuai@huawei.com>
> ---
>  drivers/acpi/Kconfig          |   19 ++
>  drivers/acpi/hotplug/Makefile |    3 +
>  drivers/acpi/hotplug/slot.c   |  417 +++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 439 insertions(+)
>  create mode 100644 drivers/acpi/hotplug/slot.c
>
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index 9577b23..af0aaf6 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -334,6 +334,25 @@ menuconfig ACPI_HOTPLUG
>           If your hardware platform does not support system device dynamic
>           reconfiguration at runtime, you need not to enable this option.
>
> +config ACPI_HOTPLUG_SLOT
> +       tristate "System Device Hotplug Slot Enumerator"

I don't really believe in hotplug drivers being modules.  I think the
core should support hotplug directly, and the decision to configure or
not should be made at build-time.

> +       depends on ACPI_HOTPLUG
> +       default m
> +       help
> +         ACPI system device hotplug slot is an abstraction of ACPI based
> +         system device dynamic reconfiguration control points. On load,
> +         this driver enumerates system device hotplug slots by wakling the
> +         ACPI namespace and provides platform specific methods to control
> +         those hotplug slots.
> +
> +         By default, this driver detects system device hotplug slots by
> +         checking avaliability of ACPI _EJ0 method. You may pass a module
> +         parameter "fake_slot=0xf" to enable faking hotplug slots on
> +         platforms without hardware dynamic reconfiguration capabilities.
> +
> +         To compile this driver as a module, choose M here:
> +         the module will be called acpihp_slot.
> +

> +static int __init acpihp_slot_generate_name(struct acpihp_slot *slot)
> +{
> +       int found = 0;
> +       u32 child_types = 0;
> +       unsigned long long uid;
> +       struct acpihp_slot_id *slot_id;
> +
> +       /*
> +        * Figure out slot type by checking types of ACPI devices which could
> +        * be attached to the slot.
> +        */
> +       slot->type = acpihp_slot_get_type_self(slot);
> +       if (slot->type == ACPIHP_SLOT_TYPE_UNKNOWN) {
> +               acpi_walk_namespace(ACPI_TYPE_DEVICE, slot->handle,
> +                               ACPI_UINT32_MAX, acpihp_slot_get_dev_type,
> +                               NULL, NULL, (void **)&child_types);
> +               acpi_walk_namespace(ACPI_TYPE_PROCESSOR, slot->handle,
> +                               ACPI_UINT32_MAX, acpihp_slot_get_dev_type,
> +                               NULL, NULL, (void **)&child_types);
> +               slot->type = acpihp_slot_get_type_child(child_types);
> +       }

If things can be hot-added below slot->handle, is there an ACPI
requirement that there be *anything* in the existing namespace below
slot->handle?  I'm not sure you can tell sort of things might be
added.

> +static int __init acpihp_slot_scan_slots(void)
> +{
> +       acpi_status status;
> +
> +       status = acpi_walk_namespace(ACPI_TYPE_DEVICE, ACPI_ROOT_OBJECT,
> +                                    ACPI_UINT32_MAX, acpihp_slot_scan,
> +                                    NULL, NULL, NULL);
> +       if (!ACPI_SUCCESS(status))
> +               goto out_err;
> +
> +       status = acpi_walk_namespace(ACPI_TYPE_PROCESSOR, ACPI_ROOT_OBJECT,
> +                                    ACPI_UINT32_MAX, acpihp_slot_scan,
> +                                    NULL, NULL, NULL);

Here's one reason I don't like this as a module: we have to walk the
namespace again (twice, even).  What happens when you hot-add a node
that itself *contains* another hot-pluggable receptacle?  Do you walk
the namespace again, calling acpiphp_slot_scan() as needed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
