Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id A736A6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 16:55:24 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so3602750pbc.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 13:55:24 -0700 (PDT)
Date: Fri, 23 Mar 2012 13:54:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] memcg swap: use mem_cgroup_uncharge_swap
Message-ID: <alpine.LSU.2.00.1203231351310.1940@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

That stuff __mem_cgroup_commit_charge_swapin() does with a swap entry,
it has a name and even a declaration: just use mem_cgroup_uncharge_swap().

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/memcontrol.c |   19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

--- linux.git/mm/memcontrol.c	2012-03-23 10:19:53.576051635 -0700
+++ linux/mm/memcontrol.c	2012-03-23 10:51:03.996092671 -0700
@@ -2850,24 +2850,7 @@ __mem_cgroup_commit_charge_swapin(struct
 	 */
 	if (do_swap_account && PageSwapCache(page)) {
 		swp_entry_t ent = {.val = page_private(page)};
-		struct mem_cgroup *swap_memcg;
-		unsigned short id;
-
-		id = swap_cgroup_record(ent, 0);
-		rcu_read_lock();
-		swap_memcg = mem_cgroup_lookup(id);
-		if (swap_memcg) {
-			/*
-			 * This recorded memcg can be obsolete one. So, avoid
-			 * calling css_tryget
-			 */
-			if (!mem_cgroup_is_root(swap_memcg))
-				res_counter_uncharge(&swap_memcg->memsw,
-						     PAGE_SIZE);
-			mem_cgroup_swap_statistics(swap_memcg, false);
-			mem_cgroup_put(swap_memcg);
-		}
-		rcu_read_unlock();
+		mem_cgroup_uncharge_swap(ent);
 	}
 	/*
 	 * At swapin, we may charge account against cgroup which has no tasks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
