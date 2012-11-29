Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A82F16B0085
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 18:25:46 -0500 (EST)
Message-ID: <1354231039.7776.80.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on
 rebind scenario
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 29 Nov 2012 16:17:19 -0700
In-Reply-To: <3341852.kzFLTzlKxq@vostro.rjw.lan>
References: 
	<1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	 <5067588.Jc88xNrCFc@vostro.rjw.lan>
	 <1354225604.7776.37.camel@misato.fc.hp.com>
	 <3341852.kzFLTzlKxq@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-acpi@vger.kernel.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2012-11-29 at 23:11 +0100, Rafael J. Wysocki wrote:
> On Thursday, November 29, 2012 02:46:44 PM Toshi Kani wrote:
> > On Thu, 2012-11-29 at 22:23 +0100, Rafael J. Wysocki wrote:
> > > On Thursday, November 29, 2012 01:38:39 PM Toshi Kani wrote:
> > > 
> > > Well, let's put it this way: If we started a trim, we should just do it
> > > completely, in which case we know we can go for the eject, or we should
> > > roll it back completely.  Now, if you just break the trim on first error,
> > > the complete rollback is kind of problematic.  It should be doable, but
> > > it won't be easy.  On the other hand, if you go for the full trim,
> > > doing a rollback is trivial, it's as though you have reinserted the whole
> > > stuff.
> > 
> > acpi_bus_check_add() skips initialization when an ACPI device already
> > has its associated acpi_device.  So, I think it works either way.
> 
> OK
> 
> > > Now, that need not harm functionality, and that's why I proposed the
> > > eject_forbidden flag, so that .remove() can say "I'm not done, please
> > > rollback", in which case the device can happily function going forward,
> > > even if we don't rebind the driver to it.
> > 
> > A partially trimmed acpi_device is hard to rollback.  acpi_device should
> > be either trimmed completely or intact.
> 
> I may or may not agree, depending on what you mean by "trimmed". :-)
> 
> > When a function failed to trim
> > an acpi_device, it needs to rollback its operation for the device before
> > returning an error.
> 
> Unless it is .remove(), because .remove() is supposed to always succeed
> (ie. unbind the driver from the device).  However, it may signal the caller
> that something's fishy, by setting a flag in the device object, for example.

Right, .remove() cannot fail.  We still need to check if we should
continue to use .remove(), though.

As for the flag, are you thinking that we call acpi_bus_trim() with
rmdevice false first, so that it won't remove acpi_device?

> > This is because only the failed function has enough
> > context to rollback when an error occurred in the middle of its
> > procedure.
> 
> Not really.  If it actually removes the struct acpi_device then the caller
> may run acpi_bus_scan() on that device if necessary.  There may be a problem
> if the device has an associated physical node (or more of them), but that
> requires special care anyway.

Well, hot-remove to a device fails when there is a reason to fail.  IOW,
such reason prevented the device to be removed safely.  So, I think we
need to put it back to the original state in this case.  Removing it by
ignoring the cause of failure sounds unsafe to me.  Some status/data may
be left un-deleted as a result.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
