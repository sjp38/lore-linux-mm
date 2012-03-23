Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id EBB916B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 16:51:52 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so3944702gge.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 13:51:52 -0700 (PDT)
Date: Fri, 23 Mar 2012 13:51:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] memcg swap: mem_cgroup_move_swap_account never needs fixup
Message-ID: <alpine.LSU.2.00.1203231348510.1940@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

The need_fixup arg to mem_cgroup_move_swap_account() is always false,
so just remove it.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
I believe it's now agreed that an 81-column line is better left unsplit.

 mm/memcontrol.c |   19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

--- linux.git/mm/memcontrol.c	2012-03-23 10:19:53.576051635 -0700
+++ linux/mm/memcontrol.c	2012-03-23 10:50:31.196094204 -0700
@@ -3160,7 +3160,6 @@ void mem_cgroup_uncharge_swap(swp_entry_
  * @entry: swap entry to be moved
  * @from:  mem_cgroup which the entry is moved from
  * @to:  mem_cgroup which the entry is moved to
- * @need_fixup: whether we should fixup res_counters and refcounts.
  *
  * It succeeds only when the swap_cgroup's record for this entry is the same
  * as the mem_cgroup's id of @from.
@@ -3171,7 +3170,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
  * both res and memsw, and called css_get().
  */
 static int mem_cgroup_move_swap_account(swp_entry_t entry,
-		struct mem_cgroup *from, struct mem_cgroup *to, bool need_fixup)
+				struct mem_cgroup *from, struct mem_cgroup *to)
 {
 	unsigned short old_id, new_id;
 
@@ -3190,24 +3189,13 @@ static int mem_cgroup_move_swap_account(
 		 * swap-in, the refcount of @to might be decreased to 0.
 		 */
 		mem_cgroup_get(to);
-		if (need_fixup) {
-			if (!mem_cgroup_is_root(from))
-				res_counter_uncharge(&from->memsw, PAGE_SIZE);
-			mem_cgroup_put(from);
-			/*
-			 * we charged both to->res and to->memsw, so we should
-			 * uncharge to->res.
-			 */
-			if (!mem_cgroup_is_root(to))
-				res_counter_uncharge(&to->res, PAGE_SIZE);
-		}
 		return 0;
 	}
 	return -EINVAL;
 }
 #else
 static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
-		struct mem_cgroup *from, struct mem_cgroup *to, bool need_fixup)
+				struct mem_cgroup *from, struct mem_cgroup *to)
 {
 	return -EINVAL;
 }
@@ -5529,8 +5517,7 @@ put:			/* get_mctgt_type() gets the page
 			break;
 		case MC_TARGET_SWAP:
 			ent = target.ent;
-			if (!mem_cgroup_move_swap_account(ent,
-						mc.from, mc.to, false)) {
+			if (!mem_cgroup_move_swap_account(ent, mc.from, mc.to)) {
 				mc.precharge--;
 				/* we fixup refcnts and charges later. */
 				mc.moved_swap++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
