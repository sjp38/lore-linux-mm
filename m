Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id C50626B005C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 14:37:04 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH v2 01/12] Add sys_hotplug.h for system device hotplug framework
Date: Mon, 04 Feb 2013 20:43:19 +0100
Message-ID: <3771593.0Hh61SLxJL@vostro.rjw.lan>
In-Reply-To: <1359994749.23410.113.camel@misato.fc.hp.com>
References: <1357861230-29549-1-git-send-email-toshi.kani@hp.com> <2048116.Qo8UgQ5hjb@vostro.rjw.lan> <1359994749.23410.113.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, lenb@kernel.org, akpm@linux-foundation.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, bhelgaas@google.com, isimatu.yasuaki@jp.fujitsu.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, guohanjun@huawei.com, yinghai@kernel.org, srivatsa.bhat@linux.vnet.ibm.com

On Monday, February 04, 2013 09:19:09 AM Toshi Kani wrote:
> On Mon, 2013-02-04 at 15:21 +0100, Rafael J. Wysocki wrote:
> > On Monday, February 04, 2013 04:48:10 AM Greg KH wrote:
> > > On Sun, Feb 03, 2013 at 09:44:39PM +0100, Rafael J. Wysocki wrote:
> > > > > Yes, but those are just remove events and we can only see how destructive they
> > > > > were after the removal.  The point is to be able to figure out whether or not
> > > > > we *want* to do the removal in the first place.
> > > > > 
> > > > > Say you have a computing node which signals a hardware problem in a processor
> > > > > package (the container with CPU cores, memory, PCI host bridge etc.).  You
> > > > > may want to eject that package, but you don't want to kill the system this
> > > > > way.  So if the eject is doable, it is very much desirable to do it, but if it
> > > > > is not doable, you'd rather shut the box down and do the replacement afterward.
> > > > > That may be costly, however (maybe weeks of computations), so it should be
> > > > > avoided if possible, but not at the expense of crashing the box if the eject
> > > > > doesn't work out.
> > > > 
> > > > It seems to me that we could handle that with the help of a new flag, say
> > > > "no_eject", in struct device, a global mutex, and a function that will walk
> > > > the given subtree of the device hierarchy and check if "no_eject" is set for
> > > > any devices in there.  Plus a global "no_eject" switch, perhaps.
> > > 
> > > I think this will always be racy, or at worst, slow things down on
> > > normal device operations as you will always be having to grab this flag
> > > whenever you want to do something new.
> > 
> > I don't see why this particular scheme should be racy, at least I don't see any
> > obvious races in it (although I'm not that good at races detection in general,
> > admittedly).
> > 
> > Also, I don't expect that flag to be used for everything, just for things known
> > to seriously break if forcible eject is done.  That may be not precise enough,
> > so that's a matter of defining its purpose more precisely.
> > 
> > We can do something like that on the ACPI level (ie. introduce a no_eject flag
> > in struct acpi_device and provide an iterface for the layers above ACPI to
> > manipulate it) but then devices without ACPI namespace objects won't be
> > covered.  That may not be a big deal, though.
> 
> I am afraid that bringing the device status management into the ACPI
> level would not a good idea.  acpi_device should only reflect ACPI
> device object information, not how its actual device is being used.
> 
> I like your initiative of acpi_scan_driver and I think scanning /
> trimming of ACPI object info is what the ACPI drivers should do.

ACPI drivers, yes, but the users of ACPI already rely on information
in struct acpi_device.  Like ACPI device power states, for example.

So platform_no_eject(dev) is not much different in that respect from
platform_pci_set_power_state(pci_dev).

The whole "eject" concept is somewhat ACPI-specific, though, and the eject
notifications come from ACPI, so I don't have a problem with limiting it to
ACPI-backed devices for the time being.

If it turns out the be useful outside of ACPI, then we can move it up to the
driver core.  For now I don't see a compelling reason to do that.

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
