Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 930296B021F
	for <linux-mm@kvack.org>; Thu, 13 May 2010 08:19:20 -0400 (EDT)
Date: Thu, 13 May 2010 20:14:57 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: [RFC,5/7] NUMA hotplug emulator
Message-ID: <20100513121457.GJ2169@shaohui>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="1EKig6ypoSyM7jaD"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, ak@linux.intel.com, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>


--1EKig6ypoSyM7jaD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

hotplug emulator: support cpu probe/release in x86

Add cpu interface probe/release under sysfs for x86. User can use this
interface to emulate the cpu hot-add process, it is for cpu hotplug 
test purpose. Add a kernel option CONFIG_ARCH_CPU_PROBE_RELEASE for this
feature.

This interface provides a mechanism to emulate cpu hotplug with software
 methods, it becomes possible to do cpu hotplug automation and stress
testing.

Directive:
*) Reserve CPU throu grub parameter like:
	maxcpus=4

the rest CPUs will not be initiliazed. 

*) Probe CPU
we can use the probe interface to hot-add new CPUs:
	echo nid > /sys/devices/system/cpu/probe

*) Release a CPU
	echo cpu > /sys/devices/system/cpu/release

A reserved CPU will be hot-added to the specified node.
1) nid == 0, the CPU will be added to the real node which the CPU
should be in
2) nid != 0, add the CPU to node nid even through it is a fake node.

Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
---
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2c078c8..54ccb0d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1228,6 +1228,17 @@ config NODE_HOTPLUG_EMU
 	  N is the number of hidden nodes, size is the memory size per
 	  hidden node. This is only useful for debugging.
 
+config ARCH_CPU_PROBE_RELEASE
+	def_bool y
+	bool "CPU hotplug emulation"
+	depends on NUMA_HOTPLUG_EMU
+	---help---
+	  Enable cpu hotplug emulation. Reserve cpu with grub parameter
+	  "maxcpus=N", where N is the initial CPU number, the rest physical
+	  CPUs will not be initialized; there is a probe/release interface
+	  is for cpu hot-add/hot-remove to specified node in software method.
+	  This is for debuging and testing purpose
+
 config NODES_SHIFT
 	int "Maximum NUMA Nodes (as a power of 2)" if !MAXSMP
 	range 1 10
@@ -1651,6 +1662,9 @@ config HOTPLUG_CPU
 	  ( Note: power management support will enable this option
 	    automatically on SMP systems. )
 	  Say N if you want to disable CPU hotplug.
+config ARCH_CPU_PROBE_RELEASE
+	def_bool y
+	depends on HOTPLUG_CPU
 
 config COMPAT_VDSO
 	def_bool y
diff --git a/arch/x86/include/asm/cpu.h b/arch/x86/include/asm/cpu.h
index b185091..339ac2d 100644
--- a/arch/x86/include/asm/cpu.h
+++ b/arch/x86/include/asm/cpu.h
@@ -28,6 +28,9 @@ struct x86_cpu {
 #ifdef CONFIG_HOTPLUG_CPU
 extern int arch_register_cpu(int num);
 extern void arch_unregister_cpu(int);
+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+extern int arch_register_cpu_emu(int num, int nid);
+#endif
 #endif
 
 DECLARE_PER_CPU(int, cpu_state);
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index cd40aba..c3c7878 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -592,8 +592,44 @@ int __ref acpi_map_lsapic(acpi_handle handle, int *pcpu)
 }
 EXPORT_SYMBOL(acpi_map_lsapic);
 
