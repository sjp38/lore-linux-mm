Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C578F6B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 01:05:24 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2R5CUmD010569
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 27 Mar 2009 14:12:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AC5C45DE57
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:12:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AA2745DE53
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:12:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DFB9E0800B
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:12:30 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D14411DB8043
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:12:29 +0900 (JST)
Date: Fri, 27 Mar 2009 14:11:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 6/8] soft limit victim select
Message-Id: <20090327141102.a22753e6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Soft Limit victim selection/cache logic.

This patch implements victim selection logic and caching method.

victim memcg is selected in following way, assume a zone under shrinking
is specified. Selected memcg will be
  - has the highest priority (high usage)
  - has memory on the zone.

When a memcg is selected, it's rotated and cached per cpu with tickets.

This cache is refreshed when
  - given ticket is exhausetd
  - very long time since last update.
  - the cached memcg doesn't include proper zone.

Even when no proper memcg is not found in victim selection logic,
some tickets are assigned to NULL victim.

As softlimitq, this cache's information has 2 ents for anon and file.

TODO:
  - need to handle cpu hotplug (in other patch)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  121 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 121 insertions(+)

Index: mmotm-2.6.29-Mar23/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar23.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar23/mm/memcontrol.c
@@ -1055,6 +1055,127 @@ static void mem_cgroup_update_soft_limit
 	return;
 }
 
+/* softlimit victim selection logic */
+
+/* Returns the amount of evictable memory in memcg */
+static int mem_cgroup_usage(struct mem_cgroup *mem, struct zone *zone, int file)
+{
+	struct mem_cgroup_per_zone *mz;
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	unsigned long usage = 0;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (!file) {
+		usage = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON)
+			+ MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
+	} else {
+		usage = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE)
+			+ MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
+	}
+	return usage;
+}
+
+struct soft_limit_cache {
+	/* If ticket is 0, refresh and refill the cache.*/
+	unsigned long ticket[2];
+	/* next update time for ticket(jiffies)*/
+	unsigned long next_update;
+	/* An event count per cpu. */
+	unsigned long total_events;
+	/* victim memcg */
+	struct mem_cgroup *mem[2];
+};
+/* In fast-path, 32pages are reclaimed per call. 4*32=128pages as base ticket */
+#define SLCACHE_NULL_TICKET (4)
+#define SLCACHE_UPDATE_JIFFIES (HZ*5) /* 5 minutes is very long. */
+DEFINE_PER_CPU(struct soft_limit_cache, soft_limit_cache);
+
+/* This is called under preempt disabled context....*/
+static void reload_softlimit_victim(struct soft_limit_cache *slc,
+				    struct zone *zone, int file)
+{
+	struct mem_cgroup *mem = NULL;
+	struct mem_cgroup *tmp;
+	struct list_head *queue;
+	int prio, bonus;
+
+	if (slc->mem[file]) {
+		mem_cgroup_put(slc->mem[file]);
+		slc->mem[file] = NULL;
+	}
+	slc->ticket[file] = SLCACHE_NULL_TICKET;
+	slc->next_update = jiffies + SLCACHE_UPDATE_JIFFIES;
+	slc->total_events++;
+
+	/* brief check the queue */
+	for (prio = SLQ_MAXPRIO - 1; prio > 0; prio--) {
+		if (!list_empty(&softlimitq.queue[prio][file]))
+			break;
+	}
+retry:
+	if (prio == 0)
+		return;
+
+	/* check queue in priority order */
+
+	queue = &softlimitq.queue[prio][file];
+	spin_lock(&softlimitq.lock);
+	if (file) {
+		list_for_each_entry(tmp, queue, soft_limit_file) {
+			if (mem_cgroup_usage(tmp, zone, file)) {
+				mem = tmp;
+				break;
+			}
+		}
+		if (mem)
+			list_move_tail(&mem->soft_limit_file, queue);
+	} else {
+		list_for_each_entry(tmp, queue, soft_limit_anon) {
+			if (mem_cgroup_usage(tmp, zone, file)) {
+				mem = tmp;
+				break;
+			}
+		}
+		if (mem)
+			list_move_tail(&mem->soft_limit_anon, queue);
+	}
+	spin_unlock(&softlimitq.lock);
+	/* If not found, goes to next priority */
+	if (!mem) {
+		prio--;
+		goto retry;
+	}
+	if (!css_is_removed(&mem->css)) {
+		slc->mem[file] = mem;
+		bonus = prio * 2;
+		slc->ticket[file] += bonus;
+		mem_cgroup_get(mem);
+	}
+}
+
+static struct mem_cgroup *get_soft_limit_victim(struct zone *zone, int file)
+{
+	struct mem_cgroup *ret;
+	struct soft_limit_cache *slc;
+
+	slc = &get_cpu_var(soft_limit_cache);
+	/*
+	 * If ticket is expired or long time since last ticket or
+	 * there are no evictables in memcg, reload victim.
+	 */
+	ret = slc->mem[file];
+	if ((!slc->ticket[file]-- ||
+	     time_after(jiffies, slc->next_update)) ||
+	    (ret && !mem_cgroup_usage(ret, zone, file))) {
+		reload_softlimit_victim(slc, zone, file);
+		ret = slc->mem[file];
+	}
+	put_cpu_var(soft_limit_cache);
+	return ret;
+}
+
+
 static void softlimitq_init(void)
 {
 	int i;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
