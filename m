Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B724C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E0C9214AF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E0C9214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E5828E0004; Mon, 11 Mar 2019 16:55:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6926D8E0002; Mon, 11 Mar 2019 16:55:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EFE28E0007; Mon, 11 Mar 2019 16:55:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD41E8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:55:42 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x17so397788pfn.16
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:55:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=RjVTAY2+ujki8k5tgFibEHfkVGcKOQe0TjN/ucwTdzo=;
        b=j5DS5VWP28iZZF1zHvI0mT6c9zQA9WhaDhdEtEky3yo9F5nn0yXQCeFLG+/s72VZIp
         MayH8xcMjlZVSvxs/yz9Z5LDl/PXQv/9xr+oE7V7/eQGH+lli4y1qvnlH6A8ByS5QFKm
         ctfdMoPssFaYs63HWTXdJwziCDG+iS8SwLnh5kWEPb7adfnBzSHXewaxsvljYcbadtWS
         f+LpQRukv9Z4x2A/mtNZlpqPENQkOObGy1M3ybTzU82N+gHdJCsnyCUX8ZMZHNJJmvTe
         +9k3fn1xCxKoKzQcb+kJ5Gc32bbz9woItz+IRBahVBvxaK6pbICt9fD4Qz9Iqw0/9Uvg
         ratg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVg4Yv0Y2mFMir0AIS6CXcxsuwaX5IvcruhyYk9e39RVaItr6dE
	5bc6LmoU/qC8tISSTEK8hxfCPM7Ok3eLD5gftHRemuJe8JqI8xiSR6hCNxDT6T6Q2LcUzVfubOJ
	UkX0qWj7ZiRBDiYuLt8p5tlDrPtlm71JEZ7ylZNe/4EqFrdtNG87CnUaotyNhl85M+w==
X-Received: by 2002:a65:51c3:: with SMTP id i3mr31356939pgq.45.1552337742563;
        Mon, 11 Mar 2019 13:55:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTnqLW7r4qEddV3eCZa742rEl/QZaacVt7ITIp//1CuniWVtBL1yHhoYJW6+im26ORLiFl
X-Received: by 2002:a65:51c3:: with SMTP id i3mr31356882pgq.45.1552337741274;
        Mon, 11 Mar 2019 13:55:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552337741; cv=none;
        d=google.com; s=arc-20160816;
        b=Vb/ZxqO1XXZEPrbunutokPqhH6jM60kKTwIM2w4BmDjXa7htblfO7BLh9j4xFCXKvk
         fkWxHXWAynWlvZoaXHCleh3byVklRO5jT0gpCDkhkdRceTkU9OJUWSrNV+S3ETCRhbvE
         msYvX9fOgN5vMLC+bsOPN6wQB3As4WsGbUoO/LRoZinIISBez9QtaOaXVJFV77u6o4Wc
         ol8HKL1f3agDP4EafLV3Lp9RUL2LRVyRgr4tUuMtvxCUpuNJyf7fhXtRRDN/RlM0tOce
         XYkmChqCzdccsLoNu229jPp2zssf6NgJ+crUoQnsZUd0PlrbY9WxtdF8lLJfVGPA3u6F
         ljJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=RjVTAY2+ujki8k5tgFibEHfkVGcKOQe0TjN/ucwTdzo=;
        b=z9gHWY28ElQJ2dhR7j+x+HsSFuf1g3r4qm5vX5cdzO1v8dmfpAW7/IVrx+OQMnnJtS
         s/te8PS7u9b4M6wvFlNuBeOqZr+17W+vSeiHdi8ooFPxGmSpgQmh+5g5bOx9CCWybIdH
         SQz202eWbKJZFVxFkvP0QGhYhFsydQu3NQeGkllr0HR40oyv1aDBW5X9AXZUMHkkCkCY
         HbgzYkZyUe9hGQKZf2loPen85JGbT/aUrZI1JqLjz1yv8nI0oD/l6kSJKJM6HrhY0ulJ
         k8Dj24NBbnX2ErDvGC2DUEnD8DNMgvjG0yw4ORZT8cTM5dADY7RkgnTjynx4VkFi+X6G
         AtAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n189si5626588pga.46.2019.03.11.13.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:55:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Mar 2019 13:55:40 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,468,1544515200"; 
   d="scan'208";a="139910164"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 11 Mar 2019 13:55:40 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv8 03/10] acpi/hmat: Parse and report heterogeneous memory
