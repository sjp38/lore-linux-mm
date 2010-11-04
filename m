Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 269246B00CA
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 20:51:09 -0400 (EDT)
Subject: [patch]vmscan: avoid set zone congested if no page dirty
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Nov 2010 08:50:58 +0800
Message-ID: <1288831858.23014.129.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: mel <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

nr_dirty and nr_congested are increased only when page is dirty. So if all pages
are clean, both them will be zero. In this case, we should not mark the zone
congested.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b8a6fdc..d31d7ce 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -913,7 +913,7 @@ keep_lumpy:
 	 * back off and wait for congestion to clear because further reclaim
 	 * will encounter the same problem
 	 */
-	if (nr_dirty == nr_congested)
+	if (nr_dirty == nr_congested && nr_dirty != 0)
 		zone_set_flag(zone, ZONE_CONGESTED);
 
 	free_page_list(&free_pages);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
