Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id F21CC6B025F
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:34:57 -0500 (EST)
Received: by wmec201 with SMTP id c201so225381657wme.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:34:57 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p21si32047667wmb.101.2015.12.08.10.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 10:34:57 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 5/8] mm: memcontrol: separate kmem code from legacy tcp accounting code
Date: Tue,  8 Dec 2015 13:34:22 -0500
Message-Id: <1449599665-18047-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The cgroup2 memory controller will include important in-kernel memory
consumers per default, including socket memory, but it will no longer
carry the historic tcp control interface.

Separate the kmem state init from the tcp control interface init in
preparation for that.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 33 ++++++++++++---------------------
 1 file changed, 12 insertions(+), 21 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5118618..55a3f07 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2925,17 +2925,6 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	return ret;
 }
 
-static int memcg_init_kmem(struct mem_cgroup *memcg)
-{
-	int ret;
-
-	ret = memcg_propagate_kmem(memcg);
-	if (ret)
-		return ret;
-
-	return tcp_init_cgroup(memcg);
-}
-
 static void memcg_offline_kmem(struct mem_cgroup *memcg)
 {
 	struct cgroup_subsys_state *css;
@@ -2988,7 +2977,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 		static_branch_dec(&memcg_kmem_enabled_key);
 		WARN_ON(page_counter_read(&memcg->kmem));
 	}
-	tcp_destroy_cgroup(memcg);
 }
 #else
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
@@ -2996,16 +2984,9 @@ static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 {
 	return -EINVAL;
 }
-static int memcg_init_kmem(struct mem_cgroup *memcg)
-{
-	return 0;
-}
 static void memcg_offline_kmem(struct mem_cgroup *memcg)
 {
 }
-static void memcg_free_kmem(struct mem_cgroup *memcg)
-{
-}
 #endif /* CONFIG_MEMCG_KMEM */
 
 /*
@@ -4241,9 +4222,14 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	}
 	mutex_unlock(&memcg_create_mutex);
 
-	ret = memcg_init_kmem(memcg);
+#ifdef CONFIG_MEMCG_KMEM
+	ret = memcg_propagate_kmem(memcg);
 	if (ret)
 		return ret;
+	ret = tcp_init_cgroup(memcg);
+	if (ret)
+		return ret;
+#endif
 
 #ifdef CONFIG_INET
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
@@ -4288,11 +4274,16 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
-	memcg_free_kmem(memcg);
 #ifdef CONFIG_INET
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_dec(&memcg_sockets_enabled_key);
 #endif
+
+#ifdef CONFIG_MEMCG_KMEM
+	memcg_free_kmem(memcg);
+	tcp_destroy_cgroup(memcg);
+#endif
+
 	__mem_cgroup_free(memcg);
 }
 
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
