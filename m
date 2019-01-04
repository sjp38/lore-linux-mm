Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 752B58E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:51:35 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c3so35318604eda.3
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:51:35 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id r24si203929edp.187.2019.01.04.04.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:51:33 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 94DED98837
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:51:33 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 07/25] mm, migrate: Immediately fail migration of a page with no migration handler
Date: Fri,  4 Jan 2019 12:49:53 +0000
Message-Id: <20190104125011.16071-8-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
index 5d1839a9148d..547cc1f3f3bb 100644
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
