Date: Fri, 2 May 2008 05:21:32 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/4] mspec: convert nopfn to fault
Message-ID: <20080502032132.GF11844@wotan.suse.de>
References: <20080502031903.GD11844@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080502031903.GD11844@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jk@ozlabs.org, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

---

 drivers/char/mspec.c |   22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

Index: linux-2.6/drivers/char/mspec.c
===================================================================
--- linux-2.6.orig/drivers/char/mspec.c
+++ linux-2.6/drivers/char/mspec.c
@@ -193,25 +193,24 @@ mspec_close(struct vm_area_struct *vma)
 }
 
 /*
- * mspec_nopfn
+ * mspec_fault
  *
  * Creates a mspec page and maps it to user space.
  */
-static unsigned long
-mspec_nopfn(struct vm_area_struct *vma, unsigned long address)
+static int
+mspec_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	unsigned long paddr, maddr;
 	unsigned long pfn;
+	pgoff_t index = vmf->pgoff;
 	int index;
 	struct vma_data *vdata = vma->vm_private_data;
 
-	BUG_ON(address < vdata->vm_start || address >= vdata->vm_end);
-	index = (address - vdata->vm_start) >> PAGE_SHIFT;
 	maddr = (volatile unsigned long) vdata->maddr[index];
 	if (maddr == 0) {
 		maddr = uncached_alloc_page(numa_node_id(), 1);
 		if (maddr == 0)
-			return NOPFN_OOM;
+			return VM_FAULT_OOM;
 
 		spin_lock(&vdata->lock);
 		if (vdata->maddr[index] == 0) {
@@ -231,13 +230,20 @@ mspec_nopfn(struct vm_area_struct *vma, 
 
 	pfn = paddr >> PAGE_SHIFT;
 
-	return pfn;
+	/*
+	 * vm_insert_pfn can fail with -EBUSY, but in that case it will
+	 * be because another thread has installed the pte first, so it
+	 * is no problem.
+	 */
+	vm_insert_pfn(vma, (unsigned long)vmf->virtual_address, pfn);
+
+	return VM_FAULT_NOPAGE;
 }
 
 static struct vm_operations_struct mspec_vm_ops = {
 	.open = mspec_open,
 	.close = mspec_close,
-	.nopfn = mspec_nopfn
+	.fault = mspec_fault,
 };
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
