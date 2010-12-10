Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C64336B0095
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 04:01:23 -0500 (EST)
Message-Id: <20101210073242.876873390@intel.com>
References: <20101210073119.156388875@intel.com>
Date: Fri, 10 Dec 2010 15:31:26 +0800
From: shaohui.zheng@intel.com
Subject: [7/7, v9] NUMA Hotplug Emulator: Implement per-node add_memory debugfs interface
Content-Disposition: inline; filename=007-hotplug-emulator-add-memory-debugfs-interface.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>, Shaohui Zheng <shaohui.zheng@intel.com>
List-ID: <linux-mm.kvack.org>

From:  Shaohui Zheng <shaohui.zheng@intel.com>

Add add_memory interface to support to memory hotplug emulation for each online
node under debugfs. The reserved memory can be added into desired node with
this interface.

The layout on debugfs:
	mem_hotplug/node0/add_memory
	mem_hotplug/node1/add_memory
	mem_hotplug/node2/add_memory
	...

Add a memory section(128M) to node 3(boots with mem=1024m)

	echo 0x40000000 > mem_hotplug/node3/add_memory

CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
Index: linux-hpe4/mm/memory_hotplug.c
===================================================================
--- linux-hpe4.orig/mm/memory_hotplug.c	2010-12-10 13:22:44.753331000 +0800
+++ linux-hpe4/mm/memory_hotplug.c	2010-12-10 13:41:48.803331000 +0800
@@ -933,6 +933,81 @@
 
 static struct dentry *memhp_debug_root;
 
+#ifdef CONFIG_ARCH_MEMORY_PROBE
+
+static ssize_t add_memory_store(struct file *file, const char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	u64 phys_addr = 0;
+	int nid = file->private_data - NULL;
+	int ret;
+
+	printk(KERN_INFO "Add a memory section to node: %d.\n", nid);
+	phys_addr = simple_strtoull(buf, NULL, 0);
+
+	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+	if (ret)
+		count = ret;
+
+	return count;
+}
+
+static int add_memory_open(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static const struct file_operations add_memory_file_ops = {
+	.open		= add_memory_open,
+	.write		= add_memory_store,
+	.llseek		= generic_file_llseek,
+};
+
+/*
+ * Create add_memory debugfs entry under specified node
+ */
+static int debugfs_create_add_memory_entry(int nid)
+{
+	char buf[32];
+	static struct dentry *node_debug_root;
+
+	snprintf(buf, sizeof(buf), "node%d", nid);
+	node_debug_root = debugfs_create_dir(buf, memhp_debug_root);
+	if (!node_debug_root)
+		return -ENOMEM;
+
+	/* the nid information was represented by the offset of pointer(NULL+nid) */
+	if (!debugfs_create_file("add_memory", S_IWUSR, node_debug_root,
+			NULL + nid, &add_memory_file_ops))
+		return -ENOMEM;
+
+	return 0;
+}
+
+static int __init memory_debug_init(void)
+{
+	int nid;
+
+	if (!memhp_debug_root)
+		memhp_debug_root = debugfs_create_dir("mem_hotplug", NULL);
+	if (!memhp_debug_root)
+		return -ENOMEM;
+
+	for_each_online_node(nid)
+		 debugfs_create_add_memory_entry(nid);
+
+	return 0;
+}
+
+module_init(memory_debug_init);
+#else
+static debugfs_create_add_memory_entry(int nid)
+{
+	return 0;
+}
+#endif /* CONFIG_ARCH_MEMORY_PROBE */
+
 static ssize_t add_node_store(struct file *file, const char __user *buf,
 				size_t count, loff_t *ppos)
 {
@@ -963,6 +1038,8 @@
 		return -ENOMEM;
 
 	ret = add_memory(nid, start, size);
+
+	debugfs_create_add_memory_entry(nid);
 	return ret ? ret : count;
 }
 
Index: linux-hpe4/Documentation/memory-hotplug.txt
===================================================================
--- linux-hpe4.orig/Documentation/memory-hotplug.txt	2010-12-10 13:22:44.733331000 +0800
+++ linux-hpe4/Documentation/memory-hotplug.txt	2010-12-10 13:42:12.783331002 +0800
@@ -19,6 +19,7 @@
   4.1 Hardware(Firmware) Support
   4.2 Notify memory hot-add event by hand
   4.3 Node hotplug emulation
+  4.4 Memory hotplug emulation
 5. Logical Memory hot-add phase
   5.1. State of memory
   5.2. How to online memory
@@ -239,6 +240,25 @@
 Once the new node has been added, it is possible to online the memory by
 toggling the "state" of its memory section(s) as described in section 5.1.
 
+4.4 Memory hotplug emulation
+------------
+With debugfs, it is possible to test memory hotplug with software method, we
+can add memory section to desired node with add_memory interface. It is a much
+more powerful interface than "probe" described in section 4.2.
+
+There is an add_memory interface for each online node at the debugfs mount
+point.
+	mem_hotplug/node0/add_memory
+	mem_hotplug/node1/add_memory
+	mem_hotplug/node2/add_memory
+	...
+
+Add a memory section(128M) to node 3(boots with mem=1024m)
+
+	echo 0x40000000 > mem_hotplug/node3/add_memory
+
+Once the new memory section has been added, it is possible to online the memory
+by toggling the "state" described in section 5.1.
 
 ------------------------------
 5. Logical Memory hot-add phase

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
