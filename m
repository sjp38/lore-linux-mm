Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4174990010C
	for <linux-mm@kvack.org>; Mon, 16 May 2011 11:07:05 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/2] mm: vmscan: If kswapd has been running too long, allow it to sleep
Date: Mon, 16 May 2011 16:06:57 +0100
Message-Id: <1305558417-24354-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1305558417-24354-1-git-send-email-mgorman@suse.de>
References: <1305558417-24354-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>, Mel Gorman <mgorman@suse.de>

Under constant allocation pressure, kswapd can be in the situation where
sleeping_prematurely() will always return true even if kswapd has been
running a long time. Check if kswapd needs to be scheduled.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index af24d1e..4d24828 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 	unsigned long balanced = 0;
 	bool all_zones_ok = true;
 
+	/* If kswapd has been running too long, just sleep */
+	if (need_resched())
+		return false;
+
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
 		return true;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
