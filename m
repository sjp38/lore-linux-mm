Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 01 of 13] limit shrink zone scanning
Message-Id: <31ccca6f0b3ee1b340b9.1199778632@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:32 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199469588 -3600
# Node ID 31ccca6f0b3ee1b340b9d32c0231eb1f957ee1ad
# Parent  e28e1be3fae5183e3e36e32e3feb9a59ec59c825
limit shrink zone scanning

Assume two tasks adds to nr_scan_*active at the same time (first line of the
old buggy code), they'll effectively double their scan rate, for no good
reason. What can happen is that instead of scanning nr_entries each, they'll
scan nr_entries*2 each. The more CPUs the bigger the race and the higher the
multiplication effect and the harder it will be to detect oom. This puts a cap
on the amount of work that it makes sense to do in case the race triggers.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1114,7 +1114,7 @@ static unsigned long shrink_zone(int pri
 	 */
 	zone->nr_scan_active +=
 		(zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
-	nr_active = zone->nr_scan_active;
+	nr_active = min(zone->nr_scan_active, zone_page_state(zone, NR_ACTIVE));
 	if (nr_active >= sc->swap_cluster_max)
 		zone->nr_scan_active = 0;
 	else
@@ -1122,7 +1122,7 @@ static unsigned long shrink_zone(int pri
 
 	zone->nr_scan_inactive +=
 		(zone_page_state(zone, NR_INACTIVE) >> priority) + 1;
-	nr_inactive = zone->nr_scan_inactive;
+	nr_inactive = min(zone->nr_scan_inactive, zone_page_state(zone, NR_INACTIVE));
 	if (nr_inactive >= sc->swap_cluster_max)
 		zone->nr_scan_inactive = 0;
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
