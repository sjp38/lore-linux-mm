Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 32C63828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 18:46:40 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id n128so70517017pfn.3
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 15:46:40 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id pf6si1459737pac.27.2016.01.12.15.46.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 15:46:39 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id cy9so347582453pac.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 15:46:39 -0800 (PST)
Date: Tue, 12 Jan 2016 15:46:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 1/2] memory-hotplug: add automatic onlining policy
 for the newly added memory
In-Reply-To: <1452617777-10598-2-git-send-email-vkuznets@redhat.com>
Message-ID: <alpine.DEB.2.10.1601121535150.28831@chino.kir.corp.google.com>
References: <1452617777-10598-1-git-send-email-vkuznets@redhat.com> <1452617777-10598-2-git-send-email-vkuznets@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

On Tue, 12 Jan 2016, Vitaly Kuznetsov wrote:

> diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
> index ce2cfcf..ceaf40c 100644
> --- a/Documentation/memory-hotplug.txt
> +++ b/Documentation/memory-hotplug.txt
> @@ -254,12 +254,23 @@ If the memory block is online, you'll read "online".
>  If the memory block is offline, you'll read "offline".
>  
>  
> -5.2. How to online memory
> +5.2. Memory onlining

Idk why you're changing this title since you didn't change it in the table 
of contents and it already pairs with "6.2. How to offline memory".

This makes it seem like you're covering all memory onlining operations in 
the kernel (including xen onlining) rather than just memory onlined by 
root.  It doesn't cover the fact that xen onlining can be done without 
automatic onlining, so I would leave this section's title as it is and 
only cover aspects of memory onlining that users are triggering 
themselves.

>  ------------
> -Even if the memory is hot-added, it is not at ready-to-use state.
> -For using newly added memory, you have to "online" the memory block.
> +When the memory is hot-added, the kernel decides whether or not to "online"
> +it according to the policy which can be read from "auto_online_blocks" file:
>  
> -For onlining, you have to write "online" to the memory block's state file as:
> +% cat /sys/devices/system/memory/auto_online_blocks
> +
> +The default is "offline" which means the newly added memory is not in a
> +ready-to-use state and you have to "online" the newly added memory blocks
> +manually. Automatic onlining can be requested by writing "online" to
> +"auto_online_blocks" file:
> +
> +% echo online > /sys/devices/system/memory/auto_online_blocks
> +

I would explicitly point out that this is a global policy and impacts all 
memory blocks that will subsequently be hotplugged.

