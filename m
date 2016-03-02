Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0A259828E1
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 07:27:40 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l68so82637626wml.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 04:27:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r187si4598352wmd.58.2016.03.02.04.27.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 04:27:39 -0800 (PST)
Subject: Re: [PATCH v2 4/5] mm, kswapd: replace kswapd compaction with waking
 up kcompactd
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
 <1454938691-2197-5-git-send-email-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D6DC39.4020608@suse.cz>
Date: Wed, 2 Mar 2016 13:27:37 +0100
MIME-Version: 1.0
In-Reply-To: <1454938691-2197-5-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

A fixlet for things Joonsoo caught.

----8<----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Wed, 2 Mar 2016 11:50:16 +0100
Subject: mm-kswapd-replace-kswapd-compaction-with-waking-up-kcompactd-fix

Change zone_balanced() check in balance_pgdat() to consider only base pages
as that's the same what kswapd_shrink_zone() later does. So a zone that would
be selected due to lack of high-order pages would not be reclaimed anyway,
and just cause extra CPU churn.

Also remove unnecessary variable testorder in kswapd_shrink_zone().

Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b8478a737ef5..23bc7e643ad8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3073,7 +3073,6 @@ static bool kswapd_shrink_zone(struct zone *zone,
 			       int classzone_idx,
 			       struct scan_control *sc)
 {
-	int testorder = sc->order;
 	unsigned long balance_gap;
 	bool lowmem_pressure;
 
@@ -3094,7 +3093,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	 * reclaim is necessary
 	 */
 	lowmem_pressure = (buffer_heads_over_limit && is_highmem(zone));
-	if (!lowmem_pressure && zone_balanced(zone, testorder, false,
+	if (!lowmem_pressure && zone_balanced(zone, sc->order, false,
 						balance_gap, classzone_idx))
 		return true;
 
@@ -3109,7 +3108,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	 * waits.
 	 */
 	if (zone_reclaimable(zone) &&
-	    zone_balanced(zone, testorder, false, 0, classzone_idx)) {
+	    zone_balanced(zone, sc->order, false, 0, classzone_idx)) {
 		clear_bit(ZONE_CONGESTED, &zone->flags);
 		clear_bit(ZONE_DIRTY, &zone->flags);
 	}
@@ -3190,7 +3189,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 				break;
 			}
 
-			if (!zone_balanced(zone, order, true, 0, 0)) {
+			if (!zone_balanced(zone, order, false, 0, 0)) {
 				end_zone = i;
 				break;
 			} else {
-- 
2.7.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
