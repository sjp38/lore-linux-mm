Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 082BF6B0062
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 02:00:58 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 06/23 V2] mempolicy: use N_MEMORY instead N_HIGH_MEMORY
Date: Thu, 2 Aug 2012 14:01:11 +0800
Message-Id: <1343887288-8866-7-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
References: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

N_HIGH_MEMORY stands for the nodes that has normal or high memory.
N_MEMORY stands for the nodes that has any memory.

The code here need to handle with the nodes which have memory, we should
use N_MEMORY instead.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/mempolicy.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1d771e4..ad0381d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -212,9 +212,9 @@ static int mpol_set_nodemask(struct mempolicy *pol,
 	/* if mode is MPOL_DEFAULT, pol is NULL. This is right. */
 	if (pol == NULL)
 		return 0;
-	/* Check N_HIGH_MEMORY */
+	/* Check N_MEMORY */
 	nodes_and(nsc->mask1,
-		  cpuset_current_mems_allowed, node_states[N_HIGH_MEMORY]);
+		  cpuset_current_mems_allowed, node_states[N_MEMORY]);
 
 	VM_BUG_ON(!nodes);
 	if (pol->mode == MPOL_PREFERRED && nodes_empty(*nodes))
@@ -1363,7 +1363,7 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 		goto out_put;
 	}
 
-	if (!nodes_subset(*new, node_states[N_HIGH_MEMORY])) {
+	if (!nodes_subset(*new, node_states[N_MEMORY])) {
 		err = -EINVAL;
 		goto out_put;
 	}
@@ -2314,7 +2314,7 @@ void __init numa_policy_init(void)
 	 * fall back to the largest node if they're all smaller.
 	 */
 	nodes_clear(interleave_nodes);
-	for_each_node_state(nid, N_HIGH_MEMORY) {
+	for_each_node_state(nid, N_MEMORY) {
 		unsigned long total_pages = node_present_pages(nid);
 
 		/* Preserve the largest node */
@@ -2395,7 +2395,7 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 		*nodelist++ = '\0';
 		if (nodelist_parse(nodelist, nodes))
 			goto out;
-		if (!nodes_subset(nodes, node_states[N_HIGH_MEMORY]))
+		if (!nodes_subset(nodes, node_states[N_MEMORY]))
 			goto out;
 	} else
 		nodes_clear(nodes);
@@ -2429,7 +2429,7 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 		 * Default to online nodes with memory if no nodelist
 		 */
 		if (!nodelist)
-			nodes = node_states[N_HIGH_MEMORY];
+			nodes = node_states[N_MEMORY];
 		break;
 	case MPOL_LOCAL:
 		/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
