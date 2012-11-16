Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 4DE546B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 16:37:31 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 0/3] acpi: Introduce prepare_remove device operation
Date: Fri, 16 Nov 2012 22:41:52 +0100
Message-ID: <6896483.i6Vm9YII9b@vostro.rjw.lan>
In-Reply-To: <20121116213310.GA12925@kroah.com>
References: <1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <11897248.2VNutIHaJi@vostro.rjw.lan> <20121116213310.GA12925@kroah.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, toshi.kani@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Friday, November 16, 2012 01:33:10 PM Greg Kroah-Hartman wrote:
> On Fri, Nov 16, 2012 at 10:17:17PM +0100, Rafael J. Wysocki wrote:
> > On Thursday, November 15, 2012 11:22:47 AM Vasilis Liaskovitis wrote:
> > > As discussed in https://patchwork.kernel.org/patch/1581581/
> > > the driver core remove function needs to always succeed. This means we need
> > > to know that the device can be successfully removed before acpi_bus_trim / 
> > > acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
> > > eject or driver unbind of memory devices fails e.g with:
> > > 
> > > echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> > > echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
> > > 
> > > since the ACPI core goes ahead and ejects the device regardless of whether the
> > > the memory is still in use or not.
> > > 
> > > For this reason a new acpi_device operation called prepare_remove is introduced.
> > > This operation should be registered for acpi devices whose removal (from kernel
> > > perspective) can fail.  Memory devices fall in this category.
> > > A similar operation is introduced in bus_type to safely handle driver unbind
> > > from the device driver core.
> > > 
> > > acpi_bus_hot_remove_device and driver_unbind are changed to handle removal in 2
> > > steps:
> > > - preparation for removal i.e. perform part of removal that can fail. Should
> > >   succeed for device and all its children.
> > > - if above step was successfull, proceed to actual device removal
> > > 
> > > With this patchset, only acpi memory devices use the new prepare_remove
> > > device operation. The actual memory removal (VM-related offline and other memory
> > > cleanups) is moved to prepare_remove. The old remove operation just cleans up
> > > the acpi structures. Directly ejecting PNP0C80 memory devices works safely. I
> > > haven't tested yet with an ACPI container which contains memory devices.
> > > 
> > > v1->v2:
> > > - new patch to introduce bus_type prepare_remove callback. Needed to prepare
> > > removal on driver unbinding from device-driver core.
> > > - v1 patches 1 and 2 simplified and merged in one. acpi_bus_trim does not require
> > > argument changes.
> > > 
> > > Comments welcome.
> > > 
> > > Vasilis Liaskovitis (3):
> > >   driver core: Introduce prepare_remove in bus_type
> > >   acpi: Introduce prepare_remove operation in acpi_device_ops
> > >   acpi_memhotplug: Add prepare_remove operation
> > > 
> > >  drivers/acpi/acpi_memhotplug.c |   22 ++++++++++++++++++++--
> > >  drivers/acpi/scan.c            |   21 ++++++++++++++++++++-
> > >  drivers/base/bus.c             |   36 ++++++++++++++++++++++++++++++++++++
> > >  include/acpi/acpi_bus.h        |    2 ++
> > >  include/linux/device.h         |    2 ++
> > >  5 files changed, 80 insertions(+), 3 deletions(-)
> > 
> > CCs of all driver core patches have to go to Greg Kroah-Hartman.
> 
> I previously rejected this, so I don't see why I would take it this time
> around :(
> 
> Please, no driver core changes for acpi, I don't see why it is suddenly
> so special to need stuff like this that can't just be done in the ACPI
> bus code itself.

OK, OK, that was just a notice to the author. :-)

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
