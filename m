Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id AE3556B004D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 19:24:20 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Patch v5 0/7] acpi,memory-hotplug: implement framework for hot removing memory
Date: Fri, 16 Nov 2012 01:28:43 +0100
Message-ID: <9217155.1eDFuhkN55@vostro.rjw.lan>
In-Reply-To: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com>
References: <1352962777-24407-1-git-send-email-wency@cn.fujitsu.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Toshi Kani <toshi.kani@hp.com>

On Thursday, November 15, 2012 02:59:30 PM Wen Congyang wrote:
> The memory device can be removed by 2 ways:
> 1. send eject request by SCI
> 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> 
> In the 1st case, acpi_memory_disable_device() will be called.
> In the 2nd case, acpi_memory_device_remove() will be called.
> acpi_memory_device_remove() will also be called when we unbind the
> memory device from the driver acpi_memhotplug or a driver initialization
> fails.
> 
> acpi_memory_disable_device() has already implemented a code which
> offlines memory and releases acpi_memory_info struct . But
> acpi_memory_device_remove() has not implemented it yet.
> 
> So the patch prepares the framework for hot removing memory and
> adds the framework into acpi_memory_device_remove().
> 
> We may hotremove the memory device by this 2 ways at the same time.
> So we remove the function acpi_memory_disable_device(), and use
> acpi_bus_hot_remove_device() which is used by 2nd case to implement it.
> We lock device in acpi_bus_hot_remove_device(), so there is no
> need to add lock in acpi_memhotplug.
> 
> The last version of this patchset is here:
> https://lkml.org/lkml/2012/11/8/121
> 
> Note:
> 1. The following commit in pm tree can be dropped now(The other two patches
>    are already dropped):
>    54c4c7db6cb94d7d1217df6d7fca6847c61744ab
> 2. This patchset requires the following patch(It is in pm tree now)
>    https://lkml.org/lkml/2012/11/1/225
> 
> Changes from v4 to v5:
> 1. patch2: new patch. use acpi_bus_hot_remove_device() to implement memory
>    device hotremove.
> 
> Changes from v3 to v4:
> 1. patch1: unlock list_lock when removing memory fails.
> 2. patch2: just rebase them
> 3. patch3-7: these patches are in -mm tree, and they conflict with this
>    patchset, so Adrew Morton drop them from -mm tree. I rebase and merge
>    them into this patchset.
> 
> Wen Congyang (6):
>   acpi,memory-hotplug: deal with eject request in hotplug queue
>   acpi_memhotplug.c: fix memory leak when memory device is unbound from
>     the module acpi_memhotplug
>   acpi_memhotplug.c: free memory device if acpi_memory_enable_device()
>     failed
>   acpi_memhotplug.c: don't allow to eject the memory device if it is
>     being used
>   acpi_memhotplug.c: bind the memory device when the driver is being
>     loaded
>   acpi_memhotplug.c: auto bind the memory device which is hotplugged
>     before the driver is loaded
> 
> Yasuaki Ishimatsu (1):
>   acpi,memory-hotplug : add memory offline code to
>     acpi_memory_device_remove()

Well, I have tried _really_ hard to apply this patchset, but pretty much
none of the patches except for [1/7] applied for me.  I have no idea what
tree they are against, but I'm pretty sure it's not my tree.

I _have_ applied patches [1-4/7] and pushed them to linux-pm.git/linux-next.
I needed to fix up almost all of them so that they applied, so please check
if my fixups make sense (and let me know ASAP if that's not the case).

If they are OK, please rebase the rest of the series on top of
linux-pm.git/linux-next and repost.  I'm not going to take any more
patches that don't apply from you.

Moreover, I'm not going to take any more ACPI memory hotplug patches
for v3.8 except for the [5-7/7] from this series (after they have been
rebased and _if_ they apply), so please don't submit any until the v3.8
merge window closes (of course, you're free to post RFCs, but I will
ignore them).

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
