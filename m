Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id CE1646B003B
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 08:29:17 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id u57so4149157wes.13
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 05:29:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hy4si11883254wjb.102.2014.02.04.05.29.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 05:29:16 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2 6/6] Revert "mm: memcg: fix race condition between memcg teardown and swapin"
Date: Tue,  4 Feb 2014 14:29:00 +0100
Message-Id: <1391520540-17436-7-git-send-email-mhocko@suse.cz>
In-Reply-To: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

This reverts commit 96f1c58d853497a757463e0b57fed140d6858f3a
because it is no longer needed after "memcg: make sure that memcg is not
offline when charging" which makes sure that no charges will be accepted
after mem_cgroup_reparent_charges has started.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 36 ------------------------------------
 1 file changed, 36 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 46b9f461cedf..6226977d53d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6623,42 +6623,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
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
 
 	memcg_destroy_kmem(memcg);
 	__mem_cgroup_free(memcg);
-- 
1.9.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