+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+static void acpi_map_cpu2node_emu(int cpu, int physid, int nid)
+{
+#ifdef CONFIG_ACPI_NUMA
+#ifdef CONFIG_X86_64
+	apicid_to_node[physid] = nid;
+	numa_set_node(cpu, nid);
+#else /* CONFIG_X86_32 */
+	apicid_2_node[physid] = nid;
+	cpu_to_node_map[cpu] = nid;
+#endif
+#endif
+}
+
+static u16 cpu_to_apicid_saved[CONFIG_NR_CPUS];
+int __ref acpi_map_lsapic_emu(int pcpu, int nid)
+{
+	/* backup cpu apicid to array cpu_to_apicid_saved */
+	if (cpu_to_apicid_saved[pcpu] == 0 &&
+		per_cpu(x86_cpu_to_apicid, pcpu) != BAD_APICID)
+		cpu_to_apicid_saved[pcpu] = per_cpu(x86_cpu_to_apicid, pcpu);
+
+	per_cpu(x86_cpu_to_apicid, pcpu) = cpu_to_apicid_saved[pcpu];
+	acpi_map_cpu2node_emu(pcpu, per_cpu(x86_cpu_to_apicid, pcpu), nid);
+
+	return pcpu;
+}
+EXPORT_SYMBOL(acpi_map_lsapic_emu);
+#endif
+
 int acpi_unmap_lsapic(int cpu)
 {
+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+	/* backup cpu apicid to array cpu_to_apicid_saved */
+	if (cpu_to_apicid_saved[cpu] == 0 &&
+		per_cpu(x86_cpu_to_apicid, cpu) != BAD_APICID)
+		cpu_to_apicid_saved[cpu] = per_cpu(x86_cpu_to_apicid, cpu);
+#endif
 	per_cpu(x86_cpu_to_apicid, cpu) = -1;
 	set_cpu_present(cpu, false);
 	num_processors--;
diff --git a/arch/x86/kernel/topology.c b/arch/x86/kernel/topology.c
index f716cd9..3a7b788 100644
--- a/arch/x86/kernel/topology.c
+++ b/arch/x86/kernel/topology.c
@@ -29,6 +29,9 @@
 #include <linux/mmzone.h>
 #include <linux/init.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
+#include <linux/topology.h>
+#include <linux/acpi.h>
 #include <asm/cpu.h>
 
 static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
@@ -37,6 +40,11 @@ static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
 /*
  * Add nid(NUMA node id) as parameter for cpu hotplug emulation. It supports
  * to register a CPU to any nodes.
+ *
+ * nid is a special parameter, it has 2 different branches:
+ * 1) when nid == NUMA_NO_NODE, the CPU will be registered into the normal node
+ * which it should be in.
+ * 2) nid != NUMA_NO_NODE, it will be registered into the specified node.
  */
 static int __ref __arch_register_cpu(int num, int nid)
 {
@@ -52,9 +60,24 @@ static int __ref __arch_register_cpu(int num, int nid)
 	if (num)
 		per_cpu(cpu_devices, num).cpu.hotpluggable = 1;
 
-	return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
+	if (nid == NUMA_NO_NODE)
+		return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
+	else
+		return register_cpu_emu(&per_cpu(cpu_devices, num).cpu, num, nid);
 }
 
+/*
+ * Emulated version of function arch_register_cpu
+ * Parameter:
+ *	  num: cpu_id
+ *	  nid: emulated numa id
+ */
+int __ref arch_register_cpu_emu(int num, int nid)
+{
+	return __arch_register_cpu(num, nid);
+}
+EXPORT_SYMBOL(arch_register_cpu_emu);
+
 int __ref arch_register_cpu(int num)
 {
 	return __arch_register_cpu(num, NUMA_NO_NODE);
@@ -66,6 +89,84 @@ void arch_unregister_cpu(int num)
 	unregister_cpu(&per_cpu(cpu_devices, num).cpu);
 }
 EXPORT_SYMBOL(arch_unregister_cpu);
+
+ssize_t arch_cpu_probe(const char *buf, size_t count)
+{
+	int nid = 0;
+	int num = 0, selected = 0;
+
+	/* check parameters */
+	if (!buf || count < 2)
+		return -EPERM;
+
+	nid = simple_strtoul(buf, NULL, 0);
+	printk(KERN_DEBUG "Add a cpu to node : %d\n", nid);
+
+	if (nid < 0 || nid > nr_node_ids - 1) {
+		printk(KERN_ERR "Invalid NUMA node id: %d (0 <= nid < %d).\n",
+			nid, nr_node_ids);
+		return -EPERM;
+	}
+
+	if (!node_online(nid)) {
+		printk(KERN_ERR "NUMA node %d is not online, give up.\n", nid);
+		return -EPERM;
+	}
+
+	/* find first uninitialized cpu */
+	for_each_present_cpu(num) {
+		if (per_cpu(cpu_sys_devices, num) == NULL) {
+			selected = num;
+			break;
+		}
+	}
+
+	if (selected >= num_possible_cpus()) {
+		printk(KERN_ERR "No free cpu, give up cpu probing.\n");
+		return -EPERM;
+	}
+
+	/* register cpu */
+	arch_register_cpu_emu(selected, nid);
+	acpi_map_lsapic_emu(selected, nid);
+
+	return count;
+}
+EXPORT_SYMBOL(arch_cpu_probe);
+
+ssize_t arch_cpu_release(const char *buf, size_t count)
+{
+	int cpu = 0;
+
+	cpu =  simple_strtoul(buf, NULL, 0);
+	/* cpu 0 is not hotplugable */
+	if (cpu == 0) {
+		printk(KERN_ERR "can not release cpu 0.\n");
+		return -EPERM;
+	}
+
+	if (cpu_online(cpu)) {
+		printk(KERN_DEBUG "offline cpu %d.\n", cpu);
+		cpu_down(cpu);
+	}
+
+	arch_unregister_cpu(cpu);
+	acpi_unmap_lsapic(cpu);
+
+	return count;
+}
+EXPORT_SYMBOL(arch_cpu_release);
+
+void cpu_hotplug_driver_unlock(void)
+{
+}
+EXPORT_SYMBOL(cpu_hotplug_driver_unlock);
+
+void cpu_hotplug_driver_lock(void)
+{
+}
+EXPORT_SYMBOL(cpu_hotplug_driver_lock);
+
 #else /* CONFIG_HOTPLUG_CPU */
 
 static int __init arch_register_cpu(int num)
@@ -83,8 +184,14 @@ static int __init topology_init(void)
 		register_one_node(i);
 #endif
 
-	for_each_present_cpu(i)
-		arch_register_cpu(i);
+	/*
+	 * when cpu hotplug emulation enabled, register the online cpu only,
+	 * the rests are reserved for cpu probe.
+	 */
+	for_each_present_cpu(i) {
+		if ((cpu_hpe_on && cpu_online(i)) || !cpu_hpe_on)
+			arch_register_cpu(i);
+	}
 
 	return 0;
 }
