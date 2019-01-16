Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6EC8E000A
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:59:43 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id d71so4363938pgc.1
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:59:43 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d18si6701527pgm.212.2019.01.16.09.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 09:59:42 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv4 09/13] acpi/hmat: Register performance attributes
Date: Wed, 16 Jan 2019 10:58:00 -0700
Message-Id: <20190116175804.30196-10-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-1-keith.busch@intel.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
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
 drivers/acpi/hmat/Kconfig |  1 +
 drivers/acpi/hmat/hmat.c  | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
index a4034d37a311..20a0e96ba58a 100644
--- a/drivers/acpi/hmat/Kconfig
+++ b/drivers/acpi/hmat/Kconfig
@@ -2,6 +2,7 @@
 config ACPI_HMAT
 	bool "ACPI Heterogeneous Memory Attribute Table Support"
 	depends on ACPI_NUMA
+	select HMEM_REPORTING
 	help
 	 Parses representation of the ACPI Heterogeneous Memory Attributes
 	 Table (HMAT) and set the memory node relationships and access
diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index efb33c74d1a3..45e20dc677f9 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
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
