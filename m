Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5122C6B02A5
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 20:46:25 -0400 (EDT)
Message-ID: <4C6495DC.4030005@goop.org>
Date: Thu, 12 Aug 2010 17:46:20 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] GSoC 2010 - Memory hotplug support for Xen guests - third
 fully working version
References: <20100812012224.GA16479@router-fw-old.local.net-space.pl>
In-Reply-To: <20100812012224.GA16479@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daniel Kiper <dkiper@net-space.pl>
Cc: konrad.wilk@oracle.com, stefano.stabellini@eu.citrix.com, linux-mm@kvack.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, v.tolstov@selfip.ru
List-ID: <linux-mm.kvack.org>

  On 08/11/2010 06:22 PM, Daniel Kiper wrote:
> Hi,
>
> Here is the third version of memory hotplug support
> for Xen guests patch. This one cleanly applies to
> git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen.git
> repository, xen/memory-hotplug head.

Thanks.  I'll paste in the full diff and comment on that rather than 
this incremental update.


> diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig index 
> fad3df2..4f35eaf 100644 --- a/drivers/xen/Kconfig +++ 
> b/drivers/xen/Kconfig @@ -9,6 +9,16 @@ config XEN_BALLOON the system 
> to expand the domain's memory allocation, or alternatively return 
> unneeded memory to the system. +config XEN_BALLOON_MEMORY_HOTPLUG + 
> bool "Xen memory balloon driver with memory hotplug support" + default 
> n + depends on XEN_BALLOON && MEMORY_HOTPLUG + help + Xen memory 
> balloon driver with memory hotplug support allows expanding + memory 
> available for the system above limit declared at system startup. + It 
> is very useful on critical systems which require long run without + 
> rebooting. + config XEN_SCRUB_PAGES bool "Scrub pages before returning 
> them to system" depends on XEN_BALLOON diff --git 
> a/drivers/xen/balloon.c b/drivers/xen/balloon.c index 1a0d8c2..5120075 
> 100644 --- a/drivers/xen/balloon.c +++ b/drivers/xen/balloon.c @@ -6,6 
> +6,7 @@ * Copyright (c) 2003, B Dragovic * Copyright (c) 2003-2004, M 
> Williamson, K Fraser * Copyright (c) 2005 Dan M. Smith, IBM 
> Corporation + * Copyright (c) 2010 Daniel Kiper * * This program is 
> free software; you can redistribute it and/or * modify it under the 
> terms of the GNU General Public License version 2 @@ -44,6 +45,8 @@ 
> #include <linux/list.h> #include <linux/sysdev.h> #include 
> <linux/gfp.h> +#include <linux/memory.h> +#include <linux/suspend.h> 
> #include <asm/page.h> #include <asm/pgalloc.h> @@ -77,6 +80,11 @@ 
> struct balloon_stats { /* Number of pages in high- and low-memory 
> balloons. */ unsigned long balloon_low; unsigned long balloon_high; 
> +#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG + unsigned long 
> boot_max_pfn; + u64 hotplug_start_paddr; + u64 hotplug_size; 


So does this mean you only support adding a single hotplug region?  What 
happens if your initial increase wasn't enough and you want to add 
more?  Would you make this a list of hot-added memory or something?

But I'm not even quite sure why you need to keep this as global data.

> +#endif }; static DEFINE_MUTEX(balloon_mutex); @@ -184,17 +192,173 @@ 
> static void balloon_alarm(unsigned long unused) 
> schedule_work(&balloon_worker); } -static unsigned long 
> current_target(void) +#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG +static 
> inline u64 is_memory_resource_reserved(void) +{ + return 
> balloon_stats.hotplug_start_paddr; +} + +static int 
> allocate_additional_memory(unsigned long nr_pages) +{ + long rc; + 
> resource_size_t r_min, r_size; + struct resource *r; + struct 
> xen_memory_reservation reservation = { + .address_bits = 0, + 
> .extent_order = 0, + .domid = DOMID_SELF + }; + unsigned long flags, 
> i, pfn; + + if (nr_pages > ARRAY_SIZE(frame_list)) + nr_pages = 
> ARRAY_SIZE(frame_list); + + if (!is_memory_resource_reserved()) { + + 
> /* + * Look for first unused memory region starting at page + * 
> boundary. Skip last memory section created at boot time + * becuase it 
> may contains unused memory pages with PG_reserved + * bit not set 
> (online_pages require PG_reserved bit set). + */ + + r = 
> kzalloc(sizeof(struct resource), GFP_KERNEL); + + if (!r) { + rc = 
> -ENOMEM; + goto out_0; + } + + r->name = "System RAM"; + r->flags = 
> IORESOURCE_MEM | IORESOURCE_BUSY; + r_min = 
> PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) 
> + 1)); + r_size = (balloon_stats.target_pages - 
> balloon_stats.current_pages) << PAGE_SHIFT; 

