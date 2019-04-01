Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4E3CC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 15:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7002820880
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 15:37:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7002820880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F03C66B0008; Mon,  1 Apr 2019 11:37:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB3CE6B000A; Mon,  1 Apr 2019 11:37:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA4F86B000C; Mon,  1 Apr 2019 11:37:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id B11766B0008
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 11:37:08 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id x125so3387111oix.17
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 08:37:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q/Qp6e3Y47/ec4t5XibYLYOHUAFkRkk0CokhGTNSJZg=;
        b=DJFKByN/1lcgG/2OG3/i2rQXFWjyk98wjDZcNMknfo+RseAJn71btzZjKc0McoMJX3
         DTJekjeI5gW3AVmnbPratxYz7XROKRIZVjDAGOUaZKou6lNFsn2O4q2AkSMqnEuI0fmn
         7NQzYhm/YiSWQD6qGMcAf8ZUrsjWpwIwN7a0JaAVOAYstARJNU3kvKQxTDjHZqLFo+hd
         U0SePAVUTq7FZ9H68vLXCyb5PCu6ZAsA3kSCMsvAA60YzQlMm4/HJA/odGrIfK1GzPei
         4/XDlpf8TGjUnd10M/MESJiduYOBypK6jshDVSRWVKSOFV2j/kGN9OiyhsIYSJV/k1iM
         6CZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAW/XD43ipwvO5mHhWzuGBzDujfx9f6t57273veVAO6m0qs0wX6N
	rQCtEJ4sqZoUbSvqdp36zuaDYGZaeyAkGs8qedFjyKEBTur+S0UK6CiZQ6fGzY39tj0OcFD9DbR
	bvWY96BxxuZxHFYMuoFbeOH+CPCysovW8J3cwQRZ1M2+QH91d2tXrcBuLCFkA+d4bug==
X-Received: by 2002:a9d:3e02:: with SMTP id a2mr45956969otd.232.1554133028421;
        Mon, 01 Apr 2019 08:37:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypZiiZ//BW3Lt6wXVC+ySt/i+ZM7VhnG0YXkZsGGJJ8z6JXsR2VpGPHHsYbw9sJFGa2Xiz
X-Received: by 2002:a9d:3e02:: with SMTP id a2mr45956871otd.232.1554133027110;
        Mon, 01 Apr 2019 08:37:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554133027; cv=none;
        d=google.com; s=arc-20160816;
        b=G0hzhrcvF5PomjGc6yRFom6tzTEOsFhhHrSo5HotjzDVkCNnVW4ZPWTOoijaTQfOuK
         tTxOsIwV7NZheUeMHJZKmIZtu3yXtx6Jy8tFPuWQc6FWgcmts1xVOAUve2tdFxiGcHeq
         hF1FaYJJ9eTFLFr4qoY2ZncZt6vUoBBKmaENw40cjWodW0+fBy58KQPd4UXR6n6jBV9e
         8SLgp5Vo4L/UMU2dpAasRrzGVtoDN2iciq+PejSe7dLXA9YqRMhuaq1AtOxyTOu96WsG
         soTHrhWS0je3TaEthL/xgfqmg2pFkcxHNJB3teWOHU8NEP/uE7zC7acFTTjpL7wNytAc
         cl7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=q/Qp6e3Y47/ec4t5XibYLYOHUAFkRkk0CokhGTNSJZg=;
        b=p1aiG9tFFMye25gnGw4C9BRKnrBrfgDOpk1461UZmFnFnxA83FPYo9J1PoNbPZOWn6
         ub7haRNxrd3diGteaa6dRhXKdU+mpZ7i3IfK01ufWCqa8zqbYcyqq3rn6CtMlz8KtsgT
         6xlNw6LFsvTehhU1pvB5uHr7msnKKcjrmdWfHNmq0Dq9IBHeCjQxXconA8VVSUGGfeX8
         WTO7K4UdqowKjcd6bMYAUZjPovvxtzIgdkh12ffa38V3hd1y10bV0VyyGXlKq/GlATkM
         TQWYd+tyLx4yqk4jpjSyNPRO07R80/RI7fUQX+YzxHjtpqJ2zq7+OnGaKPwbZPJ92PeA
         v+GA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id j26si1539566otl.261.2019.04.01.08.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 08:37:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [10.3.19.214])
	by Forcepoint Email with ESMTP id 771D277821093E355E4C;
	Mon,  1 Apr 2019 23:37:01 +0800 (CST)
Received: from FRA1000014316.huawei.com (100.126.230.97) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Mon, 1 Apr 2019 23:36:50 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
CC: <rjw@rjwysocki.net>, <keith.busch@intel.com>, <linuxarm@huawei.com>,
	<jglisse@redhat.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [RFC PATCH v2 1/3] ACPI: Support Generic Initiator only domains
Date: Mon, 1 Apr 2019 23:36:01 +0800
Message-ID: <20190401153603.67775-2-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190401153603.67775-1-Jonathan.Cameron@huawei.com>
References: <20190401153603.67775-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [100.126.230.97]
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
2.18.0

