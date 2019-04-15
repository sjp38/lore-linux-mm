Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23D97C10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:49:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CED3120848
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 17:49:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CED3120848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A74E6B0006; Mon, 15 Apr 2019 13:49:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 138646B0007; Mon, 15 Apr 2019 13:49:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEBDD6B0008; Mon, 15 Apr 2019 13:49:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id C21256B0007
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 13:49:47 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id r23so9464775ota.17
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 10:49:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ow+Ul3i0SMFqzj5C3FIRZsbVoU8F8je6HR5OyLi3CXo=;
        b=MGN9LJjiY2n+UYsR5GNoZTxoUVdUlZH1wh6ps29UvR4zh03j3YD0Vq5R55RLD43b3b
         r1K3yMIK4Zowi0p+bpw7j4vNGOV9LqlTmg9GV5bBHQ9BA4tKmP3E/CQVbqmseiw+zwAv
         4HzO4SLxh0kiutamhzieghKfr2YOsSTSAxPZMNt3OnEtD+t2+zfWEHxlZVNNRipLIaaE
         rIXyjMW1RET051MifHWPl5ff/ZyxNLaJaFcxP9LCePlV5KYkRq/7ZZLhdshIF8T0bbrf
         CcUtL4IyRXHzSm7J7rbtmeS48kZTIk6FCJa3m3l+kL0TOu24DOzxppaDuOfxj5cfAtqu
         4Gqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAV2tjPFvTmsOsW4ZSiAK1pKUClR5bAu8LF0TkLpp0sh1FH4Y5k3
	7bk8nAgec907BK1P9SgANrSZaF3Z3mrR5NCnpFMZT4KFYbiSOXERo4uMwYcCJcGxzKxa7c8DWt7
	P9XN2BXdliv1u9eFrU9OdItN2FamFFGlLiylBV69FDlVimRYfMvw84jsTEeI85W1goA==
X-Received: by 2002:aca:31c3:: with SMTP id x186mr19079085oix.131.1555350587355;
        Mon, 15 Apr 2019 10:49:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkqr93tUjLkeKWWoB8YCRDeX8T8Qg7+yeMHP/B7Q8stUF55YFCd+PMBzqLKeicyUO5XeFW
X-Received: by 2002:aca:31c3:: with SMTP id x186mr19079016oix.131.1555350585808;
        Mon, 15 Apr 2019 10:49:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555350585; cv=none;
        d=google.com; s=arc-20160816;
        b=E9eouDIiT14xus18BrkeLpH0zHdujZzrjhDuPTfzqsUQBPbz0Ts8Oe+vXJe/SYvs5L
         STh0OWlFCR3gFidcBnPFGSslcNKKwYVPagwqci6HeGEoqGjpP/SZRx+9LJN8SIL5i1xM
         aBnxyvGrsIh1uUUJNj5Tq14KndwuOkS/5aDOU+tiDJtjjekFRgDw/mblZKJ8w5RiPuXX
         fhaIUCs5+k1bqSQ68Aifylj8hLPnE1MUIv7BZxIC1JHB0Xh5Hl284fat/xfsT94KlBTr
         GuOp5xvTU2XRPBaEm27HciMtZgz2WwWDlLlGR0QP25hi/Tj4qpM2f3Wezfpc6K6FUjhu
         TYEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Ow+Ul3i0SMFqzj5C3FIRZsbVoU8F8je6HR5OyLi3CXo=;
        b=Zh8uCmRqClxkHaevhztIYh7zN3ZhtMMtTUBAOR38Pk26EIl2bvWzS050jYvMisKmIf
         uQqf2FJ4bqCQeMlLGmV5SYfUyJjQUsa3WMaDmhfrAHmIHex5DCuF41N7uEoSZBUdVzVf
         WTuB0aAdtf6rZbwAptohoaqxhLj8ASJBGzKeCjLCy7brTutiOyN8kGBJ4px93nIN2nOu
         z2Yr9nkXvF/roXsLutWbcl8Xh2j9OUU999RnDiERMZ+244cvLesPl/AkdQBZjzu3iflM
         8rfiJ3qiNf6SoMxF5Y+whwDEN6/7claQE5hIlYT+TPJBet50oecJpaXP4cbVZfubYixg
         GM3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id x64si22669062oig.54.2019.04.15.10.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 10:49:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id D55DD2A446898EE82B5D;
	Tue, 16 Apr 2019 01:49:41 +0800 (CST)
Received: from FRA1000014316.huawei.com (100.126.230.97) by
 DGGEMS401-HUB.china.huawei.com (10.3.19.201) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 01:49:34 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
