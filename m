Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 258336B010F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 12:42:43 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [RFC] simple system for enable/disable slabs being tracked by memcg.
Date: Wed, 28 Mar 2012 18:42:25 +0200
Message-Id: <1332952945-15909-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Glauber Costa <glommer@parallels.com>, Suleiman Souhlal <suleiman@google.com>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

Hi.

This is a proposal I've got for how to finally settle down the
question of which slabs should be tracked. The patch I am providing
is for discussion only, and should apply ontop of Suleiman's latest
version posted to the list.

The idea is to create a new file, memory.kmem.slabs_allowed.
I decided not to overload the slabinfo file for that, but I can,
if you ultimately want to. I just think it is cleaner this way.
As a small rationale, I'd like to somehow show which caches are
available but disabled. And yet, keep the format compatible with
/proc/slabinfo.

Reading from this file will provide this information
Writers should write a string:
 [+-]cache_name

The wild card * is accepted, but only that. I am leaving
any complex processing to userspace.

The * wildcard, though, is nice. It allows us to do:
 -* (disable all)
 +cache1
 +cache2

and so on.

Part of this patch is actually converting the slab pointers in memcg
to a complex memcg-specific structure that can hold a disabled pointer.

We could actually store it in a free bit in the address, but that is
a first version. Let me know if this is how you would like me to tackle
this.

With a system like this (either this, or something alike), my opposition
to Suleiman's idea of tracking everything under the sun basically vanishes,
since I can then selectively disable most of them.

I still prefer a special kmalloc call than a GFP flag, though.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h |   17 ++++++++
 include/linux/slab.h       |   13 ++++++
 mm/memcontrol.c            |   87 ++++++++++++++++++++++++++++++++++----
 mm/slab.c                  |   99 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 207 insertions(+), 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f5458b0..acd38a5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -427,6 +427,9 @@ bool mem_cgroup_charge_slab(struct kmem_cache *cachep, gfp_t gfp, size_t size);
 void mem_cgroup_uncharge_slab(struct kmem_cache *cachep, size_t size);
 void mem_cgroup_flush_cache_create_queue(void);
 void mem_cgroup_remove_child_kmem_cache(struct kmem_cache *cachep, int id);
+int mem_cgroup_slab_allowed(struct mem_cgroup *memcg, int id);
+void mem_cgroup_slab_allow(struct mem_cgroup *memcg, int id);
+void mem_cgroup_slab_disallow(struct mem_cgroup *memcg, int id);
 #else /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
 static inline void sock_update_memcg(struct sock *sk)
 {
@@ -456,6 +459,20 @@ static inline void
 mem_cgroup_flush_cache_create_queue(void)
 {
 }
+
+int mem_cgroup_slab_allowed(struct mem_cgroup *memcg, int id)
+{
+	return 0;
+}
+
+void mem_cgroup_slab_disallow(struct mem_cgroup *memcg, int id)
+{
+}
+
+void mem_cgroup_slab_allow(struct mem_cgroup *memcg, int id)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 0ff5ee2..3106843 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -380,6 +380,8 @@ void kmem_cache_drop_ref(struct kmem_cache *cachep);
 
 void *kmalloc_no_account(size_t size, gfp_t flags);
 
+int mem_cgroup_tune_slab(struct mem_cgroup *mem, const char *buffer);
+int mem_cgroup_probe_slab(struct mem_cgroup *mem, struct seq_file *m);
 #else /* !CONFIG_CGROUP_MEM_RES_CTLR_KMEM || !CONFIG_SLAB */
 
 #define MAX_KMEM_CACHE_TYPES 0
@@ -407,6 +409,17 @@ mem_cgroup_slabinfo(struct mem_cgroup *mem, struct seq_file *m)
 	return 0;
 }
 
+static inline int mem_cgroup_tune_slab(struct mem_cgroup *mem, const char *buffer)
+{
+	return 0;
+}
+
+static inline int mem_cgroup_probe_slab(struct mem_cgroup *mem, const char *buffer)
+{
+	return 0;
+}
+
+
 #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM && CONFIG_SLAB */
 
 #endif	/* _LINUX_SLAB_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba042d9..e8c6a92 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -226,6 +226,11 @@ enum memcg_flags {
 					 */
 };
 
+struct memcg_slab {
+	struct kmem_cache *cache;
+	bool disabled;
+};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -305,7 +310,7 @@ struct mem_cgroup {
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
 	/* Slab accounting */
-	struct kmem_cache *slabs[MAX_KMEM_CACHE_TYPES];
+	struct memcg_slab slabs[MAX_KMEM_CACHE_TYPES];
 #endif
 };
 
