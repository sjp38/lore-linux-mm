Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E64516B0260
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 21:10:36 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g8so2828052pgs.14
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 18:10:36 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e69si2358748pfc.337.2017.12.13.18.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 18:10:34 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 3/3] hmat: add performance attributes
Date: Wed, 13 Dec 2017 19:10:19 -0700
Message-Id: <20171214021019.13579-4-ross.zwisler@linux.intel.com>
In-Reply-To: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Add performance information found in the HMAT to the sysfs representation.
This information lives as an attribute group named "local_init" in the
memory target:

  # tree mem_tgt2
  mem_tgt2
  a??a??a?? firmware_id
  a??a??a?? is_cached
  a??a??a?? local_init
  a??A A  a??a??a?? mem_init0 -> ../../mem_init0
  a??A A  a??a??a?? mem_init1 -> ../../mem_init1
  a??A A  a??a??a?? read_bw_MBps
  a??A A  a??a??a?? read_lat_nsec
  a??A A  a??a??a?? write_bw_MBps
  a??A A  a??a??a?? write_lat_nsec
  a??a??a?? node2 -> ../../node/node2
  a??a??a?? power
  a??A A  a??a??a?? async
  a??A A  ...
  a??a??a?? subsystem -> ../../../../bus/hmat
  a??a??a?? uevent

This attribute group surfaces latency and bandwidth performance for a
memory target and its local initiators.  For example:

  # grep . mem_tgt2/local_init/* 2>/dev/null
  mem_tgt2/local_init/read_bw_MBps:30720
  mem_tgt2/local_init/read_lat_nsec:100
  mem_tgt2/local_init/write_bw_MBps:30720
  mem_tgt2/local_init/write_lat_nsec:100

The initiators also have a symlink to their local targets:

  # ls -l mem_init0/mem_tgt2
  lrwxrwxrwx. 1 root root 0 Dec 13 16:45 mem_init0/mem_tgt2 -> ../mem_tgt2

We create performance attribute groups only for local (initiator,target)
pairings, where the first local initiator for a given target is defined by
the "Processor Proximity Domain" field in the HMAT's Memory Subsystem
Address Range Structure table.  After we have one local initiator we scan
the performance data to link to any other "local" initiators with the same
local performance to a given memory target.

A given target only has one set of local performance values, so each target
will have at most one "local_init" attribute group, though that group can
contain links to multiple initiators that all have local performance.  A
given memory initiator may have multiple local memory targets, so multiple
"mem_tgtX" links may exist for a given initiator.

If a given memory target is cached we give performance numbers only for the
media itself, and rely on the "is_cached" attribute to represent the
fact that there is a caching layer.

The fact that we only expose a subset of the performance information
presented in the HMAT via sysfs as a compromise, driven by fact that those
usages will be the highest performing and because to represent all possible
paths could cause an unmanageable explosion of sysfs entries.

If we dump everything from the HMAT into sysfs we end up with
O(num_targets * num_initiators * num_caching_levels) attributes.  Each of
these attributes only takes up 2 bytes in a System Locality Latency and
Bandwidth Information Structure, but if we have to create a directory entry
for each it becomes much more expensive.

For example, very large systems today can have on the order of thousands of
NUMA nodes.  Say we have a system which used to have 1,000 NUMA nodes that
each had both a CPU and local memory.  The HMAT allows us to separate the
CPUs and memory into separate NUMA nodes, so we can end up with 1,000 CPU
initiator NUMA nodes and 1,000 memory target NUMA nodes.  If we represented
the performance information for each possible CPU/memory pair in sysfs we
would end up with 1,000,000 attribute groups.

This is a lot to pass in a set of packed data tables, but I think we'll
break sysfs if we try to create millions of attributes, regardless of how
we nest them in a directory hierarchy.

