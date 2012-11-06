Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 155026B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 19:00:22 -0500 (EST)
Date: Mon, 5 Nov 2012 16:00:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/3] acpi,memory-hotplug : implement framework for
 hot removing memory
Message-Id: <20121105160020.33b2f494.akpm@linux-foundation.org>
In-Reply-To: <1528960.KUfu6MoGpQ@vostro.rjw.lan>
References: <1351247463-5653-1-git-send-email-wency@cn.fujitsu.com>
	<1528960.KUfu6MoGpQ@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, liuj97@gmail.com, len.brown@intel.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com

On Fri, 02 Nov 2012 13:51:49 +0100
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> On Friday, October 26, 2012 06:31:00 PM wency@cn.fujitsu.com wrote:
> > From: Wen Congyang <wency@cn.fujitsu.com>
> > 
> > The patch-set implements a framework for hot removing memory.
> > 
> > The memory device can be removed by 2 ways:
> > 1. send eject request by SCI
> > 2. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject
> > 
> > In the 1st case, acpi_memory_disable_device() will be called.
> > In the 2nd case, acpi_memory_device_remove() will be called.
> > acpi_memory_device_remove() will also be called when we unbind the
> > memory device from the driver acpi_memhotplug or a driver initialization
> > fails.
> > 
> > acpi_memory_disable_device() has already implemented a code which
> > offlines memory and releases acpi_memory_info struct . But
> > acpi_memory_device_remove() has not implemented it yet.
> > 
> > So the patch prepares the framework for hot removing memory and
> > adds the framework into acpi_memory_device_remove().
> > 
> > The last version of this patchset is here:
> > https://lkml.org/lkml/2012/10/19/156
> > 
> > Changelogs from v2 to v3:
> >   Patch2: rename lock to list_lock
> > 
> > Changelogs from v1 to v2:
> >   Patch1: use acpi_bus_trim() instead of acpi_bus_remove()
> >   Patch2: new patch, introduce a lock to protect the list
> >   Patch3: remove memory too when type is ACPI_BUS_REMOVAL_NORMAL
> >   Note: I don't send [Patch2-4 v1] in this series because they
> >   are no logical changes in these 3 patches.
> > 
> > Wen Congyang (2):
> >   acpi,memory-hotplug: call acpi_bus_trim() to remove memory device
> >   acpi,memory-hotplug: introduce a mutex lock to protect the list in
> >     acpi_memory_device
> > 
> > Yasuaki Ishimatsu (1):
> >   acpi,memory-hotplug : add memory offline code to
> >     acpi_memory_device_remove()
> > 
> >  drivers/acpi/acpi_memhotplug.c | 51 +++++++++++++++++++++++++++++++++---------
> >  1 file changed, 41 insertions(+), 10 deletions(-)
> 
> All patches in the series applied to the linux-next branch of the linux-pm.git
> tree as v3.8 material.
> 

That merge made a big mess of some patches I had queued, so I dropped
them all:

acpi_memhotplugc-fix-memory-leak-when-memory-device-is-unbound-from-the-module-acpi_memhotplug.patch
acpi_memhotplugc-free-memory-device-if-acpi_memory_enable_device-failed.patch
acpi_memhotplugc-remove-memory-info-from-list-before-freeing-it.patch
acpi_memhotplugc-dont-allow-to-eject-the-memory-device-if-it-is-being-used.patch
acpi_memhotplugc-bind-the-memory-device-when-the-driver-is-being-loaded.patch
acpi_memhotplugc-auto-bind-the-memory-device-which-is-hotplugged-before-the-driver-is-loaded.patch

I merged these all the way back in July, actually.  I sent them to Len
in August to no effect and they've been sitting there since then.

If they're still relevant and needed then they will need to be redone,
retested and resent, sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
