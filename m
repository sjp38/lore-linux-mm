Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D322F6B005C
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 21:46:06 -0400 (EDT)
Subject: [PATCH 5/5]memhp: migrate swap cache page
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 09:47:31 +0800
Message-Id: <1246240051.26292.21.camel@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux-foundation.org, "yakui.zhao" <yakui.zhao@intel.com>
List-ID: <linux-mm.kvack.org>

In test, some pages in swap-cache can't be migrated, as they aren't rmap.

unmap_and_move() ignores swap-cache page which is just read in and hasn't
rmap (see the comments in the code), but swap_aops provides .migratepage.
Better to migrate such pages instead of ignore them.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/migrate.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: linux/mm/migrate.c
===================================================================
--- linux.orig/mm/migrate.c	2009-06-26 09:41:05.000000000 +0800
+++ linux/mm/migrate.c	2009-06-26 10:00:49.000000000 +0800
@@ -147,7 +147,7 @@ out:
 static void remove_file_migration_ptes(struct page *old, struct page *new)
 {
 	struct vm_area_struct *vma;
-	struct address_space *mapping = page_mapping(new);
+	struct address_space *mapping = new->mapping;
 	struct prio_tree_iter iter;
 	pgoff_t pgoff = new->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 
@@ -664,13 +664,15 @@ static int unmap_and_move(new_page_t get
 			 *    needs to be effective.
 			 */
 			try_to_free_buffers(page);
+			goto rcu_unlock;
 		}
-		goto rcu_unlock;
+		goto skip_unmap;
 	}
 
 	/* Establish migration ptes or remove ptes */
 	try_to_unmap(page, 1);
 
+skip_unmap:
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
