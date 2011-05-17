Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6244F6B0023
	for <linux-mm@kvack.org>; Tue, 17 May 2011 12:15:16 -0400 (EDT)
Date: Tue, 17 May 2011 17:15:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: vmscan: Correctly check if reclaimer should schedule
 during shrink_slab
Message-ID: <20110517161508.GN5279@suse.de>
References: <1305295404-12129-5-git-send-email-mgorman@suse.de>
 <4DCFAA80.7040109@jp.fujitsu.com>
 <1305519711.4806.7.camel@mulgrave.site>
 <BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
 <20110516084558.GE5279@suse.de>
 <BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
 <20110516102753.GF5279@suse.de>
 <BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
 <20110517103840.GL5279@suse.de>
 <1305640239.2046.27.camel@lenovo>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1305640239.2046.27.camel@lenovo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Minchan Kim <minchan.kim@gmail.com>, Colin Ian King <colin.king@canonical.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

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
successful call into a shrinker, the check for cond_resched() is
still necessary in case one shrinker call is particularly slow.

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
index af24d1e..0bed248 100644
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
