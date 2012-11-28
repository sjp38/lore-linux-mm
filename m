Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 3C8626B006C
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 06:05:47 -0500 (EST)
Message-ID: <50B5EFE9.3040206@huawei.com>
Date: Wed, 28 Nov 2012 19:05:13 +0800
From: Hanjun Guo <guohanjun@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device operation
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
In-Reply-To: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, rjw@sisk.pl, lenb@kernel.org, toshi.kani@hp.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>

On 2012/11/24 1:50, Vasilis Liaskovitis wrote:
> As discussed in https://patchwork.kernel.org/patch/1581581/
> the driver core remove function needs to always succeed. This means we need
> to know that the device can be successfully removed before acpi_bus_trim / 
> acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
> or SCI-initiated eject of memory devices fail e.g with:
> echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> 
> since the ACPI core goes ahead and ejects the device regardless of whether the
> the memory is still in use or not.
> 
> For this reason a new acpi_device operation called prepare_remove is introduced.
> This operation should be registered for acpi devices whose removal (from kernel
> perspective) can fail.  Memory devices fall in this category.
> 
> acpi_bus_remove() is changed to handle removal in 2 steps:
> - preparation for removal i.e. perform part of removal that can fail. Should
>   succeed for device and all its children.
> - if above step was successfull, proceed to actual device removal

Hi Vasilis,
We met the same problem when we doing computer node hotplug, It is a good idea
to introduce prepare_remove before actual device removal.

I think we could do more in prepare_remove, such as rollback. In most cases, we can
offline most of memory sections except kernel used pages now, should we rollback
and online the memory sections when prepare_remove failed ?

As you may know, the ACPI based hotplug framework we are working on already addressed
this problem, and the way we slove this problem is a bit like yours.

We introduce hp_ops in struct acpi_device_ops:
struct acpi_device_ops {
	acpi_op_add add;
	acpi_op_remove remove;
	acpi_op_start start;
	acpi_op_bind bind;
	acpi_op_unbind unbind;
	acpi_op_notify notify;
#ifdef	CONFIG_ACPI_HOTPLUG
	struct acpihp_dev_ops *hp_ops;
#endif	/* CONFIG_ACPI_HOTPLUG */
};

in hp_ops, we divide the prepare_remove into six small steps, that is:
1) pre_release(): optional step to mark device going to be removed/busy
2) release(): reclaim device from running system
3) post_release(): rollback if cancelled by user or error happened
4) pre_unconfigure(): optional step to solve possible dependency issue
5) unconfigure(): remove devices from running system
6) post_unconfigure(): free resources used by devices

In this way, we can easily rollback if error happens.
How do you think of this solution, any suggestion ? I think we can achieve
a better way for sharing ideas. :)

Thanks
Hanjun Guo

> 
> With this patchset, only acpi memory devices use the new prepare_remove
> device operation. The actual memory removal (VM-related offline and other memory
> cleanups) is moved to prepare_remove. The old remove operation just cleans up
> the acpi structures. Directly ejecting PNP0C80 memory devices works safely. I
> haven't tested yet with an ACPI container which contains memory devices.
> 
> Note that unbinding the acpi driver from a memory device with:
> echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
> 
> will no longer try to remove the memory. This is in compliance with normal
> unbind driver core semantics, see the discussion in v2 of this patchset:
> https://lkml.org/lkml/2012/11/16/649
> 
> After a successful unbind of the driver:
> - OSPM ejects of the memory device cannot proceed, as acpi_eject_store will
> return -ENODEV on missing driver.
> - SCI ejects of the memory device also cannot proceed, as they will also get
> a "driver data is NULL" error.
> So the memory can continue to be used safely after unbind.
> 
> Patchset based on Rafael's linux-pm/linux-next (commit 78c38651).
> Comments welcome.
> 
> v2->v3:
> - remove driver core changes. Only acpi core changes needed. Unbind semantics
> follow driver core rules. Unbind does not remove memory.
> - new patch to set enable bit in order to proceed with ejects on driver
> re-binding scenario.
> 
> v1->v2:
> - new patch to introduce bus_type prepare_remove callback. Needed to prepare
> removal on driver unbinding from device-driver core.
> - v1 patches 1 and 2 simplified and merged in one. acpi_bus_trim does not require
> argument changes.
> 
> Vasilis Liaskovitis (3):
>   acpi: Introduce prepare_remove operation in acpi_device_ops
>   acpi_memhotplug: Add prepare_remove operation
>   acpi_memhotplug: Allow eject to proceed on rebind scenario
> 
>  drivers/acpi/acpi_memhotplug.c |   21 +++++++++++++++++----
>  drivers/acpi/scan.c            |    9 ++++++++-
>  include/acpi/acpi_bus.h        |    2 ++
>  3 files changed, 27 insertions(+), 5 deletions(-)
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
