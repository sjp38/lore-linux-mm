Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 116596B0036
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:42:07 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so46006eaj.7
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:42:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si1398368eew.202.2013.12.18.11.42.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 11:42:07 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/6] mm: page_alloc: Document why NR_ALLOC_BATCH is always updated
Date: Wed, 18 Dec 2013 19:41:59 +0000
Message-Id: <1387395723-25391-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1387395723-25391-1-git-send-email-mgorman@suse.de>
References: <1387395723-25391-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Johannes Weiner <hannes@cmpxchg.org>

Needs-signed-off
---
 mm/page_alloc.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f861d02..61e9e8c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1547,7 +1547,15 @@ again:
 					  get_pageblock_migratetype(page));
 	}
 
+	/*
+	 * All allocations eat into the round-robin batch, even
+	 * allocations that are not subject to round-robin placement
+	 * themselves.  This makes sure that allocations that ARE
+	 * subject to round-robin placement compensate for the
+	 * allocations that aren't, to have equal placement overall.
+	 */
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
