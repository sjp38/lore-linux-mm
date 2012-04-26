Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 50D266B00E9
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 03:54:15 -0400 (EDT)
Received: by mail-lpp01m010-f41.google.com with SMTP id z14so991336lag.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 00:54:14 -0700 (PDT)
Subject: [PATCH 06/12] mm/vmscan: push lruvec pointer into
 putback_inactive_pages()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 26 Apr 2012 11:54:12 +0400
Message-ID: <20120426075412.18961.10658.stgit@zurg>
In-Reply-To: <20120426074632.18961.17803.stgit@zurg>
References: <20120426074632.18961.17803.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now zone_reclaim_stat located on lruvec, we can reach it directly.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 814948ad9..31df071 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1155,11 +1155,11 @@ static int too_many_isolated(struct zone *zone, int file,
 }
 
 static noinline_for_stack void
-putback_inactive_pages(struct mem_cgroup_zone *mz,
+putback_inactive_pages(struct lruvec *lruvec,
 		       struct list_head *page_list)
 {
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
-	struct zone *zone = mz->zone;
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	struct zone *zone = lruvec_zone(lruvec);
 	LIST_HEAD(pages_to_free);
 
 	/*
@@ -1319,7 +1319,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	putback_inactive_pages(mz, &page_list);
+	putback_inactive_pages(lruvec, &page_list);
 
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
