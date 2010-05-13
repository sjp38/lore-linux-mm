Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3529F6B0215
	for <linux-mm@kvack.org>; Thu, 13 May 2010 07:57:06 -0400 (EDT)
Date: Thu, 13 May 2010 19:52:47 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: [RFC,4/7] NUMA hotplug emulator
Message-ID: <20100513115247.GE2169@shaohui>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="AbQceqfdZEv+FvjW"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, ak@linux.intel.com, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>


--AbQceqfdZEv+FvjW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

hotplug emulator: Abstract cpu register functions

Abstract function arch_register_cpu and register_cpu, move the implementation
details to a sub function with prefix "__". 

each of the sub function has an extra parameter nid, it can be used to register
CPU under a fake NUMA node, it is a reserved interface for cpu hotplug emulation
(CPU PROBE/RELEASE) in x86.

Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
---
diff --git a/arch/x86/kernel/topology.c b/arch/x86/kernel/topology.c
index 7e45159..f716cd9 100644
--- a/arch/x86/kernel/topology.c
+++ b/arch/x86/kernel/topology.c
@@ -34,7 +34,11 @@
 static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
 
 #ifdef CONFIG_HOTPLUG_CPU
-int __ref arch_register_cpu(int num)
+/*
+ * Add nid(NUMA node id) as parameter for cpu hotplug emulation. It supports
+ * to register a CPU to any nodes.
+ */
+static int __ref __arch_register_cpu(int num, int nid)
 {
 	/*
 	 * CPU0 cannot be offlined due to several
@@ -50,6 +54,11 @@ int __ref arch_register_cpu(int num)
 
 	return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
 }
+
+int __ref arch_register_cpu(int num)
+{
+	return __arch_register_cpu(num, NUMA_NO_NODE);
+}
 EXPORT_SYMBOL(arch_register_cpu);
 
 void arch_unregister_cpu(int num)
diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index f35719a..4aca9e3 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -208,17 +208,20 @@ static ssize_t print_cpus_offline(struct sysdev_class *class,
 static SYSDEV_CLASS_ATTR(offline, 0444, print_cpus_offline, NULL);
 
 /*
- * register_cpu - Setup a sysfs device for a CPU.
+ * __register_cpu -Initialize and register the CPU device.
+ *
  * @cpu - cpu->hotpluggable field set to 1 will generate a control file in
  *	  sysfs for this CPU.
  * @num - CPU number to use when creating the device.
+ * @nid - numa node id
  *
- * Initialize and register the CPU device.
+ * We do not calculate nid by funciton cpu_to_node(), and change it as a
+ * parameter, it is an reserved interface for CPU hotplug emulation.
  */
-int __cpuinit register_cpu(struct cpu *cpu, int num)
+static int __cpuinit __register_cpu(struct cpu *cpu, int num, int nid)
 {
 	int error;
-	cpu->node_id = cpu_to_node(num);
+	cpu->node_id = nid;
 	cpu->sysdev.id = num;
 	cpu->sysdev.cls = &cpu_sysdev_class;
 
@@ -229,7 +232,7 @@ int __cpuinit register_cpu(struct cpu *cpu, int num)
 	if (!error)
 		per_cpu(cpu_sys_devices, num) = &cpu->sysdev;
 	if (!error)
-		register_cpu_under_node(num, cpu_to_node(num));
+		register_cpu_under_node(num, nid);
 
 #ifdef CONFIG_KEXEC
 	if (!error)
@@ -238,6 +241,15 @@ int __cpuinit register_cpu(struct cpu *cpu, int num)
 	return error;
 }
 
+/*
+ * register_cpu - Setup a sysfs device for a CPU.
+ * Initialize and register the CPU device.
+ */
+int __cpuinit register_cpu(struct cpu *cpu, int num)
+{
+	return __register_cpu(cpu, num, cpu_to_node(num));
+}
+
 struct sys_device *get_cpu_sysdev(unsigned cpu)
 {
 	if (cpu < nr_cpu_ids && cpu_possible(cpu))
-- 
Thanks & Regards,
Shaohui


--AbQceqfdZEv+FvjW
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="004-hotplug-emulator-x86-abstract-cpu-register-functions.patch"

hotplug emulator: Abstract cpu register functions

Abstract function arch_register_cpu and register_cpu, move the implementation
details to a sub function with prefix "__". 

each of the sub function has an extra parameter nid, it can be used to register
CPU under a fake NUMA node, it is a reserved interface for cpu hotplug emulation
(CPU PROBE/RELEASE) in x86.

Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
---
diff --git a/arch/x86/kernel/topology.c b/arch/x86/kernel/topology.c
index 7e45159..f716cd9 100644
--- a/arch/x86/kernel/topology.c
+++ b/arch/x86/kernel/topology.c
@@ -34,7 +34,11 @@
 static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
 
 #ifdef CONFIG_HOTPLUG_CPU
-int __ref arch_register_cpu(int num)
+/*
+ * Add nid(NUMA node id) as parameter for cpu hotplug emulation. It supports
+ * to register a CPU to any nodes.
+ */
+static int __ref __arch_register_cpu(int num, int nid)
 {
 	/*
 	 * CPU0 cannot be offlined due to several
@@ -50,6 +54,11 @@ int __ref arch_register_cpu(int num)
 
 	return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
 }
+
+int __ref arch_register_cpu(int num)
+{
+	return __arch_register_cpu(num, NUMA_NO_NODE);
+}
 EXPORT_SYMBOL(arch_register_cpu);
 
 void arch_unregister_cpu(int num)
diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index f35719a..4aca9e3 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -208,17 +208,20 @@ static ssize_t print_cpus_offline(struct sysdev_class *class,
 static SYSDEV_CLASS_ATTR(offline, 0444, print_cpus_offline, NULL);
 
 /*
- * register_cpu - Setup a sysfs device for a CPU.
+ * __register_cpu -Initialize and register the CPU device.
+ *
  * @cpu - cpu->hotpluggable field set to 1 will generate a control file in
  *	  sysfs for this CPU.
  * @num - CPU number to use when creating the device.
+ * @nid - numa node id
  *
- * Initialize and register the CPU device.
+ * We do not calculate nid by funciton cpu_to_node(), and change it as a
+ * parameter, it is an reserved interface for CPU hotplug emulation.
  */
-int __cpuinit register_cpu(struct cpu *cpu, int num)
+static int __cpuinit __register_cpu(struct cpu *cpu, int num, int nid)
 {
 	int error;
-	cpu->node_id = cpu_to_node(num);
+	cpu->node_id = nid;
 	cpu->sysdev.id = num;
 	cpu->sysdev.cls = &cpu_sysdev_class;
 
@@ -229,7 +232,7 @@ int __cpuinit register_cpu(struct cpu *cpu, int num)
 	if (!error)
 		per_cpu(cpu_sys_devices, num) = &cpu->sysdev;
 	if (!error)
-		register_cpu_under_node(num, cpu_to_node(num));
+		register_cpu_under_node(num, nid);
 
 #ifdef CONFIG_KEXEC
 	if (!error)
@@ -238,6 +241,15 @@ int __cpuinit register_cpu(struct cpu *cpu, int num)
 	return error;
 }
 
+/*
+ * register_cpu - Setup a sysfs device for a CPU.
+ * Initialize and register the CPU device.
+ */
+int __cpuinit register_cpu(struct cpu *cpu, int num)
+{
+	return __register_cpu(cpu, num, cpu_to_node(num));
+}
+
 struct sys_device *get_cpu_sysdev(unsigned cpu)
 {
 	if (cpu < nr_cpu_ids && cpu_possible(cpu))

--AbQceqfdZEv+FvjW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
