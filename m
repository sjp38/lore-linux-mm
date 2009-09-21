Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2903D6B0157
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 12:10:29 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/3] powerpc: Allocate per-cpu areas for node IDs for SLQB to use as per-node areas
Date: Mon, 21 Sep 2009 17:10:24 +0100
Message-Id: <1253549426-917-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

SLQB uses DEFINE_PER_CPU to define per-node areas. An implicit
assumption is made that all valid node IDs will have matching valid CPU
ids. In memoryless configurations, it is possible to have a node ID with
no CPU having the same ID. When this happens, a per-cpu are is not
created and the value of paca[cpu].data_offset is some random value.
This is later deferenced and the system crashes after accessing some
invalid address.

This patch hacks powerpc to allocate per-cpu areas for node IDs that
have no corresponding CPU id. This gets around the immediate problem but
it should be discussed if there is a requirement for a DEFINE_PER_NODE
and how it should be implemented.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 arch/powerpc/kernel/setup_64.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 1f68160..a5f52d4 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -588,6 +588,26 @@ void __init setup_per_cpu_areas(void)
 		paca[i].data_offset = ptr - __per_cpu_start;
 		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
 	}
+#ifdef CONFIG_SLQB
+	/* 
+	 * SLQB abuses DEFINE_PER_CPU to setup a per-node area. This trick
+	 * assumes that ever node ID will have a CPU of that ID to match.
+	 * On systems with memoryless nodes, this may not hold true. Hence,
+	 * we take a second pass initialising a "per-cpu" area for node-ids
+	 * that SLQB can use
+	 */
+	for_each_node_state(i, N_NORMAL_MEMORY) {
+
+		/* Skip node IDs that a valid CPU id exists for */
+		if (paca[i].data_offset)
+			continue;
+
+		ptr = alloc_bootmem_pages_node(NODE_DATA(cpu_to_node(i)), size);
+
+		paca[i].data_offset = ptr - __per_cpu_start;
+		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
+	}
+#endif /* CONFIG_SLQB */
 }
 #endif
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
