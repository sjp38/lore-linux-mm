Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7914E6B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 22:46:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EB8123EE0BD
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:45:59 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CD18B45DE92
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:45:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B327445DE77
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:45:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A5682E08001
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:45:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 655621DB8037
	for <linux-mm@kvack.org>; Fri, 27 May 2011 11:45:59 +0900 (JST)
Date: Fri, 27 May 2011 11:39:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv4] memcg: reclaim memory from node in round-robin
Message-Id: <20110527113907.8eafe906.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110527085440.71035539.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110427165120.a60c6609.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinx+4zXaO3rhHRUzr3m-K-2_NMTQw@mail.gmail.com>
	<20110428093513.5a6970c0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110428103705.a284df87.nishimura@mxp.nes.nec.co.jp>
	<20110428104912.6f86b2ee.kamezawa.hiroyu@jp.fujitsu.com>
	<20110504142623.8aa3bddb.akpm@linux-foundation.org>
	<20110506151302.a7256987.kamezawa.hiroyu@jp.fujitsu.com>
	<20110526125207.e02e5775.akpm@linux-foundation.org>
	<20110527085440.71035539.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Fri, 27 May 2011 08:54:40 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 26 May 2011 12:52:07 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Fri, 6 May 2011 15:13:02 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > > It would be much better to work out the optimum time at which to rotate
> > > > the index via some deterministic means.
> > > > 
> > > > If we can't think of a way of doing that then we should at least pace
> > > > the rotation frequency via something saner than wall-time.  Such as
> > > > number-of-pages-scanned.
> > > > 
> > > 
> > > 
> > > What I think now is using reclaim_stat or usigng some fairness based on
> > > the ratio of inactive file caches. We can calculate the total sum of
> > > recalaim_stat which gives us a scan_ratio for a whole memcg. And we can
> > > calculate LRU rotate/scan ratio per node. If rotate/scan ratio is small,
> > > it will be a good candidate of reclaim target. Hmm,
> > > 
> > >   - check which memory(anon or file) should be scanned.
> > >     (If file is too small, rotate/scan ratio of file is meaningless.)
> > >   - check rotate/scan ratio of each nodes.
> > >   - calculate weights for each nodes (by some logic ?)
> > >   - give a fair scan w.r.t node's weight.
> > > 
> > > Hmm, I'll have a study on this.
> > 
> > How's the study coming along ;)
> > 
> > I'll send this in to Linus today, but I'll feel grumpy while doing so. 
> > We really should do something smarter here - the magic constant will
> > basically always be suboptimal for everyone and we end up tweaking its
> > value (if we don't, then the feature just wasn't valuable in the first
> > place) and then we add a tunable and then people try to tweak the
> > default setting of the tunable and then I deride them for not setting
> > the tunable in initscripts and then we have to maintain the stupid
> > tunable after we've changed the internal implementation and it's all
> > basically screwed up.
> > 
> > How to we automatically determine the optimum time at which to rotate,
> > at runtime?
> > 
> 
> Ah, I think I should check it after dirty page accounting comes...because
> ratio of dirty pages is an important information..
> 
> Ok, what I think now is just comparing the number of INACTIVE_FILE or the number
> of FILE CACHES per node. 
> 
> I think we can periodically update per-node and total amount of file caches
> and we can record per-node 
>    node-file-cache * 100/ total-file cache
> information into memcg's per-node structure.
> 

Hmmm..something like this ?
==
This will not be able to be applied mmotm directly.
This patch is made from tons of magic numbers....I need more study
and will be able to write a simple one.

At first, mem_cgroup can reclaim memory from anywhere, it just checks
amount of memory. Now, victim node to be reclaimed is just determined
by round-robin.

This patch adds a scheduler simliar to a weighted fair share scanning
among nodes. Now, we periodically update mem->scan_nodes to know
which node has evictable memory. This patch gathers more information.

This patch caluculate "weight" of node as

	(nr_inactive_file + nr_active_file/10) * (200-swappiness)
        + (nr_inactive_anon) * (swappiness)
	(see vmscan.c::get_scan_count() for meaning of swappiness)

And select some nodes in a fair way proportional to the weight.
selected nodes are cached into mem->victim_nodes, victime_nodes
will be visited in round robin.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  102 ++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 84 insertions(+), 18 deletions(-)

