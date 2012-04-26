Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E9CB86B0092
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 03:54:07 -0400 (EDT)
Received: by mail-lpp01m010-f41.google.com with SMTP id z14so991381lag.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 00:54:07 -0700 (PDT)
Subject: [PATCH 04/12] mm/vmscan: push zone pointer into shrink_page_list()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 26 Apr 2012 11:54:04 +0400
Message-ID: <20120426075404.18961.18621.stgit@zurg>
In-Reply-To: <20120426074632.18961.17803.stgit@zurg>
References: <20120426074632.18961.17803.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

It doesn't need pointer to cgroup, pointer to zone is enough.
This patch also kills "mz" argument of page_check_references(), it unused after
"mm: memcg: count pte references from every member of the reclaimed hierarch"

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 49e79d5..44d5821 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -629,7 +629,6 @@ enum page_references {
 };
 
 static enum page_references page_check_references(struct page *page,
-						  struct mem_cgroup_zone *mz,
 						  struct scan_control *sc)
 {
 	int referenced_ptes, referenced_page;
@@ -688,7 +687,7 @@ static enum page_references page_check_references(struct page *page,
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-				      struct mem_cgroup_zone *mz,
+				      struct zone *zone,
 				      struct scan_control *sc,
 				      unsigned long *ret_nr_dirty,
 				      unsigned long *ret_nr_writeback)
@@ -718,7 +717,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep;
 
 		VM_BUG_ON(PageActive(page));
-		VM_BUG_ON(page_zone(page) != mz->zone);
+		VM_BUG_ON(page_zone(page) != zone);
 
 		sc->nr_scanned++;
 
@@ -741,7 +740,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep;
 		}
 
-		references = page_check_references(page, mz, sc);
+		references = page_check_references(page, sc);
 		switch (references) {
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
@@ -931,7 +930,7 @@ keep:
 	 * will encounter the same problem
 	 */
 	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
-		zone_set_flag(mz->zone, ZONE_CONGESTED);
+		zone_set_flag(zone, ZONE_CONGESTED);
 
 	free_hot_cold_page_list(&free_pages, 1);
 
@@ -1309,7 +1308,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 
 	update_isolated_counts(mz, &page_list, &nr_anon, &nr_file);
 
-	nr_reclaimed = shrink_page_list(&page_list, mz, sc,
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
 						&nr_dirty, &nr_writeback);
 
 	spin_lock_irq(&zone->lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