CC: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Keith Busch
	<keith.busch@intel.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>,
	<linuxarm@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "Jonathan
 Cameron" <Jonathan.Cameron@huawei.com>
Subject: [PATCH 1/4 V3] ACPI: Support Generic Initiator only domains
Date: Tue, 16 Apr 2019 01:49:04 +0800
Message-ID: <20190415174907.102307-2-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190415174907.102307-1-Jonathan.Cameron@huawei.com>
References: <20190415174907.102307-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [100.126.230.97]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Generic Initiators are a new ACPI concept that allows for the
description of proximity domains that contain a device which
performs memory access (such as a network card) but neither
host CPU nor Memory.

This patch has the parsing code and provides the infrastructure
for an architecture to associate these new domains with their
nearest memory processing node.

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 drivers/acpi/numa.c            | 62 +++++++++++++++++++++++++++++++++-
 drivers/base/node.c            |  3 ++
 include/asm-generic/topology.h |  3 ++
 include/linux/nodemask.h       |  1 +
 include/linux/topology.h       |  7 ++++
 5 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 867f6e3f2b4f..b08ceea5e546 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -184,6 +184,38 @@ acpi_table_print_srat_entry(struct acpi_subtable_header *header)
 		}
 		break;
 
+	case ACPI_SRAT_TYPE_GENERIC_AFFINITY:
+	{
+		struct acpi_srat_generic_affinity *p =
+			(struct acpi_srat_generic_affinity *)header;
+		char name[9] = {};
+
+		if (p->device_handle_type == 0) {
+			/*
+			 * For pci devices this may be the only place they
+			 * are assigned a proximity domain
+			 */
+			pr_debug("SRAT Generic Initiator(Seg:%u BDF:%u) in proximity domain %d %s\n",
+				 *(u16 *)(&p->device_handle[0]),
+				 *(u16 *)(&p->device_handle[2]),
+				 p->proximity_domain,
+				 (p->flags & ACPI_SRAT_GENERIC_AFFINITY_ENABLED) ?
+				"enabled" : "disabled");
+		} else {
+			/*
+			 * In this case we can rely on the device having a
+			 * proximity domain reference
+			 */
+			memcpy(name, p->device_handle, 8);
+			pr_info("SRAT Generic Initiator(HID=%.8s UID=%.4s) in proximity domain %d %s\n",
+				(char *)(&p->device_handle[0]),
+				(char *)(&p->device_handle[8]),
+				p->proximity_domain,
+				(p->flags & ACPI_SRAT_GENERIC_AFFINITY_ENABLED) ?
+				"enabled" : "disabled");
+		}
+	}
+	break;
 	default:
 		pr_warn("Found unsupported SRAT entry (type = 0x%x)\n",
 			header->type);
@@ -392,6 +424,32 @@ acpi_parse_gicc_affinity(struct acpi_subtable_header *header,
 	return 0;
 }
 
+static int __init
+acpi_parse_gi_affinity(struct acpi_subtable_header *header,
+		       const unsigned long end)
+{
+	struct acpi_srat_generic_affinity *gi_affinity;
+	int node;
+
+	gi_affinity = (struct acpi_srat_generic_affinity *)header;
+	if (!gi_affinity)
+		return -EINVAL;
+	acpi_table_print_srat_entry(header);
+
+	if (!(gi_affinity->flags & ACPI_SRAT_GENERIC_AFFINITY_ENABLED))
+		return -EINVAL;
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
@@ -447,7 +505,7 @@ int __init acpi_numa_init(void)
 
 	/* SRAT: System Resource Affinity Table */
 	if (!acpi_table_parse(ACPI_SIG_SRAT, acpi_parse_srat)) {
-		struct acpi_subtable_proc srat_proc[3];
+		struct acpi_subtable_proc srat_proc[4];
 
 		memset(srat_proc, 0, sizeof(srat_proc));
 		srat_proc[0].id = ACPI_SRAT_TYPE_CPU_AFFINITY;
@@ -456,6 +514,8 @@ int __init acpi_numa_init(void)
 		srat_proc[1].handler = acpi_parse_x2apic_affinity;
 		srat_proc[2].id = ACPI_SRAT_TYPE_GICC_AFFINITY;
 		srat_proc[2].handler = acpi_parse_gicc_affinity;
+		srat_proc[3].id = ACPI_SRAT_TYPE_GENERIC_AFFINITY;
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
index 27e7fa36f707..1aebf766fb52 100644
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
2.19.1

