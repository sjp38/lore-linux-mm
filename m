Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BA6FC6B003D
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 17:33:15 -0500 (EST)
Date: Sun, 22 Feb 2009 23:35:47 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [RFC][PATCH] add mutex and hibernation notifier to memory
	hotplug.
Message-ID: <20090222223547.GH26999@elf.ucw.cz>
References: <20081106153444.33af7019.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081106153444.33af7019.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: gerald.schaefer@de.ibm.com, ncunningham@crca.org.au, Dave Hansen <dave@linux.vnet.ibm.com>, Tolentino <matthew.e.tolentino@intel.com>, Hansen <haveblue@us.ibm.com>, linux-pm@lists.osdl.org, Matt@smtp1.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave@smtp1.linux-foundation.org, Mel Gorman <mel@skynet.ie>, Andy@smtp1.linux-foundation.org, Whitcroft <apw@shadowen.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi!

> Sorry, I can't test this now but I post this while discussion is hot.
> 
> I'll test this with CONFIG_PM_DEBUG's hibernation test mode if I can.
> (But may take a long time..) 
> 
> Any feedback is welcome.

I lost the track here... but this may still be required... ? And given
that there will be both mem hotplug and swsusp in SLE11...
								Pavel

> Thanks,
> -Kame
> ==
> Now, MEMORY_HOTPLUG and HIBERNATION is mutually exclusive in Kconfig.
> That's because
> 	- memory hotplug changes pgdat/zone/memmap range.
> 	- hibernation countes # of memory based on pgdate/zone/memmap.
> 
> This patch adds mutex for disallowing them to run simultaneously.
> 
> IIUC, add_memory() is called from following places.
>     - probe interface
>     - acpi handler
> It seems both can sleep. (acpi handler uses sleepable memory allocator etc...)
> online/offline handlers can sleep.
> hibernation notifier can sleep, too.
> 
> This also makes all memory hotplug event not to happen at the same time.
> (memory hotplug is not busy code.)
> 
> Anyway, the most difficult thing is how to test this.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  mm/Kconfig          |    5 ----
>  mm/memory_hotplug.c |   60 +++++++++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 53 insertions(+), 12 deletions(-)
> 
> Index: linux-2.6.27.4/mm/memory_hotplug.c
> ===================================================================
> --- linux-2.6.27.4.orig/mm/memory_hotplug.c
> +++ linux-2.6.27.4/mm/memory_hotplug.c
> @@ -31,6 +31,8 @@
>  
>  #include "internal.h"
>  
> +DEFINE_MUTEX(memhp_mutex);
> +
>  /* add this memory to iomem resource */
>  static struct resource *register_memory_resource(u64 start, u64 size)
>  {
> @@ -381,6 +383,7 @@ int online_pages(unsigned long pfn, unsi
>  	int ret;
>  	struct memory_notify arg;
>  
> +	mutex_lock(&memhp_mutex);
>  	arg.start_pfn = pfn;
>  	arg.nr_pages = nr_pages;
>  	arg.status_change_nid = -1;
> @@ -392,6 +395,7 @@ int online_pages(unsigned long pfn, unsi
>  	ret = memory_notify(MEM_GOING_ONLINE, &arg);
>  	ret = notifier_to_errno(ret);
>  	if (ret) {
> +		mutex_unlock(&memhp_mutex);
>  		memory_notify(MEM_CANCEL_ONLINE, &arg);
>  		return ret;
>  	}
> @@ -415,6 +419,7 @@ int online_pages(unsigned long pfn, unsi
>  		printk(KERN_DEBUG "online_pages %lx at %lx failed\n",
>  			nr_pages, pfn);
>  		memory_notify(MEM_CANCEL_ONLINE, &arg);
> +		mutex_unlock(&memhp_mutex);
>  		return ret;
>  	}
>  
> @@ -436,7 +441,7 @@ int online_pages(unsigned long pfn, unsi
>  
>  	if (onlined_pages)
>  		memory_notify(MEM_ONLINE, &arg);
> -
> +	mutex_unlock(&memhp_mutex);
>  	return 0;
>  }
>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> @@ -477,14 +482,18 @@ int add_memory(int nid, u64 start, u64 s
>  	struct resource *res;
>  	int ret;
>  
> +	mutex_lock(&memhp_mutex);
>  	res = register_memory_resource(start, size);
> -	if (!res)
> +	if (!res) {
> +		mutex_unlock(&memhp_mutex);
>  		return -EEXIST;
> -
> +	}
>  	if (!node_online(nid)) {
>  		pgdat = hotadd_new_pgdat(nid, start);
> -		if (!pgdat)
> +		if (!pgdat) {
> +			mutex_unlock(&memhp_mutex);
>  			return -ENOMEM;
> +		}
>  		new_pgdat = 1;
>  	}
>  
> @@ -508,7 +517,7 @@ int add_memory(int nid, u64 start, u64 s
>  		 */
>  		BUG_ON(ret);
>  	}
> -
> +	mutex_unlock(&memhp_mutex);
>  	return ret;
>  error:
>  	/* rollback pgdat allocation and others */
> @@ -517,10 +526,12 @@ error:
>  	if (res)
>  		release_memory_resource(res);
>  
> +	mutex_unlock(&memhp_mutex);
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(add_memory);
>  
> +
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  /*
>   * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy
> @@ -750,20 +761,23 @@ int offline_pages(unsigned long start_pf
>  		return -EINVAL;
>  	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
>  		return -EINVAL;
> +
>  	/* This makes hotplug much easier...and readable.
>  	   we assume this for now. .*/
>  	if (!test_pages_in_a_zone(start_pfn, end_pfn))
>  		return -EINVAL;
>  
> +	mutex_lock(&memhp_mutex);
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	node = zone_to_nid(zone);
>  	nr_pages = end_pfn - start_pfn;
>  
>  	/* set above range as isolated */
>  	ret = start_isolate_page_range(start_pfn, end_pfn);
> -	if (ret)
> +	if (ret) {
> +		mutex_unlock(&memhp_mutex);
>  		return ret;
> -
> +	}
>  	arg.start_pfn = start_pfn;
>  	arg.nr_pages = nr_pages;
>  	arg.status_change_nid = -1;
> @@ -838,6 +852,7 @@ repeat:
>  	writeback_set_ratelimit();
>  
>  	memory_notify(MEM_OFFLINE, &arg);
> +	mutex_unlock(&memhp_mutex);
>  	return 0;
>  
>  failed_removal:
> @@ -846,7 +861,7 @@ failed_removal:
>  	memory_notify(MEM_CANCEL_OFFLINE, &arg);
>  	/* pushback to free area */
>  	undo_isolate_page_range(start_pfn, end_pfn);
> -
> +	mutex_unlock(&memhp_mutex);
>  	return ret;
>  }
>  #else
> @@ -856,3 +871,43 @@ int remove_memory(u64 start, u64 size)
>  }
>  EXPORT_SYMBOL_GPL(remove_memory);
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
> +
> +
> +#ifdef CONFIG_HIBERNATION
> +
> +int memhp_hibenation_callback(struct notifier_block *self,
> +			      unsigned long action,
> +			      void *arg)
> +{
> +	switch(action) {
> +	case PM_HIBERNATION_PREPARE:
> +		mutex_lock(&memhp_mutex);
> +		break;
> +	case PM_POST_HIBERNATION:
> +		mutex_unlock(&memhp_mutex);
> +		break;
> +	case PM_RESTORE_PREPARE:
> +		mutex_lock(&memhp_mutex);
> +		break;
> +	case PM_POST_RESTORE:
> +		mutex_unlock(&memhp_mutex);
> +		break;
> +	default:
> +		break;
> +	}
> +	return NOTIFY_OK;
> +}
> +static struct notifier_block memhp_notifier {
> +	.notifier_call = memhp_hibernation_callback,
> +};
> +
> +static int __init memhp_hibernation_notifier_init(void)
> +{
> +	register_pm_notifier(&memhp_notifier);
> +	return 0;
> +}
> +__initcall(&memhp_hibernation_notifier_init);
> +
> +#endif
> +
> +
> Index: linux-2.6.27.4/mm/Kconfig
> ===================================================================
> --- linux-2.6.27.4.orig/mm/Kconfig
> +++ linux-2.6.27.4/mm/Kconfig
> @@ -128,12 +128,9 @@ config SPARSEMEM_VMEMMAP
>  config MEMORY_HOTPLUG
>  	bool "Allow for memory hot-add"
>  	depends on SPARSEMEM || X86_64_ACPI_NUMA
> -	depends on HOTPLUG && !HIBERNATION && ARCH_ENABLE_MEMORY_HOTPLUG
> +	depends on HOTPLUG && ARCH_ENABLE_MEMORY_HOTPLUG
>  	depends on (IA64 || X86 || PPC64 || SUPERH || S390)
>  
> -comment "Memory hotplug is currently incompatible with Software Suspend"
> -	depends on SPARSEMEM && HOTPLUG && HIBERNATION
> -
>  config MEMORY_HOTPLUG_SPARSE
>  	def_bool y
>  	depends on SPARSEMEM && MEMORY_HOTPLUG
> 

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
