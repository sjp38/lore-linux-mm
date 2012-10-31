Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 97D9F6B006E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 03:58:29 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART3 Patch 01/14] node_states: introduce N_MEMORY
Date: Wed, 31 Oct 2012 16:03:59 +0800
Message-Id: <1351670652-9932-2-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351670652-9932-1-git-send-email-wency@cn.fujitsu.com>
References: <1351670652-9932-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

We have N_NORMAL_MEMORY for standing for the nodes that have normal memory with
zone_type <= ZONE_NORMAL.

And we have N_HIGH_MEMORY for standing for the nodes that have normal or high
memory.

But we don't have any word to stand for the nodes that have *any* memory.

And we have N_CPU but without N_MEMORY.

Current code reuse the N_HIGH_MEMORY for this purpose because any node which
has memory must have high memory or normal memory currently.

A)	But this reusing is bad for *readability*. Because the name
	N_HIGH_MEMORY just stands for high or normal:

A.example 1)
	mem_cgroup_nr_lru_pages():
		for_each_node_state(nid, N_HIGH_MEMORY)

	The user will be confused(why this function just counts for high or
	normal memory node? does it counts for ZONE_MOVABLE's lru pages?)
	until someone else tell them N_HIGH_MEMORY is reused to stand for
	nodes that have any memory.

A.cont) If we introduce N_MEMORY, we can reduce this confusing
	AND make the code more clearly:

A.example 2) mm/page_cgroup.c use N_HIGH_MEMORY twice:

	One is in page_cgroup_init(void):
		for_each_node_state(nid, N_HIGH_MEMORY) {

	It means if the node have memory, we will allocate page_cgroup map for
	the node. We should use N_MEMORY instead here to gaim more clearly.

	The second using is in alloc_page_cgroup():
		if (node_state(nid, N_HIGH_MEMORY))
			addr = vzalloc_node(size, nid);

	It means if the node has high or normal memory that can be allocated
	from kernel. We should keep N_HIGH_MEMORY here, and it will be better
	if the "any memory" semantic of N_HIGH_MEMORY is removed.

B)	This reusing is out-dated if we introduce MOVABLE-dedicated node.
	The MOVABLE-dedicated node should not appear in
	node_stats[N_HIGH_MEMORY] nor node_stats[N_NORMAL_MEMORY],
	because MOVABLE-dedicated node has no high or normal memory.

	In x86_64, N_HIGH_MEMORY=N_NORMAL_MEMORY, if a MOVABLE-dedicated node
	is in node_stats[N_HIGH_MEMORY], it is also means it is in
	node_stats[N_NORMAL_MEMORY], it causes SLUB wrong.

	The slub uses
		for_each_node_state(nid, N_NORMAL_MEMORY)
	and creates kmem_cache_node for MOVABLE-dedicated node and cause problem.

In one word, we need a N_MEMORY. We just intrude it as an alias to
N_HIGH_MEMORY and fix all im-proper usages of N_HIGH_MEMORY in late patches.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Hillf Danton <dhillf@gmail.com>
---
 include/linux/nodemask.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 7afc363..c6ebdc9 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -380,6 +380,7 @@ enum node_states {
 #else
 	N_HIGH_MEMORY = N_NORMAL_MEMORY,
 #endif
+	N_MEMORY = N_HIGH_MEMORY,
 	N_CPU,		/* The node has one or more cpus */
 	NR_NODE_STATES
 };
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
