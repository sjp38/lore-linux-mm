Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 64D8D6B0089
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 03:45:13 -0500 (EST)
Message-Id: <20101130071437.461969179@intel.com>
References: <20101130071324.908098411@intel.com>
Date: Tue, 30 Nov 2010 15:13:32 +0800
From: shaohui.zheng@intel.com
Subject: [8/8, v6] NUMA Hotplug Emulator: implement debugfs interface for memory probe
Content-Disposition: inline; filename=008-hotplug-emulator-implement-memory-probe-debugfs-interface.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Shaohui Zheng <shaohui.zheng@intel.com>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

From: Shaohui Zheng <shaohui.zheng@intel.com>

Implement a debugfs inteface /sys/kernel/debug/mem_hotplug/probe for meomory hotplug
emulation.  it accepts the same parameters like
/sys/devices/system/memory/probe.

Document the interface usage to file Documentation/memory-hotplug.txt.

CC: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
--
Index: linux-hpe4/mm/memory_hotplug.c
===================================================================
--- linux-hpe4.orig/mm/memory_hotplug.c	2010-11-30 14:15:23.587622002 +0800
+++ linux-hpe4/mm/memory_hotplug.c	2010-11-30 14:16:45.447622001 +0800
@@ -983,4 +983,35 @@
 }
 
 module_init(node_debug_init);
+
+#ifdef CONFIG_ARCH_MEMORY_PROBE
+
+static ssize_t debug_memory_probe_store(struct file *file, const char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	return parse_memory_probe_store(buf, count);
+}
+
+static const struct file_operations memory_probe_file_ops = {
+	.write		= debug_memory_probe_store,
+	.llseek		= generic_file_llseek,
+};
+
+static int __init memory_debug_init(void)
+{
+	if (!memhp_debug_root)
+		memhp_debug_root = debugfs_create_dir("mem_hotplug", NULL);
+	if (!memhp_debug_root)
+		return -ENOMEM;
+
+	if (!debugfs_create_file("probe", S_IWUSR, memhp_debug_root,
+			NULL, &memory_probe_file_ops))
+		return -ENOMEM;
+
+	return 0;
+}
+
+module_init(memory_debug_init);
+
+#endif /* CONFIG_ARCH_MEMORY_PROBE */
 #endif /* CONFIG_DEBUG_FS */
Index: linux-hpe4/Documentation/memory-hotplug.txt
===================================================================
--- linux-hpe4.orig/Documentation/memory-hotplug.txt	2010-11-30 14:15:23.587622002 +0800
+++ linux-hpe4/Documentation/memory-hotplug.txt	2010-11-30 14:40:27.267622000 +0800
@@ -198,23 +198,41 @@
 In some environments, especially virtualized environment, firmware will not
 notify memory hotplug event to the kernel. For such environment, "probe"
 interface is supported. This interface depends on CONFIG_ARCH_MEMORY_PROBE.
+It can be also used for physical memory hotplug emulation.
 
-Now, CONFIG_ARCH_MEMORY_PROBE is supported only by powerpc but it does not
-contain highly architecture codes. Please add config if you need "probe"
+Now, CONFIG_ARCH_MEMORY_PROBE is supported by powerpc and x86_64, but it does
+not contain highly architecture codes. Please add config if you need "probe"
 interface.
 
-Probe interface is located at
-/sys/devices/system/memory/probe
+We have both sysfs and debugfs interface for memory probe. They are located at
+/sys/devices/system/memory/probe (sysfs) and /sys/kernel/debug/mem_hotplug/probe
+(debugfs), We can try any of them, they accpet the same parameters.
 
 You can tell the physical address of new memory to the kernel by
 
-% echo start_address_of_new_memory > /sys/devices/system/memory/probe
+% echo start_address_of_new_memory > memory/probe
 
 Then, [start_address_of_new_memory, start_address_of_new_memory + section_size)
 memory range is hot-added. In this case, hotplug script is not called (in
 current implementation). You'll have to online memory by yourself.
 Please see "How to online memory" in this text.
 
+The probe interface can accept flexible parameters, for example:
+
+Add a memory section(128M) to node 3(boots with mem=1024m)
+
+	echo 0x40000000,3 > memory/probe
+
+And more we make it friendly, it is possible to add memory to do
+
+	echo 3g > memory/probe
+	echo 1024m,3 > memory/probe
+
+Another format suggested by Dave Hansen:
+
+	echo physical_address=0x40000000 numa_node=3 > memory/probe
+
+You can also use mem_hotplug/probe(debugfs) interface in the above examples.
 
 4.3 Node hotplug emulation
 ------------

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
