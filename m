Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 535236B0025
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 11:12:58 -0500 (EST)
Message-ID: <1359993766.23410.105.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device
 hotplug framework
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 04 Feb 2013 09:02:46 -0700
In-Reply-To: <5192355.CsKHU8mj3W@vostro.rjw.lan>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
	 <1810611.i6Sc4oLaux@vostro.rjw.lan> <20130204012349.GA6433@kroah.com>
	 <5192355.CsKHU8mj3W@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Greg KH <gregkh@linuxfoundation.org>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Mon, 2013-02-04 at 14:41 +0100, Rafael J. Wysocki wrote:
> On Sunday, February 03, 2013 07:23:49 PM Greg KH wrote:
> > On Sat, Feb 02, 2013 at 09:15:37PM +0100, Rafael J. Wysocki wrote:
> > > On Saturday, February 02, 2013 03:58:01 PM Greg KH wrote:
  :
> > > Yes, but those are just remove events and we can only see how destructive they
> > > were after the removal.  The point is to be able to figure out whether or not
> > > we *want* to do the removal in the first place.
> > 
> > Yes, but, you will always race if you try to test to see if you can shut
> > down a device and then trying to do it.  So walking the bus ahead of
> > time isn't a good idea.
> >
> > And, we really don't have a viable way to recover if disconnect() fails,
> > do we.  What do we do in that situation, restore the other devices we
> > disconnected successfully?  How do we remember/know what they were?
> > 
> > PCI hotplug almost had this same problem until the designers finally
> > realized that they just had to accept the fact that removing a PCI
> > device could either happen by:
> > 	- a user yanking out the device, at which time the OS better
> > 	  clean up properly no matter what happens
> > 	- the user asked nicely to remove a device, and the OS can take
> > 	  as long as it wants to complete that action, including
> > 	  stalling for noticable amounts of time before eventually,
> > 	  always letting the action succeed.
> > 
> > I think the second thing is what you have to do here.  If a user tells
> > the OS it wants to remove these devices, you better do it.  If you
> > can't, because memory is being used by someone else, either move them
> > off, or just hope that nothing bad happens, before the user gets
> > frustrated and yanks out the CPU/memory module themselves physically :)
> 
> Well, that we can't help, but sometimes users really *want* the OS to tell them
> if it is safe to unplug something at this particualr time (think about the
> Windows' "safe remove" feature for USB sticks, for example; that came out of
> users' demand AFAIR).
> 
> So in my opinion it would be good to give them an option to do "safe eject" or
> "forcible eject", whichever they prefer.

For system device hot-plug, it always needs to be "safe eject".  This
feature will be implemented on mission critical servers, which are
managed by professional IT folks.  Crashing a server causes serious
money to the business.

A user yanking out a system device won't happen, and it immediately
crashes the system if it is done.  So, we have nothing to do with this
case.  The 2nd case can hang the operation, waiting forever to proceed,
which is still a serious issue for enterprise customers.


> > > Say you have a computing node which signals a hardware problem in a processor
> > > package (the container with CPU cores, memory, PCI host bridge etc.).  You
> > > may want to eject that package, but you don't want to kill the system this
> > > way.  So if the eject is doable, it is very much desirable to do it, but if it
> > > is not doable, you'd rather shut the box down and do the replacement afterward.
> > > That may be costly, however (maybe weeks of computations), so it should be
> > > avoided if possible, but not at the expense of crashing the box if the eject
> > > doesn't work out.
> > 
> > These same "situations" came up for PCI hotplug, and I still say the
> > same resolution there holds true, as described above.  The user wants to
> > remove something, so let them do it.  They always know best, and get mad
> > at us if we think otherwise :)
> 
> Well, not necessarily.  Users sometimes really don't know what they are doing
> and want us to give them a hint.  My opinion is that if we can give them a
> hint, there's no reason not to.
> 
> > What does the ACPI spec say about this type of thing?  Surely the same
> > people that did the PCI Hotplug spec were consulted when doing this part
> > of the spec, right?  Yeah, I know, I can dream...
> 
> It's not very specific (as usual), but it gives hints. :-)
> 
> For example, there is the _OST method (Section 6.3.5 of ACPI 5) that we are
> supposed to use to notify the platform of ejection failures and there are
> status codes like "0x81: Device in use by application" or "0x82: Device busy"
> that can be used in there.  So definitely the authors took ejection failures
> for software-related reasons into consideration.

That is correct.  Also, ACPI spec deliberately does not define
implementation details, so we defined DIG64 hotplug spec below (which I
contributed to the spec.)

http://www.dig64.org/home/DIG64_HPPF_R1_0.pdf

For example, Figure 2 in page 14 states memory hot-remove flow.  The
operation needs to either succeed or fail.  Crash or hang is not an
option.


Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
