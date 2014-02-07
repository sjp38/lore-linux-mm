Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 18B8D6B0038
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:04:36 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id b15so1668357eek.4
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:04:36 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id s6si9435805eel.35.2014.02.07.09.04.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 09:04:35 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/8] memcg: update comment about charge reparenting on cgroup exit
Date: Fri,  7 Feb 2014 12:04:20 -0500
Message-Id: <1391792665-21678-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Reparenting memory charges in the css_free() callback was meant as a
temporary fix for charges that race with offlining, but after some
follow-up discussion, it turns out that this is really the right place
to reparent charges because it guarantees none are in-flight.

Make clear that the reparenting in css_offline() is an optimistic
sweep of established charges because swapout records might hold up
css_free() indefinitely, but that in fact the css_free() reparenting
is the properly synchronized one.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 52 +++++++++++++++-------------------------------------
 1 file changed, 15 insertions(+), 37 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 639cf58b2643..b8a96c7d1167 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6600,51 +6600,29 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	kmem_cgroup_css_offline(memcg);
 
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
-	mem_cgroup_reparent_charges(memcg);
 	mem_cgroup_destroy_all_caches(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
+	/*
+	 * Memcg gets css references while charging the res_counter,
+	 * so we reparent charges in .css_free() when the references
+	 * are gone and we know there are no in-flight charges.
+	 *
+	 * However, at this time, swapout records also hold css refs
+	 * indefinitely beyond offlining, which prevent .css_free()
+	 * from being called.  But after offlining, css_tryget() is
+	 * disabled, which means that all the left-over page cache in
+	 * the group would be stuck without being reclaimable.  Clear
+	 * out all those already established charges optimistically
+	 * here, and catch any raced charges in .css_free() later on.
+	 */
+	mem_cgroup_reparent_charges(memcg);
 }
 
 static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	/*
-	 * XXX: css_offline() would be where we should reparent all
-	 * memory to prepare the cgroup for destruction.  However,
-	 * memcg does not do css_tryget() and res_counter charging
-	 * under the same RCU lock region, which means that charging
-	 * could race with offlining.  Offlining only happens to
-	 * cgroups with no tasks in them but charges can show up
-	 * without any tasks from the swapin path when the target
-	 * memcg is looked up from the swapout record and not from the
-	 * current task as it usually is.  A race like this can leak
-	 * charges and put pages with stale cgroup pointers into
-	 * circulation:
-	 *
-	 * #0                        #1
-	 *                           lookup_swap_cgroup_id()
-	 *                           rcu_read_lock()
-	 *                           mem_cgroup_lookup()
-	 *                           css_tryget()
-	 *                           rcu_read_unlock()
-	 * disable css_tryget()
-	 * call_rcu()
-	 *   offline_css()
-	 *     reparent_charges()
-	 *                           res_counter_charge()
-	 *                           css_put()
-	 *                             css_free()
-	 *                           pc->mem_cgroup = dead memcg
-	 *                           add page to lru
-	 *
-	 * The bulk of the charges are still moved in offline_css() to
-	 * avoid pinning a lot of pages in case a long-term reference
-	 * like a swapout record is deferring the css_free() to long
-	 * after offlining.  But this makes sure we catch any charges
-	 * made after offlining:
-	 */
-	mem_cgroup_reparent_charges(memcg);
 
+	mem_cgroup_reparent_charges(memcg);
 	memcg_destroy_kmem(memcg);
 	__mem_cgroup_free(memcg);
 }
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
