Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59C1CC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:50:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1447F2184E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:50:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1447F2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF35E8E0004; Tue, 12 Feb 2019 11:50:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B53AF8E0001; Tue, 12 Feb 2019 11:50:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9561A8E0004; Tue, 12 Feb 2019 11:50:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 650D78E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:50:32 -0500 (EST)
Received: by mail-vs1-f69.google.com with SMTP id o22so1197885vsp.18
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:50:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=qHcqn+Ug+DP3AjqXDsty1crmXR+AS/AECu2pwPrmmFY=;
        b=jfSd+bBW7fC3nUfzya1jNN6etCWYl68n4eR3PXGoqqIp3kdy2S9g8D9fVlW8VWGgXD
         BZL4sBO+u+mvRTsbgOCB9/9JlEZvbVYX85u2rcwrSSCtB6UusW2XeNB0ATlLqMAc6d4+
         GBsToOc2Vg7VAcWv8BXiznnpmIzHW+BeOWwD1qED8lqa7zmk1xJuOU7b6UffjS/wIFXo
         +qFawp2Oxe31EECuIZZYQb1zDUaWB83CVsJFM+pCgEhumzA8Jx6vPMYvST7vHbQ8xIE/
         yjHp4+mRXgZC4h2xMfuhX+zDM0w1WdftLjyiX5gCgHWppYgyydMCzCdLLIXZuU3UOWcN
         pn7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAubkC+XYCoWAqB33MbwqRIAuVztadR3Eq55pHk3+J4NTeUwN5yG9
	Q4nZ02R83jURlftoEnsQI4tRJ9JQH4sW2ixWcTftrpSoV5397tSNsCzzGZVC2WQCZ3uGd0V62kQ
	8u6U3QK3StvPIdJdNKwUNTgaaqO96fPwX7NqVHvLGndVPJSmaMMZuXLSPcroYsHAURA==
X-Received: by 2002:a67:7c92:: with SMTP id x140mr1778200vsc.137.1549990232048;
        Tue, 12 Feb 2019 08:50:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ7RCowAWPzAVAzPikYhgUzLJV+g1/HR3elD67nxZ7PEvFPXWRKwHSNAFPFF+YJ+5h9gUsH
X-Received: by 2002:a67:7c92:: with SMTP id x140mr1778171vsc.137.1549990231020;
        Tue, 12 Feb 2019 08:50:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549990231; cv=none;
        d=google.com; s=arc-20160816;
        b=LQFu7xY2M71ltR97UBproVXMp1IeFI9VvYWFsE/ozBXLvGQ5Fx8xM5rAp2fnTrMeBc
         B8VPikhwBqvhLTeEQ0iGst7mBTa2xCWP1TEhg0QA/lS5srPDfIc9Yk+dGWvYIrJ68mrR
         /eKjhiPnYTZHQgKMvSc+Umsoet69OTM6kGc4XUfGPQkZRUR6YubueYTZFZSfb6cahlQs
         0Hj/eVwgqwEkpIR+E/NokqUUPQCsIDsNxbkHoeXcoGvMB9x2Lc63/h+CWQZUmWUXa5Bn
         Gf+ySryqyrmS5qal15xDJHbzGzHaeOjMedh0yFJqfKfif0pfONHmMJmVxdX/YBDt0OO+
         OkEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=qHcqn+Ug+DP3AjqXDsty1crmXR+AS/AECu2pwPrmmFY=;
        b=bvEnx3Ykqs2+yiazHhF+r5CVep/MkTFC7L2+ZxmBUL2vWKwKAjFENOqvYOKji+yjgj
         Z0oGMn5std35s2Nc+m6o35w6dBN0HwL/+qd4zMyW3NHyYDXDqB+pdoFPoOswbshlooXT
         0JeWM8+nwOCpm9VstD9W3csnY5OlW/uI/UcOxyb8BLYAd9rYSToV++k5t02bYuIZjZdI
         sXSn8XrW5cAint+q1aEX5xSix3faAwqPnHtkC6fRuVOe5Sb1V++3Va5OMYhx9NDalwpK
         vkbWdQiSfuF1n8QOTxPssH/pxsBTbg1GmYZQcIVDstrdX4aYVTI5RVVbkvH2mIegYe2P
         P4Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id s19si1365209vsl.400.2019.02.12.08.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:50:31 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id B1501CCF6D9D67A146C9;
	Wed, 13 Feb 2019 00:50:26 +0800 (CST)
Received: from j00421895-HPW10.huawei.com (10.202.226.61) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Wed, 13 Feb 2019 00:50:19 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <jonathan.cameron@huawei.com>, <linux-mm@kvack.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>
CC: <linuxarm@huawei.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>, Keith Busch <keith.busch@intel.com>, "Rafael J .
 Wysocki" <rjw@rjwysocki.net>, Michal Hocko <mhocko@kernel.org>,
	<jcm@redhat.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [PATCH 1/3] ACPI: Support Generic Initator only domains
