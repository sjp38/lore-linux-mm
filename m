Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id CA76B6B00D8
	for <linux-mm@kvack.org>; Mon,  6 May 2013 20:50:43 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 2/2 v2, RFC] Driver core: Introduce offline/online callbacks for memory blocks
Date: Tue, 07 May 2013 02:59:05 +0200
Message-ID: <1809544.1r1JBXrr0i@vostro.rjw.lan>
In-Reply-To: <20130506162812.GB4929@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan> <19540491.PRsM4lKIYM@vostro.rjw.lan> <20130506162812.GB4929@dhcp-192-168-178-175.profitbricks.localdomain>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org

On Monday, May 06, 2013 06:28:12 PM Vasilis Liaskovitis wrote:
> Hi,
> 
> On Sat, May 04, 2013 at 01:21:16PM +0200, Rafael J. Wysocki wrote:
> > From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > 
> > Introduce .offline() and .online() callbacks for memory_subsys
> > that will allow the generic device_offline() and device_online()
> > to be used with device objects representing memory blocks.  That,
> > in turn, allows the ACPI subsystem to use device_offline() to put
> > removable memory blocks offline, if possible, before removing
> > memory modules holding them.
> > 
> > The 'online' sysfs attribute of memory block devices will attempt to
> > put them offline if 0 is written to it and will attempt to apply the
> > previously used online type when onlining them (i.e. when 1 is
> > written to it).
> > 
> > Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > ---
> >  drivers/base/memory.c  |  105 +++++++++++++++++++++++++++++++++++++------------
> >  include/linux/memory.h |    1 
> >  2 files changed, 81 insertions(+), 25 deletions(-)
> >
> [...]
> 
> > @@ -686,10 +735,16 @@ int offline_memory_block(struct memory_b
> >  {
> >  	int ret = 0;
> >  
> > +	lock_device_hotplug();
> >  	mutex_lock(&mem->state_mutex);
> > -	if (mem->state != MEM_OFFLINE)
> > -		ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
> > +	if (mem->state != MEM_OFFLINE) {
> > +		ret = __memory_block_change_state_uevent(mem, MEM_OFFLINE,
> > +							 MEM_ONLINE, -1);
> > +		if (!ret)
> > +			mem->dev.offline = true;
> > +	}
> >  	mutex_unlock(&mem->state_mutex);
> > +	unlock_device_hotplug();
> 
> (Testing with qemu...)

Thanks!

> offline_memory_block is called from remove_memory, which in turn is called from
> acpi_memory_device_remove (detach operation) during acpi_bus_trim. We already
> hold the device_hotplug lock when we trim (acpi_scan_hot_remove), so we
> don't need to lock/unlock_device_hotplug in offline_memory_block.

Indeed.

First, it looks like offline_memory_block_cb() is the only place calling
offline_memory_block(), is that right?  I'm wondering if it would make
sense to use device_offline() in there and remove offline_memory_block()
entirely?

Second, if you ran into this issue during testing, that would mean that patch
[1/2] actually worked for you, which would be nice. :-)  Was that really the
case?

> A more general issue is that there are now two memory offlining efforts:
> 
> 1) from acpi_bus_offline_companions during device offline
> 2) from mm: remove_memory during device detach (offline_memory_block_cb)
> 
> The 2nd is only called if the device offline operation was already succesful, so
> it seems ineffective or redundant now, at least for x86_64/acpi_memhotplug machine
> (unless the blocks were re-onlined in between).

Sure, and that should be OK for now.  Changing the detach behavior is not
essential from the patch [2/2] perspective, we can do it later.

> On the other hand, the 2nd effort has some more intelligence in offlining, as it
> tries to offline twice in the precense of memcg, see commits df3e1b91 or
> reworked 0baeab16. Maybe we need to consolidate the logic.

Hmm.  Perhaps it would make sense to implement that logic in
memory_subsys_offline(), then?

> remove_memory is called from device_detach, during trim that can't fail, so it
> should not fail. However this function can still fail in 2 cases:
> - offline_memory_block_cb
> - is_memblock_offlined_cb
> in the case of re-onlined memblocks in between device-offline and device detach.
> This seems possible I think, since we do not hold lock_memory_hotplug for the
> duration of the hot-remove operation.

But we do hold device_hotplug_lock, so every code path that may race with
acpi_scan_hot_remove() needs to take device_hotplug_lock as well.  Now,
question is whether or not there are any code paths like that calling one of
the two functions above without holding device_hotplug_lock?

Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
