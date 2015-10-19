Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id D5F5082F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 01:01:39 -0400 (EDT)
Received: by ioll68 with SMTP id l68so17703467iol.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:01:39 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id v89si24715943iov.45.2015.10.18.22.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 22:01:39 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so82890626pac.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:01:38 -0700 (PDT)
Date: Sun, 18 Oct 2015 22:01:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 8/12] mm: page migration remove_migration_ptes at lock+unlock
 level
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182159180.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

Clean up page migration a little more by calling remove_migration_ptes()
from the same level, on success or on failure, from __unmap_and_move()
or from unmap_and_move_huge_page().

Don't reset page->mapping of a PageAnon old page in move_to_new_page(),
leave that to when the page is freed.  Except for here in page migration,
it has been an invariant that a PageAnon (bit set in page->mapping) page
stays PageAnon until it is freed, and I think we're safer to keep to that.

And with the above rearrangement, it's necessary because zap_pte_range()
wants to identify whether a migration entry represents a file or an anon
page, to update the appropriate rss stats without waiting on it.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/migrate.c |   34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

--- migrat.orig/mm/migrate.c	2015-10-18 17:53:22.487335021 -0700
+++ migrat/mm/migrate.c	2015-10-18 17:53:24.858337721 -0700
@@ -722,7 +722,7 @@ static int fallback_migrate_page(struct
  *  MIGRATEPAGE_SUCCESS - success
  */
 static int move_to_new_page(struct page *newpage, struct page *page,
-				int page_was_mapped, enum migrate_mode mode)
+				enum migrate_mode mode)
 {
 	struct address_space *mapping;
 	int rc;
@@ -755,19 +755,21 @@ static int move_to_new_page(struct page
 		 * space which also has its own migratepage callback. This
 		 * is the most common path for page migration.
 		 */
-		rc = mapping->a_ops->migratepage(mapping,
-						newpage, page, mode);
+		rc = mapping->a_ops->migratepage(mapping, newpage, page, mode);
 	else
 		rc = fallback_migrate_page(mapping, newpage, page, mode);
 
-	if (rc != MIGRATEPAGE_SUCCESS) {
+	/*
+	 * When successful, old pagecache page->mapping must be cleared before
+	 * page is freed; but stats require that PageAnon be left as PageAnon.
+	 */
+	if (rc == MIGRATEPAGE_SUCCESS) {
+		set_page_memcg(page, NULL);
+		if (!PageAnon(page))
+			page->mapping = NULL;
+	} else {
 		set_page_memcg(newpage, NULL);
 		newpage->mapping = NULL;
-	} else {
-		set_page_memcg(page, NULL);
-		if (page_was_mapped)
-			remove_migration_ptes(page, newpage);
-		page->mapping = NULL;
 	}
 	return rc;
 }
@@ -902,10 +904,11 @@ static int __unmap_and_move(struct page
 	}
 
 	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page, page_was_mapped, mode);
+		rc = move_to_new_page(newpage, page, mode);
 
-	if (rc && page_was_mapped)
-		remove_migration_ptes(page, page);
+	if (page_was_mapped)
+		remove_migration_ptes(page,
+			rc == MIGRATEPAGE_SUCCESS ? newpage : page);
 
 out_unlock_both:
 	unlock_page(newpage);
@@ -1066,10 +1069,11 @@ static int unmap_and_move_huge_page(new_
 	}
 
 	if (!page_mapped(hpage))
-		rc = move_to_new_page(new_hpage, hpage, page_was_mapped, mode);
+		rc = move_to_new_page(new_hpage, hpage, mode);
 
-	if (rc != MIGRATEPAGE_SUCCESS && page_was_mapped)
-		remove_migration_ptes(hpage, hpage);
+	if (page_was_mapped)
+		remove_migration_ptes(hpage,
+			rc == MIGRATEPAGE_SUCCESS ? new_hpage : hpage);
 
 	unlock_page(new_hpage);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
