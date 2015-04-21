Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id CCCDC900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 06:41:34 -0400 (EDT)
Received: by wgsk9 with SMTP id k9so208352576wgs.3
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 03:41:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lg1si2446464wjc.136.2015.04.21.03.41.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 03:41:27 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/6] mm, migrate: Drop references to successfully migrated pages at the same time
Date: Tue, 21 Apr 2015 11:41:18 +0100
Message-Id: <1429612880-21415-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1429612880-21415-1-git-send-email-mgorman@suse.de>
References: <1429612880-21415-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

After each migration attempt, putback_lru_page() is used to drop the last
reference to the page.  This is fine but it prevents the batching of TLB
flushes because the flush must happen before a free. This patch drops all
the migrated pages at once in preparation for batching the TLB flush.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 85e042686031..82c98c5aa6ed 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -906,7 +906,7 @@ out:
  */
 static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
 			unsigned long private, struct page *page, int force,
-			enum migrate_mode mode)
+			enum migrate_mode mode, struct list_head *putback_list)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -937,7 +937,7 @@ out:
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		putback_lru_page(page);
+		list_add(&page->lru, putback_list);
 	}
 
 	/*
@@ -1086,6 +1086,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 		free_page_t put_new_page, unsigned long private,
 		enum migrate_mode mode, int reason)
 {
+	LIST_HEAD(putback_list);
 	int retry = 1;
 	int nr_failed = 0;
 	int nr_succeeded = 0;
@@ -1110,7 +1111,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 						pass > 2, mode);
 			else
 				rc = unmap_and_move(get_new_page, put_new_page,
-						private, page, pass > 2, mode);
+						private, page, pass > 2, mode,
+						&putback_list);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -1135,6 +1137,12 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	}
 	rc = nr_failed + retry;
 out:
+	while (!list_empty(&putback_list)) {
+		page = list_entry(putback_list.prev, struct page, lru);
+		list_del(&page->lru);
+		putback_lru_page(page);
+	}
+
 	if (nr_succeeded)
 		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
 	if (nr_failed)
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
