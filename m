Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 41A476B0074
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 11:51:46 -0500 (EST)
Message-ID: <1354207397.26955.417.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 29 Nov 2012 09:43:17 -0700
In-Reply-To: <2315811.arm7RJr4ey@vostro.rjw.lan>
References: 
	<1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	 <1354150952.26955.377.camel@misato.fc.hp.com>
	 <1354151742.26955.385.camel@misato.fc.hp.com>
	 <2315811.arm7RJr4ey@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-acpi@vger.kernel.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2012-11-29 at 11:03 +0100, Rafael J. Wysocki wrote:
> On Wednesday, November 28, 2012 06:15:42 PM Toshi Kani wrote:
> > On Wed, 2012-11-28 at 18:02 -0700, Toshi Kani wrote:
> > > On Thu, 2012-11-29 at 00:49 +0100, Rafael J. Wysocki wrote:
> > > > On Wednesday, November 28, 2012 02:02:48 PM Toshi Kani wrote:
> > > > If we disabled exposing
> > > > acpi_eject_store() for memory devices, then the only way would be from the
> > > > notify handler.  So I wonder if driver_unbind() shouldn't just uninstall the
> > > > notify handler for memory (so that memory eject events are simply dropped on
> > > > the floor after unbinding the driver)?
> > > 
> > > If driver_unbind() happens before an eject request, we do not have a
> > > problem.  acpi_eject_store() fails if a driver is not bound to the
> > > device.  acpi_memory_device_notify() fails as well.
> > > 
> > > The race condition Wen pointed out (see the top of this email) is that
> > > driver_unbind() may come in while eject operation is in-progress.  This
> > > is why I mentioned the following in previous email.
> > > 
> > > > So, we basically need to either 1) serialize
> > > > acpi_bus_hot_remove_device() and driver_unbind(), or 2) make
> > > > acpi_bus_hot_remove_device() to fail if driver_unbind() is run
> > > > during the operation.
> > 
> > Forgot to mention.  The 3rd option is what Greg said -- use the
> > suppress_bind_attrs field.  I think this is a good option to address
> > this race condition for now.  For a long term solution, we should have a
> > better infrastructure in place to address such issue in general.
> 
> Well, in the meantime I've had a look at acpi_bus_hot_remove_device() and
> friends and I think there's a way to address all of these problems
> without big redesign (for now).
> 
> First, why don't we introduce an ACPI device flag (in the flags field of
> struct acpi_device) called eject_forbidden or something like this such that:
> 
> (1) It will be clear by default.
> (2) It may only be set by a driver's .add() routine if necessary.
> (3) Once set, it may only be cleared by the driver's .remove() routine if
>     it's safe to physically remove the device after the .remove().
> 
> Then, after the .remove() (which must be successful) has returned, and the
> flag is set, it will tell acpi_bus_remove() to return a specific error code
> (such as -EBUSY or -EAGAIN).  It doesn't matter if .remove() was called
> earlier, because if it left the flag set, there's no way to clear it afterward
> and acpi_bus_remove() will see it set anyway.  I think the struct acpi_device
> should be unregistered anyway if that error code is to be returned.

I like the idea!  It's a good intermediate solution if we need to keep
the bind/unbind interface.  That said, I still prefer to go with option
3) for now.  I do not see much reason to keep the bind/unbind interface
for ACPI hotplug drivers, and it seems that the semantics of .remove()
is .remove_driver(), not .remove_device() for driver_unbind().  So, I
think we should disable the bind/unbind interface until we settle this
issue.

> [By the way, do you know where we free the memory allocated for struct
>  acpi_device objects?]

device_release() -> acpi_device_release().

> Now if acpi_bus_trim() gets that error code from acpi_bus_remove(), it should
> store it, but continue the trimming normally and finally it should return that
> error code to acpi_bus_hot_remove_device().
> 
> Now, if acpi_bus_hot_remove_device() gets that error code, it should just
> reverse the whole trimming (i.e. trigger acpi_bus_scan() from the device
> we attempted to eject) and notify the firmware about the failure.
> 
> If we have that, then the memory hotplug driver would only need to set
> flags.eject_forbidden in its .add() routine and make its .remove() routine
> only clear that flag if it is safe to actually remove the memory.
> 
> Does this make sense to you?

In high-level, yes.  Rollback strategy, such as we should continue the
trimming after an error, is something we need to think about along with
the framework design.  I think we need a good framework before
implementing rollback.

> [BTW, using _PS3 in acpi_bus_hot_remove_device() directly to power off the
>  device is a nonsense, because this method is not guaranteed to turn the power
>  off in the first place (it may just put the device into D3hot).  If anything,
>  acpi_device_set_power() should be used for that, but even that is not
>  guaranteed to actually remove the power (power resources may be shared with
>  other devices, so in fact that operation should be done by acpi_bus_trim()
>  for each of the trimmed devices.]

I agree.  I cannot tell for other vendor's implementation, but I expect
that _EJ0 takes care of the power state after it is ejected.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
