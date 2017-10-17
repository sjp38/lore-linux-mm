Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A56E16B0261
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 12:21:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id t69so1095811wmt.7
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:21:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si8458659wrc.11.2017.10.17.09.21.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 09:21:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/7] mm: Factor out page cache page freeing into a separate function
Date: Tue, 17 Oct 2017 18:21:16 +0200
Message-Id: <20171017162120.30990-4-jack@suse.cz>
In-Reply-To: <20171017162120.30990-1-jack@suse.cz>
References: <20171017162120.30990-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Factor out page freeing from delete_from_page_cache() into a separate
function. We will need to call the same when batching pagecache deletion
operations.

invalidate_complete_page2() and replace_page_cache_page() might want to
call this function as well however they currently don't seem to handle
THPs so it's unnecessary for them to take the hit of checking whether
a page is THP or not.

Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/filemap.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index cf74d0dacc6a..cdb44dacabd2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -254,6 +254,23 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 		account_page_cleaned(page, mapping, inode_to_wb(mapping->host));
 }
 
+static void page_cache_free_page(struct address_space *mapping,
+				struct page *page)
+{
+	void (*freepage)(struct page *);
+
+	freepage = mapping->a_ops->freepage;
+	if (freepage)
+		freepage(page);
+
+	if (PageTransHuge(page) && !PageHuge(page)) {
+		page_ref_sub(page, HPAGE_PMD_NR);
+		VM_BUG_ON_PAGE(page_count(page) <= 0, page);
+	} else {
+		put_page(page);
+	}
+}
+
 /**
  * delete_from_page_cache - delete page from page cache
  * @page: the page which the kernel is trying to remove from page cache
@@ -266,25 +283,13 @@ void delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 	unsigned long flags;
-	void (*freepage)(struct page *);
 
 	BUG_ON(!PageLocked(page));
-
-	freepage = mapping->a_ops->freepage;
-
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	__delete_from_page_cache(page, NULL);
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
 
-	if (freepage)
-		freepage(page);
-
-	if (PageTransHuge(page) && !PageHuge(page)) {
-		page_ref_sub(page, HPAGE_PMD_NR);
-		VM_BUG_ON_PAGE(page_count(page) <= 0, page);
-	} else {
-		put_page(page);
-	}
+	page_cache_free_page(mapping, page);
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