Date: Mon, 11 Mar 2019 14:55:59 -0600
Message-Id: <20190311205606.11228-4-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190311205606.11228-1-keith.busch@intel.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Systems may provide different memory types and export this information
in the ACPI Heterogeneous Memory Attribute Table (HMAT). Parse these
tables provided by the platform and report the memory access and caching
attributes to the kernel messages.

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Acked-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/Kconfig       |   1 +
 drivers/acpi/Makefile      |   1 +
 drivers/acpi/hmat/Kconfig  |   7 ++
 drivers/acpi/hmat/Makefile |   1 +
 drivers/acpi/hmat/hmat.c   | 236 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 246 insertions(+)
 create mode 100644 drivers/acpi/hmat/Kconfig
 create mode 100644 drivers/acpi/hmat/Makefile
 create mode 100644 drivers/acpi/hmat/hmat.c

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 4e015c77e48e..283ee94224c6 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -475,6 +475,7 @@ config ACPI_REDUCED_HARDWARE_ONLY
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
index 000000000000..2f7111b7af62
--- /dev/null
+++ b/drivers/acpi/hmat/Kconfig
@@ -0,0 +1,7 @@
+# SPDX-License-Identifier: GPL-2.0
+config ACPI_HMAT
+	bool "ACPI Heterogeneous Memory Attribute Table Support"
+	depends on ACPI_NUMA
+	help
+	 If set, this option has the kernel parse and report the
+	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table).
diff --git a/drivers/acpi/hmat/Makefile b/drivers/acpi/hmat/Makefile
new file mode 100644
index 000000000000..e909051d3d00
--- /dev/null
+++ b/drivers/acpi/hmat/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_ACPI_HMAT) := hmat.o
diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
new file mode 100644
index 000000000000..4758beb3b2c1
--- /dev/null
+++ b/drivers/acpi/hmat/hmat.c
@@ -0,0 +1,236 @@
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
+static __initdata u8 hmat_revision;
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
+	}
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
+	}
+}
+
+static __init u32 hmat_normalize(u16 entry, u64 base, u8 type)
+{
+	u32 value;
+
+	/*
+	 * Check for invalid and overflow values
+	 */
+	if (entry == 0xffff || !entry)
+		return 0;
+	else if (base > (UINT_MAX / (entry)))
+		return 0;
+
+	/*
+	 * Divide by the base unit for version 1, convert latency from
+	 * picosenonds to nanoseconds if revision 2.
+	 */
+	value = entry * base;
+	if (hmat_revision == 1) {
+		if (value < 10)
+			return 0;
+		value = DIV_ROUND_UP(value, 10);
+	} else if (hmat_revision == 2) {
+		switch (type) {
+		case ACPI_HMAT_ACCESS_LATENCY:
+		case ACPI_HMAT_READ_LATENCY:
+		case ACPI_HMAT_WRITE_LATENCY:
+			value = DIV_ROUND_UP(value, 1000);
+			break;
+		default:
+			break;
+		}
+	}
+	return value;
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
+		pr_notice("HMAT: Unexpected locality header length: %d\n",
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
+		pr_notice("HMAT: Unexpected locality header length:%d, minimum required:%d\n",
+			 hmat_loc->header.length, total_size);
+		return -EINVAL;
+	}
+
+	pr_info("HMAT: Locality: Flags:%02x Type:%s Initiator Domains:%d Target Domains:%d Base:%lld\n",
+		hmat_loc->flags, hmat_data_type(type), ipds, tpds,
+		hmat_loc->entry_base_unit);
+
+	inits = (u32 *)(hmat_loc + 1);
+	targs = inits + ipds;
+	entries = (u16 *)(targs + tpds);
+	for (init = 0; init < ipds; init++) {
+		for (targ = 0; targ < tpds; targ++) {
+			value = hmat_normalize(entries[init * tpds + targ],
+					       hmat_loc->entry_base_unit,
+					       type);
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
+		pr_notice("HMAT: Unexpected cache header length: %d\n",
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
+static int __init hmat_parse_proximity_domain(union acpi_subtable_headers *header,
+					      const unsigned long end)
+{
+	struct acpi_hmat_proximity_domain *p = (void *)header;
+
+	if (p->header.length != sizeof(*p)) {
+		pr_notice("HMAT: Unexpected address range header length: %d\n",
+			 p->header.length);
+		return -EINVAL;
+	}
+
+	if (hmat_revision == 1)
+		pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
+			p->reserved3, p->reserved4, p->flags, p->processor_PD,
+			p->memory_PD);
+	else
+		pr_info("HMAT: Memory Flags:%04x Processor Domain:%d Memory Domain:%d\n",
+			p->flags, p->processor_PD, p->memory_PD);
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
+		return hmat_parse_proximity_domain(header, end);
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
+	hmat_revision = tbl->revision;
+	switch (hmat_revision) {
+	case 1:
+	case 2:
+		break;
+	default:
+		pr_notice("Ignoring HMAT: Unknown revision:%d\n", hmat_revision);
+		goto out_put;
+	}
+
+	for (i = ACPI_HMAT_TYPE_ADDRESS_RANGE; i < ACPI_HMAT_TYPE_RESERVED; i++) {
+		if (acpi_table_parse_entries(ACPI_SIG_HMAT,
+					     sizeof(struct acpi_table_hmat), i,
+					     hmat_parse_subtable, 0) < 0) {
+			pr_notice("Ignoring HMAT: Invalid table");
+			goto out_put;
+		}
+	}
+out_put:
+	acpi_put_table(tbl);
+	return 0;
+}
+subsys_initcall(hmat_init);
-- 
2.14.4

