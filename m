Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id F08EB6B00CF
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 20:05:39 -0500 (EST)
Message-ID: <1360025729.23410.257.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device
 hotplug framework
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 04 Feb 2013 17:55:29 -0700
In-Reply-To: <7003418.onqVlaaHJS@vostro.rjw.lan>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
	 <5598823.8hjkkMP1h9@vostro.rjw.lan>
	 <1360016009.23410.213.camel@misato.fc.hp.com>
	 <7003418.onqVlaaHJS@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Greg KH <gregkh@linuxfoundation.org>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Tue, 2013-02-05 at 00:52 +0100, Rafael J. Wysocki wrote:
> On Monday, February 04, 2013 03:13:29 PM Toshi Kani wrote:
> > On Mon, 2013-02-04 at 21:07 +0100, Rafael J. Wysocki wrote:
> > > On Monday, February 04, 2013 06:33:52 AM Greg KH wrote:
> > > > On Mon, Feb 04, 2013 at 03:21:22PM +0100, Rafael J. Wysocki wrote:
> > > > > On Monday, February 04, 2013 04:48:10 AM Greg KH wrote:
> > > > > > On Sun, Feb 03, 2013 at 09:44:39PM +0100, Rafael J. Wysocki wrote:
> > > > > > > > Yes, but those are just remove events and we can only see how destructive they
> > > > > > > > were after the removal.  The point is to be able to figure out whether or not
> > > > > > > > we *want* to do the removal in the first place.
> > > > > > > > 
> > > > > > > > Say you have a computing node which signals a hardware problem in a processor
> > > > > > > > package (the container with CPU cores, memory, PCI host bridge etc.).  You
> > > > > > > > may want to eject that package, but you don't want to kill the system this
> > > > > > > > way.  So if the eject is doable, it is very much desirable to do it, but if it
> > > > > > > > is not doable, you'd rather shut the box down and do the replacement afterward.
> > > > > > > > That may be costly, however (maybe weeks of computations), so it should be
> > > > > > > > avoided if possible, but not at the expense of crashing the box if the eject
> > > > > > > > doesn't work out.
> > > > > > > 
> > > > > > > It seems to me that we could handle that with the help of a new flag, say
> > > > > > > "no_eject", in struct device, a global mutex, and a function that will walk
> > > > > > > the given subtree of the device hierarchy and check if "no_eject" is set for
> > > > > > > any devices in there.  Plus a global "no_eject" switch, perhaps.
> > > > > > 
> > > > > > I think this will always be racy, or at worst, slow things down on
> > > > > > normal device operations as you will always be having to grab this flag
> > > > > > whenever you want to do something new.
> > > > > 
> > > > > I don't see why this particular scheme should be racy, at least I don't see any
> > > > > obvious races in it (although I'm not that good at races detection in general,
> > > > > admittedly).
> > > > > 
> > > > > Also, I don't expect that flag to be used for everything, just for things known
> > > > > to seriously break if forcible eject is done.  That may be not precise enough,
> > > > > so that's a matter of defining its purpose more precisely.
> > > > > 
> > > > > We can do something like that on the ACPI level (ie. introduce a no_eject flag
> > > > > in struct acpi_device and provide an iterface for the layers above ACPI to
> > > > > manipulate it) but then devices without ACPI namespace objects won't be
> > > > > covered.  That may not be a big deal, though.
> > > > > 
> > > > > So say dev is about to be used for something incompatible with ejecting, so to
> > > > > speak.  Then, one would do platform_lock_eject(dev), which would check if dev
> > > > > has an ACPI handle and then take acpi_eject_lock (if so).  The return value of
> > > > > platform_lock_eject(dev) would need to be checked to see if the device is not
> > > > > gone.  If it returns success (0), one would do something to the device and
> > > > > call platform_no_eject(dev) and then platform_unlock_eject(dev).
> > > > 
> > > > How does a device "know" it is doing something that is incompatible with
> > > > ejecting?  That's a non-trivial task from what I can tell.
> > > 
> > > I agree that this is complicated in general.  But.
> > > 
> > > There are devices known to have software "offline" and "online" operations
> > > such that after the "offline" the given device is guaranteed to be not used
> > > until "online".  We have that for CPU cores, for example, and user space can
> > > do it via /sys/devices/system/cpu/cpuX/online .  So, why don't we make the
> > > "online" set the no_eject flag (under the lock as appropriate) and the
> > > "offline" clear it?  And why don't we define such "online" and "offline" for
> > > all of the other "system" stuff, like memory, PCI host bridges etc. and make it
> > > behave analogously?
> > > 
> > > Then, it is quite simple to say which devices should use the no_eject flag:
> > > devices that have "online" and "offline" exported to user space.  And guess
> > > who's responsible for "offlining" all of those things before trying to eject
> > > them: user space is.  From the kernel's point of view it is all clear.  Hands
> > > clean. :-)
> > > 
> > > Now, there's a different problem how to expose all of the relevant information
> > > to user space so that it knows what to "offline" for the specific eject
> > > operation to succeed, but that's kind of separate and worth addressing
> > > anyway.
> > 
> > So, the idea is to run a user space program that off-lines all relevant
> > devices before trimming ACPI devices.  Is that right?  That sounds like
> > a worth idea to consider with.  This basically moves the "sequencer"
> > part into user space instead of the kernel space in my proposal.  I
> > agree that how to expose all of the relevant info to user space is an
> > issue.  Also, we will need to make sure that the user program always
> > runs per a kernel request and then informs a result back to the kernel,
> > so that the kernel can do the rest of an operation and inform a result
> > to FW with _OST or _EJ0.  This loop has to close.  I think it is going
> > to be more complicated than the kernel-only approach.
> 
> I actually didn't think about that.  The point is that trying to offline
> everything *synchronously* may just be pointless, because it may be
> offlined upfront, before the eject is even requested.  So the sequence
> would be to first offline things that we'll want to eject from user space
> and then to send the eject request (e.g. via sysfs too).
> 
> Eject requests from eject buttons and things like that may just fail if
> some components involved that should be offline are online.  The fact that
> we might be able to offline them synchronously if we tried doesn't matter,
> pretty much as it doesn't matter for hot-swappable disks.
> 
> You'd probably never try to hot-remove a disk before unmounting filesystems
> mounted from it or failing it as a RAID component and nobody sane wants the
> kernel to do things like that automatically when the user presses the eject
> button.  In my opinion we should treat memory eject, or CPU package eject, or
> PCI host bridge eject in exactly the same way: Don't eject if it is not
> prepared for ejecting in the first place.
> 
> And if you think about it, that makes things *massively* simpler, because now
> the kernel doesn't heed to worry about all of those "synchronous removal"
> scenarions that very well may involve every single device in the system and
> the whole problem is nicely split into several separate "implement
> offline/online" problems that are subsystem-specific and a single
> "eject if everything relevant is offline" problem which is kind of trivial.
> Plus the one of exposing information to user space, which is separate too.

