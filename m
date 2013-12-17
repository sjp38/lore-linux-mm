Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id DB2A26B0068
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 10:45:53 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id o10so2937446eaj.18
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 07:45:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si5517724eeo.65.2013.12.17.07.45.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 07:45:53 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 5/5] Revert "mm: memcg: fix race condition between memcg teardown and swapin"
Date: Tue, 17 Dec 2013 16:45:30 +0100
Message-Id: <1387295130-19771-6-git-send-email-mhocko@suse.cz>
In-Reply-To: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
References: <1387295130-19771-1-git-send-email-mhocko@suse.cz>
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
index 2904b2a6805a..591ced342036 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6395,42 +6395,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
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
1.8.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
