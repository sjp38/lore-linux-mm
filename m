Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 621C78E00A6
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:08:28 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 74so5896731pfk.12
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:08:28 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id i7si24473410pgc.144.2019.01.24.15.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:08:27 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv5 07/10] acpi/hmat: Register performance attributes
Date: Thu, 24 Jan 2019 16:07:21 -0700
Message-Id: <20190124230724.10022-8-keith.busch@intel.com>
In-Reply-To: <20190124230724.10022-1-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Register the local attached performace access attributes with the memory's
node if HMAT provides the locality table. While HMAT does make it possible
to know performance for all possible initiator-target pairings, we export
only the local and matching pairings at this time.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/Kconfig |  1 +
 drivers/acpi/hmat/hmat.c  | 14 ++++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
index c9637e2e7514..08e972ead159 100644
--- a/drivers/acpi/hmat/Kconfig
+++ b/drivers/acpi/hmat/Kconfig
@@ -2,6 +2,7 @@
 config ACPI_HMAT
 	bool "ACPI Heterogeneous Memory Attribute Table Support"
 	depends on ACPI_NUMA
+	select HMEM_REPORTING
 	help
 	 If set, this option causes the kernel to set the memory NUMA node
 	 relationships and access attributes in accordance with ACPI HMAT
diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index 85fd835c2e23..917e6122b3f0 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -430,6 +430,19 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
 		hmat_register_if_local(target, initiator);
 }
 
+static __init void hmat_register_target_perf(struct memory_target *target)
+{
+	unsigned mem_nid = pxm_to_node(target->memory_pxm);
+	struct node_hmem_attrs hmem_attrs = {
+		.read_bandwidth	= target->read_bandwidth,
+		.write_bandwidth= target->write_bandwidth,
+		.read_latency	= target->read_latency,
+		.write_latency	= target->write_latency,
+	};
+
+	node_set_perf_attrs(mem_nid, &hmem_attrs, 0);
+}
+
 static __init void hmat_register_targets(void)
 {
 	struct memory_target *target, *tnext;
@@ -439,6 +452,7 @@ static __init void hmat_register_targets(void)
 	list_for_each_entry_safe(target, tnext, &targets, node) {
 		list_del(&target->node);
 		hmat_register_target_initiators(target);
+		hmat_register_target_perf(target);
 		kfree(target);
 	}
 
-- 
2.14.4
