Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B39F6B02E7
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 04:18:18 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so23769458wmf.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 01:18:18 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id k83si18170852wmk.31.2016.12.20.01.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 01:18:17 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id a20so23184330wme.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 01:18:16 -0800 (PST)
Date: Tue, 20 Dec 2016 10:18:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 1/1] mm, page_alloc: fix incorrect zone_statistics
 data
Message-ID: <20161220091814.GC3769@dhcp22.suse.cz>
References: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
 <1481522347-20393-2-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481522347-20393-2-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>

On Mon 12-12-16 13:59:07, Jia He wrote:
> In commit b9f00e147f27 ("mm, page_alloc: reduce branches in
> zone_statistics"), it reconstructed codes to reduce the branch miss rate.
> Compared with the original logic, it assumed if !(flag & __GFP_OTHER_NODE)
>  z->node would not be equal to preferred_zone->node. That seems to be
> incorrect.

I am sorry but I have hard time following the changelog. It is clear
that you are trying to fix a missed NUMA_{HIT,OTHER} accounting
but it is not really clear when such thing happens. You are adding
preferred_zone->node check. preferred_zone is the first zone in the
requested zonelist. So for the most allocations it is a node from the
local node. But if something request an explicit numa node (without
__GFP_OTHER_NODE which would be the majority I suspect) then we could
indeed end up accounting that as a NUMA_MISS, NUMA_FOREIGN so the
referenced patch indeed caused an unintended change of accounting AFAIU.

If this is correct then it should be a part of the changelog. I also
cannot say I would like the fix. First of all I am not sure
__GFP_OTHER_NODE is a good idea at all. How is an explicit usage of the
flag any different from an explicit __alloc_pages_node(non_local_nid)?
In both cases we ask for an allocation on a remote node and successful
allocation is a NUMA_HIT and NUMA_OTHER.

That being said, why cannot we simply do the following? As a bonus, we
can get rid of a barely used __GFP_OTHER_NODE. Also the number of
branches will stay same.
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 429855be6ec9..f035d5c8b864 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2583,25 +2583,17 @@ int __isolate_free_page(struct page *page, unsigned int order)
  * Update NUMA hit/miss statistics
  *
  * Must be called with interrupts disabled.
- *
- * When __GFP_OTHER_NODE is set assume the node of the preferred
- * zone is the local node. This is useful for daemons who allocate
- * memory on behalf of other processes.
  */
 static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
 								gfp_t flags)
 {
 #ifdef CONFIG_NUMA
-	int local_nid = numa_node_id();
-	enum zone_stat_item local_stat = NUMA_LOCAL;
-
-	if (unlikely(flags & __GFP_OTHER_NODE)) {
-		local_stat = NUMA_OTHER;
-		local_nid = preferred_zone->node;
-	}
+	if (z->node == preferred_zone->node) {
+		enum zone_stat_item local_stat = NUMA_LOCAL;
 
-	if (z->node == local_nid) {
 		__inc_zone_state(z, NUMA_HIT);
+		if (z->node != numa_node_id())
+			local_stat = NUMA_OTHER;
 		__inc_zone_state(z, local_stat);
 	} else {
 		__inc_zone_state(z, NUMA_MISS);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
