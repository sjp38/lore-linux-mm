Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C36986B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 22:15:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f63so234075pfc.23
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 19:15:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g12si5796566pla.125.2017.03.28.19.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 19:15:04 -0700 (PDT)
Received: from willy by bombadil.infradead.org with local (Exim 4.87 #1 (Red Hat Linux))
	id 1ct38Z-0007FK-N9
	for linux-mm@kvack.org; Wed, 29 Mar 2017 02:15:03 +0000
Date: Tue, 28 Mar 2017 19:15:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Consolidate calls to unmap_mapping_range in collapse_shmem
Message-ID: <20170329021503.GA7760@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Is there a reason we call unmap_mapping_range() for a single page at a
time instead of the entire hugepage?  This is surely more efficient ...
but does it do something like increase the refcount on the page?

I suppose we might be able to skip all the calls to unmap_mapping_range()
if none of the pages are mapped, but surely anonymous pages are usually
mapped?

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 34bce5c308e3..2c686ba6a32b 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1396,17 +1396,11 @@ static void collapse_shmem(struct mm_struct *mm,
 			goto out_isolate_failed;
 		}
 
-		if (page_mapped(page))
-			unmap_mapping_range(mapping, index << PAGE_SHIFT,
-					PAGE_SIZE, 0);
-
 		spin_lock_irq(&mapping->tree_lock);
 
 		slot = radix_tree_lookup_slot(&mapping->page_tree, index);
 		VM_BUG_ON_PAGE(page != radix_tree_deref_slot_protected(slot,
 					&mapping->tree_lock), page);
-		VM_BUG_ON_PAGE(page_mapped(page), page);
-
 		/*
 		 * The page is expected to have page_count() == 3:
 		 *  - we hold a pin on it;
@@ -1472,6 +1466,9 @@ static void collapse_shmem(struct mm_struct *mm,
 		unsigned long flags;
 		struct zone *zone = page_zone(new_page);
 
+		unmap_mapping_range(mapping, start << PAGE_SHIFT,
+					HPAGE_PMD_SIZE, 0);
+
 		/*
 		 * Replacing old pages with new one has succeed, now we need to
 		 * copy the content and free old pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
