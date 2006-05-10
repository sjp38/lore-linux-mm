From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 10 May 2006 13:42:28 +1000
Message-Id: <20060510034228.17792.30130.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060510034206.17792.82504.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
References: <20060510034206.17792.82504.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
Subject: [RFC 4/6] LVHPT - find architectured page size help
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org, Ian Wienand <ianw@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

Find biggest page

Split out a handy function for finding the largest page the
architecture can map over a region.

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

---

 arch/ia64/mm/tlb.c     |   43 +++++++++++++++++++++++--------------------
 include/asm-ia64/tlb.h |   25 +++++++++++++++++++++++++
 2 files changed, 48 insertions(+), 20 deletions(-)

Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/mm/tlb.c
===================================================================
--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/arch/ia64/mm/tlb.c	2006-05-03 17:11:43.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/mm/tlb.c	2006-05-10 09:13:08.000000000 +1000
@@ -26,11 +26,10 @@
 #include <asm/pal.h>
 #include <asm/tlbflush.h>
 #include <asm/dma.h>
+#include <asm/pgtable.h>
+#include <asm/tlb.h>
 
-static struct {
-	unsigned long mask;	/* mask of supported purge page-sizes */
-	unsigned long max_bits;	/* log2 of largest supported purge page-size */
-} purge;
+struct ia64_page_sizes_t ia64_page_sizes;
 
 struct ia64_ctx ia64_ctx = {
 	.lock =		SPIN_LOCK_UNLOCKED,
@@ -138,7 +137,6 @@
 		 unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long size = end - start;
 	unsigned long nbits;
 
 #ifndef CONFIG_SMP
@@ -148,12 +146,7 @@
 	}
 #endif
 
-	nbits = ia64_fls(size + 0xfff);
-	while (unlikely (((1UL << nbits) & purge.mask) == 0) &&
-			(nbits < purge.max_bits))
-		++nbits;
-	if (nbits > purge.max_bits)
-		nbits = purge.max_bits;
+	nbits = find_largest_page_size(end-start);
 	start &= ~((1UL << nbits) - 1);
 
 	preempt_disable();
@@ -173,19 +166,29 @@
 }
 EXPORT_SYMBOL(flush_tlb_range);
 
+/*
+ * We need this data early in the boot, so it gets called from
+ * setup_arch()
+ */
+void __devinit
+ia64_tlb_early_init (void)
+{
+        long status;
+        unsigned long tr_pgbits;
+
+	/* Setup valid page sizes for find_largest_page() */
+        if ((status = ia64_pal_vm_page_size(&tr_pgbits, &ia64_page_sizes.mask)) != 0) {
+                printk(KERN_ERR "PAL_VM_PAGE_SIZE failed with status=%ld;"
+                       "defaulting to architected purge page-sizes.\n", status);
+                ia64_page_sizes.mask = 0x115557000UL;
+        }
+        ia64_page_sizes.max_bits = ia64_fls(ia64_page_sizes.mask);
+}
+
 void __devinit
 ia64_tlb_init (void)
 {
 	ia64_ptce_info_t ptce_info;
-	unsigned long tr_pgbits;
-	long status;
-
-	if ((status = ia64_pal_vm_page_size(&tr_pgbits, &purge.mask)) != 0) {
-		printk(KERN_ERR "PAL_VM_PAGE_SIZE failed with status=%ld;"
-		       "defaulting to architected purge page-sizes.\n", status);
-		purge.mask = 0x115557000UL;
-	}
-	purge.max_bits = ia64_fls(purge.mask);
 
 	ia64_get_ptce(&ptce_info);
 	local_cpu_data->ptce_base = ptce_info.base;
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/include/asm-ia64/tlb.h
===================================================================
--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/include/asm-ia64/tlb.h	2006-05-03 17:11:43.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/include/asm-ia64/tlb.h	2006-05-10 09:04:39.000000000 +1000
@@ -200,6 +200,31 @@
 	tlb->end_addr = address + PAGE_SIZE;
 }
 
+/*
+ * Find an architecture suitable page size based big enough to map
+ * input size.  Return the number of bits; i.e. (1 << nbits) is the
+ * page size in bytes.
+ */
+struct ia64_page_sizes_t {
+	unsigned long mask;	/* mask of supported page-sizes */
+	unsigned long max_bits;	/* log2 of largest supported page-size */
+};
+
+ /* initalised in ia64_tlb_init() from EFI */
+extern struct ia64_page_sizes_t ia64_page_sizes;
+
+static inline unsigned long
+find_largest_page_size(unsigned long size)
+{
+	int nbits = ia64_fls(size + 0xfff);
+	while (unlikely (((1UL << nbits) & ia64_page_sizes.mask) == 0) &&
+			(nbits < ia64_page_sizes.max_bits))
+		++nbits;
+	if (nbits > ia64_page_sizes.max_bits)
+		nbits = ia64_page_sizes.max_bits;
+	return nbits;
+}
+
 #define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
 
 #define tlb_start_vma(tlb, vma)			do { } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
