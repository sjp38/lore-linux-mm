Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4D28D003B
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 09:04:18 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] memcg: never OOM when charging huge pages
Date: Mon, 31 Jan 2011 15:03:55 +0100
Message-Id: <1296482635-13421-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Huge page coverage should obviously have less priority than the
continued execution of a process.

Never kill a process when charging it a huge page fails.  Instead,
give up after the first failed reclaim attempt and fall back to
regular pages.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c28072f..9e5de7c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2343,13 +2343,19 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask, enum charge_type ctype)
 {
 	struct mem_cgroup *mem = NULL;
+	int page_size = PAGE_SIZE;
 	struct page_cgroup *pc;
+	bool oom = true;
 	int ret;
-	int page_size = PAGE_SIZE;
 
 	if (PageTransHuge(page)) {
 		page_size <<= compound_order(page);
 		VM_BUG_ON(!PageTransHuge(page));
+		/*
+		 * Never OOM-kill a process for a huge page.  The
+		 * fault handler will fall back to regular pages.
+		 */
+		oom = false;
 	}
 
 	pc = lookup_page_cgroup(page);
@@ -2358,7 +2364,7 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 		return 0;
 	prefetchw(pc);
 
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true, page_size);
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, oom, page_size);
 	if (ret || !mem)
 		return ret;
 
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
