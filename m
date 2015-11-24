Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id BF4136B025A
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:59:53 -0500 (EST)
Received: by wmec201 with SMTP id c201so45861737wme.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:59:53 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o5si29778703wjq.214.2015.11.24.13.59.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:59:52 -0800 (PST)
Date: Tue, 24 Nov 2015 16:59:40 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 13/13] mm: memcontrol: hook up vmpressure to socket pressure
Message-ID: <20151124215940.GB1373@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Let the networking stack know when a memcg is under reclaim pressure
so that it can clamp its transmit windows accordingly.

Whenever the reclaim efficiency of a cgroup's LRU lists drops low
enough for a MEDIUM or HIGH vmpressure event to occur, assert a
pressure state in the socket and tcp memory code that tells it to curb
consumption growth from sockets associated with said control group.

Traditionally, vmpressure reports for the entire subtree of a memcg
under pressure, which drops useful information on the individual
groups reclaimed. However, it's too late to change the userinterface,
so add a second reporting mode that reports on the level of reclaim
instead of at the level of pressure, and use that report for sockets.

vmpressure events are naturally edge triggered, so for hysteresis
assert socket pressure for a second to allow for subsequent vmpressure
events to occur before letting the socket code return to normal.

This will likely need finetuning for a wider variety of workloads, but
for now stick to the vmpressure presets and keep hysteresis simple.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 32 ++++++++++++++++---
 include/linux/vmpressure.h |  5 ++-
 mm/memcontrol.c            | 17 ++--------
 mm/vmpressure.c            | 78 +++++++++++++++++++++++++++++++++++-----------
 mm/vmscan.c                | 10 +++++-
 5 files changed, 103 insertions(+), 39 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index fae0aaf..a8df46c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -249,6 +249,10 @@ struct mem_cgroup {
 	struct wb_domain cgwb_domain;
 #endif
 
+#ifdef CONFIG_INET
+	unsigned long		socket_pressure;
+#endif
+
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
 	spinlock_t event_list_lock;
@@ -292,18 +296,34 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
-struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
 
 static inline
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
 }
 
+#define mem_cgroup_from_counter(counter, member)	\
+	container_of(counter, struct mem_cgroup, member)
+
 struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
 
+/**
+ * parent_mem_cgroup - find the accounting parent of a memcg
+ * @memcg: memcg whose parent to find
+ *
+ * Returns the parent memcg, or NULL if this is the root or the memory
+ * controller is in legacy no-hierarchy mode.
+ */
+static inline struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
+{
+	if (!memcg->memory.parent)
+		return NULL;
+	return mem_cgroup_from_counter(memcg->memory.parent, memory);
+}
+
 static inline bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
 			      struct mem_cgroup *root)
 {
@@ -693,10 +713,14 @@ void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
 #ifdef CONFIG_MEMCG_KMEM
-	return memcg->tcp_mem.memory_pressure;
-#else
-	return false;
+	if (memcg->tcp_mem.memory_pressure)
+		return true;
 #endif
+	do {
+		if (time_before(jiffies, memcg->socket_pressure))
+			return true;
+	} while ((memcg = parent_mem_cgroup(memcg)));
+	return false;
 }
 #else
 #define mem_cgroup_sockets_enabled 0
diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 3e45358..a77b142 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -12,6 +12,9 @@
 struct vmpressure {
 	unsigned long scanned;
 	unsigned long reclaimed;
+
+	unsigned long tree_scanned;
+	unsigned long tree_reclaimed;
 	/* The lock is used to keep the scanned/reclaimed above in sync. */
 	struct spinlock sr_lock;
 
@@ -26,7 +29,7 @@ struct vmpressure {
 struct mem_cgroup;
 
 #ifdef CONFIG_MEMCG
-extern void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
+extern void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
 		       unsigned long scanned, unsigned long reclaimed);
 extern void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 59555b0..a0da91f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1091,9 +1091,6 @@ bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
 	return ret;
 }
 
-#define mem_cgroup_from_counter(counter, member)	\
-	container_of(counter, struct mem_cgroup, member)
-
 /**
  * mem_cgroup_margin - calculate chargeable space of a memory cgroup
  * @memcg: the memory cgroup
@@ -4159,17 +4156,6 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	kfree(memcg);
 }
 
-/*
- * Returns the parent mem_cgroup in memcgroup hierarchy with hierarchy enabled.
- */
-struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
-{
-	if (!memcg->memory.parent)
-		return NULL;
-	return mem_cgroup_from_counter(memcg->memory.parent, memory);
-}
-EXPORT_SYMBOL(parent_mem_cgroup);
-
 static struct cgroup_subsys_state * __ref
 mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
