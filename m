Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 918DC6B0005
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 08:35:00 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug framework
Date: Mon, 04 Feb 2013 14:41:15 +0100
Message-ID: <5192355.CsKHU8mj3W@vostro.rjw.lan>
In-Reply-To: <20130204012349.GA6433@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com> <1810611.i6Sc4oLaux@vostro.rjw.lan> <20130204012349.GA6433@kroah.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Sunday, February 03, 2013 07:23:49 PM Greg KH wrote:
> On Sat, Feb 02, 2013 at 09:15:37PM +0100, Rafael J. Wysocki wrote:
> > On Saturday, February 02, 2013 03:58:01 PM Greg KH wrote:
> > > On Fri, Feb 01, 2013 at 11:12:59PM +0100, Rafael J. Wysocki wrote:
> > > > On Friday, February 01, 2013 08:23:12 AM Greg KH wrote:
> > > > > On Thu, Jan 31, 2013 at 09:54:51PM +0100, Rafael J. Wysocki wrote:
> > > > > > > > But, again, I'm going to ask why you aren't using the existing cpu /
> > > > > > > > memory / bridge / node devices that we have in the kernel.  Please use
> > > > > > > > them, or give me a _really_ good reason why they will not work.
> > > > > > > 
> > > > > > > We cannot use the existing system devices or ACPI devices here.  During
> > > > > > > hot-plug, ACPI handler sets this shp_device info, so that cpu and memory
> > > > > > > handlers (drivers/cpu.c and mm/memory_hotplug.c) can obtain their target
> > > > > > > device information in a platform-neutral way.  During hot-add, we first
> > > > > > > creates an ACPI device node (i.e. device under /sys/bus/acpi/devices),
> > > > > > > but platform-neutral modules cannot use them as they are ACPI-specific.
> > > > > > 
> > > > > > But suppose we're smart and have ACPI scan handlers that will create
> > > > > > "physical" device nodes for those devices during the ACPI namespace scan.
> > > > > > Then, the platform-neutral nodes will be able to bind to those "physical"
> > > > > > nodes.  Moreover, it should be possible to get a hierarchy of device objects
> > > > > > this way that will reflect all of the dependencies we need to take into
> > > > > > account during hot-add and hot-remove operations.  That may not be what we
> > > > > > have today, but I don't see any *fundamental* obstacles preventing us from
> > > > > > using this approach.
> > > > > 
> > > > > I would _much_ rather see that be the solution here as I think it is the
> > > > > proper one.
> > > > > 
> > > > > > This is already done for PCI host bridges and platform devices and I don't
> > > > > > see why we can't do that for the other types of devices too.
> > > > > 
> > > > > I agree.
> > > > > 
> > > > > > The only missing piece I see is a way to handle the "eject" problem, i.e.
> > > > > > when we try do eject a device at the top of a subtree and need to tear down
> > > > > > the entire subtree below it, but if that's going to lead to a system crash,
> > > > > > for example, we want to cancel the eject.  It seems to me that we'll need some
> > > > > > help from the driver core here.
> > > > > 
> > > > > I say do what we always have done here, if the user asked us to tear
> > > > > something down, let it happen as they are the ones that know best :)
> > > > > 
> > > > > Seriously, I guess this gets back to the "fail disconnect" idea that the
> > > > > ACPI developers keep harping on.  I thought we already resolved this
> > > > > properly by having them implement it in their bus code, no reason the
> > > > > same thing couldn't happen here, right?
> > > > 
> > > > Not really. :-)  We haven't ever resolved that particular issue I'm afraid.
> > > 
> > > Ah, I didn't realize that.
> > > 
> > > > > I don't think the core needs to do anything special, but if so, I'll be glad
> > > > > to review it.
> > > > 
> > > > OK, so this is the use case.  We have "eject" defined for something like
> > > > a container with a number of CPU cores, PCI host bridge, and a memory
> > > > controller under it.  And a few pretty much arbitrary I/O devices as a bonus.
> > > > 
> > > > Now, there's a button on the system case labeled as "Eject" and if that button
> > > > is pressed, we're supposed to _try_ to eject all of those things at once.  We
> > > > are allowed to fail that request, though, if that's problematic for some
> > > > reason, but we're supposed to let the BIOS know about that.
> > > > 
> > > > Do you seriously think that if that button is pressed, we should just proceed
> > > > with removing all that stuff no matter what?  That'd be kind of like Russian
> > > > roulette for whoever pressed that button, because s/he could only press it and
> > > > wait for the system to either crash or not.  Or maybe to crash a bit later
> > > > because of some delayed stuff that would hit one of those devices that had just
> > > > gone.  Surely not a situation any admin of a high-availability system would
> > > > like to be in. :-)
> > > > 
> > > > Quite frankly, I have no idea how that can be addressed in a single bus type,
> > > > let alone ACPI (which is not even a proper bus type, just something pretending
> > > > to be one).
> > > 
> > > You don't have it as a single bus type, you have a controller somewhere,
> > > off of the bus being destroyed, that handles sending remove events to
> > > the device and tearing everything down.  PCI does this from the very
> > > beginning.
> > 
> > Yes, but those are just remove events and we can only see how destructive they
> > were after the removal.  The point is to be able to figure out whether or not
> > we *want* to do the removal in the first place.
> 
> Yes, but, you will always race if you try to test to see if you can shut
> down a device and then trying to do it.  So walking the bus ahead of
> time isn't a good idea.
>
> And, we really don't have a viable way to recover if disconnect() fails,
> do we.  What do we do in that situation, restore the other devices we
> disconnected successfully?  How do we remember/know what they were?
> 
> PCI hotplug almost had this same problem until the designers finally
> realized that they just had to accept the fact that removing a PCI
> device could either happen by:
> 	- a user yanking out the device, at which time the OS better
> 	  clean up properly no matter what happens
> 	- the user asked nicely to remove a device, and the OS can take
> 	  as long as it wants to complete that action, including
> 	  stalling for noticable amounts of time before eventually,
> 	  always letting the action succeed.
> 
> I think the second thing is what you have to do here.  If a user tells
> the OS it wants to remove these devices, you better do it.  If you
> can't, because memory is being used by someone else, either move them
> off, or just hope that nothing bad happens, before the user gets
> frustrated and yanks out the CPU/memory module themselves physically :)