Index: memcg_async/mm/memcontrol.c
===================================================================
--- memcg_async.orig/mm/memcontrol.c
+++ memcg_async/mm/memcontrol.c
@@ -48,6 +48,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/random.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -149,6 +150,7 @@ struct mem_cgroup_per_zone {
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
 
 struct mem_cgroup_per_node {
+	u64 scan_weight;
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
 };
 
@@ -257,6 +259,7 @@ struct mem_cgroup {
 	int last_scanned_node;
 #if MAX_NUMNODES > 1
 	nodemask_t	scan_nodes;
+	nodemask_t	victim_nodes;
 	unsigned long   next_scan_node_update;
 #endif
 	/*
@@ -1732,9 +1735,21 @@ u64 mem_cgroup_get_limit(struct mem_cgro
  * nodes based on the zonelist. So update the list loosely once per 10 secs.
  *
  */
+
+/*
+ * This is for selecting a victim node with lottery proportional share
+ * scheduling. This LOTTEY value can be arbitrary but must be higher
+ * than max number of nodes.
+ */
+#define NODE_SCAN_LOTTERY	(1 << 15)
+#define NODE_SCAN_LOTTERY_MASK	(NODE_SCAN_LOTTERY - 1)
+
 static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem, bool force)
 {
 	int nid;
+	u64 total_weight;
+	unsigned long swappiness;
+	int nr_selection;
 
 	if (!force && time_after(mem->next_scan_node_update, jiffies))
 		return;
@@ -1742,18 +1757,77 @@ static void mem_cgroup_may_update_nodema
 	mem->next_scan_node_update = jiffies + 10*HZ;
 	/* make a nodemask where this memcg uses memory from */
 	mem->scan_nodes = node_states[N_HIGH_MEMORY];
+	nodes_clear(mem->victim_nodes);
+
+	swappiness = mem_cgroup_swappiness(mem);
+	total_weight = 0;
 
 	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
+		u64 val, file_weight, anon_weight, pages;
+		int lru;
 
-		if (mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_FILE) ||
-		    mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_FILE))
-			continue;
+		lru = LRU_INACTIVE_FILE;
+		val = mem_cgroup_get_zonestat_node(mem, nid, lru);
+		file_weight = val;
+		pages = val;
 
-		if (total_swap_pages &&
-		    (mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_ANON) ||
-		     mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_ANON)))
-			continue;
-		node_clear(nid, mem->scan_nodes);
+		lru = LRU_ACTIVE_FILE;
+		val = mem_cgroup_get_zonestat_node(mem, nid, lru);
+		/*
+		 * This is a magic calculation. We add 10% of active file
+		 * to weight. This should be tweaked..
+		 */
+		if (val)
+			file_weight += val/10;
+		pages += val;
+
+		if (total_swap_pages) {
+			lru = LRU_INACTIVE_ANON;
+			val = mem_cgroup_get_zonestat_node(mem, nid, lru);
+			anon_weight = val;
+			pages += val;
+			lru = LRU_ACTIVE_ANON;
+			val = mem_cgroup_get_zonestat_node(mem, nid, lru);
+			/*
+			 * Magic again. We don't want to active_anon take into
+			 * account but cannot ignore....add +1.
+			 */
+			if (val)
+				anon_weight += 1;
+			pages += val;
+		} else
+			anon_weight = 0;
+		mem->info.nodeinfo[nid]->scan_weight =
+			file_weight * (200 - swappiness) +
+			anon_weight * swappiness;
+		if (!pages)
+			node_clear(nid, mem->scan_nodes);
+
+		total_weight += mem->info.nodeinfo[nid]->scan_weight;
+	}
+	/* NORMALIZE weight information.*/
+	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
+
+		mem->info.nodeinfo[nid]->scan_weight =
+			mem->info.nodeinfo[nid]->scan_weight
+				*  NODE_SCAN_LOTTERY/ total_weight;
+	}
+	/*
+	 * because checking lottery at every scan is heavy. we cache
+ 	 * some results. These victims will be used for the next 10sec.
+ 	 * Even if scan_nodes is empty, the victim_nodes includes node 0
+ 	 * at least.
+ 	 */
+	nr_selection = int_sqrt(nodes_weight(mem->scan_nodes)) + 1;
+
+	while (nr_selection >= 0) {
+		int lottery = random32();
+		for_each_node_mask(nid, mem->scan_nodes) {
+			lottery -= mem->info.nodeinfo[nid]->scan_weight;
+			if (lottery <= 0)
+				break;
+		}
+		node_set(nid, mem->victim_nodes);
 	}
 }
 
@@ -1776,17 +1850,9 @@ int mem_cgroup_select_victim_node(struct
 	mem_cgroup_may_update_nodemask(mem, false);
 	node = mem->last_scanned_node;
 
-	node = next_node(node, mem->scan_nodes);
+	node = next_node(node, mem->victim_nodes);
 	if (node == MAX_NUMNODES)
-		node = first_node(mem->scan_nodes);
-	/*
-	 * We call this when we hit limit, not when pages are added to LRU.
-	 * No LRU may hold pages because all pages are UNEVICTABLE or
-	 * memcg is too small and all pages are not on LRU. In that case,
-	 * we use curret node.
-	 */
-	if (unlikely(node == MAX_NUMNODES))
-		node = numa_node_id();
+		node = first_node(mem->victim_nodes);
 
 	mem->last_scanned_node = node;
 	return node;




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