diff --git a/arch/x86/mm/numa_64.c b/arch/x86/mm/numa_64.c
index 7c61208..3430ff2 100644
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -12,6 +12,7 @@
 #include <linux/module.h>
 #include <linux/nodemask.h>
 #include <linux/sched.h>
+#include <linux/cpu.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -889,6 +890,19 @@ void __init init_cpu_to_node(void)
 }
 #endif
 
+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+static __init int cpu_hpe_setup(char *opt)
+{
+	if (!opt)
+		return -EINVAL;
+
+	if (!strncmp(opt, "on", 2) || !strncmp(opt, "1", 1))
+		cpu_hpe_on = 1;
+
+	return 0;
+}
+early_param("cpu_hpe", cpu_hpe_setup);
+#endif  /* CONFIG_ARCH_CPU_PROBE_RELEASE */
 
 void __cpuinit numa_set_node(int cpu, int node)
 {
diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
index 5675d97..e024143 100644
--- a/drivers/acpi/processor_driver.c
+++ b/drivers/acpi/processor_driver.c
@@ -604,6 +604,14 @@ static int __cpuinit acpi_processor_add(struct acpi_device *device)
 		goto err_free_cpumask;
 
 	sysdev = get_cpu_sysdev(pr->id);
+	/*
+	 * Reserve cpu for hotplug emulation, the reserved cpu can be hot-added
+	 * throu the cpu probe interface. Return directly.
+	 */
+	if (sysdev == NULL) {
+		goto out;
+	}
+
 	if (sysfs_create_link(&device->dev.kobj, &sysdev->kobj, "sysdev")) {
 		result = -EFAULT;
 		goto err_remove_fs;
@@ -643,6 +651,7 @@ static int __cpuinit acpi_processor_add(struct acpi_device *device)
 		goto err_remove_sysfs;
 	}
 
+out:
 	return 0;
 
 err_remove_sysfs:
diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index a1bc9c6..3225b32 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -22,9 +22,15 @@ struct sysdev_class cpu_sysdev_class = {
 };
 EXPORT_SYMBOL(cpu_sysdev_class);
 
-static DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
+DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
 
 #ifdef CONFIG_HOTPLUG_CPU
+/*
+ * cpu_hpe_on is a switch to enable/disable cpu hotplug emulation. it is
+ * disabled in default, we can enable it throu grub parameter cpu_hpe=on
+ */
+int cpu_hpe_on;
+
 static ssize_t show_online(struct sys_device *dev, struct sysdev_attribute *attr,
 			   char *buf)
 {
@@ -80,6 +86,7 @@ void unregister_cpu(struct cpu *cpu)
 }
 
 #ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+
 static ssize_t cpu_probe_store(struct sysdev_class *class,
 			       struct sysdev_class_attribute *attr,
 			       const char *buf,
@@ -250,6 +257,18 @@ int __cpuinit register_cpu(struct cpu *cpu, int num)
 	return __register_cpu(cpu, num, cpu_to_node(num));
 }
 
+/*
+ * Register cpu to the specified NUMA node
+ *
+ * emulated version of function register_cpu, but is more flexible. it supports
+ * an extra parameter nid, We can register a CPU to any specified node throu
+ * this function.
+ */
+int __cpuinit register_cpu_emu(struct cpu *cpu, int num, int nid)
+{
+	return __register_cpu(cpu, num, nid);
+}
+
 struct sys_device *get_cpu_sysdev(unsigned cpu)
 {
 	if (cpu < nr_cpu_ids && cpu_possible(cpu))
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index b926afe..c3bc5c7 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -102,6 +102,7 @@ void acpi_numa_arch_fixup(void);
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 /* Arch dependent functions for cpu hotplug support */
 int acpi_map_lsapic(acpi_handle handle, int *pcpu);
+int acpi_map_lsapic_emu(int pcpu, int nid);
 int acpi_unmap_lsapic(int cpu);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index e287863..2d4df89 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -30,7 +30,10 @@ struct cpu {
 	struct sys_device sysdev;
 };
 
+DECLARE_PER_CPU(struct sys_device *, cpu_sys_devices);
+
 extern int register_cpu(struct cpu *cpu, int num);
+extern int register_cpu_emu(struct cpu *cpu, int num, int nid);
 extern struct sys_device *get_cpu_sysdev(unsigned cpu);
 
 extern int cpu_add_sysdev_attr(struct sysdev_attribute *attr);
@@ -116,6 +119,7 @@ extern void put_online_cpus(void);
 #define register_hotcpu_notifier(nb)	register_cpu_notifier(nb)
 #define unregister_hotcpu_notifier(nb)	unregister_cpu_notifier(nb)
 int cpu_down(unsigned int cpu);
+extern int cpu_hpe_on;
 
 #ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
 extern void cpu_hotplug_driver_lock(void);
@@ -138,6 +142,7 @@ static inline void cpu_hotplug_driver_unlock(void)
 /* These aren't inline functions due to a GCC bug. */
 #define register_hotcpu_notifier(nb)	({ (void)(nb); 0; })
 #define unregister_hotcpu_notifier(nb)	({ (void)(nb); })
+static int cpu_hpe_on;
 #endif		/* CONFIG_HOTPLUG_CPU */
 
 #ifdef CONFIG_PM_SLEEP_SMP
-- 
Thanks & Regards,
Shaohui


--1EKig6ypoSyM7jaD
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="005-hotplug-emulator-x86-support-cpu-probe-release-in-x86.patch"

hotplug emulator: support cpu probe/release in x86

Add cpu interface probe/release under sysfs for x86. User can use this
interface to emulate the cpu hot-add process, it is for cpu hotplug 
test purpose. Add a kernel option CONFIG_ARCH_CPU_PROBE_RELEASE for this
feature.

This interface provides a mechanism to emulate cpu hotplug with software
 methods, it becomes possible to do cpu hotplug automation and stress
testing.

Directive:
*) Reserve CPU throu grub parameter like:
	maxcpus=4

the rest CPUs will not be initiliazed. 

*) Probe CPU
we can use the probe interface to hot-add new CPUs:
	echo nid > /sys/devices/system/cpu/probe