> +If the automatic onlining wasn't requested or some memory block was offlined
> +it is possible to change the individual block's state by writing to the "state"
> +file:
>  
>  % echo online > /sys/devices/system/memory/memoryXXX/state
>  
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 25425d3..7008edc 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -439,6 +439,37 @@ print_block_size(struct device *dev, struct device_attribute *attr,
>  static DEVICE_ATTR(block_size_bytes, 0444, print_block_size, NULL);
>  
>  /*
> + * Memory auto online policy.
> + */
> +
> +static ssize_t
> +show_auto_online_blocks(struct device *dev, struct device_attribute *attr,
> +			char *buf)
> +{
> +	if (memhp_auto_online)
> +		return sprintf(buf, "online\n");
> +	else
> +		return sprintf(buf, "offline\n");
> +}
> +
> +static ssize_t
> +store_auto_online_blocks(struct device *dev, struct device_attribute *attr,
> +			 const char *buf, size_t count)
> +{
> +	if (sysfs_streq(buf, "online"))
> +		memhp_auto_online = true;
> +	else if (sysfs_streq(buf, "offline"))
> +		memhp_auto_online = false;
> +	else
> +		return -EINVAL;
> +
> +	return count;
> +}
> +
> +static DEVICE_ATTR(auto_online_blocks, 0644, show_auto_online_blocks,
> +		   store_auto_online_blocks);
> +
> +/*
>   * Some architectures will have custom drivers to do this, and
>   * will not need to do it from userspace.  The fake hot-add code
>   * as well as ppc64 will do all of their discovery in userspace
> @@ -654,10 +685,10 @@ static int add_memory_block(int base_section_nr)
>  
>  
>  /*
> - * need an interface for the VM to add new memory regions,
> - * but without onlining it.
> + * add new memory regions keeping their state.
>   */
> -int register_new_memory(int nid, struct mem_section *section)
> +int register_new_memory(int nid, struct mem_section *section,
> +			unsigned long state)
>  {
>  	int ret = 0;
>  	struct memory_block *mem;
> @@ -669,7 +700,7 @@ int register_new_memory(int nid, struct mem_section *section)
>  		mem->section_count++;
>  		put_device(&mem->dev);
>  	} else {
> -		ret = init_memory_block(&mem, section, MEM_OFFLINE);
> +		ret = init_memory_block(&mem, section, state);
>  		if (ret)
>  			goto out;
>  	}
> @@ -737,6 +768,7 @@ static struct attribute *memory_root_attrs[] = {
>  #endif
>  
>  	&dev_attr_block_size_bytes.attr,
> +	&dev_attr_auto_online_blocks.attr,
>  	NULL
>  };
>  
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index 12eab50..890c3b5 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -338,7 +338,7 @@ static enum bp_state reserve_additional_memory(void)
>  	}
>  #endif
>  
> -	rc = add_memory_resource(nid, resource);
> +	rc = add_memory_resource(nid, resource, false);
>  	if (rc) {
>  		pr_warn("Cannot add additional memory (%i)\n", rc);
>  		goto err;
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index 8b8d8d1..1544f48 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -108,7 +108,8 @@ extern int register_memory_notifier(struct notifier_block *nb);
>  extern void unregister_memory_notifier(struct notifier_block *nb);
>  extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
> -extern int register_new_memory(int, struct mem_section *);
> +extern int register_new_memory(int nid, struct mem_section *section,
> +			       unsigned long state);
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  extern int unregister_memory_section(struct mem_section *);
>  #endif
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 2ea574f..4b7949a 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -99,6 +99,8 @@ extern void __online_page_free(struct page *page);
>  
>  extern int try_online_node(int nid);
>  
> +extern bool memhp_auto_online;
> +
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  extern bool is_pageblock_removable_nolock(struct page *page);
>  extern int arch_remove_memory(u64 start, u64 size);
> @@ -267,7 +269,7 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
>  extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
>  		void *arg, int (*func)(struct memory_block *, void *));
>  extern int add_memory(int nid, u64 start, u64 size);
> -extern int add_memory_resource(int nid, struct resource *resource);
> +extern int add_memory_resource(int nid, struct resource *resource, bool online);
>  extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
>  		bool for_device);
>  extern int arch_add_memory(int nid, u64 start, u64 size, bool for_device);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index a042a9d..9c3637e 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -76,6 +76,9 @@ static struct {
>  #define memhp_lock_acquire()      lock_map_acquire(&mem_hotplug.dep_map)
>  #define memhp_lock_release()      lock_map_release(&mem_hotplug.dep_map)
>  
> +bool memhp_auto_online;
> +EXPORT_SYMBOL_GPL(memhp_auto_online);
> +
>  void get_online_mems(void)
>  {
>  	might_sleep();
> @@ -476,6 +479,7 @@ static int __meminit __add_section(int nid, struct zone *zone,
>  					unsigned long phys_start_pfn)
>  {
>  	int ret;
> +	unsigned long state;
>  
>  	if (pfn_valid(phys_start_pfn))
>  		return -EEXIST;
> @@ -490,7 +494,10 @@ static int __meminit __add_section(int nid, struct zone *zone,
>  	if (ret < 0)
>  		return ret;
>  
> -	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
> +	state = memhp_auto_online ? MEM_ONLINE : MEM_OFFLINE;
> +
> +	return register_new_memory(nid, __pfn_to_section(phys_start_pfn),
> +				   state);
>  }
>  
>  /*
> @@ -1232,7 +1239,7 @@ int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
>  }
>  
>  /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
> -int __ref add_memory_resource(int nid, struct resource *res)
> +int __ref add_memory_resource(int nid, struct resource *res, bool online)
>  {
>  	u64 start, size;
>  	pg_data_t *pgdat = NULL;
> @@ -1292,6 +1299,11 @@ int __ref add_memory_resource(int nid, struct resource *res)
>  	/* create new memmap entry */
>  	firmware_map_add_hotplug(start, start + size, "System RAM");
>  
> +	/* online pages if requested */
> +	if (online)
> +		online_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT,
> +			     MMOP_ONLINE_KEEP);
> +
>  	goto out;
>  
>  error:

Well, shucks, what happens if online_pages() fails, such as if a memory 
hot-add notifier returns an errno for MEMORY_GOING_ONLINE?  The memory was 
added but not subsequently onlined, although auto onlining was set, so how 
does userspace know the state it is in?

> @@ -1315,7 +1327,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
>  	if (!res)
>  		return -EEXIST;
>  
> -	ret = add_memory_resource(nid, res);
> +	ret = add_memory_resource(nid, res, memhp_auto_online);
>  	if (ret < 0)
>  		release_memory_resource(res);
>  	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