Oh, I see.  Yes, it certainly makes things really simpler.  It will
bring burden to a user, but it could be solved with proper tools.  I
totally agree that I/Os should be removed beforehand.  For CPUs and
memory, it would be a bad TCE for asking a user to find a right set of
the devices to off-line, but this could be addressed with proper tools.
I think we need to check if memory block (a unit of sysfs memory
online/offline) and an ACPI memory object actually corresponds nicely.
But in high-level, this sounds like a workable plan.


> Now, each of them can be worked on separately, *tested* separately and
> debugged separately if need be and it is much easier to isolate failures
> and so on.

Right, but it is also the case with "synchronous removal" as long as we
have sysfs online interface.  The difference is that this approach only
supports sysfs interface for off-lining.


> > In addition, I am not sure if the "no_eject" flag in acpi_device is
> > really necessary here since the user program will inform the kernel if
> > all devices are off-line.  Also, the kernel will likely need to expose
> > the device info to the user program to tell which devices need to be
> > off-lined.  At that time, the kernel already knows if there is any
> > on-line device in the scope.
> 
> Well, that depends no what "the kernel" means and how it knows that.  Surely
> the "online" components have to be marked somehow so that it is easy to check
> if they are in the scope in the subsystem-independent way, so why don't we use
> something like the no_eject flag for that?

Yes, I see your point.  My previous comment assumed that the kernel
would have to obtain device info and tell a user program to off-line
them.  In such case, I thought we would have to walk thru the actual
device tree and see online/offline info anyway.  But, since we are not
doing anything like that, having the flag in acpi_device seems to be a
reasonable way to avoid dealing with the actual device tree.


Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
