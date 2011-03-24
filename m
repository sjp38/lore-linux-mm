Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 14B7A8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 05:52:55 -0400 (EDT)
Received: by pzk32 with SMTP id 32so1794284pzk.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 02:52:51 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] Accelerate OOM killing
Date: Thu, 24 Mar 2011 18:52:33 +0900
Message-Id: <1300960353-2596-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>

When I test Andrey's problem, I saw the livelock and sysrq-t says
there are many tasks in cond_resched after try_to_free_pages.

If did_some_progress is false, cond_resched could delay oom killing so
It might be killing another task.

This patch accelerates oom killing without unnecessary giving CPU
to another task. It could help avoding unnecessary another task killing
and livelock situation a litte bit.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrey Vagin <avagin@openvz.org>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/page_alloc.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cdef1d4..b962575 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1887,11 +1887,10 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	lockdep_clear_current_reclaim_state();
 	current->flags &= ~PF_MEMALLOC;
 
-	cond_resched();
-
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
+	cond_resched();
 retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
