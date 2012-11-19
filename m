Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 080F66B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 11:52:48 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so747061dak.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 08:52:48 -0800 (PST)
Message-ID: <50AA63CE.9080700@gmail.com>
Date: Tue, 20 Nov 2012 00:52:30 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [ACPIHP PATCH part1 0/4] introduce a framework for ACPI based
 system device hotplug
References: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com> <6684049.OOiNLWpfRL@vostro.rjw.lan>
In-Reply-To: <6684049.OOiNLWpfRL@vostro.rjw.lan>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, "Wang, Frank" <frank.wang@intel.com>

On 11/16/2012 08:58 PM, Rafael J. Wysocki wrote:
> Hi,
> 
> On Sunday, November 04, 2012 12:07:41 AM Jiang Liu wrote:
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
>> 3) Provide interface to cancel ongoing hotplug operations. It may take
>>    a very long time to remove a memory device, so provide interface to
>>    cancel the inprogress hotplug operations.
>> 4) Support new advanced RAS features, such as socket/memory migration.
>> 5) Provide better user interfaces to access the hotplug functionalities.
>> 6) Provide a mechanism to detect hotplug slots by checking existence
>>    of ACPI _EJ0 method or by other hardware platform specific methods.
>> 7) Unify the way to enumerate ACPI based hotplug slots. All hotplug
>>    slots will be enumerated by the enumeration driver (acpihp_slot),
>>    instead of by individual ACPI device drivers.
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
>> And the whole patchset will be split into 7 parts:
>> 1) the hotplug slot enumeration driver (acpihp_slot)
>> 2) the system device hotplug driver (acpihp_drv)
>> 3) enhance ACPI container driver to support new framework
>> 4) enhance ACPI processor driver to support new framework
>> 5) enhance ACPI memory driver to support new framework
>> 6) enhance ACPI host bridge driver to support new framework
>> 7) enhancments and cleanups to the ACPI core
> 
> First of all, thanks for following my suggestion and splitting the patchset
> into smaller pieces.  It is appreciated.
> 
> That said, I still have a problem even with this small part of your original
> patchset, because I'm practically unable to assess its possible impact on
> future development at the moment.  At least not by myself.
> 
> My background is power management and I don't have much experience with
> the kind of systems your patchset is targeted at, so I'd need quite a lot
> of time to understand the details of your approach and all of the possible
> ways it may interfere with the other people's work in progress.  It may just
> be the best thing we can do for the use cases you are after, but we also may
> be able to address them in simpler ways (which would be better).  Adding new
> frameworks like this is not usual in the ACPI subsystem, so to speak, so my
> first question is if you considered any alternatives and if you did, then what
> they were and why you decided that they would be less suitable.
> 
> Moreover, as I'm sure you know, some groups have been working on features
> related to your patchset, like memory hotplug, CPU hotplug and PCI host bridge
> hotplug, and they have made some progress already.  I wonder, then, in what way
> your patchset is going to affect their work.  Is it simply going to make their
> lifes easier in all aspects, or (if applied) will it require them to redesign
> their code and redo some patchsets they already have tested and queued up
> for submission, or, worse yet, will it invalidate their work entirely?  I have
> no good answer to this question right now, so I'd like to here from these
> people what they think about your work.
We have noticed the great interests about system device hotplug in the community,
actually that's a good news for us because we could cooperate together to achieve
the goal.

We have deeply involved in the PCI host bridge hotplug work from Yinghai. We have
submitted some patches to Yinghai and Bjorn related to PCI host bridge, and we have
also integrated Yinghai's work with our new framework and tested it on IA64 and
Xeon platforms. We also have reached an agreement with Yinghai that the new framework
will integrate with the PCI host bridge hotplug work after the PCI part has been
upstreamed. And I think PCi host bridge hotplug work and new hotplug framework
are complementary.

