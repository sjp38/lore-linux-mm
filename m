Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 01DE69000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 00:35:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 265063EE0B6
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 13:34:59 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F61545DE51
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 13:34:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EE16E45DE4D
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 13:34:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E253D1DB802F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 13:34:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A4DF31DB803B
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 13:34:58 +0900 (JST)
Date: Wed, 27 Apr 2011 13:28:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: reclaim memory from nodes in round robin
Message-Id: <20110427132814.be22bab0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikTONt-shfi3cVudkbVhqpsP=HQvg@mail.gmail.com>
References: <20110427115718.ab6c55ae.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikTONt-shfi3cVudkbVhqpsP=HQvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishmura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>

On Tue, 26 Apr 2011 20:52:39 -0700
Ying Han <yinghan@google.com> wrote:

> On Tue, Apr 26, 2011 at 7:57 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
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
> > But yes, better algorithm is appreciated.
> >
> > From: Ying Han <yinghan@google.com>
> > Signed-off-by: Ying Han <yinghan@google.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A include/linux/memcontrol.h | A  A 1 +
> > A mm/memcontrol.c A  A  A  A  A  A | A  25 +++++++++++++++++++++++++
> > A mm/vmscan.c A  A  A  A  A  A  A  A | A  A 9 ++++++++-
> > A 3 files changed, 34 insertions(+), 1 deletion(-)
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
> > @@ -237,6 +237,7 @@ struct mem_cgroup {
> > A  A  A  A  * reclaimed from.
> > A  A  A  A  */
> > A  A  A  A int last_scanned_child;
> > + A  A  A  int last_scanned_node;
> > A  A  A  A /*
> > A  A  A  A  * Should the accounting and control be hierarchical, per subtree?
> > A  A  A  A  */
> > @@ -1472,6 +1473,29 @@ mem_cgroup_select_victim(struct mem_cgro
> > A }
> >
> > A /*
> > + * Selecting a node where we start reclaim from. Because what we need is just
> > + * reducing usage counter, start from anywhere is O,K. When considering
> > + * memory reclaim from current node, there are pros. and cons.
> > + * Freeing memory from current node means freeing memory from a node which
> > + * we'll use or we've used. So, it may make LRU bad. And if several threads
> > + * hit limits, it will see a contention on a node. But freeing from remote
> > + * node mean more costs for memory reclaim because of memory latency.
> > + *
> > + * Now, we use round-robin. Better algorithm is welcomed.
> > + */
> > +int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
> > +{
> > + A  A  A  int node;
> > +
> > + A  A  A  node = next_node(mem->last_scanned_node, node_states[N_HIGH_MEMORY]);
> > + A  A  A  if (node == MAX_NUMNODES)
> > + A  A  A  A  A  A  A  node = first_node(node_states[N_HIGH_MEMORY]);
> > +
> > + A  A  A  mem->last_scanned_node = node;
> > + A  A  A  return node;
> > +}
> > +
> > +/*
> > A * Scan the hierarchy if needed to reclaim memory. We remember the last child
> > A * we reclaimed from, so that we don't end up penalizing one child extensively
> > A * based on its position in the children list.
> > @@ -4678,6 +4702,7 @@ mem_cgroup_create(struct cgroup_subsys *
> > A  A  A  A  A  A  A  A res_counter_init(&mem->memsw, NULL);
> > A  A  A  A }
> > A  A  A  A mem->last_scanned_child = 0;
> > + A  A  A  mem->last_scanned_node = MAX_NUMNODES;
> > A  A  A  A INIT_LIST_HEAD(&mem->oom_notify);
> >
> > A  A  A  A if (parent)
> > Index: memcg/mm/vmscan.c
> > ===================================================================
> > --- memcg.orig/mm/vmscan.c
> > +++ memcg/mm/vmscan.c
> > @@ -2198,6 +2198,7 @@ unsigned long try_to_free_mem_cgroup_pag
> > A {
> > A  A  A  A struct zonelist *zonelist;
> > A  A  A  A unsigned long nr_reclaimed;
> > + A  A  A  int nid;
> > A  A  A  A struct scan_control sc = {
> > A  A  A  A  A  A  A  A .may_writepage = !laptop_mode,
> > A  A  A  A  A  A  A  A .may_unmap = 1,
> > @@ -2208,10 +2209,16 @@ unsigned long try_to_free_mem_cgroup_pag
> > A  A  A  A  A  A  A  A .mem_cgroup = mem_cont,
> > A  A  A  A  A  A  A  A .nodemask = NULL, /* we don't care the placement */
> > A  A  A  A };
> > + A  A  A  /*
> > + A  A  A  A * Unlike direct reclaim via allo_pages(), memcg's reclaim
> > + A  A  A  A * don't take care from where we get free resouce. So, the node where
> > + A  A  A  A * we need to start scan is not need to be current node.
> > + A  A  A  A */
> Sorry, some typos. alloc_pages() instead of alloc_pages(). And "free resource".
> 
ok, will fix. Thank you for pointing out.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
