Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 5938E6B0005
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 20:42:25 -0500 (EST)
Message-ID: <1359682338.15120.209.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device
 hotplug framework
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 31 Jan 2013 18:32:18 -0700
In-Reply-To: <9860755.q4y3PrCFZx@vostro.rjw.lan>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
	 <20130130045830.GH30002@kroah.com>
	 <1359601065.15120.156.camel@misato.fc.hp.com>
	 <9860755.q4y3PrCFZx@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Greg KH <gregkh@linuxfoundation.org>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Thu, 2013-01-31 at 21:54 +0100, Rafael J. Wysocki wrote:
> On Wednesday, January 30, 2013 07:57:45 PM Toshi Kani wrote:
> > On Tue, 2013-01-29 at 23:58 -0500, Greg KH wrote:
> > > On Thu, Jan 10, 2013 at 04:40:19PM -0700, Toshi Kani wrote:
 :
> > > > +};
> > > > +
> > > > +struct shp_device {
> > > > +	struct list_head	list;
> > > > +	struct device		*device;
> > > 
> > > No, make it a "real" device, embed the device into it.
> > 
> > This device pointer is used to send KOBJ_ONLINE/OFFLINE event during CPU
> > online/offline operation in order to maintain the current behavior.  CPU
> > online/offline operation only changes the state of CPU, so its
> > system/cpu device continues to be present before and after an operation.
> > (Whereas, CPU hot-add/delete operation creates or removes a system/cpu
> > device.)  So, this "*device" needs to be a pointer to reference an
> > existing device that is to be on-lined/off-lined.
> > 
> > > But, again, I'm going to ask why you aren't using the existing cpu /
> > > memory / bridge / node devices that we have in the kernel.  Please use
> > > them, or give me a _really_ good reason why they will not work.
> > 
> > We cannot use the existing system devices or ACPI devices here.  During
> > hot-plug, ACPI handler sets this shp_device info, so that cpu and memory
> > handlers (drivers/cpu.c and mm/memory_hotplug.c) can obtain their target
> > device information in a platform-neutral way.  During hot-add, we first
> > creates an ACPI device node (i.e. device under /sys/bus/acpi/devices),
> > but platform-neutral modules cannot use them as they are ACPI-specific.
> 
> But suppose we're smart and have ACPI scan handlers that will create
> "physical" device nodes for those devices during the ACPI namespace scan.
> Then, the platform-neutral nodes will be able to bind to those "physical"
> nodes.  Moreover, it should be possible to get a hierarchy of device objects
> this way that will reflect all of the dependencies we need to take into
> account during hot-add and hot-remove operations.  That may not be what we
> have today, but I don't see any *fundamental* obstacles preventing us from
> using this approach.

I misstated in my previous email.  system/cpu device is actually created
by ACPI driver during ACPI scan in case of hot-add.  This is done by 
acpi_processor_hotadd_init(), which I consider as a hack but can be
done.  system/memory device is created in add_memory() by the mm module.

> This is already done for PCI host bridges and platform devices and I don't
> see why we can't do that for the other types of devices too.
> 
> The only missing piece I see is a way to handle the "eject" problem, i.e.
> when we try do eject a device at the top of a subtree and need to tear down
> the entire subtree below it, but if that's going to lead to a system crash,
> for example, we want to cancel the eject.  It seems to me that we'll need some
> help from the driver core here.

There are three different approaches suggested for system device
hot-plug:
 A. Proceed within system device bus scan.
 B. Proceed within ACPI bus scan.
 C. Proceed with a sequence (as a mini-boot).

Option A uses system devices as tokens, option B uses acpi devices as
tokens, and option C uses resource tables as tokens, for their handlers.

Here is summary of key questions & answers so far.  I hope this
clarifies why I am suggesting option 3.

1. What are the system devices?
System devices provide system-wide core computing resources, which are
essential to compose a computer system.  System devices are not
connected to any particular standard buses.

2. Why are the system devices special?
The system devices are initialized during early boot-time, by multiple
subsystems, from the boot-up sequence, in pre-defined order.  They
provide low-level services to enable other subsystems to come up.

3. Why can't initialize the system devices from the driver structure at
boot?
The driver structure is initialized at the end of the boot sequence and
requires the low-level services from the system devices initialized
beforehand.

4. Why do we need a new common framework?
Sysfs CPU and memory on-lining/off-lining are performed within the CPU
and memory modules.  They are common code and do not depend on ACPI.
Therefore, a new common framework is necessary to integrate both
on-lining/off-lining operation and hot-plugging operation of system
devices into a single framework.

5. Why can't do everything with ACPI bus scan?
Software dependency among system devices may not be dictated by the ACPI
hierarchy.  For instance, memory should be initialized before CPUs (i.e.
a new cpu may need its local memory), but such ordering cannot be
guaranteed by the ACPI hierarchy.  Also, as described in 4,
online/offline operations are independent from ACPI.  

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
