Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 7A3D86B00EA
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 13:04:36 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id q16so787924bkw.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 10:04:35 -0800 (PST)
Subject: [PATCH v5 7/7] mm/memcg: use vm_swappiness from target memory cgroup
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 08 Mar 2012 22:04:30 +0400
Message-ID: <20120308180430.27621.99232.stgit@zurg>
In-Reply-To: <20120308175752.27621.54781.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use vm_swappiness from memory cgroup which is triggered this memory reclaim.
This is more reasonable and allows to kill one argument.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

---

add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-2 (-2)
function                                     old     new   delta
shrink_mem_cgroup_zone                      1583    1581      -2
---
 mm/vmscan.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9a41769..95719f3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1859,12 +1859,11 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
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
@@ -1933,8 +1932,8 @@ static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
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
