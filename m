Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 06F396B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 20:22:30 -0500 (EST)
Received: by bkty12 with SMTP id y12so2135588bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 17:22:29 -0800 (PST)
Date: Fri, 24 Feb 2012 05:22:27 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH] mm: memcg: Remove redundant BUG_ON() in
 mem_cgroup_usage_unregister_event
Message-ID: <20120224012227.GA32689@oksana.dev.rtsoft.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In the following code:

	if (type == _MEM)
		thresholds = &memcg->thresholds;
	else if (type == _MEMSWAP)
		thresholds = &memcg->memsw_thresholds;
	else
		BUG();

	BUG_ON(!thresholds);

The BUG_ON() seems redundant.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 mm/memcontrol.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6728a7a..b423577 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4404,20 +4404,14 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 	if (type == _MEM)
 		thresholds = &memcg->thresholds;
 	else if (type == _MEMSWAP)
 		thresholds = &memcg->memsw_thresholds;
 	else
 		BUG();
 
-	/*
-	 * Something went wrong if we trying to unregister a threshold
-	 * if we don't have thresholds
-	 */
-	BUG_ON(!thresholds);
-
 	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
 
 	/* Check if a threshold crossed before removing */
 	__mem_cgroup_threshold(memcg, type == _MEMSWAP);
 
 	/* Calculate new number of threshold */
 	size = 0;
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
