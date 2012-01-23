Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 504816B004D
	for <linux-mm@kvack.org>; Sun, 22 Jan 2012 20:55:09 -0500 (EST)
Received: by wicr5 with SMTP id r5so2256076wic.14
        for <linux-mm@kvack.org>; Sun, 22 Jan 2012 17:55:07 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 23 Jan 2012 09:55:07 +0800
Message-ID: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
Subject: [PATCH] mm: vmscan: check mem cgroup over reclaimed
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

To avoid reduction in performance of reclaimee, checking overreclaim is added
after shrinking lru list, when pages are reclaimed from mem cgroup.

If over reclaim occurs, shrinking remaining lru lists is skipped, and no more
reclaim for reclaim/compaction.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Mon Jan 23 00:23:10 2012
+++ b/mm/vmscan.c	Mon Jan 23 09:57:20 2012
@@ -2086,6 +2086,7 @@ static void shrink_mem_cgroup_zone(int p
 	unsigned long nr_reclaimed, nr_scanned;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct blk_plug plug;
+	bool memcg_over_reclaimed = false;

 restart:
 	nr_reclaimed = 0;
@@ -2103,6 +2104,11 @@ restart:

 				nr_reclaimed += shrink_list(lru, nr_to_scan,
 							    mz, sc, priority);
+
+				memcg_over_reclaimed = !scanning_global_lru(mz)
+					&& (nr_reclaimed >= nr_to_reclaim);
+				if (memcg_over_reclaimed)
+					goto out;
 			}
 		}
 		/*
@@ -2116,6 +2122,7 @@ restart:
 		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
 			break;
 	}
+out:
 	blk_finish_plug(&plug);
 	sc->nr_reclaimed += nr_reclaimed;

@@ -2127,7 +2134,8 @@ restart:
 		shrink_active_list(SWAP_CLUSTER_MAX, mz, sc, priority, 0);

 	/* reclaim/compaction might need reclaim to continue */
-	if (should_continue_reclaim(mz, nr_reclaimed,
+	if (!memcg_over_reclaimed &&
+	    should_continue_reclaim(mz, nr_reclaimed,
 					sc->nr_scanned - nr_scanned, sc))
 		goto restart;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
