Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 810EA8D003A
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 05:44:51 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] memcg: charged pages always have valid per-memcg zone info
Date: Wed,  9 Feb 2011 11:44:35 +0100
Message-Id: <1297248275-23521-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

page_cgroup_zoneinfo() will never return NULL for a charged page,
remove the check for it in mem_cgroup_get_reclaim_stat_from_page().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

Andrew, this is a follow-up to 'memcg: no uncharged pages reach
page_cgroup_zoneinfo'.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 686f1ce..6d007d6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1017,9 +1017,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	if (!mz)
-		return NULL;
-
 	return &mz->reclaim_stat;
 }
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
