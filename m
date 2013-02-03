Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 294A76B0002
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 15:38:25 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug framework
Date: Sun, 03 Feb 2013 21:44:39 +0100
Message-ID: <5876609.Ic1nhHW6N2@vostro.rjw.lan>
In-Reply-To: <1810611.i6Sc4oLaux@vostro.rjw.lan>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com> <20130202145801.GB1434@kroah.com> <1810611.i6Sc4oLaux@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Saturday, February 02, 2013 09:15:37 PM Rafael J. Wysocki wrote:
> On Saturday, February 02, 2013 03:58:01 PM Greg KH wrote:
> > On Fri, Feb 01, 2013 at 11:12:59PM +0100, Rafael J. Wysocki wrote:
> > > On Friday, February 01, 2013 08:23:12 AM Greg KH wrote:
> > > > On Thu, Jan 31, 2013 at 09:54:51PM +0100, Rafael J. Wysocki wrote:
> > > > > > > But, again, I'm going to ask why you aren't using the existing cpu /
> > > > > > > memory / bridge / node devices that we have in the kernel.  Please use
> > > > > > > them, or give me a _really_ good reason why they will not work.
> > > > > > 
> > > > > > We cannot use the existing system devices or ACPI devices here.  During
> > > > > > hot-plug, ACPI handler sets this shp_device info, so that cpu and memory
> > > > > > handlers (drivers/cpu.c and mm/memory_hotplug.c) can obtain their target
> > > > > > device information in a platform-neutral way.  During hot-add, we first
> > > > > > creates an ACPI device node (i.e. device under /sys/bus/acpi/devices),
> > > > > > but platform-neutral modules cannot use them as they are ACPI-specific.
> > > > > 
> > > > > But suppose we're smart and have ACPI scan handlers that will create
> > > > > "physical" device nodes for those devices during the ACPI namespace scan.
> > > > > Then, the platform-neutral nodes will be able to bind to those "physical"
> > > > > nodes.  Moreover, it should be possible to get a hierarchy of device objects
> > > > > this way that will reflect all of the dependencies we need to take into
> > > > > account during hot-add and hot-remove operations.  That may not be what we
> > > > > have today, but I don't see any *fundamental* obstacles preventing us from
> > > > > using this approach.
> > > > 
> > > > I would _much_ rather see that be the solution here as I think it is the
> > > > proper one.
> > > > 
> > > > > This is already done for PCI host bridges and platform devices and I don't
> > > > > see why we can't do that for the other types of devices too.
> > > > 
> > > > I agree.
> > > > 
> > > > > The only missing piece I see is a way to handle the "eject" problem, i.e.
> > > > > when we try do eject a device at the top of a subtree and need to tear down
> > > > > the entire subtree below it, but if that's going to lead to a system crash,
> > > > > for example, we want to cancel the eject.  It seems to me that we'll need some
> > > > > help from the driver core here.
> > > > 
> > > > I say do what we always have done here, if the user asked us to tear
> > > > something down, let it happen as they are the ones that know best :)
> > > > 
> > > > Seriously, I guess this gets back to the "fail disconnect" idea that the
> > > > ACPI developers keep harping on.  I thought we already resolved this
> > > > properly by having them implement it in their bus code, no reason the
> > > > same thing couldn't happen here, right?
> > > 
> > > Not really. :-)  We haven't ever resolved that particular issue I'm afraid.
> > 
> > Ah, I didn't realize that.
> > 
> > > > I don't think the core needs to do anything special, but if so, I'll be glad
> > > > to review it.
> > > 
> > > OK, so this is the use case.  We have "eject" defined for something like
> > > a container with a number of CPU cores, PCI host bridge, and a memory
> > > controller under it.  And a few pretty much arbitrary I/O devices as a bonus.
> > > 
> > > Now, there's a button on the system case labeled as "Eject" and if that button
> > > is pressed, we're supposed to _try_ to eject all of those things at once.  We
> > > are allowed to fail that request, though, if that's problematic for some
> > > reason, but we're supposed to let the BIOS know about that.
> > > 
> > > Do you seriously think that if that button is pressed, we should just proceed
> > > with removing all that stuff no matter what?  That'd be kind of like Russian
> > > roulette for whoever pressed that button, because s/he could only press it and
> > > wait for the system to either crash or not.  Or maybe to crash a bit later
> > > because of some delayed stuff that would hit one of those devices that had just
> > > gone.  Surely not a situation any admin of a high-availability system would
> > > like to be in. :-)
> > > 
> > > Quite frankly, I have no idea how that can be addressed in a single bus type,
> > > let alone ACPI (which is not even a proper bus type, just something pretending
> > > to be one).
> > 
> > You don't have it as a single bus type, you have a controller somewhere,
> > off of the bus being destroyed, that handles sending remove events to
> > the device and tearing everything down.  PCI does this from the very
> > beginning.
> 
> Yes, but those are just remove events and we can only see how destructive they
> were after the removal.  The point is to be able to figure out whether or not
> we *want* to do the removal in the first place.
> 
> Say you have a computing node which signals a hardware problem in a processor
> package (the container with CPU cores, memory, PCI host bridge etc.).  You
> may want to eject that package, but you don't want to kill the system this
> way.  So if the eject is doable, it is very much desirable to do it, but if it
> is not doable, you'd rather shut the box down and do the replacement afterward.
> That may be costly, however (maybe weeks of computations), so it should be
> avoided if possible, but not at the expense of crashing the box if the eject
> doesn't work out.

It seems to me that we could handle that with the help of a new flag, say
"no_eject", in struct device, a global mutex, and a function that will walk
the given subtree of the device hierarchy and check if "no_eject" is set for
any devices in there.  Plus a global "no_eject" switch, perhaps.

To be more precise, suppose we have a "no_eject" flag that is set for a device
when the kernel is about to start using it in such a way that ejecting it would
lead to serious trouble (i.e. it is a memory module holding the kernel's page
tables or something like that).  Next, suppose that we have a function called,
say, "device_may_eject()" that will walk the subtree of the device hierarchy
starting at the given node and return false if any of the devices in there have
"no_eject" set.  Further, require that device_may_eject() has to be called
under a global mutex called something like "device_eject_lock".  Then, we can
arrange things as follows:

1. When a device is about to be used for such purposes that it shouldn't be
   ejected, the relevant code should:
  (a) Acquire device_eject_lock.
  (b) Check if the device is still there and go to (e) if not.
  (c) Do whatever needs to be done to the device.
  (d) Set the device's no_eject flag.
  (e) Release device_eject_lock.

2. When an eject operation is about to be carried out on a subtree of the device
   hierarchy, the eject code (be it ACPI or something else) should:
  (a) Acquire device_eject_lock.
  (b) Call device_may_eject() on the starting device and go to (d) if it
      returns false.
  (c) Carry out the eject (that includes calling .remove() from all of the
      involved drivers in partiular).
  (d) Release device_eject_lock.

3. When it is OK to eject the device again, the relevant code should just clear
   its "no_eject" flag under device_eject_lock.

If we want to synchronize that with such things like boot or system suspend,
a global "no_eject" switch can be used for that (it needs to be manipulated
under device_eject_lock) and one more step (check the global "no_eject") is
needed between 2(a) and 2(b).

Does it look like a reasonable approach?

Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
