From: David Woodhouse <dwmw2@infradead.org>
Subject: rmap for ARMV. 
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Tue, 19 Feb 2002 16:01:34 +0000
Message-ID: <22292.1014134494@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

ARM was fun because it has a slab cache with 2KiB objects for page tables, 
rather than allocating them a page at a time - so we couldn't just use
page->{mapping,index} for each page as we do on other architectures.

I solve this by allocating a 16-byte structure to go with each page in the 
pte_cache slab, which holds {mm,index} for each of the two page tables in 
that page.

This means a second kmem_cache_alloc in the constructor for the pte_cache
slab, which I'm a bit dubious about. The only alternative I could see was to
allocate/free them individually for each page table in pte_alloc_one() and
pte_free_slow(). The only way I'd be able to keep track of them then,
though, would be to use page->mapping for the first and page->index as a
pointer to the second, and I was even less happy with that than this
version.

--- linux-clean/arch/arm/mm/mm-armv.c	Wed Jun 27 22:12:04 2001
+++ linux/arch/arm/mm/mm-armv.c	Tue Feb 19 11:37:31 2002
@@ -19,6 +19,7 @@
 #include <asm/page.h>
 #include <asm/io.h>
 #include <asm/setup.h>
+#include <asm/rmap.h>
 
 #include <asm/mach/map.h>
 
@@ -457,6 +458,7 @@
  * cache implementation.
  */
 kmem_cache_t *pte_cache;
+kmem_cache_t *pte_rmap_cache;
 
 /*
  * The constructor gets called for each object within the cache when the
@@ -467,6 +471,22 @@
 {
 	unsigned long block = (unsigned long)pte;
 
+	if (!(block & 2048)) {
+		/* First object of two in a page - allocate the 
+		   pte_rmap_info to go with them */
+
+		struct page * page = virt_to_page(pte);
+
+		if (flags & SLAB_CTOR_ATOMIC)
+			BUG();
+
+		page->mapping = kmem_cache_alloc(pte_rmap_cache, GFP_KERNEL);
+		if (!page->mapping) {
+			printk(KERN_CRIT "pte_rmap_cache alloc failed. Oops. Slab constructors need to be allowed to fail\n");
+			/* return -ENOMEM; */
+			BUG();
+		}
+	}
 	if (block & 2047)
 		BUG();
 
@@ -475,11 +495,31 @@
 			PTRS_PER_PTE * sizeof(pte_t), 0);
 }
 
+static void pte_cache_dtor(void *pte, kmem_cache_t *cache, unsigned long flags)
+{
+	unsigned long block = (unsigned long)pte;
+
+	if (!(block & 2048)) {
+		/* First object of two in a page - free the 
+		   pte_rmap_info that was associated with them */
+
+		struct page * page = virt_to_page(pte);
+
+		kmem_cache_free(pte_rmap_cache, page->mapping);
+	}
+}
+
 void __init pgtable_cache_init(void)
 {
+	pte_rmap_cache = kmem_cache_create("pte-rmap-cache",
+				2 * sizeof(struct arm_rmap_info), 0, 0,
+				NULL, NULL);
+	if (!pte_rmap_cache)
+		BUG();
+
 	pte_cache = kmem_cache_create("pte-cache",
 				2 * PTRS_PER_PTE * sizeof(pte_t), 0, 0,
-				pte_cache_ctor, NULL);
+				pte_cache_ctor, pte_cache_dtor);
 	if (!pte_cache)
 		BUG();
 }
diff -uNr --exclude *.o --exclude *.o.flags --exclude *.a --exclude *.a.flags --exclude *~ --exclude .version --exclude compile.h linux-clean/include/asm-arm/proc-armv/rmap.h linux/include/asm-arm/proc-armv/rmap.h
--- linux-clean/include/asm-arm/proc-armv/rmap.h	Thu Jan  1 01:00:00 1970
+++ linux/include/asm-arm/proc-armv/rmap.h	Tue Feb 19 11:38:42 2002
@@ -0,0 +1,72 @@
+#ifndef _ARMV_RMAP_H
+#define _ARMV_RMAP_H
+/*
+ * linux/include/asm-arm/proc-armv/rmap.h
+ *
+ * Architecture dependant parts of the reverse mapping code,
+ *
+ * We use the struct page of the page table page to find a pointer
+ * to an array of two 'struct arm_rmap_info's, one for each of the
+ * two page tables in each page.
+ * 
+ * - rmi->mm points to the process' mm_struct
+ * - rmi->index has the high bits of the address
+ * - the lower bits of the address are calculated from the
+ *   offset of the page table entry within the page table page
+ */
+#include <linux/mm.h>
+
+struct arm_rmap_info {
+	struct mm_struct *mm;
+	unsigned long index;
+};
+
+static inline void pgtable_add_rmap(pte_t * ptep, struct mm_struct * mm, unsigned long address)
+{
+	struct page * page = virt_to_page(ptep);
+	struct arm_rmap_info *rmi = (void *)page->mapping;
+
+	if (((unsigned long)ptep)&2048)
+		rmi++;
+
+	rmi->mm = mm;
+	rmi->index = address & ~((PTRS_PER_PTE * PAGE_SIZE) - 1);
+}
+
+static inline void pgtable_remove_rmap(pte_t * ptep)
+{
+	struct page * page = virt_to_page(ptep);
+	struct arm_rmap_info *rmi = (void *)page->mapping;
+
+	if (((unsigned long)ptep)&2048)
+		rmi++;
+
+	rmi->mm = NULL;
+	rmi->index = 0;
+}
+
+static inline struct mm_struct * ptep_to_mm(pte_t * ptep)
+{
+	struct page * page = virt_to_page(ptep);
+	struct arm_rmap_info *rmi = (void *)page->mapping;
+
+	if (((unsigned long)ptep)&2048)
+		rmi++;
+
+	return rmi->mm;
+}
+
+static inline unsigned long ptep_to_address(pte_t * ptep)
+{
+	struct page * page = virt_to_page(ptep);
+	struct arm_rmap_info *rmi = (void *)page->mapping;
+	unsigned long low_bits;
+
+	if (((unsigned long)ptep)&2048)
+		rmi++;
+
+	low_bits = ((unsigned long)ptep & ~PAGE_MASK) * PTRS_PER_PTE;
+	return rmi->index + low_bits;
+}
+
+#endif /* _ARMV_RMAP_H */
diff -uNr --exclude *.o --exclude *.o.flags --exclude *.a --exclude *.a.flags --exclude *~ --exclude .version --exclude compile.h linux-clean/include/asm-arm/rmap.h linux/include/asm-arm/rmap.h
--- linux-clean/include/asm-arm/rmap.h	Thu Jan  1 01:00:00 1970
+++ linux/include/asm-arm/rmap.h	Tue Feb 19 11:29:45 2002
@@ -0,0 +1,6 @@
+#ifndef _ARM_RMAP_H
+#define _ARM_RMAP_H
+
+#include <asm/proc/rmap.h>
+
+#endif /* _ARM_RMAP_H */

--
dwmw2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
