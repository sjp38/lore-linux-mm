Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id D999A6B005A
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:38:59 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v7 09/11] Get rid of depenceny that all pages is from a zone in shrink_page_list
Date: Tue, 12 Mar 2013 16:38:33 +0900
Message-Id: <1363073915-25000-10-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

Now shrink_page_list expect all pages come from a same zone
but it's too limited to use it.

This patch removes the dependency and add may_discard in scan_control
so next patch can use shrink_page_list with pages from multiple zonnes.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6ba4e8ea..e36ee51 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -77,6 +77,9 @@ struct scan_control {
 	/* Can pages be swapped as part of reclaim? */
 	int may_swap;
 
+	/* Discard pages in vrange */
+	int may_discard;
+
 	int order;
 
 	/* Scan (total_size >> priority) pages at once */
@@ -714,7 +717,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep;
 
 		VM_BUG_ON(PageActive(page));
-		VM_BUG_ON(page_zone(page) != zone);
+		if (zone)
+			VM_BUG_ON(page_zone(page) != zone);
 
 		sc->nr_scanned++;
 
@@ -785,6 +789,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			; /* try to reclaim the page below */
 		}
 
+		/* Fail to discard a page and returns a page to caller */
+		if (sc->may_discard)
+			goto keep_locked;
+				
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
@@ -963,7 +971,8 @@ keep:
 	 * back off and wait for congestion to clear because further reclaim
 	 * will encounter the same problem
 	 */
-	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
+	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc) &&
+		zone)
 		zone_set_flag(zone, ZONE_CONGESTED);
 
 	free_hot_cold_page_list(&free_pages, 1);
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
