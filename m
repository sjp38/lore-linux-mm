Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 7F6B86B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 22:07:51 -0500 (EST)
Message-ID: <1359601065.15120.156.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device
 hotplug framework
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 30 Jan 2013 19:57:45 -0700
In-Reply-To: <20130130045830.GH30002@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
	 <1357861230-29549-2-git-send-email-toshi.kani@hp.com>
	 <20130130045830.GH30002@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: rjw@sisk.pl, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Tue, 2013-01-29 at 23:58 -0500, Greg KH wrote:
> On Thu, Jan 10, 2013 at 04:40:19PM -0700, Toshi Kani wrote:
> > +/*
> > + * Hot-plug device information
> > + */
> 
> Again, stop it with the "generic" hotplug term here, and everywhere
> else.  You are doing a very _specific_ type of hotplug devices, so spell
> it out.  We've worked hard to hotplug _everything_ in Linux, you are
> going to confuse a lot of people with this type of terms.

Agreed.  I will clarify in all places.

> > +union shp_dev_info {
> > +	struct shp_cpu {
> > +		u32		cpu_id;
> > +	} cpu;
> 
> What is this?  Why not point to the system device for the cpu?

This info is used to on-line a new CPU and create its system/cpu device.
In other word, a system/cpu device is created as a result of CPU
hotplug.

> > +	struct shp_memory {
> > +		int		node;
> > +		u64		start_addr;
> > +		u64		length;
> > +	} mem;
> 
> Same here, why not point to the system device?

Same as above.

> > +	struct shp_hostbridge {
> > +	} hb;
> > +
> > +	struct shp_node {
> > +	} node;
> 
> What happened here with these?  Empty structures?  Huh?

They are place holders for now.  PCI bridge hot-plug and node hot-plug
are still very much work in progress, so I have not integrated them into
this framework yet.

> > +};
> > +
> > +struct shp_device {
> > +	struct list_head	list;
> > +	struct device		*device;
> 
> No, make it a "real" device, embed the device into it.

This device pointer is used to send KOBJ_ONLINE/OFFLINE event during CPU
online/offline operation in order to maintain the current behavior.  CPU
online/offline operation only changes the state of CPU, so its
system/cpu device continues to be present before and after an operation.
(Whereas, CPU hot-add/delete operation creates or removes a system/cpu
device.)  So, this "*device" needs to be a pointer to reference an
existing device that is to be on-lined/off-lined.

> But, again, I'm going to ask why you aren't using the existing cpu /
> memory / bridge / node devices that we have in the kernel.  Please use
> them, or give me a _really_ good reason why they will not work.

We cannot use the existing system devices or ACPI devices here.  During
hot-plug, ACPI handler sets this shp_device info, so that cpu and memory
handlers (drivers/cpu.c and mm/memory_hotplug.c) can obtain their target
device information in a platform-neutral way.  During hot-add, we first
creates an ACPI device node (i.e. device under /sys/bus/acpi/devices),
but platform-neutral modules cannot use them as they are ACPI-specific.
Also, its system device (i.e. device under /sys/devices/system) has not
been created until the hot-add operation completes.

> > +	enum shp_class		class;
> > +	union shp_dev_info	info;
> > +};
> > +
> > +/*
> > + * Hot-plug request
> > + */
> > +struct shp_request {
> > +	/* common info */
> > +	enum shp_operation	operation;	/* operation */
> > +
> > +	/* hot-plug event info: only valid for hot-plug operations */
> > +	void			*handle;	/* FW handle */
> > +	u32			event;		/* FW event */
> 
> What is this?

The shp_request describes a hotplug or online/offline operation that is
requested.  In case of hot-plug request, the "*handle" describes a
target device (which is an ACPI device object) and the "event" describes
a type of request, such as hot-add or hot-delete.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
