Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 03AE06B005A
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 07:01:59 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/2] Avoid doing a get/put pair in every kmemcg charge
Date: Tue, 14 Aug 2012 14:58:33 +0400
Message-Id: <1344941913-15075-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1344941913-15075-1-git-send-email-glommer@parallels.com>
References: <1344941913-15075-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Suleiman Souhlal <suleiman@google.com>

Since kmem charges may outlive the cgroup existance, we need to be extra
careful to guarantee the memcg object will stay around for as long as
needed. Up to now, we were using a mem_cgroup_get()/put() pair in charge
and uncharge operations.

Although this guarantees that the object will be around until the last
call to unchage, this means an atomic update in every charge. We can do
better than that if we only issue get() in the first charge, and then
put() when the last charge finally goes away.

Note that the moment we turn the limit is unfortunately not the right
moment signal that: it is possible, albeit unlikely, to have a memcg
that has kmem enabled but never gets any charges. So two more bits are
added to the existing kmem_accounted bitmap (so no space waste).  One of
them will be flipped when the first charge happens. The other, when
memcg is dead. The later will be tested in the uncharge path, and a
put() will be issued accordingly if needed.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 51 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 64a8d19..b4802af 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -352,6 +352,8 @@ struct mem_cgroup {
 enum {
 	KMEM_ACCOUNTED_THIS, /* accounted by this cgroup itself */
 	KMEM_ACCOUNTED_PARENT, /* accounted by any of its parents. */
+	KMEM_ACCOUNTED_STARTED, /* will be set on first charge */
+	KMEM_ACCOUNTED_DEAD, /* dead memcg, pending kmem charges */
 };
 
 #ifdef CONFIG_MEMCG_KMEM
@@ -379,6 +381,32 @@ static void memcg_kmem_clear_account_parent(struct mem_cgroup *memcg)
 {
 	clear_bit(KMEM_ACCOUNTED_PARENT, &memcg->kmem_accounted);
 }
+
+/*
+ * To avoid doing a get/put pair in every charge, we'll just issue get over the
+ * first charge to the group. We use a separate test_bit before test_and_set
+ * because it will be a simple read without locking the bus. Also being a
+ * likely set bit will make the performance impact low in most situations
+ */
+static bool memcg_kmem_first_charge(struct mem_cgroup *memcg)
+{
+	if (likely(test_bit(KMEM_ACCOUNTED_STARTED, &memcg->kmem_accounted)))
+		return false;
+
+	return !test_and_set_bit(KMEM_ACCOUNTED_STARTED,
+				 &memcg->kmem_accounted);
+}
+
+static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
+{
+	if (test_bit(KMEM_ACCOUNTED_STARTED, &memcg->kmem_accounted))
+		set_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_accounted);
+}
+
+static bool memcg_kmem_dead(struct mem_cgroup *memcg)
+{
+	return test_and_clear_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_accounted);
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 /* Stuffs for move charges at task migration. */
@@ -566,12 +594,9 @@ bool __memcg_kmem_new_page(gfp_t gfp, void *_handle, int order)
 	if (!memcg_kmem_enabled(memcg))
 		goto out;
 
-	mem_cgroup_get(memcg);
-
 	size = PAGE_SIZE << order;
 	ret = memcg_charge_kmem(memcg, gfp, size) == 0;
 	if (!ret) {
-		mem_cgroup_put(memcg);
 		goto out;
 	}
 
@@ -596,7 +621,6 @@ void __memcg_kmem_commit_page(struct page *page, void *handle, int order)
 		size_t size = PAGE_SIZE << order;
 
 		memcg_uncharge_kmem(memcg, size);
-		mem_cgroup_put(memcg);
 		return;
 	}
 
@@ -641,7 +665,6 @@ void __memcg_kmem_free_page(struct page *page, int order)
 	WARN_ON(mem_cgroup_is_root(memcg));
 	size = (1 << order) << PAGE_SHIFT;
 	memcg_uncharge_kmem(memcg, size);
-	mem_cgroup_put(memcg);
 }
 EXPORT_SYMBOL(__memcg_kmem_free_page);
 
@@ -4990,6 +5013,20 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
 {
 	mem_cgroup_sockets_destroy(memcg);
+
+	memcg_kmem_mark_dead(memcg);
+
+	if (res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0)
+		return;
+
+	/*
+	 * Charges already down to 0, undo mem_cgroup_get() done in the charge
+	 * path here, being careful not to race with memcg_uncharge_kmem: it is
+	 * possible that the charges went down to 0 between mark_dead and the
+	 * res_counter read, so in that case, we don't need the put
+	 */
+	if (memcg_kmem_dead(memcg))
+		mem_cgroup_put(memcg);
 }
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
@@ -6062,7 +6099,8 @@ int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, s64 delta)
 		res_counter_uncharge(&memcg->res, delta);
 		if (do_swap_account)
 			res_counter_uncharge(&memcg->memsw, delta);
-	}
+	} else if (memcg_kmem_first_charge(memcg))
+		mem_cgroup_get(memcg);
 
 	return ret;
 }
@@ -6072,9 +6110,15 @@ void memcg_uncharge_kmem(struct mem_cgroup *memcg, s64 delta)
 	if (!memcg)
 		return;
 
-	res_counter_uncharge(&memcg->kmem, delta);
 	res_counter_uncharge(&memcg->res, delta);
 	if (do_swap_account)
 		res_counter_uncharge(&memcg->memsw, delta);
+
+	/* Not down to 0 */
+	if (res_counter_uncharge(&memcg->kmem, delta))
+		return;
+
+	if (memcg_kmem_dead(memcg))
+		mem_cgroup_put(memcg);
 }
 #endif /* CONFIG_MEMCG_KMEM */
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
