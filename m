Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 500F26B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:44:28 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n9RLiMiR032186
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 21:44:22 GMT
Received: from pwi18 (pwi18.prod.google.com [10.241.219.18])
	by wpaz13.hot.corp.google.com with ESMTP id n9RLiJDg005601
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:44:19 -0700
Received: by pwi18 with SMTP id 18so402891pwi.16
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:44:18 -0700 (PDT)
Date: Tue, 27 Oct 2009 14:44:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] acpi: remove NID_INVAL
In-Reply-To: <alpine.DEB.1.00.0910081325200.6998@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.0910271442250.30270@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162533.23192.71981.sendpatchset@localhost.localdomain> <alpine.DEB.1.10.0910081616040.8030@gentwo.org> <alpine.DEB.1.00.0910081325200.6998@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-numa@vger.kernel.org, Len Brown <lenb@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

NUMA_NO_NODE has been exported globally and thus it can replace NID_INVAL
in the acpi code.

Also removes the unused acpi_unmap_pxm_to_node() function.

Cc: Len Brown <lenb@kernel.org>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Depends on Lee Schermerhorn's hugetlb patchset in mmotm-10132113.

 drivers/acpi/numa.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -28,6 +28,7 @@
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/acpi.h>
+#include <linux/numa.h>
 #include <acpi/acpi_bus.h>
 
 #define PREFIX "ACPI: "
@@ -39,15 +40,15 @@ ACPI_MODULE_NAME("numa");
 static nodemask_t nodes_found_map = NODE_MASK_NONE;
 
 /* maps to convert between proximity domain and logical node ID */
-static int pxm_to_node_map[MAX_PXM_DOMAINS]
-				= { [0 ... MAX_PXM_DOMAINS - 1] = NID_INVAL };
+static int pxm_to_node_map[MAX_PXM_DOMAINS]				
+			= { [0 ... MAX_PXM_DOMAINS - 1] = NUMA_NO_NODE };
 static int node_to_pxm_map[MAX_NUMNODES]
-				= { [0 ... MAX_NUMNODES - 1] = PXM_INVAL };
+			= { [0 ... MAX_NUMNODES - 1] = PXM_INVAL };
 
 int pxm_to_node(int pxm)
 {
 	if (pxm < 0)
-		return NID_INVAL;
+		return NUMA_NO_NODE;
 	return pxm_to_node_map[pxm];
 }
 
@@ -68,9 +69,9 @@ int acpi_map_pxm_to_node(int pxm)
 {
 	int node = pxm_to_node_map[pxm];
 
-	if (node < 0){
+	if (node < 0) {
 		if (nodes_weight(nodes_found_map) >= MAX_NUMNODES)
-			return NID_INVAL;
+			return NUMA_NO_NODE;
 		node = first_unset_node(nodes_found_map);
 		__acpi_map_pxm_to_node(pxm, node);
 		node_set(node, nodes_found_map);
@@ -79,16 +80,6 @@ int acpi_map_pxm_to_node(int pxm)
 	return node;
 }
 
-#if 0
-void __cpuinit acpi_unmap_pxm_to_node(int node)
-{
-	int pxm = node_to_pxm_map[node];
-	pxm_to_node_map[pxm] = NID_INVAL;
-	node_to_pxm_map[node] = PXM_INVAL;
-	node_clear(node, nodes_found_map);
-}
-#endif  /*  0  */
-
 static void __init
 acpi_table_print_srat_entry(struct acpi_subtable_header *header)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