So this just reserves enough resource to satisfy the current outstanding 
requirement?  That's OK if we can repeat it, but it looks like it will 
only do this once?

> + + rc = allocate_resource(&iomem_resource, r, r_size, r_min, + 
> ULONG_MAX, PAGE_SIZE, NULL, NULL); 

Does this need to be section aligned, with a section size?  Or is any old place OK?

> + + if (rc < 0) { + kfree(r); + goto out_0; + } + + 
> balloon_stats.hotplug_start_paddr = r->start; + } + + 
> spin_lock_irqsave(&balloon_lock, flags); + + pfn = 
> PFN_DOWN(balloon_stats.hotplug_start_paddr + 
> balloon_stats.hotplug_size); + + for (i = 0; i < nr_pages; ++i, ++pfn) 
> + frame_list[i] = pfn; + + 
> set_xen_guest_handle(reservation.extent_start, frame_list); + 
> reservation.nr_extents = nr_pages; + + rc = 
> HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation); 


Allocating all the memory here seems sub-optimal.

> + + if (rc < 0) + goto out_1; + + pfn = 
> PFN_DOWN(balloon_stats.hotplug_start_paddr + 
> balloon_stats.hotplug_size); + + for (i = 0; i < rc; ++i, ++pfn) { + 
> BUG_ON(!xen_feature(XENFEAT_auto_translated_physmap) && + 
> phys_to_machine_mapping_valid(pfn)); + set_phys_to_machine(pfn, 
> frame_list[i]); + } + + balloon_stats.hotplug_size += rc << 
> PAGE_SHIFT; + balloon_stats.current_pages += rc; + +out_1: + 
> spin_unlock_irqrestore(&balloon_lock, flags); + +out_0: + return rc < 
> 0 ? rc : rc != nr_pages; +} + +static void hotplug_allocated_memory(void) 


Why is this done separately from the reservation/allocation from xen?

