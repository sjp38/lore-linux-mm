From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 01/23 V2] node_states: introduce N_MEMORY
Date: Thu, 2 Aug 2012 10:52:49 +0800
Message-ID: <1343875991-7533-2-git-send-email-laijs@cn.fujitsu.com>
References: <1343875991-7533-1-git-send-email-laijs@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1343875991-7533-1-git-send-email-laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Cc: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Dan Magenheimer <dan.magenheimer-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>, Konstantin Khlebnikov <khlebnikov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>, Gavin Shan <shangw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Petr Holasek <pholasek-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Wanlong Gao <gaowanlong-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Djalal Harouni <tixxdz-Umm1ozX2/EEdnm+yROfE0A@public.gmane.org>, Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>, Wen Congyang <wency-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Peter Zijlstra <a.p.zijlstra@ch>
List-Id: linux-mm.kvack.org

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

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/nodemask.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

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
1.7.1
