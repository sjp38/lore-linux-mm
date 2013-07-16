Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 718C16B0034
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 19:31:09 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Jul 2013 09:15:42 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 38A542BB0051
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 09:31:04 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6GNFnae4260136
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 09:15:49 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6GNV2r0007615
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 09:31:03 +1000
Date: Wed, 17 Jul 2013 07:31:01 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 04/10] mm: zone_reclaim: compaction: reset before
 initializing the scan cursors
Message-ID: <20130716233101.GB30164@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1373982114-19774-1-git-send-email-aarcange@redhat.com>
 <1373982114-19774-5-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373982114-19774-5-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Hush Bensen <hush.bensen@gmail.com>

On Tue, Jul 16, 2013 at 03:41:48PM +0200, Andrea Arcangeli wrote:
>Correct the location where we reset the scan cursors, otherwise the
>first iteration of compaction (after restarting it) will only do a
>partial scan.
>
>Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>Reviewed-by: Rik van Riel <riel@redhat.com>
>Acked-by: Mel Gorman <mgorman@suse.de>
>Acked-by: Rafael Aquini <aquini@redhat.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> mm/compaction.c | 19 +++++++++++--------
> 1 file changed, 11 insertions(+), 8 deletions(-)
>
>diff --git a/mm/compaction.c b/mm/compaction.c
>index 525baaa..afaf692 100644
>--- a/mm/compaction.c
>+++ b/mm/compaction.c
>@@ -934,6 +934,17 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> 	}
>
> 	/*
>+	 * Clear pageblock skip if there were failures recently and
>+	 * compaction is about to be retried after being
>+	 * deferred. kswapd does not do this reset and it will wait
>+	 * direct compaction to do so either when the cursor meets
>+	 * after one compaction pass is complete or if compaction is
>+	 * restarted after being deferred for a while.
>+	 */
>+	if ((compaction_restarting(zone, cc->order)) && !current_is_kswapd())
>+		__reset_isolation_suitable(zone);
>+
>+	/*
> 	 * Setup to move all movable pages to the end of the zone. Used cached
> 	 * information on where the scanners should start but check that it
> 	 * is initialised by ensuring the values are within zone boundaries.
>@@ -949,14 +960,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> 		zone->compact_cached_migrate_pfn = cc->migrate_pfn;
> 	}
>
>-	/*
>-	 * Clear pageblock skip if there were failures recently and compaction
>-	 * is about to be retried after being deferred. kswapd does not do
>-	 * this reset as it'll reset the cached information when going to sleep.
>-	 */
>-	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
>-		__reset_isolation_suitable(zone);
>-
> 	migrate_prep_local();
>
> 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
