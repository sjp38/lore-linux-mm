Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 934EC6B0007
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 18:22:59 -0500 (EST)
Message-ID: <1359760370.23410.4.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device
 hotplug framework
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 01 Feb 2013 16:12:50 -0700
In-Reply-To: <2370118.yuaZBuKn6n@vostro.rjw.lan>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
	 <20130201073010.GC1180@kroah.com>
	 <1359751210.15120.278.camel@misato.fc.hp.com>
	 <2370118.yuaZBuKn6n@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Greg KH <gregkh@linuxfoundation.org>, "lenb@kernel.org" <lenb@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "bhelgaas@google.com" <bhelgaas@google.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "srivatsa.bhat@linux.vnet.ibm.com" <srivatsa.bhat@linux.vnet.ibm.com>

On Fri, 2013-02-01 at 23:21 +0100, Rafael J. Wysocki wrote:
> On Friday, February 01, 2013 01:40:10 PM Toshi Kani wrote:
> > On Fri, 2013-02-01 at 07:30 +0000, Greg KH wrote:
> > > On Thu, Jan 31, 2013 at 06:32:18PM -0700, Toshi Kani wrote:
> > >  > This is already done for PCI host bridges and platform devices and I don't
> > > > > see why we can't do that for the other types of devices too.
> > > > > 
> > > > > The only missing piece I see is a way to handle the "eject" problem, i.e.
> > > > > when we try do eject a device at the top of a subtree and need to tear down
> > > > > the entire subtree below it, but if that's going to lead to a system crash,
> > > > > for example, we want to cancel the eject.  It seems to me that we'll need some
> > > > > help from the driver core here.
> > > > 
> > > > There are three different approaches suggested for system device
> > > > hot-plug:
> > > >  A. Proceed within system device bus scan.
> > > >  B. Proceed within ACPI bus scan.
> > > >  C. Proceed with a sequence (as a mini-boot).
> > > > 
> > > > Option A uses system devices as tokens, option B uses acpi devices as
> > > > tokens, and option C uses resource tables as tokens, for their handlers.
> > > > 
> > > > Here is summary of key questions & answers so far.  I hope this
> > > > clarifies why I am suggesting option 3.
> > > > 
> > > > 1. What are the system devices?
> > > > System devices provide system-wide core computing resources, which are
> > > > essential to compose a computer system.  System devices are not
> > > > connected to any particular standard buses.
> > > 
> > > Not a problem, lots of devices are not connected to any "particular
> > > standard busses".  All this means is that system devices are connected
> > > to the "system" bus, nothing more.
> > 
> > Can you give me a few examples of other devices that support hotplug and
> > are not connected to any particular buses?  I will investigate them to
> > see how they are managed to support hotplug.
> > 
> > > > 2. Why are the system devices special?
> > > > The system devices are initialized during early boot-time, by multiple
> > > > subsystems, from the boot-up sequence, in pre-defined order.  They
> > > > provide low-level services to enable other subsystems to come up.
> > > 
> > > Sorry, no, that doesn't mean they are special, nothing here is unique
> > > for the point of view of the driver model from any other device or bus.
> > 
> > I think system devices are unique in a sense that they are initialized
> > before drivers run.
> > 
> > > > 3. Why can't initialize the system devices from the driver structure at
> > > > boot?
> > > > The driver structure is initialized at the end of the boot sequence and
> > > > requires the low-level services from the system devices initialized
> > > > beforehand.
> > > 
> > > Wait, what "driver structure"?  
> > 
> > Sorry it was not clear.  cpu_dev_init() and memory_dev_init() are called
> > from driver_init() at the end of the boot sequence, and initialize
> > system/cpu and system/memory devices.  I assume they are the system bus
> > you are referring with option A.
> > 
> > > If you need to initialize the driver
> > > core earlier, then do so.  Or, even better, just wait until enough of
> > > the system has come up and then go initialize all of the devices you
> > > have found so far as part of your boot process.
> > 
> > They are pseudo drivers that provide sysfs entry points of cpu and
> > memory.  They do not actually initialize cpu and memory.  I do not think
> > initializing cpu and memory fits into the driver model either, since
> > drivers should run after cpu and memory are initialized.
> > 
> > > None of the above things you have stated seem to have anything to do
> > > with your proposed patch, so I don't understand why you have mentioned
> > > them...
> > 
> > You suggested option A before, which uses system bus scan to initialize
> > all system devices at boot time as well as hot-plug.  I tried to say
> > that this option would not be doable.
> > 
> > > > 4. Why do we need a new common framework?
> > > > Sysfs CPU and memory on-lining/off-lining are performed within the CPU
> > > > and memory modules.  They are common code and do not depend on ACPI.
> > > > Therefore, a new common framework is necessary to integrate both
> > > > on-lining/off-lining operation and hot-plugging operation of system
> > > > devices into a single framework.
> > > 
> > > {sigh}
> > > 
> > > Removing and adding devices and handling hotplug operations is what the
> > > driver core was written for, almost 10 years ago.  To somehow think that
> > > your devices are "special" just because they don't use ACPI is odd,
> > > because the driver core itself has nothing to do with ACPI.  Don't get
> > > the current mix of x86 system code tied into ACPI confused with an
> > > driver core issues here please.
> > 
> > CPU online/offline operation is performed within the CPU module.  Memory
> > online/offline operation is performed within the memory module.  CPU and
> > memory hotplug operations are performed within ACPI.  While they deal
> > with the same set of devices, they operate independently and are not
> > managed under a same framework.
> > 
> > I agree with you that not using ACPI is perfectly fine.  My point is
> > that ACPI framework won't be able to manage operations that do not use
> > ACPI.
> > 
> > > > 5. Why can't do everything with ACPI bus scan?
> > > > Software dependency among system devices may not be dictated by the ACPI
> > > > hierarchy.  For instance, memory should be initialized before CPUs (i.e.
> > > > a new cpu may need its local memory), but such ordering cannot be
> > > > guaranteed by the ACPI hierarchy.  Also, as described in 4,
> > > > online/offline operations are independent from ACPI.  
> > > 
> > > That's fine, the driver core is independant from ACPI.  I don't care how
> > > you do the scaning of your devices, but I do care about you creating new
> > > driver core pieces that duplicate the existing functionality of what we
> > > have today.
> > >
> > > In short, I like Rafael's proposal better, and I fail to see how
> > > anything you have stated here would matter in how this is implemented. :)
> > 
> > Doing everything within ACPI means we can only manage ACPI hotplug
> > operations, not online/offline operations.  But I understand that you
> > concern about adding a new framework with option C.  It is good to know
> > that you are fine with option B. :)  So, I will step back, and think
> > about what we can do within ACPI.
> 
> Not much, because ACPI only knows about a subset of devices that may be
> involved in that, and a limited one for that matter.  For one example,
> anything connected through PCI and not having a corresponding ACPI object (i.e.
> pretty much every add-in card in existence) will be unknown to ACPI.  And
> say one of these things is a SATA controller with a number of disks under it
> and so on.  ACPI won't even know that it exists.  Moreover, PCI won't know
> that those disks exist.  Etc.

Agreed.  Thanks for bringing I/Os into the picture.  I did not mention
them since they have not supported in this patchset, but we certainly
need to consider them into the design.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
