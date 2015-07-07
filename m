Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C92436B025A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 05:30:25 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so36805761pac.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 02:30:25 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id bf7si33731027pdb.153.2015.07.07.02.30.23
        for <linux-mm@kvack.org>;
        Tue, 07 Jul 2015 02:30:24 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 5/5] x86, acpi, cpu-hotplug: Set persistent cpuid <-> nodeid mapping when booting.
Date: Tue, 7 Jul 2015 17:30:25 +0800
Message-ID: <1436261425-29881-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, laijs@cn.fujitsu.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com
Cc: tangchen@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

From: Gu Zheng <guz.fnst@cn.fujitsu.com>

This patch set the persistent cpuid <-> nodeid mapping for all enabled/disabled
processors at boot time via an additional acpi namespace walk for processors.


Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/ia64/kernel/acpi.c       |  2 +-
 arch/x86/kernel/acpi/boot.c   |  2 +-
 drivers/acpi/bus.c            |  3 ++
 drivers/acpi/processor_core.c | 65 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/acpi.h          |  2 ++
 5 files changed, 72 insertions(+), 2 deletions(-)

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
index bcc85b2..b9a1aa1 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -695,7 +695,7 @@ static void __init acpi_set_irq_model_ioapic(void)
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 #include <acpi/processor.h>
 
-static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
+void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
 	int nid;
diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
index 513e7230e..fd03885 100644
--- a/drivers/acpi/bus.c
+++ b/drivers/acpi/bus.c
@@ -700,6 +700,9 @@ static int __init acpi_init(void)
 	acpi_debugfs_init();
 	acpi_sleep_proc_init();
 	acpi_wakeup_device_init();
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
index 1618cdf..fe3bd4b 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -172,6 +172,8 @@ static inline bool invalid_phys_cpuid(phys_cpuid_t phys_id)
 /* Arch dependent functions for cpu hotplug support */
 int acpi_map_cpu(acpi_handle handle, phys_cpuid_t physid, int *pcpu);
 int acpi_unmap_cpu(int cpu);
+void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid);
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
