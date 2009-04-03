Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CEEFA6B003D
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 04:17:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n338HJD3000916
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Apr 2009 17:17:20 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 94CE845DD75
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:17:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7218845DD72
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:17:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CD4E1DB8016
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:17:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 08243E08003
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 17:17:19 +0900 (JST)
Date: Fri, 3 Apr 2009 17:15:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 7/9] vicitim selection logic
Message-Id: <20090403171552.676b422e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
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

Change Log v1 -> v2:
 - clean up.
 - cpu hotplug support.
 - change "bonus" calclation of victime.
 - try to make the code slim.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |  198 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 198 insertions(+)

Index: softlimit-test2/mm/memcontrol.c
===================================================================
--- softlimit-test2.orig/mm/memcontrol.c
+++ softlimit-test2/mm/memcontrol.c
@@ -37,6 +37,8 @@
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
+#include <linux/cpu.h>
+
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -1093,6 +1095,169 @@ static void mem_cgroup_update_soft_limit
 	return;
 }
 
+/* softlimit victim selection logic */
+
+/* Returns the amount of evictable memory in memcg */
+static unsigned long
+mem_cgroup_usage(struct mem_cgroup *mem, struct zone *zone, int file)
+{
+	struct mem_cgroup_per_zone *mz;
+	int nid = zone->zone_pgdat->node_id;
+	int zid = zone_idx(zone);
+	unsigned long usage = 0;
+	enum lru_list l = LRU_BASE;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (file)
+		l += LRU_FILE;
+	usage = MEM_CGROUP_ZSTAT(mz, l) + MEM_CGROUP_ZSTAT(mz, l + LRU_ACTIVE);
+
+	return usage;
+}
+
+struct soft_limit_cache {
+	/* If ticket is 0, refresh and refill the cache.*/
+	int ticket[2];
+	/* next update time for ticket(jiffies)*/
+	unsigned long next_update;
+	/* victim memcg */
+	struct mem_cgroup *mem[2];
+};
+
+/*
+ * Typically, 32pages are reclaimed per call. 4*32=128pages as base ticket.
+ * 4 * prio scans are added as bonus for high priority.
+ */
+#define SLCACHE_NULL_TICKET (4)
+#define SLCACHE_UPDATE_JIFFIES (HZ*5) /* 5 minutes is very long. */
+DEFINE_PER_CPU(struct soft_limit_cache, soft_limit_cache);
+
+#ifdef CONFIG_HOTPLUG_CPU
+static void forget_soft_limit_cache(long cpu)
+{
+	struct soft_limit_cache *slc;
+
+	slc = &per_cpu(soft_limit_cache, cpu);
+	slc->ticket[0] = 0;
+	slc->ticket[1] = 0;
+	slc->next_update = jiffies;
+	if (slc->mem[0])
+		mem_cgroup_put(slc->mem[0]);
+	if (slc->mem[1])
+		mem_cgroup_put(slc->mem[1]);
+	slc->mem[0] = NULL;
+	slc->mem[1] = NULL;
+}
+#endif
+
+
+/* This is called under preempt disabled context....*/
+static noinline void reload_softlimit_victim(struct soft_limit_cache *slc,
+				    struct zone *zone, int file)
+{
+	struct mem_cgroup *mem, *tmp;
+	struct list_head *queue, *cur;
+	int prio;
+	unsigned long usage = 0;
+
+	if (slc->mem[file]) {
+		mem_cgroup_put(slc->mem[file]);
+		slc->mem[file] = NULL;
+	}
+	slc->ticket[file] = SLCACHE_NULL_TICKET;
+	slc->next_update = jiffies + SLCACHE_UPDATE_JIFFIES;
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
+
+	spin_lock(&softlimitq.lock);
+	mem = NULL;
+	/*
+	 * does same behavior as list_for_each_entry but
+	 * member for next entity depends on "file".
+	 */
+	list_for_each(cur, queue) {
+		if (!file)
+			tmp = container_of(cur, struct mem_cgroup,
+					   soft_limit_list[0]);
+		else
+			tmp = container_of(cur, struct mem_cgroup,
+					   soft_limit_list[1]);
+
+		usage = mem_cgroup_usage(tmp, zone, file);
+		if (usage) {
+			mem = tmp;
+			list_move_tail(&mem->soft_limit_list[file], queue);
+			break;
+		}
+	}
+	spin_unlock(&softlimitq.lock);
+
+	/* If not found, goes to next priority */
+	if (!mem) {
+		prio--;
+		goto retry;
+	}
+
+	if (!css_is_removed(&mem->css)) {
+		int bonus = 0;
+		unsigned long estimated_excess;
+		estimated_excess = totalram_pages/SLQ_PRIO_FACTOR;
+		estimated_excess <<= prio;
+		slc->mem[file] = mem;
+		/*
+		 * If not using hierarchy, this memcg itself consumes memory.
+		 * Then, add extra scan bonus to this memcg itself.
+		 * If not, this memcg itself may not be very bad one. If
+		 * this memcg's (anon or file )usage > 12% of excess,
+		 * add extra scan bonus. if not, just small scan.
+		 */
+		if (!mem->use_hierarchy || (usage > estimated_excess/8))
+			bonus = SLCACHE_NULL_TICKET * prio;
+		else
+			bonus = SLCACHE_NULL_TICKET; /* twice to NULL */
+		slc->ticket[file] += bonus;
+		mem_cgroup_get(mem);
+	}
+}
+
+static void slc_reset_cache_ticket(int file)
+{
+	struct soft_limit_cache *slc = &get_cpu_var(soft_limit_cache);
+
+	slc->ticket[file] = 0;
+	put_cpu_var(soft_limit_cache);
+}
+
+static struct mem_cgroup *get_soft_limit_victim(struct zone *zone, int file)
+{
+	struct mem_cgroup *ret;
+	struct soft_limit_cache *slc;
+
+	slc = &get_cpu_var(soft_limit_cache);
+	/*
+	 * If ticket is expired or long time since last ticket.
+	 * reload victim.
+	 */
+	if ((--slc->ticket[file] < 0) ||
+	    (time_after(jiffies, slc->next_update)))
+		reload_softlimit_victim(slc, zone, file);
+	ret = slc->mem[file];
+	put_cpu_var(soft_limit_cache);
+	return ret;
+}
+
+
 static void softlimitq_init(void)
 {
 	int i;
@@ -2780,3 +2945,36 @@ static int __init disable_swap_account(c
 }
 __setup("noswapaccount", disable_swap_account);
 #endif
+
+#ifdef CONFIG_HOTPLUG_CPU
+/*
+ * _NOW_, what we have to handle is just cpu removal.
+ */
+static int __cpuinit memcg_cpu_callback(struct notifier_block *nfb,
+					unsigned long action,
+					void *hcpu)
+{
+	long cpu = (long) hcpu;
+
+	switch (action) {
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+		forget_soft_limit_cache(cpu);
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block __cpuinitdata soft_limit_notifier = {
+	&memcg_cpu_callback, NULL, 0
+};
+
+static int __cpuinit memcg_cpuhp_init(void)
+{
+	register_cpu_notifier(&soft_limit_notifier);
+	return 0;
+}
+__initcall(memcg_cpuhp_init);
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
