Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id A01FC6B006C
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 10:24:57 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3692039pbb.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2012 07:24:57 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [ACPIHP PATCH part4 7/9] ACPI/processor: cache parsed APIC ID in processor driver data structure
Date: Sun,  4 Nov 2012 23:24:00 +0800
Message-Id: <1352042642-7306-8-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
References: <1352042642-7306-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J . Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Huang Ying <ying.huang@intel.com>, Bob Moore <robert.moore@intel.com>, Len Brown <lenb@kernel.org>, "Srivatsa S . Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Yijing Wang <wangyijing@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org

Enhance ACPI processor driver to cache parsed APIC ID in processor
driver data structure, and avoid reparsing again in _acpi_map_lsapic().
This change also makes fake CPU hotplug possible because we have no
dependency on _MAT method anymore.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 arch/ia64/kernel/acpi.c         |   38 ++++----------------------------------
 arch/x86/kernel/acpi/boot.c     |   38 +++-----------------------------------
 drivers/acpi/internal.h         |    2 ++
 drivers/acpi/processor_core.c   |   28 +++++++++++++++++++++++-----
 drivers/acpi/processor_driver.c |   11 ++++++++---
 include/acpi/processor.h        |    1 +
 include/linux/acpi.h            |    2 +-
 7 files changed, 42 insertions(+), 78 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 44057885..f0da941 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -880,40 +880,10 @@ __init void prefill_possible_map(void)
 		set_cpu_possible(i, true);
 }
 
-static int __cpuinit _acpi_map_lsapic(acpi_handle handle, int *pcpu)
+static int __cpuinit _acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 {
-	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
-	union acpi_object *obj;
-	struct acpi_madt_local_sapic *lsapic;
 	cpumask_t tmp_map;
-	int cpu, physid;
-
-	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_MAT", NULL, &buffer)))
-		return -EINVAL;
-
-	if (!buffer.length || !buffer.pointer)
-		return -EINVAL;
-
-	obj = buffer.pointer;
-	if (obj->type != ACPI_TYPE_BUFFER)
-	{
-		kfree(buffer.pointer);
-		return -EINVAL;
-	}
-
-	lsapic = (struct acpi_madt_local_sapic *)obj->buffer.pointer;
-
-	if ((lsapic->header.type != ACPI_MADT_TYPE_LOCAL_SAPIC) ||
-	    (!(lsapic->lapic_flags & ACPI_MADT_ENABLED))) {
-		kfree(buffer.pointer);
-		return -EINVAL;
-	}
-
-	physid = ((lsapic->id << 8) | (lsapic->eid));
-
-	kfree(buffer.pointer);
-	buffer.length = ACPI_ALLOCATE_BUFFER;
-	buffer.pointer = NULL;
+	int cpu;
 
 	cpumask_complement(&tmp_map, cpu_present_mask);
 	cpu = cpumask_first(&tmp_map);
@@ -932,9 +902,9 @@ static int __cpuinit _acpi_map_lsapic(acpi_handle handle, int *pcpu)
 }
 
 /* wrapper to silence section mismatch warning */
-int __ref acpi_map_lsapic(acpi_handle handle, int *pcpu)
+int __ref acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 {
-	return _acpi_map_lsapic(handle, pcpu);
+	return _acpi_map_lsapic(handle, physid, pcpu);
 }
 EXPORT_SYMBOL(acpi_map_lsapic);
 
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index e651f7a..5e76952 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -608,44 +608,12 @@ static void __cpuinit acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 #endif
 }
 
-static int __cpuinit _acpi_map_lsapic(acpi_handle handle, int *pcpu)
+static int __cpuinit _acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 {
-	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
-	union acpi_object *obj;
-	struct acpi_madt_local_apic *lapic;
 	cpumask_var_t tmp_map, new_map;
-	u8 physid;
 	int cpu;
 	int retval = -ENOMEM;
 
-	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_MAT", NULL, &buffer)))
-		return -EINVAL;
-
-	if (!buffer.length || !buffer.pointer)
-		return -EINVAL;
-
-	obj = buffer.pointer;
-	if (obj->type != ACPI_TYPE_BUFFER ||
-	    obj->buffer.length < sizeof(*lapic)) {
-		kfree(buffer.pointer);
-		return -EINVAL;
-	}
-
-	lapic = (struct acpi_madt_local_apic *)obj->buffer.pointer;
-
-	if (lapic->header.type != ACPI_MADT_TYPE_LOCAL_APIC ||
-	    !(lapic->lapic_flags & ACPI_MADT_ENABLED)) {
-		kfree(buffer.pointer);
-		return -EINVAL;
-	}
-
-	physid = lapic->id;
-
-	kfree(buffer.pointer);
-	buffer.length = ACPI_ALLOCATE_BUFFER;
-	buffer.pointer = NULL;
-	lapic = NULL;
-
 	if (!alloc_cpumask_var(&tmp_map, GFP_KERNEL))
 		goto out;
 
@@ -683,9 +651,9 @@ out:
 }
 
 /* wrapper to silence section mismatch warning */
