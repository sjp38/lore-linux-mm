Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6E9276B009B
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 05:45:26 -0500 (EST)
Message-Id: <20101129091935.703824659@intel.com>
References: <20101129091750.950277284@intel.com>
Date: Mon, 29 Nov 2010 17:17:52 +0800
From: shaohui.zheng@intel.com
Subject: [2/8, v5] NUMA Hotplug Emulator: Add node hotplug emulation
Content-Disposition: inline; filename=002-node-hotplug-v2.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Shaohui Zheng <shaohui.zheng@intel.com>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

From: David Rientjes <rientjes@google.com>

Add an interface to allow new nodes to be added when performing memory
hot-add.  This provides a convenient interface to test memory hotplug
notifier callbacks and surrounding hotplug code when new nodes are
onlined without actually having a machine with such hotpluggable SRAT
entries.

This adds a new debugfs interface at /sys/kernel/debug/hotplug/add_node
that behaves in a similar way to the memory hot-add "probe" interface.
Its format is size@start, where "size" is the size of the new node to be
added and "start" is the physical address of the new memory.

The new node id is a currently offline, but possible, node.  The bit must
be set in node_possible_map so that nr_node_ids is sized appropriately.

For emulation on x86, for example, it would be possible to set aside
memory for hotplugged nodes (say, anything above 2G) and to add an
additional four nodes as being possible on boot with

	mem=2G numa=possible=4

and then creating a new 128M node at runtime:

	# echo 128M@0x80000000 > /sys/kernel/debug/node/add_node
	On node 1 totalpages: 0
	init_memory_mapping: 0000000080000000-0000000088000000
	 0080000000 - 0088000000 page 2M
Once the new node has been added, its memory can be onlined.  If this
memory represents memory section 16, for example:

	# echo online > /sys/devices/system/memory/memory16/state
	Built 2 zonelists in Node order, mobility grouping on.  Total pages: 514846
	Policy zone: Normal
 [ The memory section(s) mapped to a particular node are visible via
   /sys/devices/system/node/node1, in this example. ]

The new node is now hotplugged and ready for testing.

CC: Shaohui Zheng <shaohui.zheng@intel.com>
CC: Haicheng Li <haicheng.li@intel.com>
CC: Greg KH <gregkh@suse.de>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: moved to debugfs as suggested by Greg KH
 (patch 1/2: "x86: add numa=possible command line option" is still valid)

 Documentation/memory-hotplug.txt |   24 +++++++++++++++
 mm/memory_hotplug.c              |   59 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 83 insertions(+), 0 deletions(-)
diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -18,6 +18,7 @@ be changed often.
 4. Physical memory hot-add phase
   4.1 Hardware(Firmware) Support
   4.2 Notify memory hot-add event by hand
+  4.3 Node hotplug emulation
 5. Logical Memory hot-add phase
   5.1. State of memory
   5.2. How to online memory
@@ -215,6 +216,29 @@ current implementation). You'll have to online memory by yourself.
 Please see "How to online memory" in this text.
 
 
+4.3 Node hotplug emulation
+------------
+With debugfs, it is possible to test node hotplug by assigning the newly
+added memory to a new node id when using a different interface with a similar
+behavior to "probe" described in section 4.2.  If a node id is possible
+(there are bits in /sys/devices/system/memory/possible that are not online),
+then it may be used to emulate a newly added node as the result of memory
+hotplug by using the debugfs "add_node" interface.
+
+The add_node interface is located at "node/add_node" at the debugfs mount
+point.
+
+You can create a new node of a specified size starting at the physical
+address of new memory by
+
+% echo size@start_address_of_new_memory > /sys/kernel/debug/node/add_node
+
+Where "size" can be represented in megabytes or gigabytes (for example,
+"128M" or "1G").  The minumum size is that of a memory section.
+
+Once the new node has been added, it is possible to online the memory by
+toggling the "state" of its memory section(s) as described in section 5.1.
+
 
 ------------------------------
 5. Logical Memory hot-add phase
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -910,3 +910,62 @@ int remove_memory(u64 start, u64 size)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 EXPORT_SYMBOL_GPL(remove_memory);
+
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+
+static struct dentry *node_debug_root;
+
+static ssize_t add_node_store(struct file *file, const char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	nodemask_t mask;
+	u64 start, size;
+	char buffer[64];
+	char *p;
+	int nid;
+	int ret;
+
+	memset(buffer, 0, sizeof(buffer));
+	if (count > sizeof(buffer) - 1)
+		count = sizeof(buffer) - 1;
+	if (copy_from_user(buffer, buf, count))
+		return -EFAULT;
+
+	size = memparse(buffer, &p);
+	if (size < (PAGES_PER_SECTION << PAGE_SHIFT))
+		return -EINVAL;
+	if (*p != '@')
+		return -EINVAL;
+
+	start = simple_strtoull(p + 1, NULL, 0);
+
+	nodes_andnot(mask, node_possible_map, node_online_map);
+	nid = first_node(mask);
+	if (nid == MAX_NUMNODES)
+		return -ENOMEM;
+
+	ret = add_memory(nid, start, size);
+	return ret ? ret : count;
+}
+
+static const struct file_operations add_node_file_ops = {
+	.write		= add_node_store,
+	.llseek		= generic_file_llseek,
+};
+
+static int __init node_debug_init(void)
+{
+	node_debug_root = debugfs_create_dir("node", NULL);
+	if (!node_debug_root)
+		return -ENOMEM;
+
+	if (!debugfs_create_file("add_node", S_IWUSR, node_debug_root,
+			NULL, &add_node_file_ops))
+		return -ENOMEM;
+
+	return 0;
+}
+
+module_init(node_debug_init);
+#endif /* CONFIG_DEBUG_FS */

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
