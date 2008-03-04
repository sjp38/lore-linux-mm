Received: by fg-out-1718.google.com with SMTP id e12so487029fga.4
        for <linux-mm@kvack.org>; Tue, 04 Mar 2008 02:53:13 -0800 (PST)
Message-ID: <47CD270D.7080502@gmail.com>
Date: Tue, 04 Mar 2008 19:40:13 +0900
MIME-Version: 1.0
Subject: Re: [patch 08/21] (NEW) add some sanity checks to get_scan_ratio
References: <20080228192908.126720629@redhat.com> <20080228192928.566747790@redhat.com>
In-Reply-To: <20080228192928.566747790@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
From: minchan Kim <minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

@@ -1182,9 +1194,8 @@ static unsigned long shrink_list(enum lr
  static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
  					unsigned long *percent)
  {
-	unsigned long anon, file;
+	unsigned long anon, file, free;
  	unsigned long anon_prio, file_prio;
-	unsigned long rotate_sum;
  	unsigned long ap, fp;

  	anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
@@ -1192,15 +1203,19 @@ static void get_scan_ratio(struct zone *
  	file  = zone_page_state(zone, NR_ACTIVE_FILE) +
  		zone_page_state(zone, NR_INACTIVE_FILE);

-	rotate_sum = zone->recent_rotated_file + zone->recent_rotated_anon;
-
  	/* Keep a floating average of RECENT references. */
-	if (unlikely(rotate_sum > min(anon, file))) {
+	if (unlikely(zone->recent_scanned_anon > anon / zone->inactive_ratio)) {
  		spin_lock_irq(&zone->lru_lock);
-		zone->recent_rotated_file /= 2;
+		zone->recent_scanned_anon /= 2;
  		zone->recent_rotated_anon /= 2;
  		spin_unlock_irq(&zone->lru_lock);
-		rotate_sum /= 2;
+	}
+
+	if (unlikely(zone->recent_scanned_file > file / 4)) {
+		spin_lock_irq(&zone->lru_lock);
+		zone->recent_scanned_file /= 2;
+		zone->recent_rotated_file /= 2;
+		spin_unlock_irq(&zone->lru_lock);
  	}

  	/*
@@ -1213,23 +1228,33 @@ static void get_scan_ratio(struct zone *
  	/*
  	 *                  anon       recent_rotated_anon
  	 * %anon = 100 * ----------- / ------------------- * IO cost
-	 *               anon + file       rotate_sum
+	 *               anon + file   recent_scanned_anon
  	 */
-	ap = (anon_prio * anon) / (anon + file + 1);
-	ap *= rotate_sum / (zone->recent_rotated_anon + 1);
-	if (ap == 0)
-		ap = 1;
-	else if (ap > 100)
-		ap = 100;
-	percent[0] = ap;
-
-	fp = (file_prio * file) / (anon + file + 1);
-	fp *= rotate_sum / (zone->recent_rotated_file + 1);
-	if (fp == 0)
-		fp = 1;
-	else if (fp > 100)
-		fp = 100;
-	percent[1] = fp;
+	ap = (anon_prio + 1) * (zone->recent_scanned_anon + 1);
+	ap /= zone->recent_rotated_anon + 1;
+
+	fp = (file_prio + 1) * (zone->recent_scanned_file + 1);
+	fp /= zone->recent_rotated_file + 1;
+
+	/* Normalize to percentages */
+	percent[0] = 100 * ap / (ap + fp + 1);
+	percent[1] = 100 - percent[0];
+
+	free = zone_page_state(zone, NR_FREE_PAGES);
+
+	/*
+	 * If we have no swap space, do not bother scanning anon pages.
+	 */
+	if (nr_swap_pages <= 0) {
+		percent[0] = 0;
+		percent[1] = 100;
+	}
+	/*
+	 * If we already freed most file pages, scan the anon pages
+	 * regardless of the page access ratios or swappiness setting.
+	 */
+	else if (file + free <= zone->pages_high)
+		percent[0] = 100;
  }

I think we don't need to calculate ratio percent if it don't have any 
swap device.

we can get a little bit performance gain.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e6cb98b..e578c62 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1313,6 +1313,15 @@ static void get_scan_ratio(struct zone *zone, 
struct scan_control * sc,
   unsigned long anon_prio, file_prio;
   unsigned long ap, fp;

+ /*
+  * If we have no swap space, do not bother scanning anon pages and 
unnessary calculation.
+  */
+ if (nr_swap_pages <= 0) {
+   percent[0] = 0;
+   percent[1] = 100;
+   return;
+ }
+
   anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
     zone_page_state(zone, NR_INACTIVE_ANON);
   file  = zone_page_state(zone, NR_ACTIVE_FILE) +
@@ -1357,18 +1366,12 @@ static void get_scan_ratio(struct zone *zone, 
struct scan_control * sc,

   free = zone_page_state(zone, NR_FREE_PAGES);

- /*
-  * If we have no swap space, do not bother scanning anon pages.
-  */
- if (nr_swap_pages <= 0) {
-   percent[0] = 0;
-   percent[1] = 100;
- }
+
   /*
    * If we already freed most file pages, scan the anon pages
    * regardless of the page access ratios or swappiness setting.
    */
- else if (file + free <= zone->pages_high)
+ if (file + free <= zone->pages_high)
     percent[0] = 100;
  }

Thanks,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
