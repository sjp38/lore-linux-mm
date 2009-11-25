Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6E5446B0044
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 13:38:05 -0500 (EST)
Date: Wed, 25 Nov 2009 13:37:52 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] vmscan: do not evict inactive pages when skipping an active
 list scan
Message-ID: <20091125133752.2683c3e4@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, lwoodman@redhat.com, kosaki.motohiro@fujitsu.co.jp, Tomasz Chmielewski <mangoo@wpkg.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

In AIM7 runs, recent kernels start swapping out anonymous pages
well before they should.  This is due to shrink_list falling
through to shrink_inactive_list if !inactive_anon_is_low(zone, sc),
when all we really wanted to do is pre-age some anonymous pages to
give them extra time to be referenced while on the inactive list.

The obvious fix is to make sure that shrink_list does not fall
through to scanning/reclaiming inactive pages when we called it
to scan one of the active lists.

This change should be safe because the loop in shrink_zone ensures
that we will still shrink the anon and file inactive lists whenever
we should.


Reported-by: Larry Woodman <lwoodman@redhat.com>
Signed-off-by: Rik van Riel <riel@redhat.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 777af57..ec4dfda 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1469,13 +1469,15 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 {
 	int file = is_file_lru(lru);
 
-	if (lru == LRU_ACTIVE_FILE && inactive_file_is_low(zone, sc)) {
-		shrink_active_list(nr_to_scan, zone, sc, priority, file);
+	if (lru == LRU_ACTIVE_FILE) {
+		if (inactive_file_is_low(zone, sc))
+		      shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}
 
-	if (lru == LRU_ACTIVE_ANON && inactive_anon_is_low(zone, sc)) {
-		shrink_active_list(nr_to_scan, zone, sc, priority, file);
+	if (lru == LRU_ACTIVE_ANON) {
+		if (inactive_file_is_low(zone, sc))
+		      shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}
 	return shrink_inactive_list(nr_to_scan, zone, sc, priority, file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