-int __ref acpi_map_lsapic(acpi_handle handle, int *pcpu)
+int __ref acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
 {
-	return _acpi_map_lsapic(handle, pcpu);
+	return _acpi_map_lsapic(handle, physid, pcpu);
 }
 EXPORT_SYMBOL(acpi_map_lsapic);
 
diff --git a/drivers/acpi/internal.h b/drivers/acpi/internal.h
index d2c4d83..19d8555 100644
--- a/drivers/acpi/internal.h
+++ b/drivers/acpi/internal.h
@@ -47,6 +47,8 @@ int acpi_bus_init_power(struct acpi_device *device);
 
 int acpi_wakeup_device_init(void);
 void acpi_early_processor_set_pdc(void);
+int acpi_get_apicid(acpi_handle handle, int type, u32 acpi_id);
+int acpi_map_cpuid(int apic_id, u32 acpi_id);
 
 /* --------------------------------------------------------------------------
                                   Embedded Controller
diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
index eff7222..8fd25cc 100644
--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -163,16 +163,24 @@ exit:
 	return apic_id;
 }
 
-int acpi_get_cpuid(acpi_handle handle, int type, u32 acpi_id)
+int acpi_get_apicid(acpi_handle handle, int type, u32 acpi_id)
 {
-#ifdef CONFIG_SMP
-	int i;
-#endif
-	int apic_id = -1;
+	int apic_id;
 
 	apic_id = map_mat_entry(handle, type, acpi_id);
 	if (apic_id == -1)
 		apic_id = map_madt_entry(type, acpi_id);
+
+	return apic_id;
+}
+EXPORT_SYMBOL_GPL(acpi_get_apicid);
+
+int acpi_map_cpuid(int apic_id, u32 acpi_id)
+{
+#ifdef CONFIG_SMP
+	int i;
+#endif
+
 	if (apic_id == -1) {
 		/*
 		 * On UP processor, there is no _MAT or MADT table.
@@ -212,6 +220,16 @@ int acpi_get_cpuid(acpi_handle handle, int type, u32 acpi_id)
 #endif
 	return -1;
 }
+EXPORT_SYMBOL_GPL(acpi_map_cpuid);
+
+int acpi_get_cpuid(acpi_handle handle, int type, u32 acpi_id)
+{
+	int apic_id;
+
+	apic_id = acpi_get_apicid(handle, type, acpi_id);
+
+	return acpi_map_cpuid(apic_id, acpi_id);
+}
 EXPORT_SYMBOL_GPL(acpi_get_cpuid);
 
 static bool __init processor_physically_present(acpi_handle handle)
diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
index 22214fc..9a02210 100644
--- a/drivers/acpi/processor_driver.c
+++ b/drivers/acpi/processor_driver.c
@@ -57,6 +57,7 @@
 #include <acpi/acpi_drivers.h>
 #include <acpi/processor.h>
 #include <acpi/acpi_hotplug.h>
+#include "internal.h"
 
 #define PREFIX "ACPI: "
 
@@ -303,7 +304,8 @@ static int acpi_processor_get_info(struct acpi_device *device)
 		device_declaration = 1;
 		pr->acpi_id = value;
 	}
-	cpu_index = acpi_get_cpuid(pr->handle, device_declaration, pr->acpi_id);
+	pr->apic_id = acpi_get_apicid(pr->handle, device_declaration, pr->acpi_id);
+	cpu_index = acpi_map_cpuid(pr->apic_id, pr->acpi_id);
 
 	/* Handle UP system running SMP kernel, with no LAPIC in MADT */
 	if (!cpu0_initialized && (cpu_index == -1) &&
@@ -689,7 +691,7 @@ static int acpi_processor_get_dev_info(struct acpi_device *device,
 static int acpi_processor_pre_configure(struct acpi_device *device,
 					struct acpihp_cancel_context *ctx)
 {
-	int result;
+	int result = -EINVAL;
 	struct acpi_processor *pr;
 
 	if (!device || !acpi_driver_data(device))
@@ -698,7 +700,10 @@ static int acpi_processor_pre_configure(struct acpi_device *device,
 
 	/* Generate CPUID for hot-added CPUs */
 	if (pr->id == -1) {
-		result = acpi_map_lsapic(device->handle, &pr->id);
+		if (pr->apic_id == -1)
+			return result;
+
+		result = acpi_map_lsapic(device->handle, pr->apic_id, &pr->id);
 		if (result)
 			return result;
 		BUG_ON((pr->id >= nr_cpu_ids) || (pr->id < 0));
diff --git a/include/acpi/processor.h b/include/acpi/processor.h
index 9e1c980..e25cc4e 100644
--- a/include/acpi/processor.h
+++ b/include/acpi/processor.h
@@ -197,6 +197,7 @@ struct acpi_processor_flags {
 struct acpi_processor {
 	acpi_handle handle;
 	u32 acpi_id;
+	int apic_id;
 	u32 id;
 	u32 pblk;
 	int performance_platform_limit;
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 90be989..774ce2b 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -101,7 +101,7 @@ void acpi_numa_arch_fixup(void);
 
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 /* Arch dependent functions for cpu hotplug support */
-int acpi_map_lsapic(acpi_handle handle, int *pcpu);
+int acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu);
 int acpi_unmap_lsapic(int cpu);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
