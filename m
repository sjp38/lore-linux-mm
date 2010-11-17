Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0AC5B8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:45:39 -0500 (EST)
Message-Id: <20101117021000.638336620@intel.com>
References: <20101117020759.016741414@intel.com>
Date: Wed, 17 Nov 2010 10:08:02 +0800
From: shaohui.zheng@intel.com
Subject: [3/8,v3] NUMA Hotplug Emulator: Userland interface to hotplug-add fake offlined nodes.
Content-Disposition: inline; filename=003-hotplug-emulator-userland-interface-to-add-fake-node.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Dave Hansen <haveblue@us.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Haicheng Li <haicheng.li@intel.com>, Shaohui Zheng <shaohui.zheng@intel.com>
List-ID: <linux-mm.kvack.org>

From: Haicheng Li <haicheng.li@intel.com>

Add a sysfs entry "probe" under /sys/devices/system/node/:

 - to show all fake offlined nodes:
    $ cat /sys/devices/system/node/probe

 - to hotadd a fake offlined node, e.g. nodeid is N:
    $ echo N > /sys/devices/system/node/probe

CC: Dave Hansen <haveblue@us.ibm.com>
CC: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
Index: linux-hpe4/Documentation/ABI/testing/sysfs-devices-node
===================================================================
--- linux-hpe4.orig/Documentation/ABI/testing/sysfs-devices-node	2010-11-15 17:13:02.433461413 +0800
+++ linux-hpe4/Documentation/ABI/testing/sysfs-devices-node	2010-11-15 17:13:07.093461818 +0800
@@ -5,3 +5,11 @@
 		When this file is written to, all memory within that node
 		will be compacted. When it completes, memory will be freed
 		into blocks which have as many contiguous pages as possible
+
+What:		/sys/devices/system/node/probe
+Date:		Jun 2010
+Contact:	Haicheng Li <haicheng.li@intel.com>
+Description:
+		This file lists all the availabe hidden nodes, when we write
+		a nid number to this interface, and the nid is in the available
+		node list, the hidden node becomes visible.
Index: linux-hpe4/drivers/base/node.c
===================================================================
--- linux-hpe4.orig/drivers/base/node.c	2010-11-15 17:13:02.433461413 +0800
+++ linux-hpe4/drivers/base/node.c	2010-11-15 17:13:07.093461818 +0800
@@ -538,6 +538,25 @@
 	unregister_node(&node_devices[nid]);
 }
 
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+static ssize_t store_nodes_probe(struct sysdev_class *class,
+				  struct sysdev_class_attribute *attr,
+				  const char *buf, size_t count)
+{
+	long nid;
+
+	strict_strtol(buf, 0, &nid);
+	if (nid < 0 || nid > nr_node_ids - 1) {
+		printk(KERN_ERR "Invalid NUMA node id: %ld (0 <= nid < %d).\n",
+			nid, nr_node_ids);
+		return -EPERM;
+	}
+	hotadd_hidden_nodes(nid);
+
+	return count;
+}
+#endif
+
 /*
  * node states attributes
  */
@@ -566,26 +585,35 @@
 	return print_nodes_state(na->state, buf);
 }
 
-#define _NODE_ATTR(name, state) \
+#define _NODE_ATTR_RO(name, state) \
 	{ _SYSDEV_CLASS_ATTR(name, 0444, show_node_state, NULL), state }
 
+#define _NODE_ATTR_RW(name, store_func, state) \
+	{ _SYSDEV_CLASS_ATTR(name, 0644, show_node_state, store_func), state }
+
 static struct node_attr node_state_attr[] = {
-	_NODE_ATTR(possible, N_POSSIBLE),
-	_NODE_ATTR(online, N_ONLINE),
-	_NODE_ATTR(has_normal_memory, N_NORMAL_MEMORY),
-	_NODE_ATTR(has_cpu, N_CPU),
+	[N_POSSIBLE] = _NODE_ATTR_RO(possible, N_POSSIBLE),
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+	[N_HIDDEN] = _NODE_ATTR_RW(probe, store_nodes_probe, N_HIDDEN),
+#endif
+	[N_ONLINE] = _NODE_ATTR_RO(online, N_ONLINE),
+	[N_NORMAL_MEMORY] = _NODE_ATTR_RO(has_normal_memory, N_NORMAL_MEMORY),
 #ifdef CONFIG_HIGHMEM
-	_NODE_ATTR(has_high_memory, N_HIGH_MEMORY),
+	[N_HIGH_MEMORY] = _NODE_ATTR_RO(has_high_memory, N_HIGH_MEMORY),
 #endif
+	[N_CPU] = _NODE_ATTR_RO(has_cpu, N_CPU),
 };
 
 static struct sysdev_class_attribute *node_state_attrs[] = {
-	&node_state_attr[0].attr,
-	&node_state_attr[1].attr,
-	&node_state_attr[2].attr,
-	&node_state_attr[3].attr,
+	&node_state_attr[N_POSSIBLE].attr,
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+	&node_state_attr[N_HIDDEN].attr,
+#endif
+	&node_state_attr[N_ONLINE].attr,
+	&node_state_attr[N_NORMAL_MEMORY].attr,
+	&node_state_attr[N_CPU].attr,
 #ifdef CONFIG_HIGHMEM
-	&node_state_attr[4].attr,
+	&node_state_attr[N_HIGH_MEMORY].attr,
 #endif
 	NULL
 };
Index: linux-hpe4/mm/Kconfig
===================================================================
--- linux-hpe4.orig/mm/Kconfig	2010-11-15 17:13:02.443461606 +0800
+++ linux-hpe4/mm/Kconfig	2010-11-15 17:21:05.535335091 +0800
@@ -147,6 +147,21 @@
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
+config NUMA_HOTPLUG_EMU
+	bool "NUMA hotplug emulator"
+	depends on X86_64 && NUMA && MEMORY_HOTPLUG
+
+	---help---
+
+config NODE_HOTPLUG_EMU
+	bool "Node hotplug emulation"
+	depends on NUMA_HOTPLUG_EMU && MEMORY_HOTPLUG
+	---help---
+	  Enable Node hotplug emulation. The machine will be setup with
+	  hidden virtual nodes when booted with "numa=hide=N*size", where
+	  N is the number of hidden nodes, size is the memory size per
+	  hidden node. This is only useful for debugging.
+
 #
 # If we have space for more page flags then we can enable additional
 # optimizations and functionality.

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
