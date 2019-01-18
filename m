Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC468E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:53:10 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so5124829edm.18
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:53:10 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id b11si2180785edj.393.2019.01.18.09.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:53:08 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 803011C35AE
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:53:08 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 08/22] mm, compaction: Ignore the fragmentation avoidance boost for isolation and compaction
Date: Fri, 18 Jan 2019 17:51:22 +0000
Message-Id: <20190118175136.31341-9-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fc769ff4fb2c..6607cb7131b0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3071,7 +3071,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		 * watermark, because we already know our high-order page
 		 * exists.
 		 */
-		watermark = min_wmark_pages(zone) + (1UL << order);
+		watermark = zone->_watermark[WMARK_MIN] + (1UL << order);
 		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
 			return 0;
 
-- 
2.16.4
