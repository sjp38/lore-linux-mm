Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8796F6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:05:09 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0318D3EE0BC
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:05:06 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF3D845DE97
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:05:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ABB1145DE96
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:05:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C04FE08003
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:05:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 56AA71DB803B
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:05:05 +0900 (JST)
Date: Thu, 28 Apr 2011 08:57:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv2] memcg: reclaim memory from node in round-robin
Message-Id: <20110428085751.fd478fe8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinx+4zXaO3rhHRUzr3m-K-2_NMTQw@mail.gmail.com>
References: <20110427165120.a60c6609.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinx+4zXaO3rhHRUzr3m-K-2_NMTQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Wed, 27 Apr 2011 10:33:43 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 27, 2011 at 12:51 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > I changed the logic a little and add a filter for skipping nodes.
> > With large NUMA, tasks may under cpuset or mempolicy and the usage of memory
> > can be unbalanced. So, I think a filter is required.
> 
> Thank you.
> 
> >
> > ==
> > Now, memory cgroup's direct reclaim frees memory from the current node.
> > But this has some troubles. In usual, when a set of threads works in
> > cooperative way, they are tend to on the same node. So, if they hit
> > limits under memcg, it will reclaim memory from themselves, it may be
> > active working set.
> >
> > For example, assume 2 node system which has Node 0 and Node 1
> > and a memcg which has 1G limit. After some work, file cacne remains and
> > and usages are
> > A  Node 0: A 1M
> > A  Node 1: A 998M.
> >
> > and run an application on Node 0, it will eats its foot before freeing
> > unnecessary file caches.
> >
> > This patch adds round-robin for NUMA and adds equal pressure to each
> > node. When using cpuset's spread memory feature, this will work very well.
> >
> >
> > From: Ying Han <yinghan@google.com>
> > Signed-off-by: Ying Han <yinghan@google.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Changelog v1->v2:
> > A - fixed comments.
> > A - added a logic to avoid scanning unused node.
> >
> > ---
> > A include/linux/memcontrol.h | A  A 1
> > A mm/memcontrol.c A  A  A  A  A  A | A  98 ++++++++++++++++++++++++++++++++++++++++++---
> > A mm/vmscan.c A  A  A  A  A  A  A  A | A  A 9 +++-
> > A 3 files changed, 101 insertions(+), 7 deletions(-)
> >
> > Index: memcg/include/linux/memcontrol.h
> > ===================================================================
> > --- memcg.orig/include/linux/memcontrol.h
> > +++ memcg/include/linux/memcontrol.h
> > @@ -108,6 +108,7 @@ extern void mem_cgroup_end_migration(str
> > A */
> > A int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> > A int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> > +int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
> > A unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct zone *zone,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  enum lru_list lru);
> > Index: memcg/mm/memcontrol.c
> > ===================================================================
> > --- memcg.orig/mm/memcontrol.c
> > +++ memcg/mm/memcontrol.c
> > @@ -237,6 +237,11 @@ struct mem_cgroup {
> > A  A  A  A  * reclaimed from.
> > A  A  A  A  */
> > A  A  A  A int last_scanned_child;
> > + A  A  A  int last_scanned_node;
> > +#if MAX_NUMNODES > 1
> > + A  A  A  nodemask_t A  A  A scan_nodes;
> > + A  A  A  unsigned long A  next_scan_node_update;
> > +#endif
> > A  A  A  A /*
> > A  A  A  A  * Should the accounting and control be hierarchical, per subtree?
> > A  A  A  A  */
> > @@ -650,18 +655,27 @@ static void mem_cgroup_soft_scan(struct
> > A  A  A  A this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_SCAN], val);
> > A }
> >
> > +static unsigned long
> > +mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum lru_list idx)
> > +{
> > + A  A  A  struct mem_cgroup_per_zone *mz;
> > + A  A  A  u64 total;
> > + A  A  A  int zid;
> > +
> > + A  A  A  for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> > + A  A  A  A  A  A  A  mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > + A  A  A  A  A  A  A  total += MEM_CGROUP_ZSTAT(mz, idx);
> > + A  A  A  }
> > + A  A  A  return total;
> > +}
> > A static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A enum lru_list idx)
> > A {
> > - A  A  A  int nid, zid;
> > - A  A  A  struct mem_cgroup_per_zone *mz;
> > + A  A  A  int nid;
> > A  A  A  A u64 total = 0;
> >
> > A  A  A  A for_each_online_node(nid)
> > - A  A  A  A  A  A  A  for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> > - A  A  A  A  A  A  A  A  A  A  A  mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > - A  A  A  A  A  A  A  A  A  A  A  total += MEM_CGROUP_ZSTAT(mz, idx);
> > - A  A  A  A  A  A  A  }
> > + A  A  A  A  A  A  A  total += mem_cgroup_get_zonestat_node(mem, nid, idx);
> > A  A  A  A return total;
> > A }
> >
> > @@ -1471,6 +1485,77 @@ mem_cgroup_select_victim(struct mem_cgro
> > A  A  A  A return ret;
> > A }
> >
> > +#if MAX_NUMNODES > 1
> > +
> > +/*
> > + * Update nodemask always is not very good. Even if we have empty
> > + * list, or wrong list here, we can start from some node and traverse all nodes
> > + * based on zonelist. So, update the list loosely once in 10 secs.
> > + *
> > + */
> > +static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
> > +{
> > + A  A  A  int nid;
> > +
> > + A  A  A  if (time_after(mem->next_scan_node_update, jiffies))
> > + A  A  A  A  A  A  A  return;
> > +
> > + A  A  A  mem->next_scan_node_update = jiffies + 10*HZ;
> > + A  A  A  /* make a nodemask where this memcg uses memory from */
> > + A  A  A  mem->scan_nodes = node_states[N_HIGH_MEMORY];
> > +
> > + A  A  A  for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
> > +
> > + A  A  A  A  A  A  A  if (mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_FILE) ||
> > + A  A  A  A  A  A  A  A  A  mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_FILE))
> > + A  A  A  A  A  A  A  A  A  A  A  continue;
> > +
> > + A  A  A  A  A  A  A  if (total_swap_pages &&
> > + A  A  A  A  A  A  A  A  A  (mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_ANON) ||
> > + A  A  A  A  A  A  A  A  A  A mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_ANON)))
> > + A  A  A  A  A  A  A  A  A  A  A  continue;
> > + A  A  A  A  A  A  A  node_clear(nid, mem->scan_nodes);
> > + A  A  A  }
> > +
> > +}
> > +
> > +/*
> > + * Selecting a node where we start reclaim from. Because what we need is just
> > + * reducing usage counter, start from anywhere is O,K. Considering
> > + * memory reclaim from current node, there are pros. and cons.
> > + *
> > + * Freeing memory from current node means freeing memory from a node which
> > + * we'll use or we've used. So, it may make LRU bad. And if several threads
> > + * hit limits, it will see a contention on a node. But freeing from remote
> > + * node means more costs for memory reclaim because of memory latency.
> > + *
> > + * Now, we use round-robin. Better algorithm is welcomed.
> > + */
> > +int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
> > +{
> > + A  A  A  int node;
> > +
> > + A  A  A  mem_cgroup_may_update_nodemask(mem);
> > + A  A  A  node = mem->last_scanned_node;
> > +
> > + A  A  A  node = next_node(node, mem->scan_nodes);
> > + A  A  A  if (node == MAX_NUMNODES) {
> > + A  A  A  A  A  A  A  node = first_node(mem->scan_nodes);
> > + A  A  A  A  A  A  A  if (unlikely(node == MAX_NUMNODES))
> > + A  A  A  A  A  A  A  A  A  A  A  node = numa_node_id();
> not sure about this logic, is that possible we reclaim from a node
> with all "unreclaimable" pages (based on the
> mem_cgroup_may_update_nodemask check).
> If i missed anything here, it would be helpful to add comment.
> 

What I'm afraid here is when a user uses very small memcg,
all pages on the LRU may be isolated or all usages are in per-cpu cache
of memcg or because of task-migration between memcg, it hits limit before
having any pages on LRU.....I think there is possible corner cases which
can cause hang.

ok, will add comment.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
