Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B2B2F6B002D
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 11:29:18 -0500 (EST)
Message-ID: <1359994749.23410.113.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device
 hotplug framework
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 04 Feb 2013 09:19:09 -0700
In-Reply-To: <2048116.Qo8UgQ5hjb@vostro.rjw.lan>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
	 <5876609.Ic1nhHW6N2@vostro.rjw.lan> <20130204124810.GB22096@kroah.com>
	 <2048116.Qo8UgQ5hjb@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Greg KH <gregkh@linuxfoundation.org>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Mon, 2013-02-04 at 15:21 +0100, Rafael J. Wysocki wrote:
> On Monday, February 04, 2013 04:48:10 AM Greg KH wrote:
> > On Sun, Feb 03, 2013 at 09:44:39PM +0100, Rafael J. Wysocki wrote:
> > > > Yes, but those are just remove events and we can only see how destructive they
> > > > were after the removal.  The point is to be able to figure out whether or not
> > > > we *want* to do the removal in the first place.
> > > > 
> > > > Say you have a computing node which signals a hardware problem in a processor
> > > > package (the container with CPU cores, memory, PCI host bridge etc.).  You
> > > > may want to eject that package, but you don't want to kill the system this
> > > > way.  So if the eject is doable, it is very much desirable to do it, but if it
> > > > is not doable, you'd rather shut the box down and do the replacement afterward.
> > > > That may be costly, however (maybe weeks of computations), so it should be
> > > > avoided if possible, but not at the expense of crashing the box if the eject
> > > > doesn't work out.
> > > 
> > > It seems to me that we could handle that with the help of a new flag, say
> > > "no_eject", in struct device, a global mutex, and a function that will walk
> > > the given subtree of the device hierarchy and check if "no_eject" is set for
> > > any devices in there.  Plus a global "no_eject" switch, perhaps.
> > 
> > I think this will always be racy, or at worst, slow things down on
> > normal device operations as you will always be having to grab this flag
> > whenever you want to do something new.
> 
> I don't see why this particular scheme should be racy, at least I don't see any
> obvious races in it (although I'm not that good at races detection in general,
> admittedly).
> 
> Also, I don't expect that flag to be used for everything, just for things known
> to seriously break if forcible eject is done.  That may be not precise enough,
> so that's a matter of defining its purpose more precisely.
> 
> We can do something like that on the ACPI level (ie. introduce a no_eject flag
> in struct acpi_device and provide an iterface for the layers above ACPI to
> manipulate it) but then devices without ACPI namespace objects won't be
> covered.  That may not be a big deal, though.

I am afraid that bringing the device status management into the ACPI
level would not a good idea.  acpi_device should only reflect ACPI
device object information, not how its actual device is being used.

I like your initiative of acpi_scan_driver and I think scanning /
trimming of ACPI object info is what the ACPI drivers should do.


Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
