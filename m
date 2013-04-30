Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 356B36B00D5
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 07:02:20 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id p10so361862lbi.41
        for <linux-mm@kvack.org>; Tue, 30 Apr 2013 04:02:18 -0700 (PDT)
Subject: [PATCH RFC] mm: lru milestones, timestamps and ages
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 30 Apr 2013 15:02:14 +0400
Message-ID: <20130430110214.22179.26139.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This patch adds engine for estimating rotation time for pages in lru lists.

This adds bunch of 'milestones' into each struct lruvec and inserts them into
lru lists periodically. Milestone flows in lru together with pages and brings
timestamp to the end of lru. Because milestones are embedded into lruvec they
can be easily distinguished from pages by comparing pointers.
Only few functions should care about that.

This machinery provides discrete-time estimation for age of pages from the end
of each lru and average age of each kind of evictable lrus in each zone.

Numbers are shown in '/proc/zoneinfo' and in memcg attribute 'memory.stat'.

Overhead on fast-path is nearly zero: is_lru_milestone() in isolate_lru_pages()
distinguishes milestones and pages without touching any extra cache-lines.
Memory overhead is more noticeable: 1.5k for 16 milestones per struct lruvec.
Struct mem_cgroup_per_node now requires order-1 page on 64-bit system with 4
zones per node.

In our kernel we use similar engine as source of statistics for scheduler in
memory reclaimer. This is O(1) scheduler which shifts vmscan priorities for lru
vectors depending on their sizes, limits and ages. It tries to balance memory
pressure among containers. I'll try to rework it for the mainline kernel soon.

Seems like these ages also can be used for optimal memory pressure distribution
between file and anon pages, and probably for balancing pressure among zones.
Moreover slab shrinkers also can provide similar time-based statistics,
some of them may embed timestamps directly into their objects.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mmzone.h |   26 ++++++++++
 mm/memcontrol.c        |   32 ++++++++++++
 mm/mmzone.c            |   10 ++++
 mm/vmscan.c            |  126 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/vmstat.c            |    9 +++
 5 files changed, 203 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c74092e..d8a6a43 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -7,6 +7,7 @@
 #include <linux/spinlock.h>
 #include <linux/list.h>
 #include <linux/wait.h>
+#include <linux/workqueue.h>
 #include <linux/bitops.h>
 #include <linux/cache.h>
 #include <linux/threads.h>
@@ -164,6 +165,7 @@ enum lru_list {
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
 	LRU_UNEVICTABLE,
+	NR_EVICTABLE_LRU_LISTS = LRU_UNEVICTABLE,
 	NR_LRU_LISTS
 };
 
@@ -199,14 +201,35 @@ struct zone_reclaim_stat {
 	unsigned long		recent_scanned[2];
 };
 
+struct lru_milestone {
+	unsigned long		timestamp;
+	struct list_head	lru;
+};
+
+#define NR_LRU_MILESTONES	16
+
 struct lruvec {
 	struct list_head lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat reclaim_stat;
 #ifdef CONFIG_MEMCG
 	struct zone *zone;
 #endif
+	unsigned long		age[NR_EVICTABLE_LRU_LISTS];
+	unsigned long		next_timestamp[NR_EVICTABLE_LRU_LISTS];
+	unsigned char		last_milestone[NR_EVICTABLE_LRU_LISTS];
+	struct lru_milestone	milestones[NR_EVICTABLE_LRU_LISTS][NR_LRU_MILESTONES];
 };
 
+static inline bool
+is_lru_milestone(struct lruvec *lruvec, struct list_head *list)
+{
+	return unlikely(list >= &lruvec->milestones[0][0].lru &&
+			list <  &lruvec->milestones[NR_EVICTABLE_LRU_LISTS]
+						   [NR_LRU_MILESTONES].lru);
+}
+
+void remove_lru_milestone(struct lruvec *lruvec, enum lru_list lru);
+
 /* Mask used at gathering information at once (see memcontrol.c) */
 #define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
 #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
@@ -487,6 +510,9 @@ struct zone {
 	 * rarely used fields:
 	 */
 	const char		*name;
+
+	struct delayed_work	milestones_work;
+	unsigned long		average_age[NR_EVICTABLE_LRU_LISTS];
 } ____cacheline_internodealigned_in_smp;
 
 typedef enum {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2b55222..07af4ce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -967,6 +967,27 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 	return total;
 }
 
