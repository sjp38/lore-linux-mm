Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 4950E6B0008
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 07:44:03 -0500 (EST)
Date: Mon, 4 Feb 2013 04:46:12 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug
 framework
Message-ID: <20130204124612.GA22096@kroah.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com>
 <20130130045830.GH30002@kroah.com>
 <1359601065.15120.156.camel@misato.fc.hp.com>
 <9860755.q4y3PrCFZx@vostro.rjw.lan>
 <1359682338.15120.209.camel@misato.fc.hp.com>
 <20130201073010.GC1180@kroah.com>
 <1359751210.15120.278.camel@misato.fc.hp.com>
 <20130202150154.GC1434@kroah.com>
 <1359937689.23410.82.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359937689.23410.82.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "bhelgaas@google.com" <bhelgaas@google.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "srivatsa.bhat@linux.vnet.ibm.com" <srivatsa.bhat@linux.vnet.ibm.com>

On Sun, Feb 03, 2013 at 05:28:09PM -0700, Toshi Kani wrote:
> On Sat, 2013-02-02 at 16:01 +0100, Greg KH wrote:
> > On Fri, Feb 01, 2013 at 01:40:10PM -0700, Toshi Kani wrote:
> > > On Fri, 2013-02-01 at 07:30 +0000, Greg KH wrote:
> > > > On Thu, Jan 31, 2013 at 06:32:18PM -0700, Toshi Kani wrote:
> > > >  > This is already done for PCI host bridges and platform devices and I don't
> > > > > > see why we can't do that for the other types of devices too.
> > > > > > 
> > > > > > The only missing piece I see is a way to handle the "eject" problem, i.e.
> > > > > > when we try do eject a device at the top of a subtree and need to tear down
> > > > > > the entire subtree below it, but if that's going to lead to a system crash,
> > > > > > for example, we want to cancel the eject.  It seems to me that we'll need some
> > > > > > help from the driver core here.
> > > > > 
> > > > > There are three different approaches suggested for system device
> > > > > hot-plug:
> > > > >  A. Proceed within system device bus scan.
> > > > >  B. Proceed within ACPI bus scan.
> > > > >  C. Proceed with a sequence (as a mini-boot).
> > > > > 
> > > > > Option A uses system devices as tokens, option B uses acpi devices as
> > > > > tokens, and option C uses resource tables as tokens, for their handlers.
> > > > > 
> > > > > Here is summary of key questions & answers so far.  I hope this
> > > > > clarifies why I am suggesting option 3.
> > > > > 
> > > > > 1. What are the system devices?
> > > > > System devices provide system-wide core computing resources, which are
> > > > > essential to compose a computer system.  System devices are not
> > > > > connected to any particular standard buses.
> > > > 
> > > > Not a problem, lots of devices are not connected to any "particular
> > > > standard busses".  All this means is that system devices are connected
> > > > to the "system" bus, nothing more.
> > > 
> > > Can you give me a few examples of other devices that support hotplug and
> > > are not connected to any particular buses?  I will investigate them to
> > > see how they are managed to support hotplug.
> > 
> > Any device that is attached to any bus in the driver model can be
> > hotunplugged from userspace by telling it to be "unbound" from the
> > driver controlling it.  Try it for any platform device in your system to
> > see how it happens.
> 
> The unbind operation, as I understand from you, is to detach a driver
> from a device.  Yes, unbinding can be done for any devices.  It is
> however different from hot-plug operation, which unplugs a device.

Physically, yes, but to the driver involved, and the driver core, there
is no difference.  That was one of the primary goals of the driver core
creation so many years ago.

> Today, the unbind operation to an ACPI cpu/memory devices causes
> hot-unplug (offline) operation to them, which is one of the major issues
> for us since unbind cannot fail.  This patchset addresses this issue by
> making the unbind operation of ACPI cpu/memory devices to do the
> unbinding only.  ACPI drivers no longer control cpu and memory as they
> are supposed to be controlled by their drivers, cpu and memory modules.

I think that's the problem right there, solve that, please.

> > > > > 2. Why are the system devices special?
> > > > > The system devices are initialized during early boot-time, by multiple
> > > > > subsystems, from the boot-up sequence, in pre-defined order.  They
> > > > > provide low-level services to enable other subsystems to come up.
> > > > 
> > > > Sorry, no, that doesn't mean they are special, nothing here is unique
> > > > for the point of view of the driver model from any other device or bus.
> > > 
> > > I think system devices are unique in a sense that they are initialized
> > > before drivers run.
> > 
> > No, most all devices are "initialized" before a driver runs on it, USB
> > is one such example, PCI another, and I'm pretty sure that there are
> > others.
> 
> USB devices can be initialized after the USB bus driver is initialized.
> Similarly, PCI devices can be initialized after the PCI bus driver is
> initialized.  However, CPU and memory are initialized without any
> dependency to their bus driver since there is no such thing.

You can create such a thing if you want :)

> In addition, CPU and memory have two drivers -- their actual
> drivers/subsystems and their ACPI drivers.

Again, I feel that is the root of the problem.  Rafael seems to be
working on solving this, which I think is essencial to your work as
well.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
