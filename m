Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED8A82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 17:22:52 -0500 (EST)
Received: by wmnn186 with SMTP id n186so3683822wmn.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:22:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dh6si1072903wjc.77.2015.11.04.14.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 14:22:51 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 8/8] mm: memcontrol: hook up vmpressure to socket pressure
Date: Wed,  4 Nov 2015 17:22:14 -0500
Message-Id: <1446675734-25671-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
References: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Let the networking stack know when a memcg is under reclaim pressure
so that it can clamp its transmit windows accordingly.

Whenever the reclaim efficiency of a cgroup's LRU lists drops low
enough for a MEDIUM or HIGH vmpressure event to occur, assert a
pressure state in the socket and tcp memory code that tells it to curb
consumption growth from sockets associated with said control group.

vmpressure events are naturally edge triggered, so for hysteresis
assert socket pressure for a second to allow for subsequent vmpressure
events to occur before letting the socket code return to normal.

This will likely need finetuning for a wider variety of workloads, but
for now stick to the vmpressure presets and keep hysteresis simple.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 27 +++++++++++++++++++++++++--
 mm/memcontrol.c            | 15 +--------------
 mm/vmpressure.c            | 25 ++++++++++++++++++++-----
 3 files changed, 46 insertions(+), 21 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7adabb7..d45379a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -247,6 +247,7 @@ struct mem_cgroup {
 
 #ifdef CONFIG_INET
 	struct work_struct socket_work;
+	unsigned long socket_pressure;
 #endif
 
 	/* List of events which userspace want to receive */
@@ -292,18 +293,34 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
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
@@ -695,7 +712,13 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
-	return memcg->skmem_breached;
+	if (memcg->skmem_breached)
+		return true;
+	do {
+		if (time_before(jiffies, memcg->socket_pressure))
+			return true;
+	} while ((memcg = parent_mem_cgroup(memcg)));
+	return false;
 }
 #else
 static inline bool mem_cgroup_do_sockets(void)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2994c9d..e10637f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1084,9 +1084,6 @@ bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
 	return ret;
 }
 
-#define mem_cgroup_from_counter(counter, member)	\
-	container_of(counter, struct mem_cgroup, member)
-
 /**
  * mem_cgroup_margin - calculate chargeable space of a memory cgroup
  * @memcg: the memory cgroup
@@ -4126,17 +4123,6 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
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
 static void socket_work_func(struct work_struct *work);
 
 static struct cgroup_subsys_state * __ref
@@ -4181,6 +4167,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 #endif
 #ifdef CONFIG_INET
 	INIT_WORK(&memcg->socket_work, socket_work_func);
+	memcg->socket_pressure = jiffies;
 #endif
 	return &memcg->css;
 
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 4c25e62..07e8440 100644
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
@@ -162,6 +159,7 @@ static bool vmpressure_event(struct vmpressure *vmpr,
 static void vmpressure_work_fn(struct work_struct *work)
 {
 	struct vmpressure *vmpr = work_to_vmpressure(work);
+	enum vmpressure_levels level;
 	unsigned long scanned;
 	unsigned long reclaimed;
 
@@ -185,8 +183,25 @@ static void vmpressure_work_fn(struct work_struct *work)
 	vmpr->reclaimed = 0;
 	spin_unlock(&vmpr->sr_lock);
 
+	level = vmpressure_calc_level(scanned, reclaimed);
+
+	if (level > VMPRESSURE_LOW) {
+		struct mem_cgroup *memcg;
+		/*
+		 * Let the socket buffer allocator know that we are
+		 * having trouble reclaiming LRU pages.
+		 *
+		 * For hysteresis, keep the pressure state asserted
+		 * for a second in which subsequent pressure events
+		 * can occur.
+		 */
+		memcg = container_of(vmpr, struct mem_cgroup, vmpressure);
+		if (memcg != root_mem_cgroup)
+			memcg->socket_pressure = jiffies + HZ;
+	}
+
 	do {
-		if (vmpressure_event(vmpr, scanned, reclaimed))
+		if (vmpressure_event(vmpr, level))
 			break;
 		/*
 		 * If not handled, propagate the event upward into the
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
