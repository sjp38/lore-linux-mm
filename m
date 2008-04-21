Date: Mon, 21 Apr 2008 19:36:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC] Reserve huge pages for reliable MAP_PRIVATE hugetlbfs mappings
Message-ID: <20080421183621.GA13100@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com, agl@us.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

MAP_SHARED mappings on hugetlbfs reserve huge pages at mmap() time. This is
so that all future faults will be guaranteed to succeed. Applications are not
expected to use mlock() as this can result in poor NUMA placement.

MAP_PRIVATE mappings do not reserve pages. This can result in an application
being SIGKILLed later if a large page is not available at fault time. This
makes huge pages usage very ill-advised in some cases as the unexpected
application failure is intolerable. Forcing potential poor placement with
mlock() is not a great solution either.

This patch reserves huge pages at mmap() time for MAP_PRIVATE mappings similar
to what happens for MAP_SHARED mappings. Once mmap() succeeds, the application
developer knows that future faults will also succeed. However, there is no
guarantee that children of the process will be able to write-fault the same
mapping. The assumption is being made that the majority of applications that
fork() either use MAP_SHARED as an IPC mechanism or are calling exec().

Opinions?

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 fs/hugetlbfs/inode.c    |    8 -
 include/linux/hugetlb.h |    3 
 mm/hugetlb.c            |  212 ++++++++++++++++++++++++++++++------------------
 3 files changed, 142 insertions(+), 81 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/fs/hugetlbfs/inode.c linux-2.6.25-rc9-POC-MAP_PRIVATE-reserve/fs/hugetlbfs/inode.c
--- linux-2.6.25-rc9-clean/fs/hugetlbfs/inode.c	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-POC-MAP_PRIVATE-reserve/fs/hugetlbfs/inode.c	2008-04-21 17:05:25.000000000 +0100
@@ -103,9 +103,9 @@ static int hugetlbfs_file_mmap(struct fi
 	ret = -ENOMEM;
 	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 
-	if (vma->vm_flags & VM_MAYSHARE &&
-	    hugetlb_reserve_pages(inode, vma->vm_pgoff >> (HPAGE_SHIFT-PAGE_SHIFT),
-				  len >> HPAGE_SHIFT))
+	if (hugetlb_reserve_pages(inode,
+				vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT),
+				len >> HPAGE_SHIFT, vma))
 		goto out;
 
 	ret = 0;
