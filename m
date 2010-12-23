Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BA5236B0089
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 19:28:01 -0500 (EST)
Date: Wed, 22 Dec 2010 16:27:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [3/7, v9] NUMA Hotplug Emulator: Add node hotplug emulation
Message-Id: <20101222162723.72075372.akpm@linux-foundation.org>
In-Reply-To: <20101210073242.462037866@intel.com>
References: <20101210073119.156388875@intel.com>
	<20101210073242.462037866@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: shaohui.zheng@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2010 15:31:22 +0800
shaohui.zheng@intel.com wrote:

> From: David Rientjes <rientjes@google.com>
> 
> Add an interface to allow new nodes to be added when performing memory
> hot-add.  This provides a convenient interface to test memory hotplug
> notifier callbacks and surrounding hotplug code when new nodes are
> onlined without actually having a machine with such hotpluggable SRAT
> entries.
> 
> This adds a new debugfs interface at /sys/kernel/debug/mem_hotplug/add_node
> that behaves in a similar way to the memory hot-add "probe" interface.
> Its format is size@start, where "size" is the size of the new node to be
> added and "start" is the physical address of the new memory.
> 
> The new node id is a currently offline, but possible, node.  The bit must
> be set in node_possible_map so that nr_node_ids is sized appropriately.
> 
> For emulation on x86, for example, it would be possible to set aside
> memory for hotplugged nodes (say, anything above 2G) and to add an
> additional four nodes as being possible on boot with
> 
> 	mem=2G numa=possible=4
> 
> and then creating a new 128M node at runtime:
> 
> 	# echo 128M@0x80000000 > /sys/kernel/debug/mem_hotplug/add_node
> 	On node 1 totalpages: 0
> 	init_memory_mapping: 0000000080000000-0000000088000000
> 	 0080000000 - 0088000000 page 2M
> Once the new node has been added, its memory can be onlined.  If this
> memory represents memory section 16, for example:
> 
> 	# echo online > /sys/devices/system/memory/memory16/state
> 	Built 2 zonelists in Node order, mobility grouping on.  Total pages: 514846
> 	Policy zone: Normal
>  [ The memory section(s) mapped to a particular node are visible via
>    /sys/kernel/debug/mem_hotplug/node1, in this example. ]
> 
> The new node is now hotplugged and ready for testing.
> 
> CC: Haicheng Li <haicheng.li@intel.com>
> CC: Greg KH <gregkh@suse.de>
> Signed-off-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> ---
>  Documentation/memory-hotplug.txt |   24 +++++++++++++++
>  mm/memory_hotplug.c              |   59 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 83 insertions(+), 0 deletions(-)
> Index: linux-hpe4/Documentation/memory-hotplug.txt
> ===================================================================
> --- linux-hpe4.orig/Documentation/memory-hotplug.txt	2010-11-30 12:40:43.527622001 +0800
> +++ linux-hpe4/Documentation/memory-hotplug.txt	2010-11-30 14:11:11.827622000 +0800
> @@ -18,6 +18,7 @@
>  4. Physical memory hot-add phase
>    4.1 Hardware(Firmware) Support
>    4.2 Notify memory hot-add event by hand
> +  4.3 Node hotplug emulation
>  5. Logical Memory hot-add phase
>    5.1. State of memory
>    5.2. How to online memory
> @@ -215,6 +216,29 @@
>  Please see "How to online memory" in this text.
>  
>  
> +4.3 Node hotplug emulation
> +------------
> +With debugfs, it is possible to test node hotplug by assigning the newly
> +added memory to a new node id when using a different interface with a similar
> +behavior to "probe" described in section 4.2.  If a node id is possible
> +(there are bits in /sys/devices/system/memory/possible that are not online),
> +then it may be used to emulate a newly added node as the result of memory
> +hotplug by using the debugfs "add_node" interface.
> +
> +The add_node interface is located at "mem_hotplug/add_node" at the debugfs
> +mount point.
> +
> +You can create a new node of a specified size starting at the physical
> +address of new memory by
> +
> +% echo size@start_address_of_new_memory > /sys/kernel/debug/mem_hotplug/add_node
> +
> +Where "size" can be represented in megabytes or gigabytes (for example,
> +"128M" or "1G").  The minumum size is that of a memory section.
> +
> +Once the new node has been added, it is possible to online the memory by
> +toggling the "state" of its memory section(s) as described in section 5.1.
> +
>  
>  ------------------------------
>  5. Logical Memory hot-add phase
> Index: linux-hpe4/mm/memory_hotplug.c
> ===================================================================
> --- linux-hpe4.orig/mm/memory_hotplug.c	2010-11-30 12:40:43.757622001 +0800
> +++ linux-hpe4/mm/memory_hotplug.c	2010-11-30 14:02:33.877622002 +0800
> @@ -924,3 +924,63 @@
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  EXPORT_SYMBOL_GPL(remove_memory);
> +
> +#ifdef CONFIG_DEBUG_FS
> +#include <linux/debugfs.h>
> +
> +static struct dentry *memhp_debug_root;
> +
> +static ssize_t add_node_store(struct file *file, const char __user *buf,
> +				size_t count, loff_t *ppos)
> +{
> +	nodemask_t mask;

NODEMASK_ALLOC()?

> +	u64 start, size;
> +	char buffer[64];
> +	char *p;
> +	int nid;
> +	int ret;
> +
> +	memset(buffer, 0, sizeof(buffer));
> +	if (count > sizeof(buffer) - 1)
> +		count = sizeof(buffer) - 1;

This will cause the write to return a smaller number than `count': a
short write.  Some userspace code may then decide to write the
remainder of the data (whcih is the correct way to use the write()
syscall).

Could be a bit dangerous, and perhaps simply declaring an error if too
much data was written would be a better approach.

> +	if (copy_from_user(buffer, buf, count))
> +		return -EFAULT;
> +
> +	size = memparse(buffer, &p);
> +	if (size < (PAGES_PER_SECTION << PAGE_SHIFT))

PAGES_PER_SECTION has type unsigned long, so the rhs of this comparison
might overflow on 32-bit, should anyone ever try to use this code on
32-bit.

otoh the compiler might do it as 64-bit because the lhs is 64-bit.  Not
sure.

> +		return -EINVAL;
> +	if (*p != '@')
> +		return -EINVAL;
> +
> +	start = simple_strtoull(p + 1, NULL, 0);

You disagreed with checkpatch?

> +	nodes_andnot(mask, node_possible_map, node_online_map);
> +	nid = first_node(mask);
> +	if (nid == MAX_NUMNODES)
> +		return -ENOMEM;
> +
> +	ret = add_memory(nid, start, size);
> +	return ret ? ret : count;
> +}
> +
> +static const struct file_operations add_node_file_ops = {
> +	.write		= add_node_store,
> +	.llseek		= generic_file_llseek,
> +};
> +
> +static int __init node_debug_init(void)
> +{
> +	if (!memhp_debug_root)
> +		memhp_debug_root = debugfs_create_dir("mem_hotplug", NULL);
> +	if (!memhp_debug_root)
> +		return -ENOMEM;
> +
> +	if (!debugfs_create_file("add_node", S_IWUSR, memhp_debug_root,
> +			NULL, &add_node_file_ops))
> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +
> +module_init(node_debug_init);
> +#endif /* CONFIG_DEBUG_FS */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
