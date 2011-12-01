Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 915F96B004D
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 04:20:39 -0500 (EST)
Received: by ghrr17 with SMTP id r17so2118057ghr.14
        for <linux-mm@kvack.org>; Thu, 01 Dec 2011 01:20:37 -0800 (PST)
From: Xi Wang <xi.wang@gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: [PATCH] mm: incorrect overflow check in shrink_slab()
Date: Thu, 1 Dec 2011 04:20:34 -0500
Message-Id: <0D9D9F79-204D-4460-8CE7-A583C5C38A1E@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

total_scan is unsigned long, so the overflow check (total_scan < 0)
didn't work.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a1893c0..46a04e7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -270,7 +270,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		delta *= max_pass;
 		do_div(delta, lru_pages + 1);
 		total_scan += delta;
-		if (total_scan < 0) {
+		if ((long)total_scan < 0) {
 			printk(KERN_ERR "shrink_slab: %pF negative objects to "
 			       "delete nr=%ld\n",
 			       shrinker->shrink, total_scan);
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
