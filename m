Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 9029F6B0070
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 06:05:04 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so7220712bkc.14
        for <linux-mm@kvack.org>; Thu, 29 Nov 2012 03:05:02 -0800 (PST)
Date: Thu, 29 Nov 2012 12:04:51 +0100
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
Message-ID: <20121129110451.GA639@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
 <9212118.3s2xH6uJDI@vostro.rjw.lan>
 <1354136568.26955.312.camel@misato.fc.hp.com>
 <4042591.gpFk7OYmph@vostro.rjw.lan>
 <1354150952.26955.377.camel@misato.fc.hp.com>
 <1354151742.26955.385.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354151742.26955.385.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Wed, Nov 28, 2012 at 06:15:42PM -0700, Toshi Kani wrote:
> On Wed, 2012-11-28 at 18:02 -0700, Toshi Kani wrote:
> > On Thu, 2012-11-29 at 00:49 +0100, Rafael J. Wysocki wrote:
> > > On Wednesday, November 28, 2012 02:02:48 PM Toshi Kani wrote:
> > > > > > > > > > > Consider the following case:
> > > > > > > > > > > 
> > > > > > > > > > > We hotremove the memory device by SCI and unbind it from the driver at the same time:
> > > > > > > > > > > 
> > > > > > > > > > > CPUa                                                  CPUb
> > > > > > > > > > > acpi_memory_device_notify()
> > > > > > > > > > >                                        unbind it from the driver
> > > > > > > > > > >     acpi_bus_hot_remove_device()
> > > I see two reasons for calling acpi_bus_hot_remove_device() for memory (correct
> > > me if I'm wrong): (1) from the memhotplug driver's notify handler and (2) from
> > > acpi_eject_store() which is exposed through sysfs.  
> > 
> > Yes, that is correct.
> > 
> > > If we disabled exposing
> > > acpi_eject_store() for memory devices, then the only way would be from the
> > > notify handler.  So I wonder if driver_unbind() shouldn't just uninstall the
> > > notify handler for memory (so that memory eject events are simply dropped on
> > > the floor after unbinding the driver)?
> > 
> > If driver_unbind() happens before an eject request, we do not have a
> > problem.  acpi_eject_store() fails if a driver is not bound to the
> > device.  acpi_memory_device_notify() fails as well.
> > 
> > The race condition Wen pointed out (see the top of this email) is that
> > driver_unbind() may come in while eject operation is in-progress.  This
> > is why I mentioned the following in previous email.
> > 
> > > So, we basically need to either 1) serialize
> > > acpi_bus_hot_remove_device() and driver_unbind(), or 2) make
> > > acpi_bus_hot_remove_device() to fail if driver_unbind() is run
> > > during the operation.
> 
> Forgot to mention.  The 3rd option is what Greg said -- use the
> suppress_bind_attrs field.  I think this is a good option to address
> this race condition for now.  For a long term solution, we should have a
> better infrastructure in place to address such issue in general.

I like the suppress_bind_attrs idea, I 'll take a look.

As I said for option 2), acpi_bus_remove could check for driver presence.
But It's more a quick hack to abort the eject (the race with unbind can still
happen, but acpi_bus_remove can now detect it later in the eject path).
Something like:

 static int acpi_bus_remove(struct acpi_device *dev, int rmdevice)
 {
+	int ret;
 	if (!dev)
 		return -EINVAL;
 
 	dev->removal_type = ACPI_BUS_REMOVAL_EJECT;
+
+	if (dev->driver && dev->driver->ops.prepare_remove) {
+		ret = dev->driver->ops.prepare_remove(dev);
+		if (ret)
+			return ret;
+	}
+	else if (!dev->driver)
+		return -ENODEV;
 	device_release_driver(&dev->dev);

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
