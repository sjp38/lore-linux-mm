Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3061C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:11:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 916B6222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:11:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 916B6222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2650B8E0004; Thu, 14 Feb 2019 12:10:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 219FD8E0009; Thu, 14 Feb 2019 12:10:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08CBF8E0004; Thu, 14 Feb 2019 12:10:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCD718E0009
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:44 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so5227351pfi.21
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=IVqe7/RwqKptnSILtO2UTKb6nQYdwEgQHFqkSNoeptA=;
        b=I39s90U77ilyswYO5lTcV7JncpzEKcll6wjyIBHzupxsDaSoWF0lt1MuwEnm8J/bzF
         RiVWx6FE587L9KmuQ/ytq28VxhxYdVktlYW8WUfDMbQPJGmSJhvi+EgZzIOXuQsp6QSO
         omNDlG3OekSt7ldsEG4zDke4tnVOxldxPv6EC7BBwPZztJeTuNb7RnvE6YRzTK/5KSK/
         7KjZlb48i6SQ9jfLc+Wr4Z/idE+3n9Qsd8kOP0gSF2JxS0c0AAm90LUCkIKQNOIpvJbY
         HaPY44VP3MhV7obqrDI3LwVEsHCgwgC263aIVzczcLRCU/wMfqP9N2W38+dKXxhONbpX
         PMsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaShjpS49UdGuD1ohSYG2krntPYOes5zGSqO/H5Y6sB5h0INx/e
	KH6c9/P+jecDbsCrICL2NoINuGrlUcLQOj+WusAsKyloayPdfX1pJ8Q8/NnPRnYS99oZ46bgZtV
	HYItK+o+TPXUxQX94ee5eOCIdVXpNBFyybIz7i2FrcPB7I98l0wUITSyXuM/Ifu2acw==
X-Received: by 2002:aa7:9102:: with SMTP id 2mr5021600pfh.179.1550164244401;
        Thu, 14 Feb 2019 09:10:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IafEhBc2yukj4g0tlWh5cacUgp2G66E0U94H2lAYpIUGMkYQX4WoQByIdRLTmfHmhmb9fYU
X-Received: by 2002:aa7:9102:: with SMTP id 2mr5021507pfh.179.1550164243158;
        Thu, 14 Feb 2019 09:10:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164243; cv=none;
        d=google.com; s=arc-20160816;
        b=sh3AA2URcMpjcVui6+Mi1AiWI3MF19DKaLUDPSi1nzTdqNmVEe5KMZ4b1nmUzuK6ME
         77E7XH0x+S3+cKFk/2aXVlYv3SZaCbXWk69CsaS89vWf+15Xv6LydgfO1y/nj5LVNgjN
         vcMa44fdLWHnjhrlMECM5AICCijCvkdeA9/WAfVfyfIzLR3rIeVRs7bIs2oHtBTLc5vg
         FMt9ME7hFh5nTlirBWi9y5sadglNKXCz48HwMYkAacbd4CYPfyJaooY48qT70SMNhc1B
         NL/GvZe4iQ3ZAqHryd7/jDjmc6V0l+8QvxzE4PFIH5SvYDjbBUhVUiMnDDAboSyTU2kM
         Zxvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=IVqe7/RwqKptnSILtO2UTKb6nQYdwEgQHFqkSNoeptA=;
        b=N+0FwInA7tBHN7NmTJh0xeqXqh+tK52LNf47NxndYnNoGAzBgAY32Npl/Qf4NLZZs3
         EHR0XI/G4/ikQdB/zNPjDjUSQt4P9fOK4vAzBy785wZOsIoWQTLAnKIZss3tBjHYUTRZ
         pGx+HgE2sNf3zaj8RTNMMWbU1tzT8iPzWVks7cPgJrMJXNq2l6HAc4AaW/SoifIDd/u3
         5UprjIsa5J9zs9QHlWJ/m279EgoxQ4O78zHnd6XHbgWIARlxEPqTvCtSFoJPl3ecC+HU
         fJ95fJRGXIC9GmweNRqn1lsE+pG1skpwY6iN3d+Fm+2m2HufWOONlK0bWFEHnRh7qnit
         D+xA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j17si2724426pfn.271.2019.02.14.09.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:10:43 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:10:42 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="133613128"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 14 Feb 2019 09:10:42 -0800
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
Subject: [PATCHv6 07/10] acpi/hmat: Register processor domain to its memory
Date: Thu, 14 Feb 2019 10:10:14 -0700
Message-Id: <20190214171017.9362-8-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If the HMAT Subsystem Address Range provides a valid processor proximity
domain for a memory domain, or a processor domain matches the performance
access of the valid processor proximity domain, register the memory
target with that initiator so this relationship will be visible under
the node's sysfs directory.

