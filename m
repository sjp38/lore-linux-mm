Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7FFF98D00A6
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:46:07 -0500 (EST)
Message-Id: <20101117021000.776651300@intel.com>
References: <20101117020759.016741414@intel.com>
Date: Wed, 17 Nov 2010 10:08:04 +0800
From: shaohui.zheng@intel.com
Subject: [5/8,v3] NUMA Hotplug Emulator: support cpu probe/release in x86
Content-Disposition: inline; filename=005-hotplug-emulator-x86-support-cpu-probe-release-in-x86.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Ingo Molnar <mingo@elte.hu>, Len Brown <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@Sun.COM>, Shaohui Zheng <shaohui.zheng@intel.com>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

From: Shaohui Zheng <shaohui.zheng@intel.com>

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

CC: Ingo Molnar <mingo@elte.hu>
CC: Len Brown <len.brown@intel.com>
CC: Yinghai Lu <Yinghai.Lu@Sun.COM>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
---
Index: linux-hpe4/arch/x86/kernel/acpi/boot.c
===================================================================
--- linux-hpe4.orig/arch/x86/kernel/acpi/boot.c	2010-11-17 09:00:59.742608402 +0800
+++ linux-hpe4/arch/x86/kernel/acpi/boot.c	2010-11-17 09:01:10.202837209 +0800
@@ -647,8 +647,44 @@
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
Index: linux-hpe4/arch/x86/kernel/smpboot.c
===================================================================
--- linux-hpe4.orig/arch/x86/kernel/smpboot.c	2010-11-17 09:00:59.753464132 +0800
+++ linux-hpe4/arch/x86/kernel/smpboot.c	2010-11-17 10:05:26.913464702 +0800
@@ -107,8 +107,6 @@
         mutex_unlock(&x86_cpu_hotplug_driver_mutex);
 }
 
-ssize_t arch_cpu_probe(const char *buf, size_t count) { return -1; }
-ssize_t arch_cpu_release(const char *buf, size_t count) { return -1; }
 #else
 static struct task_struct *idle_thread_array[NR_CPUS] __cpuinitdata ;
 #define get_idle_for_cpu(x)      (idle_thread_array[(x)])
Index: linux-hpe4/arch/x86/kernel/topology.c
===================================================================
--- linux-hpe4.orig/arch/x86/kernel/topology.c	2010-11-17 09:01:10.192838977 +0800
+++ linux-hpe4/arch/x86/kernel/topology.c	2010-11-17 10:05:26.924085712 +0800
@@ -30,6 +30,9 @@
 #include <linux/init.h>
 #include <linux/smp.h>
 #include <asm/cpu.h>
+#include <linux/cpu.h>
+#include <linux/topology.h>
+#include <linux/acpi.h>
 
 static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
 
@@ -66,6 +69,74 @@
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
+	arch_register_cpu_node(selected, nid);
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
 #else /* CONFIG_HOTPLUG_CPU */
 
 static int __init arch_register_cpu(int num)
@@ -83,8 +154,14 @@
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
Index: linux-hpe4/arch/x86/mm/numa_64.c
===================================================================
--- linux-hpe4.orig/arch/x86/mm/numa_64.c	2010-11-17 09:01:10.132837502 +0800
+++ linux-hpe4/arch/x86/mm/numa_64.c	2010-11-17 09:01:10.202837209 +0800
@@ -12,6 +12,7 @@
 #include <linux/module.h>
 #include <linux/nodemask.h>
 #include <linux/sched.h>
+#include <linux/cpu.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -915,6 +916,19 @@
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
Index: linux-hpe4/drivers/acpi/processor_driver.c
===================================================================
--- linux-hpe4.orig/drivers/acpi/processor_driver.c	2010-11-17 09:00:59.765335724 +0800
+++ linux-hpe4/drivers/acpi/processor_driver.c	2010-11-17 09:01:10.212839478 +0800
@@ -530,6 +530,14 @@
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
@@ -570,6 +578,7 @@
 		goto err_remove_sysfs;
 	}
 
+out:
 	return 0;
 
 err_remove_sysfs:
Index: linux-hpe4/drivers/base/cpu.c
===================================================================
--- linux-hpe4.orig/drivers/base/cpu.c	2010-11-17 09:01:10.192838977 +0800
+++ linux-hpe4/drivers/base/cpu.c	2010-11-17 09:01:10.212839478 +0800
@@ -22,9 +22,15 @@
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
Index: linux-hpe4/include/linux/acpi.h
===================================================================
--- linux-hpe4.orig/include/linux/acpi.h	2010-11-17 09:00:59.772898926 +0800
+++ linux-hpe4/include/linux/acpi.h	2010-11-17 09:01:10.212839478 +0800
@@ -102,6 +102,7 @@
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 /* Arch dependent functions for cpu hotplug support */
 int acpi_map_lsapic(acpi_handle handle, int *pcpu);
+int acpi_map_lsapic_emu(int pcpu, int nid);
 int acpi_unmap_lsapic(int cpu);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
Index: linux-hpe4/include/linux/cpu.h
===================================================================
--- linux-hpe4.orig/include/linux/cpu.h	2010-11-17 09:01:10.192838977 +0800
+++ linux-hpe4/include/linux/cpu.h	2010-11-17 09:01:10.212839478 +0800
@@ -30,6 +30,8 @@
 	struct sys_device sysdev;
 };
 
+DECLARE_PER_CPU(struct sys_device *, cpu_sys_devices);
+
 extern int register_cpu_node(struct cpu *cpu, int num, int nid);
 
 static inline int register_cpu(struct cpu *cpu, int num)
@@ -149,6 +151,7 @@
 #define register_hotcpu_notifier(nb)	register_cpu_notifier(nb)
 #define unregister_hotcpu_notifier(nb)	unregister_cpu_notifier(nb)
 int cpu_down(unsigned int cpu);
+extern int cpu_hpe_on;
 
 #ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
 extern void cpu_hotplug_driver_lock(void);
@@ -171,6 +174,7 @@
 /* These aren't inline functions due to a GCC bug. */
 #define register_hotcpu_notifier(nb)	({ (void)(nb); 0; })
 #define unregister_hotcpu_notifier(nb)	({ (void)(nb); })
+static int cpu_hpe_on;
 #endif		/* CONFIG_HOTPLUG_CPU */
 
 #ifdef CONFIG_PM_SLEEP_SMP
Index: linux-hpe4/mm/Kconfig
===================================================================
--- linux-hpe4.orig/mm/Kconfig	2010-11-17 09:01:10.192838977 +0800
+++ linux-hpe4/mm/Kconfig	2010-11-17 10:05:20.994710783 +0800
@@ -162,6 +162,17 @@
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
