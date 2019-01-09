Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF98C8E00A6
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:48:01 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 82so5732792pfs.20
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:48:01 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c10si25675731pla.173.2019.01.09.09.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 09:48:00 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 09/13] acpi/hmat: Register performance attributes
Date: Wed,  9 Jan 2019 10:43:37 -0700
Message-Id: <20190109174341.19818-10-keith.busch@intel.com>
In-Reply-To: <20190109174341.19818-1-keith.busch@intel.com>
References: <20190109174341.19818-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Save the best performace access attributes and register these with the
memory's node if HMAT provides the locality table. While HMAT does make
it possible to know performance for all possible initiator-target
pairings, we export only the best pairings at this time.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/Kconfig |  1 +
 drivers/acpi/hmat.c  | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index b102d9f544ee..ac6c38b50916 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -329,6 +329,7 @@ config ACPI_NUMA
 config ACPI_HMAT
 	bool "ACPI Heterogeneous Memory Attribute Table Support"
 	depends on ACPI_NUMA
+	select HMEM_REPORTING
 	help
 	 Parses representation of the ACPI Heterogeneous Memory Attributes
 	 Table (HMAT) and set the memory node relationships and access
diff --git a/drivers/acpi/hmat.c b/drivers/acpi/hmat.c
index efb33c74d1a3..45e20dc677f9 100644
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
 			register_memory_node_under_compute_node(m, p, 0);
+		if (t->hmem_valid)
+			node_set_perf_attrs(m, &t->hmem, 0);
 		kfree(t);
 	}
 }
-- 
2.14.4