*) Release a CPU
	echo cpu > /sys/devices/system/cpu/release

A reserved CPU will be hot-added to the specified node.
1) nid == 0, the CPU will be added to the real node which the CPU
should be in
2) nid != 0, add the CPU to node nid even through it is a fake node.

Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
---
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2c078c8..54ccb0d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1228,6 +1228,17 @@ config NODE_HOTPLUG_EMU
 	  N is the number of hidden nodes, size is the memory size per
 	  hidden node. This is only useful for debugging.
 
+config ARCH_CPU_PROBE_RELEASE
+	def_bool y
+	bool "CPU hotplug emulation"
+	depends on NUMA_HOTPLUG_EMU
+	---help---
+	  Enable cpu hotplug emulation. Reserve cpu with grub parameter
+	  "maxcpus=N", where N is the initial CPU number, the rest physical
+	  CPUs will not be initialized; there is a probe/release interface
+	  is for cpu hot-add/hot-remove to specified node in software method.
+	  This is for debuging and testing purpose
+
 config NODES_SHIFT
 	int "Maximum NUMA Nodes (as a power of 2)" if !MAXSMP
 	range 1 10
@@ -1651,6 +1662,9 @@ config HOTPLUG_CPU
 	  ( Note: power management support will enable this option
 	    automatically on SMP systems. )
 	  Say N if you want to disable CPU hotplug.
