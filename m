Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id D22726B0080
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 15:21:04 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on rebind scenario
Date: Thu, 29 Nov 2012 21:25:48 +0100
Message-ID: <1666001.sopVksfMvY@vostro.rjw.lan>
In-Reply-To: <1354211790.26955.443.camel@misato.fc.hp.com>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <20121129113030.GB639@dhcp-192-168-178-175.profitbricks.localdomain> <1354211790.26955.443.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thursday, November 29, 2012 10:56:30 AM Toshi Kani wrote:
> On Thu, 2012-11-29 at 12:30 +0100, Vasilis Liaskovitis wrote:
> > On Thu, Nov 29, 2012 at 11:03:05AM +0100, Rafael J. Wysocki wrote:
> > > On Wednesday, November 28, 2012 06:15:42 PM Toshi Kani wrote:
> > > > On Wed, 2012-11-28 at 18:02 -0700, Toshi Kani wrote:
> > > > > On Thu, 2012-11-29 at 00:49 +0100, Rafael J. Wysocki wrote:
> > > > > > On Wednesday, November 28, 2012 02:02:48 PM Toshi Kani wrote:
> > > > > > > > > > > > > > Consider the following case:
> > > > > > > > > > > > > > 
> > > > > > > > > > > > > > We hotremove the memory device by SCI and unbind it from the driver at the same time:
> > > > > > > > > > > > > > 
> > > > > > > > > > > > > > CPUa                                                  CPUb
> > > > > > > > > > > > > > acpi_memory_device_notify()
> > > > > > > > > > > > > >                                        unbind it from the driver
> > > > > > > > > > > > > >     acpi_bus_hot_remove_device()
> > > > > > > > > > > > > 
> > [...]
> > > Well, in the meantime I've had a look at acpi_bus_hot_remove_device() and
> > > friends and I think there's a way to address all of these problems
> > > without big redesign (for now).
> > > 
> > > First, why don't we introduce an ACPI device flag (in the flags field of
> > > struct acpi_device) called eject_forbidden or something like this such that:
> > > 
> > > (1) It will be clear by default.
> > > (2) It may only be set by a driver's .add() routine if necessary.
> > > (3) Once set, it may only be cleared by the driver's .remove() routine if
> > >     it's safe to physically remove the device after the .remove().
> > > 
> > > Then, after the .remove() (which must be successful) has returned, and the
> > > flag is set, it will tell acpi_bus_remove() to return a specific error code
> > > (such as -EBUSY or -EAGAIN).  It doesn't matter if .remove() was called
> > > earlier, because if it left the flag set, there's no way to clear it afterward
> > > and acpi_bus_remove() will see it set anyway.  I think the struct acpi_device
> > > should be unregistered anyway if that error code is to be returned.
> > > 
> > > [By the way, do you know where we free the memory allocated for struct
> > >  acpi_device objects?]
> > > 
> > > Now if acpi_bus_trim() gets that error code from acpi_bus_remove(), it should
> > > store it, but continue the trimming normally and finally it should return that
> > > error code to acpi_bus_hot_remove_device().
> > 
> > Side-note: In the pre_remove patches, acpi_bus_trim actually returns on the
> > first error from acpi_bus_remove (e.g. when memory offlining in pre_remove
> > fails). Trimming is not continued. 
> > 
> > Normally, acpi_bus_trim keeps trimming as you say, and always returns the last
> > error. Is this the desired behaviour that we want to keep for bus_trim? (This is
> > more a general question, not specific to the eject_forbidden suggestion)
> 
> Your change makes sense to me.  At least until we have rollback code in
> place, we need to fail as soon as we hit an error.

Are you sure this makes sense?  What happens to the devices that we have
trimmed already and then there's an error?  Looks like they are just unusable
going forward, aren't they?

> > > Now, if acpi_bus_hot_remove_device() gets that error code, it should just
> > > reverse the whole trimming (i.e. trigger acpi_bus_scan() from the device
> > > we attempted to eject) and notify the firmware about the failure.
> > 
> > sounds like this rollback needs to be implemented in any solution we choose
> > to implement, correct?
> 
> Yes, rollback is necessary.  But I do not think we need to include it
> into your patch, though.

As the first step, we should just trim everything and then return an error
code in my opinion.

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
