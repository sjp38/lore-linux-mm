Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 13F845F0017
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:20:11 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 19/25] Do not setup zonelist cache when there is only one node
Date: Mon, 20 Apr 2009 23:20:05 +0100
Message-Id: <1240266011-11140-20-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

There is a zonelist cache which is used to track zones that are not in
the allowed cpuset or found to be recently full. This is to reduce cache
footprint on large machines. On smaller machines, it just incurs cost
for no gain. This patch only uses the zonelist cache when there are NUMA
nodes.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
---
 mm/page_alloc.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bf4b8d9..ec01d8f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1440,6 +1440,8 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	/* Determine in advance if the zonelist needs filtering */
 	if ((alloc_flags & ALLOC_CPUSET) && unlikely(number_of_cpusets > 1))
 		zonelist_filter = 1;
+	if (num_online_nodes() > 1)
+		zonelist_filter = 1;
 
 zonelist_scan:
 	/*
@@ -1484,8 +1486,12 @@ this_zone_full:
 			zlc_mark_zone_full(zonelist, z);
 try_next_zone:
 		if (NUMA_BUILD && zonelist_filter) {
-			if (!did_zlc_setup) {
-				/* do zlc_setup after the first zone is tried */
+			if (!did_zlc_setup && num_online_nodes() > 1) {
+				/*
+				 * do zlc_setup after the first zone is tried
+				 * but only if there are multiple nodes to make
+				 * it worthwhile
+				 */
 				allowednodes = zlc_setup(zonelist, alloc_flags);
 				zlc_active = 1;
 			}
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
