Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 455AA6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 17:11:47 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb12so1401201pbc.8
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 14:11:46 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH] x86/numa: Allow node distance table to have I/O nodes
Date: Tue, 15 Oct 2013 15:07:44 -0600
Message-Id: <1381871264-14070-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org, hpa@zytor.com, tglx@linutronix.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-pci@vger.kernel.org, yinghai@kernel.org, tj@kernel.org, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, Toshi Kani <toshi.kani@hp.com>

When a system has I/O devices (ex. PCI bridges) with their own
locality, the following error message shows up.

 NUMA: Warning: node ids are out of bound, from=-1 to=-1 distance=10

acpi_numa_slit_init() calls numa_set_distance(), which assumes
that all nodes on the system have been parsed with SRAT already.
However, SRAT does not list I/O devices.  SLIT has the distance
table for all localities including I/Os.  Hence, the above message
shows up when a system has a unique I/O device locality.

This patch changes acpi_numa_slit_init() to make sure all the
nodes are parsed, so that it can initialize the distance table
with all the localities.

The following map tables may contain I/O nodes as a result.
 - numa_distance[], i.e. node distance table
 - node_states[N_POSSIBLE], aka. node_possible_map
 - mp_bus_to_node[], i.e. pci bus# to node# map

There is no functional change since there is no code that makes
use of the I/O nodes.
 - I/O nodes are set to off-line.
 - pci_acpi_scan_root() continues to set -1 to pci_sysdata.node
   of a PCI bridge with a unique locality (per commit b755de8d).

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/mm/srat.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index 26f4e12..fb5bd73 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -45,7 +45,20 @@ static __init inline int srat_disabled(void)
 /* Callback for SLIT parsing */
 void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 {
-	int i, j;
+	int node, i, j;
+
+	/* SLIT may have I/O nodes, which are not listed in SRAT */
+	for (i = 0; i < slit->locality_count; i++) {
+		if (pxm_to_node(i) != NUMA_NO_NODE)
+			continue;
+
+		node = setup_node(i);
+		if (WARN_ONCE(node < 0, "SLIT: Too many proximity domains.\n"))
+			continue;
+
+		node_set(node, numa_nodes_parsed);
+		pr_info("SLIT: Node %u PXM %u I/O only\n", node, i);
+	}
 
 	for (i = 0; i < slit->locality_count; i++)
 		for (j = 0; j < slit->locality_count; j++)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
