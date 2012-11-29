Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 7233C6B006E
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 06:30:37 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so7236451bkc.14
        for <linux-mm@kvack.org>; Thu, 29 Nov 2012 03:30:35 -0800 (PST)
Date: Thu, 29 Nov 2012 12:30:30 +0100
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
Message-ID: <20121129113030.GB639@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
 <1354150952.26955.377.camel@misato.fc.hp.com>
 <1354151742.26955.385.camel@misato.fc.hp.com>
 <2315811.arm7RJr4ey@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2315811.arm7RJr4ey@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Toshi Kani <toshi.kani@hp.com>, linux-acpi@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 29, 2012 at 11:03:05AM +0100, Rafael J. Wysocki wrote:
> On Wednesday, November 28, 2012 06:15:42 PM Toshi Kani wrote:
> > On Wed, 2012-11-28 at 18:02 -0700, Toshi Kani wrote:
> > > On Thu, 2012-11-29 at 00:49 +0100, Rafael J. Wysocki wrote:
> > > > On Wednesday, November 28, 2012 02:02:48 PM Toshi Kani wrote:
> > > > > > > > > > > > Consider the following case:
> > > > > > > > > > > > 
> > > > > > > > > > > > We hotremove the memory device by SCI and unbind it from the driver at the same time:
> > > > > > > > > > > > 
> > > > > > > > > > > > CPUa                                                  CPUb
> > > > > > > > > > > > acpi_memory_device_notify()
> > > > > > > > > > > >                                        unbind it from the driver
> > > > > > > > > > > >     acpi_bus_hot_remove_device()
> > > > > > > > > > > 
[...]
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
> 
> [By the way, do you know where we free the memory allocated for struct
>  acpi_device objects?]
> 
> Now if acpi_bus_trim() gets that error code from acpi_bus_remove(), it should
> store it, but continue the trimming normally and finally it should return that
> error code to acpi_bus_hot_remove_device().

Side-note: In the pre_remove patches, acpi_bus_trim actually returns on the
first error from acpi_bus_remove (e.g. when memory offlining in pre_remove
fails). Trimming is not continued. 

Normally, acpi_bus_trim keeps trimming as you say, and always returns the last
error. Is this the desired behaviour that we want to keep for bus_trim? (This is
more a general question, not specific to the eject_forbidden suggestion)

> 
> Now, if acpi_bus_hot_remove_device() gets that error code, it should just
> reverse the whole trimming (i.e. trigger acpi_bus_scan() from the device
> we attempted to eject) and notify the firmware about the failure.

sounds like this rollback needs to be implemented in any solution we choose
to implement, correct?

> 
> If we have that, then the memory hotplug driver would only need to set
> flags.eject_forbidden in its .add() routine and make its .remove() routine
> only clear that flag if it is safe to actually remove the memory.
> 

But when .remove op is called, we are already in the irreversible/error-free
removal (final removal step).
Maybe we need to reset eject_forbidden in a prepare_remove operation which
handles the removal part that can fail ?

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
