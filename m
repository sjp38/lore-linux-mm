Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ABCA36B0022
	for <linux-mm@kvack.org>; Mon, 23 May 2011 05:54:03 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] mm: vmscan: Correct use of pgdat_balanced in sleeping_prematurely
Date: Mon, 23 May 2011 10:53:54 +0100
Message-Id: <1306144435-2516-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1306144435-2516-1-git-send-email-mgorman@suse.de>
References: <1306144435-2516-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>, Mel Gorman <mgorman@suse.de>

From: Johannes Weiner <hannes@cmpxchg.org>

Johannes Weiner poined out that the logic in commit [1741c877: mm:
kswapd: keep kswapd awake for high-order allocations until a percentage
of the node is balanced] is backwards. Instead of allowing kswapd to go
to sleep when balancing for high order allocations, it keeps it kswapd
running uselessly.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8bfd450..1aa262b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2286,7 +2286,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 	 * must be balanced
 	 */
 	if (order)
-		return pgdat_balanced(pgdat, balanced, classzone_idx);
+		return !pgdat_balanced(pgdat, balanced, classzone_idx);
 	else
 		return !all_zones_ok;
 }
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
