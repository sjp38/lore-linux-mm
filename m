Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA266B026B
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:53:07 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p9so2598679pfj.3
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:53:07 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h18-v6si21592604pgv.47.2018.11.14.14.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 14:53:05 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 7/7] acpi/hmat: Parse and report heterogeneous memory
Date: Wed, 14 Nov 2018 15:49:20 -0700
Message-Id: <20181114224921.12123-8-keith.busch@intel.com>
In-Reply-To: <20181114224921.12123-2-keith.busch@intel.com>
References: <20181114224921.12123-2-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

The ACPI Heterogeneous Memory Attribute Table (HMAT) table added in ACPI 6.2
provides a way for platforms to express different memory address range
characteristics.

Parse these tables provided by the platform and register the local
initiator performance access and caching attributes with the memory numa
nodes so they can be observed through sysfs.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/Kconfig  |   9 ++
 drivers/acpi/Makefile |   1 +
 drivers/acpi/hmat.c   | 384 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/acpi/tables.c |  10 ++
 4 files changed, 404 insertions(+)
 create mode 100644 drivers/acpi/hmat.c

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 7cea769c37df..9e6b767dd366 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -327,6 +327,15 @@ config ACPI_NUMA
 	depends on (X86 || IA64 || ARM64)
 	default y if IA64_GENERIC || IA64_SGI_SN2 || ARM64
 
+config ACPI_HMAT
+	bool "ACPI Heterogeneous Memory Attribute Table Support"
+	depends on ACPI_NUMA
+	select HMEM
+	help
+	 Parses representation of the ACPI Heterogeneous Memory Attributes
+	 Table (HMAT) and set the memory node relationships and access
+	 attributes.
+
 config ACPI_CUSTOM_DSDT_FILE
 	string "Custom DSDT Table file to include"
 	default ""
diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
index edc039313cd6..b5e13499f88b 100644
--- a/drivers/acpi/Makefile
+++ b/drivers/acpi/Makefile
@@ -55,6 +55,7 @@ acpi-$(CONFIG_X86)		+= x86/apple.o
 acpi-$(CONFIG_X86)		+= x86/utils.o
 acpi-$(CONFIG_DEBUG_FS)		+= debugfs.o
 acpi-$(CONFIG_ACPI_NUMA)	+= numa.o
+acpi-$(CONFIG_ACPI_HMAT)	+= hmat.o
 acpi-$(CONFIG_ACPI_PROCFS_POWER) += cm_sbs.o
 acpi-y				+= acpi_lpat.o
 acpi-$(CONFIG_ACPI_LPIT)	+= acpi_lpit.o
