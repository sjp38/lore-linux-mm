Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 3FCAF6B003D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 21:59:13 -0400 (EDT)
Message-ID: <51BA77F1.4080106@huawei.com>
Date: Fri, 14 Jun 2013 09:54:57 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v4 5/9] memcg: use css_get/put when charging/uncharging kmem
References: <51BA7794.2000305@huawei.com>
In-Reply-To: <51BA7794.2000305@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

Use css_get/put instead of mem_cgroup_get/put.

We can't do a simple replacement, because here mem_cgroup_put()
is called during mem_cgroup_css_free(), while mem_cgroup_css_free()
won't be called until css refcnt goes down to 0.

Instead we increment css refcnt in mem_cgroup_css_offline(), and
then check if there's still kmem charges. If not, css refcnt will
be decremented immediately, otherwise the refcnt will be released
after the last kmem allocation is uncahred.

v3:
- changed wmb() to smp_wmb(), and moved it to memcg_kmem_mark_dead(),
  and added comment.

v2:
- added wmb() in kmem_cgroup_css_offline(), pointed out by Michal
- revised comments as suggested by Michal
- fixed to check if kmem is activated in kmem_cgroup_css_offline()

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c | 70 ++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 45 insertions(+), 25 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 466c595..8f20a9c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -416,6 +416,11 @@ static void memcg_kmem_clear_activated(struct mem_cgroup *memcg)
 
 static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
 {
+	/*
+	 * We need to call css_get() first, because memcg_uncharge_kmem()
+	 * will call css_put() if it sees the memcg is dead.
+	 */
+	smp_wmb();
 	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags))
 		set_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_account_flags);
 }
@@ -3060,8 +3065,16 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 	if (res_counter_uncharge(&memcg->kmem, size))
 		return;
 
+	/*
+	 * Releases a reference taken in kmem_cgroup_css_offline in case
+	 * this last uncharge is racing with the offlining code or it is
+	 * outliving the memcg existence.
+	 *
+	 * The memory barrier imposed by test&clear is paired with the
+	 * explicit one in memcg_kmem_mark_dead().
+	 */
 	if (memcg_kmem_test_and_clear_dead(memcg))
-		mem_cgroup_put(memcg);
+		css_put(&memcg->css);
 }
 
 void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
@@ -5165,14 +5178,6 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
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
@@ -5205,12 +5210,10 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
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
@@ -5893,23 +5896,38 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	return mem_cgroup_sockets_init(memcg, ss);
 }
 
-static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
+static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 {
-	mem_cgroup_sockets_destroy(memcg);
+	if (!memcg_kmem_is_active(memcg))
+		return;
+
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
+	 * Although this might sound strange as this path is called from
+	 * css_offline() when the referencemight have dropped down to 0
+	 * and shouldn't be incremented anymore (css_tryget would fail)
+	 * we do not have other options because of the kmem allocations
+	 * lifetime.
+	 */
+	css_get(&memcg->css);
 
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
@@ -5917,7 +5935,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	return 0;
 }
 
-static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
+static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 {
 }
 #endif
@@ -6350,6 +6368,8 @@ static void mem_cgroup_css_offline(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
+	kmem_cgroup_css_offline(memcg);
+
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
 	mem_cgroup_destroy_all_caches(memcg);
@@ -6359,7 +6379,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
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
