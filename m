Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BF15F6B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 13:41:59 -0500 (EST)
Received: by paceu11 with SMTP id eu11so39610019pac.1
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 10:41:59 -0800 (PST)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id xm5si15999176pbc.140.2015.03.06.10.41.58
        for <linux-mm@kvack.org>;
        Fri, 06 Mar 2015 10:41:58 -0800 (PST)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH] Allow compaction of unevictable pages
Date: Fri,  6 Mar 2015 13:41:27 -0500
Message-Id: <1425667287-30841-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, pages which are marked as unevictable are protected from
compaction, but not from other types of migration.  The mlock
desctription does not promise that all page faults will be avoided, only
major ones so this protection is not necessary.  This extra protection
can cause problems for applications that are using mlock to avoid
swapping pages out, but require order > 0 allocations to continue to
succeed in a fragmented environment.  This patch changes the
isolate_mode used by the compaction code to allow compaction of
unevictable pages.

To illustrate this problem I wrote a quick test program that mmaps a
large number of 1MB files filled with random data.  These maps are
created locked and read only.  Then, every other mmap is unmapped and I
attempt to allocate huge pages to the static huge page pool.  Without
this patch I am unable to allocate any huge pages after fragmenting
memory.  With it, I can allocate almost all the space freed by unmapping
as huge pages.

Signed-off-by: Eric B Munson <emunson@akamai.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/compaction.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8c0d945..33c81e1 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1056,7 +1056,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 {
 	unsigned long low_pfn, end_pfn;
 	struct page *page;
-	const isolate_mode_t isolate_mode =
+	const isolate_mode_t isolate_mode = ISOLATE_UNEVICTABLE |
 		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
 
 	/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
