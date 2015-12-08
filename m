Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D4DEC82F65
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:31:26 -0500 (EST)
Received: by wmvv187 with SMTP id v187so218769862wmv.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:31:26 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 141si5616407wmg.56.2015.12.08.07.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 07:31:24 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 14/14] mm: memcontrol: switch to the updated jump-label API
Date: Tue,  8 Dec 2015 10:30:24 -0500
Message-Id: <1449588624-9220-15-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

According to <linux/jump_label.h> the direct use of struct static_key
is deprecated. Update the socket and slab accounting code accordingly.

Reported-by: Jason Baron <jbaron@akamai.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  8 ++++----
 mm/memcontrol.c            | 12 ++++++------
 net/ipv4/tcp_memcontrol.c  |  4 ++--
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e4f6721..189f04d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -708,8 +708,8 @@ void sock_release_memcg(struct sock *sk);
 bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 #if defined(CONFIG_MEMCG) && defined(CONFIG_INET)
-extern struct static_key memcg_sockets_enabled_key;
-#define mem_cgroup_sockets_enabled static_key_false(&memcg_sockets_enabled_key)
+extern struct static_key_false memcg_sockets_enabled_key;
+#define mem_cgroup_sockets_enabled static_branch_unlikely(&memcg_sockets_enabled_key)
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
 #ifdef CONFIG_MEMCG_KMEM
@@ -731,7 +731,7 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 #endif
 
 #ifdef CONFIG_MEMCG_KMEM
-extern struct static_key memcg_kmem_enabled_key;
+extern struct static_key_false memcg_kmem_enabled_key;
 
 extern int memcg_nr_cache_ids;
 void memcg_get_cache_ids(void);
@@ -747,7 +747,7 @@ void memcg_put_cache_ids(void);
 
 static inline bool memcg_kmem_enabled(void)
 {
-	return static_key_false(&memcg_kmem_enabled_key);
+	return static_branch_unlikely(&memcg_kmem_enabled_key);
 }
 
 static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a0da91f..5fe45d68 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -346,7 +346,7 @@ void memcg_put_cache_ids(void)
  * conditional to this static branch, we'll have to allow modules that does
  * kmem_cache_alloc and the such to see this symbol as well
  */
-struct static_key memcg_kmem_enabled_key;
+DEFINE_STATIC_KEY_FALSE(memcg_kmem_enabled_key);
 EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
 #endif /* CONFIG_MEMCG_KMEM */
@@ -2883,7 +2883,7 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 	err = page_counter_limit(&memcg->kmem, nr_pages);
 	VM_BUG_ON(err);
 
-	static_key_slow_inc(&memcg_kmem_enabled_key);
+	static_branch_inc(&memcg_kmem_enabled_key);
 	/*
 	 * A memory cgroup is considered kmem-active as soon as it gets
 	 * kmemcg_id. Setting the id after enabling static branching will
@@ -3622,7 +3622,7 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 	if (memcg->kmem_acct_activated) {
 		memcg_destroy_kmem_caches(memcg);
-		static_key_slow_dec(&memcg_kmem_enabled_key);
+		static_branch_dec(&memcg_kmem_enabled_key);
 		WARN_ON(page_counter_read(&memcg->kmem));
 	}
 	tcp_destroy_cgroup(memcg);
@@ -4258,7 +4258,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 
 #ifdef CONFIG_INET
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
-		static_key_slow_inc(&memcg_sockets_enabled_key);
+		static_branch_inc(&memcg_sockets_enabled_key);
 #endif
 
 	/*
@@ -4302,7 +4302,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	memcg_destroy_kmem(memcg);
 #ifdef CONFIG_INET
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
-		static_key_slow_dec(&memcg_sockets_enabled_key);
+		static_branch_dec(&memcg_sockets_enabled_key);
 #endif
 	__mem_cgroup_free(memcg);
 }
@@ -5494,7 +5494,7 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 
 #ifdef CONFIG_INET
 
-struct static_key memcg_sockets_enabled_key;
+DEFINE_STATIC_KEY_FALSE(memcg_sockets_enabled_key);
 EXPORT_SYMBOL(memcg_sockets_enabled_key);
 
 void sock_update_memcg(struct sock *sk)
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 9a22e2d..18bc7f7 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -34,7 +34,7 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 		return;
 
 	if (memcg->tcp_mem.active)
-		static_key_slow_dec(&memcg_sockets_enabled_key);
+		static_branch_dec(&memcg_sockets_enabled_key);
 }
 
 static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
@@ -65,7 +65,7 @@ static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 		 * because when this value change, the code to process it is not
 		 * patched in yet.
 		 */
-		static_key_slow_inc(&memcg_sockets_enabled_key);
+		static_branch_inc(&memcg_sockets_enabled_key);
 		memcg->tcp_mem.active = true;
 	}
 
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
