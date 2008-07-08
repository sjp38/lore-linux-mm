Date: Tue, 8 Jul 2008 11:38:09 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH 1/2] - Unmap driver ptes
Message-ID: <20080708163809.GA19366@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add function to unmap driver ptes.

zap_vma_ptes() is intended to be used by drivers to unmap
ptes assigned to the driver private vmas. This interface is
similar to zap_page_range() but is less general & less likely to
be abused.


Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 include/linux/mm.h |    2 ++
 mm/memory.c        |   23 +++++++++++++++++++++++
 2 files changed, 25 insertions(+)

Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2008-07-07 12:22:17.809892803 -0500
+++ linux/include/linux/mm.h	2008-07-07 12:22:56.126695482 -0500
@@ -742,6 +742,8 @@ struct zap_details {
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 		pte_t pte);
 
+int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
+		unsigned long size);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
 unsigned long unmap_vmas(struct mmu_gather **tlb,
Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2008-07-07 12:22:18.357961503 -0500
+++ linux/mm/memory.c	2008-07-07 12:31:51.097688882 -0500
@@ -978,6 +978,29 @@ unsigned long zap_page_range(struct vm_a
 }
 EXPORT_SYMBOL_GPL(zap_page_range);
 
+/**
+ * zap_vma_ptes - remove ptes mapping the vma
+ * @vma: vm_area_struct holding ptes to be zapped
+ * @address: starting address of pages to zap
+ * @size: number of bytes to zap
+ *
+ * This function only unmaps ptes assigned to VM_PFNMAP vmas.
+ *
+ * The entire address range must be fully contained within the vma.
+ *
+ * Returns 0 if successful.
+ */
+int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
+		unsigned long size)
+{
+	if (address < vma->vm_start || address + size > vma->vm_end ||
+	    		!(vma->vm_flags & VM_PFNMAP))
+		return -1;
+	zap_page_range(vma, address, size, NULL);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(zap_vma_ptes);
+
 /*
  * Do a quick page-table lookup for a single page.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
