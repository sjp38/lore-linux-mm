Message-ID: <48EDF9DA.7000508@inria.fr>
Date: Thu, 09 Oct 2008 14:32:26 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: [PATCH] mm: use a radix-tree to make do_move_pages() complexity linear
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

Add a radix-tree in do_move_pages() to associate each page with
the struct page_to_node that describes its migration.
new_page_node() can now easily find out the page_to_node of the
given page instead of traversing the whole page_to_node array.
So the overall complexity is linear instead of quadratic.

We still need the page_to_node array since it is allocated by the
caller (sys_move_page()) and used by do_pages_stat() when no target
nodes are given by the application. And we need room to store all
these page_to_node entries for do_move_pages() as well anyway.

If a page is given twice by the application, the old code would
return -EBUSY (failure from the second isolate_lru_page()). Now,
radix_tree_insert() will return -EEXIST, and we convert it back
to -EBUSY to keep the user-space ABI.

The radix-tree is emptied at the end of do_move_pages() since
new_page_node() doesn't know when an entry is used for the last
time (unmap_and_move() could try another pass later).
Marking pp->page as ZERO_PAGE(0) was actually never used. We now
set it to NULL when pp is not in the radix-tree. It is faster
than doing a loop of radix_tree_lookup_gang()+delete().

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
Signed-off-by: Nathalie Furmento <Nathalie.Furmento@labri.fr>

--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -31,6 +31,7 @@
 #include <linux/security.h>
 #include <linux/memcontrol.h>
 #include <linux/syscalls.h>
+#include <linux/radix-tree.h>
 
 #include "internal.h"
 
@@ -840,12 +841,10 @@ struct page_to_node {
 static struct page *new_page_node(struct page *p, unsigned long private,
 		int **result)
 {
-	struct page_to_node *pm = (struct page_to_node *)private;
+	struct radix_tree_root *root = (struct radix_tree_root *) private;
+	struct page_to_node *pm = (struct page_to_node *) radix_tree_lookup(root, (unsigned long) p);
 
-	while (pm->node != MAX_NUMNODES && pm->page != p)
-		pm++;
-
-	if (pm->node == MAX_NUMNODES)
+	if (!pm)
 		return NULL;
 
 	*result = &pm->status;
@@ -865,6 +864,7 @@ static int do_move_pages(struct mm_struct *mm, struct page_to_node *pm,
 	int err;
 	struct page_to_node *pp;
 	LIST_HEAD(pagelist);
+	RADIX_TREE(pmroot, GFP_KERNEL);
 
 	down_read(&mm->mmap_sem);
 
@@ -876,11 +876,8 @@ static int do_move_pages(struct mm_struct *mm, struct page_to_node *pm,
 		struct vm_area_struct *vma;
 		struct page *page;
 
-		/*
-		 * A valid page pointer that will not match any of the
-		 * pages that will be moved.
-		 */
-		pp->page = ZERO_PAGE(0);
+		/* set to NULL as long as pp is not in the radix-tree */
+		pp->page = NULL;
 
 		err = -EFAULT;
 		vma = find_vma(mm, pp->addr);
@@ -900,9 +897,7 @@ static int do_move_pages(struct mm_struct *mm, struct page_to_node *pm,
 		if (PageReserved(page))		/* Check for zero page */
 			goto put_and_set;
 
-		pp->page = page;
 		err = page_to_nid(page);
-
 		if (err == pp->node)
 			/*
 			 * Node already in the right place
@@ -914,6 +909,23 @@ static int do_move_pages(struct mm_struct *mm, struct page_to_node *pm,
 				!migrate_all)
 			goto put_and_set;
 
+		/*
+		 * Insert pp in the radix-tree so that new_page_node() can find it
+		 * while only knowing the page.
+		 * There cannot be any duplicate since isolate_lru_page() would fail
+		 * below anyway.
+		 */
+		err = radix_tree_insert(&pmroot, (unsigned long) page, pp);
+		if (err < 0) {
+			if (err == -EEXIST)
+				/* the page cannot be migrated twice */
+				err = -EBUSY;
+			goto put_and_set;
+		}
+
+		/* set pp->page for real now that pp is in the radix-tree */
+		pp->page = page;
+
 		err = isolate_lru_page(page, &pagelist);
 put_and_set:
 		/*
@@ -927,12 +939,17 @@ set_status:
 	}
 
 	if (!list_empty(&pagelist))
-		err = migrate_pages(&pagelist, new_page_node,
-				(unsigned long)pm);
+		err = migrate_pages(&pagelist, new_page_node, (unsigned long) &pmroot);
 	else
 		err = -ENOENT;
 
 	up_read(&mm->mmap_sem);
+
+	/* empty the radix-tree now that new_page_node() will not be called anymore */
+	for(pp = pm; pp->node != MAX_NUMNODES; pp++)
+		if (pp->page)
+			radix_tree_delete(&pmroot, (unsigned long) pp->page);
+
 	return err;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
