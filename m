Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6F8A56B009B
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 05:45:28 -0500 (EST)
Message-Id: <20101129091935.806925633@intel.com>
References: <20101129091750.950277284@intel.com>
Date: Mon, 29 Nov 2010 17:17:53 +0800
From: shaohui.zheng@intel.com
Subject: [3/8, v5] NUMA Hotplug Emulation: Abstract cpu register functions
Content-Disposition: inline; filename=003-hotplug-emulator-x86-abstract-cpu-register-functions.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Shaohui Zheng <shaohui.zheng@intel.com>
List-ID: <linux-mm.kvack.org>

From: Shaohui Zheng <shaohui.zheng@intel.com>

Abstract cpu register functions, provide a more flexible interface
register_cpu_node, the new interface provides convenience to add cpu
to a specified node, we can use it to add a cpu to a fake node.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
Index: linux-hpe4/arch/x86/include/asm/cpu.h
===================================================================
--- linux-hpe4.orig/arch/x86/include/asm/cpu.h	2010-11-17 09:00:59.742608402 +0800
+++ linux-hpe4/arch/x86/include/asm/cpu.h	2010-11-17 09:01:10.192838977 +0800
@@ -27,6 +27,7 @@
 
 #ifdef CONFIG_HOTPLUG_CPU
 extern int arch_register_cpu(int num);
+extern int arch_register_cpu_node(int num, int nid);
 extern void arch_unregister_cpu(int);
 #endif
 
Index: linux-hpe4/arch/x86/kernel/topology.c
===================================================================
--- linux-hpe4.orig/arch/x86/kernel/topology.c	2010-11-17 09:01:01.053461766 +0800
+++ linux-hpe4/arch/x86/kernel/topology.c	2010-11-17 10:05:32.934085248 +0800
@@ -52,6 +52,15 @@
 }
 EXPORT_SYMBOL(arch_register_cpu);
 
+int __ref arch_register_cpu_node(int num, int nid)
+{
+	if (num)
+		per_cpu(cpu_devices, num).cpu.hotpluggable = 1;
+
+	return register_cpu_node(&per_cpu(cpu_devices, num).cpu, num, nid);
+}
+EXPORT_SYMBOL(arch_register_cpu_node);
+
 void arch_unregister_cpu(int num)
 {
 	unregister_cpu(&per_cpu(cpu_devices, num).cpu);
Index: linux-hpe4/drivers/base/cpu.c
===================================================================
--- linux-hpe4.orig/drivers/base/cpu.c	2010-11-17 09:01:01.053461766 +0800
+++ linux-hpe4/drivers/base/cpu.c	2010-11-17 10:05:32.943465010 +0800
@@ -208,17 +208,18 @@
 static SYSDEV_CLASS_ATTR(offline, 0444, print_cpus_offline, NULL);
 
 /*
- * register_cpu - Setup a sysfs device for a CPU.
+ * register_cpu_node - Setup a sysfs device for a CPU.
  * @cpu - cpu->hotpluggable field set to 1 will generate a control file in
  *	  sysfs for this CPU.
  * @num - CPU number to use when creating the device.
+ * @nid - Node ID to use, if any.
  *
  * Initialize and register the CPU device.
  */
-int __cpuinit register_cpu(struct cpu *cpu, int num)
+int __cpuinit register_cpu_node(struct cpu *cpu, int num, int nid)
 {
 	int error;
-	cpu->node_id = cpu_to_node(num);
+	cpu->node_id = nid;
 	cpu->sysdev.id = num;
 	cpu->sysdev.cls = &cpu_sysdev_class;
 
@@ -229,7 +230,7 @@
 	if (!error)
 		per_cpu(cpu_sys_devices, num) = &cpu->sysdev;
 	if (!error)
-		register_cpu_under_node(num, cpu_to_node(num));
+		register_cpu_under_node(num, nid);
 
 #ifdef CONFIG_KEXEC
 	if (!error)
Index: linux-hpe4/include/linux/cpu.h
===================================================================
--- linux-hpe4.orig/include/linux/cpu.h	2010-11-17 09:00:59.772898926 +0800
+++ linux-hpe4/include/linux/cpu.h	2010-11-17 10:05:32.954085309 +0800
@@ -30,7 +30,13 @@
 	struct sys_device sysdev;
 };
 
-extern int register_cpu(struct cpu *cpu, int num);
+extern int register_cpu_node(struct cpu *cpu, int num, int nid);
+
+static inline int register_cpu(struct cpu *cpu, int num)
+{
+	return register_cpu_node(cpu, num, cpu_to_node(num));
+}
+
 extern struct sys_device *get_cpu_sysdev(unsigned cpu);
 
 extern int cpu_add_sysdev_attr(struct sysdev_attribute *attr);

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
