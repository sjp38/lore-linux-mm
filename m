Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9AAukup001500
	for <linux-mm@kvack.org> (envelope-from y-goto@jp.fujitsu.com);
	Fri, 10 Oct 2008 19:56:46 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5887B2AC027
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 19:56:46 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3102A12C044
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 19:56:46 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id F0F091DB803A
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 19:56:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 67AB21DB803B
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 19:56:42 +0900 (JST)
Date: Fri, 10 Oct 2008 19:56:42 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: Subject: [PATCH 2/2] mm: include memory section subtree in sysfs with only sparsemem enabled
In-Reply-To: <20081009192126.GC8793@us.ibm.com>
References: <20081009192126.GC8793@us.ibm.com>
Message-Id: <20081010195555.26D8.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Nish Aravamudan <nish.aravamudan@gmail.com>
List-ID: <linux-mm.kvack.org>

Thanks.

Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>

> 
> Include memory section subtree in sysfs with only Sparsemem enabled.
> 
> Inclusion of the /sys/devices/system/memory subtree and symlinks
> to the /sys/devices/system/memory/memory* memory section directories
> from /sys/devices/system/node/node* currently depend on both Memory
> Hotplug (CONFIG_MEMORY_HOTPLUG) and Sparsemem (CONFIG_SPARSEMEM) being
> enabled.  This change eliminates the Memory Hotplug dependency so that
> the useful memory section information will be available in sysfs when
> only Sparsemem is enabled.
> 
> Tested on 2-node x86_64, 2-node ppc64, and 2-node ia64 systems.
> 
> This change is in response to the suggestion received from Yasunori
> Goto on 30 Sept 2008 in his review comments with respect to the
> "mm: show node to memory section relationship with symlinks in sysfs"
> patch posted on 29 Sept 2008.
> 
> Signed-off-by: Gary Hade <garyhade@us.ibm.com>
> 
> ---
>  drivers/base/Makefile  |    2 +-
>  drivers/base/memory.c  |    9 +++++++++
>  drivers/base/node.c    |    4 ++--
>  include/linux/memory.h |    4 ++--
>  4 files changed, 14 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.27-rc8/drivers/base/Makefile
> ===================================================================
> --- linux-2.6.27-rc8.orig/drivers/base/Makefile	2008-10-07 13:13:48.000000000 -0700
> +++ linux-2.6.27-rc8/drivers/base/Makefile	2008-10-07 13:14:13.000000000 -0700
> @@ -9,7 +9,7 @@
>  obj-$(CONFIG_ISA)	+= isa.o
>  obj-$(CONFIG_FW_LOADER)	+= firmware_class.o
>  obj-$(CONFIG_NUMA)	+= node.o
> -obj-$(CONFIG_MEMORY_HOTPLUG_SPARSE) += memory.o
> +obj-$(CONFIG_SPARSEMEM) += memory.o
>  obj-$(CONFIG_SMP)	+= topology.o
>  ifeq ($(CONFIG_SYSFS),y)
>  obj-$(CONFIG_MODULES)	+= module.o
> Index: linux-2.6.27-rc8/drivers/base/memory.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/drivers/base/memory.c	2008-10-07 13:13:56.000000000 -0700
> +++ linux-2.6.27-rc8/drivers/base/memory.c	2008-10-07 13:14:13.000000000 -0700
> @@ -155,6 +155,7 @@
>  	return blocking_notifier_call_chain(&memory_chain, val, v);
>  }
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG
>  /*
>   * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
>   * OK to have direct references to sparsemem variables in here.
> @@ -256,6 +257,14 @@
>  		return ret;
>  	return count;
>  }
> +#else
> +static ssize_t
> +store_mem_state(struct sys_device *dev,
> +		struct sysdev_attribute *attr, const char *buf, size_t count)
> +{
> +	return -EINVAL;
> +}
> +#endif /* CONFIG_MEMORY_HOTPLUG */
>  
>  /*
>   * phys_device is a bad name for this.  What I really want
> Index: linux-2.6.27-rc8/drivers/base/node.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/drivers/base/node.c	2008-10-07 13:13:51.000000000 -0700
> +++ linux-2.6.27-rc8/drivers/base/node.c	2008-10-07 13:14:13.000000000 -0700
> @@ -226,7 +226,7 @@
>  	return 0;
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
> +#ifdef CONFIG_SPARSEMEM
>  #define page_initialized(page)  (page->lru.next)
>  
>  static int get_nid_for_pfn(unsigned long pfn)
> @@ -320,7 +320,7 @@
>  }
>  #else
>  static int link_mem_sections(int nid) { return 0; }
> -#endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> +#endif /* CONFIG_SPARSEMEM */
>  
>  int register_one_node(int nid)
>  {
> Index: linux-2.6.27-rc8/include/linux/memory.h
> ===================================================================
> --- linux-2.6.27-rc8.orig/include/linux/memory.h	2008-10-07 13:13:41.000000000 -0700
> +++ linux-2.6.27-rc8/include/linux/memory.h	2008-10-07 13:14:13.000000000 -0700
> @@ -60,7 +60,7 @@
>  #define SLAB_CALLBACK_PRI       1
>  #define IPC_CALLBACK_PRI        10
>  
> -#ifndef CONFIG_MEMORY_HOTPLUG_SPARSE
> +#ifndef CONFIG_SPARSEMEM
>  static inline int memory_dev_init(void)
>  {
>  	return 0;
> @@ -87,7 +87,7 @@
>  extern struct memory_block *find_memory_block(struct mem_section *);
>  #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
>  enum mem_add_context { BOOT, HOTPLUG };
> -#endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> +#endif /* CONFIG_SPARSEMEM */
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  #define hotplug_memory_notifier(fn, pri) {			\

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
