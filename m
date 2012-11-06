Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 285386B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 11:18:16 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so292340dad.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 08:18:15 -0800 (PST)
Message-ID: <5099383F.3010905@gmail.com>
Date: Wed, 07 Nov 2012 00:18:07 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [ACPIHP PATCH part1 1/4] ACPIHP: introduce a framework for ACPI
 based system device hotplug
References: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com> <1351958865-24394-2-git-send-email-jiang.liu@huawei.com> <CAErSpo6RQk+sdeOF7c+G2qp5iYgrnQcx+rD0f8eVNRPLRoLpdg@mail.gmail.com>
In-Reply-To: <CAErSpo6RQk+sdeOF7c+G2qp5iYgrnQcx+rD0f8eVNRPLRoLpdg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Gaohuai Han <hangaohuai@huawei.com>

Hi Bjorn,
	Thanks for your review and please refer to inlined comments below.

On 11/06/2012 05:05 AM, Bjorn Helgaas wrote:
> On Sat, Nov 3, 2012 at 10:07 AM, Jiang Liu <liuj97@gmail.com> wrote:
>> Modern high-end servers may support advanced RAS features, such as
>> system device dynamic reconfiguration. On x86 and IA64 platforms,
>> system device means processor(CPU), memory device, PCI host bridge
>> and even computer node.
>>
>> The ACPI specifications have provided standard interfaces between
>> firmware and OS to support device dynamic reconfiguraiton at runtime.
>> This patch series introduces a new framework for system device
>> dynamic reconfiguration based on ACPI specification, which will
>> replace current existing system device hotplug logic embedded in
>> ACPI processor/memory/container device drivers.
>>
>> The new ACPI based hotplug framework is modelled after the PCI hotplug
>> architecture and target to achieve following goals:
>> 1) Optimize device configuration order to achieve best performance for
>>    hot-added system devices. For best perforamnce, system device should
>>    be configured in order of memory -> CPU -> IOAPIC/IOMMU -> PCI HB.
>> 2) Resolve dependencies among hotplug slots. You need first to remove
>>    the memory device before removing a physical processor if a
>>    hotpluggable memory device is connected to a hotpluggable physical
>>    processor.
> 
> Doesn't the namespace already have a way to communicate these dependencies?
The namespace could could resolve most dependency issues, but there are still
several corner cases need special care.
1) On a typical Intel Nehalem/Westmere platform, an IOH will be connected to
two physical processors through QPI. The IOH depends on the two processors.
And the ACPI namespace is something like:
/_SB
    |_SCK0
    |_SCK1
    |_PCI1
2) For a large system composed up of multiple computer nodes, nodes may have
dependency on neighbors due to interconnect topology constraints.

So we need to resolve dependency by both evaluating _EDL and analyze ACPI
namespace topology.

>> 3) Provide interface to cancel ongoing hotplug operations. It may take
>>    a very long time to remove a memory device, so provide interface to
>>    cancel the inprogress hotplug operations.
>> 4) Support new advanced RAS features, such as socket/memory migration.
>> 5) Provide better user interfaces to access the hotplug functionalities.
>> 6) Provide a mechanism to detect hotplug slots by checking existence
>>    of ACPI _EJ0 method or by other hardware platform specific methods.
> 
> I don't know what "hotplug slot" means for ACPI.  ACPI allows hotplug
> of arbitrary devices in the namespace, whether they have EJ0 or not.
Here "hotplug" slot is an abstraction of receptacles where a group of
system devices could be attached to, or where we could control a group
of system devices. It's totally conceptual, may or may not has 
corresponding physical slots. For example,
1) a hotplug slot for a hotpluggable memory board has a physical slot.
2) a hotplug slot for a non-hotpluggable processor with power control
capability has no physical slot. (That means you may power on/off a
physical processor but can't hotplug it at runtime). This case is useful
for hardware partitioning.

Detecting hotplug slots by checking existence of _EJ0 is the default
but unreliable way. For a real high-end server with system device
hotplug capabilities should provide some static ACPI table to describe
hotplug slots/capabilities. There are some ongoing efforts for that from
Intel, but not in the public domain yet. So the hotplug slot enumeration
driver is designed to extensible:)

