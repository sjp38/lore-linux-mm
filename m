Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 860EA6B0068
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 10:24:46 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3692039pbb.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 07:24:46 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part4 5/9] CPU: introduce busy flag to temporarily disable CPU online sysfs interface
Date: Sun,  4 Nov 2012 23:23:58 +0800
Message-Id: <1352042642-7306-6-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
References: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

When doing physical processor hotplug, all affected CPUs need to be
handled in atomic and shouldn't be disturbed by online/offline requests
from CPU device's online sysfs interface. So introduce a busy flag
into struct cpu to temporariliy reject requests from online sysfs
interface.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 arch/ia64/include/asm/cpu.h     |    2 +-
 arch/ia64/kernel/topology.c     |   10 ++++++----
 arch/x86/include/asm/cpu.h      |    2 +-
 arch/x86/kernel/topology.c      |   10 ++++++----
 drivers/acpi/processor_driver.c |    3 ++-
 drivers/base/cpu.c              |   22 ++++++++++++++++++++++
 drivers/xen/cpu_hotplug.c       |    2 +-
 include/linux/cpu.h             |    2 ++
 8 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/arch/ia64/include/asm/cpu.h b/arch/ia64/include/asm/cpu.h
index fcca30b..192fa2f 100644
--- a/arch/ia64/include/asm/cpu.h
+++ b/arch/ia64/include/asm/cpu.h
@@ -15,7 +15,7 @@ DECLARE_PER_CPU(struct ia64_cpu, cpu_devices);
 DECLARE_PER_CPU(int, cpu_state);
 
 #ifdef CONFIG_HOTPLUG_CPU
-extern int arch_register_cpu(int num);
+extern int arch_register_cpu(int num, int busy);
 extern void arch_unregister_cpu(int);
 #endif
 
diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index c64460b..11d47a4 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -40,15 +40,17 @@ EXPORT_SYMBOL_GPL(arch_fix_phys_package_id);
 
 
 #ifdef CONFIG_HOTPLUG_CPU
-int __ref arch_register_cpu(int num)
+int __ref arch_register_cpu(int num, int busy)
 {
 #ifdef CONFIG_ACPI
 	/*
 	 * If CPEI can be re-targeted or if this is not
 	 * CPEI target, then it is hotpluggable
 	 */
-	if (can_cpei_retarget() || !is_cpu_cpei_target(num))
+	if (can_cpei_retarget() || !is_cpu_cpei_target(num)) {
 		sysfs_cpus[num].cpu.hotpluggable = 1;
+		sysfs_cpus[num].cpu.busy = busy;
+	}
 	map_cpu_to_node(num, node_cpuid[num].nid);
 #endif
 	return register_cpu(&sysfs_cpus[num].cpu, num);
@@ -64,7 +66,7 @@ void __ref arch_unregister_cpu(int num)
 }
 EXPORT_SYMBOL(arch_unregister_cpu);
 #else
-static int __init arch_register_cpu(int num)
+static int __init arch_register_cpu(int num, int busy)
 {
 	return register_cpu(&sysfs_cpus[num].cpu, num);
 }
@@ -90,7 +92,7 @@ static int __init topology_init(void)
 		panic("kzalloc in topology_init failed - NR_CPUS too big?");
 
 	for_each_present_cpu(i) {
-		if((err = arch_register_cpu(i)))
+		if((err = arch_register_cpu(i, 0)))
 			goto out;
 	}
 out:
diff --git a/arch/x86/include/asm/cpu.h b/arch/x86/include/asm/cpu.h
index 4564c8e..724c777 100644
--- a/arch/x86/include/asm/cpu.h
+++ b/arch/x86/include/asm/cpu.h
@@ -26,7 +26,7 @@ struct x86_cpu {
 };
 
 #ifdef CONFIG_HOTPLUG_CPU
-extern int arch_register_cpu(int num);
+extern int arch_register_cpu(int num, int busy);
 extern void arch_unregister_cpu(int);
 #endif
 
diff --git a/arch/x86/kernel/topology.c b/arch/x86/kernel/topology.c
index 76ee977..c66ef53 100644
--- a/arch/x86/kernel/topology.c
+++ b/arch/x86/kernel/topology.c
@@ -35,7 +35,7 @@
 static DEFINE_PER_CPU(struct x86_cpu, cpu_devices);
 
 #ifdef CONFIG_HOTPLUG_CPU
