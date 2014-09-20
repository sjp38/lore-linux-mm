Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 481846B0038
	for <linux-mm@kvack.org>; Sat, 20 Sep 2014 16:00:49 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id y10so1168712wgg.18
        for <linux-mm@kvack.org>; Sat, 20 Sep 2014 13:00:48 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d6si3291010wix.107.2014.09.20.13.00.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Sep 2014 13:00:48 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] mm: memcontrol: remove obsolete kmemcg pinning tricks
Date: Sat, 20 Sep 2014 16:00:34 -0400
Message-Id: <1411243235-24680-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
References: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

As charges now pin the css explicitely, there is no more need for
kmemcg to acquire a proxy reference for outstanding pages during
offlining, or maintain state to identify such "dead" groups.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 74 +--------------------------------------------------------
 1 file changed, 1 insertion(+), 73 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b832c87ec43b..019a44ac25d6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -471,7 +471,6 @@ struct mem_cgroup {
 /* internal only representation about the status of kmem accounting. */
 enum {
 	KMEM_ACCOUNTED_ACTIVE, /* accounted by this cgroup itself */
-	KMEM_ACCOUNTED_DEAD, /* dead memcg with pending kmem charges */
 };
 
 #ifdef CONFIG_MEMCG_KMEM
@@ -485,22 +484,6 @@ static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
 
-static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
-{
-	/*
-	 * Our caller must use css_get() first, because memcg_uncharge_kmem()
-	 * will call css_put() if it sees the memcg is dead.
-	 */
-	smp_wmb();
-	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags))
-		set_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_account_flags);
-}
-
-static bool memcg_kmem_test_and_clear_dead(struct mem_cgroup *memcg)
-{
-	return test_and_clear_bit(KMEM_ACCOUNTED_DEAD,
-				  &memcg->kmem_account_flags);
-}
 #endif
 
 /* Stuffs for move charges at task migration. */
@@ -2807,22 +2790,7 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
 	if (do_swap_account)
 		page_counter_uncharge(&memcg->memsw, nr_pages);
 
-	/* Not down to 0 */
-	if (page_counter_uncharge(&memcg->kmem, nr_pages)) {
-		css_put_many(&memcg->css, nr_pages);
-		return;
-	}
-
-	/*
-	 * Releases a reference taken in kmem_cgroup_css_offline in case
-	 * this last uncharge is racing with the offlining code or it is
-	 * outliving the memcg existence.
-	 *
-	 * The memory barrier imposed by test&clear is paired with the
-	 * explicit one in memcg_kmem_mark_dead().
-	 */
-	if (memcg_kmem_test_and_clear_dead(memcg))
-		css_put(&memcg->css);
+	page_counter_uncharge(&memcg->kmem, nr_pages);
 
 	css_put_many(&memcg->css, nr_pages);
 }
@@ -4805,40 +4773,6 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 	mem_cgroup_sockets_destroy(memcg);
 }
-
-static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
-{
-	if (!memcg_kmem_is_active(memcg))
-		return;
-
-	/*
-	 * kmem charges can outlive the cgroup. In the case of slab
-	 * pages, for instance, a page contain objects from various
-	 * processes. As we prevent from taking a reference for every
-	 * such allocation we have to be careful when doing uncharge
-	 * (see memcg_uncharge_kmem) and here during offlining.
-	 *
-	 * The idea is that that only the _last_ uncharge which sees
-	 * the dead memcg will drop the last reference. An additional
-	 * reference is taken here before the group is marked dead
-	 * which is then paired with css_put during uncharge resp. here.
-	 *
-	 * Although this might sound strange as this path is called from
-	 * css_offline() when the referencemight have dropped down to 0 and
-	 * shouldn't be incremented anymore (css_tryget_online() would
-	 * fail) we do not have other options because of the kmem
-	 * allocations lifetime.
-	 */
-	css_get(&memcg->css);
-
-	memcg_kmem_mark_dead(memcg);
-
-	if (atomic_long_read(&memcg->kmem.count))
-		return;
-
-	if (memcg_kmem_test_and_clear_dead(memcg))
-		css_put(&memcg->css);
-}
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
@@ -4848,10 +4782,6 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
 }
-
-static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
-{
-}
 #endif
 
 /*
@@ -5443,8 +5373,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
-	kmem_cgroup_css_offline(memcg);
-
 	/*
 	 * This requires that offlining is serialized.  Right now that is
 	 * guaranteed because css_killed_work_fn() holds the cgroup_mutex.
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
