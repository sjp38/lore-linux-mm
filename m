Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BB29A6B00D7
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 06:05:41 -0500 (EST)
Date: Tue, 9 Nov 2010 12:05:21 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] memcg: fix unit mismatch in memcg oom limit calculation
Message-ID: <20101109110521.GS23393@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Adding the number of swap pages to the byte limit of a memory control
group makes no sense.  Convert the pages to bytes before adding them.

The only user of this code is the OOM killer, and the way it is used
means that the error results in a higher OOM badness value.  Since the
cgroup limit is the same for all tasks in the cgroup, the error should
have no practical impact at the moment.

But let's not wait for future or changing users to trip over it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1552,8 +1552,9 @@ u64 mem_cgroup_get_limit(struct mem_cgro
 	u64 limit;
 	u64 memsw;
 
-	limit = res_counter_read_u64(&memcg->res, RES_LIMIT) +
-			total_swap_pages;
+	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
+	limit += total_swap_pages << PAGE_SHIFT;
+
 	memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
 	/*
 	 * If memsw is finite and limits the amount of swap space available

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
