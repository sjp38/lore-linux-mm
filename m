Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B02069000C2
	for <linux-mm@kvack.org>; Mon,  4 Jul 2011 10:05:57 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 8so6166032iwn.14
        for <linux-mm@kvack.org>; Mon, 04 Jul 2011 07:05:56 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 10/10] compaction: add drain ilru of pagevec
Date: Mon,  4 Jul 2011 23:04:43 +0900
Message-Id: <ffbd3363011cb1e1ca8f816d539effe3cd5644a4.1309787991.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

inorder_lru checks whether previous page of drained page is
in lru. If it isn't in lru, same_lru returns false and inorder_lru
got failed which would be frequent in heavy memory pressure as
previous page is in ilru pagevec. It's not desireable.

In addtion, fast returning of migrated page into LRU is important
in case of reclaiming pages by compation and kswapd/other direct
reclaim happens by parallel. That's because the pages in ilru pagevec
might be really tail of LRU so we can prevent eviction working set pages.

The elaspsed time of decompress 10GB in my experiment is following as.

inorder_lru			inorder_lru + drain pagevec
01:43:16.16             	01:40:27.18

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/swap.h |    2 ++
 mm/compaction.c      |    2 ++
 mm/swap.c            |   13 +++++++++++++
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 78f5249..6aafb75 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -217,6 +217,8 @@ extern unsigned int nr_free_pagecache_pages(void);
 
 
 /* linux/mm/swap.c */
+extern void drain_ilru_pagevecs(int cpu);
+extern void __ilru_cache_add(struct page *, enum lru_list lru);
 extern void __ilru_cache_add(struct page *, enum lru_list lru);
 extern void __lru_cache_add(struct page *, enum lru_list lru);
 extern void lru_cache_add_ilru(struct page *, enum lru_list lru);
diff --git a/mm/compaction.c b/mm/compaction.c
index 7bc784a..a515639 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -573,6 +573,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 			cc->nr_migratepages = 0;
 		}
 
+		drain_ilru_pagevecs(get_cpu());
+		put_cpu();
 	}
 
 out:
diff --git a/mm/swap.c b/mm/swap.c
index f2ccf81..c2cf0e2 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -525,6 +525,19 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 	update_page_reclaim_stat(zone, page, file, 0);
 }
 
+void drain_ilru_pagevecs(int cpu)
+{
+	struct pagevec *pvecs = per_cpu(ilru_add_pvecs, cpu);
+	struct pagevec *pvec;
+	int lru;
+
+	for_each_lru(lru) {
+		pvec = &pvecs[lru - LRU_BASE];
+		if (pagevec_count(pvec))
+			____pagevec_ilru_add(pvec, lru);
+	}
+}
+
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
