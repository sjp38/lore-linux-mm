Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id E5F8A6B0036
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 20:45:30 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id l13so2453389iga.9
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:45:30 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id od6si143183igb.6.2014.04.30.17.45.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 17:45:30 -0700 (PDT)
Received: by mail-ie0-f177.google.com with SMTP id rp18so2857807iec.36
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:45:30 -0700 (PDT)
Date: Wed, 30 Apr 2014 17:45:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, compaction: return failed migration target pages
 back to freelist
In-Reply-To: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1404301744400.8415@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
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
 mm/compaction.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -797,6 +797,19 @@ static struct page *compaction_alloc(struct page *migratepage,
 }
 
 /*
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
  * We cannot control nr_migratepages and nr_freepages fully when migration is
  * running as migrate_pages() has no knowledge of compact_control. When
  * migration is complete, we count the number of pages on the lists by hand.
@@ -1023,8 +1036,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
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
