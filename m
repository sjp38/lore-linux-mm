Date: Mon, 7 Aug 2006 20:42:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.18-rc3-mm2: rcu radix tree patches break page migration
In-Reply-To: <44D7E7DF.1080106@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0608072041010.24071@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608071556530.23088@schroedinger.engr.sgi.com>
 <44D7E7DF.1080106@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: npiggin@suse.de, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Nick Piggin wrote:

> Question: can you replace the lookup_slot with a regular lookup, then
> replace the pointer switch with a radix_tree_delete + radix_tree_insert
> and see if that works?

Ahh... Okay that makes things work the right way.

Does that mean we need to get rid of radix tree replaces in 
general?

Patch:

Index: linux-2.6.18-rc3-mm2/mm/migrate.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/mm/migrate.c	2006-08-07 20:21:12.985022791 -0700
+++ linux-2.6.18-rc3-mm2/mm/migrate.c	2006-08-07 20:25:28.676221751 -0700
@@ -294,7 +294,8 @@ out:
 static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page)
 {
-	struct page **radix_pointer;
+	struct page *radix_pointer;
+	long index;
 
 	if (!mapping) {
 		/* Anonymous page */
@@ -305,12 +306,14 @@ static int migrate_page_move_mapping(str
 
 	write_lock_irq(&mapping->tree_lock);
 
-	radix_pointer = (struct page **)radix_tree_lookup_slot(
+	index = page_index(page);
+
+	radix_pointer = (struct page *)radix_tree_lookup(
 						&mapping->page_tree,
-						page_index(page));
+						index);
 
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
-			radix_tree_deref_slot(radix_pointer) != page) {
+			radix_pointer != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
@@ -326,7 +329,8 @@ static int migrate_page_move_mapping(str
 	}
 #endif
 
-	radix_tree_replace_slot(radix_pointer, newpage);
+	radix_tree_delete(&mapping->page_tree, index);
+	radix_tree_insert(&mapping->page_tree, index, newpage);
 	__put_page(page);
 	write_unlock_irq(&mapping->tree_lock);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