@@ -4671,6 +4676,21 @@ static int mem_cgroup_independent_kmem_limit_write(struct cgroup *cgrp,
 	return 0;
 }
 
+int mem_cgroup_slab_allowed(struct mem_cgroup *memcg, int idx)
+{
+	return !memcg->slabs[idx].disabled;
+}
+
+void mem_cgroup_slab_allow(struct mem_cgroup *memcg, int idx)
+{
+	memcg->slabs[idx].disabled = false;
+}
+
+void mem_cgroup_slab_disallow(struct mem_cgroup *memcg, int idx)
+{
+	memcg->slabs[idx].disabled = true;
+}
+
 static int
 mem_cgroup_slabinfo_show(struct cgroup *cgroup, struct cftype *ctf,
     struct seq_file *m)
@@ -4685,6 +4705,35 @@ mem_cgroup_slabinfo_show(struct cgroup *cgroup, struct cftype *ctf,
 	return mem_cgroup_slabinfo(mem, m);
 }
 
+static int mem_cgroup_slabs_read(struct cgroup *cgroup, struct cftype *ctf,
+				 struct seq_file *m)
+{
+	struct mem_cgroup *mem;
+
+	mem  = mem_cgroup_from_cont(cgroup);
+
+	if (mem == root_mem_cgroup)
+		return -EINVAL;
+
+	if (!list_empty(&cgroup->children))
+		return -EBUSY;
+
+	return mem_cgroup_probe_slab(mem, m);
+}
+
+static int mem_cgroup_slabs_write(struct cgroup *cgroup, struct cftype *cft,
+				  const char *buffer)
+{
+	struct mem_cgroup *mem;
+
+	mem  = mem_cgroup_from_cont(cgroup);
+
+	if (mem == root_mem_cgroup)
+		return -EINVAL;
+
+	return mem_cgroup_tune_slab(mem, buffer);
+}
+
 static struct cftype kmem_cgroup_files[] = {
 	{
 		.name = "kmem.independent_kmem_limit",
@@ -4706,6 +4755,12 @@ static struct cftype kmem_cgroup_files[] = {
 		.name = "kmem.slabinfo",
 		.read_seq_string = mem_cgroup_slabinfo_show,
 	},
+	{
+		.name = "kmem.slabs_allowed",
+		.read_seq_string = mem_cgroup_slabs_read,
+		.write_string = mem_cgroup_slabs_write,
+	},
+
 };
 
 static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
@@ -5765,7 +5820,7 @@ memcg_create_kmem_cache(struct mem_cgroup *memcg, struct kmem_cache *cachep)
 	 * This should behave as a write barrier, so we should be fine
 	 * with RCU.
 	 */
-	if (cmpxchg(&memcg->slabs[idx], NULL, new_cachep) != NULL) {
+	if (cmpxchg(&memcg->slabs[idx].cache, NULL, new_cachep) != NULL) {
 		kmem_cache_destroy(new_cachep);
 		return cachep;
 	}
@@ -5838,6 +5893,7 @@ memcg_create_cache_enqueue(struct mem_cgroup *memcg, struct kmem_cache *cachep)
 {
 	struct create_work *cw;
 	unsigned long flags;
+	int idx;
 
 	spin_lock_irqsave(&create_queue_lock, flags);
 	list_for_each_entry(cw, &create_queue, list) {
@@ -5848,6 +5904,14 @@ memcg_create_cache_enqueue(struct mem_cgroup *memcg, struct kmem_cache *cachep)
 	}
 	spin_unlock_irqrestore(&create_queue_lock, flags);
 
+	/*
+	 * If this cache is disabled, it basically means we are doing
+	 * global accounting for that particular cache. So skip it
+	 */
+	idx = cachep->memcg_params.id;
+	if (memcg->slabs[idx].disabled)
+		return;
+
 	/* The corresponding put will be done in the workqueue. */
 	if (!css_tryget(&memcg->css))
 		return;
@@ -5912,18 +5976,18 @@ mem_cgroup_get_kmem_cache(struct kmem_cache *cachep, gfp_t gfp)
 
 	VM_BUG_ON(idx == -1);
 
-	if (rcu_access_pointer(memcg->slabs[idx]) == NULL) {
+	if (rcu_access_pointer(memcg->slabs[idx].cache) == NULL) {
 		memcg_create_cache_enqueue(memcg, cachep);
 		return cachep;
 	}
 
-	return rcu_dereference(memcg->slabs[idx]);
+	return rcu_dereference(memcg->slabs[idx].cache);
 }
 
 void
 mem_cgroup_remove_child_kmem_cache(struct kmem_cache *cachep, int id)
 {
-	rcu_assign_pointer(cachep->memcg_params.memcg->slabs[id], NULL);
+	rcu_assign_pointer(cachep->memcg_params.memcg->slabs[id].cache, NULL);
 }
 
 bool
@@ -5966,10 +6030,15 @@ mem_cgroup_uncharge_slab(struct kmem_cache *cachep, size_t size)
 static void
 memcg_slab_init(struct mem_cgroup *memcg)
 {
+	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
 	int i;
 
-	for (i = 0; i < MAX_KMEM_CACHE_TYPES; i++)
-		rcu_assign_pointer(memcg->slabs[i], NULL);
+	for (i = 0; i < MAX_KMEM_CACHE_TYPES; i++) {
+		rcu_assign_pointer(memcg->slabs[i].cache, NULL);
+		if (parent)
+			memcg->slabs[i].disabled =
+			parent->slabs[i].disabled;
+	}
 }
 
 /*
@@ -5988,9 +6057,9 @@ memcg_slab_move(struct mem_cgroup *memcg)
 	mem_cgroup_flush_cache_create_queue();
 
 	for (i = 0; i < MAX_KMEM_CACHE_TYPES; i++) {
-		cachep = rcu_access_pointer(memcg->slabs[i]);
+		cachep = rcu_access_pointer(memcg->slabs[i].cache);
 		if (cachep != NULL) {
-			rcu_assign_pointer(memcg->slabs[i], NULL);
+			rcu_assign_pointer(memcg->slabs[i].cache, NULL);
 			cachep->memcg_params.memcg = NULL;
 
 			/* The space for this is already allocated */
diff --git a/mm/slab.c b/mm/slab.c
index 1b35799..1bf13f1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4766,6 +4766,105 @@ mem_cgroup_slabinfo(struct mem_cgroup *mem, struct seq_file *m)
 
 	return 0;
 }
+
+int mem_cgroup_probe_slab(struct mem_cgroup *memcg, struct seq_file *m)
+{
+	struct kmem_cache *cachep;
+
+	seq_printf(m, "Available slabs:\n");
+
+	mutex_lock(&cache_chain_mutex);
+	list_for_each_entry(cachep, &cache_chain, next) {
+		bool allowed;
+		if (cachep->memcg_params.id == -1)
+			continue;
+
+		if (!(cachep->flags & SLAB_MEMCG_ACCT))
+			continue;
+
+		allowed = !mem_cgroup_slab_allowed(memcg, cachep->memcg_params.id);
+
+		seq_printf(m, "%c %-17s\n", allowed ? '*' : ' ', cachep->name);
+	}
+	mutex_unlock(&cache_chain_mutex);
+
+	return 0;
+}
+
+/*
+ * selects which slabs are tracked in this memcg, from the pool of available
+ * slabs.
+ *
+ * Not worth to implement a full regex parser. Pre-processing can be done in
+ * userspace if needed. It helps, however, to at least have a * wildcard for
+ * groups of cache, like size-*.
+ *
+ * The first character is either a + or a -, meaning either add or remove
+ * a particular cache from the list of tracked caches.
+ */
+int mem_cgroup_tune_slab(struct mem_cgroup *mem, const char *buffer)
+{
+	struct kmem_cache *cachep;
+	int op;
+	int ret = -EINVAL;
+
+	if (!buffer)
+		return ret;
+
+	if (*buffer == '+' )
+		op = 1;
+	else if (*buffer == '-')
+		op = 0;
+	else
+		return ret;
+	
+	buffer++;
+
+	mutex_lock(&cache_chain_mutex);
+	list_for_each_entry(cachep, &cache_chain, next) {
+		const char *cname = cachep->name;
+		const char *ptr = buffer;
+		const char *next = NULL;
+
+		if (cachep->memcg_params.id == -1)
+			continue;
+
+		while (*ptr && *cname) {
+			if (*ptr == '*') {
+				if (!next) {
+					next = ptr;
+					next++;
+				} 
+				if (*next == *cname) {
+					next = NULL;
+					ptr++;	
+					continue;
+				}
+				cname++;
+				if (!*cname)
+					ptr++;
+				continue;
+			} else if (*ptr != *cname)
+				break;
+			ptr++;
+			cname++;
+		}
+		if (*cname || *ptr)
+			continue;
+		ret = 0;
+
+		if (op == 0)
+			mem_cgroup_slab_disallow(mem, cachep->memcg_params.id);
+		else if (op == 1)
+			mem_cgroup_slab_allow(mem, cachep->memcg_params.id);
+		else
+			BUG();
+	}
+
+	mutex_unlock(&cache_chain_mutex);
+	return ret;
+}
+
 #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
 
 #ifdef CONFIG_DEBUG_SLAB_LEAK
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
