Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id EB76F82F67
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 18:42:40 -0500 (EST)
Received: by wmww144 with SMTP id w144so8707682wmw.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:42:40 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o5si21649944wjq.214.2015.11.12.15.42.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 15:42:39 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 14/14] mm: memcontrol: hook up vmpressure to socket pressure
Date: Thu, 12 Nov 2015 18:41:33 -0500
Message-Id: <1447371693-25143-15-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

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
 include/linux/memcontrol.h | 29 +++++++++++++++++++++++++----
 mm/memcontrol.c            | 15 +--------------
 mm/vmpressure.c            | 25 ++++++++++++++++++++-----
 3 files changed, 46 insertions(+), 23 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 809d6de..dba43cb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -258,6 +258,7 @@ struct mem_cgroup {
 
 #ifdef CONFIG_INET
 	struct work_struct	socket_work;
+	unsigned long		socket_pressure;
 #endif
 
 	/* List of events which userspace want to receive */
@@ -303,18 +304,34 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
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
@@ -706,10 +723,14 @@ void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
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
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cad9525..4068662 100644
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
@@ -4138,17 +4135,6 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
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
@@ -4192,6 +4178,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
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
