Date: Tue, 13 May 2003 13:36:36 -0700
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: [RFC][PATCH] Interface to invalidate regions of mmaps
Message-ID: <20030513133636.C2929@us.ibm.com>
Reply-To: paulmck@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
Cc: mjbligh@us.ibm.com
List-ID: <linux-mm.kvack.org>

This patch adds an API to allow networked and distributed filesystems
to invalidate portions of (or all of) a file.  This is needed to 
provide POSIX or near-POSIX semantics in such filesystems, as
discussed on LKML late last year:

	http://marc.theaimsgroup.com/?l=linux-kernel&m=103609089604576&w=2
	http://marc.theaimsgroup.com/?l=linux-kernel&m=103167761917669&w=2

Thoughts?

						Thanx, Paul

diff -urN -X dontdiff linux-2.5.69/include/linux/mm.h linux-2.5.69.invalidate_mmap_range/include/linux/mm.h
--- linux-2.5.69/include/linux/mm.h	Sun May  4 16:53:00 2003
+++ linux-2.5.69.invalidate_mmap_range/include/linux/mm.h	Fri May  9 17:35:48 2003
@@ -412,6 +412,9 @@
 int zeromap_page_range(struct vm_area_struct *vma, unsigned long from,
 			unsigned long size, pgprot_t prot);
 
+extern void invalidate_mmap_range(struct address_space *mapping,
+				  loff_t const holebegin,
+				  loff_t const holelen);
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern pmd_t *FASTCALL(__pmd_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address));
 extern pte_t *FASTCALL(pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
diff -urN -X dontdiff linux-2.5.69/kernel/ksyms.c linux-2.5.69.invalidate_mmap_range/kernel/ksyms.c
--- linux-2.5.69/kernel/ksyms.c	Sun May  4 16:52:49 2003
+++ linux-2.5.69.invalidate_mmap_range/kernel/ksyms.c	Fri May  9 17:35:48 2003
@@ -117,6 +117,7 @@
 EXPORT_SYMBOL(max_mapnr);
 #endif
 EXPORT_SYMBOL(high_memory);
+EXPORT_SYMBOL(invalidate_mmap_range);
 EXPORT_SYMBOL(vmtruncate);
 EXPORT_SYMBOL(find_vma);
 EXPORT_SYMBOL(get_unmapped_area);
diff -urN -X dontdiff linux-2.5.69/mm/memory.c linux-2.5.69.invalidate_mmap_range/mm/memory.c
--- linux-2.5.69/mm/memory.c	Sun May  4 16:53:14 2003
+++ linux-2.5.69.invalidate_mmap_range/mm/memory.c	Mon May 12 15:09:28 2003
@@ -1060,6 +1060,74 @@
 	return ret;
 }
 
+/*
+ * Helper function for invalidate_mmap_range().
+ * Both hba and hlen are page numbers in PAGE_SIZE units.
+ */
+static void 
+invalidate_mmap_range_list(struct list_head *head,
+			   unsigned long const hba,
+			   unsigned long const hlen)
+{
+	struct list_head *curr;
+	unsigned long hea;	/* last page of hole. */
+	unsigned long vba;
+	unsigned long vea;	/* last page of corresponding uva hole. */
+	struct vm_area_struct *vp;
+	unsigned long zba;
+	unsigned long zea;
+
+	hea = hba + hlen - 1;	/* avoid overflow. */
+	list_for_each(curr, head) {
+		vp = list_entry(curr, struct vm_area_struct, shared);
+		vba = vp->vm_pgoff;
+		vea = vba + ((vp->vm_end - vp->vm_start) >> PAGE_SHIFT) - 1;
+		if (hea < vba || vea < hba)
+		    	continue;	/* Mapping disjoint from hole. */
+		zba = (hba <= vba) ? vba : hba;
+		zea = (vea <= hea) ? vea : hea;
+		zap_page_range(vp,
+			       ((zba - vba) << PAGE_SHIFT) + vp->vm_start,
+			       (zea - zba + 1) << PAGE_SHIFT);
+	}
+}
+
+/**
+ * invalidate_mmap_range - invalidate the portion of all mmaps
+ * in the specified address_space corresponding to the specified
+ * page range in the underlying file.
+ * @address_space: the address space containing mmaps to be invalidated.
+ * @holebegin: byte in first page to invalidate, relative to the start of
+ * the underlying file.  This will be rounded down to a PAGE_SIZE
+ * boundary.
+ * @holelen: size of prospective hole in bytes.  This will be rounded
+ * up to a PAGE_SIZE boundary.
+ */
+void 
+invalidate_mmap_range(struct address_space *mapping,
+		      loff_t const holebegin,
+		      loff_t const holelen)
+{
+	unsigned long hba = holebegin >> PAGE_SHIFT;
+	unsigned long hlen = (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
+
+	if (hlen == 0)
+		return;
+	/* Check for overflow. */
+	if (sizeof(holelen) > sizeof(hlen)) {
+		long long holeend = (holebegin + holelen - 1) >> PAGE_SHIFT;
+
+		if (holeend & ~(long long)ULONG_MAX)
+			hlen = ULONG_MAX - hba + 1;
+	}
+	down(&mapping->i_shared_sem);
+	if (unlikely(!list_empty(&mapping->i_mmap)))
+		invalidate_mmap_range_list(&mapping->i_mmap, hba, hlen);
+	if (unlikely(!list_empty(&mapping->i_mmap_shared)))
+		invalidate_mmap_range_list(&mapping->i_mmap_shared, hba, hlen);
+	up(&mapping->i_shared_sem);
+}       
+
 static void vmtruncate_list(struct list_head *head, unsigned long pgoff)
 {
 	unsigned long start, end, len, diff;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
