Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9AAtn5h011786
	for <linux-mm@kvack.org> (envelope-from y-goto@jp.fujitsu.com);
	Fri, 10 Oct 2008 19:55:49 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 61D2953C161
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 19:55:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 224FE240061
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 19:55:49 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 045ED1DB8041
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 19:55:49 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 97DDB1DB803B
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 19:55:45 +0900 (JST)
Date: Fri, 10 Oct 2008 19:55:45 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] [REPOST] mm: show node to memory section relationship with symlinks in sysfs
In-Reply-To: <20081009192115.GB8793@us.ibm.com>
References: <20081009192115.GB8793@us.ibm.com>
Message-Id: <20081010195455.26D6.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Nish Aravamudan <nish.aravamudan@gmail.com>
List-ID: <linux-mm.kvack.org>

Looks good to me.

Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>


> 
> Show node to memory section relationship with symlinks in sysfs
> 
> Add /sys/devices/system/node/nodeX/memoryY symlinks for all
> the memory sections located on nodeX.  For example:
> /sys/devices/system/node/node1/memory135 -> ../../memory/memory135
> indicates that memory section 135 resides on node1.
> 
> Tested on 2-node x86_64, 2-node ppc64, and 2-node ia64 systems.
> 
> Also revises documentation to cover this change as well as updating
> Documentation/ABI/testing/sysfs-devices-memory to include descriptions
> of memory hotremove files 'phys_device', 'phys_index', and 'state'
> that were previously not described there.
> 
> Supersedes the "mm: show memory section to node relationship in sysfs"
> patch posted on 05 Sept 2008 which created node ID containing 'node'
> files in /sys/devices/system/memory/memoryX instead of symlinks.
> Changed from files to symlinks due to feedback that symlinks were
> more consistent with the sysfs way.
> 
> Also supercedes the "mm: show node to memory section relationship
> with symlinks in sysfs" patch posted on 29 Sept 2008 to address a
> Yasunori Goto reported problem where an incorrect symlink was created
> due to a range of uninitialized pages at the beginning of a section.
> This problem which produced a symlink in /sys/devices/system/node/node0
> that incorrectly referenced a mem section located on node1 is corrected
> in this version.  This version also covers the case were a mem section
> could span multiple nodes.
> 
> Signed-off-by: Gary Hade <garyhade@us.ibm.com>
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> 
> ---
>  Documentation/ABI/testing/sysfs-devices-memory |   51 +++++++
>  Documentation/memory-hotplug.txt               |   16 +-
>  arch/ia64/mm/init.c                            |    2 
>  arch/powerpc/mm/mem.c                          |    2 
>  arch/s390/mm/init.c                            |    2 
>  arch/sh/mm/init.c                              |    3 
>  arch/x86/mm/init_32.c                          |    2 
>  arch/x86/mm/init_64.c                          |    2 
>  drivers/base/memory.c                          |   19 +-
>  drivers/base/node.c                            |  100 +++++++++++++++
>  include/linux/memory.h                         |    6 
>  include/linux/memory_hotplug.h                 |    2 
>  include/linux/node.h                           |   13 +
>  mm/memory_hotplug.c                            |    9 -
>  14 files changed, 205 insertions(+), 24 deletions(-)
> 
> Index: linux-2.6.27-rc8/Documentation/ABI/testing/sysfs-devices-memory
> ===================================================================
> --- linux-2.6.27-rc8.orig/Documentation/ABI/testing/sysfs-devices-memory	2008-10-06 11:18:46.000000000 -0700
> +++ linux-2.6.27-rc8/Documentation/ABI/testing/sysfs-devices-memory	2008-10-06 11:20:19.000000000 -0700
> @@ -6,7 +6,6 @@
>  		internal state of the kernel memory blocks. Files could be
>  		added or removed dynamically to represent hot-add/remove
>  		operations.
> -
>  Users:		hotplug memory add/remove tools
>  		https://w3.opensource.ibm.com/projects/powerpc-utils/
>  
> @@ -19,6 +18,56 @@
>  		This is useful for a user-level agent to determine
>  		identify removable sections of the memory before attempting
>  		potentially expensive hot-remove memory operation
> +Users:		hotplug memory remove tools
> +		https://w3.opensource.ibm.com/projects/powerpc-utils/
> +
> +What:		/sys/devices/system/memory/memoryX/phys_device
> +Date:		September 2008
> +Contact:	Badari Pulavarty <pbadari@us.ibm.com>
> +Description:
> +		The file /sys/devices/system/memory/memoryX/phys_device
> +		is read-only and is designed to show the name of physical
> +		memory device.  Implementation is currently incomplete.
>  
> +What:		/sys/devices/system/memory/memoryX/phys_index
> +Date:		September 2008
> +Contact:	Badari Pulavarty <pbadari@us.ibm.com>
> +Description:
> +		The file /sys/devices/system/memory/memoryX/phys_index
> +		is read-only and contains the section ID in hexadecimal
> +		which is equivalent to decimal X contained in the
> +		memory section directory name.
> +
> +What:		/sys/devices/system/memory/memoryX/state
> +Date:		September 2008
> +Contact:	Badari Pulavarty <pbadari@us.ibm.com>
> +Description:
> +		The file /sys/devices/system/memory/memoryX/state
> +		is read-write.  When read, it's contents show the
> +		online/offline state of the memory section.  When written,
> +		root can toggle the the online/offline state of a removable
> +		memory section (see removable file description above)
> +		using the following commands.
> +		# echo online > /sys/devices/system/memory/memoryX/state
> +		# echo offline > /sys/devices/system/memory/memoryX/state
> +
> +		For example, if /sys/devices/system/memory/memory22/removable
> +		contains a value of 1 and
> +		/sys/devices/system/memory/memory22/state contains the
> +		string "online" the following command can be executed by
> +		by root to offline that section.
> +		# echo offline > /sys/devices/system/memory/memory22/state
>  Users:		hotplug memory remove tools
>  		https://w3.opensource.ibm.com/projects/powerpc-utils/
> +
> +What:		/sys/devices/system/node/nodeX/memoryY
> +Date:		September 2008
> +Contact:	Gary Hade <garyhade@us.ibm.com>
> +Description:
> +		When CONFIG_NUMA is enabled
> +		/sys/devices/system/node/nodeX/memoryY is a symbolic link that
> +		points to the corresponding /sys/devices/system/memory/memoryY
> +		memory section directory.  For example, the following symbolic
> +		link is created for memory section 9 on node0.
> +		/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
> +
> Index: linux-2.6.27-rc8/Documentation/memory-hotplug.txt
> ===================================================================
> --- linux-2.6.27-rc8.orig/Documentation/memory-hotplug.txt	2008-10-06 11:18:45.000000000 -0700
> +++ linux-2.6.27-rc8/Documentation/memory-hotplug.txt	2008-10-06 11:20:42.000000000 -0700
> @@ -124,7 +124,7 @@
>      This option can be kernel module too.
>  
>  --------------------------------
> -3 sysfs files for memory hotplug
> +4 sysfs files for memory hotplug
>  --------------------------------
>  All sections have their device information under /sys/devices/system/memory as
>  
> @@ -138,11 +138,12 @@
>  (0x100000000 / 1Gib = 4)
>  This device covers address range [0x100000000 ... 0x140000000)
>  
> -Under each section, you can see 3 files.
> +Under each section, you can see 4 files.
>  
>  /sys/devices/system/memory/memoryXXX/phys_index
>  /sys/devices/system/memory/memoryXXX/phys_device
>  /sys/devices/system/memory/memoryXXX/state
> +/sys/devices/system/memory/memoryXXX/removable
>  
>  'phys_index' : read-only and contains section id, same as XXX.
>  'state'      : read-write
> @@ -150,10 +151,20 @@
>                 at write: user can specify "online", "offline" command
>  'phys_device': read-only: designed to show the name of physical memory device.
>                 This is not well implemented now.
> +'removable'  : read-only: contains an integer value indicating
> +               whether the memory section is removable or not
> +               removable.  A value of 1 indicates that the memory
> +               section is removable and a value of 0 indicates that
> +               it is not removable.
>  
>  NOTE:
>    These directories/files appear after physical memory hotplug phase.
>  
> +If CONFIG_NUMA is enabled the
> +/sys/devices/system/memory/memoryXXX memory section
> +directories can also be accessed via symbolic links located in
> +the /sys/devices/system/node/node* directories.  For example:
> +/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
>  
>  --------------------------------
>  4. Physical memory hot-add phase
> @@ -365,7 +376,6 @@
>    - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
>      sysctl or new control file.
>    - showing memory section and physical device relationship.
> -  - showing memory section and node relationship (maybe good for NUMA)
>    - showing memory section is under ZONE_MOVABLE or not
>    - test and make it better memory offlining.
>    - support HugeTLB page migration and offlining.
> Index: linux-2.6.27-rc8/arch/ia64/mm/init.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/arch/ia64/mm/init.c	2008-10-06 11:18:45.000000000 -0700
> +++ linux-2.6.27-rc8/arch/ia64/mm/init.c	2008-10-06 11:19:41.000000000 -0700
> @@ -693,7 +693,7 @@
>  	pgdat = NODE_DATA(nid);
>  
>  	zone = pgdat->node_zones + ZONE_NORMAL;
> -	ret = __add_pages(zone, start_pfn, nr_pages);
> +	ret = __add_pages(nid, zone, start_pfn, nr_pages);
>  
>  	if (ret)
>  		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
> Index: linux-2.6.27-rc8/arch/powerpc/mm/mem.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/arch/powerpc/mm/mem.c	2008-10-06 11:18:44.000000000 -0700
> +++ linux-2.6.27-rc8/arch/powerpc/mm/mem.c	2008-10-06 11:19:41.000000000 -0700
> @@ -133,7 +133,7 @@
>  	/* this should work for most non-highmem platforms */
>  	zone = pgdata->node_zones;
>  
> -	return __add_pages(zone, start_pfn, nr_pages);
> +	return __add_pages(nid, zone, start_pfn, nr_pages);
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> Index: linux-2.6.27-rc8/arch/s390/mm/init.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/arch/s390/mm/init.c	2008-10-06 11:18:45.000000000 -0700
> +++ linux-2.6.27-rc8/arch/s390/mm/init.c	2008-10-06 11:19:41.000000000 -0700
> @@ -183,7 +183,7 @@
>  	rc = vmem_add_mapping(start, size);
>  	if (rc)
>  		return rc;
> -	rc = __add_pages(zone, PFN_DOWN(start), PFN_DOWN(size));
> +	rc = __add_pages(nid, zone, PFN_DOWN(start), PFN_DOWN(size));
>  	if (rc)
>  		vmem_remove_mapping(start, size);
>  	return rc;
> Index: linux-2.6.27-rc8/arch/sh/mm/init.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/arch/sh/mm/init.c	2008-10-06 11:18:45.000000000 -0700
> +++ linux-2.6.27-rc8/arch/sh/mm/init.c	2008-10-06 11:19:41.000000000 -0700
> @@ -276,7 +276,8 @@
>  	pgdat = NODE_DATA(nid);
>  
>  	/* We only have ZONE_NORMAL, so this is easy.. */
> -	ret = __add_pages(pgdat->node_zones + ZONE_NORMAL, start_pfn, nr_pages);
> +	ret = __add_pages(nid, pgdat->node_zones + ZONE_NORMAL,
> +				start_pfn, nr_pages);
>  	if (unlikely(ret))
>  		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
>  
> Index: linux-2.6.27-rc8/arch/x86/mm/init_32.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/arch/x86/mm/init_32.c	2008-10-06 11:18:45.000000000 -0700
> +++ linux-2.6.27-rc8/arch/x86/mm/init_32.c	2008-10-06 11:19:41.000000000 -0700
> @@ -995,7 +995,7 @@
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  
> -	return __add_pages(zone, start_pfn, nr_pages);
> +	return __add_pages(nid, zone, start_pfn, nr_pages);
>  }
>  #endif
>  
> Index: linux-2.6.27-rc8/drivers/base/memory.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/drivers/base/memory.c	2008-10-06 11:18:44.000000000 -0700
> +++ linux-2.6.27-rc8/drivers/base/memory.c	2008-10-06 11:19:41.000000000 -0700
> @@ -345,8 +345,9 @@
>   * section belongs to...
>   */
>  
> -static int add_memory_block(unsigned long node_id, struct mem_section *section,
> -		     unsigned long state, int phys_device)
> +static int add_memory_block(int nid, struct mem_section *section,
> +			unsigned long state, int phys_device,
> +			enum mem_add_context context)
>  {
>  	struct memory_block *mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>  	int ret = 0;
> @@ -368,6 +369,10 @@
>  		ret = mem_create_simple_file(mem, phys_device);
>  	if (!ret)
>  		ret = mem_create_simple_file(mem, removable);
> +	if (!ret) {
> +		if (context == HOTPLUG)
> +			ret = register_mem_sect_under_node(mem, nid);
> +	}
>  
>  	return ret;
>  }
> @@ -380,7 +385,7 @@
>   *
>   * This could be made generic for all sysdev classes.
>   */
> -static struct memory_block *find_memory_block(struct mem_section *section)
> +struct memory_block *find_memory_block(struct mem_section *section)
>  {
>  	struct kobject *kobj;
>  	struct sys_device *sysdev;
> @@ -409,6 +414,7 @@
>  	struct memory_block *mem;
>  
>  	mem = find_memory_block(section);
> +	unregister_mem_sect_under_nodes(mem);
>  	mem_remove_simple_file(mem, phys_index);
>  	mem_remove_simple_file(mem, state);
>  	mem_remove_simple_file(mem, phys_device);
> @@ -422,9 +428,9 @@
>   * need an interface for the VM to add new memory regions,
>   * but without onlining it.
>   */
> -int register_new_memory(struct mem_section *section)
> +int register_new_memory(int nid, struct mem_section *section)
>  {
> -	return add_memory_block(0, section, MEM_OFFLINE, 0);
> +	return add_memory_block(nid, section, MEM_OFFLINE, 0, HOTPLUG);
>  }
>  
>  int unregister_memory_section(struct mem_section *section)
> @@ -456,7 +462,8 @@
>  	for (i = 0; i < NR_MEM_SECTIONS; i++) {
>  		if (!present_section_nr(i))
>  			continue;
> -		err = add_memory_block(0, __nr_to_section(i), MEM_ONLINE, 0);
> +		err = add_memory_block(0, __nr_to_section(i), MEM_ONLINE,
> +					0, BOOT);
>  		if (!ret)
>  			ret = err;
>  	}
> Index: linux-2.6.27-rc8/drivers/base/node.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/drivers/base/node.c	2008-10-06 11:18:44.000000000 -0700
> +++ linux-2.6.27-rc8/drivers/base/node.c	2008-10-06 11:19:41.000000000 -0700
> @@ -6,6 +6,7 @@
>  #include <linux/module.h>
>  #include <linux/init.h>
>  #include <linux/mm.h>
> +#include <linux/memory.h>
>  #include <linux/node.h>
>  #include <linux/hugetlb.h>
>  #include <linux/cpumask.h>
> @@ -225,6 +226,102 @@
>  	return 0;
>  }
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
> +#define page_initialized(page)  (page->lru.next)
> +
> +static int get_nid_for_pfn(unsigned long pfn)
> +{
> +	struct page *page;
> +
> +	if (!pfn_valid_within(pfn))
> +		return -1;
> +	page = pfn_to_page(pfn);
> +	if (!page_initialized(page))
> +		return -1;
> +	return pfn_to_nid(pfn);
> +}
> +
> +/* register memory section under specified node if it spans that node */
> +int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
> +{
> +	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> +
> +	if (!mem_blk)
> +		return -EFAULT;
> +	if (!node_online(nid))
> +		return 0;
> +	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
> +	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> +	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> +		int page_nid;
> +
> +		page_nid = get_nid_for_pfn(pfn);
> +		if (page_nid < 0)
> +			continue;
> +		if (page_nid != nid)
> +			continue;
> +		return sysfs_create_link_nowarn(&node_devices[nid].sysdev.kobj,
> +					&mem_blk->sysdev.kobj,
> +					kobject_name(&mem_blk->sysdev.kobj));
> +	}
> +	/* mem section does not span the specified node */
> +	return 0;
> +}
> +
> +/* unregister memory section under all nodes that it spans */
> +int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
> +{
> +	nodemask_t unlinked_nodes;
> +	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> +
> +	if (!mem_blk)
> +		return -EFAULT;
> +	nodes_clear(unlinked_nodes);
> +	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
> +	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> +	for (pfn = sect_start_pfn; pfn < sect_end_pfn; pfn++) {
> +		unsigned int nid;
> +
> +		nid = get_nid_for_pfn(pfn);
> +		if (nid < 0)
> +			continue;
> +		if (!node_online(nid))
> +			continue;
> +		if (node_test_and_set(nid, unlinked_nodes))
> +			continue;
> +		sysfs_remove_link(&node_devices[nid].sysdev.kobj,
> +			 kobject_name(&mem_blk->sysdev.kobj));
> +	}
> +	return 0;
> +}
> +
> +static int link_mem_sections(int nid)
> +{
> +	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
> +	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
> +	unsigned long pfn;
> +	int err = 0;
> +
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +		unsigned long section_nr = pfn_to_section_nr(pfn);
> +		struct mem_section *mem_sect;
> +		struct memory_block *mem_blk;
> +		int ret;
> +
> +		if (!present_section_nr(section_nr))
> +			continue;
> +		mem_sect = __nr_to_section(section_nr);
> +		mem_blk = find_memory_block(mem_sect);
> +		ret = register_mem_sect_under_node(mem_blk, nid);
> +		if (!err)
> +			err = ret;
> +	}
> +	return err;
> +}
> +#else
> +static int link_mem_sections(int nid) { return 0; }
> +#endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> +
>  int register_one_node(int nid)
>  {
>  	int error = 0;
> @@ -244,6 +341,9 @@
>  			if (cpu_to_node(cpu) == nid)
>  				register_cpu_under_node(cpu, nid);
>  		}
> +
> +		/* link memory sections under this node */
> +		error = link_mem_sections(nid);
>  	}
>  
>  	return error;
> Index: linux-2.6.27-rc8/include/linux/memory.h
> ===================================================================
> --- linux-2.6.27-rc8.orig/include/linux/memory.h	2008-10-06 11:18:44.000000000 -0700
> +++ linux-2.6.27-rc8/include/linux/memory.h	2008-10-06 11:19:41.000000000 -0700
> @@ -79,14 +79,14 @@
>  #else
>  extern int register_memory_notifier(struct notifier_block *nb);
>  extern void unregister_memory_notifier(struct notifier_block *nb);
> -extern int register_new_memory(struct mem_section *);
> +extern int register_new_memory(int, struct mem_section *);
>  extern int unregister_memory_section(struct mem_section *);
>  extern int memory_dev_init(void);
>  extern int remove_memory_block(unsigned long, struct mem_section *, int);
>  extern int memory_notify(unsigned long val, void *v);
> +extern struct memory_block *find_memory_block(struct mem_section *);
>  #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
> -
> -
> +enum mem_add_context { BOOT, HOTPLUG };
>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> Index: linux-2.6.27-rc8/include/linux/memory_hotplug.h
> ===================================================================
> --- linux-2.6.27-rc8.orig/include/linux/memory_hotplug.h	2008-10-06 11:18:44.000000000 -0700
> +++ linux-2.6.27-rc8/include/linux/memory_hotplug.h	2008-10-06 11:19:41.000000000 -0700
> @@ -72,7 +72,7 @@
>  extern int offline_pages(unsigned long, unsigned long, unsigned long);
>  
>  /* reasonably generic interface to expand the physical pages in a zone  */
> -extern int __add_pages(struct zone *zone, unsigned long start_pfn,
> +extern int __add_pages(int nid, struct zone *zone, unsigned long start_pfn,
>  	unsigned long nr_pages);
>  extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
>  	unsigned long nr_pages);
> Index: linux-2.6.27-rc8/include/linux/node.h
> ===================================================================
> --- linux-2.6.27-rc8.orig/include/linux/node.h	2008-10-06 11:18:44.000000000 -0700
> +++ linux-2.6.27-rc8/include/linux/node.h	2008-10-06 11:19:41.000000000 -0700
> @@ -26,6 +26,7 @@
>  	struct sys_device	sysdev;
>  };
>  
> +struct memory_block;
>  extern struct node node_devices[];
>  
>  extern int register_node(struct node *, int, struct node *);
> @@ -35,6 +36,9 @@
>  extern void unregister_one_node(int nid);
>  extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
> +extern int register_mem_sect_under_node(struct memory_block *mem_blk,
> +						int nid);
> +extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk);
>  #else
>  static inline int register_one_node(int nid)
>  {
> @@ -52,6 +56,15 @@
>  {
>  	return 0;
>  }
> +static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
> +							int nid)
> +{
> +	return 0;
> +}
> +static inline int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
> +{
> +	return 0;
> +}
>  #endif
>  
>  #define to_node(sys_device) container_of(sys_device, struct node, sysdev)
> Index: linux-2.6.27-rc8/mm/memory_hotplug.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/mm/memory_hotplug.c	2008-10-06 11:18:44.000000000 -0700
> +++ linux-2.6.27-rc8/mm/memory_hotplug.c	2008-10-06 11:19:41.000000000 -0700
> @@ -216,7 +216,8 @@
>  	return 0;
>  }
>  
> -static int __add_section(struct zone *zone, unsigned long phys_start_pfn)
> +static int __add_section(int nid, struct zone *zone,
> +				unsigned long phys_start_pfn)
>  {
>  	int nr_pages = PAGES_PER_SECTION;
>  	int ret;
> @@ -234,7 +235,7 @@
>  	if (ret < 0)
>  		return ret;
>  
> -	return register_new_memory(__pfn_to_section(phys_start_pfn));
> +	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
>  }
>  
>  #ifdef CONFIG_SPARSEMEM_VMEMMAP
> @@ -273,7 +274,7 @@
>   * call this function after deciding the zone to which to
>   * add the new pages.
>   */
> -int __add_pages(struct zone *zone, unsigned long phys_start_pfn,
> +int __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
>  		 unsigned long nr_pages)
>  {
>  	unsigned long i;
> @@ -284,7 +285,7 @@
>  	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
>  
>  	for (i = start_sec; i <= end_sec; i++) {
> -		err = __add_section(zone, i << PFN_SECTION_SHIFT);
> +		err = __add_section(nid, zone, i << PFN_SECTION_SHIFT);
>  
>  		/*
>  		 * EEXIST is finally dealt with by ioresource collision
> Index: linux-2.6.27-rc8/arch/x86/mm/init_64.c
> ===================================================================
> --- linux-2.6.27-rc8.orig/arch/x86/mm/init_64.c	2008-10-06 11:18:45.000000000 -0700
> +++ linux-2.6.27-rc8/arch/x86/mm/init_64.c	2008-10-06 11:24:09.000000000 -0700
> @@ -725,7 +725,7 @@
>  	if (last_mapped_pfn > max_pfn_mapped)
>  		max_pfn_mapped = last_mapped_pfn;
>  
> -	ret = __add_pages(zone, start_pfn, nr_pages);
> +	ret = __add_pages(nid, zone, start_pfn, nr_pages);
>  	WARN_ON(1);
>  
>  	return ret;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
