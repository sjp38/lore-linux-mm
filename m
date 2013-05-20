Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 263666B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 13:28:05 -0400 (EDT)
Message-ID: <1369070876.5673.51.camel@misato.fc.hp.com>
Subject: Re: [PATCH 5/5] ACPI / memhotplug: Drop unnecessary code
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 20 May 2013 11:27:56 -0600
In-Reply-To: <2228904.eTtCrFuSan@vostro.rjw.lan>
References: <2250271.rGYN6WlBxf@vostro.rjw.lan>
	 <2228904.eTtCrFuSan@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <liuj97@gmail.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-mm@kvack.org

On Sun, 2013-05-19 at 01:34 +0200, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> Now that the memory offlining should be taken care of by the
> companion device offlining code in acpi_scan_hot_remove(), the
> ACPI memory hotplug driver doesn't need to offline it in
> acpi_memory_remove_memory() any more.  Consequently, it doesn't
> need to call remove_memory() any more, which means that that
> funtion may be dropped entirely, because acpi_memory_remove_memory()
> is the only user of it.

The off-lining part of remove_memory() can be removed, but not the
hot-delete part.  Please see my comments below.

> Make the changes described above to get rid of the dead code.
> 
> Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> ---
>  drivers/acpi/acpi_memhotplug.c |   15 ------
>  include/linux/memory_hotplug.h |    1 
>  mm/memory_hotplug.c            |  102 -----------------------------------------
>  3 files changed, 2 insertions(+), 116 deletions(-)
> 
> Index: linux-pm/drivers/acpi/acpi_memhotplug.c
> ===================================================================
> --- linux-pm.orig/drivers/acpi/acpi_memhotplug.c
> +++ linux-pm/drivers/acpi/acpi_memhotplug.c
> @@ -271,31 +271,20 @@ static int acpi_memory_enable_device(str
>  	return 0;
>  }
>  
> -static int acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
> +static void acpi_memory_remove_memory(struct acpi_memory_device *mem_device)
>  {
>  	acpi_handle handle = mem_device->device->handle;
> -	int result = 0, nid;
>  	struct acpi_memory_info *info, *n;
>  
> -	nid = acpi_get_node(handle);
> -
>  	list_for_each_entry_safe(info, n, &mem_device->res_list, list) {
>  		if (!info->enabled)
>  			continue;
>  
> -		if (nid < 0)
> -			nid = memory_add_physaddr_to_nid(info->start_addr);
> -
> +		/* All of the memory blocks are offline at this point. */
>  		acpi_unbind_memory_blocks(info, handle);
> -		result = remove_memory(nid, info->start_addr, info->length);

We still need to call remove_memory().

> -		if (result)
> -			return result;
> -
>  		list_del(&info->list);
>  		kfree(info);
>  	}
> -
> -	return result;
>  }
>  
>  static void acpi_memory_device_free(struct acpi_memory_device *mem_device)
> Index: linux-pm/include/linux/memory_hotplug.h
> ===================================================================
> --- linux-pm.orig/include/linux/memory_hotplug.h
> +++ linux-pm/include/linux/memory_hotplug.h
> @@ -252,7 +252,6 @@ extern int add_memory(int nid, u64 start
>  extern int arch_add_memory(int nid, u64 start, u64 size);
>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>  extern bool is_memblock_offlined(struct memory_block *mem);
> -extern int remove_memory(int nid, u64 start, u64 size);
>  extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
>  								int nr_pages);
>  extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
> Index: linux-pm/mm/memory_hotplug.c
> ===================================================================
> --- linux-pm.orig/mm/memory_hotplug.c
> +++ linux-pm/mm/memory_hotplug.c
> @@ -1670,41 +1670,6 @@ int walk_memory_range(unsigned long star
>  }

 :

> -
> -int __ref remove_memory(int nid, u64 start, u64 size)
> -{
> -	unsigned long start_pfn, end_pfn;
> -	int ret = 0;
> -	int retry = 1;
> -
> -	start_pfn = PFN_DOWN(start);
> -	end_pfn = PFN_UP(start + size - 1);
> -
> -	/*
> -	 * When CONFIG_MEMCG is on, one memory block may be used by other
> -	 * blocks to store page cgroup when onlining pages. But we don't know
> -	 * in what order pages are onlined. So we iterate twice to offline
> -	 * memory:
> -	 * 1st iterate: offline every non primary memory block.
> -	 * 2nd iterate: offline primary (i.e. first added) memory block.
> -	 */
> -repeat:
> -	walk_memory_range(start_pfn, end_pfn, &ret,
> -			  offline_memory_block_cb);
> -	if (ret) {
> -		if (!retry)
> -			return ret;
> -
> -		retry = 0;
> -		ret = 0;
> -		goto repeat;
> -	}

The above procedure can be removed as it is for off-lining.

> -	lock_memory_hotplug();
> -
> -	/*
> -	 * we have offlined all memory blocks like this:
> -	 *   1. lock memory hotplug
> -	 *   2. offline a memory block
> -	 *   3. unlock memory hotplug
> -	 *
> -	 * repeat step1-3 to offline the memory block. All memory blocks
> -	 * must be offlined before removing memory. But we don't hold the
> -	 * lock in the whole operation. So we should check whether all
> -	 * memory blocks are offlined.
> -	 */
> -
> -	ret = walk_memory_range(start_pfn, end_pfn, NULL,
> -				is_memblock_offlined_cb);
> -	if (ret) {
> -		unlock_memory_hotplug();
> -		return ret;
> -	}
> -

I think the above procedure is still useful for safe guard.

> -	/* remove memmap entry */
> -	firmware_map_remove(start, start + size, "System RAM");
> -
> -	arch_remove_memory(start, size);
> -
> -	try_offline_node(nid);

The above procedure performs memory hot-delete specific operations and
is necessary.

Thanks,
-Toshi

> -	unlock_memory_hotplug();
> -
> -	return 0;
> -}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
