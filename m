Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id D01676B004D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 17:34:37 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on rebind scenario
Date: Wed, 28 Nov 2012 23:39:22 +0100
Message-ID: <11009650.oKuHEgoNWB@vostro.rjw.lan>
In-Reply-To: <1354140982.26955.341.camel@misato.fc.hp.com>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com> <1451747.3VlxbhJES4@vostro.rjw.lan> <1354140982.26955.341.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: linux-acpi@vger.kernel.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, Wen Congyang <wency@cn.fujitsu.com>, Wen Congyang <wencongyang@gmail.com>, isimatu.yasuaki@jp.fujitsu.com, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wednesday, November 28, 2012 03:16:22 PM Toshi Kani wrote:
> > > > > > > I see.  I do not think whether or not the device is removed on eject
> > > > > > > makes any difference here.  The issue is that after driver_unbind() is
> > > > > > > done, acpi_bus_hot_remove_device() no longer calls the ACPI memory
> > > > > > > driver (hence, it cannot fail in prepare_remove), and goes ahead to call
> > > > > > > _EJ0.  If driver_unbind() did off-line the memory, this is OK.  However,
> > > > > > > it cannot off-line kernel memory ranges.  So, we basically need to
> > > > > > > either 1) serialize acpi_bus_hot_remove_device() and driver_unbind(), or
> > > > > > > 2) make acpi_bus_hot_remove_device() to fail if driver_unbind() is run
> > > > > > > during the operation.
> > > > > > 
> > > > > > OK, I see the problem now.
> > > > > > 
> > > > > > What exactly is triggering the driver_unbind() in this scenario?
> > > > > 
> > > > > User can request driver_unbind() from sysfs as follows.  I do not see
> > > > > much reason why user has to do for memory, though.
> > > > > 
> > > > > echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
> > > > 
> > > > This is wrong.  Even if we want to permit user space to forcibly unbind
> > > > drivers from anything like this, we should at least check for some
> > > > situations in which it is plain dangerous.  Like in this case.  So I think
> > > > the above should fail unless we know that the driver won't be necessary
> > > > to handle hot-removal of memory.
> > > 
> > > Well, we tried twice already... :)
> > > https://lkml.org/lkml/2012/11/16/649
> > 
> > I didn't mean driver_unbind() should fail.  The code path that executes
> > driver_unbind() eventually should fail _before_ executing it.
> 
> driver_unbind() is the handler, so it is called directly from this
> unbind interface.

Yes, sorry for the confusion.

So, it looks like the driver core wants us to handle driver unbinding no
matter what.

This pretty much means that it is a bad idea to have a driver that is
exposed as a "device driver" in sysfs for memory hotplugging.

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
