Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 16A838D0011
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 15:27:44 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on rebind scenario
Date: Thu, 06 Dec 2012 21:32:39 +0100
Message-ID: <3500918.ab8V1kPRPP@vostro.rjw.lan>
In-Reply-To: <1354808489.20543.31.camel@misato.fc.hp.com>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <14429189.LmXxfguqbu@vostro.rjw.lan> <1354808489.20543.31.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thursday, December 06, 2012 08:41:29 AM Toshi Kani wrote:
> On Thu, 2012-12-06 at 13:50 +0100, Rafael J. Wysocki wrote:
> > On Thursday, December 06, 2012 10:30:19 AM Vasilis Liaskovitis wrote:
> > > Hi,
> > > On Thu, Nov 29, 2012 at 10:44:11AM -0700, Toshi Kani wrote:
> > > > On Thu, 2012-11-29 at 12:04 +0100, Vasilis Liaskovitis wrote:
> > > > 
> > > > Yes, that's what I had in mind along with device_lock().  I think the
> > > > lock is necessary to close the window.
> > > > http://www.spinics.net/lists/linux-mm/msg46973.html
> > > > 
> > > > But as I mentioned in other email, I prefer option 3 with
> > > > suppress_bind_attrs.  So, yes, please take a look to see how it works
> > > > out.
> > > 
> > > I tested the suppress_bind_attrs and it works by simply setting it to true
> > > before driver registration e.g. 
> > > 
> > > --- a/drivers/acpi/scan.c
> > > +++ b/drivers/acpi/scan.c
> > > @@ -783,7 +783,8 @@ int acpi_bus_register_driver(struct acpi_driver *driver)
> > >  	driver->drv.name = driver->name;
> > >  	driver->drv.bus = &acpi_bus_type;
> > >  	driver->drv.owner = driver->owner;
> > > -
> > > +    if (!strcmp(driver->class, "memory"))
> > > +        driver->drv.suppress_bind_attrs = true;
> > >  	ret = driver_register(&driver->drv);
> > >  	return ret;
> > >  }
> > > 
> > > No bind/unbind sysfs files are created when using this, as expected.
> > > I assume we only want to suppress for acpi_memhotplug
> > > (class=ACPI_MEMORY_DEVICE_CLASS i.e. "memory") devices.
> > > 
> > > Is there agreement on what acpi_bus_trim behaviour and rollback (if any) we
> > > want to have for the current ACPI framework (partial trim or full trim on
> > > failure)?
> > 
> > Last time I suggested to split the trimming so that first we only unbind
> > drivers (and roll back that part, ie. rebind the drivers on errors) and
> > next we remove the struct acpi_device objects, just before doing the actual
> > eject.  So there would be two walks of the hierarchy below the device we want
> > to eject, one for driver unbinding (that can be rolled back) and one for the
> > actual removal.
> > 
> > Toshi Kani seemed to agree with that and there were no follow-ups.
> 
> I was hoping to have a short term solution to fix the panic on
> attempting to delete a kernel memory range, assuming that the memory
> hot-plug feature is going to make into 3.8.  It's a blocker issue for
> testing the feature.  Now that the VM patchset does not seem to make
> into 3.8, I think we can step back and focus on a long term solution
> toward 3.9.
> 
> I agree that we should separate resource online/offlining step and
> acpi_device creation/deletion step.  It can address the panic and make
> rollback easier to handle.  For 3.9, we should have a better framework
> in place to handle it in general.  So, I am currently working on a
> framework proposal, and hopefully able to send it out in a week or so.

Cool, thanks for doing this!

> Lastly, thanks Vasilis for testing the suppress_bind_attrs change.  I
> think we may still need it for 3.9.

Well, we'll see. :-)

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
