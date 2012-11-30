Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D85FC6B0044
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 20:18:05 -0500 (EST)
Message-ID: <1354237778.7776.98.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 29 Nov 2012 18:09:38 -0700
In-Reply-To: <1525935.BNLeevluWK@vostro.rjw.lan>
References: 
	<1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	 <3341852.kzFLTzlKxq@vostro.rjw.lan>
	 <1354231039.7776.80.camel@misato.fc.hp.com>
	 <1525935.BNLeevluWK@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-acpi@vger.kernel.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2012-11-30 at 01:13 +0100, Rafael J. Wysocki wrote:
> On Thursday, November 29, 2012 04:17:19 PM Toshi Kani wrote:
> > On Thu, 2012-11-29 at 23:11 +0100, Rafael J. Wysocki wrote:
> > > On Thursday, November 29, 2012 02:46:44 PM Toshi Kani wrote:
> > > > On Thu, 2012-11-29 at 22:23 +0100, Rafael J. Wysocki wrote:
> > > > > On Thursday, November 29, 2012 01:38:39 PM Toshi Kani wrote:
> > > > > Now, that need not harm functionality, and that's why I proposed the
> > > > > eject_forbidden flag, so that .remove() can say "I'm not done, please
> > > > > rollback", in which case the device can happily function going forward,
> > > > > even if we don't rebind the driver to it.
> > > > 
> > > > A partially trimmed acpi_device is hard to rollback.  acpi_device should
> > > > be either trimmed completely or intact.
> > > 
> > > I may or may not agree, depending on what you mean by "trimmed". :-)
> > > 
> > > > When a function failed to trim
> > > > an acpi_device, it needs to rollback its operation for the device before
> > > > returning an error.
> > > 
> > > Unless it is .remove(), because .remove() is supposed to always succeed
> > > (ie. unbind the driver from the device).  However, it may signal the caller
> > > that something's fishy, by setting a flag in the device object, for example.
> > 
> > Right, .remove() cannot fail.  We still need to check if we should
> > continue to use .remove(), though.
> > 
> > As for the flag, are you thinking that we call acpi_bus_trim() with
> > rmdevice false first, so that it won't remove acpi_device?
> 
> I'm not sure if that's going to help.
> 
> Definitely, .remove() should just unbind the driver from the device.
> That's what it's supposed to do.  Still, it may leave some information for
> the caller in the device structure itself.  For example, "I have unbound
> from the device, but it is not safe to remove it physically".

Right.

> I'm now thinking that we may need to rework the trimming so that
> .remove() is called for all drivers first and the struct acpi_device
> objects are not removed at this stage.  Then, if .remove() from one
> driver signals the situation like above, the routine will have to
> rebind the drivers that have been unbound and we're done.
> 
> After that stage, when all drivers have been unbound, we should be
> able to go for full eject.  First, we can drop all struct acpi_device
> objects in the relevant subtree and then we can run _EJ0.

I agree that such approach is worth pursuing.

> > > > This is because only the failed function has enough
> > > > context to rollback when an error occurred in the middle of its
> > > > procedure.
> > > 
> > > Not really.  If it actually removes the struct acpi_device then the caller
> > > may run acpi_bus_scan() on that device if necessary.  There may be a problem
> > > if the device has an associated physical node (or more of them), but that
> > > requires special care anyway.
> > 
> > Well, hot-remove to a device fails when there is a reason to fail.  IOW,
> > such reason prevented the device to be removed safely.  So, I think we
> > need to put it back to the original state in this case.  Removing it by
> > ignoring the cause of failure sounds unsafe to me.  Some status/data may
> > be left un-deleted as a result.
> 
> Again, I may or may not agree with that, depending on whether you're talking
> about physical devices or about struct acpi_device objects.

Sorry, by "hot-remove a device", I was referring removing struct
acpi_device and off-lining its resource.  By "left un-delted", I was
referring its resource left un-deleted, such as memory ranges.

> Anyway, I agree that removing struct acpi_device objects may not be worth the
> effort if we're going to re-create them in a while, because that may be costly.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
