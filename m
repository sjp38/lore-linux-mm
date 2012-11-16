Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 30E8C6B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 07:53:54 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [ACPIHP PATCH part1 0/4] introduce a framework for ACPI based system device hotplug
Date: Fri, 16 Nov 2012 13:58:16 +0100
Message-ID: <6684049.OOiNLWpfRL@vostro.rjw.lan>
In-Reply-To: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com>
References: <1351958865-24394-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, "Wang, Frank" <frank.wang@intel.com>

Hi,

On Sunday, November 04, 2012 12:07:41 AM Jiang Liu wrote:
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
> 3) Provide interface to cancel ongoing hotplug operations. It may take
>    a very long time to remove a memory device, so provide interface to
>    cancel the inprogress hotplug operations.
> 4) Support new advanced RAS features, such as socket/memory migration.
> 5) Provide better user interfaces to access the hotplug functionalities.
> 6) Provide a mechanism to detect hotplug slots by checking existence
>    of ACPI _EJ0 method or by other hardware platform specific methods.
> 7) Unify the way to enumerate ACPI based hotplug slots. All hotplug
>    slots will be enumerated by the enumeration driver (acpihp_slot),
>    instead of by individual ACPI device drivers.
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
> And the whole patchset will be split into 7 parts:
> 1) the hotplug slot enumeration driver (acpihp_slot)
> 2) the system device hotplug driver (acpihp_drv)
> 3) enhance ACPI container driver to support new framework
> 4) enhance ACPI processor driver to support new framework
> 5) enhance ACPI memory driver to support new framework
> 6) enhance ACPI host bridge driver to support new framework
> 7) enhancments and cleanups to the ACPI core

First of all, thanks for following my suggestion and splitting the patchset
into smaller pieces.  It is appreciated.

That said, I still have a problem even with this small part of your original
patchset, because I'm practically unable to assess its possible impact on
future development at the moment.  At least not by myself.

My background is power management and I don't have much experience with
the kind of systems your patchset is targeted at, so I'd need quite a lot
of time to understand the details of your approach and all of the possible
ways it may interfere with the other people's work in progress.  It may just
be the best thing we can do for the use cases you are after, but we also may
be able to address them in simpler ways (which would be better).  Adding new
frameworks like this is not usual in the ACPI subsystem, so to speak, so my
first question is if you considered any alternatives and if you did, then what
they were and why you decided that they would be less suitable.

Moreover, as I'm sure you know, some groups have been working on features
related to your patchset, like memory hotplug, CPU hotplug and PCI host bridge
hotplug, and they have made some progress already.  I wonder, then, in what way
your patchset is going to affect their work.  Is it simply going to make their
lifes easier in all aspects, or (if applied) will it require them to redesign
their code and redo some patchsets they already have tested and queued up
for submission, or, worse yet, will it invalidate their work entirely?  I have
no good answer to this question right now, so I'd like to here from these
people what they think about your work.

Bjorn has already posted his comments and he seems to be skeptical.  His
opinions are very important to me, because he has a lot of experience and
knows things I'm not aware of.  This means, in particular, that I'll be
extremely cautious about applying patches that he has objections against.

You also need to be aware of the fact that some core kernel developers have
long-term goals.  They need not be very precisely defined plans, but just
things those developers would like to achieve at one point in the future.  My
personal goal is to unify the handling of devices by the ACPI subsystem, as
outlined in this message to Yinghai:

http://marc.info/?l=linux-kernel&m=135180467616074&w=4

Unfortunately, I can't really say at this point how your patches, if applied,
will affect this goal (most likely they will make it more difficult to achieve,
it seems) and I know, for example, that the driver core people have some goals
that may be affected by it too (for example, adding new device classes is not
recommended).  That needs to be determined.

Last, but not least, core kernel developers are extremely cautious about adding
new user space interfaces, because doing that is a long-term commitment to
support them and maintain their compatibility with the previous versions.  This
sometimes turns out to be particularly painful, especially if such "old"
interfaces are not suitable for some "new" use cases.  Therefore, every time
somebody wants to add a new sysfs file, for example, we want to know whether
or not this is really necessary/useful and we need to figure out whether or not
the interface being added is the best one for the given use case (and possibly
for other related use cases, including future ones that can be anticipated).
Your patchset seems to add a number of these and they aren't sufficiently
documented, so it is quite difficult to do that.

As for more specific comments, I'd like the changelog of [1/4] to describe
what this particular patch is doing and why it is doing that instead of just
repeating the [0/4] message in its greater part, which isn't very useful.
Also, I'd like sysfs interfaces to be documented in the usual way (i.e. in
Documentation/ABI/) and all functions that are not static to have kerneldoc
comments explaining the meaning of their arguments and describing what the
functions are for (in general terms).  [It wouldn't really hurt if at least
the more important static functions had kerneldoc comments too.]  New data
types, if any, need to be described in comments too (what they are for in
general as well as their individual fields).  It also would be good to have
a general document describing they way the framework is supposed to work under
Documentation/acpi.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