> { - unsigned long target = balloon_stats.target_pages; + int nid, ret; 
> + struct memory_block *mem; + unsigned long pfn, pfn_limit; + + nid = 
> memory_add_physaddr_to_nid(balloon_stats.hotplug_start_paddr); 

Is the entire reserved memory range guaranteed to be within one node?

I see that this function has multiple definitions depending on a number 
of config settings.  Do we care about what definition it has?

> + + ret = add_registered_memory(nid, 
> balloon_stats.hotplug_start_paddr, + balloon_stats.hotplug_size); + + 
> if (ret) { + pr_err("%s: add_registered_memory: Memory hotplug failed: 
> %i\n", + __func__, ret); + goto error; + } + + if (xen_pv_domain()) { 
> + pfn = PFN_DOWN(balloon_stats.hotplug_start_paddr); + pfn_limit = pfn 
> + (balloon_stats.hotplug_size >> PAGE_SHIFT); - target = min(target, - 
> balloon_stats.current_pages + - balloon_stats.balloon_low + - 
> balloon_stats.balloon_high); + for (; pfn < pfn_limit; ++pfn) + if 
> (!PageHighMem(pfn_to_page(pfn))) + 
> BUG_ON(HYPERVISOR_update_va_mapping( + (unsigned long)__va(pfn << 
> PAGE_SHIFT), + mfn_pte(pfn_to_mfn(pfn), PAGE_KERNEL), 0)); + } + + ret 
> = online_pages(PFN_DOWN(balloon_stats.hotplug_start_paddr), + 
> balloon_stats.hotplug_size >> PAGE_SHIFT); 

Are the pages available for allocation by the rest of the kernel from 
this point on?

Which function allocates the actual page structures?

> + + if (ret) { + pr_err("%s: online_pages: Failed: %i\n", __func__, 
> ret); + goto error; + } + + pfn = 
> PFN_DOWN(balloon_stats.hotplug_start_paddr); + pfn_limit = pfn + 
> (balloon_stats.hotplug_size >> PAGE_SHIFT); - return target; + for (; 
> pfn < pfn_limit; pfn += PAGES_PER_SECTION) { + mem = 
> find_memory_block(__pfn_to_section(pfn)); + BUG_ON(!mem); + 
> BUG_ON(!present_section_nr(mem->phys_index)); + 
> mutex_lock(&mem->state_mutex); + mem->state = MEM_ONLINE; + 
> mutex_unlock(&mem->state_mutex); + } 

What does this do?  How is it different from what online_pages() does?

> + + goto out; + +error: + balloon_stats.current_pages -= 
> balloon_stats.hotplug_size >> PAGE_SHIFT; + balloon_stats.target_pages 
> -= balloon_stats.hotplug_size >> PAGE_SHIFT; + +out: + 
> balloon_stats.hotplug_start_paddr = 0; + balloon_stats.hotplug_size = 
> 0; } +#else +static inline u64 is_memory_resource_reserved(void) +{ + 
> return 0; +} + +static inline int allocate_additional_memory(unsigned 
> long nr_pages) +{ + /* + * CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not 
> set. + * balloon_stats.target_pages could not be bigger + * than 
> balloon_stats.current_pages because additional + * memory allocation 
> is not possible. + */ + balloon_stats.target_pages = 
> balloon_stats.current_pages; + + return 0; +} + +static inline void 
> hotplug_allocated_memory(void) +{ +} +#endif /* 
> CONFIG_XEN_BALLOON_MEMORY_HOTPLUG */ static int 
> increase_reservation(unsigned long nr_pages) { @@ -236,7 +400,7 @@ 
> static int increase_reservation(unsigned long nr_pages) 
> set_phys_to_machine(pfn, frame_list[i]); /* Link back into the page 
> tables if not highmem. */ - if (pfn < max_low_pfn) { + if 
> (xen_pv_domain() && !PageHighMem(page)) { int ret; ret = 
> HYPERVISOR_update_va_mapping( (unsigned long)__va(pfn << PAGE_SHIFT), 
> @@ -286,7 +450,7 @@ static int decrease_reservation(unsigned long 
> nr_pages) scrub_page(page); - if (!PageHighMem(page)) { + if 
> (xen_pv_domain() && !PageHighMem(page)) { ret = 
> HYPERVISOR_update_va_mapping( (unsigned long)__va(pfn << PAGE_SHIFT), 
> __pte_ma(0), 0); @@ -334,9 +498,15 @@ static void 
> balloon_process(struct work_struct *work) mutex_lock(&balloon_mutex); 
> do { - credit = current_target() - balloon_stats.current_pages; - if 
> (credit > 0) - need_sleep = (increase_reservation(credit) != 0); + 
> credit = balloon_stats.target_pages - balloon_stats.current_pages; + + 
> if (credit > 0) { + if (balloon_stats.balloon_low || 
> balloon_stats.balloon_high) + need_sleep = 
> (increase_reservation(credit) != 0); + else + need_sleep = 
> (allocate_additional_memory(credit) != 0); + } + if (credit < 0) 
> need_sleep = (decrease_reservation(-credit) != 0); @@ -347,8 +517,10 
> @@ static void balloon_process(struct work_struct *work) } while 
> ((credit != 0) && !need_sleep); /* Schedule more work if there is some 
> still to be done. */ - if (current_target() != 
> balloon_stats.current_pages) + if (balloon_stats.target_pages != 
> balloon_stats.current_pages) mod_timer(&balloon_timer, jiffies + HZ); 
> + else if (is_memory_resource_reserved()) + hotplug_allocated_memory(); 

Why can't this be done in allocate_additional_memory()?

> mutex_unlock(&balloon_mutex); } @@ -405,17 +577,27 @@ static int 
> __init balloon_init(void) unsigned long pfn; struct page *page; - if 
> (!xen_pv_domain()) + if (!xen_domain()) return -ENODEV; 
> pr_info("xen_balloon: Initialising balloon driver.\n"); - 
> balloon_stats.current_pages = min(xen_start_info->nr_pages, max_pfn); 
> + if (xen_pv_domain()) + balloon_stats.current_pages = 
> min(xen_start_info->nr_pages, max_pfn); + else + 
> balloon_stats.current_pages = max_pfn; + balloon_stats.target_pages = 
> balloon_stats.current_pages; balloon_stats.balloon_low = 0; 
> balloon_stats.balloon_high = 0; balloon_stats.driver_pages = 0UL; 
> +#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG + balloon_stats.boot_max_pfn 
> = max_pfn; + balloon_stats.hotplug_start_paddr = 0; + 
> balloon_stats.hotplug_size = 0; +#endif + init_timer(&balloon_timer); 
> balloon_timer.data = 0; balloon_timer.function = balloon_alarm; @@ 
> -423,11 +605,12 @@ static int __init balloon_init(void) 
> register_balloon(&balloon_sysdev); /* Initialise the balloon with 
> excess memory space. */ - for (pfn = xen_start_info->nr_pages; pfn < 
> max_pfn; pfn++) { - page = pfn_to_page(pfn); - if 
> (!PageReserved(page)) - balloon_append(page); - } + if 
> (xen_pv_domain()) + for (pfn = xen_start_info->nr_pages; pfn < 
> max_pfn; pfn++) { + page = pfn_to_page(pfn); + if 
> (!PageReserved(page)) + balloon_append(page); + } 
> target_watch.callback = watch_target; xenstore_notifier.notifier_call 
> = balloon_init_watcher; diff --git a/include/linux/memory_hotplug.h 
> b/include/linux/memory_hotplug.h index 35b07b7..37f1894 100644 --- 
> a/include/linux/memory_hotplug.h +++ b/include/linux/memory_hotplug.h 
> @@ -202,6 +202,7 @@ static inline int 
> is_mem_section_removable(unsigned long pfn, } #endif /* 
> CONFIG_MEMORY_HOTREMOVE */ +extern int add_registered_memory(int nid, 
> u64 start, u64 size); extern int add_memory(int nid, u64 start, u64 
> size); extern int arch_add_memory(int nid, u64 start, u64 size); 
> extern int remove_memory(u64 start, u64 size); diff --git 
> a/mm/memory_hotplug.c b/mm/memory_hotplug.c index be211a5..48a65bb 
> 100644 --- a/mm/memory_hotplug.c +++ b/mm/memory_hotplug.c @@ -481,22 
> +481,13 @@ static void rollback_node_hotadd(int nid, pg_data_t *pgdat) 
> return; } - /* we are OK calling __meminit stuff here - we have 
> CONFIG_MEMORY_HOTPLUG */ -int __ref add_memory(int nid, u64 start, u64 
> size) +static int __ref __add_memory(int nid, u64 start, u64 size) { 
> pg_data_t *pgdat = NULL; int new_pgdat = 0; - struct resource *res; 
> int ret; - lock_system_sleep(); - - res = 
> register_memory_resource(start, size); - ret = -EEXIST; - if (!res) - 
> goto out; - if (!node_online(nid)) { pgdat = hotadd_new_pgdat(nid, 
> start); ret = -ENOMEM; @@ -533,11 +524,45 @@ error: /* rollback pgdat 
> allocation and others */ if (new_pgdat) rollback_node_hotadd(nid, 
> pgdat); - if (res) - release_memory_resource(res); out: + return ret; 
> +} + +int __ref add_registered_memory(int nid, u64 start, u64 size) +{ 
> + int ret; + + lock_system_sleep(); + ret = __add_memory(nid, start, 
> size); unlock_system_sleep(); + + return ret; +} 
> +EXPORT_SYMBOL_GPL(add_registered_memory); + +int __ref add_memory(int 
> nid, u64 start, u64 size) +{ + int ret = -EEXIST; + struct resource 
> *res; + + lock_system_sleep(); + + res = 
> register_memory_resource(start, size); + + if (!res) + goto out; + + 
> ret = __add_memory(nid, start, size); + + if (!ret) + goto out; + + 
> release_memory_resource(res); 

In your earlier, patch I think you made the firmware_map_add_hotplug() 
be specific to add_memory, but now you have it in __add_memory.  Does it 
make a difference either way?

> + +out: + unlock_system_sleep(); + return ret; } 
> EXPORT_SYMBOL_GPL(add_memory); 

As before, this all looks reasonably good.  I think the next steps 
should be:

   1. identify how to incrementally allocate the memory from Xen, rather
      than doing it at hotplug time
   2. identify how to disable the sysfs online interface for Xen
      hotplugged memory

For 1., I think the code should be something like:

increase_address_space(unsigned long pages)
{
	- reserve resource for memory section
	- online section
	for each page in section {
		online page
		mark page structure allocated
		add page to ballooned_pages list
		balloon_stats.balloon_(low|high)++;
	}
}


The tricky part is making sure that the memory for the page structures 
has been populated so it can be used.  Aside from that, there should be 
no need to have another call to 
HYPERVISOR_memory_op(XENMEM_populate_physmap, ...) aside from the 
existing one.

Or to look at it another way, memory hotplug is the mechanism for 
increasing the amount of available physical address space, but 
ballooning is the way to increase the number of allocated pages.  They 
are orthogonal.


2 requires a deeper understanding of the existing hotplug code.  It 
needs to be refactored so that you can use the core hotplug machinery 
without enabling the sysfs page-onlining mechanism, while still leaving 
it available for physical hotplug.  In the short term, having a boolean 
to disable the onlining mechanism is probably the pragmatic solution, so 
the balloon code can simply disable it.

Thanks,
     J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
