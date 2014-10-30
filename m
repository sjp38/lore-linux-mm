From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 06/10] mm/xip: share the i_mmap_rwsem
Date: Thu, 30 Oct 2014 12:34:13 -0700
Message-ID: <1414697657-1678-7-git-send-email-dave@stgolabs.net>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>
List-Id: linux-mm.kvack.org

__xip_unmap() will remove the xip sparse page from the cache
and take down pte mapping, without altering the interval tree,
thus share the i_mmap_rwsem when searching for the ptes to
unmap.

Additionally, tidy up the function a bit and make variables only
local to the interval tree walk loop.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>
---
 mm/filemap_xip.c | 23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index bad746b..0d105ae 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -155,22 +155,14 @@ xip_file_read(struct file *filp, char __user *buf, size_t len, loff_t *ppos)
 EXPORT_SYMBOL_GPL(xip_file_read);
 
 /*
- * __xip_unmap is invoked from xip_unmap and
- * xip_write
+ * __xip_unmap is invoked from xip_unmap and xip_write
  *
  * This function walks all vmas of the address_space and unmaps the
  * __xip_sparse_page when found at pgoff.
  */
-static void
-__xip_unmap (struct address_space * mapping,
-		     unsigned long pgoff)
+static void __xip_unmap(struct address_space * mapping, unsigned long pgoff)
 {
 	struct vm_area_struct *vma;
-	struct mm_struct *mm;
-	unsigned long address;
-	pte_t *pte;
-	pte_t pteval;
-	spinlock_t *ptl;
 	struct page *page;
 	unsigned count;
 	int locked = 0;
@@ -182,11 +174,14 @@ __xip_unmap (struct address_space * mapping,
 		return;
 
 retry:
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
-		mm = vma->vm_mm;
-		address = vma->vm_start +
+		pte_t *pte, pteval;
+		spinlock_t *ptl;
+		struct mm_struct *mm = vma->vm_mm;
+		unsigned long address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 		pte = page_check_address(page, mm, address, &ptl, 1);
 		if (pte) {
@@ -202,7 +197,7 @@ retry:
 			page_cache_release(page);
 		}
 	}
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 
 	if (locked) {
 		mutex_unlock(&xip_sparse_mutex);
-- 
1.8.4.5
