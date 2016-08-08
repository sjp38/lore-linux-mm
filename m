Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FAC0828E4
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 04:38:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so661495663pfx.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 01:38:20 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id uz10si35868127pac.114.2016.08.08.01.38.18
        for <linux-mm@kvack.org>;
        Mon, 08 Aug 2016 01:38:19 -0700 (PDT)
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Subject: [PATCH v11 4/7] x86, acpi, cpu-hotplug: Enable MADT APIs to return disabled apicid.
Date: Mon, 8 Aug 2016 16:37:53 +0800
Message-ID: <1470645476-16605-5-git-send-email-douly.fnst@cn.fujitsu.com>
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

This patch finishes step 3.

There are four mappings in the kernel:
1. nodeid (logical node id)   <->   pxm        (persistent)
2. apicid (physical cpu id)   <->   nodeid     (persistent)
3. cpuid (logical cpu id)     <->   apicid     (not persistent, now persistent by step 2)
4. cpuid (logical cpu id)     <->   nodeid     (not persistent)

So, in order to setup persistent cpuid <-> nodeid mapping for all possible CPUs,
we should:
1. Setup cpuid <-> apicid mapping for all possible CPUs, which has been done in step 1, 2.
2. Setup cpuid <-> nodeid mapping for all possible CPUs. But before that, we should
   obtain all apicids from MADT.

All processors' apicids can be obtained by _MAT method or from MADT in ACPI.
The current code ignores disabled processors and returns -ENODEV.

After this patch, a new parameter will be added to MADT APIs so that caller
is able to control if disabled processors are ignored.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
---
 drivers/acpi/acpi_processor.c |  5 +++-
 drivers/acpi/processor_core.c | 57 +++++++++++++++++++++++++++----------------
 2 files changed, 40 insertions(+), 22 deletions(-)

diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index c7ba948..e85b19a 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -300,8 +300,11 @@ static int acpi_processor_get_info(struct acpi_device *device)
 	 *  Extra Processor objects may be enumerated on MP systems with
 	 *  less than the max # of CPUs. They should be ignored _iff
 	 *  they are physically not present.
+	 *
+	 *  NOTE: Even if the processor has a cpuid, it may not present because
+	 *  cpuid <-> apicid mapping is persistent now.
 	 */
