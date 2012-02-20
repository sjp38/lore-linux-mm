Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 426C16B00ED
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:17 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:16 -0800 (PST)
Subject: [PATCH v2 10/22] mm: unify inactive_list_is_low()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:13 +0400
Message-ID: <20120220172313.22196.37308.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Unify memcg and non-memcg logic, always use exact counters from struct lruvec.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   30 ++++++++----------------------
 1 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3e8d049..6889a39 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1809,6 +1809,7 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz,
 {
 	unsigned long active, inactive;
 	unsigned int ratio;
+	struct lruvec *lruvec;
 
 	/*
 	 * If we don't have swap space, anonymous page deactivation
@@ -1822,17 +1823,9 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz,
 	else
 		ratio = mem_cgroup_inactive_ratio(sc->target_mem_cgroup);
 
-	if (scanning_global_lru(mz)) {
-		active = zone_page_state(mz->zone, NR_ACTIVE_ANON);
-		inactive = zone_page_state(mz->zone, NR_INACTIVE_ANON);
-	} else {
-		active = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
-				zone_to_nid(mz->zone), zone_idx(mz->zone),
-				BIT(LRU_ACTIVE_ANON));
-		inactive = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
-				zone_to_nid(mz->zone), zone_idx(mz->zone),
-				BIT(LRU_INACTIVE_ANON));
-	}
+	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
+	active = lruvec->pages_count[LRU_ACTIVE_ANON];
+	inactive = lruvec->pages_count[LRU_INACTIVE_ANON];
 
 	return inactive * ratio < active;
 }
@@ -1861,18 +1854,11 @@ static inline int inactive_anon_is_low(struct mem_cgroup_zone *mz,
 static int inactive_file_is_low(struct mem_cgroup_zone *mz)
 {
 	unsigned long active, inactive;
+	struct lruvec *lruvec;
 
-	if (scanning_global_lru(mz)) {
-		active = zone_page_state(mz->zone, NR_ACTIVE_FILE);
-		inactive = zone_page_state(mz->zone, NR_INACTIVE_FILE);
-	} else {
-		active = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
-				zone_to_nid(mz->zone), zone_idx(mz->zone),
-				BIT(LRU_ACTIVE_FILE));
-		inactive = mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
-				zone_to_nid(mz->zone), zone_idx(mz->zone),
-				BIT(LRU_INACTIVE_FILE));
-	}
+	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
+	active = lruvec->pages_count[LRU_ACTIVE_FILE];
+	inactive = lruvec->pages_count[LRU_INACTIVE_FILE];
 
 	return inactive < active;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
