Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 725A16B0005
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 09:31:48 -0500 (EST)
Date: Mon, 4 Feb 2013 06:33:52 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug
 framework
Message-ID: <20130204143351.GA20119@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
 <5876609.Ic1nhHW6N2@vostro.rjw.lan>
 <20130204124810.GB22096@kroah.com>
 <2048116.Qo8UgQ5hjb@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2048116.Qo8UgQ5hjb@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Toshi Kani <toshi.kani@hp.com>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Mon, Feb 04, 2013 at 03:21:22PM +0100, Rafael J. Wysocki wrote:
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
> 
> So say dev is about to be used for something incompatible with ejecting, so to
> speak.  Then, one would do platform_lock_eject(dev), which would check if dev
> has an ACPI handle and then take acpi_eject_lock (if so).  The return value of
> platform_lock_eject(dev) would need to be checked to see if the device is not
> gone.  If it returns success (0), one would do something to the device and
> call platform_no_eject(dev) and then platform_unlock_eject(dev).

How does a device "know" it is doing something that is incompatible with
ejecting?  That's a non-trivial task from what I can tell.

What happens if a device wants to set that flag, right after it was told
to eject and the device was in the middle of being removed?  How can you
"fail" the "I can't be removed me now, so don't" requirement that it now
has?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