@@ -4210,6 +4196,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+#ifdef CONFIG_INET
+	memcg->socket_pressure = jiffies;
+#endif
 	return &memcg->css;
 
 free_out:
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 4c25e62..af262bb 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -137,14 +137,11 @@ struct vmpressure_event {
 };
 
 static bool vmpressure_event(struct vmpressure *vmpr,
-			     unsigned long scanned, unsigned long reclaimed)
+			     enum vmpressure_levels level)
 {
 	struct vmpressure_event *ev;
-	enum vmpressure_levels level;
 	bool signalled = false;
 
-	level = vmpressure_calc_level(scanned, reclaimed);
-
 	mutex_lock(&vmpr->events_lock);
 
 	list_for_each_entry(ev, &vmpr->events, node) {
@@ -164,6 +161,7 @@ static void vmpressure_work_fn(struct work_struct *work)
 	struct vmpressure *vmpr = work_to_vmpressure(work);
 	unsigned long scanned;
 	unsigned long reclaimed;
+	enum vmpressure_levels level;
 
 	spin_lock(&vmpr->sr_lock);
 	/*
@@ -174,19 +172,21 @@ static void vmpressure_work_fn(struct work_struct *work)
 	 * here. No need for any locks here since we don't care if
 	 * vmpr->reclaimed is in sync.
 	 */
-	scanned = vmpr->scanned;
+	scanned = vmpr->tree_scanned;
 	if (!scanned) {
 		spin_unlock(&vmpr->sr_lock);
 		return;
 	}
 
-	reclaimed = vmpr->reclaimed;
-	vmpr->scanned = 0;
-	vmpr->reclaimed = 0;
+	reclaimed = vmpr->tree_reclaimed;
+	vmpr->tree_scanned = 0;
+	vmpr->tree_reclaimed = 0;
 	spin_unlock(&vmpr->sr_lock);
 
+	level = vmpressure_calc_level(scanned, reclaimed);
+
 	do {
-		if (vmpressure_event(vmpr, scanned, reclaimed))
+		if (vmpressure_event(vmpr, level))
 			break;
 		/*
 		 * If not handled, propagate the event upward into the
@@ -199,6 +199,7 @@ static void vmpressure_work_fn(struct work_struct *work)
  * vmpressure() - Account memory pressure through scanned/reclaimed ratio
  * @gfp:	reclaimer's gfp mask
  * @memcg:	cgroup memory controller handle
+ * @tree:	legacy subtree mode
  * @scanned:	number of pages scanned
  * @reclaimed:	number of pages reclaimed
  *
@@ -206,9 +207,16 @@ static void vmpressure_work_fn(struct work_struct *work)
  * "instantaneous" memory pressure (scanned/reclaimed ratio). The raw
  * pressure index is then further refined and averaged over time.
  *
+ * If @tree is set, vmpressure is in traditional userspace reporting
+ * mode: @memcg is considered the pressure root and userspace is
+ * notified of the entire subtree's reclaim efficiency.
+ *
+ * If @tree is not set, reclaim efficiency is recorded for @memcg, and
+ * only in-kernel users are notified.
+ *
  * This function does not return any value.
  */
-void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
+void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
 		unsigned long scanned, unsigned long reclaimed)
 {
 	struct vmpressure *vmpr = memcg_to_vmpressure(memcg);
@@ -238,15 +246,47 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
 	if (!scanned)
 		return;
 
-	spin_lock(&vmpr->sr_lock);
-	vmpr->scanned += scanned;
-	vmpr->reclaimed += reclaimed;
-	scanned = vmpr->scanned;
-	spin_unlock(&vmpr->sr_lock);
+	if (tree) {
+		spin_lock(&vmpr->sr_lock);
+		vmpr->tree_scanned += scanned;
+		vmpr->tree_reclaimed += reclaimed;
+		scanned = vmpr->scanned;
+		spin_unlock(&vmpr->sr_lock);
 
-	if (scanned < vmpressure_win)
-		return;
-	schedule_work(&vmpr->work);
+		if (scanned < vmpressure_win)
+			return;
+		schedule_work(&vmpr->work);
+	} else {
+		enum vmpressure_levels level;
+
+		/* For now, no users for root-level efficiency */
+		if (memcg == root_mem_cgroup)
+			return;
+
+		spin_lock(&vmpr->sr_lock);
+		scanned = vmpr->scanned += scanned;
+		reclaimed = vmpr->reclaimed += reclaimed;
+		if (scanned < vmpressure_win) {
+			spin_unlock(&vmpr->sr_lock);
+			return;
+		}
+		vmpr->scanned = vmpr->reclaimed = 0;
+		spin_unlock(&vmpr->sr_lock);
+
+		level = vmpressure_calc_level(scanned, reclaimed);
+
+		if (level > VMPRESSURE_LOW) {
+			/*
+			 * Let the socket buffer allocator know that
+			 * we are having trouble reclaiming LRU pages.
+			 *
+			 * For hysteresis keep the pressure state
+			 * asserted for a second in which subsequent
+			 * pressure events can occur.
+			 */
+			memcg->socket_pressure = jiffies + HZ;
+		}
+	}
 }
 
 /**
@@ -276,7 +316,7 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
 	 * to the vmpressure() basically means that we signal 'critical'
 	 * level.
 	 */
-	vmpressure(gfp, memcg, vmpressure_win, 0);
+	vmpressure(gfp, memcg, true, vmpressure_win, 0);
 }
 
 /**
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 97ba9e1..50e54c0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2396,6 +2396,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		memcg = mem_cgroup_iter(root, NULL, &reclaim);
 		do {
 			unsigned long lru_pages;
+			unsigned long reclaimed;
 			unsigned long scanned;
 			struct lruvec *lruvec;
 			int swappiness;
@@ -2408,6 +2409,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 			swappiness = mem_cgroup_swappiness(memcg);
+			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
 
 			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
@@ -2418,6 +2420,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
 
+			/* Record the group's reclaim efficiency */
+			vmpressure(sc->gfp_mask, memcg, false,
+				   sc->nr_scanned - scanned,
+				   sc->nr_reclaimed - reclaimed);
+
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
 			 * cgroups to fulfill the overall scan target for the
@@ -2449,7 +2456,8 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			reclaim_state->reclaimed_slab = 0;
 		}
 
-		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
+		/* Record the subtree's reclaim efficiency */
+		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
 			   sc->nr_scanned - nr_scanned,
 			   sc->nr_reclaimed - nr_reclaimed);
 
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