@@ -942,7 +942,7 @@ struct file *hugetlb_file_setup(const ch
 		goto out_dentry;
 
 	error = -ENOMEM;
-	if (hugetlb_reserve_pages(inode, 0, size >> HPAGE_SHIFT))
+	if (hugetlb_reserve_pages(inode, 0, size >> HPAGE_SHIFT, NULL))
 		goto out_inode;
 
 	d_instantiate(dentry, inode);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/include/linux/hugetlb.h linux-2.6.25-rc9-POC-MAP_PRIVATE-reserve/include/linux/hugetlb.h
--- linux-2.6.25-rc9-clean/include/linux/hugetlb.h	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-POC-MAP_PRIVATE-reserve/include/linux/hugetlb.h	2008-04-17 16:45:32.000000000 +0100
@@ -29,7 +29,8 @@ int hugetlb_report_node_meminfo(int, cha
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
-int hugetlb_reserve_pages(struct inode *inode, long from, long to);
+int hugetlb_reserve_pages(struct inode *inode, long from, long to,
+						struct vm_area_struct *vma);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 
 extern unsigned long max_huge_pages;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/mm/hugetlb.c linux-2.6.25-rc9-POC-MAP_PRIVATE-reserve/mm/hugetlb.c
--- linux-2.6.25-rc9-clean/mm/hugetlb.c	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-POC-MAP_PRIVATE-reserve/mm/hugetlb.c	2008-04-21 18:29:19.000000000 +0100
@@ -40,6 +40,34 @@ static int hugetlb_next_nid;
  */
 static DEFINE_SPINLOCK(hugetlb_lock);
 
+/* Helpers to track the number of pages reserved for a MAP_PRIVATE vma */
+static unsigned long vma_resv_huge_pages(struct vm_area_struct *vma)
+{
+	if (!(vma->vm_flags & VM_MAYSHARE))
+		return (unsigned long)vma->vm_private_data;
+	return 0;
+}
+
+static void adjust_vma_resv_huge_pages(struct vm_area_struct *vma,
+						int delta)
+{
+	BUG_ON((unsigned long)vma->vm_private_data > 100);
+	WARN_ON_ONCE(vma->vm_flags & VM_MAYSHARE);
+	if (!(vma->vm_flags & VM_MAYSHARE)) {
+		unsigned long reserve;
+		reserve = (unsigned long)vma->vm_private_data + delta;
+		vma->vm_private_data = (void *)reserve;
+	}
+}
+static void set_vma_resv_huge_pages(struct vm_area_struct *vma,
+						unsigned long reserve)
+{
+	BUG_ON((unsigned long)vma->vm_private_data > 100);
+	WARN_ON_ONCE(vma->vm_flags & VM_MAYSHARE);
+	if (!(vma->vm_flags & VM_MAYSHARE))
+		vma->vm_private_data = (void *)reserve;
+}
+
 static void clear_huge_page(struct page *page, unsigned long addr)
 {
 	int i;
@@ -99,6 +127,16 @@ static struct page *dequeue_huge_page_vm
 					htlb_alloc_mask, &mpol);
 	struct zone **z;
 
+	/*
+	 * A child process with MAP_PRIVATE mappings created by their parent
+	 * have no page reserves. This check ensures that reservations are
+	 * not "stolen". The child may still get SIGKILLed
+	 */
+	if (!(vma->vm_flags & VM_MAYSHARE) &&
+			!vma_resv_huge_pages(vma) &&
+			free_huge_pages - resv_huge_pages == 0)
+		return NULL;
+
 	for (z = zonelist->zones; *z; z++) {
 		nid = zone_to_nid(*z);
 		if (cpuset_zone_allowed_softwall(*z, htlb_alloc_mask) &&
@@ -108,8 +146,23 @@ static struct page *dequeue_huge_page_vm
 			list_del(&page->lru);
 			free_huge_pages--;
 			free_huge_pages_node[nid]--;
-			if (vma && vma->vm_flags & VM_MAYSHARE)
+
+			/* Update reserves as applicable */
+			if (vma->vm_flags & VM_MAYSHARE) {
+				/* Shared mappings always have a reserve */
 				resv_huge_pages--;
+			} else {
+				/*
+				 * Only the process that called mmap() has
+				 * reserves for private mappings. Be careful
+				 * not to overflow counters from children
+				 * faulting
+				 */
+				if (vma_resv_huge_pages(vma)) {
+					resv_huge_pages--;
+					adjust_vma_resv_huge_pages(vma, -1);
+				}
+			}
 			break;
 		}
 	}
@@ -437,50 +490,23 @@ static void return_unused_surplus_pages(
 	}
 }
 
-
-static struct page *alloc_huge_page_shared(struct vm_area_struct *vma,
-						unsigned long addr)
+static struct page *alloc_huge_page(struct vm_area_struct *vma,
+				    unsigned long addr)
 {
 	struct page *page;
+	struct address_space *mapping = vma->vm_file->f_mapping;
 
+	/* Try dequeueing a page from the pool */
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(vma, addr);
 	spin_unlock(&hugetlb_lock);
-	return page ? page : ERR_PTR(-VM_FAULT_OOM);
-}
-
-static struct page *alloc_huge_page_private(struct vm_area_struct *vma,
-						unsigned long addr)
-{
-	struct page *page = NULL;
-
-	if (hugetlb_get_quota(vma->vm_file->f_mapping, 1))
-		return ERR_PTR(-VM_FAULT_SIGBUS);
 
-	spin_lock(&hugetlb_lock);
-	if (free_huge_pages > resv_huge_pages)
-		page = dequeue_huge_page_vma(vma, addr);
-	spin_unlock(&hugetlb_lock);
+	/* Attempt dynamic resizing */
 	if (!page) {
 		page = alloc_buddy_huge_page(vma, addr);
-		if (!page) {
-			hugetlb_put_quota(vma->vm_file->f_mapping, 1);
-			return ERR_PTR(-VM_FAULT_OOM);
-		}
+		if (!page)
+			page = ERR_PTR(-VM_FAULT_OOM);
 	}
-	return page;
-}
-
-static struct page *alloc_huge_page(struct vm_area_struct *vma,
-				    unsigned long addr)
-{
-	struct page *page;
-	struct address_space *mapping = vma->vm_file->f_mapping;
-
-	if (vma->vm_flags & VM_MAYSHARE)
-		page = alloc_huge_page_shared(vma, addr);
-	else
-		page = alloc_huge_page_private(vma, addr);
 
 	if (!IS_ERR(page)) {
 		set_page_refcounted(page);
@@ -705,8 +731,64 @@ static int hugetlb_vm_op_fault(struct vm
 	return 0;
 }
 
+static int hugetlb_acct_memory(long delta)
+{
+	int ret = -ENOMEM;
+
+	spin_lock(&hugetlb_lock);
+	/*
+	 * When cpuset is configured, it breaks the strict hugetlb page
+	 * reservation as the accounting is done on a global variable. Such
+	 * reservation is completely rubbish in the presence of cpuset because
+	 * the reservation is not checked against page availability for the
+	 * current cpuset. Application can still potentially OOM'ed by kernel
+	 * with lack of free htlb page in cpuset that the task is in.
+	 * Attempt to enforce strict accounting with cpuset is almost
+	 * impossible (or too ugly) because cpuset is too fluid that
+	 * task or memory node can be dynamically moved between cpusets.
+	 *
+	 * The change of semantics for shared hugetlb mapping with cpuset is
+	 * undesirable. However, in order to preserve some of the semantics,
+	 * we fall back to check against current free page availability as
+	 * a best attempt and hopefully to minimize the impact of changing
+	 * semantics that cpuset has.
+	 */
+	if (delta > 0) {
+		if (gather_surplus_pages(delta) < 0)
+			goto out;
+
+		if (delta > cpuset_mems_nr(free_huge_pages_node)) {
+			return_unused_surplus_pages(delta);
+			goto out;
+		}
+	}
+
+	ret = 0;
+	if (delta < 0)
+		return_unused_surplus_pages((unsigned long) -delta);
+
+out:
+	spin_unlock(&hugetlb_lock);
+	return ret;
+}
+
+static void hugetlb_vm_open(struct vm_area_struct *vma)
+{
+	if (!(vma->vm_flags & VM_MAYSHARE))
+		set_vma_resv_huge_pages(vma, 0);
+}
+
+static void hugetlb_vm_close(struct vm_area_struct *vma)
+{
+	unsigned long reserve = vma_resv_huge_pages(vma);
+	if (reserve)
+		hugetlb_acct_memory(-reserve);
+}
+
 struct vm_operations_struct hugetlb_vm_ops = {
 	.fault = hugetlb_vm_op_fault,
+	.close = hugetlb_vm_close,
+	.open = hugetlb_vm_open,
 };
 
 static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
@@ -1223,52 +1305,30 @@ static long region_truncate(struct list_
 	return chg;
 }
 
-static int hugetlb_acct_memory(long delta)
+int hugetlb_reserve_pages(struct inode *inode,
+					long from, long to,
+					struct vm_area_struct *vma)
 {
-	int ret = -ENOMEM;
+	long ret, chg;
 
-	spin_lock(&hugetlb_lock);
 	/*
-	 * When cpuset is configured, it breaks the strict hugetlb page
-	 * reservation as the accounting is done on a global variable. Such
-	 * reservation is completely rubbish in the presence of cpuset because
-	 * the reservation is not checked against page availability for the
-	 * current cpuset. Application can still potentially OOM'ed by kernel
-	 * with lack of free htlb page in cpuset that the task is in.
-	 * Attempt to enforce strict accounting with cpuset is almost
-	 * impossible (or too ugly) because cpuset is too fluid that
-	 * task or memory node can be dynamically moved between cpusets.
-	 *
-	 * The change of semantics for shared hugetlb mapping with cpuset is
-	 * undesirable. However, in order to preserve some of the semantics,
-	 * we fall back to check against current free page availability as
-	 * a best attempt and hopefully to minimize the impact of changing
-	 * semantics that cpuset has.
+	 * Shared mappings and read-only mappings should based their reservation
+	 * on the number of pages that are already allocated on behalf of the
+	 * file. Private mappings that are writable need to reserve the full
+	 * area. Note that a read-only private mapping that subsequently calls
+	 * mprotect() to make it read-write may not work reliably
 	 */
-	if (delta > 0) {
-		if (gather_surplus_pages(delta) < 0)
-			goto out;
-
-		if (delta > cpuset_mems_nr(free_huge_pages_node)) {
-			return_unused_surplus_pages(delta);
-			goto out;
-		}
+	if (vma->vm_flags & VM_SHARED)
+		chg = region_chg(&inode->i_mapping->private_list, from, to);
+	else {
+		if (vma->vm_flags & VM_MAYWRITE)
+			chg = to - from;
+		else
+			chg = region_chg(&inode->i_mapping->private_list,
+								from, to);
+		set_vma_resv_huge_pages(vma, chg);
 	}
-
-	ret = 0;
-	if (delta < 0)
-		return_unused_surplus_pages((unsigned long) -delta);
-
-out:
-	spin_unlock(&hugetlb_lock);
-	return ret;
-}
-
-int hugetlb_reserve_pages(struct inode *inode, long from, long to)
-{
-	long ret, chg;
-
-	chg = region_chg(&inode->i_mapping->private_list, from, to);
+
 	if (chg < 0)
 		return chg;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