By only representing performance information for local (initiator,target)
pairings, we reduce the number of sysfs entries to O(num_targets).

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 drivers/acpi/hmat/Makefile          |   2 +-
 drivers/acpi/hmat/core.c            | 263 +++++++++++++++++++++++++++++++++++-
 drivers/acpi/hmat/hmat.h            |  17 +++
 drivers/acpi/hmat/perf_attributes.c |  56 ++++++++
 4 files changed, 336 insertions(+), 2 deletions(-)
 create mode 100644 drivers/acpi/hmat/perf_attributes.c

diff --git a/drivers/acpi/hmat/Makefile b/drivers/acpi/hmat/Makefile
index edf4bcb1c97d..b5d1d83684da 100644
--- a/drivers/acpi/hmat/Makefile
+++ b/drivers/acpi/hmat/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_ACPI_HMAT) := hmat.o
-hmat-y := core.o initiator.o target.o
+hmat-y := core.o initiator.o target.o perf_attributes.o
diff --git a/drivers/acpi/hmat/core.c b/drivers/acpi/hmat/core.c
index 61b90dadf84b..89e84658fc73 100644
--- a/drivers/acpi/hmat/core.c
+++ b/drivers/acpi/hmat/core.c
@@ -23,11 +23,225 @@
 #include <linux/slab.h>
 #include "hmat.h"
 
+#define NO_VALUE	-1
+#define LOCAL_INIT	"local_init"
+
 static LIST_HEAD(target_list);
 static LIST_HEAD(initiator_list);
+LIST_HEAD(locality_list);
 
 static bool bad_hmat;
 
