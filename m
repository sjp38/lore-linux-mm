Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id BBB496B0070
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 10:25:08 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so2531187dad.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 07:25:08 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part4 9/9] x86: simplify _acpi_map_lsapic() implementation
Date: Sun,  4 Nov 2012 23:24:02 +0800
Message-Id: <1352042642-7306-10-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
References: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

Simplify implementation of function _acpi_map_lsapic().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 arch/x86/include/asm/mpspec.h |    2 +-
 arch/x86/kernel/acpi/boot.c   |   44 +++++++++--------------------------------
 arch/x86/kernel/apic/apic.c   |    8 +++++---
 3 files changed, 15 insertions(+), 39 deletions(-)

diff --git a/arch/x86/include/asm/mpspec.h b/arch/x86/include/asm/mpspec.h
index 3e2f42a..f1d6487 100644
--- a/arch/x86/include/asm/mpspec.h
+++ b/arch/x86/include/asm/mpspec.h
@@ -94,7 +94,7 @@ static inline void early_reserve_e820_mpc_new(void) { }
 #define default_get_smp_config x86_init_uint_noop
 #endif
 
-void __cpuinit generic_processor_info(int apicid, int version);
+int __cpuinit generic_processor_info(int apicid, int version);
 #ifdef CONFIG_ACPI
 extern void mp_register_ioapic(int id, u32 address, u32 gsi_base);
 extern void mp_override_legacy_irq(u8 bus_irq, u8 polarity, u8 trigger,
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 5e76952..f354446 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -195,24 +195,24 @@ static int __init acpi_parse_madt(struct acpi_table_header *table)
 	return 0;
 }
 
-static void __cpuinit acpi_register_lapic(int id, u8 enabled)
+static int __cpuinit acpi_register_lapic(int id, u8 enabled)
 {
 	unsigned int ver = 0;
 
 	if (id >= (MAX_LOCAL_APIC-1)) {
 		printk(KERN_INFO PREFIX "skipped apicid that is too big\n");
-		return;
+		return -1;
 	}
 
 	if (!enabled) {
 		++disabled_cpus;
-		return;
+		return -1;
 	}
 
 	if (boot_cpu_physical_apicid != -1U)
 		ver = apic_version[boot_cpu_physical_apicid];
 
-	generic_processor_info(id, ver);
+	return generic_processor_info(id, ver);
 }
 
 static int __init
@@ -610,44 +610,19 @@ static void __cpuinit acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 
 static int __cpuinit _acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 {
-	cpumask_var_t tmp_map, new_map;
 	int cpu;
-	int retval = -ENOMEM;
 
-	if (!alloc_cpumask_var(&tmp_map, GFP_KERNEL))
-		goto out;
-
-	if (!alloc_cpumask_var(&new_map, GFP_KERNEL))
-		goto free_tmp_map;
-
-	cpumask_copy(tmp_map, cpu_present_mask);
-	acpi_register_lapic(physid, ACPI_MADT_ENABLED);
-
-	/*
-	 * If acpi_register_lapic successfully generates a new logical cpu
-	 * number, then the following will get us exactly what was mapped
-	 */
-	cpumask_andnot(new_map, cpu_present_mask, tmp_map);
-	if (cpumask_empty(new_map)) {
+	cpu = acpi_register_lapic(physid, ACPI_MADT_ENABLED);
+	if (cpu == -1) {
 		printk ("Unable to map lapic to logical cpu number\n");
-		retval = -EINVAL;
-		goto free_new_map;
+		return -EINVAL;
 	}
 
 	acpi_processor_set_pdc(handle);
-
-	cpu = cpumask_first(new_map);
 	acpi_map_cpu2node(handle, cpu, physid);
-
 	*pcpu = cpu;
-	retval = 0;
-
-free_new_map:
-	free_cpumask_var(new_map);
-free_tmp_map:
-	free_cpumask_var(tmp_map);
-out:
-	return retval;
+
+	return 0;
 }
 
 /* wrapper to silence section mismatch warning */
@@ -665,7 +640,6 @@ int acpi_unmap_lsapic(int cpu)
 
 	return (0);
 }
-
 EXPORT_SYMBOL(acpi_unmap_lsapic);
 #endif				/* CONFIG_ACPI_HOTPLUG_CPU */
 
diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
index b17416e..9fdc293 100644
--- a/arch/x86/kernel/apic/apic.c
+++ b/arch/x86/kernel/apic/apic.c
@@ -2030,7 +2030,7 @@ void disconnect_bsp_APIC(int virt_wire_setup)
 	apic_write(APIC_LVT1, value);
 }
 
-void __cpuinit generic_processor_info(int apicid, int version)
+int __cpuinit generic_processor_info(int apicid, int version)
 {
 	int cpu, max = nr_cpu_ids;
 	bool boot_cpu_detected = physid_isset(boot_cpu_physical_apicid,
@@ -2050,7 +2050,7 @@ void __cpuinit generic_processor_info(int apicid, int version)
 			"  Processor %d/0x%x ignored.\n", max, thiscpu, apicid);
 
 		disabled_cpus++;
-		return;
+		return -1;
 	}
 
 	if (num_processors >= nr_cpu_ids) {
@@ -2061,7 +2061,7 @@ void __cpuinit generic_processor_info(int apicid, int version)
 			"  Processor %d/0x%x ignored.\n", max, thiscpu, apicid);
 
 		disabled_cpus++;
-		return;
+		return -1;
 	}
 
 	num_processors++;
@@ -2106,6 +2106,8 @@ void __cpuinit generic_processor_info(int apicid, int version)
 #endif
 	set_cpu_possible(cpu, true);
 	set_cpu_present(cpu, true);
+
+	return cpu;
 }
 
 int hard_smp_processor_id(void)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
