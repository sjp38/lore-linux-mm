Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5B36B0277
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:07 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z5-v6so7705701pln.20
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o124-v6si9218244pga.90.2018.06.16.19.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:06 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 41/74] mm: Convert page migration to XArray
Date: Sat, 16 Jun 2018 19:00:19 -0700
Message-Id: <20180617020052.4759-42-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/migrate.c | 48 ++++++++++++++++++------------------------------
 1 file changed, 18 insertions(+), 30 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 8c0af0f7cab1..80dc5b8c9738 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -323,7 +323,7 @@ void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
 	page = migration_entry_to_page(entry);
 
 	/*
-	 * Once radix-tree replacement of page migration started, page_count
+	 * Once page cache replacement of page migration started, page_count
 	 * *must* be zero. And, we don't want to call wait_on_page_locked()
 	 * against a page without get_page().
 	 * So, we use get_page_unless_zero(), here. Even failed, page fault
@@ -438,10 +438,10 @@ int migrate_page_move_mapping(struct address_space *mapping,
 		struct buffer_head *head, enum migrate_mode mode,
 		int extra_count)
 {
+	XA_STATE(xas, &mapping->i_pages, page_index(page));
 	struct zone *oldzone, *newzone;
 	int dirty;
 	int expected_count = 1 + extra_count;
-	void **pslot;
 
 	/*
 	 * Device public or private pages have an extra refcount as they are
@@ -467,21 +467,16 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	oldzone = page_zone(page);
 	newzone = page_zone(newpage);
 
-	xa_lock_irq(&mapping->i_pages);
-
-	pslot = radix_tree_lookup_slot(&mapping->i_pages,
- 					page_index(page));
+	xas_lock_irq(&xas);
 
 	expected_count += hpage_nr_pages(page) + page_has_private(page);
-	if (page_count(page) != expected_count ||
-		radix_tree_deref_slot_protected(pslot,
-					&mapping->i_pages.xa_lock) != page) {
-		xa_unlock_irq(&mapping->i_pages);
+	if (page_count(page) != expected_count || xas_load(&xas) != page) {
+		xas_unlock_irq(&xas);
 		return -EAGAIN;
 	}
 
 	if (!page_ref_freeze(page, expected_count)) {
-		xa_unlock_irq(&mapping->i_pages);
+		xas_unlock_irq(&xas);
 		return -EAGAIN;
 	}
 
@@ -495,7 +490,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	if (mode == MIGRATE_ASYNC && head &&
 			!buffer_migrate_lock_buffers(head, mode)) {
 		page_ref_unfreeze(page, expected_count);
-		xa_unlock_irq(&mapping->i_pages);
+		xas_unlock_irq(&xas);
 		return -EAGAIN;
 	}
 
@@ -523,16 +518,13 @@ int migrate_page_move_mapping(struct address_space *mapping,
 		SetPageDirty(newpage);
 	}
 
-	radix_tree_replace_slot(&mapping->i_pages, pslot, newpage);
+	xas_store(&xas, newpage);
 	if (PageTransHuge(page)) {
 		int i;
-		int index = page_index(page);
 
 		for (i = 1; i < HPAGE_PMD_NR; i++) {
-			pslot = radix_tree_lookup_slot(&mapping->i_pages,
-						       index + i);
-			radix_tree_replace_slot(&mapping->i_pages, pslot,
-						newpage + i);
+			xas_next(&xas);
+			xas_store(&xas, newpage + i);
 		}
 	}
 
@@ -543,7 +535,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 */
 	page_ref_unfreeze(page, expected_count - hpage_nr_pages(page));
 
-	xa_unlock(&mapping->i_pages);
+	xas_unlock(&xas);
 	/* Leave irq disabled to prevent preemption while updating stats */
 
 	/*
@@ -583,22 +575,18 @@ EXPORT_SYMBOL(migrate_page_move_mapping);
 int migrate_huge_page_move_mapping(struct address_space *mapping,
 				   struct page *newpage, struct page *page)
 {
+	XA_STATE(xas, &mapping->i_pages, page_index(page));
 	int expected_count;
-	void **pslot;
-
-	xa_lock_irq(&mapping->i_pages);
-
-	pslot = radix_tree_lookup_slot(&mapping->i_pages, page_index(page));
 
+	xas_lock_irq(&xas);
 	expected_count = 2 + page_has_private(page);
-	if (page_count(page) != expected_count ||
-		radix_tree_deref_slot_protected(pslot, &mapping->i_pages.xa_lock) != page) {
-		xa_unlock_irq(&mapping->i_pages);
+	if (page_count(page) != expected_count || xas_load(&xas) != page) {
+		xas_unlock_irq(&xas);
 		return -EAGAIN;
 	}
 
 	if (!page_ref_freeze(page, expected_count)) {
-		xa_unlock_irq(&mapping->i_pages);
+		xas_unlock_irq(&xas);
 		return -EAGAIN;
 	}
 
@@ -607,11 +595,11 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
 
 	get_page(newpage);
 
-	radix_tree_replace_slot(&mapping->i_pages, pslot, newpage);
+	xas_store(&xas, newpage);
 
 	page_ref_unfreeze(page, expected_count - 1);
 
-	xa_unlock_irq(&mapping->i_pages);
+	xas_unlock_irq(&xas);
 
 	return MIGRATEPAGE_SUCCESS;
 }
-- 
2.17.1
