From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/2] x86: cope with no remap space being allocated for a numa node
References: <exportbomb.1211277639@pinky>
Date: Tue, 20 May 2008 11:01:19 +0100
Message-Id: <1211277679.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When allocating the pgdat's for numa nodes on x86_32 we attempt to
place them in the numa remap space for that node.  However should
the node not have any remap space allocated (such as due to having
non-ram pages in the remap location in the node) then we will
incorrectly place the pgdat at zero.  Check we have remap available,
falling back to node 0 memory where we do not.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 arch/x86/mm/discontig_32.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)
diff --git a/arch/x86/mm/discontig_32.c b/arch/x86/mm/discontig_32.c
index 026201f..435c343 100644
--- a/arch/x86/mm/discontig_32.c
+++ b/arch/x86/mm/discontig_32.c
@@ -156,7 +156,7 @@ static void __init propagate_e820_map_node(int nid)
  */
 static void __init allocate_pgdat(int nid)
 {
-	if (nid && node_has_online_mem(nid))
+	if (nid && node_has_online_mem(nid) && node_remap_start_vaddr[nid])
 		NODE_DATA(nid) = (pg_data_t *)node_remap_start_vaddr[nid];
 	else {
 		NODE_DATA(nid) = (pg_data_t *)(pfn_to_kaddr(min_low_pfn));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
