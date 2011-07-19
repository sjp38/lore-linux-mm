Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8BC766B0082
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 03:09:30 -0400 (EDT)
Subject: [PATCH]vmscan: fix a livelock in kswapd
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Jul 2011 15:09:27 +0800
Message-ID: <1311059367.15392.299.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@suse.de, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

I'm running a workload which triggers a lot of swap in a machine with 4 nodes.
After I kill the workload, I found a kswapd livelock. Sometimes kswapd3 or
kswapd2 are keeping running and I can't access filesystem, but most memory is
free. This looks like a regression since commit 08951e545918c159.
Node 2 and 3 have only ZONE_NORMAL, but balance_pgdat() will return 0 for
classzone_idx. The reason is end_zone in balance_pgdat() is 0 by default, if
all zones have watermark ok, end_zone will keep 0.
Later sleeping_prematurely() always returns true. Because this is an order 3
wakeup, and if classzone_idx is 0, both balanced_pages and present_pages
in pgdat_balanced() are 0.
We add a special case here. If a zone has no page, we think it's balanced. This
fixes the livelock.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5ed24b9..ad4056f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2310,7 +2310,8 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
 	for (i = 0; i <= classzone_idx; i++)
 		present_pages += pgdat->node_zones[i].present_pages;
 
-	return balanced_pages > (present_pages >> 2);
+	/* A special case here: if zone has no page, we think it's balanced */
+	return balanced_pages >= (present_pages >> 2);
 }
 
 /* is kswapd sleeping prematurely? */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
