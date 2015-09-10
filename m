Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id AD65D6B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 00:38:09 -0400 (EDT)
Received: by iofb144 with SMTP id b144so47572869iof.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 21:38:09 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id da4si16245755pad.91.2015.09.09.21.29.59
        for <linux-mm@kvack.org>;
        Wed, 09 Sep 2015 21:38:09 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 6/7] x86, acpi, cpu-hotplug: Enable MADT APIs to return disabled apicid.
Date: Thu, 10 Sep 2015 12:27:48 +0800
Message-ID: <1441859269-25831-7-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com
Cc: tangchen@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

From: Gu Zheng <guz.fnst@cn.fujitsu.com>

This patch finishes step3 mentioned in previous patch 4.

There are four mappings in the kernel:
1. nodeid (logical node id)   <->   pxm
2. apicid (physical cpu id)   <->   nodeid
3. cpuid (logical cpu id)     <->   apicid
4. cpuid (logical cpu id)     <->   nodeid

1. pxm (proximity domain) is provided by ACPI firmware in SRAT, and nodeid <-> pxm
   mapping is setup at boot time. This mapping is persistent, won't change.

2. apicid <-> nodeid mapping is setup using info in 1. The mapping is setup at boot
   time and CPU hotadd time, and cleared at CPU hotremove time. This mapping is also
   persistent.

3. cpuid <-> apicid mapping is setup at boot time and CPU hotadd time. cpuid is
   allocated, lower ids first, and released at CPU hotremove time, reused for other
   hotadded CPUs. So this mapping is not persistent.

4. cpuid <-> nodeid mapping is also setup at boot time and CPU hotadd time, and
   cleared at CPU hotremove time. As a result of 3, this mapping is not persistent.

So, in order to setup persistent cpuid <-> nodeid mapping for all possible CPUs,
we should:
1. Setup cpuid <-> apicid mapping for all possible CPUs, which has been done in patch 4.
2. Setup cpuid <-> nodeid mapping for all possible CPUs. But before that, we should
   obtain all apicids from MADT.

All processors' apicids can be obtained by _MAT method or from MADT in ACPI.
The current code ignores disabled processors and returns -ENODEV.

After this patch, a new parameter will be added to MADT APIs so that caller
is able to control if disabled processors are ignored.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 drivers/acpi/acpi_processor.c |  5 +++-
 drivers/acpi/processor_core.c | 57 +++++++++++++++++++++++++++----------------
 2 files changed, 40 insertions(+), 22 deletions(-)

diff --git a/drivers/acpi/acpi_processor.c b/drivers/acpi/acpi_processor.c
index 92a5f73..2deade1 100644
--- a/drivers/acpi/acpi_processor.c
+++ b/drivers/acpi/acpi_processor.c
@@ -282,8 +282,11 @@ static int acpi_processor_get_info(struct acpi_device *device)
 	 *  Extra Processor objects may be enumerated on MP systems with
 	 *  less than the max # of CPUs. They should be ignored _iff
 	 *  they are physically not present.
+	 *
+	 *  NOTE: Even if the processor has a cpuid, it may be not present
+	 *  because cpuid <-> apicid mapping is persistent.
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
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
