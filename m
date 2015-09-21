Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id D237C6B0256
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:24:13 -0400 (EDT)
Received: by iofh134 with SMTP id h134so121135265iof.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 07:24:13 -0700 (PDT)
Received: from m12-17.163.com (m12-17.163.com. [220.181.12.17])
        by mx.google.com with ESMTP id kl8si3739527igb.39.2015.09.21.07.24.11
        for <linux-mm@kvack.org>;
        Mon, 21 Sep 2015 07:24:13 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 1/2] mm/vmscan: make inactive_anon/file_is_low return bool
Date: Mon, 21 Sep 2015 21:37:52 +0800
Message-Id: <1442842673-4140-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, tj@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch makes inactive_anon/file_is_low return bool
due to these particular functions only using either one
or zero as their return value.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 mm/vmscan.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2d978b2..ed0c7fc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1859,7 +1859,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 }
 
 #ifdef CONFIG_SWAP
-static int inactive_anon_is_low_global(struct zone *zone)
+static bool inactive_anon_is_low_global(struct zone *zone)
 {
 	unsigned long active, inactive;
 
@@ -1867,9 +1867,9 @@ static int inactive_anon_is_low_global(struct zone *zone)
 	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
 
 	if (inactive * zone->inactive_ratio < active)
-		return 1;
+		return true;
 
-	return 0;
+	return false;
 }
 
 /**
@@ -1879,14 +1879,14 @@ static int inactive_anon_is_low_global(struct zone *zone)
  * Returns true if the zone does not have enough inactive anon pages,
  * meaning some active anon pages need to be deactivated.
  */
-static int inactive_anon_is_low(struct lruvec *lruvec)
+static bool inactive_anon_is_low(struct lruvec *lruvec)
 {
 	/*
 	 * If we don't have swap space, anonymous page deactivation
 	 * is pointless.
 	 */
 	if (!total_swap_pages)
-		return 0;
+		return false;
 
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_inactive_anon_is_low(lruvec);
@@ -1894,9 +1894,9 @@ static int inactive_anon_is_low(struct lruvec *lruvec)
 	return inactive_anon_is_low_global(lruvec_zone(lruvec));
 }
 #else
-static inline int inactive_anon_is_low(struct lruvec *lruvec)
+static inline bool inactive_anon_is_low(struct lruvec *lruvec)
 {
-	return 0;
+	return false;
 }
 #endif
 
@@ -1914,7 +1914,7 @@ static inline int inactive_anon_is_low(struct lruvec *lruvec)
  * This uses a different ratio than the anonymous pages, because
  * the page cache uses a use-once replacement algorithm.
  */
-static int inactive_file_is_low(struct lruvec *lruvec)
+static bool inactive_file_is_low(struct lruvec *lruvec)
 {
 	unsigned long inactive;
 	unsigned long active;
@@ -1925,7 +1925,7 @@ static int inactive_file_is_low(struct lruvec *lruvec)
 	return active > inactive;
 }
 
-static int inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru)
+static bool inactive_list_is_low(struct lruvec *lruvec, enum lru_list lru)
 {
 	if (is_file_lru(lru))
 		return inactive_file_is_low(lruvec);
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
