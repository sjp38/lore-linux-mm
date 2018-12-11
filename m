Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 069E18E006F
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 20:05:53 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id c14so9416025pls.21
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 17:05:52 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si11402278pfj.276.2018.12.10.17.05.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 17:05:51 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 08/12] acpi/hmat: Register performance attributes
Date: Mon, 10 Dec 2018 18:03:06 -0700
Message-Id: <20181211010310.8551-9-keith.busch@intel.com>
In-Reply-To: <20181211010310.8551-1-keith.busch@intel.com>
References: <20181211010310.8551-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Save the best performance access attributes and register these with the
memory's node if HMAT provides the locality table.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/Kconfig |  1 +
 drivers/acpi/hmat.c  | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 9a05af3a18cf..6b5f6ca690af 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -330,6 +330,7 @@ config ACPI_NUMA
 config ACPI_HMAT
 	bool "ACPI Heterogeneous Memory Attribute Table Support"
 	depends on ACPI_NUMA
+	select HMEM_REPORTING
 	help
 	 Parses representation of the ACPI Heterogeneous Memory Attributes
 	 Table (HMAT) and set the memory node relationships and access
diff --git a/drivers/acpi/hmat.c b/drivers/acpi/hmat.c
index 5d8747ad025f..40bc83f4b593 100644
--- a/drivers/acpi/hmat.c
+++ b/drivers/acpi/hmat.c
@@ -23,6 +23,8 @@ struct memory_target {
 	struct list_head node;
 	unsigned int memory_pxm;
 	unsigned long p_nodes[BITS_TO_LONGS(MAX_NUMNODES)];
+	bool hmem_valid;
+	struct node_hmem_attrs hmem;
 };
 
 static __init struct memory_target *find_mem_target(unsigned int m)
@@ -108,6 +110,34 @@ static __init void hmat_update_access(u8 type, u32 value, u32 *best)
 	}
 }
 
+static __init void hmat_update_target(struct memory_target *t, u8 type,
+				      u32 value)
+{
+	switch (type) {
+	case ACPI_HMAT_ACCESS_LATENCY:
+		t->hmem.read_latency = value;
+		t->hmem.write_latency = value;
+		break;
+	case ACPI_HMAT_READ_LATENCY:
+		t->hmem.read_latency = value;
+		break;
+	case ACPI_HMAT_WRITE_LATENCY:
+		t->hmem.write_latency = value;
+		break;
+	case ACPI_HMAT_ACCESS_BANDWIDTH:
+		t->hmem.read_bandwidth = value;
+		t->hmem.write_bandwidth = value;
+		break;
+	case ACPI_HMAT_READ_BANDWIDTH:
+		t->hmem.read_bandwidth = value;
+		break;
+	case ACPI_HMAT_WRITE_BANDWIDTH:
+		t->hmem.write_bandwidth = value;
+		break;
+	}
+	t->hmem_valid = true;
+}
+
 static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 				      const unsigned long end)
 {
@@ -166,6 +196,8 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 					set_bit(p_node, t->p_nodes);
 			}
 		}
+		if (t && best)
+			hmat_update_target(t, type, best);
 	}
 	return 0;
 }
@@ -267,6 +299,8 @@ static __init void hmat_register_targets(void)
 		m = pxm_to_node(t->memory_pxm);
 		for_each_set_bit(p, t->p_nodes, MAX_NUMNODES)
 			register_memory_node_under_compute_node(m, p);
+		if (t->hmem_valid)
+			node_set_perf_attrs(m, &t->hmem);
 		kfree(t);
 	}
 }
-- 
2.14.4
