Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id CE6136B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 03:05:09 -0400 (EDT)
Message-ID: <5195D666.6030408@huawei.com>
Date: Fri, 17 May 2013 15:04:06 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 5/9] memcg: use css_get/put when charging/uncharging kmem
References: <5195D5F8.7000609@huawei.com>
In-Reply-To: <5195D5F8.7000609@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Use css_get/put instead of mem_cgroup_get/put.

We can't do a simple replacement, because here mem_cgroup_put()
is called during mem_cgroup_css_free(), while mem_cgroup_css_free()
won't be called until css refcnt goes down to 0.

Instead we increment css refcnt in mem_cgroup_css_offline(), and
then check if there's still kmem charges. If not, css refcnt will
be decremented immediately, otherwise the refcnt won't be decremented
when kmem charges goes down to 0.

v2:
- added wmb() in kmem_cgroup_css_offline(), pointed out by Michal
- revised comments as suggested by Michal
- fixed to check if kmem is activated in kmem_cgroup_css_offline()

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 66 +++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 41 insertions(+), 25 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 63526f9..2f0d117 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3033,8 +3033,16 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 	if (res_counter_uncharge(&memcg->kmem, size))
 		return;
 
+	/*
+	 * Releases a reference taken in kmem_cgroup_css_offline in case
+	 * this last uncharge is racing with the offlining code or it is
+	 * outliving the memcg existence.
+	 *
+	 * The memory barrier imposed by test&clear is paired with the
+	 * explicit one in kmem_cgroup_css_offline.
+	 */
 	if (memcg_kmem_test_and_clear_dead(memcg))
-		mem_cgroup_put(memcg);
+		css_put(&memcg->css);
 }
 
 void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
@@ -5130,14 +5138,6 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 		 * starts accounting before all call sites are patched
 		 */
 		memcg_kmem_set_active(memcg);
-
-		/*
-		 * kmem charges can outlive the cgroup. In the case of slab
-		 * pages, for instance, a page contain objects from various
-		 * processes, so it is unfeasible to migrate them away. We
-		 * need to reference count the memcg because of that.
-		 */
-		mem_cgroup_get(memcg);
 	} else
 		ret = res_counter_set_limit(&memcg->kmem, val);
 out:
@@ -5170,12 +5170,10 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 		goto out;
 
 	/*
-	 * destroy(), called if we fail, will issue static_key_slow_inc() and
-	 * mem_cgroup_put() if kmem is enabled. We have to either call them
-	 * unconditionally, or clear the KMEM_ACTIVE flag. I personally find
-	 * this more consistent, since it always leads to the same destroy path
+	 * __mem_cgroup_free() will issue static_key_slow_dec() because this
+	 * memcg is active already. If the later initialization fails then the
+	 * cgroup core triggers the cleanup so we do not have to do it here.
 	 */
-	mem_cgroup_get(memcg);
 	static_key_slow_inc(&memcg_kmem_enabled_key);
 
 	mutex_lock(&set_limit_mutex);
@@ -5858,23 +5856,39 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	return mem_cgroup_sockets_init(memcg, ss);
 }
 
-static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
+static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 {
-	mem_cgroup_sockets_destroy(memcg);
+	if (!memcg_kmem_is_active(memcg))
+		return;
 
+	/*
+	 * kmem charges can outlive the cgroup. In the case of slab
+	 * pages, for instance, a page contain objects from various
+	 * processes. As we prevent from taking a reference for every
+	 * such allocation we have to be careful when doing uncharge
+	 * (see memcg_uncharge_kmem) and here during offlining.
+	 *
+	 * The idea is that that only the _last_ uncharge which sees
+	 * the dead memcg will drop the last reference. An additional
+	 * reference is taken here before the group is marked dead
+	 * which is then paired with css_put during uncharge resp. here.
+	 *
+	 * Although this might sound strange as this path is called when
+	 * the reference has already dropped down to 0 and shouldn't be
+	 * incremented anymore (css_tryget would fail) we do not have
+	 * other options because of the kmem allocations lifetime.
+	 */
+	css_get(&memcg->css);
+
+	/* see comment in memcg_uncharge_kmem() */
+	wmb();
 	memcg_kmem_mark_dead(memcg);
 
 	if (res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0)
 		return;
 
-	/*
-	 * Charges already down to 0, undo mem_cgroup_get() done in the charge
-	 * path here, being careful not to race with memcg_uncharge_kmem: it is
-	 * possible that the charges went down to 0 between mark_dead and the
-	 * res_counter read, so in that case, we don't need the put
-	 */
 	if (memcg_kmem_test_and_clear_dead(memcg))
-		mem_cgroup_put(memcg);
+		css_put(&memcg->css);
 }
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
@@ -5882,7 +5896,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	return 0;
 }
 
-static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
+static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 {
 }
 #endif
@@ -6315,6 +6329,8 @@ static void mem_cgroup_css_offline(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
+	kmem_cgroup_css_offline(memcg);
+
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
 	mem_cgroup_destroy_all_caches(memcg);
@@ -6324,7 +6340,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
-	kmem_cgroup_destroy(memcg);
+	mem_cgroup_sockets_destroy(memcg);
 
 	mem_cgroup_put(memcg);
 }
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
