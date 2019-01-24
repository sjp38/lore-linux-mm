Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3A708E0097
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:08:26 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id t10so4939357plo.13
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:08:26 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d13si14930236pgh.196.2019.01.24.15.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:08:25 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv5 03/10] acpi/hmat: Parse and report heterogeneous memory
Date: Thu, 24 Jan 2019 16:07:17 -0700
Message-Id: <20190124230724.10022-4-keith.busch@intel.com>
In-Reply-To: <20190124230724.10022-1-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Systems may provide different memory types and export this information
in the ACPI Heterogeneous Memory Attribute Table (HMAT). Parse these
tables provided by the platform and report the memory access and caching
attributes to the kernel messages.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/Kconfig       |   1 +
 drivers/acpi/Makefile      |   1 +
 drivers/acpi/hmat/Kconfig  |   8 ++
 drivers/acpi/hmat/Makefile |   1 +
 drivers/acpi/hmat/hmat.c   | 181 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 192 insertions(+)
 create mode 100644 drivers/acpi/hmat/Kconfig
 create mode 100644 drivers/acpi/hmat/Makefile
 create mode 100644 drivers/acpi/hmat/hmat.c

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 90ff0a47c12e..b377f970adfd 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -465,6 +465,7 @@ config ACPI_REDUCED_HARDWARE_ONLY
 	  If you are unsure what to do, do not enable this option.
 
 source "drivers/acpi/nfit/Kconfig"
+source "drivers/acpi/hmat/Kconfig"
 
 source "drivers/acpi/apei/Kconfig"
 source "drivers/acpi/dptf/Kconfig"
diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
index bb857421c2e8..5d361e4e3405 100644
--- a/drivers/acpi/Makefile
+++ b/drivers/acpi/Makefile
@@ -80,6 +80,7 @@ obj-$(CONFIG_ACPI_PROCESSOR)	+= processor.o
 obj-$(CONFIG_ACPI)		+= container.o
 obj-$(CONFIG_ACPI_THERMAL)	+= thermal.o
 obj-$(CONFIG_ACPI_NFIT)		+= nfit/
+obj-$(CONFIG_ACPI_HMAT)		+= hmat/
 obj-$(CONFIG_ACPI)		+= acpi_memhotplug.o
 obj-$(CONFIG_ACPI_HOTPLUG_IOAPIC) += ioapic.o
 obj-$(CONFIG_ACPI_BATTERY)	+= battery.o
diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
new file mode 100644
index 000000000000..c9637e2e7514
--- /dev/null
+++ b/drivers/acpi/hmat/Kconfig
@@ -0,0 +1,8 @@
+# SPDX-License-Identifier: GPL-2.0
+config ACPI_HMAT
+	bool "ACPI Heterogeneous Memory Attribute Table Support"
+	depends on ACPI_NUMA
+	help
+	 If set, this option causes the kernel to set the memory NUMA node
+	 relationships and access attributes in accordance with ACPI HMAT
+	 (Heterogeneous Memory Attributes Table).
diff --git a/drivers/acpi/hmat/Makefile b/drivers/acpi/hmat/Makefile
new file mode 100644
index 000000000000..e909051d3d00
--- /dev/null
+++ b/drivers/acpi/hmat/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_ACPI_HMAT) := hmat.o
diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
new file mode 100644
index 000000000000..1741bf30d87f
--- /dev/null
+++ b/drivers/acpi/hmat/hmat.c
@@ -0,0 +1,181 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Copyright (c) 2019, Intel Corporation.
+ *
+ * Heterogeneous Memory Attributes Table (HMAT) representation
+ *
+ * This program parses and reports the platform's HMAT tables, and registers
+ * the applicable attributes with the node's interfaces.
+ */
+
+#include <linux/acpi.h>
+#include <linux/bitops.h>
+#include <linux/device.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/node.h>
+#include <linux/sysfs.h>
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
+static __init int hmat_parse_locality(union acpi_subtable_headers *header,
+				      const unsigned long end)
+{
+	struct acpi_hmat_locality *hmat_loc = (void *)header;
+	unsigned int init, targ, total_size, ipds, tpds;
+	u32 *inits, *targs, value;
+	u16 *entries;
+	u8 type;
+
+	if (hmat_loc->header.length < sizeof(*hmat_loc)) {
+		pr_debug("HMAT: Unexpected locality header length: %d\n",
+			 hmat_loc->header.length);
+		return -EINVAL;
+	}
+
+	type = hmat_loc->data_type;
+	ipds = hmat_loc->number_of_initiator_Pds;
+	tpds = hmat_loc->number_of_target_Pds;
+	total_size = sizeof(*hmat_loc) + sizeof(*entries) * ipds * tpds +
+		     sizeof(*inits) * ipds + sizeof(*targs) * tpds;
+	if (hmat_loc->header.length < total_size) {
+		pr_debug("HMAT: Unexpected locality header length:%d, minimum required:%d\n",
+			 hmat_loc->header.length, total_size);
+		return -EINVAL;
+	}
+
+	pr_info("HMAT: Locality: Flags:%02x Type:%s Initiator Domains:%d Target Domains:%d Base:%lld\n",
+		hmat_loc->flags, hmat_data_type(type), ipds, tpds,
+		hmat_loc->entry_base_unit);
+
+	inits = (u32 *)(hmat_loc + 1);
+	targs = &inits[ipds];
+	entries = (u16 *)(&targs[tpds]);
+	for (init = 0; init < ipds; init++) {
+		for (targ = 0; targ < tpds; targ++) {
+			value = entries[init * tpds + targ];
+			value = (value * hmat_loc->entry_base_unit) / 10;
+			pr_info("  Initiator-Target[%d-%d]:%d%s\n",
+				inits[init], targs[targ], value,
+				hmat_data_type_suffix(type));
+		}
+	}
+
+	return 0;
+}
+
+static __init int hmat_parse_cache(union acpi_subtable_headers *header,
+				   const unsigned long end)
+{
+	struct acpi_hmat_cache *cache = (void *)header;
+	u32 attrs;
+
+	if (cache->header.length < sizeof(*cache)) {
+		pr_debug("HMAT: Unexpected cache header length: %d\n",
+			 cache->header.length);
+		return -EINVAL;
+	}
+
+	attrs = cache->cache_attributes;
+	pr_info("HMAT: Cache: Domain:%d Size:%llu Attrs:%08x SMBIOS Handles:%d\n",
+		cache->memory_PD, cache->cache_size, attrs,
+		cache->number_of_SMBIOShandles);
+
+	return 0;
+}
+
+static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
+					   const unsigned long end)
+{
+	struct acpi_hmat_address_range *spa = (void *)header;
+
+	if (spa->header.length != sizeof(*spa)) {
+		pr_debug("HMAT: Unexpected address range header length: %d\n",
+			 spa->header.length);
+		return -EINVAL;
+	}
+	pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
+		spa->physical_address_base, spa->physical_address_length,
+		spa->flags, spa->processor_PD, spa->memory_PD);
+
+	return 0;
+}
+
+static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
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
+static __init int hmat_init(void)
+{
+	struct acpi_table_header *tbl;
+	enum acpi_hmat_type i;
+	acpi_status status;
+
+	if (srat_disabled())
+		return 0;
+
+	status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
+	if (ACPI_FAILURE(status))
+		return 0;
+
+	for (i = ACPI_HMAT_TYPE_ADDRESS_RANGE; i < ACPI_HMAT_TYPE_RESERVED; i++) {
+		if (acpi_table_parse_entries(ACPI_SIG_HMAT,
+					     sizeof(struct acpi_table_hmat), i,
+					     hmat_parse_subtable, 0) < 0)
+			goto out_put;
+	}
+out_put:
+	acpi_put_table(tbl);
+	return 0;
+}
+subsys_initcall(hmat_init);
-- 
2.14.4
