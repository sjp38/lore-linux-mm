Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 422706B00EB
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 17:56:47 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so2948567bkw.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:56:46 -0700 (PDT)
Subject: [PATCH v6 7/7] mm/memcg: use vm_swappiness from target memory cgroup
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 23 Mar 2012 01:56:43 +0400
Message-ID: <20120322215643.27814.58756.stgit@zurg>
In-Reply-To: <20120322214944.27814.42039.stgit@zurg>
References: <20120322214944.27814.42039.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>

Use vm_swappiness from memory cgroup which is triggered this memory reclaim.
This is more reasonable and allows to kill one argument.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>
---
 mm/vmscan.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9de66be..5e2906d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1840,12 +1840,11 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	return shrink_inactive_list(nr_to_scan, mz, sc, priority, lru);
 }
 
-static int vmscan_swappiness(struct mem_cgroup_zone *mz,
-			     struct scan_control *sc)
+static int vmscan_swappiness(struct scan_control *sc)
 {
 	if (global_reclaim(sc))
 		return vm_swappiness;
-	return mem_cgroup_swappiness(mz->mem_cgroup);
+	return mem_cgroup_swappiness(sc->target_mem_cgroup);
 }
 
 /*
@@ -1913,8 +1912,8 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
 	 * With swappiness at 100, anonymous and file have the same priority.
 	 * This scanning priority is essentially the inverse of IO cost.
 	 */
-	anon_prio = vmscan_swappiness(mz, sc);
-	file_prio = 200 - vmscan_swappiness(mz, sc);
+	anon_prio = vmscan_swappiness(sc);
+	file_prio = 200 - vmscan_swappiness(sc);
 
 	/*
 	 * OK, so we have swap space and a fair amount of page cache

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
