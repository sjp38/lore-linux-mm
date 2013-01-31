Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 85F866B0002
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 15:48:42 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug framework
Date: Thu, 31 Jan 2013 21:54:51 +0100
Message-ID: <9860755.q4y3PrCFZx@vostro.rjw.lan>
In-Reply-To: <1359601065.15120.156.camel@misato.fc.hp.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com> <20130130045830.GH30002@kroah.com> <1359601065.15120.156.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Wednesday, January 30, 2013 07:57:45 PM Toshi Kani wrote:
> On Tue, 2013-01-29 at 23:58 -0500, Greg KH wrote:
> > On Thu, Jan 10, 2013 at 04:40:19PM -0700, Toshi Kani wrote:
> > > +/*
> > > + * Hot-plug device information
> > > + */
> > 
> > Again, stop it with the "generic" hotplug term here, and everywhere
> > else.  You are doing a very _specific_ type of hotplug devices, so spell
> > it out.  We've worked hard to hotplug _everything_ in Linux, you are
> > going to confuse a lot of people with this type of terms.
> 
> Agreed.  I will clarify in all places.
> 
> > > +union shp_dev_info {
> > > +	struct shp_cpu {
> > > +		u32		cpu_id;
> > > +	} cpu;
> > 
> > What is this?  Why not point to the system device for the cpu?
> 
> This info is used to on-line a new CPU and create its system/cpu device.
> In other word, a system/cpu device is created as a result of CPU
> hotplug.
> 
> > > +	struct shp_memory {
> > > +		int		node;
> > > +		u64		start_addr;
> > > +		u64		length;
> > > +	} mem;
> > 
> > Same here, why not point to the system device?
> 
> Same as above.
> 
> > > +	struct shp_hostbridge {
> > > +	} hb;
> > > +
> > > +	struct shp_node {
> > > +	} node;
> > 
> > What happened here with these?  Empty structures?  Huh?
> 
> They are place holders for now.  PCI bridge hot-plug and node hot-plug
> are still very much work in progress, so I have not integrated them into
> this framework yet.
> 
> > > +};
> > > +
> > > +struct shp_device {
> > > +	struct list_head	list;
> > > +	struct device		*device;
> > 
> > No, make it a "real" device, embed the device into it.
> 
> This device pointer is used to send KOBJ_ONLINE/OFFLINE event during CPU
> online/offline operation in order to maintain the current behavior.  CPU
> online/offline operation only changes the state of CPU, so its
> system/cpu device continues to be present before and after an operation.
> (Whereas, CPU hot-add/delete operation creates or removes a system/cpu
> device.)  So, this "*device" needs to be a pointer to reference an
> existing device that is to be on-lined/off-lined.
> 
> > But, again, I'm going to ask why you aren't using the existing cpu /
> > memory / bridge / node devices that we have in the kernel.  Please use
> > them, or give me a _really_ good reason why they will not work.
> 
> We cannot use the existing system devices or ACPI devices here.  During
> hot-plug, ACPI handler sets this shp_device info, so that cpu and memory
> handlers (drivers/cpu.c and mm/memory_hotplug.c) can obtain their target
> device information in a platform-neutral way.  During hot-add, we first
> creates an ACPI device node (i.e. device under /sys/bus/acpi/devices),
> but platform-neutral modules cannot use them as they are ACPI-specific.

But suppose we're smart and have ACPI scan handlers that will create
"physical" device nodes for those devices during the ACPI namespace scan.
Then, the platform-neutral nodes will be able to bind to those "physical"
nodes.  Moreover, it should be possible to get a hierarchy of device objects
this way that will reflect all of the dependencies we need to take into
account during hot-add and hot-remove operations.  That may not be what we
have today, but I don't see any *fundamental* obstacles preventing us from
using this approach.

This is already done for PCI host bridges and platform devices and I don't
see why we can't do that for the other types of devices too.

The only missing piece I see is a way to handle the "eject" problem, i.e.
when we try do eject a device at the top of a subtree and need to tear down
the entire subtree below it, but if that's going to lead to a system crash,
for example, we want to cancel the eject.  It seems to me that we'll need some
help from the driver core here.

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
