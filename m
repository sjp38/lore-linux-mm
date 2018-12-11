Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A2A98E006C
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 20:05:50 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so8634399pgb.7
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 17:05:50 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si11402278pfj.276.2018.12.10.17.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 17:05:48 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 05/12] acpi/hmat: Register processor domain to its memory
Date: Mon, 10 Dec 2018 18:03:03 -0700
Message-Id: <20181211010310.8551-6-keith.busch@intel.com>
In-Reply-To: <20181211010310.8551-1-keith.busch@intel.com>
References: <20181211010310.8551-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

If the HMAT Subsystem Address Range provides a valid processor proximity
domain for a memory domain, or a processor domain with the highest
performing access, register the node as one of the initiator's primary
memory targets so this relationship will be visible under the node's
sysfs directory.

Since HMAT requires valid address ranges have an equivalent SRAT entry,
verify each memory target satisfies this requirement.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat.c | 149 +++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 142 insertions(+), 7 deletions(-)

diff --git a/drivers/acpi/hmat.c b/drivers/acpi/hmat.c
index ef3881f0f370..5d8747ad025f 100644
--- a/drivers/acpi/hmat.c
+++ b/drivers/acpi/hmat.c
@@ -17,6 +17,43 @@
 #include <linux/slab.h>
 #include <linux/sysfs.h>
 
+static LIST_HEAD(targets);
+
+struct memory_target {
+	struct list_head node;
+	unsigned int memory_pxm;
+	unsigned long p_nodes[BITS_TO_LONGS(MAX_NUMNODES)];
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
 static __init const char *hmat_data_type(u8 type)
 {
 	switch (type) {
@@ -53,11 +90,30 @@ static __init const char *hmat_data_type_suffix(u8 type)
 	};
 }
 
+static __init void hmat_update_access(u8 type, u32 value, u32 *best)
+{
+	switch (type) {
+	case ACPI_HMAT_ACCESS_LATENCY:
+	case ACPI_HMAT_READ_LATENCY:
+	case ACPI_HMAT_WRITE_LATENCY:
+		if (!*best || *best > value)
+			*best = value;
+		break;
+	case ACPI_HMAT_ACCESS_BANDWIDTH:
+	case ACPI_HMAT_READ_BANDWIDTH:
+	case ACPI_HMAT_WRITE_BANDWIDTH:
+		if (!*best || *best < value)
+			*best = value;
+		break;
+	}
+}
+
 static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 				      const unsigned long end)
 {
+	struct memory_target *t;
 	struct acpi_hmat_locality *loc = (void *)header;
-	unsigned int init, targ, total_size, ipds, tpds;
+	unsigned int init, targ, pass, p_node, total_size, ipds, tpds;
 	u32 *inits, *targs, value;
 	u16 *entries;
 	u8 type;
@@ -87,12 +143,28 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 	targs = &inits[ipds];
 	entries = (u16 *)(&targs[tpds]);
 	for (targ = 0; targ < tpds; targ++) {
-		for (init = 0; init < ipds; init++) {
-			value = entries[init * tpds + targ];
-			value = (value * loc->entry_base_unit) / 10;
-			pr_info("  Initiator-Target[%d-%d]:%d%s\n",
-				inits[init], targs[targ], value,
-				hmat_data_type_suffix(type));
+		u32 best = 0;
+
+		t = find_mem_target(targs[targ]);
+		for (pass = 0; pass < 2; pass++) {
+			for (init = 0; init < ipds; init++) {
+				value = entries[init * tpds + targ];
+				value = (value * loc->entry_base_unit) / 10;
+
+				if (!pass) {
+					hmat_update_access(type, value, &best);
+					pr_info("  Initiator-Target[%d-%d]:%d%s\n",
+						inits[init], targs[targ], value,
+						hmat_data_type_suffix(type));
+					continue;
+				}
+
+				if (!t)
+					continue;
+				p_node = pxm_to_node(inits[init]);
+				if (p_node != NUMA_NO_NODE && value == best)
+					set_bit(p_node, t->p_nodes);
+			}
 		}
 	}
 	return 0;
@@ -122,6 +194,7 @@ static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
 					   const unsigned long end)
 {
 	struct acpi_hmat_address_range *spa = (void *)header;
+	struct memory_target *t = NULL;
 
 	if (spa->header.length != sizeof(*spa)) {
 		pr_err("HMAT: Unexpected address range header length: %d\n",
@@ -131,6 +204,23 @@ static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
 	pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
 		spa->physical_address_base, spa->physical_address_length,
 		spa->flags, spa->processor_PD, spa->memory_PD);
+
+	if (spa->flags & ACPI_HMAT_MEMORY_PD_VALID) {
+		t = find_mem_target(spa->memory_PD);
+		if (!t) {
+			pr_warn("HMAT: Memory Domain missing from SRAT\n");
+			return -EINVAL;
+		}
+	}
+	if (t && spa->flags & ACPI_HMAT_PROCESSOR_PD_VALID) {
+		int p_node = pxm_to_node(spa->processor_PD);
+
+		if (p_node == NUMA_NO_NODE) {
+			pr_warn("HMAT: Invalid Processor Domain\n");
+			return -EINVAL;
+		}
+		set_bit(p_node, t->p_nodes);
+	}
 	return 0;
 }
 
@@ -154,6 +244,33 @@ static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
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
+static __init void hmat_register_targets(void)
+{
+	struct memory_target *t, *next;
+	unsigned m, p;
+
+	list_for_each_entry_safe(t, next, &targets, node) {
+		list_del(&t->node);
+		m = pxm_to_node(t->memory_pxm);
+		for_each_set_bit(p, t->p_nodes, MAX_NUMNODES)
+			register_memory_node_under_compute_node(m, p);
+		kfree(t);
+	}
+}
+
 static __init int parse_noop(struct acpi_table_header *table)
 {
 	return 0;
@@ -169,6 +286,23 @@ static __init int hmat_init(void)
 	if (srat_disabled())
 		return 0;
 
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
 	status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
 	if (ACPI_FAILURE(status))
 		return 0;
@@ -185,6 +319,7 @@ static __init int hmat_init(void)
 					&subtable_proc, 1, 0) < 0)
 			goto out_put;
 	}
+	hmat_register_targets();
  out_put:
 	acpi_put_table(tbl);
 	return 0;
-- 
2.14.4
