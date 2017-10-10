Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F067C6B026E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:19:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a7so75279816pfj.3
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:19:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si6334197pfk.204.2017.10.10.08.19.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 08:19:50 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/7] mm: Factor out page cache page freeing into a separate function
Date: Tue, 10 Oct 2017 17:19:33 +0200
Message-Id: <20171010151937.26984-4-jack@suse.cz>
In-Reply-To: <20171010151937.26984-1-jack@suse.cz>
References: <20171010151937.26984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

Factor out page freeing from delete_from_page_cache() into a separate
function. We will need to call the same when batching pagecache deletion
operations.

invalidate_complete_page2() and replace_page_cache_page() might want to
call this function as well however they currently don't seem to handle
THPs so it's unnecessary for them to take the hit of checking whether
a page is THP or not.

Acked-by: Mel Gorman <mgorman@suse.de>
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
