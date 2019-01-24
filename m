Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A384D8E0082
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:08:27 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id i124so5045138pgc.2
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:08:27 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id i7si24473410pgc.144.2019.01.24.15.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:08:26 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv5 05/10] acpi/hmat: Register processor domain to its memory
Date: Thu, 24 Jan 2019 16:07:19 -0700
Message-Id: <20190124230724.10022-6-keith.busch@intel.com>
In-Reply-To: <20190124230724.10022-1-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

If the HMAT Subsystem Address Range provides a valid processor proximity
domain for a memory domain, or a processor domain matches the performance
access of the valid processor proximity domain, register the memory
target with that initiator so this relationship will be visible under
the node's sysfs directory.

Since HMAT requires valid address ranges have an equivalent SRAT entry,
verify each memory target satisfies this requirement.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/hmat.c | 310 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 310 insertions(+)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index 1741bf30d87f..85fd835c2e23 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -16,6 +16,91 @@
 #include <linux/node.h>
 #include <linux/sysfs.h>
 
+static __initdata LIST_HEAD(targets);
+static __initdata LIST_HEAD(initiators);
+static __initdata LIST_HEAD(localities);
+
+struct memory_target {
+	struct list_head node;
+	unsigned int memory_pxm;
+	unsigned int processor_pxm;
+	unsigned int read_bandwidth;
+	unsigned int write_bandwidth;
+	unsigned int read_latency;
+	unsigned int write_latency;
+};
+
+struct memory_initiator {
+	struct list_head node;
+	unsigned int processor_pxm;
+};
+
+struct memory_locality {
+	struct list_head node;
+	struct acpi_hmat_locality *hmat_loc;
+};
+
+static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
+{
+	struct memory_initiator *intitator;
+
+	list_for_each_entry(intitator, &initiators, node)
+		if (intitator->processor_pxm == cpu_pxm)
+			return intitator;
+	return NULL;
+}
+
+static __init struct memory_target *find_mem_target(unsigned int mem_pxm)
+{
+	struct memory_target *target;
+
+	list_for_each_entry(target, &targets, node)
+		if (target->memory_pxm == mem_pxm)
+			return target;
+	return NULL;
+}
+
+static __init struct memory_initiator *alloc_memory_initiator(
+							unsigned int cpu_pxm)
+{
+	struct memory_initiator *intitator;
+
+	if (pxm_to_node(cpu_pxm) == NUMA_NO_NODE)
+		return NULL;
+
+	intitator = find_mem_initiator(cpu_pxm);
+	if (intitator)
+		return intitator;
+
+	intitator = kzalloc(sizeof(*intitator), GFP_KERNEL);
+	if (!intitator)
+		return NULL;
+
+	intitator->processor_pxm = cpu_pxm;
+	list_add_tail(&intitator->node, &initiators);
+	return intitator;
+}
+
+static __init void alloc_memory_target(unsigned int mem_pxm)
+{
+	struct memory_target *target;
+
+	if (pxm_to_node(mem_pxm) == NUMA_NO_NODE)
+		return;
+
+	target = find_mem_target(mem_pxm);
+	if (target)
+		return;
+
+	target = kzalloc(sizeof(*target), GFP_KERNEL);
+	if (!target)
+		return;
+
+	target->memory_pxm = mem_pxm;
+	target->processor_pxm = PXM_INVAL;
+	list_add_tail(&target->node, &targets);
+}
+
 static __init const char *hmat_data_type(u8 type)
 {
 	switch (type) {
@@ -52,13 +137,45 @@ static __init const char *hmat_data_type_suffix(u8 type)
 	};
 }
 
