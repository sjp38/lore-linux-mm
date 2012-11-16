Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 810446B004D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 18:33:59 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so1463739dad.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 15:33:58 -0800 (PST)
Date: Fri, 16 Nov 2012 15:33:55 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v2 0/3] acpi: Introduce prepare_remove device
 operation
Message-ID: <20121116233355.GA21144@kroah.com>
References: <1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
 <1446291.TgLDtXqY7q@vostro.rjw.lan>
 <1353105943.12509.60.camel@misato.fc.hp.com>
 <20121116230143.GA15338@kroah.com>
 <1353107684.12509.65.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1353107684.12509.65.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 16, 2012 at 04:14:44PM -0700, Toshi Kani wrote:
> On Fri, 2012-11-16 at 15:01 -0800, Greg Kroah-Hartman wrote:
> > On Fri, Nov 16, 2012 at 03:45:43PM -0700, Toshi Kani wrote:
> > > On Fri, 2012-11-16 at 22:43 +0100, Rafael J. Wysocki wrote:
> > > > On Thursday, November 15, 2012 11:22:47 AM Vasilis Liaskovitis wrote:
> > > > > As discussed in https://patchwork.kernel.org/patch/1581581/
> > > > > the driver core remove function needs to always succeed. This means we need
> > > > > to know that the device can be successfully removed before acpi_bus_trim / 
> > > > > acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
> > > > > eject or driver unbind of memory devices fails e.g with:
> > > > > 
> > > > > echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> > > > > echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
> > > > > 
> > > > > since the ACPI core goes ahead and ejects the device regardless of whether the
> > > > > the memory is still in use or not.
> > > > 
> > > > So the question is, does the ACPI core have to do that and if so, then why?
> > > 
> > > The problem is that acpi_memory_devcie_remove() can fail.  However,
> > > device_release_driver() is a void function, so it cannot report its
> > > error.  Here are function flows for SCI, sysfs eject and unbind.
> > 
> > Then don't ever let acpi_memory_device_remove() fail.  If the user wants
> > it gone, it needs to go away.  Just like any other device in the system
> > that can go away at any point in time, you can't "fail" that.
> 
> That would be ideal, but we cannot delete a memory device that contains
> kernel memory.  I am curious, how do you deal with a USB device that is
> being mounted in this case?

As the device is physically gone now, we deal with it and clean up
properly.

And that's the point here, what happens if the memory really is gone?
You will still have to handle it now being removed, you can't "fail" a
physical removal of a device.

If you remove a memory device that has kernel memory on it, well, you
better be able to somehow remap it before the kernel needs it :)

sorry,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
