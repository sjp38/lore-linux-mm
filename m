Message-ID: <48F3ADD4.60307@inria.fr>
Date: Mon, 13 Oct 2008 22:21:40 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: [PATCH 2/5] mm: don't vmalloc a huge page_to_node array for do_pages_stat()
References: <48F3AD47.1050301@inria.fr>
In-Reply-To: <48F3AD47.1050301@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

do_pages_stat() does not need any page_to_node entry for real.
Just pass the pointers to the user-space page address array and to
the user-space status array, and have do_pages_stat() traverse the
former and fill the latter directly.

Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
---
 mm/migrate.c |   40 +++++++++++++++++++++++++---------------
 1 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index e505b2f..e92e4f1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -936,25 +936,33 @@ set_status:
 }
 
 /*
- * Determine the nodes of a list of pages. The addr in the pm array
- * must have been set to the virtual address of which we want to determine
- * the node number.
+ * Determine the nodes of an array of pages and store it in an array of status.
  */
-static int do_pages_stat(struct mm_struct *mm, struct page_to_node *pm)
+static int do_pages_stat(struct mm_struct *mm, unsigned long nr_pages,
+			 const void __user * __user *pages,
+			 int __user *status)
 {
+	unsigned long i;
+	int err;
+
 	down_read(&mm->mmap_sem);
 
-	for ( ; pm->node != MAX_NUMNODES; pm++) {
+	for (i = 0; i < nr_pages; i++) {
+		const void __user *p;
+		unsigned long addr;
 		struct vm_area_struct *vma;
 		struct page *page;
-		int err;
 
 		err = -EFAULT;
-		vma = find_vma(mm, pm->addr);
+		if (get_user(p, pages+i))
+			goto out;
+		addr = (unsigned long) p;
+
+		vma = find_vma(mm, addr);
 		if (!vma)
 			goto set_status;
 
-		page = follow_page(vma, pm->addr, 0);
+		page = follow_page(vma, addr, 0);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
@@ -967,11 +975,13 @@ static int do_pages_stat(struct mm_struct *mm, struct page_to_node *pm)
 
 		err = page_to_nid(page);
 set_status:
-		pm->status = err;
+		put_user(err, status+i);
 	}
+	err = 0;
 
+out:
 	up_read(&mm->mmap_sem);
-	return 0;
+	return err;
 }
 
 /*
@@ -1027,6 +1037,10 @@ asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
  	if (err)
  		goto out2;
 
+	if (!nodes) {
+		err = do_pages_stat(mm, nr_pages, pages, status);
+		goto out2;
+	}
 
 	task_nodes = cpuset_mems_allowed(task);
 
@@ -1075,11 +1089,7 @@ asmlinkage long sys_move_pages(pid_t pid, unsigned long nr_pages,
 	/* End marker */
 	pm[nr_pages].node = MAX_NUMNODES;
 
-	if (nodes)
-		err = do_move_pages(mm, pm, flags & MPOL_MF_MOVE_ALL);
-	else
-		err = do_pages_stat(mm, pm);
-
+	err = do_move_pages(mm, pm, flags & MPOL_MF_MOVE_ALL);
 	if (err >= 0)
 		/* Return status information */
 		for (i = 0; i < nr_pages; i++)
-- 
1.5.6.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
