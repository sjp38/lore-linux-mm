Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF008E021C
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 18:03:14 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f31so281587edf.17
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:03:14 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id k13si643824edl.377.2018.12.14.15.03.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 15:03:12 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.254.10])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 4AFED1C1D19
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 23:03:12 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 06/14] mm, migrate: Immediately fail migration of a page with no migration handler
Date: Fri, 14 Dec 2018 23:03:02 +0000
Message-Id: <20181214230310.572-7-mgorman@techsingularity.net>
In-Reply-To: <20181214230310.572-1-mgorman@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Pages with no migration handler use a fallback hander which sometimes
works and sometimes persistently fails such as blockdev pages. Migration
will retry a number of times on these persistent pages which is wasteful
during compaction. This patch will fail migration immediately unless the
caller is in MIGRATE_SYNC mode which indicates the caller is willing to
wait while being persistent.

This is not expected to help THP allocation success rates but it does
reduce latencies slightly.

1-socket thpfioscale
                                    4.20.0-rc6             4.20.0-rc6
                               noreserved-v1r4          failfast-v1r4
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      2276.15 (   0.00%)     3867.54 * -69.92%*
Amean     fault-both-5      4992.20 (   0.00%)     5313.20 (  -6.43%)
Amean     fault-both-7      7373.30 (   0.00%)     7039.11 (   4.53%)
Amean     fault-both-12    11911.52 (   0.00%)    11328.29 (   4.90%)
Amean     fault-both-18    17209.42 (   0.00%)    16455.34 (   4.38%)
Amean     fault-both-24    20943.71 (   0.00%)    20448.94 (   2.36%)
Amean     fault-both-30    22703.00 (   0.00%)    21655.07 (   4.62%)
Amean     fault-both-32    22461.41 (   0.00%)    21415.35 (   4.66%)

The 2-socket results are not materially different. Scan rates are
similar as expected.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index df17a710e2c7..0e27a10429e2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -885,7 +885,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 	 */
 	if (page_has_private(page) &&
 	    !try_to_release_page(page, GFP_KERNEL))
-		return -EAGAIN;
+		return mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
 
 	return migrate_page(mapping, newpage, page, mode);
 }
-- 
2.16.4
