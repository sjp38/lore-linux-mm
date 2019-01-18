Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26D288E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:52:50 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so5312915ede.19
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:52:50 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id m3-v6si1788975ejb.316.2019.01.18.09.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:52:48 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 341701C35B5
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:52:48 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 06/22] mm, migrate: Immediately fail migration of a page with no migration handler
Date: Fri, 18 Jan 2019 17:51:20 +0000
Message-Id: <20190118175136.31341-7-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Pages with no migration handler use a fallback handler which sometimes
works and sometimes persistently retries. A historical example was blockdev
pages but there are others such as odd refcounting when page->private
is used.  These are retried multiple times which is wasteful during
compaction so this patch will fail migration faster unless the caller
specifies MIGRATE_SYNC.

This is not expected to help THP allocation success rates but it did
reduce latencies very slightly in some cases.

1-socket thpfioscale
                                        4.20.0                 4.20.0
                              noreserved-v2r15         failfast-v2r15
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      3839.67 (   0.00%)     3833.72 (   0.15%)
Amean     fault-both-5      5177.47 (   0.00%)     4967.15 (   4.06%)
Amean     fault-both-7      7245.03 (   0.00%)     7139.19 (   1.46%)
Amean     fault-both-12    11534.89 (   0.00%)    11326.30 (   1.81%)
Amean     fault-both-18    16241.10 (   0.00%)    16270.70 (  -0.18%)
Amean     fault-both-24    19075.91 (   0.00%)    19839.65 (  -4.00%)
Amean     fault-both-30    22712.11 (   0.00%)    21707.05 (   4.43%)
Amean     fault-both-32    21692.92 (   0.00%)    21968.16 (  -1.27%)

The 2-socket results are not materially different. Scan rates are similar
as expected.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 52b04c217e30..4512afab46ac 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -916,7 +916,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 	 */
 	if (page_has_private(page) &&
 	    !try_to_release_page(page, GFP_KERNEL))
-		return -EAGAIN;
+		return mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
 
 	return migrate_page(mapping, newpage, page, mode);
 }
-- 
2.16.4
