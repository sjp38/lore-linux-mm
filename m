Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5403F828E4
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 04:38:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so661494989pfx.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 01:38:19 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id uz10si35868127pac.114.2016.08.08.01.38.17
        for <linux-mm@kvack.org>;
        Mon, 08 Aug 2016 01:38:18 -0700 (PDT)
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Subject: [PATCH v11 5/7] x86, acpi, cpu-hotplug: Set persistent cpuid <-> nodeid mapping when booting.
Date: Mon, 8 Aug 2016 16:37:54 +0800
Message-ID: <1470645476-16605-6-git-send-email-douly.fnst@cn.fujitsu.com>
In-Reply-To: <1470645476-16605-1-git-send-email-douly.fnst@cn.fujitsu.com>
References: <1470645476-16605-1-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org
Cc: x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dou Liyang <douly.fnst@cn.fujitsu.com>

From: Gu Zheng <guz.fnst@cn.fujitsu.com>

The whole patch-set aims at making cpuid <-> nodeid mapping persistent. So that,
when node online/offline happens, cache based on cpuid <-> nodeid mapping such as
wq_numa_possible_cpumask will not cause any problem.
It contains 4 steps:
1. Enable apic registeration flow to handle both enabled and disabled cpus.
2. Introduce a new array storing all possible cpuid <-> apicid mapping.
3. Enable _MAT and MADT relative apis to return non-presnet or disabled cpus' apicid.
4. Establish all possible cpuid <-> nodeid mapping.

This patch finishes step 4.

This patch set the persistent cpuid <-> nodeid mapping for all enabled/disabled
processors at boot time via an additional acpi namespace walk for processors.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
---
 arch/ia64/kernel/acpi.c       |  3 +-
 arch/x86/kernel/acpi/boot.c   |  4 ++-
 drivers/acpi/acpi_processor.c |  5 ++++
 drivers/acpi/bus.c            |  1 +
 drivers/acpi/processor_core.c | 67 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/acpi.h          |  3 ++
 6 files changed, 81 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index b1698bc..bb36515 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -796,7 +796,7 @@ int acpi_isa_irq_to_gsi(unsigned isa_irq, u32 *gsi)
  *  ACPI based hotplug CPU support
  */
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
-static int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
+int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
 	/*
@@ -811,6 +811,7 @@ static int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 #endif
 	return 0;
 }
+EXPORT_SYMBOL(acpi_map_cpu2node);
 
 int additional_cpus __initdata = -1;
 
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 1f11463..69ebb10 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -692,7 +692,7 @@ static void __init acpi_set_irq_model_ioapic(void)
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 #include <acpi/processor.h>
 
-static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
+int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
 	int nid;
@@ -703,7 +703,9 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 		numa_set_node(cpu, nid);
 	}
 #endif
+	return 0;
 }
+EXPORT_SYMBOL(acpi_map_cpu2node);
 
 int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu)
 {
diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index e85b19a..0c15828 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -182,6 +182,11 @@ int __weak arch_register_cpu(int cpu)
 
 void __weak arch_unregister_cpu(int cpu) {}
 
+int __weak acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
+{
+	return -ENODEV;
+}
+
 static int acpi_processor_hotadd_init(struct acpi_processor *pr)
 {
 	unsigned long long sta;
diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
index 262ca31..0fe5f54 100644
--- a/drivers/acpi/bus.c
+++ b/drivers/acpi/bus.c
@@ -1124,6 +1124,7 @@ static int __init acpi_init(void)
 	acpi_sleep_proc_init();
 	acpi_wakeup_device_init();
 	acpi_debugger_init();
+	acpi_set_processor_mapping();
 	return 0;
 }
 
diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
index 824b98b..e814cd4 100644
--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -261,6 +261,73 @@ int acpi_get_cpuid(acpi_handle handle, int type, u32 acpi_id)
 }
 EXPORT_SYMBOL_GPL(acpi_get_cpuid);
 
+#ifdef CONFIG_ACPI_HOTPLUG_CPU
+static bool map_processor(acpi_handle handle, phys_cpuid_t *phys_id, int *cpuid)
+{
+	int type;
+	u32 acpi_id;
+	acpi_status status;
+	acpi_object_type acpi_type;
+	unsigned long long tmp;
+	union acpi_object object = { 0 };
+	struct acpi_buffer buffer = { sizeof(union acpi_object), &object };
+
+	status = acpi_get_type(handle, &acpi_type);
+	if (ACPI_FAILURE(status))
+		return false;
+
+	switch (acpi_type) {
+	case ACPI_TYPE_PROCESSOR:
+		status = acpi_evaluate_object(handle, NULL, NULL, &buffer);
+		if (ACPI_FAILURE(status))
+			return false;
+		acpi_id = object.processor.proc_id;
+		break;
+	case ACPI_TYPE_DEVICE:
+		status = acpi_evaluate_integer(handle, "_UID", NULL, &tmp);
+		if (ACPI_FAILURE(status))
+			return false;
+		acpi_id = tmp;
+		break;
+	default:
+		return false;
+	}
+
+	type = (acpi_type == ACPI_TYPE_DEVICE) ? 1 : 0;
+
+	*phys_id = __acpi_get_phys_id(handle, type, acpi_id, false);
+	*cpuid = acpi_map_cpuid(*phys_id, acpi_id);
+	if (*cpuid == -1)
+		return false;
+
+	return true;
+}
+
+static acpi_status __init
+set_processor_node_mapping(acpi_handle handle, u32 lvl, void *context,
+			   void **rv)
+{
+	phys_cpuid_t phys_id;
+	int cpu_id;
+
+	if (!map_processor(handle, &phys_id, &cpu_id))
+		return AE_ERROR;
+
+	acpi_map_cpu2node(handle, cpu_id, phys_id);
+	return AE_OK;
+}
+
+void __init acpi_set_processor_mapping(void)
+{
+	/* Set persistent cpu <-> node mapping for all processors. */
+	acpi_walk_namespace(ACPI_TYPE_PROCESSOR, ACPI_ROOT_OBJECT,
+			    ACPI_UINT32_MAX, set_processor_node_mapping,
+			    NULL, NULL, NULL);
+}
+#else
+void __init acpi_set_processor_mapping(void) {}
+#endif /* CONFIG_ACPI_HOTPLUG_CPU */
+
 #ifdef CONFIG_ACPI_HOTPLUG_IOAPIC
 static int get_ioapic_id(struct acpi_subtable_header *entry, u32 gsi_base,
 			 u64 *phys_addr, int *ioapic_id)
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 288fac5..30df63c 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -258,8 +258,11 @@ static inline bool invalid_phys_cpuid(phys_cpuid_t phys_id)
 /* Arch dependent functions for cpu hotplug support */
 int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu);
 int acpi_unmap_cpu(int cpu);
+int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
+void __init acpi_set_processor_mapping(void);
+
 #ifdef CONFIG_ACPI_HOTPLUG_IOAPIC
 int acpi_get_ioapic_id(acpi_handle handle, u32 gsi_base, u64 *phys_addr);
 #endif
-- 
2.5.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
