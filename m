Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA63SVRb013339
	for <linux-mm@kvack.org> (envelope-from y-goto@jp.fujitsu.com);
	Thu, 6 Nov 2008 12:28:31 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BF7845DD7E
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 12:28:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DBCC945DD7A
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 12:28:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B4CE51DB8037
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 12:28:30 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 61F9C1DB8038
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 12:28:30 +0900 (JST)
Date: Thu, 06 Nov 2008 12:28:30 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory hotplug
In-Reply-To: <20081106121212.e609476d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081106110709.b168cc30.kamezawa.hiroyu@jp.fujitsu.com> <20081106121212.e609476d.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20081106121916.4474.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, "Rafael J. Wysocki" <rjw@sisk.pl>, Dave Hansen <dave@linux.vnet.ibm.com>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hmm.

I think simple mutex is enough. read/write lock is not necessary.
Memory hotplug event is very rare, and there is no requirement of
parallel execution.


> On Thu, 6 Nov 2008 11:07:09 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Okay. then we can add "kernel thread for calling add/remove memory" and say
> > "PLEASE WAIT UNTIL HIBERNATION IS READY".
> > 
> > I can try that by myself but doesn't have suitable machine....
> > I think I can show you pseudo code in hours. please wait a bit.
> > 
> 
> How about this one ? as a start step ?
> I have no test environment. So please take this as a sample.
> -Kame
> =
> 
> Now, MEMORY_HOTPLUG and HIBERNATION is mutually exclusive in Kconfig.
> That's because
> 	- memory hotplug changes pgdat/zone/memmap range.
> 	- hibernation countes # of memory based on pgdate/zone/memmap.
> 
> This patch adds rwsemaphore for making them not to run at the same time.
> 
> IIUC, add_memory() is called from following places.
>     - probe interface
>     - acpi handler
> It seems both can sleep. (acpi handler uses sleepable memory allocator etc...)
> 
> online/offline handlers also sleeps.
> 
> Anyway, the most difficult thing is how to test this.
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  mm/Kconfig          |    2 -
>  mm/memory_hotplug.c |   61 +++++++++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 54 insertions(+), 9 deletions(-)
> 
> Index: linux-2.6.27.4/mm/memory_hotplug.c
> ===================================================================
> --- linux-2.6.27.4.orig/mm/memory_hotplug.c
> +++ linux-2.6.27.4/mm/memory_hotplug.c
> @@ -31,6 +31,13 @@
>  
>  #include "internal.h"
>  
> +struct rw_semaphore memhp_mutex;
> +
> +static int init_memhp_mutex(void)
> +{
> +	init_rwsem(&memhp_mutex);
> +}
> +
>  /* add this memory to iomem resource */
>  static struct resource *register_memory_resource(u64 start, u64 size)
>  {
> @@ -381,6 +388,7 @@ int online_pages(unsigned long pfn, unsi
>  	int ret;
>  	struct memory_notify arg;
>  
> +	down_read(&memhp_mutex);
>  	arg.start_pfn = pfn;
>  	arg.nr_pages = nr_pages;
>  	arg.status_change_nid = -1;
> @@ -392,6 +400,7 @@ int online_pages(unsigned long pfn, unsi
>  	ret = memory_notify(MEM_GOING_ONLINE, &arg);
>  	ret = notifier_to_errno(ret);
>  	if (ret) {
> +		up_read(&memhp_mutex);
>  		memory_notify(MEM_CANCEL_ONLINE, &arg);
>  		return ret;
>  	}
> @@ -415,6 +424,7 @@ int online_pages(unsigned long pfn, unsi
>  		printk(KERN_DEBUG "online_pages %lx at %lx failed\n",
>  			nr_pages, pfn);
>  		memory_notify(MEM_CANCEL_ONLINE, &arg);
> +		up_read(&memhp_mutex);
>  		return ret;
>  	}
>  
> @@ -436,7 +446,7 @@ int online_pages(unsigned long pfn, unsi
>  
>  	if (onlined_pages)
>  		memory_notify(MEM_ONLINE, &arg);
> -
> +	up_read(&memhp_mutex);
>  	return 0;
>  }
>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> @@ -477,14 +487,18 @@ int add_memory(int nid, u64 start, u64 s
>  	struct resource *res;
>  	int ret;
>  
> +	down_read(&memhp_mutex);
>  	res = register_memory_resource(start, size);
> -	if (!res)
> +	if (!res) {
> +		up_read(&memhp_mutex);
>  		return -EEXIST;
> -
> +	}
>  	if (!node_online(nid)) {
>  		pgdat = hotadd_new_pgdat(nid, start);
> -		if (!pgdat)
> +		if (!pgdat) {
> +			up_read(&memhp_mutex);
>  			return -ENOMEM;
> +		}
>  		new_pgdat = 1;
>  	}
>  
> @@ -508,7 +522,7 @@ int add_memory(int nid, u64 start, u64 s
>  		 */
>  		BUG_ON(ret);
>  	}
> -
> +	up_read(&memhp_mutex);
>  	return ret;
>  error:
>  	/* rollback pgdat allocation and others */
> @@ -517,10 +531,12 @@ error:
>  	if (res)
>  		release_memory_resource(res);
>  
> +	up_read(&memhp_mutex);
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(add_memory);
>  
> +
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  /*
>   * A free page on the buddy free lists (not the per-cpu lists) has PageBuddy
> @@ -750,20 +766,23 @@ int offline_pages(unsigned long start_pf
>  		return -EINVAL;
>  	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
>  		return -EINVAL;
> +
>  	/* This makes hotplug much easier...and readable.
>  	   we assume this for now. .*/
>  	if (!test_pages_in_a_zone(start_pfn, end_pfn))
>  		return -EINVAL;
>  
> +	down_read(&memhp_mutex);
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	node = zone_to_nid(zone);
>  	nr_pages = end_pfn - start_pfn;
>  
>  	/* set above range as isolated */
>  	ret = start_isolate_page_range(start_pfn, end_pfn);
> -	if (ret)
> +	if (ret) {
> +		up_read(&memhp_mutex);
>  		return ret;
> -
> +	}
>  	arg.start_pfn = start_pfn;
>  	arg.nr_pages = nr_pages;
>  	arg.status_change_nid = -1;
> @@ -838,6 +857,7 @@ repeat:
>  	writeback_set_ratelimit();
>  
>  	memory_notify(MEM_OFFLINE, &arg);
> +	up_read(&memhp_mutex);
>  	return 0;
>  
>  failed_removal:
> @@ -846,7 +866,7 @@ failed_removal:
>  	memory_notify(MEM_CANCEL_OFFLINE, &arg);
>  	/* pushback to free area */
>  	undo_isolate_page_range(start_pfn, end_pfn);
> -
> +	up_read(&memhp_mutex);
>  	return ret;
>  }
>  #else
> @@ -856,3 +876,34 @@ int remove_memory(u64 start, u64 size)
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
> +	int ret;
> +
> +	switch(action) {
> +	case PM_HIBERNATION_PREPARE:
> +		down_write(&memhp_mutex);
> +		break;
> +	case PM_POST_HIBERNATION:
> +		up_write(&memhp_mutex);
> +		break;
> +	case PM_RESTORE_PREPARE:
> +		down_write(&memhp_mutex);
> +		break;
> +	case PM_POST_RESTORE:
> +		up_write(&memhp_mutex);
> +		break;
> +	default:
> +		break;
> +	}
> +	return NOTIFY_OK;
> +}
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
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
