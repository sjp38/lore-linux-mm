Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 158CA6B002B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 18:22:58 -0500 (EST)
Message-ID: <1353107684.12509.65.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 0/3] acpi: Introduce prepare_remove device
 operation
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 16 Nov 2012 16:14:44 -0700
In-Reply-To: <20121116230143.GA15338@kroah.com>
References: 
	<1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	 <1446291.TgLDtXqY7q@vostro.rjw.lan>
	 <1353105943.12509.60.camel@misato.fc.hp.com>
	 <20121116230143.GA15338@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2012-11-16 at 15:01 -0800, Greg Kroah-Hartman wrote:
> On Fri, Nov 16, 2012 at 03:45:43PM -0700, Toshi Kani wrote:
> > On Fri, 2012-11-16 at 22:43 +0100, Rafael J. Wysocki wrote:
> > > On Thursday, November 15, 2012 11:22:47 AM Vasilis Liaskovitis wrote:
> > > > As discussed in https://patchwork.kernel.org/patch/1581581/
> > > > the driver core remove function needs to always succeed. This means we need
> > > > to know that the device can be successfully removed before acpi_bus_trim / 
> > > > acpi_bus_hot_remove_device are called. This can cause panics when OSPM-initiated
> > > > eject or driver unbind of memory devices fails e.g with:
> > > > 
> > > > echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> > > > echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
> > > > 
> > > > since the ACPI core goes ahead and ejects the device regardless of whether the
> > > > the memory is still in use or not.
> > > 
> > > So the question is, does the ACPI core have to do that and if so, then why?
> > 
> > The problem is that acpi_memory_devcie_remove() can fail.  However,
> > device_release_driver() is a void function, so it cannot report its
> > error.  Here are function flows for SCI, sysfs eject and unbind.
> 
> Then don't ever let acpi_memory_device_remove() fail.  If the user wants
> it gone, it needs to go away.  Just like any other device in the system
> that can go away at any point in time, you can't "fail" that.

That would be ideal, but we cannot delete a memory device that contains
kernel memory.  I am curious, how do you deal with a USB device that is
being mounted in this case?

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
