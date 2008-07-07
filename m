Date: Mon, 7 Jul 2008 12:58:58 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 12/13] GRU Driver V3 -  export is_uv_system(), zap_page_range() & follow_page()
Message-ID: <20080707175858.GA1927@sgi.com>
References: <20080703213348.489120321@attica.americas.sgi.com> <20080703213633.890647632@attica.americas.sgi.com> <20080704073926.GA1449@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080704073926.GA1449@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, cl@linux-foundation.org, hugh@veritas.com
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, holt@sgi.com, andrea@qumranet.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2008 at 03:39:26AM -0400, Christoph Hellwig wrote:
> On Thu, Jul 03, 2008 at 04:34:00PM -0500, steiner@sgi.com wrote:
> > +EXPORT_SYMBOL_GPL(zap_page_range);
> >  
> 
> NACK.
> 

I agree that zap_pages_range() is more general than what is needed.

How about the following. This should prevent abuse of the API &
provide what (I think) drivers need.

Verified with GRU & XPMEM.


--- jack

--------------------------------------------------------------------------------------------
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
