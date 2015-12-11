Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 796536B0256
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:54:33 -0500 (EST)
Received: by wmec201 with SMTP id c201so84759829wme.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:54:33 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bz19si27587751wjb.232.2015.12.11.11.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 11:54:32 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/4] mm: memcontrol: flatten struct cg_proto
Date: Fri, 11 Dec 2015 14:54:12 -0500
Message-Id: <1449863653-6546-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

There are no more external users of struct cg_proto, flatten the
structure into struct mem_cgroup.

Since using those struct members doesn't stand out as much anymore,
add cgroup2 static branches to make it clearer which code is legacy.

Suggested-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 14 ++++++--------
 mm/memcontrol.c            | 33 +++++++++++++++------------------
 2 files changed, 21 insertions(+), 26 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 47995b4..a3869bf 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -85,12 +85,6 @@ enum mem_cgroup_events_target {
 	MEM_CGROUP_NTARGETS,
 };
 
-struct cg_proto {
-	struct page_counter	memory_allocated;	/* Current allocated memory. */
-	int			memory_pressure;
-	bool			active;
-};
-
 #ifdef CONFIG_MEMCG
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
@@ -169,8 +163,11 @@ struct mem_cgroup {
 
 	/* Accounted resources */
 	struct page_counter memory;
+
+	/* Legacy consumer-oriented counters */
 	struct page_counter memsw;
 	struct page_counter kmem;
+	struct page_counter tcpmem;
 
 	/* Normal memory consumption range */
 	unsigned long low;
@@ -236,7 +233,8 @@ struct mem_cgroup {
 	unsigned long		socket_pressure;
 
 	/* Legacy tcp memory accounting */
-	struct cg_proto tcp_mem;
+	bool			tcpmem_active;
+	int			tcpmem_pressure;
 
 #ifndef CONFIG_SLOB
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
@@ -715,7 +713,7 @@ extern struct static_key_false memcg_sockets_enabled_key;
 #define mem_cgroup_sockets_enabled static_branch_unlikely(&memcg_sockets_enabled_key)
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
-	if (memcg->tcp_mem.memory_pressure)
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && memcg->tcpmem_pressure)
 		return true;
 	do {
 		if (time_before(jiffies, memcg->socket_pressure))
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 422ff3f..306842c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2822,7 +2822,7 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 		counter = &memcg->kmem;
 		break;
 	case _TCP:
-		counter = &memcg->tcp_mem.memory_allocated;
+		counter = &memcg->tcpmem;
 		break;
 	default:
 		BUG();
@@ -3007,11 +3007,11 @@ static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
 
 	mutex_lock(&memcg_limit_mutex);
 
-	ret = page_counter_limit(&memcg->tcp_mem.memory_allocated, limit);
+	ret = page_counter_limit(&memcg->tcpmem, limit);
 	if (ret)
 		goto out;
 
-	if (!memcg->tcp_mem.active) {
+	if (!memcg->tcpmem_active) {
 		/*
 		 * The active flag needs to be written after the static_key
 		 * update. This is what guarantees that the socket activation
@@ -3029,7 +3029,7 @@ static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
 		 * patched in yet.
 		 */
 		static_branch_inc(&memcg_sockets_enabled_key);
-		memcg->tcp_mem.active = true;
+		memcg->tcpmem_active = true;
 	}
 out:
 	mutex_unlock(&memcg_limit_mutex);
@@ -3098,7 +3098,7 @@ static ssize_t mem_cgroup_reset(struct kernfs_open_file *of, char *buf,
 		counter = &memcg->kmem;
 		break;
 	case _TCP:
-		counter = &memcg->tcp_mem.memory_allocated;
+		counter = &memcg->tcpmem;
 		break;
 	default:
 		BUG();
@@ -4273,8 +4273,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, &parent->memsw);
 		page_counter_init(&memcg->kmem, &parent->kmem);
-		page_counter_init(&memcg->tcp_mem.memory_allocated,
-				  &parent->tcp_mem.memory_allocated);
+		page_counter_init(&memcg->tcpmem, &parent->tcpmem);
 
 		/*
 		 * No need to take a reference to the parent because cgroup
@@ -4286,7 +4285,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
-		page_counter_init(&memcg->tcp_mem.memory_allocated, NULL);
+		page_counter_init(&memcg->tcpmem, NULL);
 		/*
 		 * Deeper hierachy with use_hierarchy == false doesn't make
 		 * much sense so let cgroup subsystem know about this
@@ -4345,7 +4344,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_dec(&memcg_sockets_enabled_key);
 
-	if (memcg->tcp_mem.active)
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && memcg->tcpmem_active)
 		static_branch_dec(&memcg_sockets_enabled_key);
 
 	memcg_free_kmem(memcg);
@@ -5572,7 +5571,7 @@ void sock_update_memcg(struct sock *sk)
 	memcg = mem_cgroup_from_task(current);
 	if (memcg == root_mem_cgroup)
 		goto out;
-	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && !memcg->tcp_mem.active)
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && !memcg->tcpmem_active)
 		goto out;
 	if (css_tryget_online(&memcg->css))
 		sk->sk_memcg = memcg;
@@ -5600,15 +5599,14 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 	gfp_t gfp_mask = GFP_KERNEL;
 
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
-		struct page_counter *counter;
+		struct page_counter *fail;
 
-		if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
-					    nr_pages, &counter)) {
-			memcg->tcp_mem.memory_pressure = 0;
+		if (page_counter_try_charge(&memcg->tcpmem, nr_pages, &fail)) {
+			memcg->tcpmem_pressure = 0;
 			return true;
 		}
-		page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
-		memcg->tcp_mem.memory_pressure = 1;
+		page_counter_charge(&memcg->tcpmem, nr_pages);
+		memcg->tcpmem_pressure = 1;
 		return false;
 	}
 
@@ -5631,8 +5629,7 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
-		page_counter_uncharge(&memcg->tcp_mem.memory_allocated,
-				      nr_pages);
+		page_counter_uncharge(&memcg->tcpmem, nr_pages);
 		return;
 	}
 
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