By registering only the best performing relationships, this provides the
most useful information applications may want to know when considering
which CPU they should run on for a given memory node, or which memory
node they should allocate memory from for a given CPU.

Since HMAT requires valid address ranges have an equivalent SRAT entry,
verify each memory target satisfies this requirement.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/Kconfig |   1 +
 drivers/acpi/hmat/hmat.c  | 396 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 396 insertions(+), 1 deletion(-)

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
index 7a809f6a5119..b29f7160c7bb 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -13,11 +13,105 @@
 #include <linux/device.h>
 #include <linux/init.h>
 #include <linux/list.h>
+#include <linux/list_sort.h>
 #include <linux/node.h>
 #include <linux/sysfs.h>
 
 static __initdata u8 hmat_revision;
 
+static __initdata LIST_HEAD(targets);
+static __initdata LIST_HEAD(initiators);
+static __initdata LIST_HEAD(localities);
+
+/*
+ * The defined enum order is used to prioritize attributes selecting the best
+ * performing node.
+ */
+enum locality_types {
+	WRITE_LATENCY,
+	READ_LATENCY,
+	WRITE_BANDWIDTH,
+	READ_BANDWIDTH,
+};
+
+static struct memory_locality *localities_types[4];
+
+struct memory_target {
+	struct list_head node;
+	unsigned int memory_pxm;
+	unsigned int processor_pxm;
+	struct node_hmem_attrs hmem_attrs;
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
+static __init void alloc_memory_initiator(unsigned int cpu_pxm)
+{
+	struct memory_initiator *intitator;
+
+	if (pxm_to_node(cpu_pxm) == NUMA_NO_NODE)
+		return;
+
+	intitator = find_mem_initiator(cpu_pxm);
+	if (intitator)
+		return;
+
+	intitator = kzalloc(sizeof(*intitator), GFP_KERNEL);
+	if (!intitator)
+		return;
+
+	intitator->processor_pxm = cpu_pxm;
+	list_add_tail(&intitator->node, &initiators);
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
@@ -89,14 +183,83 @@ static __init u32 hmat_normalize(u16 entry, u64 base, u8 type)
 	return value;
 }
 
+static __init void hmat_update_target_access(struct memory_target *target,
+					     u8 type, u32 value)
+{
+	switch (type) {
+	case ACPI_HMAT_ACCESS_LATENCY:
+		target->hmem_attrs.read_latency = value;
+		target->hmem_attrs.write_latency = value;
+		break;
+	case ACPI_HMAT_READ_LATENCY:
+		target->hmem_attrs.read_latency = value;
+		break;
+	case ACPI_HMAT_WRITE_LATENCY:
+		target->hmem_attrs.write_latency = value;
+		break;
+	case ACPI_HMAT_ACCESS_BANDWIDTH:
+		target->hmem_attrs.read_bandwidth = value;
+		target->hmem_attrs.write_bandwidth = value;
+		break;
+	case ACPI_HMAT_READ_BANDWIDTH:
+		target->hmem_attrs.read_bandwidth = value;
+		break;
+	case ACPI_HMAT_WRITE_BANDWIDTH:
+		target->hmem_attrs.write_bandwidth = value;
+		break;
+	default:
+		break;
+	}
+}
+
+static __init void hmat_add_locality(struct acpi_hmat_locality *hmat_loc)
+{
+	struct memory_locality *loc;
+
+	loc = kzalloc(sizeof(*loc), GFP_KERNEL);
+	if (!loc) {
+		pr_notice_once("Failed to allocate HMAT locality\n");
+		return;
+	}
+
+	loc->hmat_loc = hmat_loc;
+	list_add_tail(&loc->node, &localities);
+
+	switch (hmat_loc->data_type) {
+	case ACPI_HMAT_ACCESS_LATENCY:
+		localities_types[READ_LATENCY] = loc;
+		localities_types[WRITE_LATENCY] = loc;
+		break;
+	case ACPI_HMAT_READ_LATENCY:
+		localities_types[READ_LATENCY] = loc;
+		break;
+	case ACPI_HMAT_WRITE_LATENCY:
+		localities_types[WRITE_LATENCY] = loc;
+		break;
+	case ACPI_HMAT_ACCESS_BANDWIDTH:
+		localities_types[READ_BANDWIDTH] = loc;
+		localities_types[WRITE_BANDWIDTH] = loc;
+		break;
+	case ACPI_HMAT_READ_BANDWIDTH:
+		localities_types[READ_BANDWIDTH] = loc;
+		break;
+	case ACPI_HMAT_WRITE_BANDWIDTH:
+		localities_types[WRITE_BANDWIDTH] = loc;
+		break;
+	default:
+		break;
+	}
+}
+
 static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 				      const unsigned long end)
 {
 	struct acpi_hmat_locality *hmat_loc = (void *)header;
+	struct memory_target *target;
 	unsigned int init, targ, total_size, ipds, tpds;
 	u32 *inits, *targs, value;
 	u16 *entries;
-	u8 type;
+	u8 type, mem_hier;
 
 	if (hmat_loc->header.length < sizeof(*hmat_loc)) {
 		pr_notice("HMAT: Unexpected locality header length: %d\n",
@@ -105,6 +268,7 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 	}
 
 	type = hmat_loc->data_type;
+	mem_hier = hmat_loc->flags & ACPI_HMAT_MEMORY_HIERARCHY;
 	ipds = hmat_loc->number_of_initiator_Pds;
 	tpds = hmat_loc->number_of_target_Pds;
 	total_size = sizeof(*hmat_loc) + sizeof(*entries) * ipds * tpds +
@@ -123,6 +287,7 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 	targs = inits + ipds;
 	entries = (u16 *)(targs + tpds);
 	for (init = 0; init < ipds; init++) {
+		alloc_memory_initiator(inits[init]);
 		for (targ = 0; targ < tpds; targ++) {
 			value = hmat_normalize(entries[init * tpds + targ],
 					       hmat_loc->entry_base_unit,
@@ -130,9 +295,18 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 			pr_info("  Initiator-Target[%d-%d]:%d%s\n",
 				inits[init], targs[targ], value,
 				hmat_data_type_suffix(type));
+
+			if (mem_hier == ACPI_HMAT_MEMORY) {
+				target = find_mem_target(targs[targ]);
+				if (target && target->processor_pxm == inits[init])
+					hmat_update_target_access(target, type, value);
+			}
 		}
 	}
 
+	if (mem_hier == ACPI_HMAT_MEMORY)
+		hmat_add_locality(hmat_loc);
+
 	return 0;
 }
 
@@ -160,6 +334,7 @@ static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
 					   const unsigned long end)
 {
 	struct acpi_hmat_address_range *spa = (void *)header;
+	struct memory_target *target = NULL;
 
 	if (spa->header.length != sizeof(*spa)) {
 		pr_notice("HMAT: Unexpected address range header length: %d\n",
@@ -175,6 +350,23 @@ static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
 		pr_info("HMAT: Memory Flags:%04x Processor Domain:%d Memory Domain:%d\n",
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
 
@@ -198,6 +390,195 @@ static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
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
+static __init u32 hmat_initiator_perf(struct memory_target *target,
+			       struct memory_initiator *initiator,
+			       struct acpi_hmat_locality *hmat_loc)
+{
+	unsigned int ipds, tpds, i, idx = 0, tdx = 0;
+	u32 *inits, *targs;
+	u16 *entries;
+
+	ipds = hmat_loc->number_of_initiator_Pds;
+	tpds = hmat_loc->number_of_target_Pds;
+	inits = (u32 *)(hmat_loc + 1);
+	targs = inits + ipds;
+	entries = (u16 *)(targs + tpds);
+
+	for (i = 0; i < ipds; i++) {
+		if (inits[i] == initiator->processor_pxm) {
+			idx = i;
+			break;
+		}
+	}
+
+	if (i == ipds)
+		return 0;
+
+	for (i = 0; i < tpds; i++) {
+		if (targs[i] == target->memory_pxm) {
+			tdx = i;
+			break;
+		}
+	}
+	if (i == tpds)
+		return 0;
+
+	return hmat_normalize(entries[idx * tpds + tdx],
+			      hmat_loc->entry_base_unit,
+			      hmat_loc->data_type);
+}
+
+static __init bool hmat_update_best(u8 type, u32 value, u32 *best)
+{
+	bool updated = false;
+
+	if (!value)
+		return false;
+
+	switch (type) {
+	case ACPI_HMAT_ACCESS_LATENCY:
+	case ACPI_HMAT_READ_LATENCY:
+	case ACPI_HMAT_WRITE_LATENCY:
+		if (!*best || *best > value) {
+			*best = value;
+			updated = true;
+		}
+		break;
+	case ACPI_HMAT_ACCESS_BANDWIDTH:
+	case ACPI_HMAT_READ_BANDWIDTH:
+	case ACPI_HMAT_WRITE_BANDWIDTH:
+		if (!*best || *best < value) {
+			*best = value;
+			updated = true;
+		}
+		break;
+	}
+
+	return updated;
+}
+
+static int initiator_cmp(void *priv, struct list_head *a, struct list_head *b)
+{
+	struct memory_initiator *ia;
+	struct memory_initiator *ib;
+	unsigned long *p_nodes = priv;
+
+	ia = list_entry(a, struct memory_initiator, node);
+	ib = list_entry(b, struct memory_initiator, node);
+
+	set_bit(ia->processor_pxm, p_nodes);
+	set_bit(ib->processor_pxm, p_nodes);
+
+	return ia->processor_pxm - ib->processor_pxm;
+}
+
+static __init void hmat_register_target_initiators(struct memory_target *target)
+{
+	static DECLARE_BITMAP(p_nodes, MAX_NUMNODES);
+	struct memory_initiator *initiator;
+	unsigned int mem_nid, cpu_nid;
+	struct memory_locality *loc = NULL;
+	u32 best = 0;
+	int i;
+
+	if (target->processor_pxm == PXM_INVAL)
+		return;
+
+	mem_nid = pxm_to_node(target->memory_pxm);
+
+	/*
+	 * If the Address Range Structure provides a local processor pxm, link
+	 * only that one. Otherwise, find the best performance attribtes and
+	 * register all initiators that match.
+	 */
+	if (target->processor_pxm != PXM_INVAL) {
+		cpu_nid = pxm_to_node(target->processor_pxm);
+		register_memory_node_under_compute_node(mem_nid, cpu_nid, 0);
+		return;
+	}
+
+	if (list_empty(&localities))
+		return;
+
+	/*
+	 * We need the initiator list iteration sorted so we can use
+	 * bitmap_clear for previously set initiators when we find a better
+	 * memory accessor. We'll also use the sorting to prime the candidate
+	 * nodes with known initiators.
+	 */
+	bitmap_zero(p_nodes, MAX_NUMNODES);
+	list_sort(p_nodes, &initiators, initiator_cmp);
+	for (i = WRITE_LATENCY; i <= READ_BANDWIDTH; i++) {
+		loc = localities_types[i];
+		if (!loc)
+			continue;
+
+		best = 0;
+		list_for_each_entry(initiator, &initiators, node) {
+			u32 value;
+
+			if (!test_bit(initiator->processor_pxm, p_nodes))
+				continue;
+
+			value = hmat_initiator_perf(target, initiator, loc->hmat_loc);
+			if (hmat_update_best(loc->hmat_loc->data_type, value, &best))
+				bitmap_clear(p_nodes, 0, initiator->processor_pxm);
+			if (value != best)
+				clear_bit(initiator->processor_pxm, p_nodes);
+		}
+		if (best)
+			hmat_update_target_access(target, loc->hmat_loc->data_type, best);
+	}
+
+	for_each_set_bit(i, p_nodes, MAX_NUMNODES) {
+		cpu_nid = pxm_to_node(i);
+		register_memory_node_under_compute_node(mem_nid, cpu_nid, 0);
+	}
+}
+
+static __init void hmat_register_targets(void)
+{
+	struct memory_target *target;
+
+	list_for_each_entry(target, &targets, node)
+		hmat_register_target_initiators(target);
+}
+
+static __init void hmat_free_structures(void)
+{
+	struct memory_target *target, *tnext;
+	struct memory_locality *loc, *lnext;
+	struct memory_initiator *intitator, *inext;
+
+	list_for_each_entry_safe(target, tnext, &targets, node) {
+		list_del(&target->node);
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
@@ -207,6 +588,17 @@ static __init int hmat_init(void)
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
@@ -229,7 +621,9 @@ static __init int hmat_init(void)
 			goto out_put;
 		}
 	}
+	hmat_register_targets();
 out_put:
+	hmat_free_structures();
 	acpi_put_table(tbl);
 	return 0;
 }
-- 
2.14.4

