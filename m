Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E6DF56B025F
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:36:03 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so26989636lfa.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:36:03 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id j9si1982357wjb.260.2016.07.08.02.36.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 02:36:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 56A81F4049
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 09:36:02 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 04/34] mm, mmzone: clarify the usage of zone padding
Date: Fri,  8 Jul 2016 10:34:40 +0100
Message-Id: <1467970510-21195-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Zone padding separates write-intensive fields used by page allocation,
compaction and vmstats but the comments are a little misleading and
need clarification.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d4f5cac0a8c3..edafdaf62e90 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -477,20 +477,21 @@ struct zone {
 	unsigned long		wait_table_hash_nr_entries;
 	unsigned long		wait_table_bits;
 
+	/* Write-intensive fields used from the page allocator */
 	ZONE_PADDING(_pad1_)
+
 	/* free areas of different sizes */
 	struct free_area	free_area[MAX_ORDER];
 
 	/* zone flags, see below */
 	unsigned long		flags;
 
-	/* Write-intensive fields used from the page allocator */
+	/* Primarily protects free_area */
 	spinlock_t		lock;
 
+	/* Write-intensive fields used by compaction and vmstats. */
 	ZONE_PADDING(_pad2_)
 
-	/* Write-intensive fields used by page reclaim */
-
 	/*
 	 * When free pages are below this point, additional steps are taken
 	 * when reading the number of free pages to avoid per-cpu counter
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
