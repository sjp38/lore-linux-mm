Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 900FE6B0072
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 18:26:18 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on rebind scenario
Date: Thu, 29 Nov 2012 00:31:02 +0100
Message-ID: <2363618.GHMYUtrpGK@vostro.rjw.lan>
In-Reply-To: <20121128231046.GA15416@kroah.com>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <4960597.PcG7YIEMVH@vostro.rjw.lan> <20121128231046.GA15416@kroah.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, linux-acpi@vger.kernel.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wednesday, November 28, 2012 03:10:46 PM Greg KH wrote:
> On Thu, Nov 29, 2012 at 12:05:20AM +0100, Rafael J. Wysocki wrote:
> > On Wednesday, November 28, 2012 02:46:33 PM Greg KH wrote:
> > > > So, it looks like the driver core wants us to handle driver unbinding no
> > > > matter what.
> > > 
> > > Yes.  Well, the driver core does the unbinding no matter what, if it was
> > > told, by a user, to do so.  Why is that a problem?  The user then is
> > > responsible for any bad things (i.e. not able to control the device any
> > > more), if they do so.
> > 
> > I don't really agree with that, because the user may simply not know what
> > the consequences of that will be.  In my not so humble opinion any interface
> > allowing user space to crash the kernel is a bad one.  And this is an example
> > of that.
> 
> This has been in place since 2005, over 7 years now, and I have never
> heard any problems with it being used to crash the kernel, despite the
> easy ability for people to unbind all of their devices from drivers and
> instantly cause a system hang.  So really doubt this is a problem in
> real life :)
> 
> > > > This pretty much means that it is a bad idea to have a driver that is
> > > > exposed as a "device driver" in sysfs for memory hotplugging.
> > > 
> > > Again, why?  All this means is that the driver is now not connected to
> > > the device (memory in this case.)  The memory is still there, still
> > > operates as before, only difference is, the driver can't touch it
> > > anymore.
> > > 
> > > This is the same for any ACPI driver, and has been for years.
> > 
> > Except that if this driver has been unbound and the removal is triggered by
> > an SCI, the core will just go on and remove the memory, although it may
> > be killing the kernel this way.
> 
> Why would memory go away if a driver is unbound from a device?  The
> device didn't go away.  It's the same if the driver was a module and it
> was unloaded, you should not turn memory off in that situation, right?

Right.  It looks like there's some confusion about the role of .remove()
in the ACPI subsystem, but I need to investigate it a bit more.

> Are you also going to prevent module unloading of this driver?

I'm not sure what I'm going to do with that driver at the moment to be honest. :-)

> > Arguably, this may be considered as the core's fault, but the only way to
> > fix that would be to move the code from that driver into the core and not to
> > register it as a "driver" any more.  Which was my point. :-)
> 
> No, I think people are totally overreacting to the unbind/bind files,
> which are there to aid in development, and in adding new device ids to
> drivers, as well as sometimes doing a hacky revoke() call.
> 
> > > Please don't confuse unbind with any "normal" system operation, it is
> > > not to be used for memory hotplug, or anything else like this.
> > > 
> > > Also, if you really do not want to do this, turn off the ability to
> > > unbind/bind for these devices, that is under your control in your bus
> > > logic.
> > 
> > OK, but how?  I'm looking at driver_unbind() and not seeing any way to do
> > that actually.
> 
> See the suppress_bind_attrs field in struct device_driver.  It's even
> documented in device.h, but sadly, no one reads documentation :)

That's good to know, thanks. :-)

And if I knew I could find that information in device.h, I'd look in there.

> I recommend you set this field if you don't want the bind/unbind files
> to show up for your memory driver, although I would argue that the
> driver needs to be fixed up to not do foolish things like removing
> memory from a system unless it really does go away...

Quite frankly, I need to look at that driver and how things are supposed to
work more thoroughly, because I don't seem to see a reason to do various
things the way they are done.  Well, maybe it's just me.

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
