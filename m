Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id ADB3E6B0068
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 12:20:53 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jm1so2990755bkc.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 09:20:52 -0800 (PST)
Date: Mon, 12 Nov 2012 18:20:47 +0100
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [RFC PATCH 0/3] acpi: Introduce prepare_remove device operation
Message-ID: <20121112172046.GA4931@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1352399371-8015-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
 <50A07477.2050002@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50A07477.2050002@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, rjw@sisk.pl, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 12, 2012 at 12:00:55PM +0800, Wen Congyang wrote:
> At 11/09/2012 02:29 AM, Vasilis Liaskovitis Wrote:
> > As discussed in
> > https://patchwork.kernel.org/patch/1581581/
> > the driver core remove function needs to always succeed. This means we need
> > to know that the device can be successfully removed before acpi_bus_trim / 
> > acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
> > eject (echo 1 > /sys/bus/acpi/devices/PNP/eject) of memory devices fails, since
> > the ACPI core goes ahead and ejects the device regardless of whether the memory
> > is still in use or not.
> > 
> > For this reason a new acpi_device operation called prepare_remove is introduced.
> > This operation should be registered for acpi devices whose removal (from kernel
> > perspective) can fail.  Memory devices fall in this category.
> > 
> > acpi_bus_hot_remove_device is changed to handle removal in 2 steps:
> > - preparation for removal i.e. perform part of removal that can fail outside of
> >   ACPI core. Should succeed for device and all its children.
> > - if above step was successfull, proceed to actual ACPI removal
> 
> If we unbind the device from the driver, we still need to do preparation. But
> you don't do it in your patch.

yes, driver_unbind breaks with the current patchset. I 'll try to fix and
repost. However, I think this will require a new driver-core wide prepare_remove
callback (not only acpi-specific). I am not sure that would be acceptable.

thanks,

- Vasilis

> 
> Thanks
> Wen Congyang
> > 
> > acpi_bus_trim is changed accordingly to handle preparation for removal and
> > actual removal.
> > 
> > With this patchset, only acpi memory devices use the new prepare_remove
> > device operation. The actual memory removal (VM-related offline and other memory
> > cleanups) is moved to prepare_remove. The old remove operation just cleans up
> > the acpi structures. Directly ejecting PNP0C80 memory devices works safely. I
> > haven't tested yet with an ACPI container which contains memory devices.
> > 
> > Other ACPI devices (e.g. CPU) do not register prepare_remove callbacks, and
> > their OSPM-side eject should not be affected.
> > 
> > I am not happy with the name prepare_remove. Comments welcome. Let me know if I
> > should work more in this direction (I think Yasuaki might also look into this
> > and might have a simpler idea)
> > 
> > Patches are on top of Rafael's linux-pm/linux-next
> > 
> > Vasilis Liaskovitis (3):
> >   acpi: Introduce prepare_remove operation in acpi_device_ops
> >   acpi: Make acpi_bus_trim handle device removal preparation
> >   acpi_memhotplug: Add prepare_remove operation
> > 
> >  drivers/acpi/acpi_memhotplug.c     |   24 +++++++++++++++++++++---
> >  drivers/acpi/dock.c                |    2 +-
> >  drivers/acpi/scan.c                |   32 +++++++++++++++++++++++++++++---
> >  drivers/pci/hotplug/acpiphp_glue.c |    4 ++--
> >  drivers/pci/hotplug/sgi_hotplug.c  |    2 +-
> >  include/acpi/acpi_bus.h            |    4 +++-
> >  6 files changed, 57 insertions(+), 11 deletions(-)
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
