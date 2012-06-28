Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id C726C6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:28:19 -0400 (EDT)
Message-ID: <4FEBFA8D.5040607@cn.fujitsu.com>
Date: Thu, 28 Jun 2012 14:32:45 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/12] memory-hotplug : remove /sys/firmware/memmap/X
 sysfs
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9E5F.4070205@jp.fujitsu.com>
In-Reply-To: <4FEA9E5F.4070205@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 06/27/2012 01:47 PM, Yasuaki Ishimatsu Wrote:
> When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
> sysfs files are created. But there is no code to remove these files. The patch
> implements the function to remove them.
> 
> Note : The code does not free firmware_map_entry since there is no way to free
>        memory which is allocated by bootmem.
> 
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> ---
>  drivers/firmware/memmap.c    |   71 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/firmware-map.h |    6 +++
>  mm/memory_hotplug.c          |    6 +++
>  3 files changed, 82 insertions(+), 1 deletion(-)
> 
> Index: linux-3.5-rc4/mm/memory_hotplug.c
> ===================================================================
> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-06-26 13:37:30.546288901 +0900
> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-06-26 13:44:37.069955820 +0900
> @@ -661,7 +661,11 @@ EXPORT_SYMBOL_GPL(add_memory);
> 
>  int remove_memory(int nid, u64 start, u64 size)
>  {
> -	return -EBUSY;
> +	lock_memory_hotplug();
> +	/* remove memmap entry */
> +	firmware_map_remove(start, start + size, "System RAM");
> +	unlock_memory_hotplug();
> +	return 0;
> 
>  }
>  EXPORT_SYMBOL_GPL(remove_memory);
> Index: linux-3.5-rc4/include/linux/firmware-map.h
> ===================================================================
> --- linux-3.5-rc4.orig/include/linux/firmware-map.h	2012-06-25 04:53:04.000000000 +0900
> +++ linux-3.5-rc4/include/linux/firmware-map.h	2012-06-26 13:44:37.070955807 +0900
> @@ -25,6 +25,7 @@
> 
>  int firmware_map_add_early(u64 start, u64 end, const char *type);
>  int firmware_map_add_hotplug(u64 start, u64 end, const char *type);
> +int firmware_map_remove(u64 start, u64 end, const char *type);
> 
>  #else /* CONFIG_FIRMWARE_MEMMAP */
> 
> @@ -38,6 +39,11 @@ static inline int firmware_map_add_hotpl
>  	return 0;
>  }
> 
> +static inline int firmware_map_remove(u64 start, u64 end, const char *type)
> +{
> +	return 0;
> +}
> +
>  #endif /* CONFIG_FIRMWARE_MEMMAP */
> 
>  #endif /* _LINUX_FIRMWARE_MAP_H */
> Index: linux-3.5-rc4/drivers/firmware/memmap.c
> ===================================================================
> --- linux-3.5-rc4.orig/drivers/firmware/memmap.c	2012-06-25 04:53:04.000000000 +0900
> +++ linux-3.5-rc4/drivers/firmware/memmap.c	2012-06-26 13:47:17.606948898 +0900
> @@ -123,6 +123,16 @@ static int firmware_map_add_entry(u64 st
>  	return 0;
>  }
> 
> +/**
> + * firmware_map_remove_entry() - Does the real work to remove a firmware
> + * memmap entry.
> + * @entry: removed entry.
> + **/
> +static inline void firmware_map_remove_entry(struct firmware_map_entry *entry)
> +{
> +	list_del(&entry->list);
> +}
> +
>  /*
>   * Add memmap entry on sysfs
>   */
> @@ -144,6 +154,31 @@ static int add_sysfs_fw_map_entry(struct
>  	return 0;
>  }
> 
> +/*
> + * Remove memmap entry on sysfs
> + */
> +static inline void remove_sysfs_fw_map_entry(struct firmware_map_entry *entry)
> +{
> +	kobject_del(&entry->kobj);
> +}
> +
> +/*
> + * Search memmap entry
> + */
> +
> +struct firmware_map_entry * __meminit
> +find_firmware_map_entry(u64 start, u64 end, const char *type)
> +{
> +	struct firmware_map_entry *entry;
> +
> +	list_for_each_entry(entry, &map_entries, list)
> +		if ((entry->start == start) && (entry->end == end) &&
> +		    (!strcmp(entry->type, type)))
> +			return entry;
> +
> +	return NULL;
> +}
> +
>  /**
>   * firmware_map_add_hotplug() - Adds a firmware mapping entry when we do
>   * memory hotplug.
> @@ -196,6 +231,42 @@ int __init firmware_map_add_early(u64 st
>  	return firmware_map_add_entry(start, end, type, entry);
>  }
> 
> +void release_firmware_map_entry(struct firmware_map_entry *entry)
> +{
> +	/*
> +	 * FIXME : There is no idea.
> +	 *         How to free the entry which allocated bootmem?
> +	 */
> +}
> +
> +/**
> + * firmware_map_remove() - remove a firmware mapping entry
> + * @start: Start of the memory range.
> + * @end:   End of the memory range (inclusive).
> + * @type:  Type of the memory range.
> + *
> + * removes a firmware mapping entry.
> + *
> + * Returns 0 on success, or -EINVAL if no entry.
> + **/
> +int __meminit firmware_map_remove(u64 start, u64 end, const char *type)
> +{
> +	struct firmware_map_entry *entry;
> +
> +	entry = find_firmware_map_entry(start, end, type);

Hmm, we cannot find the entry easily, because the end can be:
1. start + size
2. start + size - 1

So, We should fix this bug first.

> +	if (!entry)
> +		return -EINVAL;
> +
> +	/* remove the memmap entry */
> +	remove_sysfs_fw_map_entry(entry);
> +
> +	firmware_map_remove_entry(entry);
> +
> +	release_firmware_map_entry(entry);

I guess you want to free the memory in the above function. But I think it is
not a good idea to free it here. We should free it when the entry->kobj's kref
is decreased to 0.

Thanks
Wen Congyang

> +
> +	return 0;
> +}
> +
>  /*
>   * Sysfs functions -------------------------------------------------------------
>   */
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
