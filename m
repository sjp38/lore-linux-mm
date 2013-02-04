Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 7C0906B00A2
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 18:13:44 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug framework
Date: Tue, 05 Feb 2013 00:19:59 +0100
Message-ID: <2002851.rU9bZPbPSe@vostro.rjw.lan>
In-Reply-To: <1360010058.23410.169.camel@misato.fc.hp.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com> <23473445.t1DSaBm58X@vostro.rjw.lan> <1360010058.23410.169.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Monday, February 04, 2013 01:34:18 PM Toshi Kani wrote:
> On Mon, 2013-02-04 at 21:12 +0100, Rafael J. Wysocki wrote:
> > On Monday, February 04, 2013 12:46:24 PM Toshi Kani wrote:
> > > On Mon, 2013-02-04 at 20:48 +0100, Rafael J. Wysocki wrote:
> > > > On Monday, February 04, 2013 09:02:46 AM Toshi Kani wrote:
> > > > > On Mon, 2013-02-04 at 14:41 +0100, Rafael J. Wysocki wrote:
> > > > > > On Sunday, February 03, 2013 07:23:49 PM Greg KH wrote:
> > > > > > > On Sat, Feb 02, 2013 at 09:15:37PM +0100, Rafael J. Wysocki wrote:
> > > > > > > > On Saturday, February 02, 2013 03:58:01 PM Greg KH wrote:
> > > > >   :
> > > > > > > > Yes, but those are just remove events and we can only see how destructive they
> > > > > > > > were after the removal.  The point is to be able to figure out whether or not
> > > > > > > > we *want* to do the removal in the first place.
> > > > > > > 
> > > > > > > Yes, but, you will always race if you try to test to see if you can shut
> > > > > > > down a device and then trying to do it.  So walking the bus ahead of
> > > > > > > time isn't a good idea.
> > > > > > >
> > > > > > > And, we really don't have a viable way to recover if disconnect() fails,
> > > > > > > do we.  What do we do in that situation, restore the other devices we
> > > > > > > disconnected successfully?  How do we remember/know what they were?
> > > > > > > 
> > > > > > > PCI hotplug almost had this same problem until the designers finally
> > > > > > > realized that they just had to accept the fact that removing a PCI
> > > > > > > device could either happen by:
> > > > > > > 	- a user yanking out the device, at which time the OS better
> > > > > > > 	  clean up properly no matter what happens
> > > > > > > 	- the user asked nicely to remove a device, and the OS can take
> > > > > > > 	  as long as it wants to complete that action, including
> > > > > > > 	  stalling for noticable amounts of time before eventually,
> > > > > > > 	  always letting the action succeed.
> > > > > > > 
> > > > > > > I think the second thing is what you have to do here.  If a user tells
> > > > > > > the OS it wants to remove these devices, you better do it.  If you
> > > > > > > can't, because memory is being used by someone else, either move them
> > > > > > > off, or just hope that nothing bad happens, before the user gets
> > > > > > > frustrated and yanks out the CPU/memory module themselves physically :)
> > > > > > 
> > > > > > Well, that we can't help, but sometimes users really *want* the OS to tell them
> > > > > > if it is safe to unplug something at this particualr time (think about the
> > > > > > Windows' "safe remove" feature for USB sticks, for example; that came out of
> > > > > > users' demand AFAIR).
> > > > > > 
> > > > > > So in my opinion it would be good to give them an option to do "safe eject" or
> > > > > > "forcible eject", whichever they prefer.
> > > > > 
> > > > > For system device hot-plug, it always needs to be "safe eject".  This
> > > > > feature will be implemented on mission critical servers, which are
> > > > > managed by professional IT folks.  Crashing a server causes serious
> > > > > money to the business.
> > > > 
> > > > Well, "always" is a bit too strong a word as far as human behavior is concerned
> > > > in my opinion.
> > > > 
> > > > That said I would be perfectly fine with not supporting the "forcible eject" to
> > > > start with and waiting for the first request to add support for it.  I also
> > > > would be fine with taking bets on how much time it's going to take for such a
> > > > request to appear. :-)
> > > 
> > > Sounds good.  In my experience, though, it actually takes a LONG time to
> > > convince customers that "safe eject" is actually safe.  Enterprise
> > > customers are so afraid of doing anything risky that might cause the
> > > system to crash or hang due to some defect.  I would be very surprised
> > > to see a customer asking for a force operation when we do not guarantee
> > > its outcome.  I have not seen such enterprise customers yet.
> > 
> > But we're talking about a kernel that is supposed to run on mobile phones too,
> > among other things.
> 
> I think using this feature for RAS i.e. replacing a faulty device
> on-line, will continue to be limited for high-end systems.  For low-end
> systems, it does not make sense for customers to pay much $$ for this
> feature.  They can just shut the system down for replacement, or they
> can simply buy a new system instead of repairing.
> 
> That said, using this feature on VM for workload balancing does not
> require any special hardware.  So, I can see someone willing to try out
> to see how it goes with a force option on VM for personal use.   

Besides, SMP was a $$ "enterprise" feature not so long ago, so things tend to
change. :-)

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
