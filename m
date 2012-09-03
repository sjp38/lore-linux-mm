Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id D53C36B0062
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 03:44:40 -0400 (EDT)
Message-ID: <50445CB4.80303@cn.fujitsu.com>
Date: Mon, 03 Sep 2012 15:31:00 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v8 PATCH 08/20] memory-hotplug: remove /sys/firmware/memmap/X
 sysfs
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>	<1346148027-24468-9-git-send-email-wency@cn.fujitsu.com> <20120831140623.8d13bd2c.akpm@linux-foundation.org>
In-Reply-To: <20120831140623.8d13bd2c.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

At 09/01/2012 05:06 AM, Andrew Morton Wrote:
> On Tue, 28 Aug 2012 18:00:15 +0800
> wency@cn.fujitsu.com wrote:
> 
>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
>> sysfs files are created. But there is no code to remove these files. The patch
>> implements the function to remove them.
>>
>> Note : The code does not free firmware_map_entry since there is no way to free
>>        memory which is allocated by bootmem.
>>
>> ....
>>
>> +#define to_memmap_entry(obj) container_of(obj, struct firmware_map_entry, kobj)
> 
> It would be better to implement this as an inlined C function.  That
> has improved type safety and improved readability.

Hmm, this macro is not a new macro. It is defined after the function
release_firmware_map_entry(). We just moved it here because we
need it in the function release_firmware_map_entry().

> 
>> +static void release_firmware_map_entry(struct kobject *kobj)
>> +{
>> +	struct firmware_map_entry *entry = to_memmap_entry(kobj);
>> +	struct page *page;
>> +
>> +	page = virt_to_page(entry);
>> +	if (PageSlab(page) || PageCompound(page))
> 
> That PageCompound() test looks rather odd.  Why is this done?
> 
>> +		kfree(entry);
>> +
>> +	/* There is no way to free memory allocated from bootmem*/
>> +}
> 
> This function is a bit ugly - poking around in page flags to determine
> whether or not the memory came from bootmem.  It would be cleaner to
> use a separate boolean.  Although I guess we can live with it as you
> have it here.
> 
>>  static struct kobj_type memmap_ktype = {
>> +	.release	= release_firmware_map_entry,
>>  	.sysfs_ops	= &memmap_attr_ops,
>>  	.default_attrs	= def_attrs,
>>  };
>> @@ -123,6 +139,16 @@ static int firmware_map_add_entry(u64 start, u64 end,
>>  	return 0;
>>  }
>>  
>> +/**
>> + * firmware_map_remove_entry() - Does the real work to remove a firmware
>> + * memmap entry.
>> + * @entry: removed entry.
>> + **/
>> +static inline void firmware_map_remove_entry(struct firmware_map_entry *entry)
>> +{
>> +	list_del(&entry->list);
>> +}
> 
> Is there no locking  to protect that list?

OK, I will add a lock to protect it.

Thanks
Wen Congyang

> 
>>  /*
>>   * Add memmap entry on sysfs
>>   */
>> @@ -144,6 +170,31 @@ static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry)
>>  	return 0;
>>  }
>>  
>> +/*
>> + * Remove memmap entry on sysfs
>> + */
>> +static inline void remove_sysfs_fw_map_entry(struct firmware_map_entry *entry)
>> +{
>> +	kobject_put(&entry->kobj);
>> +}
>> +
>> +/*
>> + * Search memmap entry
>> + */
>> +
>> +struct firmware_map_entry * __meminit
>> +find_firmware_map_entry(u64 start, u64 end, const char *type)
> 
> A better name would be firmware_map_find_entry().  To retain the (good)
> convention that symbols exported from here all start with
> "firmware_map_".
> 
>> +{
>> +	struct firmware_map_entry *entry;
>> +
>> +	list_for_each_entry(entry, &map_entries, list)
>> +		if ((entry->start == start) && (entry->end == end) &&
>> +		    (!strcmp(entry->type, type)))
>> +			return entry;
>> +
>> +	return NULL;
>> +}
>> +
>>  /**
>>   * firmware_map_add_hotplug() - Adds a firmware mapping entry when we do
>>   * memory hotplug.
>> @@ -196,6 +247,32 @@ int __init firmware_map_add_early(u64 start, u64 end, const char *type)
>>  	return firmware_map_add_entry(start, end, type, entry);
>>  }
>>  
>> +/**
>> + * firmware_map_remove() - remove a firmware mapping entry
>> + * @start: Start of the memory range.
>> + * @end:   End of the memory range.
>> + * @type:  Type of the memory range.
>> + *
>> + * removes a firmware mapping entry.
>> + *
>> + * Returns 0 on success, or -EINVAL if no entry.
>> + **/
>> +int __meminit firmware_map_remove(u64 start, u64 end, const char *type)
>> +{
>> +	struct firmware_map_entry *entry;
>> +
>> +	entry = find_firmware_map_entry(start, end - 1, type);
>> +	if (!entry)
>> +		return -EINVAL;
>> +
>> +	firmware_map_remove_entry(entry);
>> +
>> +	/* remove the memmap entry */
>> +	remove_sysfs_fw_map_entry(entry);
>> +
>> +	return 0;
>> +}
> 
> Again, the lack of locking looks bad.
> 
>> ...
>>
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1052,9 +1052,9 @@ int offline_memory(u64 start, u64 size)
>>  	return 0;
>>  }
>>  
>> -int remove_memory(int nid, u64 start, u64 size)
>> +int __ref remove_memory(int nid, u64 start, u64 size)
> 
> Why was __ref added?
> 
>>  {
>> -	int ret = -EBUSY;
>> +	int ret = 0;
>>  	lock_memory_hotplug();
>>  	/*
>>  	 * The memory might become online by other task, even if you offine it.
>>
>> ...
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