Well, that we can't help, but sometimes users really *want* the OS to tell them
if it is safe to unplug something at this particualr time (think about the
Windows' "safe remove" feature for USB sticks, for example; that came out of
users' demand AFAIR).

So in my opinion it would be good to give them an option to do "safe eject" or
"forcible eject", whichever they prefer.

> > Say you have a computing node which signals a hardware problem in a processor
> > package (the container with CPU cores, memory, PCI host bridge etc.).  You
> > may want to eject that package, but you don't want to kill the system this
> > way.  So if the eject is doable, it is very much desirable to do it, but if it
> > is not doable, you'd rather shut the box down and do the replacement afterward.
> > That may be costly, however (maybe weeks of computations), so it should be
> > avoided if possible, but not at the expense of crashing the box if the eject
> > doesn't work out.
> 
> These same "situations" came up for PCI hotplug, and I still say the
> same resolution there holds true, as described above.  The user wants to
> remove something, so let them do it.  They always know best, and get mad
> at us if we think otherwise :)

Well, not necessarily.  Users sometimes really don't know what they are doing
and want us to give them a hint.  My opinion is that if we can give them a
hint, there's no reason not to.

> What does the ACPI spec say about this type of thing?  Surely the same
> people that did the PCI Hotplug spec were consulted when doing this part
> of the spec, right?  Yeah, I know, I can dream...

It's not very specific (as usual), but it gives hints. :-)

For example, there is the _OST method (Section 6.3.5 of ACPI 5) that we are
supposed to use to notify the platform of ejection failures and there are
status codes like "0x81: Device in use by application" or "0x82: Device busy"
that can be used in there.  So definitely the authors took ejection failures
for software-related reasons into consideration.

> > > I know it's more complicated with these types of devices, and I think we
> > > are getting closer to the correct solution, I just don't want to ever
> > > see duplicate devices in the driver model for the same physical device.
> > 
> > Do you mean two things based on struct device for the same hardware component?
> > That's been happening already pretty much forever for every PCI device known
> > to the ACPI layer, for PNP and many others.  However, those ACPI things are (or
> > rather should be, but we're going to clean that up) only for convenience (to be
> > able to see the namespace structure and related things in sysfs).  So the stuff
> > under /sys/devices/LNXSYSTM\:00/ is not "real".
> 
> Yes, I've never treated that as a "real" device because they (usually)
> didn't ever bind to the "real" driver that controlled the device and how
> it talked to the rest of the os (like a USB device for example.)  I
> always thought just of it as a "shadow" of the firmware image, nothing
> that should be directly operated on if at all possible.

Precisely.  That's why I'd like to move that stuff away from /sys/devices/
and I don't see a reason why these objects should be based on struct device.
They need kobjects to show up in sysfs, but apart from this they don't really
need anything from struct device as far as I can say.

> But, as you are pointing out, maybe this needs to be changed.  Having
> users have to look in one part of the tree for one interface to a
> device, and another totally different part for a different interface to
> the same physical device is crazy, don't you agree?

Well, it is confusing.  I don't have a problem with exposing the ACPI namespace
in the form of a directory structure in sysfs and I see some benefits from
doing that, but I'd like it to be clear what's represented by that directory
structure and I don't want people to confuse ACPI device objects with devices
(they are abstract interfaces to devices rather than anything else).

> As to how to solve it, I really have no idea, I don't know ACPI that
> well at all, and honestly, don't want to, I want to keep what little
> hair I have left...

I totally understand you. :-)

> > In my view it shouldn't even
> > be under /sys/devices/ (/sys/firmware/acpi/ seems to be a better place for it),
> 
> I agree.
> 
> > but that may be difficult to change without breaking user space (maybe we can
> > just symlink it from /sys/devices/ or something).  And the ACPI bus type
> > shouldn't even exist in my opinion.
> > 
> > There's much confusion in there and much work to clean that up, I agree, but
> > that's kind of separate from the hotplug thing.
> 
> I agree as well.
> 
> Best of luck.

Thanks. :-)

Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
