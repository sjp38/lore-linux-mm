From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080520162938.8338.33238.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080520162858.8338.22460.sendpatchset@skynet.skynet.ie>
References: <20080520162858.8338.22460.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/3] Reserve huge pages for reliable MAP_PRIVATE hugetlbfs mappings until fork()
Date: Tue, 20 May 2008 17:29:38 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, abh@cray.com, dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, dwg@au1.ibm.com, andi@firstfloor.org, kenchen@google.com, agl@us.ibm.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

This patch reserves huge pages at mmap() time for MAP_PRIVATE mappings in a
similar manner to the reservations taken for MAP_SHARED mappings. The reserve count is
accounted both globally and on a per-VMA basis for private mappings. This
guarantees that a process that successfully calls mmap() will successfully
fault all pages in the future unless fork() is called.

The characteristics of private mappings of hugetlbfs files behaviour after
this patch are;

1. The process calling mmap() is guaranteed to succeed all future faults until
   it forks().
2. On fork(), the parent may die due to SIGKILL on writes to the private
   mapping if enough pages are not available for the COW. For reasonably
   reliable behaviour in the face of a small huge page pool, children of
   hugepage-aware processes should not reference the mappings; such as
   might occur when fork()ing to exec().
3. On fork(), the child VMAs inherit no reserves. Reads on pages already
   faulted by the parent will succeed. Successful writes will depend on enough
   huge pages being free in the pool.
4. Quotas of the hugetlbfs mount are checked at reserve time for the mapper
   and at fault time otherwise.

Before this patch, all reads or writes in the child potentially needs page
allocations that can later lead to the death of the parent. This applies
to reads and writes of uninstantiated pages as well as COW. After the
patch it is only a write to an instantiated page that causes problems.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 fs/hugetlbfs/inode.c    |    8 +-
 include/linux/hugetlb.h |    9 ++
 kernel/fork.c           |    9 ++
 mm/hugetlb.c            |  158 ++++++++++++++++++++++++++++++++-----------
 4 files changed, 140 insertions(+), 44 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc2-mm1-0010-move-hugetlb_acct_memory/fs/hugetlbfs/inode.c linux-2.6.26-rc2-mm1-0020-map_private_reserve/fs/hugetlbfs/inode.c
