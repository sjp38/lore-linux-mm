Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 185978E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:52:06 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c34so34718737edb.8
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:52:06 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id a30-v6si360894ejl.130.2019.01.04.04.52.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:52:04 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 33A8A1C1B9A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:52:04 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 10/25] mm, compaction: Ignore the fragmentation avoidance boost for isolation and compaction
Date: Fri,  4 Jan 2019 12:49:56 +0000
Message-Id: <20190104125011.16071-11-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

When pageblocks get fragmented, watermarks are artifically boosted to
reclaim pages to avoid further fragmentation events. However, compaction
is often either fragmentation-neutral or moving movable pages away from
unmovable/reclaimable pages. As the true watermarks are preserved, allow
compaction to ignore the boost factor.

The expected impact is very slight as the main benefit is that compaction
is slightly more likely to succeed when the system has been fragmented
very recently. On both 1-socket and 2-socket machines for THP-intensive
allocation during fragmentation the success rate was increased by less
than 1% which is marginal. However, detailed tracing indicated that
failure of migration due to a premature ENOMEM triggered by watermark
checks were eliminated.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 57ba9d1da519..05c9a81d54ed 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2958,7 +2958,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		 * watermark, because we already know our high-order page
 		 * exists.
 		 */
-		watermark = min_wmark_pages(zone) + (1UL << order);
+		watermark = zone->_watermark[WMARK_MIN] + (1UL << order);
 		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
 			return 0;
 
-- 
2.16.4
