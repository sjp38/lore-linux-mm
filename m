Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 384736B0111
	for <linux-mm@kvack.org>; Mon,  6 May 2013 06:39:55 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 0/2 v2, RFC] Driver core: Add offline/online callbacks for memory_subsys
Date: Mon, 06 May 2013 12:48:14 +0200
Message-ID: <1573930.mCD9JKX0Q1@vostro.rjw.lan>
In-Reply-To: <2376818.CRj1BTLk0Y@vostro.rjw.lan>
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan> <1583356.7oqZ7gBy2q@vostro.rjw.lan> <2376818.CRj1BTLk0Y@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, vasilis.liaskovitis@profitbricks.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org

On Saturday, May 04, 2013 01:11:21 PM Rafael J. Wysocki wrote:
> Hi,
> 
> On Saturday, May 04, 2013 03:01:23 AM Rafael J. Wysocki wrote:
> > Hi,
> > 
> > This is a continuation of this patchset: https://lkml.org/lkml/2013/5/2/214
> > and it applies on top of it or rather on top of the rebased version (with
> > build problems fixed) in the bleeding-edge branch of the linux-pm.git tree:
> > 
> > http://git.kernel.org/cgit/linux/kernel/git/rafael/linux-pm.git/log/?h=bleeding-edge
> > 
> > An introduction to the first part of the patchset is below, a description of
> > the current patches follows.
> 
> Actually, I'm withdrawing the previous version of this patchset (or rather
> patches [2-3/3] from it), because I had a better idea in the meantime.
> 
> Patch [1/2] is the same as the previous [1/3] ->
> 
> > On Thursday, May 02, 2013 02:26:39 PM Rafael J. Wysocki wrote:
> > > On Monday, April 29, 2013 02:23:59 PM Rafael J. Wysocki wrote:
> > > > 
> > > > It has been argued for a number of times that in some cases, if a device cannot
> > > > be gracefully removed from the system, it shouldn't be removed from it at all,
> > > > because that may lead to a kernel crash.  In particular, that will happen if a
> > > > memory module holding kernel memory is removed, but also removing the last CPU
> > > > in the system may not be a good idea.  [And I can imagine a few other cases
> > > > like that.]
> > > > 
> > > > The kernel currently only supports "forced" hot-remove which cannot be stopped
> > > > once started, so users have no choice but to try to hot-remove stuff and see
> > > > whether or not that crashes the kernel which is kind of unpleasant.  That seems
> > > > to be based on the "the user knows better" argument according to which users
> > > > triggering device hot-removal should really know what they are doing, so the
> > > > kernel doesn't have to worry about that.  However, for instance, this pretty
> > > > much isn't the case for memory modules, because the users have no way to see
> > > > whether or not any kernel memory has been allocated from a given module.
> > > > 
> > > > There have been a few attempts to address this issue, but none of them has
> > > > gained broader acceptance.  The following 3 patches are the heart of a new
> > > > proposal which is based on the idea to introduce device_offline() and
> > > > device_online() operations along the lines of the existing CPU offline/online
> > > > mechanism (or, rather, to extend the CPU offline/online so that analogous
> > > > operations are available for other devices).  The way it is supposed to work is
> > > > that device_offline() will fail if the given device cannot be gracefully
> > > > removed from the system (in the kernel's view).  Once it succeeds, though, the
> > > > device won't be used any more until either it is removed, or device_online() is
> > > > run for it.  That will allow the ACPI device hot-remove code, for one example,
> > > > to avoid triggering a non-reversible removal procedure for devices that cannot
> > > > be removed gracefully.
> > > > 
> > > > Patch [1/3] introduces device_offline() and device_online() as outlined above.
> > > > The .offline() and .online() callbacks are only added at the bus type level for
> > > > now, because that should be sufficient to cover the memory and CPU use cases.
> > > 
> > > That's [1/4] now and the changes from the previous version are:
> > > - strtobool() is used in store_online().
> > > - device_offline_lock has been renamed to device_hotplug_lock (and the
> > >   functions operating it accordingly) following the Toshi's advice.
> > > 
> > > > Patch [2/3] modifies the CPU hotplug support code to use device_offline() and
> > > > device_online() to support the sysfs 'online' attribute for CPUs.
> > > 
> > > That is [2/4] now and it takes cpu_hotplug_driver_lock() around cpu_up() and
> > > cpu_down().
> > > 
> > > > Patch [3/3] changes the ACPI device hot-remove code to use device_offline()
> > > > for checking if graceful removal of devices is possible.  The way it does that
> > > > is to walk the list of "physical" companion devices for each struct acpi_device
> > > > involved in the operation and call device_offline() for each of them.  If any
> > > > of the device_offline() calls fails (and the hot-removal is not "forced", which
> > > > is an option), the removal procedure (which is not reversible) is simply not
> > > > carried out.
> > > 
> > > That's current [3/4].  It's a bit simpler, because I decided that it would be
> > > better to have a global 'force_remove' attribute (the semantics of the
> > > per-profile 'force_remove' wasn't clear and it didn't really add any value over
> > > a global one).  I also added lock/unlock_device_hotplug() around acpi_bus_scan()
> > > in acpi_scan_bus_device_check() to allow scan handlers to update dev->offline
> > > for "physical" companion devices safely (the processor's one added by the next
> > > patch actually does that).
> > > 
> > > > Of some concern is that device_offline() (and possibly device_online()) is
> > > > called under physical_node_lock of the corresponding struct acpi_device, which
> > > > introduces ordering dependency between that lock and device locks for the
> > > > "physical" devices, but I didn't see any cleaner way to do that (I guess it
> > > > is avoidable at the expense of added complexity, but for now it's just better
> > > > to make the code as clean as possible IMO).
> > > 
> > > Patch [4/4] reworks the ACPI processor driver to use the common hotplug code.
> > > It basically splits the driver into two parts as described in the changelog,
> > > where the first part is essentially a scan handler and the second part is
> > > a driver, but it doesn't bind to struct acpi_device any more.  Instead, it
> > > binds to processor devices under /sys/devices/system/cpu/ (the driver itself
> > > has a sysfs directory under /sys/bus/cpu/drivers/ which IMHO makes more sense
> > > than having it under /sys/bus/acpi/drivers/).
> > > 
> > > The patch at https://patchwork.kernel.org/patch/2506371/ is a prerequisite
> > > for this series, but I'm going to push it for v3.10-rc2 if no one screams
> > > bloody murder.
> 
> -> (this is [1/2] now):
> 
> > Patch [1/3] in the current series uses acpi_bind_one() to associate memory
> > block devices with ACPI namespace objects representing memory modules that hold
> > them.  With patch [3/3] that will allow the ACPI core's device hot-remove code
> > to attempt to offline the memory blocks, if possible, before removing the
> > modules holding them from the system (and if the offlining fails, the removal
> > will not be carried out).
> 
> Patch [2/2] adds .online() and .offline() callbacks to memory_subsys
> that are used by the common "online" sysfs attribute and by the ACPI core's
> hot-remove code, through device_online() and device_offline().
> 
> The way it is supposed to work is that device_offline() will attempt to put
> memory blocks offline and device_online() will online them and attempt to
> apply the last online type previously used to them.

I forgot to mention that patch [2/2] was (lightly) tested.  Unfortunately,
I don't have the hardware (or an emulator) allowing me to test patch [1/2].

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
