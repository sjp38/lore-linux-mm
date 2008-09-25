From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: [RESEND][PATCH] mm: make do_move_pages() complexity linear
Date: Thu, 25 Sep 2008 15:00:04 +0200
Message-ID: <48DB8B54.4050502@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755142AbYIYM7D@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-Id: linux-mm.kvack.org

Page migration is currently very slow because its overhead is quadratic
with the number of pages. This is caused by each single page migration
doing a linear lookup in the page array in new_page_node().

Since pages are stored in the array order in the pagelist and do_move_pages
process this list in order, new_page_node() can cache the last "pm" pointer
to the page array. This way, the next iteration will find the next page in
usually 1 while loop (or 0 if called multiple times on the same page, or
more if some pages are missing in the list).

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
Signed-off-by: Nathalie Furmento <Nathalie.Furmento@labri.fr>
---
 mm/migrate.c |   25 +++++++++++++++++++++----
 1 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 2a80136..349b205 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -837,14 +837,29 @@ struct page_to_node {
 	int status;
 };
 
+/*
+ * Allocate a page on the node given as a page_to_node in private.
+ *
+ * Cache the _last used_ pm in private so that the next call may find the
+ * target pm in very few while loops (usually 1) instead of scanning the
+ * whole pm array.
+ * We cannot cache the _next_ pm in private (to get 0 while loop in the
+ * regular case) because it would break the case where new_page_node()
+ * is called multiple times on the same page (when migrate_pages() tries
+ * unmap_and_move() multiple times).
+ */
 static struct page *new_page_node(struct page *p, unsigned long private,
 		int **result)
 {
-	struct page_to_node *pm = (struct page_to_node *)private;
+	struct page_to_node **pmptr = (struct page_to_node **)private;
+	struct page_to_node *pm = *pmptr;
 
 	while (pm->node != MAX_NUMNODES && pm->page != p)
 		pm++;
 
+	/* save the current pm to reduce the while loop in the next call */
+	*pmptr = pm;
+
 	if (pm->node == MAX_NUMNODES)
 		return NULL;
 
@@ -926,10 +941,12 @@ set_status:
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
1.5.6.5