--- linux-2.6.26-rc2-mm1-0010-move-hugetlb_acct_memory/fs/hugetlbfs/inode.c	2008-05-12 01:09:41.000000000 +0100
+++ linux-2.6.26-rc2-mm1-0020-map_private_reserve/fs/hugetlbfs/inode.c	2008-05-20 11:53:50.000000000 +0100
@@ -103,9 +103,9 @@ static int hugetlbfs_file_mmap(struct fi
 	ret = -ENOMEM;
 	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 
-	if (vma->vm_flags & VM_MAYSHARE &&
-	    hugetlb_reserve_pages(inode, vma->vm_pgoff >> (HPAGE_SHIFT-PAGE_SHIFT),
-				  len >> HPAGE_SHIFT))
+	if (hugetlb_reserve_pages(inode,
+				vma->vm_pgoff >> (HPAGE_SHIFT-PAGE_SHIFT),
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc2-mm1-0010-move-hugetlb_acct_memory/include/linux/hugetlb.h linux-2.6.26-rc2-mm1-0020-map_private_reserve/include/linux/hugetlb.h
--- linux-2.6.26-rc2-mm1-0010-move-hugetlb_acct_memory/include/linux/hugetlb.h	2008-05-12 01:09:41.000000000 +0100
+++ linux-2.6.26-rc2-mm1-0020-map_private_reserve/include/linux/hugetlb.h	2008-05-20 11:53:50.000000000 +0100
@@ -17,6 +17,7 @@ static inline int is_vm_hugetlb_page(str
 	return vma->vm_flags & VM_HUGETLB;
 }
 
+void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int hugetlb_treat_movable_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
@@ -30,7 +31,8 @@ int hugetlb_report_node_meminfo(int, cha
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
-int hugetlb_reserve_pages(struct inode *inode, long from, long to);
+int hugetlb_reserve_pages(struct inode *inode, long from, long to,
+						struct vm_area_struct *vma);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 
 extern unsigned long max_huge_pages;
@@ -58,6 +60,11 @@ static inline int is_vm_hugetlb_page(str
 {
 	return 0;
 }
+
+static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
+{
+}
+
 static inline unsigned long hugetlb_total_pages(void)
 {
 	return 0;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc2-mm1-0010-move-hugetlb_acct_memory/kernel/fork.c linux-2.6.26-rc2-mm1-0020-map_private_reserve/kernel/fork.c
--- linux-2.6.26-rc2-mm1-0010-move-hugetlb_acct_memory/kernel/fork.c	2008-05-19 13:36:30.000000000 +0100
+++ linux-2.6.26-rc2-mm1-0020-map_private_reserve/kernel/fork.c	2008-05-20 11:53:50.000000000 +0100
@@ -54,6 +54,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/hugetlb.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -306,6 +307,14 @@ static int dup_mmap(struct mm_struct *mm
 		}
 
 		/*
+		 * Clear hugetlb-related page reserves for children. This only
+		 * affects MAP_PRIVATE mappings. Faults generated by the child
+		 * are not guaranteed to succeed, even if read-only
+		 */
+		if (is_vm_hugetlb_page(tmp))
+			reset_vma_resv_huge_pages(tmp);
+
+		/*
 		 * Link in the new vma and copy the page table entries.
 		 */
 		*pprev = tmp;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc2-mm1-0010-move-hugetlb_acct_memory/mm/hugetlb.c linux-2.6.26-rc2-mm1-0020-map_private_reserve/mm/hugetlb.c
--- linux-2.6.26-rc2-mm1-0010-move-hugetlb_acct_memory/mm/hugetlb.c	2008-05-20 11:53:41.000000000 +0100
+++ linux-2.6.26-rc2-mm1-0020-map_private_reserve/mm/hugetlb.c	2008-05-20 11:53:50.000000000 +0100
@@ -40,6 +40,69 @@ static int hugetlb_next_nid;
  */
 static DEFINE_SPINLOCK(hugetlb_lock);
 
+/*
+ * These helpers are used to track how many pages are reserved for
+ * faults in a MAP_PRIVATE mapping. Only the process that called mmap()
+ * is guaranteed to have their future faults succeed.
+ *
+ * With the exception of reset_vma_resv_huge_pages() which is called at fork(),
+ * the reserve counters are updated with the hugetlb_lock held. It is safe
+ * to reset the VMA at fork() time as it is not in use yet and there is no
+ * chance of the global counters getting corrupted as a result of the values.
+ */
+static unsigned long vma_resv_huge_pages(struct vm_area_struct *vma)
+{
+	VM_BUG_ON(!is_vm_hugetlb_page(vma));
+	if (!(vma->vm_flags & VM_SHARED))
+		return (unsigned long)vma->vm_private_data;
+	return 0;
+}
+
+static void set_vma_resv_huge_pages(struct vm_area_struct *vma,
+							unsigned long reserve)
+{
+	VM_BUG_ON(!is_vm_hugetlb_page(vma));
+	VM_BUG_ON(vma->vm_flags & VM_SHARED);
+
+	vma->vm_private_data = (void *)reserve;
+}
+
+/* Decrement the reserved pages in the hugepage pool by one */
+static void decrement_hugepage_resv_vma(struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_SHARED) {
+		/* Shared mappings always use reserves */
+		resv_huge_pages--;
+	} else {
+		/*
+		 * Only the process that called mmap() has reserves for
+		 * private mappings.
+		 */
+		if (vma_resv_huge_pages(vma)) {
+			resv_huge_pages--;
+			reserve = (unsigned long)vma->vm_private_data - 1;
+			vma->vm_private_data = (void *)reserve;
+		}
+	}
+}
+
+void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
+{
+	VM_BUG_ON(!is_vm_hugetlb_page(vma));
+	if (!(vma->vm_flags & VM_SHARED))
+		vma->vm_private_data = (void *)0;
+}
+
+/* Returns true if the VMA has associated reserve pages */
+static int vma_has_private_reserves(struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_SHARED)
+		return 0;
+	if (!vma_resv_huge_pages(vma))
+		return 0;
+	return 1;
+}
+
 static void clear_huge_page(struct page *page, unsigned long addr)
 {
 	int i;
@@ -101,6 +164,15 @@ static struct page *dequeue_huge_page_vm
 	struct zone *zone;
 	struct zoneref *z;
 
+	/*
+	 * A child process with MAP_PRIVATE mappings created by their parent
+	 * have no page reserves. This check ensures that reservations are
+	 * not "stolen". The child may still get SIGKILLed
+	 */
+	if (!vma_has_private_reserves(vma) &&
+			free_huge_pages - resv_huge_pages == 0)
+		return NULL;
+
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
 		nid = zone_to_nid(zone);
@@ -111,8 +183,8 @@ static struct page *dequeue_huge_page_vm
 			list_del(&page->lru);
 			free_huge_pages--;
 			free_huge_pages_node[nid]--;
-			if (vma && vma->vm_flags & VM_MAYSHARE)
-				resv_huge_pages--;
+			decrement_hugepage_resv_vma(vma);
+
 			break;
 		}
 	}
@@ -461,55 +533,40 @@ static void return_unused_surplus_pages(
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
+	struct inode *inode = mapping->host;
+	unsigned int chg = 0;
+
+	/*
+	 * Processes that did not create the mapping will have no reserves and
+	 * will not have accounted against quota. Check that the quota can be
+	 * made before satisfying the allocation
+	 */
+	if (!vma_has_private_reserves(vma)) {
+		chg = 1;
+		if (hugetlb_get_quota(inode->i_mapping, chg))
+			return ERR_PTR(-ENOSPC);
+	}
 
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(vma, addr);
 	spin_unlock(&hugetlb_lock);
-	return page ? page : ERR_PTR(-VM_FAULT_OOM);
-}
 
-static struct page *alloc_huge_page_private(struct vm_area_struct *vma,
-						unsigned long addr)
-{
-	struct page *page = NULL;
-
-	if (hugetlb_get_quota(vma->vm_file->f_mapping, 1))
-		return ERR_PTR(-VM_FAULT_SIGBUS);
-
-	spin_lock(&hugetlb_lock);
-	if (free_huge_pages > resv_huge_pages)
-		page = dequeue_huge_page_vma(vma, addr);
-	spin_unlock(&hugetlb_lock);
 	if (!page) {
 		page = alloc_buddy_huge_page(vma, addr);
 		if (!page) {
-			hugetlb_put_quota(vma->vm_file->f_mapping, 1);
+			hugetlb_put_quota(inode->i_mapping, chg);
 			return ERR_PTR(-VM_FAULT_OOM);
 		}
 	}
-	return page;
-}
 
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
+	set_page_refcounted(page);
+	set_page_private(page, (unsigned long) mapping);
 
-	if (!IS_ERR(page)) {
-		set_page_refcounted(page);
-		set_page_private(page, (unsigned long) mapping);
-	}
 	return page;
 }
 
@@ -757,6 +814,13 @@ out:
 	return ret;
 }
 
+static void hugetlb_vm_op_close(struct vm_area_struct *vma)
+{
+	unsigned long reserve = vma_resv_huge_pages(vma);
+	if (reserve)
+		hugetlb_acct_memory(-reserve);
+}
+
 /*
  * We cannot handle pagefaults against hugetlb pages at all.  They cause
  * handle_mm_fault() to try to instantiate regular-sized pages in the
@@ -771,6 +835,7 @@ static int hugetlb_vm_op_fault(struct vm
 
 struct vm_operations_struct hugetlb_vm_ops = {
 	.fault = hugetlb_vm_op_fault,
+	.close = hugetlb_vm_op_close,
 };
 
 static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
@@ -1289,11 +1354,25 @@ static long region_truncate(struct list_
 	return chg;
 }
 
-int hugetlb_reserve_pages(struct inode *inode, long from, long to)
+int hugetlb_reserve_pages(struct inode *inode,
+					long from, long to,
+					struct vm_area_struct *vma)
 {
 	long ret, chg;
 
-	chg = region_chg(&inode->i_mapping->private_list, from, to);
+	/*
+	 * Shared mappings base their reservation on the number of pages that
+	 * are already allocated on behalf of the file. Private mappings need
+	 * to reserve the full area even if read-only as mprotect() may be
+	 * called to make the mapping read-write. Assume !vma is a shm mapping
+	 */
+	if (!vma || vma->vm_flags & VM_SHARED)
+		chg = region_chg(&inode->i_mapping->private_list, from, to);
+	else {
+		chg = to - from;
+		set_vma_resv_huge_pages(vma, chg);
+	}
+
 	if (chg < 0)
 		return chg;
 
@@ -1304,7 +1383,8 @@ int hugetlb_reserve_pages(struct inode *
 		hugetlb_put_quota(inode->i_mapping, chg);
 		return ret;
 	}
-	region_add(&inode->i_mapping->private_list, from, to);
+	if (!vma || vma->vm_flags & VM_SHARED)
+		region_add(&inode->i_mapping->private_list, from, to);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
