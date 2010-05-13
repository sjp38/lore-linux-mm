Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B23596B0214
	for <linux-mm@kvack.org>; Thu, 13 May 2010 07:52:54 -0400 (EDT)
Date: Thu, 13 May 2010 19:48:35 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: [RFC, 3/7] NUMA hotplug emulator 
Message-ID: <20100513114835.GD2169@shaohui>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="B4IIlcmfBL/1gGOG"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Greg Kroah-Hartman <gregkh@suse.de>, David Rientjes <rientjes@google.com>, Alex Chiang <achiang@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>


--B4IIlcmfBL/1gGOG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Userland interface to hotplug-add fake offlined nodes.

Add a sysfs entry "probe" under /sys/devices/system/node/:

 - to show all fake offlined nodes:
    $ cat /sys/devices/system/node/probe

 - to hotadd a fake offlined node, e.g. nodeid is N:
    $ echo N > /sys/devices/system/node/probe

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 9458685..2c078c8 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1214,6 +1214,20 @@ config NUMA_EMU
 	  into virtual nodes when booted with "numa=fake=N", where N is the
 	  number of nodes. This is only useful for debugging.
 
+config NUMA_HOTPLUG_EMU
+	bool "NUMA hotplug emulator"
+	depends on X86_64 && NUMA && HOTPLUG
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
 config NODES_SHIFT
 	int "Maximum NUMA Nodes (as a power of 2)" if !MAXSMP
 	range 1 10
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 057979a..a0be257 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -535,6 +535,26 @@ void unregister_one_node(int nid)
 	unregister_node(&node_devices[nid]);
 }
 
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+static ssize_t store_nodes_probe(struct sysdev_class *class,
+				  struct sysdev_class_attribute *attr,
+				  const char *buf, size_t count)
+{
+	long nid;
+	int ret;
+
+	strict_strtol(buf, 0, &nid);
+	if (nid < 0 || nid > nr_node_ids - 1) {
+		printk(KERN_ERR "Invalid NUMA node id: %d (0 <= nid < %d).\n",
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
@@ -563,26 +583,35 @@ static ssize_t show_node_state(struct sysdev_class *class,
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
-- 
Thanks & Regards,
Shaohui


--B4IIlcmfBL/1gGOG
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="003-hotplug-emulator-userland-interface-to-add-fake-node.patch"

Userland interface to hotplug-add fake offlined nodes.

Add a sysfs entry "probe" under /sys/devices/system/node/:

 - to show all fake offlined nodes:
    $ cat /sys/devices/system/node/probe

 - to hotadd a fake offlined node, e.g. nodeid is N:
    $ echo N > /sys/devices/system/node/probe

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 9458685..2c078c8 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1214,6 +1214,20 @@ config NUMA_EMU
 	  into virtual nodes when booted with "numa=fake=N", where N is the
 	  number of nodes. This is only useful for debugging.
 
+config NUMA_HOTPLUG_EMU
+	bool "NUMA hotplug emulator"
+	depends on X86_64 && NUMA && HOTPLUG
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
 config NODES_SHIFT
 	int "Maximum NUMA Nodes (as a power of 2)" if !MAXSMP
 	range 1 10
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 057979a..a0be257 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -535,6 +535,26 @@ void unregister_one_node(int nid)
 	unregister_node(&node_devices[nid]);
 }
 
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+static ssize_t store_nodes_probe(struct sysdev_class *class,
+				  struct sysdev_class_attribute *attr,
+				  const char *buf, size_t count)
+{
+	long nid;
+	int ret;
+
+	strict_strtol(buf, 0, &nid);
+	if (nid < 0 || nid > nr_node_ids - 1) {
+		printk(KERN_ERR "Invalid NUMA node id: %d (0 <= nid < %d).\n",
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
@@ -563,26 +583,35 @@ static ssize_t show_node_state(struct sysdev_class *class,
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

--B4IIlcmfBL/1gGOG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
