Message-ID: <48CA611A.8060706@inria.fr>
Date: Fri, 12 Sep 2008 14:31:22 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: [PATCH] mm: make do_move_pages() complexity linear
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

Page migration is currently very slow because its overhead is quadratic
with the number of pages. This is caused by each single page migration
doing a linear lookup in the page array in new_page_node().
    
Since pages are stored in the array order in the pagelist and do_move_pages
process this list in order, new_page_node() can increase the "pm" pointer
to the page array so that the next iteration will find the next page in
0 or few lookup steps.
    
Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
Signed-off-by: Nathalie Furmento <Nathalie.Furmento@labri.fr>

--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -837,14 +837,23 @@ struct page_to_node {
 	int status;
 };
 
+/*
+ * Allocate a page on the node given as a page_to_node in private.
+ * Increase private to point to the next page_to_node so that the
+ * next iteration does not have to traverse the whole pm array.
+ */
 static struct page *new_page_node(struct page *p, unsigned long private,
 		int **result)
 {
-	struct page_to_node *pm = (struct page_to_node *)private;
+	struct page_to_node **pmptr = (struct page_to_node **)private;
+	struct page_to_node *pm = *pmptr;
 
 	while (pm->node != MAX_NUMNODES && pm->page != p)
 		pm++;
 
+	/* prepare for the next iteration */
+	*pmptr = pm + 1;
+
 	if (pm->node == MAX_NUMNODES)
 		return NULL;
 
@@ -926,10 +935,12 @@ set_status:
 		pp->status = err;
 	}
 
-	if (!list_empty(&pagelist))
+	if (!list_empty(&pagelist)) {
+		/* new_page_node() will modify tmp */
+		struct page_to_node *tmp = pm;
 		err = migrate_pages(&pagelist, new_page_node,
-				(unsigned long)pm);
-	else
+				    (unsigned long)&tmp);
+	} else
 		err = -ENOENT;
 
 	up_read(&mm->mmap_sem);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
