Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9B36B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 06:45:35 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so81503564pad.4
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 03:45:35 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pg2si23267739pdb.161.2015.02.02.03.45.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Feb 2015 03:45:34 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] memcg: cleanup static keys decrement
Date: Mon, 2 Feb 2015 14:45:27 +0300
Message-ID: <1422877527-18186-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Move memcg_socket_limit_enabled decrement to tcp_destroy_cgroup (called
from memcg_destroy_kmem -> mem_cgroup_sockets_destroy) and zap a bunch
of wrapper functions.

Although this patch moves static keys decrement from __mem_cgroup_free
to mem_cgroup_css_free, it does not introduce any functional changes,
because the keys are incremented on setting the limit (tcp or kmem),
which can only happen after successful mem_cgroup_css_online.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/net/sock.h        |    5 -----
 mm/memcontrol.c           |   38 +++++---------------------------------
 net/ipv4/tcp_memcontrol.c |    4 ++++
 3 files changed, 9 insertions(+), 38 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 2210fec65669..28bdf874da4a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1099,11 +1099,6 @@ static inline bool memcg_proto_active(struct cg_proto *cg_proto)
 	return test_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
 }
 
-static inline bool memcg_proto_activated(struct cg_proto *cg_proto)
-{
-	return test_bit(MEMCG_SOCK_ACTIVATED, &cg_proto->flags);
-}
-
 #ifdef SOCK_REFCNT_DEBUG
 static inline void sk_refcnt_debug_inc(struct sock *sk)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3b2cc3a5413a..f1ab93daa1b7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -519,16 +519,6 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(tcp_proto_cgroup);
 
-static void disarm_sock_keys(struct mem_cgroup *memcg)
-{
-	if (!memcg_proto_activated(&memcg->tcp_mem))
-		return;
-	static_key_slow_dec(&memcg_socket_limit_enabled);
-}
-#else
-static void disarm_sock_keys(struct mem_cgroup *memcg)
-{
-}
 #endif
 
 #ifdef CONFIG_MEMCG_KMEM
@@ -583,28 +573,8 @@ void memcg_put_cache_ids(void)
 struct static_key memcg_kmem_enabled_key;
 EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
-static void disarm_kmem_keys(struct mem_cgroup *memcg)
-{
-	if (memcg->kmem_acct_activated)
-		static_key_slow_dec(&memcg_kmem_enabled_key);
-	/*
-	 * This check can't live in kmem destruction function,
-	 * since the charges will outlive the cgroup
-	 */
-	WARN_ON(page_counter_read(&memcg->kmem));
-}
-#else
-static void disarm_kmem_keys(struct mem_cgroup *memcg)
-{
-}
 #endif /* CONFIG_MEMCG_KMEM */
 
-static void disarm_static_keys(struct mem_cgroup *memcg)
-{
-	disarm_sock_keys(memcg);
-	disarm_kmem_keys(memcg);
-}
-
 static struct mem_cgroup_per_zone *
 mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
 {
@@ -4092,7 +4062,11 @@ static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
 
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
-	memcg_destroy_kmem_caches(memcg);
+	if (memcg->kmem_acct_activated) {
+		memcg_destroy_kmem_caches(memcg);
+		static_key_slow_dec(&memcg_kmem_enabled_key);
+		WARN_ON(page_counter_read(&memcg->kmem));
+	}
 	mem_cgroup_sockets_destroy(memcg);
 }
 #else
@@ -4523,8 +4497,6 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 		free_mem_cgroup_per_zone_info(memcg, node);
 
 	free_percpu(memcg->stat);
-
-	disarm_static_keys(memcg);
 	kfree(memcg);
 }
 
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index c2a75c6957a1..2379c1b4efb2 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -47,6 +47,10 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 		return;
 
 	percpu_counter_destroy(&cg_proto->sockets_allocated);
+
+	if (test_bit(MEMCG_SOCK_ACTIVATED, &cg_proto->flags))
+		static_key_slow_dec(&memcg_socket_limit_enabled);
+
 }
 EXPORT_SYMBOL(tcp_destroy_cgroup);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
