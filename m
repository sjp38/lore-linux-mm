Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 290EB6B00D8
	for <linux-mm@kvack.org>; Tue,  7 May 2013 06:59:51 -0400 (EDT)
Received: by mail-bk0-f47.google.com with SMTP id jg9so209843bkc.34
        for <linux-mm@kvack.org>; Tue, 07 May 2013 03:59:49 -0700 (PDT)
Date: Tue, 7 May 2013 12:59:45 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [PATCH 2/2 v2, RFC] Driver core: Introduce offline/online
 callbacks for memory blocks
Message-ID: <20130507105945.GA4354@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan>
 <19540491.PRsM4lKIYM@vostro.rjw.lan>
 <20130506162812.GB4929@dhcp-192-168-178-175.profitbricks.localdomain>
 <1809544.1r1JBXrr0i@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1809544.1r1JBXrr0i@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org, wency@cn.fujitsu.com

Hi,

On Tue, May 07, 2013 at 02:59:05AM +0200, Rafael J. Wysocki wrote:
> On Monday, May 06, 2013 06:28:12 PM Vasilis Liaskovitis wrote:
> > On Sat, May 04, 2013 at 01:21:16PM +0200, Rafael J. Wysocki wrote:
> > > From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > > 
> > > Introduce .offline() and .online() callbacks for memory_subsys
> > > that will allow the generic device_offline() and device_online()
> > > to be used with device objects representing memory blocks.  That,
> > > in turn, allows the ACPI subsystem to use device_offline() to put
> > > removable memory blocks offline, if possible, before removing
> > > memory modules holding them.
> > > 
> > > The 'online' sysfs attribute of memory block devices will attempt to
> > > put them offline if 0 is written to it and will attempt to apply the
> > > previously used online type when onlining them (i.e. when 1 is
> > > written to it).
> > > 
> > > Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> > > ---
> > >  drivers/base/memory.c  |  105 +++++++++++++++++++++++++++++++++++++------------
> > >  include/linux/memory.h |    1 
> > >  2 files changed, 81 insertions(+), 25 deletions(-)
> > >
> > [...]
> > 
> > > @@ -686,10 +735,16 @@ int offline_memory_block(struct memory_b
> > >  {
> > >  	int ret = 0;
> > >  
> > > +	lock_device_hotplug();
> > >  	mutex_lock(&mem->state_mutex);
> > > -	if (mem->state != MEM_OFFLINE)
> > > -		ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
> > > +	if (mem->state != MEM_OFFLINE) {
> > > +		ret = __memory_block_change_state_uevent(mem, MEM_OFFLINE,
> > > +							 MEM_ONLINE, -1);
> > > +		if (!ret)
> > > +			mem->dev.offline = true;
> > > +	}
> > >  	mutex_unlock(&mem->state_mutex);
> > > +	unlock_device_hotplug();
> > 
> > (Testing with qemu...)
> 
> Thanks!
> 
> > offline_memory_block is called from remove_memory, which in turn is called from
> > acpi_memory_device_remove (detach operation) during acpi_bus_trim. We already
> > hold the device_hotplug lock when we trim (acpi_scan_hot_remove), so we
> > don't need to lock/unlock_device_hotplug in offline_memory_block.
> 
> Indeed.
> 
> First, it looks like offline_memory_block_cb() is the only place calling
> offline_memory_block(), is that right?  I'm wondering if it would make

correct.

> sense to use device_offline() in there and remove offline_memory_block()
> entirely?

possibly. Not sure if we can get hold of the struct device from
mm/memory_hotplug.c, maybe we still need the helper function that operates
directly on the memory block.

> 
> Second, if you ran into this issue during testing, that would mean that patch
> [1/2] actually worked for you, which would be nice. :-)  Was that really the
> case?

yes, the patchset works fine once the extra lock/unlock_device_hotplug is
removed. For various dimm hot-remove operations, I saw either successfull
offlining and removal, or failed offlining and aborted removal.
You can add this to 1/2 (or, once the extra lock is removed, to 2/2 as well):

Tested-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

> 
> > A more general issue is that there are now two memory offlining efforts:
> > 
> > 1) from acpi_bus_offline_companions during device offline
> > 2) from mm: remove_memory during device detach (offline_memory_block_cb)
> > 
> > The 2nd is only called if the device offline operation was already succesful, so
> > it seems ineffective or redundant now, at least for x86_64/acpi_memhotplug machine
> > (unless the blocks were re-onlined in between).
> 
> Sure, and that should be OK for now.  Changing the detach behavior is not
> essential from the patch [2/2] perspective, we can do it later.

yes, ok.

> 
> > On the other hand, the 2nd effort has some more intelligence in offlining, as it
> > tries to offline twice in the precense of memcg, see commits df3e1b91 or
> > reworked 0baeab16. Maybe we need to consolidate the logic.
> 
> Hmm.  Perhaps it would make sense to implement that logic in
> memory_subsys_offline(), then?

the logic tries to offline the memory blocks of the device twice, because the
first memory block might be storing information for the subsequent memblocks.

memory_subsys_offline operates on one memory block at a time. Perhaps we can get
the same effect if we do an acpi_walk of acpi_bus_offline_companions twice in
acpi_scan_hot_remove but it's probably not a good idea, since that would
affect non-memory devices as well. 

I am not sure how important this intelligence is in practice (I am not using
mem cgroups in my guest kernel tests yet).  Maybe Wen (original author) has
more details on 2-pass offlining effectiveness.

> 
> > remove_memory is called from device_detach, during trim that can't fail, so it
> > should not fail. However this function can still fail in 2 cases:
> > - offline_memory_block_cb
> > - is_memblock_offlined_cb
> > in the case of re-onlined memblocks in between device-offline and device detach.
> > This seems possible I think, since we do not hold lock_memory_hotplug for the
> > duration of the hot-remove operation.
> 
> But we do hold device_hotplug_lock, so every code path that may race with
> acpi_scan_hot_remove() needs to take device_hotplug_lock as well.  Now,
> question is whether or not there are any code paths like that calling one of
> the two functions above without holding device_hotplug_lock?

I think you are right. The other code path I had in mind was userspace initiated
online/offline operations from store_mem_state in drivers/base/memory.c. But we
also do lock_device_hotplug in that case too. So it seems safe. If I find
something else with stress testing the paths simultaneously (or another code
path) I 'll update.

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
