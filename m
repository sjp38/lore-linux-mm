Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E926D6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:36:42 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id 123so111049953wmz.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:36:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z187si5039965wmb.114.2016.01.26.07.36.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 07:36:41 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 1/3] mm, kswapd: remove bogus check of balance_classzone_idx
Date: Tue, 26 Jan 2016 16:36:13 +0100
Message-Id: <1453822575-20835-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

During work on kcompactd integration I have spotted a confusing check of
balance_classzone_idx, which I believe is bogus.

The balanced_classzone_idx is filled by balance_pgdat() as the highest zone
it attempted to balance. This was introduced by commit dc83edd941f4 ("mm:
kswapd: use the classzone idx that kswapd was using for
sleeping_prematurely()"). The intention is that (as expressed in today's
function names), the value used for kswapd_shrink_zone() calls in
balance_pgdat() is the same as for the decisions in kswapd_try_to_sleep().
An unwanted side-effect of that commit was breaking the checks in kswapd()
whether there was another kswapd_wakeup with a tighter (=lower) classzone_idx.
Commits 215ddd6664ce ("mm: vmscan: only read new_classzone_idx from pgdat
when reclaiming successfully") and d2ebd0f6b895 ("kswapd: avoid unnecessary
rebalance after an unsuccessful balancing") tried to fixed, but apparently
introduced a bogus check that this patch removes.

Consider zone indexes X < Y < Z, where:
- Z is the value used for the first kswapd wakeup.
- Y is returned as balanced_classzone_idx, which means zones with index higher
  than Y (including Z) were found to be unreclaimable.
- X is the value used for the second kswapd wakeup

The new wakeup with value X means that kswapd is now supposed to balance harder
all zones with index <= X. But instead, due to Y < Z, it will go sleep and
won't read the new value X. This is subtly wrong.

The effect of this patch is that kswapd will react better in some situations,
where e.g. the first wakeup is for ZONE_DMA32, the second is for ZONE_DMA, and
due to unreclaimable ZONE_NORMAL. Before this patch, kswapd would go sleep
instead of reclaiming ZONE_DMA harder. I expect these situations are very rare,
and more value is in better maintainability due to the removal of confusing
and bogus check.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb3dd37ccd7c..72d52d3aef74 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3481,8 +3481,7 @@ static int kswapd(void *p)
 		 * new request of a similar or harder type will succeed soon
 		 * so consider going to sleep on the basis we reclaimed at
 		 */
-		if (balanced_classzone_idx >= new_classzone_idx &&
-					balanced_order == new_order) {
+		if (balanced_order == new_order) {
 			new_order = pgdat->kswapd_max_order;
 			new_classzone_idx = pgdat->classzone_idx;
 			pgdat->kswapd_max_order =  0;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
