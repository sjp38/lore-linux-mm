Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id CB0A96B0071
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 20:24:07 -0500 (EST)
Message-ID: <1354151742.26955.385.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 28 Nov 2012 18:15:42 -0700
In-Reply-To: <1354150952.26955.377.camel@misato.fc.hp.com>
References: 
	<1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	 <9212118.3s2xH6uJDI@vostro.rjw.lan>
	 <1354136568.26955.312.camel@misato.fc.hp.com>
	 <4042591.gpFk7OYmph@vostro.rjw.lan>
	 <1354150952.26955.377.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-acpi@vger.kernel.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2012-11-28 at 18:02 -0700, Toshi Kani wrote:
> On Thu, 2012-11-29 at 00:49 +0100, Rafael J. Wysocki wrote:
> > On Wednesday, November 28, 2012 02:02:48 PM Toshi Kani wrote:
> > > > > > > > > > Consider the following case:
> > > > > > > > > > 
> > > > > > > > > > We hotremove the memory device by SCI and unbind it from the driver at the same time:
> > > > > > > > > > 
> > > > > > > > > > CPUa                                                  CPUb
> > > > > > > > > > acpi_memory_device_notify()
> > > > > > > > > >                                        unbind it from the driver
> > > > > > > > > >     acpi_bus_hot_remove_device()
> > > > > > > > > 
> > > > > > > > > Can we make acpi_bus_remove() to fail if a given acpi_device is not
> > > > > > > > > bound with a driver?  If so, can we make the unbind operation to perform
> > > > > > > > > unbind only?
> > > > > > > > 
> > > > > > > > acpi_bus_remove_device could check if the driver is present, and return -ENODEV
> > > > > > > > if it's not present (dev->driver == NULL).
> > > > > > > > 
> > > > > > > > But there can still be a race between an eject and an unbind operation happening
> > > > > > > > simultaneously. This seems like a general problem to me i.e. not specific to an
> > > > > > > > acpi memory device. How do we ensure an eject does not race with a driver unbind
> > > > > > > > for other acpi devices?
> > > > > > > > 
> > > > > > > > Is there a per-device lock in acpi-core or device-core that can prevent this from
> > > > > > > > happening? Driver core does a device_lock(dev) on all operations, but this is
> > > > > > > > probably not grabbed on SCI-initiated acpi ejects.
> > > > > > > 
> > > > > > > Since driver_unbind() calls device_lock(dev->parent) before calling
> > > > > > > device_release_driver(), I am wondering if we can call
> > > > > > > device_lock(dev->dev->parent) at the beginning of acpi_bus_remove()
> > > > > > > (i.e. before calling pre_remove) and fails if dev->driver is NULL.  The
> > > > > > > parent lock is otherwise released after device_release_driver() is done.
> > > > > > 
> > > > > > I would be careful.  You may introduce some subtle locking-related issues
> > > > > > this way.
> > > > > 
> > > > > Right.  This requires careful inspection and testing.  As far as the
> > > > > locking is concerned, I am not keen on using fine grained locking for
> > > > > hot-plug.  It is much simpler and solid if we serialize such operations.
> > > > > 
> > > > > > Besides, there may be an alternative approach to all this.  For example,
> > > > > > what if we don't remove struct device objects on eject?  The ACPI handles
> > > > > > associated with them don't go away in that case after all, do they?
> > > > > 
> > > > > Umm...  Sorry, I am not getting your point.  The issue is that we need
> > > > > to be able to fail a request when memory range cannot be off-lined.
> > > > > Otherwise, we end up ejecting online memory range.
> > > > 
> > > > Yes, this is the major one.  The minor issue, however, is a race condition
> > > > between unbinding a driver from a device and removing the device if I
> > > > understand it correctly.  Which will go away automatically if the device is
> > > > not removed in the first place.  Or so I would think. :-)
> > > 
> > > I see.  I do not think whether or not the device is removed on eject
> > > makes any difference here.  The issue is that after driver_unbind() is
> > > done, acpi_bus_hot_remove_device() no longer calls the ACPI memory
> > > driver (hence, it cannot fail in prepare_remove), and goes ahead to call
> > > _EJ0.
> > 
> > I see two reasons for calling acpi_bus_hot_remove_device() for memory (correct
> > me if I'm wrong): (1) from the memhotplug driver's notify handler and (2) from
> > acpi_eject_store() which is exposed through sysfs.  
> 
> Yes, that is correct.
> 
> > If we disabled exposing
> > acpi_eject_store() for memory devices, then the only way would be from the
> > notify handler.  So I wonder if driver_unbind() shouldn't just uninstall the
> > notify handler for memory (so that memory eject events are simply dropped on
> > the floor after unbinding the driver)?
> 
> If driver_unbind() happens before an eject request, we do not have a
> problem.  acpi_eject_store() fails if a driver is not bound to the
> device.  acpi_memory_device_notify() fails as well.
> 
> The race condition Wen pointed out (see the top of this email) is that
> driver_unbind() may come in while eject operation is in-progress.  This
> is why I mentioned the following in previous email.
> 
> > So, we basically need to either 1) serialize
> > acpi_bus_hot_remove_device() and driver_unbind(), or 2) make
> > acpi_bus_hot_remove_device() to fail if driver_unbind() is run
> > during the operation.

Forgot to mention.  The 3rd option is what Greg said -- use the
suppress_bind_attrs field.  I think this is a good option to address
this race condition for now.  For a long term solution, we should have a
better infrastructure in place to address such issue in general.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
