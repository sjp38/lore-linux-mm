Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 23E3F6B0255
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 11:22:44 -0500 (EST)
Received: by wmww144 with SMTP id w144so111796143wmw.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 08:22:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 202si20221685wmp.104.2015.11.23.08.22.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 08:22:42 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm: fix swapped Movable and Reclaimable in /proc/pagetypeinfo
Date: Mon, 23 Nov 2015 17:22:14 +0100
Message-Id: <1448295734-14072-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Commit 016c13daa5c9 ("mm, page_alloc: use masks and shifts when converting GFP
flags to migrate types") has swapped MIGRATE_MOVABLE and MIGRATE_RECLAIMABLE
in the enum definition. However, migratetype_names wasn't updated to reflect
that. As a result, the file /proc/pagetypeinfo shows the counts for Movable as
Reclaimable and vice versa.

Additionally, commit 0aaa29a56e4f ("mm, page_alloc: reserve pageblocks for
high-order atomic allocations on demand") introduced MIGRATE_HIGHATOMIC, but
did not add a letter to distinguish it into show_migration_types(), so it
doesn't appear in the listing of free areas during page alloc failures or oom
kills.

This patch fixes both problems. The atomic reserves will show with a letter
'H' in the free areas listings.

Fixes: 016c13daa5c9e4827eca703e2f0621c131f2cca3
Fixes: 0aaa29a56e4fb0fc9e24edb649e2733a672ca099
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 3 ++-
 mm/vmstat.c     | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 17a3c66..165980d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3647,8 +3647,9 @@ static void show_migration_types(unsigned char type)
 {
 	static const char types[MIGRATE_TYPES] = {
 		[MIGRATE_UNMOVABLE]	= 'U',
-		[MIGRATE_RECLAIMABLE]	= 'E',
 		[MIGRATE_MOVABLE]	= 'M',
+		[MIGRATE_RECLAIMABLE]	= 'E',
+		[MIGRATE_HIGHATOMIC]	= 'H'
 #ifdef CONFIG_CMA
 		[MIGRATE_CMA]		= 'C',
 #endif
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 879a2be..2ec3434 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -921,8 +921,8 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 #ifdef CONFIG_PROC_FS
 static char * const migratetype_names[MIGRATE_TYPES] = {
 	"Unmovable",
-	"Reclaimable",
 	"Movable",
+	"Reclaimable",
 	"HighAtomic",
 #ifdef CONFIG_CMA
 	"CMA",
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