-	if (invalid_logical_cpuid(pr->id)) {
+	if (invalid_logical_cpuid(pr->id) || !cpu_present(pr->id)) {
 		int ret = acpi_processor_hotadd_init(pr);
 		if (ret)
 			return ret;
diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
index 33a38d6..824b98b 100644
--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -32,12 +32,12 @@ static struct acpi_table_madt *get_madt_table(void)
 }
 
 static int map_lapic_id(struct acpi_subtable_header *entry,
-		 u32 acpi_id, phys_cpuid_t *apic_id)
+		 u32 acpi_id, phys_cpuid_t *apic_id, bool ignore_disabled)
 {
 	struct acpi_madt_local_apic *lapic =
 		container_of(entry, struct acpi_madt_local_apic, header);
 
-	if (!(lapic->lapic_flags & ACPI_MADT_ENABLED))
+	if (ignore_disabled && !(lapic->lapic_flags & ACPI_MADT_ENABLED))
 		return -ENODEV;
 
 	if (lapic->processor_id != acpi_id)
@@ -48,12 +48,13 @@ static int map_lapic_id(struct acpi_subtable_header *entry,
 }
 
 static int map_x2apic_id(struct acpi_subtable_header *entry,
-		int device_declaration, u32 acpi_id, phys_cpuid_t *apic_id)
+		int device_declaration, u32 acpi_id, phys_cpuid_t *apic_id,
+		bool ignore_disabled)
 {
 	struct acpi_madt_local_x2apic *apic =
 		container_of(entry, struct acpi_madt_local_x2apic, header);
 
-	if (!(apic->lapic_flags & ACPI_MADT_ENABLED))
+	if (ignore_disabled && !(apic->lapic_flags & ACPI_MADT_ENABLED))
 		return -ENODEV;
 
 	if (device_declaration && (apic->uid == acpi_id)) {
@@ -65,12 +66,13 @@ static int map_x2apic_id(struct acpi_subtable_header *entry,
 }
 
 static int map_lsapic_id(struct acpi_subtable_header *entry,
-		int device_declaration, u32 acpi_id, phys_cpuid_t *apic_id)
+		int device_declaration, u32 acpi_id, phys_cpuid_t *apic_id,
+		bool ignore_disabled)
 {
 	struct acpi_madt_local_sapic *lsapic =
 		container_of(entry, struct acpi_madt_local_sapic, header);
 
-	if (!(lsapic->lapic_flags & ACPI_MADT_ENABLED))
+	if (ignore_disabled && !(lsapic->lapic_flags & ACPI_MADT_ENABLED))
 		return -ENODEV;
 
 	if (device_declaration) {
@@ -87,12 +89,13 @@ static int map_lsapic_id(struct acpi_subtable_header *entry,
  * Retrieve the ARM CPU physical identifier (MPIDR)
  */
 static int map_gicc_mpidr(struct acpi_subtable_header *entry,
-		int device_declaration, u32 acpi_id, phys_cpuid_t *mpidr)
+		int device_declaration, u32 acpi_id, phys_cpuid_t *mpidr,
+		bool ignore_disabled)
 {
 	struct acpi_madt_generic_interrupt *gicc =
 	    container_of(entry, struct acpi_madt_generic_interrupt, header);
 
-	if (!(gicc->flags & ACPI_MADT_ENABLED))
+	if (ignore_disabled && !(gicc->flags & ACPI_MADT_ENABLED))
 		return -ENODEV;
 
 	/* device_declaration means Device object in DSDT, in the
@@ -108,7 +111,7 @@ static int map_gicc_mpidr(struct acpi_subtable_header *entry,
 	return -EINVAL;
 }
 
-static phys_cpuid_t map_madt_entry(int type, u32 acpi_id)
+static phys_cpuid_t map_madt_entry(int type, u32 acpi_id, bool ignore_disabled)
 {
 	unsigned long madt_end, entry;
 	phys_cpuid_t phys_id = PHYS_CPUID_INVALID;	/* CPU hardware ID */
@@ -128,16 +131,20 @@ static phys_cpuid_t map_madt_entry(int type, u32 acpi_id)
 		struct acpi_subtable_header *header =
 			(struct acpi_subtable_header *)entry;
 		if (header->type == ACPI_MADT_TYPE_LOCAL_APIC) {
-			if (!map_lapic_id(header, acpi_id, &phys_id))
+			if (!map_lapic_id(header, acpi_id, &phys_id,
+					  ignore_disabled))
 				break;
 		} else if (header->type == ACPI_MADT_TYPE_LOCAL_X2APIC) {
-			if (!map_x2apic_id(header, type, acpi_id, &phys_id))
+			if (!map_x2apic_id(header, type, acpi_id, &phys_id,
+					   ignore_disabled))
 				break;
 		} else if (header->type == ACPI_MADT_TYPE_LOCAL_SAPIC) {
-			if (!map_lsapic_id(header, type, acpi_id, &phys_id))
+			if (!map_lsapic_id(header, type, acpi_id, &phys_id,
+					   ignore_disabled))
 				break;
 		} else if (header->type == ACPI_MADT_TYPE_GENERIC_INTERRUPT) {
-			if (!map_gicc_mpidr(header, type, acpi_id, &phys_id))
+			if (!map_gicc_mpidr(header, type, acpi_id, &phys_id,
+					    ignore_disabled))
 				break;
 		}
 		entry += header->length;
@@ -145,7 +152,8 @@ static phys_cpuid_t map_madt_entry(int type, u32 acpi_id)
 	return phys_id;
 }
 
-static phys_cpuid_t map_mat_entry(acpi_handle handle, int type, u32 acpi_id)
+static phys_cpuid_t map_mat_entry(acpi_handle handle, int type, u32 acpi_id,
+				  bool ignore_disabled)
 {
 	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
 	union acpi_object *obj;
@@ -166,30 +174,37 @@ static phys_cpuid_t map_mat_entry(acpi_handle handle, int type, u32 acpi_id)
 
 	header = (struct acpi_subtable_header *)obj->buffer.pointer;
 	if (header->type == ACPI_MADT_TYPE_LOCAL_APIC)
-		map_lapic_id(header, acpi_id, &phys_id);
+		map_lapic_id(header, acpi_id, &phys_id, ignore_disabled);
 	else if (header->type == ACPI_MADT_TYPE_LOCAL_SAPIC)
-		map_lsapic_id(header, type, acpi_id, &phys_id);
+		map_lsapic_id(header, type, acpi_id, &phys_id, ignore_disabled);
 	else if (header->type == ACPI_MADT_TYPE_LOCAL_X2APIC)
-		map_x2apic_id(header, type, acpi_id, &phys_id);
+		map_x2apic_id(header, type, acpi_id, &phys_id, ignore_disabled);
 	else if (header->type == ACPI_MADT_TYPE_GENERIC_INTERRUPT)
-		map_gicc_mpidr(header, type, acpi_id, &phys_id);
+		map_gicc_mpidr(header, type, acpi_id, &phys_id,
+			       ignore_disabled);
 
 exit:
 	kfree(buffer.pointer);
 	return phys_id;
 }
 
-phys_cpuid_t acpi_get_phys_id(acpi_handle handle, int type, u32 acpi_id)
+static phys_cpuid_t __acpi_get_phys_id(acpi_handle handle, int type,
+				       u32 acpi_id, bool ignore_disabled)
 {
 	phys_cpuid_t phys_id;
 
-	phys_id = map_mat_entry(handle, type, acpi_id);
+	phys_id = map_mat_entry(handle, type, acpi_id, ignore_disabled);
 	if (invalid_phys_cpuid(phys_id))
-		phys_id = map_madt_entry(type, acpi_id);
+		phys_id = map_madt_entry(type, acpi_id, ignore_disabled);
 
 	return phys_id;
 }
 
+phys_cpuid_t acpi_get_phys_id(acpi_handle handle, int type, u32 acpi_id)
+{
+	return __acpi_get_phys_id(handle, type, acpi_id, true);
+}
+
 int acpi_map_cpuid(phys_cpuid_t phys_id, u32 acpi_id)
 {
 #ifdef CONFIG_SMP
-- 
2.5.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
