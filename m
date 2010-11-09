Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DFAB56B00C5
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 22:33:47 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: avoid overflow in memcg_hierarchical_free_pages()
Date: Mon,  8 Nov 2010 17:15:20 -0800
Message-Id: <1289265320-7025-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Use page counts rather than byte counts to avoid overflowing
unsigned long local variables.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6c7115d..b287afd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1345,17 +1345,17 @@ memcg_hierarchical_free_pages(struct mem_cgroup *mem)
 {
 	unsigned long free, min_free;
 
-	min_free = global_page_state(NR_FREE_PAGES) << PAGE_SHIFT;
+	min_free = global_page_state(NR_FREE_PAGES);
 
 	while (mem) {
-		free = res_counter_read_u64(&mem->res, RES_LIMIT) -
-			res_counter_read_u64(&mem->res, RES_USAGE);
+		free = (res_counter_read_u64(&mem->res, RES_LIMIT) -
+			res_counter_read_u64(&mem->res, RES_USAGE)) >>
+			PAGE_SHIFT;
 		min_free = min(min_free, free);
 		mem = parent_mem_cgroup(mem);
 	}
 
-	/* Translate free memory in pages */
-	return min_free >> PAGE_SHIFT;
+	return min_free;
 }
 
 /*
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
