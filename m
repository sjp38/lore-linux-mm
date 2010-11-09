Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ED0BA6B00D9
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 03:54:30 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: avoid "free" overflow in memcg_hierarchical_free_pages()
Date: Tue,  9 Nov 2010 00:54:13 -0800
Message-Id: <1289292853-7022-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

memcg limit and usage values are stored in res_counter, as 64-bit
numbers, even on 32-bit machines.  The "free" variable in
memcg_hierarchical_free_pages() stores the difference between two
64-bit numbers (limit - current_usage), and thus should be stored
in a 64-bit local rather than a machine defined unsigned long.

Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 35870f9..d8a06d6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1343,7 +1343,8 @@ static long mem_cgroup_local_page_stat(struct mem_cgroup *mem,
 static unsigned long
 memcg_hierarchical_free_pages(struct mem_cgroup *mem)
 {
-	unsigned long free, min_free;
+	u64 free;
+	unsigned long min_free;
 
 	min_free = global_page_state(NR_FREE_PAGES);
 
@@ -1351,7 +1352,7 @@ memcg_hierarchical_free_pages(struct mem_cgroup *mem)
 		free = (res_counter_read_u64(&mem->res, RES_LIMIT) -
 			res_counter_read_u64(&mem->res, RES_USAGE)) >>
 			PAGE_SHIFT;
-		min_free = min(min_free, free);
+		min_free = min((u64)min_free, free);
 		mem = parent_mem_cgroup(mem);
 	}
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