>> 7) Unify the way to enumerate ACPI based hotplug slots. All hotplug
>>    slots will be enumerated by the enumeration driver (acpihp_slot),
>>    instead of by individual ACPI device drivers.
> 
> Why do we need to enumerate these "slots" specifically?
> 
> I think this patch adds things in /sys.  It might help if you
> described what they are.
There's no standard way in ACPI5.0 to describe system device hotplug slots yet.
And we want to show user the system device hotplug capabilities even when there
is no device attached to a slot. In other word, user could now how much
devices they could connect to the system by hotplugging.

>> 8) Unify the way to handle ACPI hotplug events. All ACPI hotplug events
>>    for system devices will be handled by a generic ACPI hotplug driver
>>    (acpihp_drv) instead of by individual ACPI device drivers.
>> 9) Provide better error handling and error recovery.
>> 10) Trigger hotplug events/operations by software. This feature is useful
>>    for hardware fault management and/or power saving.
>>
>> The new framework is composed up of three major components:
>> 1) A system device hotplug slot enumerator driver, which enumerates
>>    hotplug slots in the system and provides platform specific methods
>>    to control those slots.
>> 2) A system device hotplug driver, which is a platform independent
>>    driver to manage all hotplug slots created by the slot enumerator.
>>    The hotplug driver implements a state machine for hotplug slots and
>>    provides user interfaces to manage hotplug slots.
>> 3) Several ACPI device drivers to configure/unconfigure system devices
>>    at runtime.
>>
>> To get rid of inter dependengcy between the slot enumerator and hotplug
>> driver, common code shared by them will be built into the kernel. The
>> shared code provides some helper routines and a device class named
>> acpihp_slot_class with following default sysfs properties:
>>         capabilities: RAS capabilities of the hotplug slot
>>         state: current state of the hotplug slot state machine
>>         status: current health status of the hotplug slot
>>         object: ACPI object corresponding to the hotplug slot
>>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> Signed-off-by: Gaohuai Han <hangaohuai@huawei.com>
> 
> ...
>> +static char *acpihp_dev_mem_ids[] = {
>> +       "PNP0C80",
>> +       NULL
>> +};
>> +
>> +static char *acpihp_dev_pcihb_ids[] = {
>> +       "PNP0A03",
>> +       NULL
>> +};
> 
> Why should this driver need to know about these PNP IDs?  We ought to
> be able to support hotplug of any device in the namespace, no matter
> what its ID.
We need PNP IDs for:
1) Give a meaningful name for each slot.
lrwxrwxrwx  CPU00 -> ../../../devices/LNXSYSTM:00/acpihp/CPU00
lrwxrwxrwx  CPU01 -> ../../../devices/LNXSYSTM:00/acpihp/CPU01
lrwxrwxrwx  CPU02 -> ../../../devices/LNXSYSTM:00/acpihp/CPU02
lrwxrwxrwx  CPU03 -> ../../../devices/LNXSYSTM:00/acpihp/CPU03
lrwxrwxrwx  IOX01 -> ../../../devices/LNXSYSTM:00/acpihp/IOX01
lrwxrwxrwx  MEM00 -> ../../../devices/LNXSYSTM:00/acpihp/CPU00/MEM00
lrwxrwxrwx  MEM01 -> ../../../devices/LNXSYSTM:00/acpihp/CPU00/MEM01
lrwxrwxrwx  MEM02 -> ../../../devices/LNXSYSTM:00/acpihp/CPU01/MEM02
lrwxrwxrwx  MEM03 -> ../../../devices/LNXSYSTM:00/acpihp/CPU01/MEM03
lrwxrwxrwx  MEM04 -> ../../../devices/LNXSYSTM:00/acpihp/CPU02/MEM04
lrwxrwxrwx  MEM05 -> ../../../devices/LNXSYSTM:00/acpihp/CPU02/MEM05
lrwxrwxrwx  MEM06 -> ../../../devices/LNXSYSTM:00/acpihp/CPU03/MEM06
lrwxrwxrwx  MEM07 -> ../../../devices/LNXSYSTM:00/acpihp/CPU03/MEM07

2) Classify system device into groups according to device types, so we could
configure/unconfigure them in optimal order for performance as:
memory -> CPU -> IOAPIC -> PCI host bridge

3) The new hotplug framework are designed to handle system device hotplug,
and it won't hand IO device hotplug such as PCI etc. So it need to stop
scanning subtree of PCI host bridges.

Thanks!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
