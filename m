Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4DAC06B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 05:54:03 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/2] mm: vmscan: Correctly check if reclaimer should schedule during shrink_slab
Date: Mon, 23 May 2011 10:53:55 +0100
Message-Id: <1306144435-2516-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1306144435-2516-1-git-send-email-mgorman@suse.de>
References: <1306144435-2516-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>, Mel Gorman <mgorman@suse.de>

It has been reported on some laptops that kswapd is consuming large
amounts of CPU and not being scheduled when SLUB is enabled during
large amounts of file copying. It is expected that this is due to
kswapd missing every cond_resched() point because;

shrink_page_list() calls cond_resched() if inactive pages were isolated
        which in turn may not happen if all_unreclaimable is set in
        shrink_zones(). If for whatver reason, all_unreclaimable is
        set on all zones, we can miss calling cond_resched().

balance_pgdat() only calls cond_resched if the zones are not
        balanced. For a high-order allocation that is balanced, it
        checks order-0 again. During that window, order-0 might have
        become unbalanced so it loops again for order-0 and returns
        that it was reclaiming for order-0 to kswapd(). It can then
        find that a caller has rewoken kswapd for a high-order and
        re-enters balance_pgdat() without ever calling cond_resched().

shrink_slab only calls cond_resched() if we are reclaiming slab
	pages. If there are a large number of direct reclaimers, the
	shrinker_rwsem can be contended and prevent kswapd calling
	cond_resched().

This patch modifies the shrink_slab() case. If the semaphore is
contended, the caller will still check cond_resched(). After each
successful call into a shrinker, the check for cond_resched() remains
in case one shrinker is particularly slow.

This patch replaces
mm-vmscan-if-kswapd-has-been-running-too-long-allow-it-to-sleep.patch
in -mm.

[mgorman@suse.de: Preserve call to cond_resched after each call into shrinker]
From: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1aa262b..cc1470b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -230,8 +230,11 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 	if (scanned == 0)
 		scanned = SWAP_CLUSTER_MAX;
 
-	if (!down_read_trylock(&shrinker_rwsem))
-		return 1;	/* Assume we'll be able to shrink next time */
+	if (!down_read_trylock(&shrinker_rwsem)) {
+		/* Assume we'll be able to shrink next time */
+		ret = 1;
+		goto out;
+	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
@@ -282,6 +285,8 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 		shrinker->nr += total_scan;
 	}
 	up_read(&shrinker_rwsem);
+out:
+	cond_resched();
 	return ret;
 }
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
