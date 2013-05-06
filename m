Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 5E7256B0069
	for <linux-mm@kvack.org>; Mon,  6 May 2013 12:28:17 -0400 (EDT)
Received: by mail-bk0-f49.google.com with SMTP id e19so1698729bku.36
        for <linux-mm@kvack.org>; Mon, 06 May 2013 09:28:15 -0700 (PDT)
Date: Mon, 6 May 2013 18:28:12 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [PATCH 2/2 v2, RFC] Driver core: Introduce offline/online
 callbacks for memory blocks
Message-ID: <20130506162812.GB4929@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1576321.HU0tZ4cGWk@vostro.rjw.lan>
 <1583356.7oqZ7gBy2q@vostro.rjw.lan>
 <2376818.CRj1BTLk0Y@vostro.rjw.lan>
 <19540491.PRsM4lKIYM@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <19540491.PRsM4lKIYM@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, isimatu.yasuaki@jp.fujitsu.com, Len Brown <lenb@kernel.org>, linux-mm@kvack.org

Hi,

On Sat, May 04, 2013 at 01:21:16PM +0200, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> Introduce .offline() and .online() callbacks for memory_subsys
> that will allow the generic device_offline() and device_online()
> to be used with device objects representing memory blocks.  That,
> in turn, allows the ACPI subsystem to use device_offline() to put
> removable memory blocks offline, if possible, before removing
> memory modules holding them.
> 
> The 'online' sysfs attribute of memory block devices will attempt to
> put them offline if 0 is written to it and will attempt to apply the
> previously used online type when onlining them (i.e. when 1 is
> written to it).
> 
> Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> ---
>  drivers/base/memory.c  |  105 +++++++++++++++++++++++++++++++++++++------------
>  include/linux/memory.h |    1 
>  2 files changed, 81 insertions(+), 25 deletions(-)
>
[...]

> @@ -686,10 +735,16 @@ int offline_memory_block(struct memory_b
>  {
>  	int ret = 0;
>  
> +	lock_device_hotplug();
>  	mutex_lock(&mem->state_mutex);
> -	if (mem->state != MEM_OFFLINE)
> -		ret = __memory_block_change_state(mem, MEM_OFFLINE, MEM_ONLINE, -1);
> +	if (mem->state != MEM_OFFLINE) {
> +		ret = __memory_block_change_state_uevent(mem, MEM_OFFLINE,
> +							 MEM_ONLINE, -1);
> +		if (!ret)
> +			mem->dev.offline = true;
> +	}
>  	mutex_unlock(&mem->state_mutex);
> +	unlock_device_hotplug();

(Testing with qemu...)
offline_memory_block is called from remove_memory, which in turn is called from
acpi_memory_device_remove (detach operation) during acpi_bus_trim. We already
hold the device_hotplug lock when we trim (acpi_scan_hot_remove), so we
don't need to lock/unlock_device_hotplug in offline_memory_block.

A more general issue is that there are now two memory offlining efforts:

1) from acpi_bus_offline_companions during device offline
2) from mm: remove_memory during device detach (offline_memory_block_cb)

The 2nd is only called if the device offline operation was already succesful, so
it seems ineffective or redundant now, at least for x86_64/acpi_memhotplug machine
(unless the blocks were re-onlined in between).
On the other hand, the 2nd effort has some more intelligence in offlining, as it
tries to offline twice in the precense of memcg, see commits df3e1b91 or
reworked 0baeab16. Maybe we need to consolidate the logic.

remove_memory is called from device_detach, during trim that can't fail, so it
should not fail. However this function can still fail in 2 cases:
- offline_memory_block_cb
- is_memblock_offlined_cb
in the case of re-onlined memblocks in between device-offline and device detach.
This seems possible I think, since we do not hold lock_memory_hotplug for the
duration of the hot-remove operation.

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
