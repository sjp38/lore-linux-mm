Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 7B5706B0062
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 17:46:36 -0500 (EST)
Date: Wed, 28 Nov 2012 14:46:33 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
Message-ID: <20121128224633.GA14555@kroah.com>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
 <1451747.3VlxbhJES4@vostro.rjw.lan>
 <1354140982.26955.341.camel@misato.fc.hp.com>
 <11009650.oKuHEgoNWB@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <11009650.oKuHEgoNWB@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Toshi Kani <toshi.kani@hp.com>, linux-acpi@vger.kernel.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 28, 2012 at 11:39:22PM +0100, Rafael J. Wysocki wrote:
> On Wednesday, November 28, 2012 03:16:22 PM Toshi Kani wrote:
> > > > > > > > I see.  I do not think whether or not the device is removed on eject
> > > > > > > > makes any difference here.  The issue is that after driver_unbind() is
> > > > > > > > done, acpi_bus_hot_remove_device() no longer calls the ACPI memory
> > > > > > > > driver (hence, it cannot fail in prepare_remove), and goes ahead to call
> > > > > > > > _EJ0.  If driver_unbind() did off-line the memory, this is OK.  However,
> > > > > > > > it cannot off-line kernel memory ranges.  So, we basically need to
> > > > > > > > either 1) serialize acpi_bus_hot_remove_device() and driver_unbind(), or
> > > > > > > > 2) make acpi_bus_hot_remove_device() to fail if driver_unbind() is run
> > > > > > > > during the operation.
> > > > > > > 
> > > > > > > OK, I see the problem now.
> > > > > > > 
> > > > > > > What exactly is triggering the driver_unbind() in this scenario?
> > > > > > 
> > > > > > User can request driver_unbind() from sysfs as follows.  I do not see
> > > > > > much reason why user has to do for memory, though.
> > > > > > 
> > > > > > echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
> > > > > 
> > > > > This is wrong.  Even if we want to permit user space to forcibly unbind
> > > > > drivers from anything like this, we should at least check for some
> > > > > situations in which it is plain dangerous.  Like in this case.  So I think
> > > > > the above should fail unless we know that the driver won't be necessary
> > > > > to handle hot-removal of memory.
> > > > 
> > > > Well, we tried twice already... :)
> > > > https://lkml.org/lkml/2012/11/16/649
> > > 
> > > I didn't mean driver_unbind() should fail.  The code path that executes
> > > driver_unbind() eventually should fail _before_ executing it.
> > 
> > driver_unbind() is the handler, so it is called directly from this
> > unbind interface.
> 
> Yes, sorry for the confusion.
> 
> So, it looks like the driver core wants us to handle driver unbinding no
> matter what.

Yes.  Well, the driver core does the unbinding no matter what, if it was
told, by a user, to do so.  Why is that a problem?  The user then is
responsible for any bad things (i.e. not able to control the device any
more), if they do so.

> This pretty much means that it is a bad idea to have a driver that is
> exposed as a "device driver" in sysfs for memory hotplugging.

Again, why?  All this means is that the driver is now not connected to
the device (memory in this case.)  The memory is still there, still
operates as before, only difference is, the driver can't touch it
anymore.

This is the same for any ACPI driver, and has been for years.

Please don't confuse unbind with any "normal" system operation, it is
not to be used for memory hotplug, or anything else like this.

Also, if you really do not want to do this, turn off the ability to
unbind/bind for these devices, that is under your control in your bus
logic.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
