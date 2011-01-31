Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3388D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 09:04:18 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] memcg: prevent endless loop when charging huge pages to near-limit group
Date: Mon, 31 Jan 2011 15:03:54 +0100
Message-Id: <1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If reclaim after a failed charging was unsuccessful, the limits are
checked again, just in case they settled by means of other tasks.

This is all fine as long as every charge is of size PAGE_SIZE, because
in that case, being below the limit means having at least PAGE_SIZE
bytes available.

But with transparent huge pages, we may end up in an endless loop
where charging and reclaim fail, but we keep going because the limits
are not yet exceeded, although not allowing for a huge page.

Fix this up by explicitely checking for enough room, not just whether
we are within limits.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/res_counter.h |   12 ++++++++++++
 mm/memcontrol.c             |   27 ++++++++++++++++++++-------
 2 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index fcb9884..5cfd78a 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -182,6 +182,18 @@ static inline bool res_counter_check_under_limit(struct res_counter *cnt)
 	return ret;
 }
 
+static inline bool res_counter_check_margin(struct res_counter *cnt,
+					    unsigned long bytes)
+{
+	bool ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = cnt->limit - cnt->usage >= bytes;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
 {
 	bool ret;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 73ea323..c28072f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1111,6 +1111,15 @@ static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
 	return false;
 }
 
+static bool mem_cgroup_check_margin(struct mem_cgroup *mem, unsigned long bytes)
+{
+	if (!res_counter_check_margin(&mem->res, bytes))
+		return false;
+	if (do_swap_account && !res_counter_check_margin(&mem->memsw, bytes))
+		return false;
+	return true;
+}
+
 static unsigned int get_swappiness(struct mem_cgroup *memcg)
 {
 	struct cgroup *cgrp = memcg->css.cgroup;
@@ -1852,15 +1861,19 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 		return CHARGE_WOULDBLOCK;
 
 	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
-					gfp_mask, flags);
+					      gfp_mask, flags);
+	if (mem_cgroup_check_margin(mem_over_limit, csize))
+		return CHARGE_RETRY;
 	/*
-	 * try_to_free_mem_cgroup_pages() might not give us a full
-	 * picture of reclaim. Some pages are reclaimed and might be
-	 * moved to swap cache or just unmapped from the cgroup.
-	 * Check the limit again to see if the reclaim reduced the
-	 * current usage of the cgroup before giving up
+	 * Even though the limit is exceeded at this point, reclaim
+	 * may have been able to free some pages.  Retry the charge
+	 * before killing the task.
+	 *
+	 * Only for regular pages, though: huge pages are rather
+	 * unlikely to succeed so close to the limit, and we fall back
+	 * to regular pages anyway in case of failure.
 	 */
-	if (ret || mem_cgroup_check_under_limit(mem_over_limit))
+	if (csize == PAGE_SIZE && ret)
 		return CHARGE_RETRY;
 
 	/*
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
