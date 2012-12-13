Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E751E6B005A
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 13:30:26 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so942756dak.14
        for <linux-mm@kvack.org>; Thu, 13 Dec 2012 10:30:26 -0800 (PST)
Date: Thu, 13 Dec 2012 10:30:21 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH 00/11] Hot-plug and Online/Offline framework
Message-ID: <20121213183021.GC9606@kroah.com>
References: <1355354243-18657-1-git-send-email-toshi.kani@hp.com>
 <20121212235657.GD22764@kroah.com>
 <1355359176.18964.41.camel@misato.fc.hp.com>
 <20121213005510.GA9220@kroah.com>
 <1355369864.18964.68.camel@misato.fc.hp.com>
 <20121213041627.GA14083@kroah.com>
 <1355414634.18964.158.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1355414634.18964.158.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "rjw@sisk.pl" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "bhelgaas@google.com" <bhelgaas@google.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "srivatsa.bhat@linux.vnet.ibm.com" <srivatsa.bhat@linux.vnet.ibm.com>

On Thu, Dec 13, 2012 at 09:03:54AM -0700, Toshi Kani wrote:
> On Thu, 2012-12-13 at 04:16 +0000, Greg KH wrote:
> > On Wed, Dec 12, 2012 at 08:37:44PM -0700, Toshi Kani wrote:
> > > On Wed, 2012-12-12 at 16:55 -0800, Greg KH wrote:
> > > > On Wed, Dec 12, 2012 at 05:39:36PM -0700, Toshi Kani wrote:
> > > > > On Wed, 2012-12-12 at 15:56 -0800, Greg KH wrote:
> > > > > > On Wed, Dec 12, 2012 at 04:17:12PM -0700, Toshi Kani wrote:
> > > > > > > This patchset is an initial prototype of proposed hot-plug framework
> > > > > > > for design review.  The hot-plug framework is designed to provide 
> > > > > > > the common framework for hot-plugging and online/offline operations
> > > > > > > of system devices, such as CPU, Memory and Node.  While this patchset
> > > > > > > only supports ACPI-based hot-plug operations, the framework itself is
> > > > > > > designed to be platform-neural and can support other FW architectures
> > > > > > > as necessary.
> > > > > > > 
> > > > > > > The patchset has not been fully tested yet, esp. for memory hot-plug.
> > > > > > > Any help for testing will be very appreciated since my test setup
> > > > > > > is limited.
> > > > > > > 
> > > > > > > The patchset is based on the linux-next branch of linux-pm.git tree.
> > > > > > > 
> > > > > > > Overview of the Framework
> > > > > > > =========================
> > > > > > 
> > > > > > <snip>
> > > > > > 
> > > > > > Why all the new framework, doesn't the existing bus infrastructure
> > > > > > provide everything you need here?  Shouldn't you just be putting your
> > > > > > cpus and memory sticks on a bus and handle stuff that way?  What makes
> > > > > > these types of devices so unique from all other devices that Linux has
> > > > > > been handling in a dynamic manner (i.e. hotplugging them) for many many
> > > > > > years?
> > > > > > 
> > > > > > Why are you reinventing the wheel?
> > > > > 
> > > > > Good question.  Yes, USB and PCI hotplug operate based on their bus
> > > > > structures.  USB and PCI cards only work under USB and PCI bus
> > > > > controllers.  So, their framework can be composed within the bus
> > > > > structures as you pointed out.
> > > > > 
> > > > > However, system devices such CPU and memory do not have their standard
> > > > > bus.  ACPI allows these system devices to be enumerated, but it does not
> > > > > make ACPI as the HW bus hierarchy for CPU and memory, unlike PCI and
> > > > > USB.  Therefore, CPU and memory modules manage CPU and memory outside of
> > > > > ACPI.  This makes sense because CPU and memory can be used without ACPI.
> > > > > 
> > > > > This leads us an issue when we try to manage system device hotplug
> > > > > within ACPI, because ACPI does not control everything.  This patchset
> > > > > provides a common hotplug framework for system devices, which both ACPI
> > > > > and non-ACPI modules (i.e. CPU and memory modules) can participate and
> > > > > are coordinated for their hotplug operations.  This is analogous to the
> > > > > boot-up sequence, which ACPI and non-ACPI modules can participate to
> > > > > enable CPU and memory.
> > > > 
> > > > Then create a "virtual" bus and put the devices you wish to control on
> > > > that.  That is what the "system bus" devices were supposed to be, it's
> > > > about time someone took that code and got it all working properly in
> > > > this way, that is why it was created oh so long ago.
> > > 
> > > It may be the ideal, but it will take us great effort to make such
> > > things to happen based on where we are now.  It is going to be a long
> > > way.  I believe the first step is to make the boot-up flow and hot-plug
> > > flow consistent for system devices.  This is what this patchset is
> > > trying to do.
> > 
> > If you use the system "bus" for this, the "flow" will be identical, that
> > is what the driver core provides for you.  I don't see why you need to
> > implement something that sits next to it and not just use what we
> > already have here.
> 
> Here is very brief boot-up flow.  
> 
> start_kernel()
>   boot_cpu_init()         // init cpu0
>   setup_arch()
>     x86_init.paging.pagetable_init() // init mem pagetable
>   :
> kernel_init()
>   kernel_init_freeable()
>     smp_init()            // init other CPUs
>       :
>     do_basic_setup()
>       driver_init()
>         cpu_dev_init()    // build system/cpu tree
>         memory_dev_init() // build system/memory tree
>       do_initcalls()
>         acpi_init()       // build ACPI device tree
> 
> CPU and memory are initialized at early boot.  The system device tree is
> built at the last step of the boot sequence and is only used for
> providing sysfs interfaces.

Then fix that and create the system device tree earlier.

> That is, the system bus structure has nothing to do with the actual
> CPU and memory initialization at boot.

Then that should be fixed, right?

> Similarly, ACPI drivers do not initialize actual CPU and memory at boot
> as they are also called at the last step.

That should also probably be fixed, right?

> Further, the ACPI device tree and system bus tree are separate
> entities.

That's because ACPI seems to be getting crazy these days, and creating
lots of different devices and tieing it back into the existing device
trees.  Which is fine, see how it's being done with USB for one example
of how this can be done correctly, _if_ you want to keep them separate
(doing so is your own choice, nothing that I'm saying is necessary.)

> Hotplug events are sent to ACPI.

Your hotplug events are being sent there, that's your decision to do so,
it doesn't happen that way with other subsystems that get hotplug events
from ACPI (i.e. PCI hotplug, right?)

> In order to keep the boot flow and hotplug flow consistent, I believe
> the first step is to keep the role of modules consistent between boot
> and hotplug.

I agree, see above for how to resolve that :)

> For instance, acpi_init() only builds ACPI tree at boot, so ACPI
> should only build ACPI tree at hot-add as well.  This keeps ACPI
> drivers to do the same for both boot and hot-add.

Agreed.

> The framework is designed to provide the consistency along with other
> high-availability features such as rollback.

I want my tiny, USB-powered device to have "high-availability", don't
think of that type of functionality as somehow being special, it's what
we have been doing with other subsystems for _years_ now.

Again, I think if you properly tie the system bus code into the CPU work
at the correct location, you can achieve everything you need.  I base
this on the fact that this is what other subsystems and architectures
have been doing for years.  Just because this is ACPI is no reason to
think that it needs to be done differently.

Odds are, s390 has been doing this for 10+ years and none of us realize
this, they are usually that far ahead of the curve if history is any
lesson.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
