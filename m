Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 12E0E6B006A
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:29:07 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 06/25] Move check for disabled anti-fragmentation out of fastpath
Date: Fri, 20 Mar 2009 10:02:53 +0000
Message-Id: <1237543392-11797-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On low-memory systems, anti-fragmentation gets disabled as there is nothing
it can do and it would just incur overhead shuffling pages between lists
constantly. Currently the check is made in the free page fast path for every
page. This patch moves it to a slow path. On machines with low memory,
there will be small amount of additional overhead as pages get shuffled
between lists but it should quickly settle.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
---
 include/linux/mmzone.h |    3 ---
 mm/page_alloc.c        |    4 ++++
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1aca6ce..ca000b8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -50,9 +50,6 @@ extern int page_group_by_mobility_disabled;
 
 static inline int get_pageblock_migratetype(struct page *page)
 {
-	if (unlikely(page_group_by_mobility_disabled))
-		return MIGRATE_UNMOVABLE;
-
 	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7ba7705..d815c8f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -171,6 +171,10 @@ int page_group_by_mobility_disabled __read_mostly;
 
 static void set_pageblock_migratetype(struct page *page, int migratetype)
 {
+
+	if (unlikely(page_group_by_mobility_disabled))
+		migratetype = MIGRATE_UNMOVABLE;
+
 	set_pageblock_flags_group(page, (unsigned long)migratetype,
 					PB_migrate, PB_migrate_end);
 }
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
