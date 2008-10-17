Message-ID: <48F87885.5000606@inria.fr>
Date: Fri, 17 Oct 2008 13:35:33 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: [RESEND][PATCH] mm: rework do_pages_move() to work on page_sized
 chunks
References: <48F3AD47.1050301@inria.fr> <48F3AE1D.3060208@inria.fr> <48F79B42.3070106@linux-foundation.org>
In-Reply-To: <48F79B42.3070106@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

Rework do_pages_move() to work by page-sized chunks of struct page_to_node
that are passed to do_move_page_to_node_array(). We now only have to
allocate a single page instead a possibly very large vmalloc area to store
all page_to_node entries.

As a result, new_page_node() will now have a very small lookup, hidding
much of the overall sys_move_pages() overhead.

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
Signed-off-by: Nathalie Furmento <Nathalie.Furmento@labri.fr>
---
 mm/migrate.c |   79 ++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 44 insertions(+), 35 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index dffc98b..678589c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -947,41 +947,43 @@ static int do_pages_move(struct mm_struct *mm, struct task_struct *task,
 			 const int __user *nodes,
 			 int __user *status, int flags)
 {
-	struct page_to_node *pm = NULL;
+	struct page_to_node *pm;
 	nodemask_t task_nodes;
-	int err = 0;
-	int i;
+	unsigned long chunk_nr_pages;
+	unsigned long chunk_start;
+	int err;
 
 	task_nodes = cpuset_mems_allowed(task);
 
-	/* Limit nr_pages so that the multiplication may not overflow */
-	if (nr_pages >= ULONG_MAX / sizeof(struct page_to_node) - 1) {
-		err = -E2BIG;
-		goto out;
-	}
-
-	pm = vmalloc((nr_pages + 1) * sizeof(struct page_to_node));
-	if (!pm) {
-		err = -ENOMEM;
+	err = -ENOMEM;
+	pm = (struct page_to_node *)__get_free_page(GFP_KERNEL);
+	if (!pm)
 		goto out;
-	}
-
 	/*
-	 * Get parameters from user space and initialize the pm
-	 * array. Return various errors if the user did something wrong.
+	 * Store a chunk of page_to_node array in a page,
+	 * but keep the last one as a marker
 	 */
-	for (i = 0; i < nr_pages; i++) {
-		const void __user *p;
+	chunk_nr_pages = (PAGE_SIZE / sizeof(struct page_to_node)) - 1;
 
-		err = -EFAULT;
-		if (get_user(p, pages + i))
-			goto out_pm;
+	for (chunk_start = 0;
+	     chunk_start < nr_pages;
+	     chunk_start += chunk_nr_pages) {
+		int j;
+
+		if (chunk_start + chunk_nr_pages > nr_pages)
+			chunk_nr_pages = nr_pages - chunk_start;
 
-		pm[i].addr = (unsigned long)p;
-		if (nodes) {
+		/* fill the chunk pm with addrs and nodes from user-space */
+		for (j = 0; j < chunk_nr_pages; j++) {
+			const void __user *p;
 			int node;
 
-			if (get_user(node, nodes + i))
+			err = -EFAULT;
+			if (get_user(p, pages + j + chunk_start))
+				goto out_pm;
+			pm[j].addr = (unsigned long) p;
+
+			if (get_user(node, nodes + j + chunk_start))
 				goto out_pm;
 
 			err = -ENODEV;
@@ -992,22 +994,29 @@ static int do_pages_move(struct mm_struct *mm, struct task_struct *task,
 			if (!node_isset(node, task_nodes))
 				goto out_pm;
 
-			pm[i].node = node;
-		} else
-			pm[i].node = 0;	/* anything to not match MAX_NUMNODES */
-	}
-	/* End marker */
-	pm[nr_pages].node = MAX_NUMNODES;
+			pm[j].node = node;
+		}
+
+		/* End marker for this chunk */
+		pm[chunk_nr_pages].node = MAX_NUMNODES;
+
+		/* Migrate this chunk */
+		err = do_move_page_to_node_array(mm, pm,
+						 flags & MPOL_MF_MOVE_ALL);
+		if (err < 0)
+			goto out_pm;
 
-	err = do_move_page_to_node_array(mm, pm, flags & MPOL_MF_MOVE_ALL);
-	if (err >= 0)
 		/* Return status information */
-		for (i = 0; i < nr_pages; i++)
-			if (put_user(pm[i].status, status + i))
+		for (j = 0; j < chunk_nr_pages; j++)
+			if (put_user(pm[j].status, status + j + chunk_start)) {
 				err = -EFAULT;
+				goto out_pm;
+			}
+	}
+	err = 0;
 
 out_pm:
-	vfree(pm);
+	free_page((unsigned long)pm);
 out:
 	return err;
 }
-- 
1.5.6.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
