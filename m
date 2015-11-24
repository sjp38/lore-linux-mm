Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8164B6B0261
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:53:10 -0500 (EST)
Received: by wmww144 with SMTP id w144so156918790wmw.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:53:10 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v189si1005957wmg.35.2015.11.24.13.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:53:09 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 11/13] mm: memcontrol: move socket code for unified hierarchy accounting
Date: Tue, 24 Nov 2015 16:52:03 -0500
Message-Id: <1448401925-22501-12-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The unified hierarchy memory controller will account socket
memory. Move the infrastructure functions accordingly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 148 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 74 insertions(+), 74 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6b8c0f7..ed030b5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -294,80 +294,6 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 	return mem_cgroup_from_css(css);
 }
 
-/* Writing them here to avoid exposing memcg's inner layout */
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
-
-struct static_key memcg_sockets_enabled_key;
-EXPORT_SYMBOL(memcg_sockets_enabled_key);
-
-void sock_update_memcg(struct sock *sk)
-{
-	struct mem_cgroup *memcg;
-
-	/* Socket cloning can throw us here with sk_cgrp already
-	 * filled. It won't however, necessarily happen from
-	 * process context. So the test for root memcg given
-	 * the current task's memcg won't help us in this case.
-	 *
-	 * Respecting the original socket's memcg is a better
-	 * decision in this case.
-	 */
-	if (sk->sk_memcg) {
-		BUG_ON(mem_cgroup_is_root(sk->sk_memcg));
-		css_get(&sk->sk_memcg->css);
-		return;
-	}
-
-	rcu_read_lock();
-	memcg = mem_cgroup_from_task(current);
-	if (memcg != root_mem_cgroup &&
-	    memcg->tcp_mem.active &&
-	    css_tryget_online(&memcg->css))
-		sk->sk_memcg = memcg;
-	rcu_read_unlock();
-}
-EXPORT_SYMBOL(sock_update_memcg);
-
-void sock_release_memcg(struct sock *sk)
-{
-	WARN_ON(!sk->sk_memcg);
-	css_put(&sk->sk_memcg->css);
-}
-
-/**
- * mem_cgroup_charge_skmem - charge socket memory
- * @memcg: memcg to charge
- * @nr_pages: number of pages to charge
- *
- * Charges @nr_pages to @memcg. Returns %true if the charge fit within
- * @memcg's configured limit, %false if the charge had to be forced.
- */
-bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
-{
-	struct page_counter *counter;
-
-	if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
-				    nr_pages, &counter)) {
-		memcg->tcp_mem.memory_pressure = 0;
-		return true;
-	}
-	page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
-	memcg->tcp_mem.memory_pressure = 1;
-	return false;
-}
-
-/**
- * mem_cgroup_uncharge_skmem - uncharge socket memory
- * @memcg - memcg to uncharge
- * @nr_pages - number of pages to uncharge
- */
-void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
-{
-	page_counter_uncharge(&memcg->tcp_mem.memory_allocated, nr_pages);
-}
-
-#endif
-
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
@@ -5544,6 +5470,80 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 	commit_charge(newpage, memcg, true);
 }
 
+/* Writing them here to avoid exposing memcg's inner layout */
+#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
+
+struct static_key memcg_sockets_enabled_key;
+EXPORT_SYMBOL(memcg_sockets_enabled_key);
+
+void sock_update_memcg(struct sock *sk)
+{
+	struct mem_cgroup *memcg;
+
+	/* Socket cloning can throw us here with sk_cgrp already
+	 * filled. It won't however, necessarily happen from
+	 * process context. So the test for root memcg given
+	 * the current task's memcg won't help us in this case.
+	 *
+	 * Respecting the original socket's memcg is a better
+	 * decision in this case.
+	 */
+	if (sk->sk_memcg) {
+		BUG_ON(mem_cgroup_is_root(sk->sk_memcg));
+		css_get(&sk->sk_memcg->css);
+		return;
+	}
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(current);
+	if (memcg != root_mem_cgroup &&
+	    memcg->tcp_mem.active &&
+	    css_tryget_online(&memcg->css))
+		sk->sk_memcg = memcg;
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(sock_update_memcg);
+
+void sock_release_memcg(struct sock *sk)
+{
+	WARN_ON(!sk->sk_memcg);
+	css_put(&sk->sk_memcg->css);
+}
+
+/**
+ * mem_cgroup_charge_skmem - charge socket memory
+ * @memcg: memcg to charge
+ * @nr_pages: number of pages to charge
+ *
+ * Charges @nr_pages to @memcg. Returns %true if the charge fit within
+ * @memcg's configured limit, %false if the charge had to be forced.
+ */
+bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
+{
+	struct page_counter *counter;
+
+	if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
+				    nr_pages, &counter)) {
+		memcg->tcp_mem.memory_pressure = 0;
+		return true;
+	}
+	page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
+	memcg->tcp_mem.memory_pressure = 1;
+	return false;
+}
+
+/**
+ * mem_cgroup_uncharge_skmem - uncharge socket memory
+ * @memcg - memcg to uncharge
+ * @nr_pages - number of pages to uncharge
+ */
+void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
+{
+	page_counter_uncharge(&memcg->tcp_mem.memory_allocated, nr_pages);
+}
+
+#endif
+
 /*
  * subsys_initcall() for memory controller.
  *
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