+static __init void hmat_update_target_access(struct memory_target *target,
+                                             u8 type, u32 value)
+{
+	switch (type) {
+	case ACPI_HMAT_ACCESS_LATENCY:
+		target->read_latency = value;
+		target->write_latency = value;
+		break;
+	case ACPI_HMAT_READ_LATENCY:
+		target->read_latency = value;
+		break;
+	case ACPI_HMAT_WRITE_LATENCY:
+		target->write_latency = value;
+		break;
+	case ACPI_HMAT_ACCESS_BANDWIDTH:
+		target->read_bandwidth = value;
+		target->write_bandwidth = value;
+		break;
+	case ACPI_HMAT_READ_BANDWIDTH:
+		target->read_bandwidth = value;
+		break;
+	case ACPI_HMAT_WRITE_BANDWIDTH:
+		target->write_bandwidth = value;
+		break;
+	default:
+		break;
+	};
+}
+
 static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 				      const unsigned long end)
 {
 	struct acpi_hmat_locality *hmat_loc = (void *)header;
+	struct memory_target *target;
+	struct memory_initiator *initiator;
 	unsigned int init, targ, total_size, ipds, tpds;
 	u32 *inits, *targs, value;
 	u16 *entries;
+	bool report = false;
 	u8 type;
 
 	if (hmat_loc->header.length < sizeof(*hmat_loc)) {
@@ -82,16 +199,42 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 		hmat_loc->flags, hmat_data_type(type), ipds, tpds,
 		hmat_loc->entry_base_unit);
 
+	/* Don't report performance of memory side caches */
+	switch (hmat_loc->flags & ACPI_HMAT_MEMORY_HIERARCHY) {
+	case ACPI_HMAT_MEMORY:
+	case ACPI_HMAT_LAST_LEVEL_CACHE:
+		report = true;
+		break;
+	default:
+		break;
+	}
+
 	inits = (u32 *)(hmat_loc + 1);
 	targs = &inits[ipds];
 	entries = (u16 *)(&targs[tpds]);
 	for (init = 0; init < ipds; init++) {
+		initiator = alloc_memory_initiator(inits[init]);
 		for (targ = 0; targ < tpds; targ++) {
 			value = entries[init * tpds + targ];
 			value = (value * hmat_loc->entry_base_unit) / 10;
 			pr_info("  Initiator-Target[%d-%d]:%d%s\n",
 				inits[init], targs[targ], value,
 				hmat_data_type_suffix(type));
+
+			target = find_mem_target(targs[targ]);
+			if (target && report &&
+			    target->processor_pxm == initiator->processor_pxm)
+				hmat_update_target_access(target, type, value);
+		}
+	}
+
+	if (report) {
+		struct memory_locality *loc;
+
+		loc = kzalloc(sizeof(*loc), GFP_KERNEL);
+		if (loc) {
+			loc->hmat_loc = hmat_loc;
+			list_add_tail(&loc->node, &localities);
 		}
 	}
 
@@ -122,16 +265,35 @@ static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
 					   const unsigned long end)
 {
 	struct acpi_hmat_address_range *spa = (void *)header;
+	struct memory_target *target = NULL;
 
 	if (spa->header.length != sizeof(*spa)) {
 		pr_debug("HMAT: Unexpected address range header length: %d\n",
 			 spa->header.length);
 		return -EINVAL;
 	}
+
 	pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
 		spa->physical_address_base, spa->physical_address_length,
 		spa->flags, spa->processor_PD, spa->memory_PD);
 
+	if (spa->flags & ACPI_HMAT_MEMORY_PD_VALID) {
+		target = find_mem_target(spa->memory_PD);
+		if (!target) {
+			pr_debug("HMAT: Memory Domain missing from SRAT\n");
+			return -EINVAL;
+		}
+	}
+	if (target && spa->flags & ACPI_HMAT_PROCESSOR_PD_VALID) {
+		int p_node = pxm_to_node(spa->processor_PD);
+
+		if (p_node == NUMA_NO_NODE) {
+			pr_debug("HMAT: Invalid Processor Domain\n");
+			return -EINVAL;
+		}
+		target->processor_pxm = p_node;
+	}
+
 	return 0;
 }
 
@@ -155,6 +317,142 @@ static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
 	}
 }
 
