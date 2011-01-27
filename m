Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 79D898D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 05:40:25 -0500 (EST)
Date: Thu, 27 Jan 2011 11:40:14 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] memcg: prevent endless loop with huge pages and near-limit
 group
Message-ID: <20110127104014.GD2401@cmpxchg.org>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
 <20110121154430.70d45f15.kamezawa.hiroyu@jp.fujitsu.com>
 <20110127103438.GC2401@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110127103438.GC2401@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is a patch I sent to Andrea ages ago in response to a RHEL
bugzilla.  Not sure why it did not reach mainline...  But it fixes one
issue you described in 4/7, namely looping around a not exceeded limit
with a huge page that won't fit anymore.

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] memcg: prevent endless loop with huge pages and near-limit group

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
 mm/memcontrol.c             |   20 +++++++++++---------
 2 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index fcb9884..03212e4 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -182,6 +182,18 @@ static inline bool res_counter_check_under_limit(struct res_counter *cnt)
 	return ret;
 }
 
+static inline bool res_counter_check_room(struct res_counter *cnt,
+					  unsigned long room)
+{
+	bool ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = cnt->limit - cnt->usage >= room;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
 {
 	bool ret;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d572102..8fa4be3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1111,6 +1111,15 @@ static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
 	return false;
 }
 
+static bool mem_cgroup_check_room(struct mem_cgroup *mem, unsigned long room)
+{
+	if (!res_counter_check_room(&mem->res, room))
+		return false;
+	if (!do_swap_account)
+		return true;
+	return res_counter_check_room(&mem->memsw, room);
+}
+
 static unsigned int get_swappiness(struct mem_cgroup *memcg)
 {
 	struct cgroup *cgrp = memcg->css.cgroup;
@@ -1844,16 +1853,9 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 	if (!(gfp_mask & __GFP_WAIT))
 		return CHARGE_WOULDBLOCK;
 
-	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
+	mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
 					gfp_mask, flags);
-	/*
-	 * try_to_free_mem_cgroup_pages() might not give us a full
-	 * picture of reclaim. Some pages are reclaimed and might be
-	 * moved to swap cache or just unmapped from the cgroup.
-	 * Check the limit again to see if the reclaim reduced the
-	 * current usage of the cgroup before giving up
-	 */
-	if (ret || mem_cgroup_check_under_limit(mem_over_limit))
+	if (mem_cgroup_check_room(mem_over_limit, csize))
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