Date: Tue, 12 Feb 2019 16:49:24 +0000
Message-ID: <20190212164926.202-2-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190212164926.202-1-Jonathan.Cameron@huawei.com>
References: <20190212164926.202-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Generic Initiators are a new ACPI concept that allows for
the description of proximity domains that contain a
device which performs memory access (such as a network card)
but neither host CPU nor memory.

This first patch has the parsing code and provides the
infrastructure for an architecture to associate these
new domains with their nearest memory possessing node.

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 drivers/acpi/numa.c            | 62 +++++++++++++++++++++++++++++++++-
 drivers/base/node.c            |  3 ++
 include/acpi/actbl3.h          | 37 +++++++++++++++++++-
 include/asm-generic/topology.h |  3 ++
 include/linux/nodemask.h       |  1 +
 include/linux/topology.h       |  7 ++++
 6 files changed, 111 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 7bbbf8256a41..890095794695 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -183,6 +183,38 @@ acpi_table_print_srat_entry(struct acpi_subtable_header *header)
 		}
 		break;
 
+	case ACPI_SRAT_TYPE_GENERIC_INITIATOR_AFFINITY:
+	{
+		struct acpi_srat_gi_affinity *p =
+			(struct acpi_srat_gi_affinity *)header;
+		char name[9] = {};
+
+		if (p->flags & ACPI_SRAT_GI_PCI_HANDLE) {
+			/*
+			 * For pci devices this may be the only place they
+			 * are assigned a proximity domain
+			 */
+			pr_debug("SRAT Generic Initiator(Seg:%u BDF:%u) in proximity domain %d %s\n",
+				p->pci_handle.segment,
+				p->pci_handle.bdf,
+				p->proximity_domain,
+				(p->flags & ACPI_SRAT_GI_ENABLED) ?
+				"enabled" : "disabled");
+		} else {
+			/*
+			 * In this case we can rely on the device having a
+			 * proximity domain reference
+			 */
+			memcpy(name, p->acpi_handle.hid, 8);
+			pr_info("SRAT Generic Initiator(HID=%s UID=%u) in proximity domain %d %s\n",
+				name,
+				p->acpi_handle.uid,
+				p->proximity_domain,
+				(p->flags & ACPI_SRAT_GI_ENABLED) ?
+				"enabled" : "disabled");
+		}
+	}
+	break;
 	default:
 		pr_warn("Found unsupported SRAT entry (type = 0x%x)\n",
 			header->type);
@@ -391,6 +423,32 @@ acpi_parse_gicc_affinity(struct acpi_subtable_header *header,
 	return 0;
 }
 
+static int __init
+acpi_parse_gi_affinity(struct acpi_subtable_header *header,
+		       const unsigned long end)
+{
+	struct acpi_srat_gi_affinity *gi_affinity;
+	int node;
+
+	gi_affinity = (struct acpi_srat_gi_affinity *)header;
+	if (!gi_affinity)
+		return -EINVAL;
+	acpi_table_print_srat_entry(header);
+
+	if (!(gi_affinity->flags & ACPI_SRAT_GI_ENABLED))
+		return EINVAL;
+
+	node = acpi_map_pxm_to_node(gi_affinity->proximity_domain);
+	if (node == NUMA_NO_NODE || node >= MAX_NUMNODES) {
+		pr_err("SRAT: Too many proximity domains.\n");
+		return -EINVAL;
+	}
+	node_set(node, numa_nodes_parsed);
+	node_set_state(node, N_GENERIC_INITIATOR);
+
+	return 0;
+}
+
 static int __initdata parsed_numa_memblks;
 
 static int __init
