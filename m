Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0266D6B0261
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 21:35:40 -0400 (EDT)
Received: by mail-oi0-f47.google.com with SMTP id m82so52568423oif.1
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 18:35:39 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id h139si4196791oic.135.2016.03.16.18.35.36
        for <linux-mm@kvack.org>;
        Wed, 16 Mar 2016 18:35:39 -0700 (PDT)
From: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Subject: [PATCH v6 5/5] x86, acpi, cpu-hotplug: Set persistent cpuid <-> nodeid mapping when booting.
Date: Thu, 17 Mar 2016 09:32:40 +0800
Message-ID: <0ecee1cba429e53220c7887c7a139ad598c5a4a2.1458177577.git.zhugh.fnst@cn.fujitsu.com>
In-Reply-To: <cover.1458177577.git.zhugh.fnst@cn.fujitsu.com>
References: <cover.1458177577.git.zhugh.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn
Cc: x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, zhugh.fnst@cn.fujitsu.com, Gu Zheng <guz.fnst@cn.fujitsu.com>

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
---
 arch/ia64/kernel/acpi.c       |  2 +-
 arch/x86/kernel/acpi/boot.c   |  2 +-
 drivers/acpi/bus.c            |  3 ++
 drivers/acpi/processor_core.c | 65 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/acpi.h          |  6 ++++
 5 files changed, 76 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index b1698bc..7db5563 100644
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
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 0ce06ee..7d45261 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -696,7 +696,7 @@ static void __init acpi_set_irq_model_ioapic(void)
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 #include <acpi/processor.h>
 
-static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
+void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
 	int nid;
diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
index 0e85678..215177a 100644
--- a/drivers/acpi/bus.c
+++ b/drivers/acpi/bus.c
@@ -1110,6 +1110,9 @@ static int __init acpi_init(void)
 	acpi_sleep_proc_init();
 	acpi_wakeup_device_init();
 	acpi_debugger_init();
+#ifdef CONFIG_ACPI_HOTPLUG_CPU
+	acpi_set_processor_mapping();
+#endif
 	return 0;
 }
 
diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
index 824b98b..45580ff 100644
--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -261,6 +261,71 @@ int acpi_get_cpuid(acpi_handle handle, int type, u32 acpi_id)
 }
 EXPORT_SYMBOL_GPL(acpi_get_cpuid);
 
+#ifdef CONFIG_ACPI_HOTPLUG_CPU
+static bool map_processor(acpi_handle handle, int *phys_id, int *cpuid)
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
+	u32 apic_id;
+	int cpu_id;
+
+	if (!map_processor(handle, &apic_id, &cpu_id))
+		return AE_ERROR;
+
+	acpi_map_cpu2node(handle, cpu_id, apic_id);
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
+#endif
+
 #ifdef CONFIG_ACPI_HOTPLUG_IOAPIC
 static int get_ioapic_id(struct acpi_subtable_header *entry, u32 gsi_base,
 			 u64 *phys_addr, int *ioapic_id)
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 06ed7e5..ad9e7c7 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -265,6 +265,12 @@ static inline bool invalid_phys_cpuid(phys_cpuid_t phys_id)
 /* Arch dependent functions for cpu hotplug support */
 int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu);
 int acpi_unmap_cpu(int cpu);
+#if defined(CONFIG_X86)
+void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid);
+#elif defined(CONFIG_IA64)
+int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid);
+#endif
+void __init acpi_set_processor_mapping(void);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
 #ifdef CONFIG_ACPI_HOTPLUG_IOAPIC
-- 
1.9.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
