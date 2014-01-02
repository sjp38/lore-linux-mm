Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 66AD96B006C
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:23 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so13935682pdj.11
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:23 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id wm3si41540365pab.281.2014.01.01.23.13.20
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:21 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 16/16] vrange: Add vmstat counter about purged page
Date: Thu,  2 Jan 2014 16:12:24 +0900
Message-Id: <1388646744-15608-17-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

Adds some vmstat for analysise vrange working.

[PGDISCARD|PGVSCAN]_[KSWAPD|DIRECT] means purged page/scanning
so we could see effectiveness of vrange.

PGDISCARD_RESCUED means how many of pages we are missing in
core discarding logic of vrange so if it is big in no big memory
pressure, it may have a problem in scanning logic.

PGDISCARD_SAVE_RECLAIM means how many time we avoid reclaim via
discarding volatile pages but not sure how it is exact because
sc->nr_to_reclaim is very high if it were sc->prioirty is low(ie,
high memory pressure) so it it hard to meet the condition.
Maybe I would change the check via zone_watermark_ok.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/vm_event_item.h |    6 ++++++
 mm/vmscan.c                   |    8 ++++++--
 mm/vmstat.c                   |    6 ++++++
 mm/vrange.c                   |   14 ++++++++++++++
 4 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 1855f0a22add..df0d8e9e0540 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -25,6 +25,12 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
+		PGVSCAN_KSWAPD,
+		PGVSCAN_DIRECT,
+		PGDISCARD_KSWAPD,
+		PGDISCARD_DIRECT,
+		PGDISCARD_RESCUED, /* rescued from shrink_page_list */
+		PGDISCARD_SAVE_RECLAIM, /* how many save reclaim */
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
 		FOR_ALL_ZONES(PGSTEAL_DIRECT),
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d8f45af1ab84..c88e48be010b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -886,8 +886,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * because page->mapping could be NULL if it's purged.
 		 */
 		case PAGEREF_DISCARD:
-			if (may_enter_fs && discard_vpage(page) == 0)
+			if (may_enter_fs && discard_vpage(page) == 0) {
+				count_vm_event(PGDISCARD_RESCUED);
 				goto free_it;
+			}
 		case PAGEREF_KEEP:
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
@@ -1768,8 +1770,10 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	unsigned long nr_reclaimed;
 
 	nr_reclaimed = shrink_vrange(lru, lruvec, sc);
-	if (nr_reclaimed >= sc->nr_to_reclaim)
+	if (nr_reclaimed >= sc->nr_to_reclaim) {
+		count_vm_event(PGDISCARD_SAVE_RECLAIM);
 		return nr_reclaimed;
+	}
 
 	if (is_active_lru(lru)) {
 		if (inactive_list_is_low(lruvec, lru))
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9bb314577911..fa4eea4c5499 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -789,6 +789,12 @@ const char * const vmstat_text[] = {
 
 	"pgfault",
 	"pgmajfault",
+	"pgvscan_kswapd",
+	"pgvscan_direct",
+	"pgdiscard_kswapd",
+	"pgdiscard_direct",
+	"pgdiscard_rescued",
+	"pgdiscard_save_reclaim",
 
 	TEXTS_FOR_ZONES("pgrefill")
 	TEXTS_FOR_ZONES("pgsteal_kswapd")
diff --git a/mm/vrange.c b/mm/vrange.c
index 6cdbf6feed26..16de0a085453 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -1223,6 +1223,7 @@ static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard,
 {
 	int ret = 0;
 	struct vrange_root *vroot;
+	unsigned long total_scan = *scan;
 	vroot = vrange->owner;
 
 	vroot = vrange_get_vroot(vrange);
@@ -1244,6 +1245,19 @@ static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard,
 		ret = __discard_vrange_file(mapping, vrange, nr_discard, scan);
 	}
 
+	if (!ret) {
+		if (current_is_kswapd())
+			count_vm_events(PGDISCARD_KSWAPD, *nr_discard);
+		else
+			count_vm_events(PGDISCARD_DIRECT, *nr_discard);
+	}
+
+	if (current_is_kswapd())
+		count_vm_events(PGVSCAN_KSWAPD,
+				(total_scan - *scan) >> PAGE_SHIFT);
+	else
+		count_vm_events(PGVSCAN_DIRECT,
+				(total_scan - *scan) >> PAGE_SHIFT);
 out:
 	__vroot_put(vroot);
 	return ret;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