For BSP hotplug from Fenghua, I think we could easily integrate it with the new
framework. We have also cooperated with Fujitsu about the memory hotplug core 
logic (not include the ACPI part), we have already submitted some patches, integrated
and tested some patches from Fujitsu. And we have also had an discussion with
Wen Congyang at China Linux Kernel Developer Forum last month about memory hotplug.
We also have a patchset to integrate memory hotplug with the new framework, but
it's still during internal review and tests.

But for the ACPI part for CPU and memory hotplug enhancements recently posted to
the community, I think they are different solutions with the new framework. I feel
they are lightweight enhancements to existing code with some limitations, but the
new framework is a heavyweight solution with full functionalities and improved
usability. So we may need discussions about the different solutions here:)

We have also noticed memory power management related work from 

> 
> Bjorn has already posted his comments and he seems to be skeptical.  His
> opinions are very important to me, because he has a lot of experience and
> knows things I'm not aware of.  This means, in particular, that I'll be
> extremely cautious about applying patches that he has objections against.
Yeah, we really appreciate comments from Bjorn, and he has profound experiences
in may areas.

> 
> You also need to be aware of the fact that some core kernel developers have
> long-term goals.  They need not be very precisely defined plans, but just
> things those developers would like to achieve at one point in the future.  My
> personal goal is to unify the handling of devices by the ACPI subsystem, as
> outlined in this message to Yinghai:
> 
> http://marc.info/?l=linux-kernel&m=135180467616074&w=4
The idea is great to consolidate ACPI and IO device nodes. It will difinitely
help the IOAPIC driver used in PCI host bridge hotplug because anIOAPIC may be
an ACPI and/or PCI device.

It's a great idea to consolidate ACPI driver with native device driver for
IO devices. But there may be some difference for system devices because system
devices are mostly managed in platform dependent ways. For example, cpu and memory
driver under drivers/base/ only implement platform independent functionalities,
and we even have no platform independent driver for PCI host bridges. That means
we still need special handling for system devices in platform dependent way within
the ACPI world.

If we still have some forms of "ACPI drivers" for system devices, it will be ok
for the new hotplug framework even if we remove the "struct device dev" from 
"struct acpi_device". The change for the hotplug framework to support your new
ACPI OS adapter layer shouldn't be too large.

> 
> Unfortunately, I can't really say at this point how your patches, if applied,
> will affect this goal (most likely they will make it more difficult to achieve,
> it seems) and I know, for example, that the driver core people have some goals
> that may be affected by it too (for example, adding new device classes is not
> recommended).  That needs to be determined.
The reason for device class instead of bus driver is just for simplicity. 
If appreciated, we could change the class driver into a bus driver.

> 
> Last, but not least, core kernel developers are extremely cautious about adding
> new user space interfaces, because doing that is a long-term commitment to
> support them and maintain their compatibility with the previous versions.  This
> sometimes turns out to be particularly painful, especially if such "old"
> interfaces are not suitable for some "new" use cases.  Therefore, every time
> somebody wants to add a new sysfs file, for example, we want to know whether
> or not this is really necessary/useful and we need to figure out whether or not
> the interface being added is the best one for the given use case (and possibly
> for other related use cases, including future ones that can be anticipated).
> Your patchset seems to add a number of these and they aren't sufficiently
> documented, so it is quite difficult to do that.
Yeah, we will enhance the documentations. 

> 
> As for more specific comments, I'd like the changelog of [1/4] to describe
> what this particular patch is doing and why it is doing that instead of just
> repeating the [0/4] message in its greater part, which isn't very useful.
> Also, I'd like sysfs interfaces to be documented in the usual way (i.e. in
> Documentation/ABI/) and all functions that are not static to have kerneldoc
> comments explaining the meaning of their arguments and describing what the
> functions are for (in general terms).  [It wouldn't really hurt if at least
> the more important static functions had kerneldoc comments too.]  New data
> types, if any, need to be described in comments too (what they are for in
> general as well as their individual fields).  It also would be good to have
> a general document describing they way the framework is supposed to work under
> Documentation/acpi.
Thanks for reminder, we will enhance these documentations once we have settled
down about the overall idea and design.

Thanks!
Gerry

> 
> Thanks,
> Rafael
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
