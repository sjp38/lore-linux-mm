Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF5938E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 06:15:09 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e12so2816961edd.16
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 03:15:09 -0800 (PST)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id g6si324256eds.222.2019.01.09.03.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 03:15:08 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id EF5CBB8A07
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 11:15:07 +0000 (GMT)
Date: Wed, 9 Jan 2019 11:15:06 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm, compaction: Finish pageblock scanning on contention -fix
Message-ID: <20190109111506.GV31517@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, YueHaibing <yuehaibing@huawei.com>, Linux-MM <linux-mm@kvack.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

From: YueHaibing <yuehaibing@huawei.com>

Fixes gcc '-Wunused-but-set-variable' warning:

mm/compaction.c: In function 'compact_zone':
mm/compaction.c:2063:22: warning:
 variable 'c' set but not used [-Wunused-but-set-variable]
mm/compaction.c:2063:19: warning:
 variable 'b' set but not used [-Wunused-but-set-variable]
mm/compaction.c:2063:16: warning:
 variable 'a' set but not used [-Wunused-but-set-variable]

This never used since 94d5992baaa5 ("mm, compaction: finish
pageblock scanning on contention"). This is a fix to the mmotm patch
broken-out/mm-compaction-finish-pageblock-scanning-on-contention.patch

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 51da4691092b..ca8da58ce1cd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1963,7 +1963,6 @@ static enum compact_result compact_zone(struct compact_control *cc)
 	unsigned long end_pfn = zone_end_pfn(cc->zone);
 	unsigned long last_migrated_pfn;
 	const bool sync = cc->mode != MIGRATE_ASYNC;
-	unsigned long a, b, c;
 
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
@@ -2009,10 +2008,6 @@ static enum compact_result compact_zone(struct compact_control *cc)
 			cc->whole_zone = true;
 	}
 
-	a = cc->migrate_pfn;
-	b = cc->free_pfn;
-	c = (cc->free_pfn - cc->migrate_pfn) / pageblock_nr_pages;
-
 	last_migrated_pfn = 0;
 
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
