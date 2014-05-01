Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BFC766B0037
	for <linux-mm@kvack.org>; Thu,  1 May 2014 17:35:45 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id g10so3649825pdj.17
        for <linux-mm@kvack.org>; Thu, 01 May 2014 14:35:45 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id rb6si21987250pab.67.2014.05.01.14.35.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 14:35:44 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so1430331pdj.24
        for <linux-mm@kvack.org>; Thu, 01 May 2014 14:35:44 -0700 (PDT)
Date: Thu, 1 May 2014 14:35:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 2/4] mm, compaction: return failed migration target pages
 back to freelist
In-Reply-To: <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1405011434420.23898@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Memory compaction works by having a "freeing scanner" scan from one end of a 
zone which isolates pages as migration targets while another "migrating scanner" 
scans from the other end of the same zone which isolates pages for migration.

When page migration fails for an isolated page, the target page is returned to 
the system rather than the freelist built by the freeing scanner.  This may 
require the freeing scanner to continue scanning memory after suitable migration 
targets have already been returned to the system needlessly.

This patch returns destination pages to the freeing scanner freelist when page 
migration fails.  This prevents unnecessary work done by the freeing scanner but 
also encourages memory to be as compacted as possible at the end of the zone.

Reported-by: Greg Thelen <gthelen@google.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -797,23 +797,32 @@ static struct page *compaction_alloc(struct page *migratepage,
 }
 
 /*
- * We cannot control nr_migratepages and nr_freepages fully when migration is
- * running as migrate_pages() has no knowledge of compact_control. When
- * migration is complete, we count the number of pages on the lists by hand.
+ * This is a migrate-callback that "frees" freepages back to the isolated
+ * freelist.  All pages on the freelist are from the same zone, so there is no
+ * special handling needed for NUMA.
+ */
+static void compaction_free(struct page *page, unsigned long data)
+{
+	struct compact_control *cc = (struct compact_control *)data;
+
+	list_add(&page->lru, &cc->freepages);
+	cc->nr_freepages++;
+}
+
+/*
+ * We cannot control nr_migratepages fully when migration is running as
+ * migrate_pages() has no knowledge of of compact_control.  When migration is
+ * complete, we count the number of pages on the list by hand.
  */
 static void update_nr_listpages(struct compact_control *cc)
 {
 	int nr_migratepages = 0;
-	int nr_freepages = 0;
 	struct page *page;
 
 	list_for_each_entry(page, &cc->migratepages, lru)
 		nr_migratepages++;
-	list_for_each_entry(page, &cc->freepages, lru)
-		nr_freepages++;
 
 	cc->nr_migratepages = nr_migratepages;
-	cc->nr_freepages = nr_freepages;
 }
 
 /* possible outcome of isolate_migratepages */
@@ -1023,8 +1032,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		}
 
 		nr_migrate = cc->nr_migratepages;
-		err = migrate_pages(&cc->migratepages, compaction_alloc, NULL,
-				(unsigned long)cc,
+		err = migrate_pages(&cc->migratepages, compaction_alloc,
+				compaction_free, (unsigned long)cc,
 				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC,
 				MR_COMPACTION);
 		update_nr_listpages(cc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
