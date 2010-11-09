Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5EB8D0005
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 04:25:33 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 5/6] memcg: simplify mem_cgroup_dirty_info()
Date: Tue,  9 Nov 2010 01:24:30 -0800
Message-Id: <1289294671-6865-6-git-send-email-gthelen@google.com>
In-Reply-To: <1289294671-6865-1-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Because mem_cgroup_page_stat() no longer returns negative numbers
to indicate failure, mem_cgroup_dirty_info() does not need to check
for such failures.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f8df350..ccdbb7e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1258,8 +1258,6 @@ bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
 	__mem_cgroup_dirty_param(&dirty_param, memcg);
 
 	value = mem_cgroup_page_stat(memcg, MEMCG_NR_DIRTYABLE_PAGES);
-	if (value < 0)
-		goto done;
 
 	available_mem = min((unsigned long)value, sys_available_mem);
 
@@ -1279,15 +1277,9 @@ bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
 			(dirty_param.dirty_background_ratio *
 			       available_mem) / 100;
 
-	value = mem_cgroup_page_stat(memcg, MEMCG_NR_RECLAIM_PAGES);
-	if (value < 0)
-		goto done;
-	info->nr_reclaimable = value;
-
-	value = mem_cgroup_page_stat(memcg, MEMCG_NR_WRITEBACK);
-	if (value < 0)
-		goto done;
-	info->nr_writeback = value;
+	info->nr_reclaimable =
+		mem_cgroup_page_stat(memcg, MEMCG_NR_RECLAIM_PAGES);
+	info->nr_writeback = mem_cgroup_page_stat(memcg, MEMCG_NR_WRITEBACK);
 
 	valid = true;
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
