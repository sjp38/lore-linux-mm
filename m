Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4B982F65
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 00:22:07 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so117761142wic.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:22:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f9si4871006wiy.5.2015.10.21.21.22.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 21:22:05 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/8] mm: memcontrol: prepare for unified hierarchy socket accounting
Date: Thu, 22 Oct 2015 00:21:32 -0400
Message-Id: <1445487696-21545-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The unified hierarchy memory controller will account socket
memory. Move the infrastructure functions accordingly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 136 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 68 insertions(+), 68 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c41e6d7..3789050 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -287,74 +287,6 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 	return mem_cgroup_from_css(css);
 }
 
-/* Writing them here to avoid exposing memcg's inner layout */
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
-
-DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
-
-void sock_update_memcg(struct sock *sk)
-{
-	struct mem_cgroup *memcg;
-	/*
-	 * Socket cloning can throw us here with sk_cgrp already
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
-	if (css_tryget_online(&memcg->css))
-		sk->sk_memcg = memcg;
-	rcu_read_unlock();
-}
-EXPORT_SYMBOL(sock_update_memcg);
-
-void sock_release_memcg(struct sock *sk)
-{
-	if (sk->sk_memcg)
-		css_put(&sk->sk_memcg->css);
-}
-
-/**
- * mem_cgroup_charge_skmem - charge socket memory
- * @memcg: memcg to charge
- * @nr_pages: number of pages to charge
- *
- * Charges @nr_pages to @memcg. Returns %true if the charge fit within
- * the memcg's configured limit, %false if the charge had to be forced.
- */
-bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
-{
-	struct page_counter *counter;
-
-	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
-		return true;
-
-	page_counter_charge(&memcg->skmem, nr_pages);
-	return false;
-}
-
-/**
- * mem_cgroup_uncharge_skmem - uncharge socket memory
- * @memcg: memcg to uncharge
- * @nr_pages: number of pages to uncharge
- */
-void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
-{
-	page_counter_uncharge(&memcg->skmem, nr_pages);
-}
-
-#endif
-
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
@@ -5521,6 +5453,74 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 	commit_charge(newpage, memcg, true);
 }
 
+/* Writing them here to avoid exposing memcg's inner layout */
+#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
+
+DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
+
+void sock_update_memcg(struct sock *sk)
+{
+	struct mem_cgroup *memcg;
+	/*
+	 * Socket cloning can throw us here with sk_cgrp already
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
+	if (css_tryget_online(&memcg->css))
+		sk->sk_memcg = memcg;
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(sock_update_memcg);
+
+void sock_release_memcg(struct sock *sk)
+{
+	if (sk->sk_memcg)
+		css_put(&sk->sk_memcg->css);
+}
+
+/**
+ * mem_cgroup_charge_skmem - charge socket memory
+ * @memcg: memcg to charge
+ * @nr_pages: number of pages to charge
+ *
+ * Charges @nr_pages to @memcg. Returns %true if the charge fit within
+ * the memcg's configured limit, %false if the charge had to be forced.
+ */
+bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
+{
+	struct page_counter *counter;
+
+	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
+		return true;
+
+	page_counter_charge(&memcg->skmem, nr_pages);
+	return false;
+}
+
+/**
+ * mem_cgroup_uncharge_skmem - uncharge socket memory
+ * @memcg: memcg to uncharge
+ * @nr_pages: number of pages to uncharge
+ */
+void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
+{
+	page_counter_uncharge(&memcg->skmem, nr_pages);
+}
+
+#endif
+
 /*
  * subsys_initcall() for memory controller.
  *
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