@@ -446,7 +504,7 @@ int __init acpi_numa_init(void)
 
 	/* SRAT: System Resource Affinity Table */
 	if (!acpi_table_parse(ACPI_SIG_SRAT, acpi_parse_srat)) {
-		struct acpi_subtable_proc srat_proc[3];
+		struct acpi_subtable_proc srat_proc[4];
 
 		memset(srat_proc, 0, sizeof(srat_proc));
 		srat_proc[0].id = ACPI_SRAT_TYPE_CPU_AFFINITY;
@@ -455,6 +513,8 @@ int __init acpi_numa_init(void)
 		srat_proc[1].handler = acpi_parse_x2apic_affinity;
 		srat_proc[2].id = ACPI_SRAT_TYPE_GICC_AFFINITY;
 		srat_proc[2].handler = acpi_parse_gicc_affinity;
+		srat_proc[3].id = ACPI_SRAT_TYPE_GENERIC_INITIATOR_AFFINITY;
+		srat_proc[3].handler = acpi_parse_gi_affinity;
 
 		acpi_table_parse_entries_array(ACPI_SIG_SRAT,
 					sizeof(struct acpi_table_srat),
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 86d6cd92ce3d..f59b9d4ca5d5 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -634,6 +634,8 @@ static struct node_attr node_state_attr[] = {
 #endif
 	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
 	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
+	[N_GENERIC_INITIATOR] = _NODE_ATTR(has_generic_initiator,
+					   N_GENERIC_INITIATOR),
 };
 
 static struct attribute *node_state_attrs[] = {
@@ -645,6 +647,7 @@ static struct attribute *node_state_attrs[] = {
 #endif
 	&node_state_attr[N_MEMORY].attr.attr,
 	&node_state_attr[N_CPU].attr.attr,
+	&node_state_attr[N_GENERIC_INITIATOR].attr.attr,
 	NULL
 };
 
diff --git a/include/acpi/actbl3.h b/include/acpi/actbl3.h
index ea1ca49c9c1b..35ea3f736697 100644
--- a/include/acpi/actbl3.h
+++ b/include/acpi/actbl3.h
@@ -190,7 +190,8 @@ enum acpi_srat_type {
 	ACPI_SRAT_TYPE_X2APIC_CPU_AFFINITY = 2,
 	ACPI_SRAT_TYPE_GICC_AFFINITY = 3,
 	ACPI_SRAT_TYPE_GIC_ITS_AFFINITY = 4,	/* ACPI 6.2 */
-	ACPI_SRAT_TYPE_RESERVED = 5	/* 5 and greater are reserved */
+	ACPI_SRAT_TYPE_GENERIC_INITIATOR_AFFINITY = 5, /* ACPI 6.3 */
+	ACPI_SRAT_TYPE_RESERVED = 6	/* 6 and greater are reserved */
 };
 
 /*
@@ -271,6 +272,40 @@ struct acpi_srat_gic_its_affinity {
 	u32 its_id;
 };
 
+/* Flags for struct acpi_srat_gi_affinity */
+
+#define ACPI_SRAT_GI_ENABLED     (1)		/* 00: Use affinity structure */
+#define ACPI_SRAT_GI_ACPI_HANDLE (0)		/* 01: */
+#define ACPI_SRAT_GI_PCI_HANDLE  (1 << 1)	/* 01: */
+
+/* Handles to associate the generic initiator with types of ACPI device */
+
+struct acpi_srat_gi_acpi_handle {
+	char hid[8];
+	u32 uid;
+	u32 reserved;
+};
+
+struct acpi_srat_gi_pci_handle {
+	u16 segment;
+	u16 bdf;
+	u8 reserved[12];
+};
+
+/* 5 : Generic Initiator Affinity (ACPI 6.3) */
+
+struct acpi_srat_gi_affinity {
+	struct acpi_subtable_header header;
+	u8 reserved;
+	u8 device_handl_type;
+	u32 proximity_domain;
+	union {
+		struct acpi_srat_gi_acpi_handle acpi_handle;
+		struct acpi_srat_gi_pci_handle pci_handle;
+	};
+	u32 flags;
+	u32 reserved2;
+};
 /*******************************************************************************
  *
  * STAO - Status Override Table (_STA override) - ACPI 6.0
diff --git a/include/asm-generic/topology.h b/include/asm-generic/topology.h
index 238873739550..54d0b4176a45 100644
--- a/include/asm-generic/topology.h
+++ b/include/asm-generic/topology.h
@@ -71,6 +71,9 @@
 #ifndef set_cpu_numa_mem
 #define set_cpu_numa_mem(cpu, node)
 #endif
+#ifndef set_gi_numa_mem
+#define set_gi_numa_mem(gi, node)
+#endif
 
 #endif	/* !CONFIG_NUMA || !CONFIG_HAVE_MEMORYLESS_NODES */
 
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 5a30ad594ccc..501b1d32b323 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -399,6 +399,7 @@ enum node_states {
 #endif
 	N_MEMORY,		/* The node has memory(regular, high, movable) */
 	N_CPU,		/* The node has one or more cpus */
+	N_GENERIC_INITIATOR,	/* The node is a GI only node */
 	NR_NODE_STATES
 };
 
diff --git a/include/linux/topology.h b/include/linux/topology.h
index cb0775e1ee4b..9d5f8501efcf 100644
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -125,6 +125,13 @@ static inline void set_numa_mem(int node)
 }
 #endif
 
+#ifndef set_gi_numa_mem
+static inline void set_gi_numa_mem(int gi, int node)
+{
+	_node_numa_mem_[gi] = node;
+}
+#endif
+
 #ifndef node_to_mem_node
 static inline int node_to_mem_node(int node)
 {
-- 
2.18.0


