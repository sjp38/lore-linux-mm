Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 790AF8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 09:04:15 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] memcg: prevent endless loop when charging huge pages
Date: Mon, 31 Jan 2011 15:03:53 +0100
Message-Id: <1296482635-13421-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The charging code can encounter a charge size that is bigger than a
regular page in two situations: one is a batched charge to fill the
per-cpu stocks, the other is a huge page charge.

This code is distributed over two functions, however, and only the
outer one is aware of huge pages.  In case the charging fails, the
inner function will tell the outer function to retry if the charge
size is bigger than regular pages--assuming batched charging is the
only case.  And the outer function will retry forever charging a huge
page.

This patch makes sure the inner function can distinguish between batch
charging and a single huge page charge.  It will only signal another
attempt if batch charging failed, and go into regular reclaim when it
is called on behalf of a huge page.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d572102..73ea323 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1837,8 +1837,15 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
 	} else
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
-
-	if (csize > PAGE_SIZE) /* change csize and retry */
+	/*
+	 * csize can be either a huge page (HPAGE_SIZE), a batch of
+	 * regular pages (CHARGE_SIZE), or a single regular page
+	 * (PAGE_SIZE).
+	 *
+	 * Never reclaim on behalf of optional batching, retry with a
+	 * single page instead.
+	 */
+	if (csize == CHARGE_SIZE)
 		return CHARGE_RETRY;
 
 	if (!(gfp_mask & __GFP_WAIT))
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
