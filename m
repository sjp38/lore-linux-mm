Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ADCDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 269C5222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 269C5222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2C238E0006; Thu, 14 Feb 2019 12:10:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D9708E0004; Thu, 14 Feb 2019 12:10:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C8818E0006; Thu, 14 Feb 2019 12:10:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 499018E0004
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:42 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id m3so5249387pfj.14
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=tyEKj59565U25rl0qcMR+696K6bogldQbhLNBv4PyRM=;
        b=p2KqsxG9nbOZYvdVU6RF5I5Hj5GUJrElrGo4fzduk/LQMRg1OV4VsTpHchy5SrHF7H
         +DPDTP/sQqFvfF7Ga4Q4ZVCf1LZCTdwCAB7dsXZScnAomfINRtC3bxDToNNHXcGDCtLr
         nR5wp7z++uw7Sip8eUdpGQxwQ4d+60WrEZQbvsh0E56ogj/ZR6M7/Vudwf4bSBnqHvZe
         7WeoAAo1QPVh+NSRPzxEjXptshKzvNJVOcLZIvViTl7zp7aL5hm2JVtiAqfMxHGE0el7
         KAwVp5MzjJxDpJUYQ0Qu0ifd1sVBBkjVctBNlCYSO9K6TcSzEtumBqBtmvlODagJzL9g
         P1JA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY5mI8y65gNaqJu5X11QUXsuNum9DmU95AFwzcaF4rFEO3R6CYD
	DlIR1o8iEDcwJByRk1QxRq83fIG7imxuHzpJblYqNGJQQtZPaEHREgxl7KGe8jgd9KmErvAXbgn
	/BUKVjmJGqknZEIoDQP1fiRebcRYuShJz4DcrLKdilvb31O68m6WoGdRZrX1lJXpziQ==
X-Received: by 2002:aa7:808f:: with SMTP id v15mr5217550pff.30.1550164241913;
        Thu, 14 Feb 2019 09:10:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYNqGnXJwPO+x9aw6c/P5zBv89+jZpWQMhdqWiBNvFtWC12TbWq+zZc6UWW1hY9PjhvRRwZ
X-Received: by 2002:aa7:808f:: with SMTP id v15mr5217464pff.30.1550164240783;
        Thu, 14 Feb 2019 09:10:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164240; cv=none;
        d=google.com; s=arc-20160816;
        b=eYjF67Lx3CbqULCWvGrnk+rAEDHzBRXu5pbXMQ+8Vn3uCLFjjcA6FRR88s+rubCazZ
         /l0eDX3UeTAmzLFxGfYxoWRI0FpvwwJBWEZiXW7Gxr0OZWGpNqNIHW1NBV6XcbV0BbmW
         ARRv6HVsm88LgxIk3PH/q9JmbXOJ5qR0fTHI1UgjeNXLQSuRt9ugidyQUOekg+l/g3cn
         AOfTjZ5NO4jqAK3NoxXonnAb51AjNBDHz9j+xoAQkcJr5LZ9uqD7mXHn7aS8TJoPPlpL
         5nsoaXp6cveGzwL3wKG5eCim1mCXfpTGEelSDeucXxHVchzJZ/EdsXUlSff4XxnoYv/K
         EvZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=tyEKj59565U25rl0qcMR+696K6bogldQbhLNBv4PyRM=;
        b=g4HhrUb5sLWKewfIbYXfea2SZYV1c5we/kbkCjkUAl0Heh2h9uTrS3xXeAkVdST5G1
         JO6dvHGbml4EYLKId4x92lIQ/kbPIM0ES0viIAgvr+A76AaIDjpKv7xbxkyGDVsbK70n
         VLn/wd9/8FzrlOQpbHRK68fkT34luv2LD7rEFE4d1PKYGkBZ5/bdhW9tH6WRCx2amK35
         d7t4/omiVSVFe4VU18/qTYPVxdqEw+Yr9vZzLmuFq6kL99KRrG829KYgShm9aUxNgba2
         IwKYIjFPs8MraFRvW5Z8K5QCWfmkPAy9aRSSCq5KnEdl/JLV55YMztb+vQapvlwZotkP
         Azyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j17si2724426pfn.271.2019.02.14.09.10.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:10:40 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:10:40 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="133613106"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 14 Feb 2019 09:10:39 -0800
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv6 03/10] acpi/hmat: Parse and report heterogeneous memory
Date: Thu, 14 Feb 2019 10:10:10 -0700
Message-Id: <20190214171017.9362-4-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
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
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/Kconfig       |   1 +
 drivers/acpi/Makefile      |   1 +
 drivers/acpi/hmat/Kconfig  |   8 ++
 drivers/acpi/hmat/Makefile |   1 +
 drivers/acpi/hmat/hmat.c   | 236 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 247 insertions(+)
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
index 000000000000..7a809f6a5119
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
+static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
+					   const unsigned long end)
+{
+	struct acpi_hmat_address_range *spa = (void *)header;
+
+	if (spa->header.length != sizeof(*spa)) {
+		pr_notice("HMAT: Unexpected address range header length: %d\n",
+			 spa->header.length);
+		return -EINVAL;
+	}
+
+	if (hmat_revision == 1)
+		pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
+			spa->physical_address_base, spa->physical_address_length,
+			spa->flags, spa->processor_PD, spa->memory_PD);
+	else
+		pr_info("HMAT: Memory Flags:%04x Processor Domain:%d Memory Domain:%d\n",
+			spa->flags, spa->processor_PD, spa->memory_PD);
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

