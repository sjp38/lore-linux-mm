Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03FE86B422D
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:35:11 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so9013330eda.12
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 06:35:10 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id n23si401920edt.94.2018.11.26.06.35.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 06:35:05 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id DF7E51C2CBB
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:35:04 +0000 (GMT)
Date: Mon, 26 Nov 2018 14:35:03 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm: Use alloc_flags to record if kswapd can wake -fix
Message-ID: <20181126143503.GO23260@techsingularity.net>
References: <20181123114528.28802-1-mgorman@techsingularity.net>
 <20181123114528.28802-4-mgorman@techsingularity.net>
 <39711f99-1a2a-67d3-5cb0-a63ac739a917@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <39711f99-1a2a-67d3-5cb0-a63ac739a917@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Vlastimil Babka correctly pointed out that the ALLOC_KSWAPD flag needs to be
applied in the !CONFIG_ZONE_DMA32 case. This is a fix for the mmotm path
mm-use-alloc_flags-to-record-if-kswapd-can-wake.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e44eb68744ed..a48ebb821360 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3268,7 +3268,6 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 }
 #endif	/* CONFIG_NUMA */
 
-#ifdef CONFIG_ZONE_DMA32
 /*
  * The restriction on ZONE_DMA32 as being a suitable zone to use to avoid
  * fragmentation is subtle. If the preferred zone was HIGHMEM then
@@ -3285,6 +3284,7 @@ alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		alloc_flags |= ALLOC_KSWAPD;
 
+#ifdef CONFIG_ZONE_DMA32
 	if (zone_idx(zone) != ZONE_NORMAL)
 		goto out;
 
@@ -3298,15 +3298,9 @@ alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
 		goto out;
 
 out:
+#endif /* CONFIG_ZONE_DMA32 */
 	return alloc_flags;
 }
-#else
-static inline unsigned int
-alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
-{
-	return 0;
-}
-#endif
 
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
