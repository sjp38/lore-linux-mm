Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AA5496B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 08:05:26 -0500 (EST)
Date: Fri, 8 Jan 2010 19:08:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH - resend ] memory-hotplug: create /sys/firmware/memmap
	entry for new memory(v3)
Message-ID: <20100108110810.GA6153@localhost>
References: <DA586906BA1FFC4384FCFD6429ECE86031560B8D@shzsmsx502.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE86031560B8D@shzsmsx502.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
To: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 08, 2010 at 11:16:13AM +0800, Zheng, Shaohui wrote:
> Resend the patch to the mailing-list, the original patch URL is at 
> http://patchwork.kernel.org/patch/69071/. It is already reviewed, but It is still not 
> accepted and no comments, I guess that it should be ignored since we have so many 
> patches each day, send it again.  
> 
> memory-hotplug: create /sys/firmware/memmap entry for hot-added memory
> 
> Interface firmware_map_add was not called in explicit, Remove it and add function
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
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>
> Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
> index 56f9234..ec8c3d4 100644
> --- a/drivers/firmware/memmap.c
> +++ b/drivers/firmware/memmap.c
> @@ -123,52 +123,75 @@ static int firmware_map_add_entry(u64 start, u64 end,
>  }
>  
>  /**
> - * firmware_map_add() - Adds a firmware mapping entry.
> + * Add memmap entry on sysfs
> + */
> +static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry) {

Minor style issue:

ERROR: open brace '{' following function declarations go on the next line
#31: FILE: drivers/firmware/memmap.c:128:
+static int add_sysfs_fw_map_entry(struct firmware_map_entry *entry) {

total: 1 errors, 0 warnings, 145 lines checked

patches/memory-hotplug-create-sys-firmware-memmap-entry-for-new-memory-v3.patch
has style problems, please review.  If any of these e rrors
are false positives report them to the maintainer, see CHECKPATCH in
MAINTAINERS.

> +	static int map_entries_nr;
> +	static struct kset *mmap_kset;
> +
> +	if (!mmap_kset) {
> +		mmap_kset = kset_create_and_add("memmap", NULL, firmware_kobj);
> +		if (WARN_ON(!mmap_kset))

This WARN_ON() may never trigger, or when things go terribly wrong it
repeatedly produce a dozen stack dumps, which don't really help
diagnose the root cause.  Better to just remove it.

> +			return -ENOMEM;
> +	}
> +
> +	entry->kobj.kset = mmap_kset;
> +	if (kobject_add(&entry->kobj, NULL, "%d", map_entries_nr++))
> +		kobject_put(&entry->kobj);
> +
> +	return 0;
> +}
> +
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
> -	entry = kmalloc(sizeof(struct firmware_map_entry), GFP_ATOMIC);
> -	if (!entry)
> +	entry = alloc_bootmem(sizeof(struct firmware_map_entry));
> +	if (WARN_ON(!entry))

Ditto.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
