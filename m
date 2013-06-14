Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id D7AFB6B003B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 21:58:55 -0400 (EDT)
Message-ID: <51BA77FE.60704@huawei.com>
Date: Fri, 14 Jun 2013 09:55:10 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v4 6/9] memcg: use css_get/put for swap memcg
References: <51BA7794.2000305@huawei.com>
In-Reply-To: <51BA7794.2000305@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

Use css_get/put instead of mem_cgroup_get/put. A simple replacement
will do.

The historical reason that memcg has its own refcnt instead of always
using css_get/put, is that cgroup couldn't be removed if there're still
css refs, so css refs can't be used as long-lived reference. The
situation has changed so that rmdir a cgroup will succeed regardless
css refs, but won't be freed until css refs goes down to 0.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8f20a9c..a63d9f1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4213,12 +4213,12 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
 	unlock_page_cgroup(pc);
 	/*
 	 * even after unlock, we have memcg->res.usage here and this memcg
-	 * will never be freed.
+	 * will never be freed, so it's safe to call css_get().
 	 */
 	memcg_check_events(memcg, page);
 	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
 		mem_cgroup_swap_statistics(memcg, true);
-		mem_cgroup_get(memcg);
+		css_get(&memcg->css);
 	}
 	/*
 	 * Migration does not charge the res_counter for the
@@ -4330,7 +4330,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 
 	/*
 	 * record memcg information,  if swapout && memcg != NULL,
-	 * mem_cgroup_get() was called in uncharge().
+	 * css_get() was called in uncharge().
 	 */
 	if (do_swap_account && swapout && memcg)
 		swap_cgroup_record(ent, css_id(&memcg->css));
@@ -4361,7 +4361,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
 		if (!mem_cgroup_is_root(memcg))
 			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 		mem_cgroup_swap_statistics(memcg, false);
-		mem_cgroup_put(memcg);
+		css_put(&memcg->css);
 	}
 	rcu_read_unlock();
 }
@@ -4395,11 +4395,14 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 		 * This function is only called from task migration context now.
 		 * It postpones res_counter and refcount handling till the end
 		 * of task migration(mem_cgroup_clear_mc()) for performance
-		 * improvement. But we cannot postpone mem_cgroup_get(to)
-		 * because if the process that has been moved to @to does
-		 * swap-in, the refcount of @to might be decreased to 0.
+		 * improvement. But we cannot postpone css_get(to)  because if
+		 * the process that has been moved to @to does swap-in, the
+		 * refcount of @to might be decreased to 0.
+		 *
+		 * We are in attach() phase, so the cgroup is guaranteed to be
+		 * alive, so we can just call css_get().
 		 */
-		mem_cgroup_get(to);
+		css_get(&to->css);
 		return 0;
 	}
 	return -EINVAL;
@@ -6690,6 +6693,7 @@ static void __mem_cgroup_clear_mc(void)
 {
 	struct mem_cgroup *from = mc.from;
 	struct mem_cgroup *to = mc.to;
+	int i;
 
 	/* we must uncharge all the leftover precharges from mc.to */
 	if (mc.precharge) {
@@ -6710,7 +6714,9 @@ static void __mem_cgroup_clear_mc(void)
 		if (!mem_cgroup_is_root(mc.from))
 			res_counter_uncharge(&mc.from->memsw,
 						PAGE_SIZE * mc.moved_swap);
-		__mem_cgroup_put(mc.from, mc.moved_swap);
+
+		for (i = 0; i < mc.moved_swap; i++)
+			css_put(&mc.from->css);
 
 		if (!mem_cgroup_is_root(mc.to)) {
 			/*
@@ -6720,7 +6726,7 @@ static void __mem_cgroup_clear_mc(void)
 			res_counter_uncharge(&mc.to->res,
 						PAGE_SIZE * mc.moved_swap);
 		}
-		/* we've already done mem_cgroup_get(mc.to) */
+		/* we've already done css_get(mc.to) */
 		mc.moved_swap = 0;
 	}
 	memcg_oom_recover(from);
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