+/* Performance attributes for an initiator/target pair. */
+static int get_performance_data(u32 init_pxm, u32 tgt_pxm,
+		struct acpi_hmat_locality *hmat_loc)
+{
+	int num_init = hmat_loc->number_of_initiator_Pds;
+	int num_tgt = hmat_loc->number_of_target_Pds;
+	int init_idx = NO_VALUE;
+	int tgt_idx = NO_VALUE;
+	u32 *initiators, *targets;
+	u16 *entries, val;
+	int i;
+
+	/* the initiator array is after the struct acpi_hmat_locality fields */
+	initiators = (u32 *)(hmat_loc + 1);
+	targets = &initiators[num_init];
+	entries = (u16 *)&targets[num_tgt];
+
+	for (i = 0; i < num_init; i++) {
+		if (initiators[i] == init_pxm) {
+			init_idx = i;
+			break;
+		}
+	}
+
+	if (init_idx == NO_VALUE)
+		return NO_VALUE;
+
+	for (i = 0; i < num_tgt; i++) {
+		if (targets[i] == tgt_pxm) {
+			tgt_idx = i;
+			break;
+		}
+	}
+
+	if (tgt_idx == NO_VALUE)
+		return NO_VALUE;
+
+	val = entries[init_idx*num_tgt + tgt_idx];
+	if (val < 10 || val == 0xFFFF)
+		return NO_VALUE;
+
+	return (int)(val * hmat_loc->entry_base_unit) / 10;
+}
+
+/*
+ * 'direction' is either READ or WRITE
+ * Latency is reported in nanoseconds and bandwidth is reported in MB/s.
+ */
+static int hmat_get_attribute(int init_pxm, int tgt_pxm, int direction,
+		enum hmat_attr_type type)
+{
+	struct memory_locality *loc;
+	int value;
+
+	list_for_each_entry(loc, &locality_list, list) {
+		struct acpi_hmat_locality *hmat_loc = loc->hmat_loc;
+
+		if (direction == READ && type == LATENCY &&
+		    (hmat_loc->data_type == ACPI_HMAT_ACCESS_LATENCY ||
+		     hmat_loc->data_type == ACPI_HMAT_READ_LATENCY)) {
+			value = get_performance_data(init_pxm, tgt_pxm,
+					hmat_loc);
+			if (value != NO_VALUE)
+				return value;
+		}
+
+		if (direction == WRITE && type == LATENCY &&
+		    (hmat_loc->data_type == ACPI_HMAT_ACCESS_LATENCY ||
+		     hmat_loc->data_type == ACPI_HMAT_WRITE_LATENCY)) {
+			value = get_performance_data(init_pxm, tgt_pxm,
+					hmat_loc);
+			if (value != NO_VALUE)
+				return value;
+		}
+
+		if (direction == READ && type == BANDWIDTH &&
+		    (hmat_loc->data_type == ACPI_HMAT_ACCESS_BANDWIDTH ||
+		     hmat_loc->data_type == ACPI_HMAT_READ_BANDWIDTH)) {
+			value = get_performance_data(init_pxm, tgt_pxm,
+					hmat_loc);
+			if (value != NO_VALUE)
+				return value;
+		}
+
+		if (direction == WRITE && type == BANDWIDTH &&
+		    (hmat_loc->data_type == ACPI_HMAT_ACCESS_BANDWIDTH ||
+		     hmat_loc->data_type == ACPI_HMAT_WRITE_BANDWIDTH)) {
+			value = get_performance_data(init_pxm, tgt_pxm,
+					hmat_loc);
+			if (value != NO_VALUE)
+				return value;
+		}
+	}
+
+	return NO_VALUE;
+}
+
+/*
+ * 'direction' is either READ or WRITE
+ * Latency is reported in nanoseconds and bandwidth is reported in MB/s.
+ */
+int hmat_local_attribute(struct device *tgt_dev, int direction,
+		enum hmat_attr_type type)
+{
+	struct memory_target *tgt = to_memory_target(tgt_dev);
+	int tgt_pxm = tgt->ma->proximity_domain;
+	int init_pxm;
+
+	if (!tgt->local_init)
+		return NO_VALUE;
+
+	init_pxm = tgt->local_init->pxm;
+	return hmat_get_attribute(init_pxm, tgt_pxm, direction, type);
+}
+
+static bool is_local_init(int init_pxm, int tgt_pxm, int read_lat,
+		int write_lat, int read_bw, int write_bw)
+{
+	if (read_lat != hmat_get_attribute(init_pxm, tgt_pxm, READ, LATENCY))
+		return false;
+
+	if (write_lat != hmat_get_attribute(init_pxm, tgt_pxm, WRITE, LATENCY))
+		return false;
+
+	if (read_bw != hmat_get_attribute(init_pxm, tgt_pxm, READ, BANDWIDTH))
+		return false;
+
+	if (write_bw != hmat_get_attribute(init_pxm, tgt_pxm, WRITE, BANDWIDTH))
+		return false;
+
+	return true;
+}
+
+static const struct attribute_group performance_attribute_group = {
+	.attrs = performance_attributes,
+	.name = LOCAL_INIT,
+};
+
+static void remove_performance_attributes(struct memory_target *tgt)
+{
+	if (!tgt->local_init)
+		return;
+
+	/*
+	 * FIXME: Need to enhance the core sysfs code to remove all the links
+	 * in both the attribute group and in the device itself when those are
+	 * removed.
+	 */
+	sysfs_remove_group(&tgt->dev.kobj, &performance_attribute_group);
+}
+
+static int add_performance_attributes(struct memory_target *tgt)
+{
+	int read_lat, write_lat, read_bw, write_bw;
+	int tgt_pxm = tgt->ma->proximity_domain;
+	struct kobject *init_kobj, *tgt_kobj;
+	struct device *init_dev, *tgt_dev;
+	struct memory_initiator *init;
+	int ret;
+
+	if (!tgt->local_init)
+		return 0;
+
+	tgt_dev = &tgt->dev;
+	tgt_kobj = &tgt_dev->kobj;
+
+	/* Create entries for initiator/target pair in the target.  */
+	ret = sysfs_create_group(tgt_kobj, &performance_attribute_group);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Iterate through initiators and find all the ones that have the same
+	 * performance as the local initiator.
+	 */
+	read_lat = hmat_local_attribute(tgt_dev, READ, LATENCY);
+	write_lat = hmat_local_attribute(tgt_dev, WRITE, LATENCY);
+	read_bw = hmat_local_attribute(tgt_dev, READ, BANDWIDTH);
+	write_bw = hmat_local_attribute(tgt_dev, WRITE, BANDWIDTH);
+
+	list_for_each_entry(init, &initiator_list, list) {
+		init_dev = &init->dev;
+		init_kobj = &init_dev->kobj;
+
+		if (init == tgt->local_init ||
+			is_local_init(init->pxm, tgt_pxm, read_lat,
+				write_lat, read_bw, write_bw)) {
+			ret = sysfs_add_link_to_group(tgt_kobj, LOCAL_INIT,
+					init_kobj, dev_name(init_dev));
+			if (ret < 0)
+				goto err;
+
+			/*
+			 * Create a link in the local initiator to this
+			 * target.
+			 */
+			ret = sysfs_create_link(init_kobj, tgt_kobj,
+					kobject_name(tgt_kobj));
+			if (ret < 0)
+				goto err;
+		}
+
+	}
+	tgt->has_perf_attributes = true;
+	return 0;
+err:
+	remove_performance_attributes(tgt);
+	return ret;
+}
+
 static int link_node_for_kobj(unsigned int node, struct kobject *kobj)
 {
 	if (node_devices[node])
@@ -132,6 +346,9 @@ static void release_memory_target(struct device *dev)
 
 static void __init remove_memory_target(struct memory_target *tgt)
 {
+	if (tgt->has_perf_attributes)
+		remove_performance_attributes(tgt);
+
 	if (tgt->is_registered) {
 		remove_node_for_kobj(pxm_to_node(tgt->ma->proximity_domain),
 				&tgt->dev.kobj);
@@ -276,6 +493,38 @@ hmat_parse_address_range(struct acpi_subtable_header *header,
 	return -EINVAL;
 }
 
+static int __init hmat_parse_locality(struct acpi_subtable_header *header,
+		const unsigned long end)
+{
+	struct acpi_hmat_locality *hmat_loc;
+	struct memory_locality *loc;
+
+	if (bad_hmat)
+		return 0;
+
+	hmat_loc = (struct acpi_hmat_locality *)header;
+	if (!hmat_loc) {
+		pr_err("HMAT: NULL table entry\n");
+		bad_hmat = true;
+		return -EINVAL;
+	}
+
+	/* We don't report cached performance information in sysfs. */
+	if (hmat_loc->flags == ACPI_HMAT_MEMORY ||
+			hmat_loc->flags == ACPI_HMAT_LAST_LEVEL_CACHE) {
+		loc = kzalloc(sizeof(*loc), GFP_KERNEL);
+		if (!loc) {
+			bad_hmat = true;
+			return -ENOMEM;
+		}
+
+		loc->hmat_loc = hmat_loc;
+		list_add_tail(&loc->list, &locality_list);
+	}
+
+	return 0;
+}
+
 static int __init hmat_parse_cache(struct acpi_subtable_header *header,
 		const unsigned long end)
 {
@@ -431,6 +680,7 @@ srat_parse_memory_affinity(struct acpi_subtable_header *header,
 static void hmat_cleanup(void)
 {
 	struct memory_initiator *init, *init_iter;
+	struct memory_locality *loc, *loc_iter;
 	struct memory_target *tgt, *tgt_iter;
 
 	list_for_each_entry_safe(tgt, tgt_iter, &target_list, list)
@@ -438,6 +688,11 @@ static void hmat_cleanup(void)
 
 	list_for_each_entry_safe(init, init_iter, &initiator_list, list)
 		remove_memory_initiator(init);
+
+	list_for_each_entry_safe(loc, loc_iter, &locality_list, list) {
+		list_del(&loc->list);
+		kfree(loc);
+	}
 }
 
 static int __init hmat_init(void)
@@ -488,13 +743,15 @@ static int __init hmat_init(void)
 	}
 
 	if (!acpi_table_parse(ACPI_SIG_HMAT, hmat_noop_parse)) {
-		struct acpi_subtable_proc hmat_proc[2];
+		struct acpi_subtable_proc hmat_proc[3];
 
 		memset(hmat_proc, 0, sizeof(hmat_proc));
 		hmat_proc[0].id = ACPI_HMAT_TYPE_ADDRESS_RANGE;
 		hmat_proc[0].handler = hmat_parse_address_range;
 		hmat_proc[1].id = ACPI_HMAT_TYPE_CACHE;
 		hmat_proc[1].handler = hmat_parse_cache;
+		hmat_proc[2].id = ACPI_HMAT_TYPE_LOCALITY;
+		hmat_proc[2].handler = hmat_parse_locality;
 
 		acpi_table_parse_entries_array(ACPI_SIG_HMAT,
 					sizeof(struct acpi_table_hmat),
@@ -516,6 +773,10 @@ static int __init hmat_init(void)
 		ret = register_memory_target(tgt);
 		if (ret)
 			goto err;
+
+		ret = add_performance_attributes(tgt);
+		if (ret)
+			goto err;
 	}
 
 	return 0;
diff --git a/drivers/acpi/hmat/hmat.h b/drivers/acpi/hmat/hmat.h
index 108aad1f8ad7..89200f5c4b38 100644
--- a/drivers/acpi/hmat/hmat.h
+++ b/drivers/acpi/hmat/hmat.h
@@ -16,6 +16,11 @@
 #ifndef _ACPI_HMAT_H_
 #define _ACPI_HMAT_H_
 
+enum hmat_attr_type {
+	LATENCY,
+	BANDWIDTH,
+};
+
 struct memory_initiator {
 	struct list_head list;
 	struct device dev;
@@ -39,9 +44,21 @@ struct memory_target {
 
 	bool is_cached;
 	bool is_registered;
+	bool has_perf_attributes;
 };
 #define to_memory_target(d) container_of((d), struct memory_target, dev)
 
+struct memory_locality {
+	struct list_head list;
+	struct acpi_hmat_locality *hmat_loc;
+};
+
 extern const struct attribute_group *memory_initiator_attribute_groups[];
 extern const struct attribute_group *memory_target_attribute_groups[];
+extern struct attribute *performance_attributes[];
+
+extern struct list_head locality_list;
+
+int hmat_local_attribute(struct device *tgt_dev, int direction,
+		enum hmat_attr_type type);
 #endif /* _ACPI_HMAT_H_ */
diff --git a/drivers/acpi/hmat/perf_attributes.c b/drivers/acpi/hmat/perf_attributes.c
new file mode 100644
index 000000000000..60f107b58822
--- /dev/null
+++ b/drivers/acpi/hmat/perf_attributes.c
@@ -0,0 +1,56 @@
+/*
+ * Heterogeneous Memory Attributes Table (HMAT) sysfs performance attributes
+ *
+ * Copyright (c) 2017, Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#include <linux/acpi.h>
+#include <linux/device.h>
+#include <linux/sysfs.h>
+#include "hmat.h"
+
+static ssize_t read_lat_nsec_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%d\n", hmat_local_attribute(dev, READ, LATENCY));
+}
+static DEVICE_ATTR_RO(read_lat_nsec);
+
+static ssize_t write_lat_nsec_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%d\n", hmat_local_attribute(dev, WRITE, LATENCY));
+}
+static DEVICE_ATTR_RO(write_lat_nsec);
+
+static ssize_t read_bw_MBps_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%d\n", hmat_local_attribute(dev, READ, BANDWIDTH));
+}
+static DEVICE_ATTR_RO(read_bw_MBps);
+
+static ssize_t write_bw_MBps_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%d\n",
+			hmat_local_attribute(dev, WRITE, BANDWIDTH));
+}
+static DEVICE_ATTR_RO(write_bw_MBps);
+
+struct attribute *performance_attributes[] = {
+	&dev_attr_read_lat_nsec.attr,
+	&dev_attr_write_lat_nsec.attr,
+	&dev_attr_read_bw_MBps.attr,
+	&dev_attr_write_bw_MBps.attr,
+	NULL
+};
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
