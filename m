Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D29316B006E
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 16:55:11 -0500 (EST)
Message-ID: <1354225604.7776.37.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 29 Nov 2012 14:46:44 -0700
In-Reply-To: <5067588.Jc88xNrCFc@vostro.rjw.lan>
References: 
	<1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	 <1666001.sopVksfMvY@vostro.rjw.lan>
	 <1354221519.7776.10.camel@misato.fc.hp.com>
	 <5067588.Jc88xNrCFc@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2012-11-29 at 22:23 +0100, Rafael J. Wysocki wrote:
> On Thursday, November 29, 2012 01:38:39 PM Toshi Kani wrote:
> > On Thu, 2012-11-29 at 21:25 +0100, Rafael J. Wysocki wrote:
> > > On Thursday, November 29, 2012 10:56:30 AM Toshi Kani wrote:
> > > > On Thu, 2012-11-29 at 12:30 +0100, Vasilis Liaskovitis wrote:
> > > > > Side-note: In the pre_remove patches, acpi_bus_trim actually returns on the
> > > > > first error from acpi_bus_remove (e.g. when memory offlining in pre_remove
> > > > > fails). Trimming is not continued. 
> > > > > 
> > > > > Normally, acpi_bus_trim keeps trimming as you say, and always returns the last
> > > > > error. Is this the desired behaviour that we want to keep for bus_trim? (This is
> > > > > more a general question, not specific to the eject_forbidden suggestion)
> > > > 
> > > > Your change makes sense to me.  At least until we have rollback code in
> > > > place, we need to fail as soon as we hit an error.
> > > 
> > > Are you sure this makes sense?  What happens to the devices that we have
> > > trimmed already and then there's an error?  Looks like they are just unusable
> > > going forward, aren't they?
> > 
> > Yes, the devices trimmed already are released from the kernel, and their
> > memory ranges become unusable.  This is bad.  But I do not think we
> > should trim further to make more devices unusable after an error. 
> > 
> > 
> > > > > > Now, if acpi_bus_hot_remove_device() gets that error code, it should just
> > > > > > reverse the whole trimming (i.e. trigger acpi_bus_scan() from the device
> > > > > > we attempted to eject) and notify the firmware about the failure.
> > > > > 
> > > > > sounds like this rollback needs to be implemented in any solution we choose
> > > > > to implement, correct?
> > > > 
> > > > Yes, rollback is necessary.  But I do not think we need to include it
> > > > into your patch, though.
> > > 
> > > As the first step, we should just trim everything and then return an error
> > > code in my opinion.
> > 
> > But we cannot trim devices with kernel memory.
> 
> Well, let's put it this way: If we started a trim, we should just do it
> completely, in which case we know we can go for the eject, or we should
> roll it back completely.  Now, if you just break the trim on first error,
> the complete rollback is kind of problematic.  It should be doable, but
> it won't be easy.  On the other hand, if you go for the full trim,
> doing a rollback is trivial, it's as though you have reinserted the whole
> stuff.

acpi_bus_check_add() skips initialization when an ACPI device already
has its associated acpi_device.  So, I think it works either way.


> Now, that need not harm functionality, and that's why I proposed the
> eject_forbidden flag, so that .remove() can say "I'm not done, please
> rollback", in which case the device can happily function going forward,
> even if we don't rebind the driver to it.

A partially trimmed acpi_device is hard to rollback.  acpi_device should
be either trimmed completely or intact.  When a function failed to trim
an acpi_device, it needs to rollback its operation for the device before
returning an error.  This is because only the failed function has enough
context to rollback when an error occurred in the middle of its
procedure.

Thanks,
-Toshi  




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
