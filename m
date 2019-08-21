Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A51B4C3A5A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:53:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6776622DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:53:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6776622DA7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 589116B02C4; Wed, 21 Aug 2019 10:53:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 512256B02C5; Wed, 21 Aug 2019 10:53:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38BC56B02C6; Wed, 21 Aug 2019 10:53:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0061.hostedemail.com [216.40.44.61])
	by kanga.kvack.org (Postfix) with ESMTP id 11C096B02C4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:53:18 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B310C181B0486
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:53:17 +0000 (UTC)
X-FDA: 75846728034.16.scale41_1ca6ca7ab0f2b
X-HE-Tag: scale41_1ca6ca7ab0f2b
X-Filterd-Recvd-Size: 7272
Received: from huawei.com (szxga05-in.huawei.com [45.249.212.191])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:53:16 +0000 (UTC)
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id A73F3D22D9709479EC69;
	Wed, 21 Aug 2019 22:53:11 +0800 (CST)
Received: from lhrphicprd00229.huawei.com (10.123.41.22) by
 DGGEMS407-HUB.china.huawei.com (10.3.19.207) with Microsoft SMTP Server id
 14.3.439.0; Wed, 21 Aug 2019 22:53:01 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
CC: Keith Busch <keith.busch@intel.com>, <jglisse@redhat.com>, "Rafael J .
 Wysocki" <rjw@rjwysocki.net>, <linuxarm@huawei.com>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [PATCH 1/4] ACPI: Support Generic Initiator only domains
Date: Wed, 21 Aug 2019 22:52:39 +0800
Message-ID: <20190821145242.2330-2-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190821145242.2330-1-Jonathan.Cameron@huawei.com>
References: <20190821145242.2330-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.123.41.22]
X-CFilter-Loop: Reflected
Content-Transfer-Encoding: quoted-printable
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
index eadbf90e65d1..fe34315a9234 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -170,6 +170,38 @@ acpi_table_print_srat_entry(struct acpi_subtable_hea=
der *header)
 		}
 		break;
=20
+	case ACPI_SRAT_TYPE_GENERIC_AFFINITY:
+	{
+		struct acpi_srat_generic_affinity *p =3D
+			(struct acpi_srat_generic_affinity *)header;
+		char name[9] =3D {};
+
+		if (p->device_handle_type =3D=3D 0) {
+			/*
+			 * For pci devices this may be the only place they
+			 * are assigned a proximity domain
+			 */
+			pr_debug("SRAT Generic Initiator(Seg:%u BDF:%u) in proximity domain %=
d %s\n",
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
+			pr_info("SRAT Generic Initiator(HID=3D%.8s UID=3D%.4s) in proximity d=
omain %d %s\n",
+				(char *)(&p->device_handle[0]),
+				(char *)(&p->device_handle[8]),
+				p->proximity_domain,
+				(p->flags & ACPI_SRAT_GENERIC_AFFINITY_ENABLED) ?
+				"enabled" : "disabled");
+		}
+	}
+	break;
 	default:
 		pr_warn("Found unsupported SRAT entry (type =3D 0x%x)\n",
 			header->type);
@@ -378,6 +410,32 @@ acpi_parse_gicc_affinity(union acpi_subtable_headers=
 *header,
 	return 0;
 }
=20
+static int __init
+acpi_parse_gi_affinity(union acpi_subtable_headers *header,
+		       const unsigned long end)
+{
+	struct acpi_srat_generic_affinity *gi_affinity;
+	int node;
+
+	gi_affinity =3D (struct acpi_srat_generic_affinity *)header;
+	if (!gi_affinity)
+		return -EINVAL;
+	acpi_table_print_srat_entry(&header->common);
+
+	if (!(gi_affinity->flags & ACPI_SRAT_GENERIC_AFFINITY_ENABLED))
+		return -EINVAL;
+
+	node =3D acpi_map_pxm_to_node(gi_affinity->proximity_domain);
+	if (node =3D=3D NUMA_NO_NODE || node >=3D MAX_NUMNODES) {
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
=20
 static int __init
@@ -433,7 +491,7 @@ int __init acpi_numa_init(void)
=20
 	/* SRAT: System Resource Affinity Table */
 	if (!acpi_table_parse(ACPI_SIG_SRAT, acpi_parse_srat)) {
-		struct acpi_subtable_proc srat_proc[3];
+		struct acpi_subtable_proc srat_proc[4];
=20
 		memset(srat_proc, 0, sizeof(srat_proc));
 		srat_proc[0].id =3D ACPI_SRAT_TYPE_CPU_AFFINITY;
@@ -442,6 +500,8 @@ int __init acpi_numa_init(void)
 		srat_proc[1].handler =3D acpi_parse_x2apic_affinity;
 		srat_proc[2].id =3D ACPI_SRAT_TYPE_GICC_AFFINITY;
 		srat_proc[2].handler =3D acpi_parse_gicc_affinity;
+		srat_proc[3].id =3D ACPI_SRAT_TYPE_GENERIC_AFFINITY;
+		srat_proc[3].handler =3D acpi_parse_gi_affinity;
=20
 		acpi_table_parse_entries_array(ACPI_SIG_SRAT,
 					sizeof(struct acpi_table_srat),
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 75b7e6f6535b..6f60689af5f8 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -980,6 +980,8 @@ static struct node_attr node_state_attr[] =3D {
 #endif
 	[N_MEMORY] =3D _NODE_ATTR(has_memory, N_MEMORY),
 	[N_CPU] =3D _NODE_ATTR(has_cpu, N_CPU),
+	[N_GENERIC_INITIATOR] =3D _NODE_ATTR(has_generic_initiator,
+					   N_GENERIC_INITIATOR),
 };
=20
 static struct attribute *node_state_attrs[] =3D {
@@ -991,6 +993,7 @@ static struct attribute *node_state_attrs[] =3D {
 #endif
 	&node_state_attr[N_MEMORY].attr.attr,
 	&node_state_attr[N_CPU].attr.attr,
+	&node_state_attr[N_GENERIC_INITIATOR].attr.attr,
 	NULL
 };
=20
diff --git a/include/asm-generic/topology.h b/include/asm-generic/topolog=
y.h
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
=20
 #endif	/* !CONFIG_NUMA || !CONFIG_HAVE_MEMORYLESS_NODES */
=20
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
=20
diff --git a/include/linux/topology.h b/include/linux/topology.h
index 47a3e3c08036..2f97754e0508 100644
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -125,6 +125,13 @@ static inline void set_numa_mem(int node)
 }
 #endif
=20
+#ifndef set_gi_numa_mem
+static inline void set_gi_numa_mem(int gi, int node)
+{
+	_node_numa_mem_[gi] =3D node;
+}
+#endif
+
 #ifndef node_to_mem_node
 static inline int node_to_mem_node(int node)
 {
--=20
2.20.1


