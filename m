Date: Mon, 8 May 2006 23:51:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060509065157.24194.33125.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060509065146.24194.47401.sendpatchset@schroedinger.engr.sgi.com>
References: <20060509065146.24194.47401.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/5] page migration: Remove useless mapping checks
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Remove another check for mapping

Page migration still checked for mapping being NULL after
taking the tree_lock. However the mapping never changes for a locked page.
Remove two more checks for mapping being NULL.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-30 22:45:53.794977846 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-05-03 21:49:52.957619975 -0700
@@ -291,7 +291,7 @@
 
 	if (!mapping) {
 		/* Anonymous page */
-		if (page_count(page) != 1 || !page->mapping)
+		if (page_count(page) != 1)
 			return -EAGAIN;
 		return 0;
 	}
@@ -302,8 +302,7 @@
 						&mapping->page_tree,
 						page_index(page));
 
-	if (!page_mapping(page) ||
-			page_count(page) != 2 + !!PagePrivate(page) ||
+	if (page_count(page) != 2 + !!PagePrivate(page) ||
 			*radix_pointer != page) {
 		write_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
