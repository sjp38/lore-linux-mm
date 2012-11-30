Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 7792F6B004D
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 17:35:45 -0500 (EST)
Message-ID: <1354314435.20085.55.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 30 Nov 2012 15:27:15 -0700
In-Reply-To: <50B6C7A4.806@huawei.com>
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com>
	 <50B5CFAE.80103@huawei.com> <20121129014251.GA9217@kernel>
	 <50B6C7A4.806@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, "Wang, Frank" <frank.wang@intel.com>

On Thu, 2012-11-29 at 10:25 +0800, Jiang Liu wrote:
> On 2012-11-29 9:42, Jaegeuk Hanse wrote:
> > On Wed, Nov 28, 2012 at 04:47:42PM +0800, Jiang Liu wrote:
> >> Hi all,
> >> 	Seems it's a great chance to discuss about the memory hotplug feature
> >> within this thread. So I will try to give some high level thoughts about memory
> >> hotplug feature on x86/IA64. Any comments are welcomed!
> >> 	First of all, I think usability really matters. Ideally, memory hotplug
> >> feature should just work out of box, and we shouldn't expect administrators to 
> >> add several extra platform dependent parameters to enable memory hotplug. 
> >> But how to enable memory (or CPU/node) hotplug out of box? I think the key point
> >> is to cooperate with BIOS/ACPI/firmware/device management teams. 
> >> 	I still position memory hotplug as an advanced feature for high end 
> >> servers and those systems may/should provide some management interfaces to 
> >> configure CPU/memory/node hotplug features. The configuration UI may be provided
> >> by BIOS, BMC or centralized system management suite. Once administrator enables
> >> hotplug feature through those management UI, OS should support system device
> >> hotplug out of box. For example, HP SuperDome2 management suite provides interface
> >> to configure a node as floating node(hot-removable). And OpenSolaris supports
> >> CPU/memory hotplug out of box without any extra configurations. So we should
> >> shape interfaces between firmware and OS to better support system device hotplug.

Well described.  I agree with you.  I am also OK to have the boot option
for the time being, but we should be able to get the info from ACPI for
better TCE.

> >> 	On the other hand, I think there are no commercial available x86/IA64
> >> platforms with system device hotplug capabilities in the field yet, at least only
> >> limited quantity if any. So backward compatibility is not a big issue for us now.

HP SuperDome is IA64-based and supports node hotplug when running with
HP-UX.  It implements vendor-unique ACPI interface to describe movable
memory ranges.

> >> So I think it's doable to rely on firmware to provide better support for system
> >> device hotplug.
> >> 	Then what should be enhanced to better support system device hotplug?
> >>
> >> 1) ACPI specification should be enhanced to provide a static table to describe
> >> components with hotplug features, so OS could reserve special resources for
> >> hotplug at early boot stages. For example, to reserve enough CPU ids for CPU
> >> hot-add. Currently we guess maximum number of CPUs supported by the platform
> >> by counting CPU entries in APIC table, that's not reliable.

Right.  HP SuperDome implements vendor-unique ACPI interface for this as
well.  For Linux, it is nice to have a standard interface defined.

> >> 2) BIOS should implement SRAT, MPST and PMTT tables to better support memory
> >> hotplug. SRAT associates memory ranges with proximity domains with an extra
> >> "hotpluggable" flag. PMTT provides memory device topology information, such
> >> as "socket->memory controller->DIMM". MPST is used for memory power management
> >> and provides a way to associate memory ranges with memory devices in PMTT.
> >> With all information from SRAT, MPST and PMTT, OS could figure out hotplug
> >> memory ranges automatically, so no extra kernel parameters needed.

I agree that using SRAT is a good compromise.  The hotpluggable flag is
supposed to indicate the platform's capability, but could use for this
purpose until we have a better interface defined.

> >> 3) Enhance ACPICA to provide a method to scan static ACPI tables before
> >> memory subsystem has been initialized because OS need to access SRAT,
> >> MPST and PMTT when initializing memory subsystem.

I do not think this is an ACPICA issue.  HP-UX also uses ACPICA, and can
access ACPI tables and walk ACPI namespace during early boot-time.  This
is achieved by the acpi_os layer to use special early boot-time memory
allocator at early boot-time.  Therefore, boot-time and hot-add config
code are very consistent in HP-UX.

> >> 4) The last and the most important issue is how to minimize performance
> >> drop caused by memory hotplug. As proposed by this patchset, once we
> >> configure all memory of a NUMA node as movable, it essentially disable
> >> NUMA optimization of kernel memory allocation from that node. According
> >> to experience, that will cause huge performance drop. We have observed
> >> 10-30% performance drop with memory hotplug enabled. And on another
> >> OS the average performance drop caused by memory hotplug is about 10%.
> >> If we can't resolve the performance drop, memory hotplug is just a feature
> >> for demo:( With help from hardware, we do have some chances to reduce
> >> performance penalty caused by memory hotplug.
> >> 	As we know, Linux could migrate movable page, but can't migrate
> >> non-movable pages used by kernel/DMA etc. And the most hard part is how
> >> to deal with those unmovable pages when hot-removing a memory device.
> >> Now hardware has given us a hand with a technology named memory migration,
> >> which could transparently migrate memory between memory devices. There's
> >> no OS visible changes except NUMA topology before and after hardware memory
> >> migration.
> >> 	And if there are multiple memory devices within a NUMA node,
> >> we could configure some memory devices to host unmovable memory and the
> >> other to host movable memory. With this configuration, there won't be
> >> bigger performance drop because we have preserved all NUMA optimizations.
> >> We also could achieve memory hotplug remove by:
> >> 1) Use existing page migration mechanism to reclaim movable pages.
> >> 2) For memory devices hosting unmovable pages, we need:
> >> 2.1) find a movable memory device on other nodes with enough capacity
> >> and reclaim it.
> >> 2.2) use hardware migration technology to migrate unmovable memory to
> >> the just reclaimed memory device on other nodes.
>>>
> >> 	I hope we could expect users to adopt memory hotplug technology
> >> with all these implemented.
> >>
> >> 	Back to this patch, we could rely on the mechanism provided
> >> by it to automatically mark memory ranges as movable with information
> >>from ACPI SRAT/MPST/PMTT tables. So we don't need administrator to
> >> manually configure kernel parameters to enable memory hotplug.

Right.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