+config ARCH_CPU_PROBE_RELEASE
+	def_bool y
+	depends on HOTPLUG_CPU
 
 config COMPAT_VDSO
 	def_bool y
diff --git a/arch/x86/include/asm/cpu.h b/arch/x86/include/asm/cpu.h
index b185091..339ac2d 100644
--- a/arch/x86/include/asm/cpu.h
+++ b/arch/x86/include/asm/cpu.h
@@ -28,6 +28,9 @@ struct x86_cpu {
 #ifdef CONFIG_HOTPLUG_CPU
 extern int arch_register_cpu(int num);
 extern void arch_unregister_cpu(int);
+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+extern int arch_register_cpu_emu(int num, int nid);
+#endif
 #endif
 
 DECLARE_PER_CPU(int, cpu_state);
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index cd40aba..c3c7878 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -592,8 +592,44 @@ int __ref acpi_map_lsapic(acpi_handle handle, int *pcpu)
 }
 EXPORT_SYMBOL(acpi_map_lsapic);
 
+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+static void acpi_map_cpu2node_emu(int cpu, int physid, int nid)
+{
+#ifdef CONFIG_ACPI_NUMA
+#ifdef CONFIG_X86_64
+	apicid_to_node[physid] = nid;
+	numa_set_node(cpu, nid);
+#else /* CONFIG_X86_32 */
+	apicid_2_node[physid] = nid;
+	cpu_to_node_map[cpu] = nid;
+#endif
+#endif
+}
+
+static u16 cpu_to_apicid_saved[CONFIG_NR_CPUS];
+int __ref acpi_map_lsapic_emu(int pcpu, int nid)
+{
+	/* backup cpu apicid to array cpu_to_apicid_saved */
+	if (cpu_to_apicid_saved[pcpu] == 0 &&
+		per_cpu(x86_cpu_to_apicid, pcpu) != BAD_APICID)
+		cpu_to_apicid_saved[pcpu] = per_cpu(x86_cpu_to_apicid, pcpu);
+
+	per_cpu(x86_cpu_to_apicid, pcpu) = cpu_to_apicid_saved[pcpu];
+	acpi_map_cpu2node_emu(pcpu, per_cpu(x86_cpu_to_apicid, pcpu), nid);
+
+	return pcpu;
+}
+EXPORT_SYMBOL(acpi_map_lsapic_emu);
+#endif
+
 int acpi_unmap_lsapic(int cpu)
 {
+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+	/* backup cpu apicid to array cpu_to_apicid_saved */
+	if (cpu_to_apicid_saved[cpu] == 0 &&
+		per_cpu(x86_cpu_to_apicid, cpu) != BAD_APICID)
+		cpu_to_apicid_saved[cpu] = per_cpu(x86_cpu_to_apicid, cpu);
+#endif
 	per_cpu(x86_cpu_to_apicid, cpu) = -1;
 	set_cpu_present(cpu, false);
 	num_processors--;
diff --git a/arch/x86/kernel/topology.c b/arch/x86/kernel/topology.c
index f716cd9..3a7b788 100644
--- a/arch/x86/kernel/topology.c
+++ b/arch/x86/kernel/topology.c
@@ -29,6 +29,9 @@
 #include <linux/mmzone.h>
 #include <linux/init.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
+#include <linux/topology.h>
+#include <linux/acpi.h>
 #include <asm/cpu.h>
 
 static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
@@ -37,6 +40,11 @@ static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
 /*
  * Add nid(NUMA node id) as parameter for cpu hotplug emulation. It supports
  * to register a CPU to any nodes.
+ *
+ * nid is a special parameter, it has 2 different branches:
+ * 1) when nid == NUMA_NO_NODE, the CPU will be registered into the normal node
+ * which it should be in.
+ * 2) nid != NUMA_NO_NODE, it will be registered into the specified node.
  */
 static int __ref __arch_register_cpu(int num, int nid)
 {
@@ -52,9 +60,24 @@ static int __ref __arch_register_cpu(int num, int nid)
 	if (num)
 		per_cpu(cpu_devices, num).cpu.hotpluggable = 1;
 
-	return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
+	if (nid == NUMA_NO_NODE)
+		return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
+	else
+		return register_cpu_emu(&per_cpu(cpu_devices, num).cpu, num, nid);
 }
 
+/*
+ * Emulated version of function arch_register_cpu
+ * Parameter:
+ *	  num: cpu_id
+ *	  nid: emulated numa id
+ */
+int __ref arch_register_cpu_emu(int num, int nid)
+{
+	return __arch_register_cpu(num, nid);
+}
+EXPORT_SYMBOL(arch_register_cpu_emu);
+
 int __ref arch_register_cpu(int num)
 {
 	return __arch_register_cpu(num, NUMA_NO_NODE);
@@ -66,6 +89,84 @@ void arch_unregister_cpu(int num)
 	unregister_cpu(&per_cpu(cpu_devices, num).cpu);
 }
 EXPORT_SYMBOL(arch_unregister_cpu);
+
+ssize_t arch_cpu_probe(const char *buf, size_t count)
+{
+	int nid = 0;
+	int num = 0, selected = 0;
+
+	/* check parameters */
+	if (!buf || count < 2)
+		return -EPERM;
+
+	nid = simple_strtoul(buf, NULL, 0);
+	printk(KERN_DEBUG "Add a cpu to node : %d\n", nid);
+
+	if (nid < 0 || nid > nr_node_ids - 1) {
+		printk(KERN_ERR "Invalid NUMA node id: %d (0 <= nid < %d).\n",
+			nid, nr_node_ids);
+		return -EPERM;
+	}
+
+	if (!node_online(nid)) {
+		printk(KERN_ERR "NUMA node %d is not online, give up.\n", nid);
+		return -EPERM;
+	}
+
+	/* find first uninitialized cpu */
+	for_each_present_cpu(num) {
+		if (per_cpu(cpu_sys_devices, num) == NULL) {
+			selected = num;
+			break;
+		}
+	}
+
+	if (selected >= num_possible_cpus()) {
+		printk(KERN_ERR "No free cpu, give up cpu probing.\n");
+		return -EPERM;
+	}
+
+	/* register cpu */
+	arch_register_cpu_emu(selected, nid);
+	acpi_map_lsapic_emu(selected, nid);
+
+	return count;
+}
+EXPORT_SYMBOL(arch_cpu_probe);
+
+ssize_t arch_cpu_release(const char *buf, size_t count)
+{
+	int cpu = 0;
+
+	cpu =  simple_strtoul(buf, NULL, 0);
+	/* cpu 0 is not hotplugable */
+	if (cpu == 0) {
+		printk(KERN_ERR "can not release cpu 0.\n");
+		return -EPERM;
+	}
+
+	if (cpu_online(cpu)) {
+		printk(KERN_DEBUG "offline cpu %d.\n", cpu);
+		cpu_down(cpu);
+	}
+
+	arch_unregister_cpu(cpu);
+	acpi_unmap_lsapic(cpu);
+
+	return count;
+}
+EXPORT_SYMBOL(arch_cpu_release);
+
+void cpu_hotplug_driver_unlock(void)
+{
+}
+EXPORT_SYMBOL(cpu_hotplug_driver_unlock);
+
+void cpu_hotplug_driver_lock(void)
+{
+}
+EXPORT_SYMBOL(cpu_hotplug_driver_lock);
+
 #else /* CONFIG_HOTPLUG_CPU */
 
 static int __init arch_register_cpu(int num)
@@ -83,8 +184,14 @@ static int __init topology_init(void)
 		register_one_node(i);
 #endif
 
-	for_each_present_cpu(i)
-		arch_register_cpu(i);
+	/*
+	 * when cpu hotplug emulation enabled, register the online cpu only,
+	 * the rests are reserved for cpu probe.
+	 */
+	for_each_present_cpu(i) {
+		if ((cpu_hpe_on && cpu_online(i)) || !cpu_hpe_on)
+			arch_register_cpu(i);
+	}
 
 	return 0;
 }