+static __init int srat_parse_mem_affinity(union acpi_subtable_headers *header,
+					  const unsigned long end)
+{
+	struct acpi_srat_mem_affinity *ma = (void *)header;
+
+	if (!ma)
+		return -EINVAL;
+	if (!(ma->flags & ACPI_SRAT_MEM_ENABLED))
+		return 0;
+	alloc_memory_target(ma->proximity_domain);
+	return 0;
+}
+
+static __init bool hmat_is_local(struct memory_target *target,
+                                 u8 type, u32 value)
+{
+	switch (type) {
+	case ACPI_HMAT_ACCESS_LATENCY:
+		return value == target->read_latency &&
+		       value == target->write_latency;
+	case ACPI_HMAT_READ_LATENCY:
+		return value == target->read_latency;
+	case ACPI_HMAT_WRITE_LATENCY:
+		return value == target->write_latency;
+	case ACPI_HMAT_ACCESS_BANDWIDTH:
+		return value == target->read_bandwidth &&
+		       value == target->write_bandwidth;
+	case ACPI_HMAT_READ_BANDWIDTH:
+		return value == target->read_bandwidth;
+	case ACPI_HMAT_WRITE_BANDWIDTH:
+		return value == target->write_bandwidth;
+	default:
+		return true;
+	};
+}
+
+static bool hmat_is_local_initiator(struct memory_target *target,
+				    struct memory_initiator *initiator,
+				    struct acpi_hmat_locality *hmat_loc)
+{
+	unsigned int ipds, tpds, i, idx = 0, tdx = 0;
+	u32 *inits, *targs, value;
+	u16 *entries;
+
+	ipds = hmat_loc->number_of_initiator_Pds;
+	tpds = hmat_loc->number_of_target_Pds;
+	inits = (u32 *)(hmat_loc + 1);
+	targs = &inits[ipds];
+	entries = (u16 *)(&targs[tpds]);
+
+	for (i = 0; i < ipds; i++) {
+		if (inits[i] == initiator->processor_pxm) {
+			idx = i;
+			break;
+		}
+	}
+
+	if (i == ipds)
+		return false;
+
+	for (i = 0; i < tpds; i++) {
+		if (targs[i] == target->memory_pxm) {
+			tdx = i;
+			break;
+		}
+	}
+	if (i == tpds)
+		return false;
+
+	value = entries[idx * tpds + tdx];
+	value = (value * hmat_loc->entry_base_unit) / 10;
+
+	return hmat_is_local(target, hmat_loc->data_type, value);
+}
+
+static __init void hmat_register_if_local(struct memory_target *target,
+					  struct memory_initiator *initiator)
+{
+	unsigned int mem_nid, cpu_nid;
+	struct memory_locality *loc;
+
+	if (initiator->processor_pxm == target->processor_pxm)
+		return;
+
+	list_for_each_entry(loc, &localities, node)
+		if (!hmat_is_local_initiator(target, initiator, loc->hmat_loc))
+			return;
+
+	mem_nid = pxm_to_node(target->memory_pxm);
+	cpu_nid = pxm_to_node(initiator->processor_pxm);
+	register_memory_node_under_compute_node(mem_nid, cpu_nid, 0);
+}
+
+static __init void hmat_register_target_initiators(struct memory_target *target)
+{
+	struct memory_initiator *initiator;
+	unsigned int mem_nid, cpu_nid;
+
+	if (target->processor_pxm == PXM_INVAL)
+		return;
+
+	mem_nid = pxm_to_node(target->memory_pxm);
+	cpu_nid = pxm_to_node(target->processor_pxm);
+	if (register_memory_node_under_compute_node(mem_nid, cpu_nid, 0))
+		return;
+
+	if (list_empty(&localities))
+		return;
+
+	list_for_each_entry(initiator, &initiators, node)
+		hmat_register_if_local(target, initiator);
+}
+
+static __init void hmat_register_targets(void)
+{
+	struct memory_target *target, *tnext;
+	struct memory_locality *loc, *lnext;
+	struct memory_initiator *intitator, *inext;
+
+	list_for_each_entry_safe(target, tnext, &targets, node) {
+		list_del(&target->node);
+		hmat_register_target_initiators(target);
+		kfree(target);
+	}
+
+	list_for_each_entry_safe(intitator, inext, &initiators, node) {
+		list_del(&intitator->node);
+		kfree(intitator);
+	}
+
+	list_for_each_entry_safe(loc, lnext, &localities, node) {
+		list_del(&loc->node);
+		kfree(loc);
+	}
+}
+
 static __init int hmat_init(void)
 {
 	struct acpi_table_header *tbl;
@@ -164,6 +462,17 @@ static __init int hmat_init(void)
 	if (srat_disabled())
 		return 0;
 
+	status = acpi_get_table(ACPI_SIG_SRAT, 0, &tbl);
+	if (ACPI_FAILURE(status))
+		return 0;
+
+	if (acpi_table_parse_entries(ACPI_SIG_SRAT,
+				sizeof(struct acpi_table_srat),
+				ACPI_SRAT_TYPE_MEMORY_AFFINITY,
+				srat_parse_mem_affinity, 0) < 0)
+		goto out_put;
+	acpi_put_table(tbl);
+
 	status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
 	if (ACPI_FAILURE(status))
 		return 0;
@@ -174,6 +483,7 @@ static __init int hmat_init(void)
 					     hmat_parse_subtable, 0) < 0)
 			goto out_put;
 	}
+	hmat_register_targets();
 out_put:
 	acpi_put_table(tbl);
 	return 0;
-- 
2.14.4
