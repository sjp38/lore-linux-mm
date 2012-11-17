Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 3F42D6B0074
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 19:17:08 -0500 (EST)
Message-ID: <1353110933.10939.6.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 0/3] acpi: Introduce prepare_remove device
 operation
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 16 Nov 2012 17:08:53 -0700
In-Reply-To: <20121117000250.GA4425@kroah.com>
References: 
	<1352974970-6643-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	 <1446291.TgLDtXqY7q@vostro.rjw.lan>
	 <1353105943.12509.60.camel@misato.fc.hp.com>
	 <20121116230143.GA15338@kroah.com>
	 <1353107684.12509.65.camel@misato.fc.hp.com>
	 <20121116233355.GA21144@kroah.com>
	 <1353108906.10624.5.camel@misato.fc.hp.com>
	 <20121117000250.GA4425@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> > > > > > > So the question is, does the ACPI core have to do that and if so, then why?
> > > > > > 
> > > > > > The problem is that acpi_memory_devcie_remove() can fail.  However,
> > > > > > device_release_driver() is a void function, so it cannot report its
> > > > > > error.  Here are function flows for SCI, sysfs eject and unbind.
> > > > > 
> > > > > Then don't ever let acpi_memory_device_remove() fail.  If the user wants
> > > > > it gone, it needs to go away.  Just like any other device in the system
> > > > > that can go away at any point in time, you can't "fail" that.
> > > > 
> > > > That would be ideal, but we cannot delete a memory device that contains
> > > > kernel memory.  I am curious, how do you deal with a USB device that is
> > > > being mounted in this case?
> > > 
> > > As the device is physically gone now, we deal with it and clean up
> > > properly.
> > > 
> > > And that's the point here, what happens if the memory really is gone?
> > > You will still have to handle it now being removed, you can't "fail" a
> > > physical removal of a device.
> > > 
> > > If you remove a memory device that has kernel memory on it, well, you
> > > better be able to somehow remap it before the kernel needs it :)
> > 
> > :)
> > 
> > Well, we are not trying to support surprise removal here.  All three
> > use-cases (SCI, eject, and unbind) are for graceful removal.  Therefore
> > they should fail if the removal operation cannot complete in graceful
> > way.
> 
> Then handle that in the ACPI bus code, it isn't anything that the driver
> core should care about, right?

Unfortunately not.  Please take a look at the function flow for the
unbind case in my first email.  This request directly goes to
driver_unbind(), which is a driver core function.

> And odds are, eventually you will have to handle surprise removal, it's
> only a matter of time :)

Hardware guys will have hard time to support it before software guys can
do something here...  Staff like cache coherency is a devil.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
