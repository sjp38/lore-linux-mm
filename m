Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE2A8E00B4
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:21:51 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id n17so13120540pfk.23
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:21:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o11si12668575pgd.234.2018.12.11.09.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 09:21:50 -0800 (PST)
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BDD56B010
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:21:48 +0000 (UTC)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/6] mm: migration: Factor out code to compute expected number of page references
Date: Tue, 11 Dec 2018 18:21:38 +0100
Message-Id: <20181211172143.7358-2-jack@suse.cz>
In-Reply-To: <20181211172143.7358-1-jack@suse.cz>
References: <20181211172143.7358-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, mgorman@suse.de, Jan Kara <jack@suse.cz>

Factor out function to compute number of expected page references in
migrate_page_move_mapping(). Note that we move hpage_nr_pages() and
page_has_private() checks from under xas_lock_irq() however this is safe
since we hold page lock.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/migrate.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index f7e4bfdc13b7..789c7bc90a0c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -428,6 +428,22 @@ static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
 }
 #endif /* CONFIG_BLOCK */
 
+static int expected_page_refs(struct page *page)
+{
+	int expected_count = 1;
+
+	/*
+	 * Device public or private pages have an extra refcount as they are
+	 * ZONE_DEVICE pages.
+	 */
+	expected_count += is_device_private_page(page);
+	expected_count += is_device_public_page(page);
+	if (page->mapping)
+		expected_count += hpage_nr_pages(page) + page_has_private(page);
+
+	return expected_count;
+}
+
 /*
  * Replace the page in the mapping.
  *
@@ -444,14 +460,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	XA_STATE(xas, &mapping->i_pages, page_index(page));
 	struct zone *oldzone, *newzone;
 	int dirty;
-	int expected_count = 1 + extra_count;
-
-	/*
-	 * Device public or private pages have an extra refcount as they are
-	 * ZONE_DEVICE pages.
-	 */
-	expected_count += is_device_private_page(page);
-	expected_count += is_device_public_page(page);
+	int expected_count = expected_page_refs(page) + extra_count;
 
 	if (!mapping) {
 		/* Anonymous page without mapping */
@@ -471,8 +480,6 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	newzone = page_zone(newpage);
 
 	xas_lock_irq(&xas);
-
-	expected_count += hpage_nr_pages(page) + page_has_private(page);
 	if (page_count(page) != expected_count || xas_load(&xas) != page) {
 		xas_unlock_irq(&xas);
 		return -EAGAIN;
-- 
2.16.4
