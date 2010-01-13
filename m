Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 603F26B006A
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 17:30:24 -0500 (EST)
Date: Wed, 13 Jan 2010 14:28:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH-RESEND v4] memory-hotplug: create /sys/firmware/memmap
 entry for new memory
Message-Id: <20100113142827.26b2269e.akpm@linux-foundation.org>
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE86031560F92@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560F92@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 2010 10:00:11 +0800
"Zheng, Shaohui" <shaohui.zheng@intel.com> wrote:

> Resend the memmap patch v4 to mailing-list after follow up fengguang's review 
> comments. 
> 
> memory-hotplug: create /sys/firmware/memmap entry for hot-added memory
> 
> Interface firmware_map_add was not called in explict, Remove it and add function
> firmware_map_add_hotplug as hotplug interface of memmap.
> 
> When we hot-add new memory, sysfs does not export memmap entry for it. we add
>  a call in function add_memory to function firmware_map_add_hotplug.
> 
> Add a new function add_sysfs_fw_map_entry to create memmap entry, it can avoid 
> duplicated codes.
> 
> Thanks for the careful review from Fengguang Wu and Dave Hansen.
> 

Please describe the format of the proposed sysfs file.  Example output
would be suitable.

> @@ -123,20 +123,40 @@ static int firmware_map_add_entry(u64 start, u64 end,
>  }
>  
>  /**
> - * firmware_map_add() - Adds a firmware mapping entry.
> + * Add memmap entry on sysfs
> + */
> +static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry)
> +{
> +	static int map_entries_nr;
> +	static struct kset *mmap_kset;
> +
> +	if (!mmap_kset) {
> +		mmap_kset = kset_create_and_add("memmap", NULL, firmware_kobj);
> +		if (!mmap_kset)
> +			return -ENOMEM;
> +	}

This is a bit racy if two threads execute it at the same time.  I guess
it doesn't matter.


> +	entry->kobj.kset = mmap_kset;
> +	if (kobject_add(&entry->kobj, NULL, "%d", map_entries_nr++))
> +		kobject_put(&entry->kobj);

hm.  Is this refcounting correct?

> +
> +	return 0;
> +}

One caller of add_sysfs_fw_map_entry() is __meminit and the other is
__init.  So this function can be __meminit?

> +/**
> + * firmware_map_add_early() - Adds a firmware mapping entry.
>   * @start: Start of the memory range.
>   * @end:   End of the memory range (inclusive).
>   * @type:  Type of the memory range.
>   *
> - * This function uses kmalloc() for memory
> - * allocation. Use firmware_map_add_early() if you want to use the bootmem
> - * allocator.
> + * Adds a firmware mapping entry. This function uses the bootmem allocator
> + * for memory allocation.
>   *
>   * That function must be called before late_initcall.
>   *
>   * Returns 0 on success, or -ENOMEM if no memory could be allocated.
>   **/
> -int firmware_map_add(u64 start, u64 end, const char *type)
> +int __init firmware_map_add_early(u64 start, u64 end, const char *type)
>  {
>  	struct firmware_map_entry *entry;
>  
> @@ -148,27 +168,31 @@ int firmware_map_add(u64 start, u64 end, const char *type)
>  }
>  
>  /**
> - * firmware_map_add_early() - Adds a firmware mapping entry.
> + * firmware_map_add_hotplug() - Adds a firmware mapping entry when we do
> + * memory hotplug.
>   * @start: Start of the memory range.
>   * @end:   End of the memory range (inclusive).
>   * @type:  Type of the memory range.
>   *
> - * Adds a firmware mapping entry. This function uses the bootmem allocator
> - * for memory allocation. Use firmware_map_add() if you want to use kmalloc().
> - *
> - * That function must be called before late_initcall.
> + * Adds a firmware mapping entry. This function is for memory hotplug, it is
> + * simiar with function firmware_map_add_early. the only difference is that

s/simiar/similar/
s/with/to/
s/the/The/
s/function firmware_map_add_early/firmware_map_add_early()/

> + * it will create the syfs entry dynamically.
>   *
>   * Returns 0 on success, or -ENOMEM if no memory could be allocated.
>   **/
> -int __init firmware_map_add_early(u64 start, u64 end, const char *type)
> +int __meminit firmware_map_add_hotplug(u64 start, u64 end, const char *type)
>  {
>  	struct firmware_map_entry *entry;
>  
> -	entry = alloc_bootmem(sizeof(struct firmware_map_entry));
> -	if (WARN_ON(!entry))
> +	entry = kzalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
> +	if (!entry)
>  		return -ENOMEM;
>  
> -	return firmware_map_add_entry(start, end, type, entry);
> +	firmware_map_add_entry(start, end, type, entry);
> +	/* create the memmap entry */
> +	add_sysfs_fw_map_entry(entry);
> +
> +	return 0;
>  }
>  
>  /*
> @@ -214,18 +238,10 @@ static ssize_t memmap_attr_show(struct kobject *kobj,
>   */
>  static int __init memmap_init(void)
>  {
> -	int i = 0;
>  	struct firmware_map_entry *entry;
> -	struct kset *memmap_kset;
> -
> -	memmap_kset = kset_create_and_add("memmap", NULL, firmware_kobj);
> -	if (WARN_ON(!memmap_kset))
> -		return -ENOMEM;
>  
>  	list_for_each_entry(entry, &map_entries, list) {
> -		entry->kobj.kset = memmap_kset;
> -		if (kobject_add(&entry->kobj, NULL, "%d", i++))
> -			kobject_put(&entry->kobj);
> +		add_sysfs_fw_map_entry(entry);
>  	}

The braces are now unneeded.  checkpatch used to warn about this I
think.  Either someone broke checkpatch or it doesn't understand
list_for_each_entry().

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
