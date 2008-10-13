Message-ID: <48F3ADF5.1060609@inria.fr>
Date: Mon, 13 Oct 2008 22:22:13 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: [PATCH 3/5] mm: extract do_pages_move() out of sys_move_pages()
References: <48F3AD47.1050301@inria.fr>
In-Reply-To: <48F3AD47.1050301@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

To prepare the chunking, move the sys_move_pages() code that
is used when nodes!=NULL into do_pages_move().
And rename do_move_pages() into do_move_page_to_node_array().

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
---
 mm/migrate.c |  152 +++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 86 insertions(+), 66 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index e92e4f1..dffc98b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -858,9 +858,11 @@ static struct page *new_page_node(struct page *p, unsigned long private,
  * Move a set of pages as indicated in the pm array. The addr
  * field must be set to the virtual address of the page to be moved
  * and the node number must contain a valid target node.
+ * The pm array ends with node = MAX_NUMNODES.
  */
-static int do_move_pages(struct mm_struct *mm, struct page_to_node *pm,
-				int migrate_all)
+static int do_move_page_to_node_array(struct mm_struct *mm,
+				      struct page_to_node *pm,
+				      int migrate_all)
 {
 	int err;
 	struct page_to_node *pp;
@@ -936,6 +938,81 @@ set_status:
 }
 
 /*
+ * Migrate an array of page address onto an array of nodes and fill
+ * the corresponding array of status.
+ */
+static int do_pages_move(struct mm_struct *mm, struct task_struct *task,
+			 unsigned long nr_pages,
+			 const void __user * __user *pages,
+			 const int __user *nodes,
+			 int __user *status, int flags)
+{
+	struct page_to_node *pm = NULL;
+	nodemask_t task_nodes;
+	int err = 0;
+	int i;
+
+	task_nodes = cpuset_mems_allowed(task);
+
+	/* Limit nr_pages so that the multiplication may not overflow */
+	if (nr_pages >= ULONG_MAX / sizeof(struct page_to_node) - 1) {
+		err = -E2BIG;
+		goto out;
+	}
+
+	pm = vmalloc((nr_pages + 1) * sizeof(struct page_to_node));
+	if (!pm) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	/*
+	 * Get parameters from user space and initialize the pm
+	 * array. Return various errors if the user did something wrong.
+	 */
+	for (i = 0; i < nr_pages; i++) {
+		const void __user *p;
+
+		err = -EFAULT;
+		if (get_user(p, pages + i))
+			goto out_pm;
+
+		pm[i].addr = (unsigned long)p;
+		if (nodes) {
+			int node;
+
+			if (get_user(node, nodes + i))
+				goto out_pm;
+
+			err = -ENODEV;
+			if (!node_state(node, N_HIGH_MEMORY))
+				goto out_pm;
+
+			err = -EACCES;
+			if (!node_isset(node, task_nodes))
+				goto out_pm;
+
+			pm[i].node = node;
+		} else
+			pm[i].node = 0;	/* anything to not match MAX_NUMNODES */
+	}
+	/* End marker */
+	pm[nr_pages].node = MAX_NUMNODES;
+
+	err = do_move_page_to_node_array(mm, pm, flags & MPOL_MF_MOVE_ALL);
+	if (err >= 0)
+		/* Return status information */
+		for (i = 0; i < nr_pages; i++)
+			if (put_user(pm[i].status, status + i))
+				err = -EFAULT;
+
+out_pm:
+	vfree(pm);
+out:
+	return err;
+}
+
+/*
  * Determine the nodes of an array of pages and store it in an array of status.
  */
 static int do_pages_stat(struct mm_struct *mm, unsigned long nr_pages,
@@ -993,12 +1070,9 @@ asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
 			const int __user *nodes,
 			int __user *status, int flags)
 {
-	int err = 0;
-	int i;
 	struct task_struct *task;
-	nodemask_t task_nodes;
 	struct mm_struct *mm;
-	struct page_to_node *pm = NULL;
+	int err;
 
 	/* Check flags */
 	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
@@ -1030,75 +1104,21 @@ asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
 	    (current->uid != task->suid) && (current->uid != task->uid) &&
 	    !capable(CAP_SYS_NICE)) {
 		err = -EPERM;
-		goto out2;
+		goto out;
 	}
 
  	err = security_task_movememory(task);
  	if (err)
- 		goto out2;
+		goto out;
 
-	if (!nodes) {
+	if (nodes) {
+		err = do_pages_move(mm, task, nr_pages, pages, nodes, status,
+				    flags);
+	} else {
 		err = do_pages_stat(mm, nr_pages, pages, status);
-		goto out2;
-	}
-
-	task_nodes = cpuset_mems_allowed(task);
-
-	/* Limit nr_pages so that the multiplication may not overflow */
-	if (nr_pages >= ULONG_MAX / sizeof(struct page_to_node) - 1) {
-		err = -E2BIG;
-		goto out2;
 	}
 
-	pm = vmalloc((nr_pages + 1) * sizeof(struct page_to_node));
-	if (!pm) {
-		err = -ENOMEM;
-		goto out2;
-	}
-
-	/*
-	 * Get parameters from user space and initialize the pm
-	 * array. Return various errors if the user did something wrong.
-	 */
-	for (i = 0; i < nr_pages; i++) {
-		const void __user *p;
-
-		err = -EFAULT;
-		if (get_user(p, pages + i))
-			goto out;
-
-		pm[i].addr = (unsigned long)p;
-		if (nodes) {
-			int node;
-
-			if (get_user(node, nodes + i))
-				goto out;
-
-			err = -ENODEV;
-			if (!node_state(node, N_HIGH_MEMORY))
-				goto out;
-
-			err = -EACCES;
-			if (!node_isset(node, task_nodes))
-				goto out;
-
-			pm[i].node = node;
-		} else
-			pm[i].node = 0;	/* anything to not match MAX_NUMNODES */
-	}
-	/* End marker */
-	pm[nr_pages].node = MAX_NUMNODES;
-
-	err = do_move_pages(mm, pm, flags & MPOL_MF_MOVE_ALL);
-	if (err >= 0)
-		/* Return status information */
-		for (i = 0; i < nr_pages; i++)
-			if (put_user(pm[i].status, status + i))
-				err = -EFAULT;
-
 out:
-	vfree(pm);
-out2:
 	mmput(mm);
 	return err;
 }
-- 
1.5.6.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
