Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AE50A6B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 02:52:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o696qrWW013862
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Jul 2010 15:52:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9275845DE4D
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:52:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 55C4345DE50
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:52:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A4451DB803F
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:52:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9316A1DB803E
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:52:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan: protect to read reclaim_stat by lru_lock
Message-Id: <20100709155108.3D2A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  9 Jul 2010 15:52:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Rik van Riel pointed out reading reclaim_stat should be protected
lru_lock, otherwise vmscan might sweep 2x much pages.

This fault was introduced by followint commit.

  commit 4f98a2fee8acdb4ac84545df98cccecfd130f8db
  Author: Rik van Riel <riel@redhat.com>
  Date:   Sat Oct 18 20:26:32 2008 -0700

    vmscan: split LRU lists into anon & file sets

    Split the LRU lists in two, one set for pages that are backed by real file
    systems ("file") and one for pages that are backed by memory and swap
    ("anon").  The latter includes tmpfs.

    The advantage of doing this is that the VM will not have to scan over lots
    of anonymous pages (which we generally do not want to swap out), just to
    find the page cache pages that it should evict.

    This patch has the infrastructure and a basic policy to balance how much
    we scan the anon lists and how much we scan the file lists.  The big
    policy changes are in separate patches.

Cc: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0f9f624..5a377e6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1581,6 +1581,13 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	}
 
 	/*
+	 * With swappiness at 100, anonymous and file have the same priority.
+	 * This scanning priority is essentially the inverse of IO cost.
+	 */
+	anon_prio = sc->swappiness;
+	file_prio = 200 - sc->swappiness;
+
+	/*
 	 * OK, so we have swap space and a fair amount of page cache
 	 * pages.  We use the recently rotated / recently scanned
 	 * ratios to determine how valuable each cache is.
@@ -1591,28 +1598,18 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	 *
 	 * anon in [0], file in [1]
 	 */
+	spin_lock_irq(&zone->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
-		spin_lock_irq(&zone->lru_lock);
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
-		spin_unlock_irq(&zone->lru_lock);
 	}
 
 	if (unlikely(reclaim_stat->recent_scanned[1] > file / 4)) {
-		spin_lock_irq(&zone->lru_lock);
 		reclaim_stat->recent_scanned[1] /= 2;
 		reclaim_stat->recent_rotated[1] /= 2;
-		spin_unlock_irq(&zone->lru_lock);
 	}
 
 	/*
-	 * With swappiness at 100, anonymous and file have the same priority.
-	 * This scanning priority is essentially the inverse of IO cost.
-	 */
-	anon_prio = sc->swappiness;
-	file_prio = 200 - sc->swappiness;
-
-	/*
 	 * The amount of pressure on anon vs file pages is inversely
 	 * proportional to the fraction of recently scanned pages on
 	 * each list that were recently referenced and in active use.
@@ -1622,6 +1619,7 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
+	spin_unlock_irq(&zone->lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