+static unsigned mem_cgroup_avg_age(struct mem_cgroup *memcg, enum lru_list lru)
+{
+	struct mem_cgroup_per_zone *mz;
+	unsigned long size = 0, pages;
+	int nid, zid;
+	u64 age = 0;
+
+	for_each_node_state(nid, N_MEMORY) {
+		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+			mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+			pages = mz->lru_size[lru];
+			size += pages;
+			age += (u64)pages * mz->lruvec.age[lru];
+		}
+	}
+
+	if (size)
+		do_div(age, size);
+	return jiffies_to_msecs(age);
+}
+
 static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 				       enum mem_cgroup_events_target target)
 {
@@ -4707,6 +4728,11 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 			break;
 		}
 		page = list_entry(list->prev, struct page, lru);
+		if (is_lru_milestone(lruvec, &page->lru)) {
+			remove_lru_milestone(lruvec, lru);
+			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			continue;
+		}
 		if (busy == page) {
 			list_move(&page->lru, list);
 			busy = NULL;
@@ -5298,6 +5324,10 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i],
 			   mem_cgroup_nr_lru_pages(memcg, BIT(i)) * PAGE_SIZE);
 
+	for (i = 0; i < NR_EVICTABLE_LRU_LISTS; i++)
+		seq_printf(m, "avg_age_%s %u\n", mem_cgroup_lru_names[i],
+			   mem_cgroup_avg_age(memcg, i));
+
 	/* Hierarchical information */
 	{
 		unsigned long long limit, memsw_limit;
@@ -5923,6 +5953,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 	 */
 	if (!node_state(node, N_NORMAL_MEMORY))
 		tmp = -1;
+	/* Try to decrease NR_LRU_MILESTONES if this happens */
+	BUILD_BUG_ON(sizeof(struct mem_cgroup_per_node) > 2 * PAGE_SIZE);
 	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
 	if (!pn)
 		return 1;
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 2ac0afb..64d59d6 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -89,12 +89,22 @@ int memmap_valid_within(unsigned long pfn,
 
 void lruvec_init(struct lruvec *lruvec)
 {
+	unsigned long now = jiffies;
 	enum lru_list lru;
+	int i;
 
 	memset(lruvec, 0, sizeof(struct lruvec));
 
 	for_each_lru(lru)
 		INIT_LIST_HEAD(&lruvec->lists[lru]);
+
+	for_each_evictable_lru(lru) {
+		for (i = 0; i < NR_LRU_MILESTONES; i++) {
+			INIT_LIST_HEAD(&lruvec->milestones[lru][i].lru);
+			lruvec->milestones[lru][i].timestamp = now;
+		}
+		lruvec->next_timestamp[lru] = now;
+	}
 }
 
 #if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_NID_NOT_IN_PAGE_FLAGS)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 669fba3..caf5fee 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1101,6 +1101,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
 
+		if (is_lru_milestone(lruvec, &page->lru)) {
+			remove_lru_milestone(lruvec, lru);
+			continue;
+		}
+
 		VM_BUG_ON(!PageLRU(page));
 
 		switch (__isolate_lru_page(page, mode)) {
@@ -2489,6 +2494,113 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
 	} while (memcg);
 }
 
+void remove_lru_milestone(struct lruvec *lruvec, enum lru_list lru)
+{
+	struct zone *zone = lruvec_zone(lruvec);
+	unsigned long now = jiffies, interval, next;
+	struct lru_milestone *ms;
+
+	ms = container_of(lruvec->lists[lru].prev, struct lru_milestone, lru);
+	list_del_init(&ms->lru);
+	lruvec->age[lru] = now - ms->timestamp;
+
+	pr_debug("lruvec:%p lru:%d remove:%02ld age:%lu\n", lruvec, lru,
+			ms - lruvec->milestones[lru], lruvec->age[lru]);
+
+	/* get new estimation for next milestone */
+	interval = lruvec->age[lru] / NR_LRU_MILESTONES;
+	ms = lruvec->milestones[lru] + lruvec->last_milestone[lru];
+	next = ms->timestamp + interval;
+	lruvec->next_timestamp[lru] = next;
+
+	if (time_before(next, zone->milestones_work.timer.expires))
+		mod_delayed_work(system_wq, &zone->milestones_work,
+				 time_after(next, now) ? (next - now) : 0);
+}
+
+static void insert_lru_milestone(struct lruvec *lruvec, enum lru_list lru)
+{
+	unsigned long now = jiffies, interval;
+	struct lru_milestone *ms;
+
+	lruvec->last_milestone[lru]++;
+	lruvec->last_milestone[lru] %= NR_LRU_MILESTONES;
+	ms = lruvec->milestones[lru] + lruvec->last_milestone[lru];
+
+	/* get linear estimation of perfect interval between milestones */
+	interval = lruvec->age[lru] / NR_LRU_MILESTONES;
+
+	if (!list_empty(&ms->lru)) {
+		list_del(&ms->lru);
+		lruvec->age[lru] = now - ms->timestamp;
+		/* double inteval if oldest milestone is still in lru */
+		interval += HZ/100 + lruvec->age[lru] / NR_LRU_MILESTONES;
+	}
+
+	/* Required for calculating average ages in u64 without overflows */
+	interval = min_t(unsigned long, interval, INT_MAX / NR_LRU_MILESTONES);
+
+	ms->timestamp = now;
+	list_add(&ms->lru, &lruvec->lists[lru]);
+	lruvec->next_timestamp[lru] = now + interval;
+
+	pr_debug("lruvec:%p lru:%d insert:%02ld age:%lu\n", lruvec, lru,
+			ms - lruvec->milestones[lru], lruvec->age[lru]);
+}
+
+static void lru_milestones_work(struct work_struct *work)
+{
+	unsigned long size[NR_EVICTABLE_LRU_LISTS] = {0,};
+	u64 age[NR_EVICTABLE_LRU_LISTS] = {0,};
+	struct mem_cgroup *memcg;
+	unsigned long next;
+	struct zone *zone;
+	enum lru_list lru;
+
+	zone = container_of(work, struct zone, milestones_work.work);
+	if (!populated_zone(zone) || !node_state(zone_to_nid(zone), N_MEMORY))
+		return;
+
+	next = jiffies + INT_MAX / NR_LRU_MILESTONES;
+	zone->milestones_work.timer.expires = next;
+
+	memcg = mem_cgroup_iter(NULL, NULL, NULL);
+	do {
+		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+		unsigned long now = jiffies;
+		unsigned long pages;
+
+		for_each_evictable_lru(lru) {
+			if (time_after_eq(now, lruvec->next_timestamp[lru])) {
+				spin_lock_irq(&zone->lru_lock);
+				insert_lru_milestone(lruvec, lru);
+				spin_unlock_irq(&zone->lru_lock);
+			}
+			if (time_before(lruvec->next_timestamp[lru], next))
+				next = lruvec->next_timestamp[lru];
+
+			pages = get_lru_size(lruvec, lru);
+			size[lru] += pages;
+			age[lru] += (u64)pages * lruvec->age[lru];
+		}
+
+		memcg = mem_cgroup_iter(NULL, memcg, NULL);
+	} while (memcg);
+
+	for_each_evictable_lru(lru) {
+		if (size[lru])
+			do_div(age[lru], size[lru]);
+		zone->average_age[lru] = age[lru];
+	}
+
+	if (time_before_eq(next, zone->milestones_work.timer.expires)) {
+		unsigned long now = jiffies;
+
+		mod_delayed_work(system_wq, &zone->milestones_work,
+				 time_after(next, now) ? (next - now) : 0);
+	}
+}
+
 static bool zone_balanced(struct zone *zone, int order,
 			  unsigned long balance_gap, int classzone_idx)
 {
@@ -2958,6 +3070,7 @@ static int kswapd(void *p)
 	int balanced_classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
+	int i;
 
 	struct reclaim_state reclaim_state = {
 		.reclaimed_slab = 0,
@@ -2985,6 +3098,13 @@ static int kswapd(void *p)
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 	set_freezable();
 
+	for (i = pgdat->nr_zones - 1; i >= 0; i--) {
+		struct zone *zone = pgdat->node_zones + i;
+
+		INIT_DELAYED_WORK(&zone->milestones_work, lru_milestones_work);
+		schedule_delayed_work(&zone->milestones_work, 0);
+	}
+
 	order = new_order = 0;
 	balanced_order = 0;
 	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
@@ -3039,6 +3159,12 @@ static int kswapd(void *p)
 		}
 	}
 
+	for (i = pgdat->nr_zones - 1; i >= 0; i--) {
+		struct zone *zone = pgdat->node_zones + i;
+
+		cancel_delayed_work_sync(&zone->milestones_work);
+	}
+
 	current->reclaim_state = NULL;
 	return 0;
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index e1d8ed1..ed82165 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1053,6 +1053,15 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		   zone->all_unreclaimable,
 		   zone->zone_start_pfn,
 		   zone->inactive_ratio);
+	seq_printf(m,
+		   "\n  avg_age_inactive_anon: %u"
+		   "\n  avg_age_active_anon:   %u"
+		   "\n  avg_age_inactive_file: %u"
+		   "\n  avg_age_active_file:   %u",
+		   jiffies_to_msecs(zone->average_age[LRU_INACTIVE_ANON]),
+		   jiffies_to_msecs(zone->average_age[LRU_ACTIVE_ANON]),
+		   jiffies_to_msecs(zone->average_age[LRU_INACTIVE_FILE]),
+		   jiffies_to_msecs(zone->average_age[LRU_ACTIVE_FILE]));
 	seq_putc(m, '\n');
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