diff --git a/drivers/acpi/hmat.c b/drivers/acpi/hmat.c
new file mode 100644
index 000000000000..9070e84fd30e
--- /dev/null
+++ b/drivers/acpi/hmat.c
@@ -0,0 +1,384 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Heterogeneous Memory Attributes Table (HMAT) representation
+ *
+ * Copyright (c) 2018, Intel Corporation.
+ */
+
+#include <acpi/acpi_numa.h>
+#include <linux/acpi.h>
+#include <linux/bitops.h>
+#include <linux/cpu.h>
+#include <linux/device.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/node.h>
+#include <linux/slab.h>
+#include <linux/sysfs.h>
+
+static LIST_HEAD(targets);
+
+struct memory_target {
+	struct list_head node;
+	unsigned int memory_pxm;
+	unsigned long processor_nodes[BITS_TO_LONGS(MAX_NUMNODES)];
+	struct node_hmem_attrs hmem;
+};
+
+static __init struct memory_target *find_mem_target(unsigned int m)
+{
+	struct memory_target *t;
+
+	list_for_each_entry(t, &targets, node)
+		if (t->memory_pxm == m)
+			return t;
+	return NULL;
+}
+
+static __init void alloc_memory_target(unsigned int mem_pxm)
+{
+	struct memory_target *t;
+
+	if (pxm_to_node(mem_pxm) == NUMA_NO_NODE)
+		return;
+
+	t = find_mem_target(mem_pxm);
+	if (t)
+		return;
+
+	t = kzalloc(sizeof(*t), GFP_KERNEL);
+	if (!t)
+		return;
+
+	t->memory_pxm = mem_pxm;
+	list_add_tail(&t->node, &targets);
+}
+
+static __init const char *hmat_data_type(u8 type)
+{
+	switch (type) {
+	case ACPI_HMAT_ACCESS_LATENCY:
+		return "Access Latency";
+	case ACPI_HMAT_READ_LATENCY:
+		return "Read Latency";
+	case ACPI_HMAT_WRITE_LATENCY:
+		return "Write Latency";
+	case ACPI_HMAT_ACCESS_BANDWIDTH:
+		return "Access Bandwidth";
+	case ACPI_HMAT_READ_BANDWIDTH:
+		return "Read Bandwidth";
+	case ACPI_HMAT_WRITE_BANDWIDTH:
+		return "Write Bandwidth";
+	default:
+		return "Reserved";
+	};
+}
+
+static __init const char *hmat_data_type_suffix(u8 type)
+{
+	switch (type) {
+	case ACPI_HMAT_ACCESS_LATENCY:
+	case ACPI_HMAT_READ_LATENCY:
+	case ACPI_HMAT_WRITE_LATENCY:
+		return " nsec";
+	case ACPI_HMAT_ACCESS_BANDWIDTH:
+	case ACPI_HMAT_READ_BANDWIDTH:
+	case ACPI_HMAT_WRITE_BANDWIDTH:
+		return " MB/s";
+	default:
+		return "";
+	};
+}
+
+static __init void hmat_update_value(u32 *dest, u32 value, bool gt,
+				     bool *update, bool *tie)
+{
+	if (!(*dest)) {
+		*update = true;
+		*dest = value;
+	} else if (gt && value > *dest) {
+		*update = true;
+		*dest = value;
+	} else if (!gt && value < *dest) {
+		*update = true;
+		*dest = value;
+	} else if (*dest == value) {
+		*tie = true;
+	}
+}
+
+static __init void hmat_update_target_access(unsigned int p, unsigned int m, u8 type,
+				      unsigned int value)
+{
+	struct memory_target *t = find_mem_target(m);
+	int p_node = pxm_to_node(p);
+	bool update = false, tie = false;
+
+	if (!t || p_node == NUMA_NO_NODE || !value)
+		return;
+
+	switch (type) {
+	case ACPI_HMAT_ACCESS_LATENCY:
+		hmat_update_value(&t->hmem.read_latency, value, false,
+				  &update, &tie);
+		hmat_update_value(&t->hmem.write_latency, value, false,
+				  &update, &tie);
+		break;
+	case ACPI_HMAT_READ_LATENCY:
+		hmat_update_value(&t->hmem.read_latency, value, false,
+				  &update, &tie);
+		break;
+	case ACPI_HMAT_WRITE_LATENCY:
+		hmat_update_value(&t->hmem.write_latency, value, false,
+				  &update, &tie);
+		break;
+	case ACPI_HMAT_ACCESS_BANDWIDTH:
+		hmat_update_value(&t->hmem.read_bandwidth, value, true,
+				  &update, &tie);
+		hmat_update_value(&t->hmem.write_bandwidth, value, true,
+				  &update, &tie);
+		break;
+	case ACPI_HMAT_READ_BANDWIDTH:
+		hmat_update_value(&t->hmem.read_bandwidth, value, true,
+				  &update, &tie);
+		break;
+	case ACPI_HMAT_WRITE_BANDWIDTH:
+		hmat_update_value(&t->hmem.write_bandwidth, value, true,
+				  &update, &tie);
+		break;
+	}
+
+	if (update) {
+		bitmap_zero(t->processor_nodes, MAX_NUMNODES);
+		set_bit(p_node, t->processor_nodes);
+	} else if (tie)
+		set_bit(p_node, t->processor_nodes);
+}
+
+static __init int hmat_parse_locality(struct acpi_subtable_header *header,
+				      const unsigned long end)
+{
+	struct acpi_hmat_locality *loc = (void *)header;
+	unsigned int i, j, total_size, ipds, tpds;
+	u32 *inits, *targs, value;
+	u16 *entries;
+	u8 type;
+
+	if (loc->header.length < sizeof(*loc)) {
+		pr_err("HMAT: Unexpected locality header length: %d\n",
+			loc->header.length);
+		return -EINVAL;
+	}
+
+	type = loc->data_type;
+	ipds = loc->number_of_initiator_Pds;
+	tpds = loc->number_of_target_Pds;
+	total_size = sizeof(*loc) + sizeof(*entries) * ipds * tpds +
+		     sizeof(*inits) * ipds + sizeof(*targs) * tpds;
+	if (loc->header.length < total_size) {
+		pr_err("HMAT: Unexpected locality header length:%d, minimum required:%d\n",
+			loc->header.length, total_size);
+		return -EINVAL;
+	}
+
+	pr_info("HMAT: Locality: Flags:%02x Type:%s Initiator Domains:%d Target Domains:%d Base:%lld\n",
+		loc->flags, hmat_data_type(type), ipds, tpds,
+		loc->entry_base_unit);
+
+	inits = (u32 *)(loc + 1);
+	targs = &inits[ipds];
+	entries = (u16 *)(&targs[tpds]);
+	for (i = 0; i < ipds; i++) {
+		for (j = 0; j < loc->number_of_target_Pds; j++) {
+			value = (*entries * loc->entry_base_unit) / 10;
+			pr_info("  Initiator-Target[%d-%d]:%d%s\n", inits[i],
+				targs[j], value, hmat_data_type_suffix(type));
+
+			if ((loc->flags & ACPI_HMAT_MEMORY_HIERARCHY) ==
+							ACPI_HMAT_MEMORY)
+				hmat_update_target_access(inits[i], targs[j],
+							  type, value);
+			entries++;
+		}
+	}
+	return 0;
+}
+
+static __init int hmat_parse_cache(struct acpi_subtable_header *header,
+				   const unsigned long end)
+{
+	struct acpi_hmat_cache *cache = (void *)header;
+	struct node_cache_attrs cache_attrs;
+	u32 attrs;
+
+	if (cache->header.length < sizeof(*cache)) {
+		pr_err("HMAT: Unexpected cache header length: %d\n",
+			cache->header.length);
+		return -EINVAL;
+	}
+
+	attrs = cache->cache_attributes;
+	pr_info("HMAT: Cache: Domain:%d Size:%llu Attrs:%08x SMBIOS Handles:%d\n",
+		cache->memory_PD, cache->cache_size, attrs,
+		cache->number_of_SMBIOShandles);
+
+	cache_attrs.size = cache->cache_size;
+	cache_attrs.level = (attrs & ACPI_HMAT_CACHE_LEVEL) >> 4;
+	cache_attrs.line_size = (attrs & ACPI_HMAT_CACHE_LINE_SIZE) >> 16;
+
+	switch ((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) {
+	case ACPI_HMAT_CA_DIRECT_MAPPED:
+		cache_attrs.associativity = NODE_CACHE_DIRECT_MAP;
+		break;
+	case ACPI_HMAT_CA_COMPLEX_CACHE_INDEXING:
+		cache_attrs.associativity = NODE_CACHE_INDEXED;
+		break;
+	case ACPI_HMAT_CA_NONE:
+	default:
+		cache_attrs.associativity = NODE_CACHE_OTHER;
+		break;
+	}
+	switch ((attrs & ACPI_HMAT_WRITE_POLICY) >> 12) {
+	case ACPI_HMAT_CP_WB:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_BACK;
+		break;
+	case ACPI_HMAT_CP_WT:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_THROUGH;
+		break;
+	case ACPI_HMAT_CP_NONE:
+	default:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_OTHER;
+		break;
+	}
+
+	node_add_cache(pxm_to_node(cache->memory_PD), &cache_attrs);
+	return 0;
+}
+
+static int __init hmat_parse_address_range(struct acpi_subtable_header *header,
+					   const unsigned long end)
+{
+	struct acpi_hmat_address_range *spa = (void *)header;
+
+	if (spa->header.length != sizeof(*spa)) {
+		pr_err("HMAT: Unexpected address range header length: %d\n",
+			spa->header.length);
+		return -EINVAL;
+	}
+	pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
+		spa->physical_address_base, spa->physical_address_length,
+		spa->flags, spa->processor_PD, spa->memory_PD);
+	return 0;
+}
+
+static int __init hmat_parse_subtable(struct acpi_subtable_header *header,
+				      const unsigned long end)
+{
+	struct acpi_hmat_structure *hdr = (void *)header;
+
+	if (!hdr)
+		return -EINVAL;
+
+	switch (hdr->type) {
+	case ACPI_HMAT_TYPE_ADDRESS_RANGE:
+		return hmat_parse_address_range(header, end);
+	case ACPI_HMAT_TYPE_LOCALITY:
+		return hmat_parse_locality(header, end);
+	case ACPI_HMAT_TYPE_CACHE:
+		return hmat_parse_cache(header, end);
+	default:
+		return -EINVAL;
+	}
+}
+
+static __init int srat_parse_mem_affinity(struct acpi_subtable_header *header,
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
+static __init void hmat_register_targets(void)
+{
+	struct memory_target *t, *next;
+	unsigned m, p;
+
+	list_for_each_entry_safe(t, next, &targets, node) {
+		bool hmem_valid = false;
+
+		list_del(&t->node);
+		m = pxm_to_node(t->memory_pxm);
+
+		for_each_set_bit(p, t->processor_nodes, MAX_NUMNODES) {
+			if (register_memory_node_under_compute_node(m, p))
+				goto free_target;
+			hmem_valid = true;
+		}
+		if (hmem_valid)
+			node_set_perf_attrs(m, &t->hmem);
+free_target:
+		kfree(t);
+	}
+}
+
+static __init int parse_noop(struct acpi_table_header *table)
+{
+	return 0;
+}
+
+static __init int hmat_init(void)
+{
+	struct acpi_subtable_proc subtable_proc;
+	struct acpi_table_header *tbl;
+	enum acpi_hmat_type i;
+	acpi_status status;
+
+	if (srat_disabled())
+		return 0;
+
+	status = acpi_get_table(ACPI_SIG_SRAT, 0, &tbl);
+	if (ACPI_FAILURE(status))
+		return 0;
+
+	if (acpi_table_parse(ACPI_SIG_SRAT, parse_noop))
+		goto out_put;
+
+	memset(&subtable_proc, 0, sizeof(subtable_proc));
+	subtable_proc.id = ACPI_SRAT_TYPE_MEMORY_AFFINITY;
+	subtable_proc.handler = srat_parse_mem_affinity;
+
+	if (acpi_table_parse_entries_array(ACPI_SIG_SRAT,
+				sizeof(struct acpi_table_srat),
+				&subtable_proc, 1, 0) < 0)
+		goto out_put;
+	acpi_put_table(tbl);
+
+	status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
+	if (ACPI_FAILURE(status))
+		return 0;
+
+	if (acpi_table_parse(ACPI_SIG_HMAT, parse_noop))
+		goto out_put;
+
+	memset(&subtable_proc, 0, sizeof(subtable_proc));
+	subtable_proc.handler = hmat_parse_subtable;
+	for (i = ACPI_HMAT_TYPE_ADDRESS_RANGE; i < ACPI_HMAT_TYPE_RESERVED; i++) {
+		subtable_proc.id = i;
+		if (acpi_table_parse_entries_array(ACPI_SIG_HMAT,
+					sizeof(struct acpi_table_hmat),
+					&subtable_proc, 1, 0) < 0)
+			goto out_put;
+	}
+	hmat_register_targets();
+ out_put:
+	acpi_put_table(tbl);
+	return 0;
+}
+device_initcall(hmat_init);
diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 15ee77780f68..a34669a1d47a 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -51,10 +51,12 @@ static int acpi_apic_instance __initdata;
 
 enum acpi_subtable_type {
 	ACPI_SUBTABLE_COMMON,
+	ACPI_SUBTABLE_HMAT,
 };
 
 union acpi_subtable_headers {
 	struct acpi_subtable_header common;
+	struct acpi_hmat_structure hmat;
 };
 
 struct acpi_subtable_entry {
@@ -236,6 +238,8 @@ acpi_get_entry_type(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return entry->hdr->common.type;
+	case ACPI_SUBTABLE_HMAT:
+		return entry->hdr->hmat.type;
 	}
 	WARN_ONCE(1, "invalid acpi type\n");
 	return 0;
@@ -247,6 +251,8 @@ acpi_get_entry_length(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return entry->hdr->common.length;
+	case ACPI_SUBTABLE_HMAT:
+		return entry->hdr->hmat.length;
 	}
 	WARN_ONCE(1, "invalid acpi type\n");
 	return 0;
@@ -258,6 +264,8 @@ acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return sizeof(entry->hdr->common);
+	case ACPI_SUBTABLE_HMAT:
+		return sizeof(entry->hdr->hmat);
 	}
 	WARN_ONCE(1, "invalid acpi type\n");
 	return 0;
@@ -266,6 +274,8 @@ acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
 static enum acpi_subtable_type __init
 acpi_get_subtable_type(char *id)
 {
+	if (strncmp(id, ACPI_SIG_HMAT, 4) == 0)
+		return ACPI_SUBTABLE_HMAT;
 	return ACPI_SUBTABLE_COMMON;
 }
 
-- 
2.14.4