-int __ref arch_register_cpu(int num)
+int __ref arch_register_cpu(int num, int busy)
 {
 	/*
 	 * CPU0 cannot be offlined due to several
@@ -46,8 +46,10 @@ int __ref arch_register_cpu(int num)
 	 * Also certain PCI quirks require not to enable hotplug control
 	 * for all CPU's.
 	 */
-	if (num)
+	if (num) {
 		per_cpu(cpu_devices, num).cpu.hotpluggable = 1;
+		per_cpu(cpu_devices, num).cpu.busy = busy;
+	}
 
 	return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
 }
@@ -60,7 +62,7 @@ void arch_unregister_cpu(int num)
 EXPORT_SYMBOL(arch_unregister_cpu);
 #else /* CONFIG_HOTPLUG_CPU */
 
-static int __init arch_register_cpu(int num)
+static int __init arch_register_cpu(int num, int busy)
 {
 	return register_cpu(&per_cpu(cpu_devices, num).cpu, num);
 }
@@ -76,7 +78,7 @@ static int __init topology_init(void)
 #endif
 
 	for_each_present_cpu(i)
-		arch_register_cpu(i);
+		arch_register_cpu(i, 0);
 
 	return 0;
 }
diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
index b8c3684..53e364d 100644
--- a/drivers/acpi/processor_driver.c
+++ b/drivers/acpi/processor_driver.c
@@ -702,7 +702,8 @@ static int acpi_processor_pre_configure(struct acpi_device *device,
 		if (result)
 			return result;
 		BUG_ON((pr->id >= nr_cpu_ids) || (pr->id < 0));
-		result = arch_register_cpu(pr->id);
+
+		result = arch_register_cpu(pr->id, 0);
 		if (result) {
 			acpi_unmap_lsapic(pr->id);
 			pr->id = -1;
diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index 6345294..dc6246c 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -42,6 +42,11 @@ static ssize_t __ref store_online(struct device *dev,
 	ssize_t ret;
 
 	cpu_hotplug_driver_lock();
+	if (cpu->busy) {
+		ret = -EBUSY;
+		goto out;
+	}
+
 	switch (buf[0]) {
 	case '0':
 		ret = cpu_down(cpu->dev.id);
@@ -56,6 +61,8 @@ static ssize_t __ref store_online(struct device *dev,
 	default:
 		ret = -EINVAL;
 	}
+
+out:
 	cpu_hotplug_driver_unlock();
 
 	if (ret >= 0)
@@ -308,6 +315,21 @@ bool cpu_is_hotpluggable(unsigned cpu)
 }
 EXPORT_SYMBOL_GPL(cpu_is_hotpluggable);
 
+int cpu_set_busy(unsigned int id, int busy)
+{
+	int old;
+	struct device *device = get_cpu_device(id);
+	struct cpu *cpu = container_of(device, struct cpu, dev);
+
+	cpu_hotplug_driver_lock();
+	old = cpu->busy;
+	cpu->busy = busy;
+	cpu_hotplug_driver_unlock();
+
+	return old;
+}
+EXPORT_SYMBOL_GPL(cpu_set_busy);
+
 #ifdef CONFIG_GENERIC_CPU_DEVICES
 static DEFINE_PER_CPU(struct cpu, cpu_devices);
 #endif
diff --git a/drivers/xen/cpu_hotplug.c b/drivers/xen/cpu_hotplug.c
index 4dcfced..95bde8a 100644
--- a/drivers/xen/cpu_hotplug.c
+++ b/drivers/xen/cpu_hotplug.c
@@ -9,7 +9,7 @@
 static void enable_hotplug_cpu(int cpu)
 {
 	if (!cpu_present(cpu))
-		arch_register_cpu(cpu);
+		arch_register_cpu(cpu, 0);
 
 	set_cpu_present(cpu, true);
 }
diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index ce7a074..557501b 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -23,12 +23,14 @@ struct device;
 struct cpu {
 	int node_id;		/* The node which contains the CPU */
 	int hotpluggable;	/* creates sysfs control file if hotpluggable */
+	int busy;
 	struct device dev;
 };
 
 extern int register_cpu(struct cpu *cpu, int num);
 extern struct device *get_cpu_device(unsigned cpu);
 extern bool cpu_is_hotpluggable(unsigned cpu);
+extern int cpu_set_busy(unsigned int cpu, int busy);
 
 extern int cpu_add_dev_attr(struct device_attribute *attr);
 extern void cpu_remove_dev_attr(struct device_attribute *attr);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
