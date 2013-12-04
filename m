Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id D29516B003A
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 17:45:31 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id d7so6895500bkh.31
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 14:45:31 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id dg6si1947852bkc.242.2013.12.04.14.45.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 14:45:30 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] mm: memcg: fix race condition between memcg teardown and swapin
Date: Wed,  4 Dec 2013 17:45:13 -0500
Message-Id: <1386197114-5317-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1386197114-5317-1-git-send-email-hannes@cmpxchg.org>
References: <1386197114-5317-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

There is a race condition between a memcg being torn down and a swapin
triggered from a different memcg of a page that was recorded to belong
to the exiting memcg on swapout (with CONFIG_MEMCG_SWAP extension).
The result is unreclaimable pages pointing to dead memcgs, which can
lead to anything from endless loops in later memcg teardown (the page
is charged to all hierarchical parents but is not on any LRU list) or
crashes from following the dangling memcg pointer.

Memcgs with tasks in them can not be torn down and usually charges
don't show up in memcgs without tasks.  Swapin with the
CONFIG_MEMCG_SWAP extension is the notable exception because it
charges the cgroup that was recorded as owner during swapout, which
may be empty and in the process of being torn down when a task in
another memcg triggers the swapin:

  teardown:                 swapin:

                            lookup_swap_cgroup_id()
                            rcu_read_lock()
                            mem_cgroup_lookup()
                            css_tryget()
                            rcu_read_unlock()
  disable css_tryget()
  call_rcu()
    offline_css()
      reparent_charges()
                            res_counter_charge() (hierarchical!)
                            css_put()
                              css_free()
                            pc->mem_cgroup = dead memcg
                            add page to dead lru

Add a final reparenting step into css_free() to make sure any such
raced charges are moved out of the memcg before it's finally freed.

In the longer term it would be cleaner to have the css_tryget() and
the res_counter charge under the same RCU lock section so that the
charge reparenting is deferred until the last charge whose tryget
succeeded is visible.  But this will require more invasive changes
that will be harder to evaluate and backport into stable, so better
defer them to a separate change set.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@kernel.org>
---
 mm/memcontrol.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e3aff0175d4c..f6a63f5b3827 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6355,6 +6355,42 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	/*
+	 * XXX: css_offline() would be where we should reparent all
+	 * memory to prepare the cgroup for destruction.  However,
+	 * memcg does not do css_tryget() and res_counter charging
+	 * under the same RCU lock region, which means that charging
+	 * could race with offlining.  Offlining only happens to
+	 * cgroups with no tasks in them but charges can show up
+	 * without any tasks from the swapin path when the target
+	 * memcg is looked up from the swapout record and not from the
+	 * current task as it usually is.  A race like this can leak
+	 * charges and put pages with stale cgroup pointers into
+	 * circulation:
+	 *
+	 * #0                        #1
+	 *                           lookup_swap_cgroup_id()
+	 *                           rcu_read_lock()
+	 *                           mem_cgroup_lookup()
+	 *                           css_tryget()
+	 *                           rcu_read_unlock()
+	 * disable css_tryget()
+	 * call_rcu()
+	 *   offline_css()
+	 *     reparent_charges()
+	 *                           res_counter_charge()
+	 *                           css_put()
+	 *                             css_free()
+	 *                           pc->mem_cgroup = dead memcg
+	 *                           add page to lru
+	 *
+	 * The bulk of the charges are still moved in offline_css() to
+	 * avoid pinning a lot of pages in case a long-term reference
+	 * like a swapout record is deferring the css_free() to long
+	 * after offlining.  But this makes sure we catch any charges
+	 * made after offlining:
+	 */
+	mem_cgroup_reparent_charges(memcg);
 
 	memcg_destroy_kmem(memcg);
 	__mem_cgroup_free(memcg);
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