diff --git a/arch/x86/mm/numa_64.c b/arch/x86/mm/numa_64.c
index 7c61208..3430ff2 100644
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -12,6 +12,7 @@
 #include <linux/module.h>
 #include <linux/nodemask.h>
 #include <linux/sched.h>
+#include <linux/cpu.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -889,6 +890,19 @@ void __init init_cpu_to_node(void)
 }
 #endif
 
+#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+static __init int cpu_hpe_setup(char *opt)
+{
+	if (!opt)
+		return -EINVAL;
+
+	if (!strncmp(opt, "on", 2) || !strncmp(opt, "1", 1))
+		cpu_hpe_on = 1;
+
+	return 0;
+}
+early_param("cpu_hpe", cpu_hpe_setup);
+#endif  /* CONFIG_ARCH_CPU_PROBE_RELEASE */
 
 void __cpuinit numa_set_node(int cpu, int node)
 {
diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
index 5675d97..e024143 100644
--- a/drivers/acpi/processor_driver.c
+++ b/drivers/acpi/processor_driver.c
@@ -604,6 +604,14 @@ static int __cpuinit acpi_processor_add(struct acpi_device *device)
 		goto err_free_cpumask;
 
 	sysdev = get_cpu_sysdev(pr->id);
+	/*
+	 * Reserve cpu for hotplug emulation, the reserved cpu can be hot-added
+	 * throu the cpu probe interface. Return directly.
+	 */
+	if (sysdev == NULL) {
+		goto out;
+	}
+
 	if (sysfs_create_link(&device->dev.kobj, &sysdev->kobj, "sysdev")) {
 		result = -EFAULT;
 		goto err_remove_fs;
@@ -643,6 +651,7 @@ static int __cpuinit acpi_processor_add(struct acpi_device *device)
 		goto err_remove_sysfs;
 	}
 
+out:
 	return 0;
 
 err_remove_sysfs:
diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index a1bc9c6..3225b32 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -22,9 +22,15 @@ struct sysdev_class cpu_sysdev_class = {
 };
 EXPORT_SYMBOL(cpu_sysdev_class);
 
-static DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
+DEFINE_PER_CPU(struct sys_device *, cpu_sys_devices);
 
 #ifdef CONFIG_HOTPLUG_CPU
+/*
+ * cpu_hpe_on is a switch to enable/disable cpu hotplug emulation. it is
+ * disabled in default, we can enable it throu grub parameter cpu_hpe=on
+ */
+int cpu_hpe_on;
+
 static ssize_t show_online(struct sys_device *dev, struct sysdev_attribute *attr,
 			   char *buf)
 {
@@ -80,6 +86,7 @@ void unregister_cpu(struct cpu *cpu)
 }
 
 #ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
+
 static ssize_t cpu_probe_store(struct sysdev_class *class,
 			       struct sysdev_class_attribute *attr,
 			       const char *buf,
@@ -250,6 +257,18 @@ int __cpuinit register_cpu(struct cpu *cpu, int num)
 	return __register_cpu(cpu, num, cpu_to_node(num));
 }
 
+/*
+ * Register cpu to the specified NUMA node
+ *
+ * emulated version of function register_cpu, but is more flexible. it supports
+ * an extra parameter nid, We can register a CPU to any specified node throu
+ * this function.
+ */
+int __cpuinit register_cpu_emu(struct cpu *cpu, int num, int nid)
+{
+	return __register_cpu(cpu, num, nid);
+}
+
 struct sys_device *get_cpu_sysdev(unsigned cpu)
 {
 	if (cpu < nr_cpu_ids && cpu_possible(cpu))
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index b926afe..c3bc5c7 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -102,6 +102,7 @@ void acpi_numa_arch_fixup(void);
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 /* Arch dependent functions for cpu hotplug support */
 int acpi_map_lsapic(acpi_handle handle, int *pcpu);
+int acpi_map_lsapic_emu(int pcpu, int nid);
 int acpi_unmap_lsapic(int cpu);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index e287863..2d4df89 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -30,7 +30,10 @@ struct cpu {
 	struct sys_device sysdev;
 };
 
+DECLARE_PER_CPU(struct sys_device *, cpu_sys_devices);
+
 extern int register_cpu(struct cpu *cpu, int num);
+extern int register_cpu_emu(struct cpu *cpu, int num, int nid);
 extern struct sys_device *get_cpu_sysdev(unsigned cpu);
 
 extern int cpu_add_sysdev_attr(struct sysdev_attribute *attr);
@@ -116,6 +119,7 @@ extern void put_online_cpus(void);
 #define register_hotcpu_notifier(nb)	register_cpu_notifier(nb)
 #define unregister_hotcpu_notifier(nb)	unregister_cpu_notifier(nb)
 int cpu_down(unsigned int cpu);
+extern int cpu_hpe_on;
 
 #ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
 extern void cpu_hotplug_driver_lock(void);
@@ -138,6 +142,7 @@ static inline void cpu_hotplug_driver_unlock(void)
 /* These aren't inline functions due to a GCC bug. */
 #define register_hotcpu_notifier(nb)	({ (void)(nb); 0; })
 #define unregister_hotcpu_notifier(nb)	({ (void)(nb); })
+static int cpu_hpe_on;
 #endif		/* CONFIG_HOTPLUG_CPU */
 
 #ifdef CONFIG_PM_SLEEP_SMP

--1EKig6ypoSyM7jaD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
