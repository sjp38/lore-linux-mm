Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 237F16B006E
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 13:15:34 -0400 (EDT)
Received: by paceu11 with SMTP id eu11so60177760pac.1
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 10:15:33 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id ro12si10791547pab.108.2015.03.09.10.15.32
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 10:15:33 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V2] Allow compaction of unevictable pages
Date: Mon,  9 Mar 2015 13:12:36 -0400
Message-Id: <1425921156-16923-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, pages which are marked as unevictable are protected from
compaction, but not from other types of migration.  The mlock
desctription does not promise that all page faults will be avoided, only
major ones so this protection is not necessary.  This extra protection
can cause problems for applications that are using mlock to avoid
swapping pages out, but require order > 0 allocations to continue to
succeed in a fragmented environment.  This patch removes the
ISOLATE_UNEVICTABLE mode and the check for it in __isolate_lru_page().

To illustrate this problem I wrote a quick test program that mmaps a
large number of 1MB files filled with random data.  These maps are
created locked and read only.  Then every other mmap is unmapped and I
attempt to allocate huge pages to the static huge page pool.  Without
this patch I am unable to allocate any huge pages after  fragmenting
memory.  With it, I can allocate almost all the space freed by unmapping
as huge pages.

Signed-off-by: Eric B Munson <emunson@akamai.com>

Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

---
 include/linux/mmzone.h |    2 --
 mm/compaction.c        |    3 +--
 mm/vmscan.c            |    4 ----
 3 files changed, 1 insertion(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f279d9c..599fb01 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -232,8 +232,6 @@ struct lruvec {
 #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x2)
 /* Isolate for asynchronous migration */
 #define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x4)
-/* Isolate unevictable pages */
-#define ISOLATE_UNEVICTABLE	((__force isolate_mode_t)0x8)
 
 /* LRU Isolation modes. */
 typedef unsigned __bitwise__ isolate_mode_t;
diff --git a/mm/compaction.c b/mm/compaction.c
index 8c0d945..4a8ea87 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -872,8 +872,7 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
 			continue;
 
-		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
-							ISOLATE_UNEVICTABLE);
+		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn, 0);
 
 		/*
 		 * In case of fatal failure, release everything that might
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd..3b2a444 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1234,10 +1234,6 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 	if (!PageLRU(page))
 		return ret;
 
-	/* Compaction should not handle unevictable pages but CMA can do so */
-	if (PageUnevictable(page) && !(mode & ISOLATE_UNEVICTABLE))
-		return ret;
-
 	ret = -EBUSY;
 
 	/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
