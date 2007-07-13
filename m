From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 6/7] SPARC64: SPARSEMEM_VMEMMAP support
References: <exportbomb.1184333503@pinky>
Message-Id: <E1I9LL2-00009b-08@hellhawk.shadowen.org>
Date: Fri, 13 Jul 2007 14:37:40 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Hey Christoph, here is sparc64 support for this stuff.

After implementing this and seeing more and more how it works, I
really like it :-)

Thanks a lot for doing this work Christoph!

[apw@shadowen.org: style fixups]
From: David Miller <davem@davemloft.net>
Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/arch/sparc64/Kconfig b/arch/sparc64/Kconfig
index c73830d..9344dce 100644
--- a/arch/sparc64/Kconfig
+++ b/arch/sparc64/Kconfig
@@ -228,10 +228,17 @@ config ARCH_SPARSEMEM_ENABLE
 
 config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
-	select SPARSEMEM_STATIC
 
 source "mm/Kconfig"
 
+config SPARSEMEM_VMEMMAP
+	def_bool y
+	depends on SPARSEMEM
+
+config ARCH_POPULATES_SPARSEMEM_VMEMMAP
+	def_bool y
+	depends on SPARSEMEM_VMEMMAP
+
 config ISA
 	bool
 	help
diff --git a/arch/sparc64/kernel/ktlb.S b/arch/sparc64/kernel/ktlb.S
index d4024ac..964527d 100644
--- a/arch/sparc64/kernel/ktlb.S
+++ b/arch/sparc64/kernel/ktlb.S
@@ -226,6 +226,15 @@ kvmap_dtlb_load:
 	ba,pt		%xcc, sun4v_dtlb_load
 	 mov		%g5, %g3
 
+kvmap_vmemmap:
+	sub		%g4, %g5, %g5
+	srlx		%g5, 22, %g5
+	sethi		%hi(vmemmap_table), %g1
+	sllx		%g5, 3, %g5
+	or		%g1, %lo(vmemmap_table), %g1
+	ba,pt		%xcc, kvmap_dtlb_load
+	 ldx		[%g1 + %g5], %g5
+
 kvmap_dtlb_nonlinear:
 	/* Catch kernel NULL pointer derefs.  */
 	sethi		%hi(PAGE_SIZE), %g5
@@ -233,6 +242,13 @@ kvmap_dtlb_nonlinear:
 	bleu,pn		%xcc, kvmap_dtlb_longpath
 	 nop
 
+	/* Do not use the TSB for vmemmap.  */
+	mov		(VMEMMAP_BASE >> 24), %g5
+	sllx		%g5, 24, %g5
+	cmp		%g4,%g5
+	bgeu,pn		%xcc, kvmap_vmemmap
+	 nop
+
 	KERN_TSB_LOOKUP_TL1(%g4, %g6, %g5, %g1, %g2, %g3, kvmap_dtlb_load)
 
 kvmap_dtlb_tsbmiss:
diff --git a/arch/sparc64/mm/init.c b/arch/sparc64/mm/init.c
index 3010227..9bb6688 100644
--- a/arch/sparc64/mm/init.c
+++ b/arch/sparc64/mm/init.c
@@ -1647,6 +1647,58 @@ EXPORT_SYMBOL(_PAGE_E);
 unsigned long _PAGE_CACHE __read_mostly;
 EXPORT_SYMBOL(_PAGE_CACHE);
 
+#ifdef CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP
+
+#define VMEMMAP_CHUNK_SHIFT	22
+#define VMEMMAP_CHUNK		(1UL << VMEMMAP_CHUNK_SHIFT)
+#define VMEMMAP_CHUNK_MASK	~(VMEMMAP_CHUNK - 1UL)
+#define VMEMMAP_ALIGN(x)	(((x)+VMEMMAP_CHUNK-1UL)&VMEMMAP_CHUNK_MASK)
+
+#define VMEMMAP_SIZE	((((1UL << MAX_PHYSADDR_BITS) >> PAGE_SHIFT) * \
+			  sizeof(struct page *)) >> VMEMMAP_CHUNK_SHIFT)
+unsigned long vmemmap_table[VMEMMAP_SIZE];
+
+int __meminit vmemmap_populate(struct page *start, unsigned long nr, int node)
+{
+	unsigned long vstart = (unsigned long) start;
+	unsigned long vend = (unsigned long) (start + nr);
+	unsigned long phys_start = (vstart - VMEMMAP_BASE);
+	unsigned long phys_end = (vend - VMEMMAP_BASE);
+	unsigned long addr = phys_start & VMEMMAP_CHUNK_MASK;
+	unsigned long end = VMEMMAP_ALIGN(phys_end);
+	unsigned long pte_base;
+
+	pte_base = (_PAGE_VALID | _PAGE_SZ4MB_4U |
+		    _PAGE_CP_4U | _PAGE_CV_4U |
+		    _PAGE_P_4U | _PAGE_W_4U);
+	if (tlb_type == hypervisor)
+		pte_base = (_PAGE_VALID | _PAGE_SZ4MB_4V |
+			    _PAGE_CP_4V | _PAGE_CV_4V |
+			    _PAGE_P_4V | _PAGE_W_4V);
+
+	for (; addr < end; addr += VMEMMAP_CHUNK) {
+		unsigned long *vmem_pp =
+			vmemmap_table + (addr >> VMEMMAP_CHUNK_SHIFT);
+		void *block;
+
+		if (!(*vmem_pp & _PAGE_VALID)) {
+			block = vmemmap_alloc_block(1UL << 22, node);
+			if (!block)
+				return -ENOMEM;
+
+			*vmem_pp = pte_base | __pa(block);
+
+			printk(KERN_INFO "[%p-%p] page_structs=%lu "
+			       "node=%d entry=%lu/%lu\n", start, block, nr,
+			       node,
+			       addr >> VMEMMAP_CHUNK_SHIFT,
+			       VMEMMAP_SIZE >> VMEMMAP_CHUNK_SHIFT);
+		}
+	}
+	return 0;
+}
+#endif /* CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP */
+
 static void prot_init_common(unsigned long page_none,
 			     unsigned long page_shared,
 			     unsigned long page_copy,
diff --git a/include/asm-sparc64/pgtable.h b/include/asm-sparc64/pgtable.h
index 0393380..3167ccf 100644
--- a/include/asm-sparc64/pgtable.h
+++ b/include/asm-sparc64/pgtable.h
@@ -42,6 +42,9 @@
 #define HI_OBP_ADDRESS		_AC(0x0000000100000000,UL)
 #define VMALLOC_START		_AC(0x0000000100000000,UL)
 #define VMALLOC_END		_AC(0x0000000200000000,UL)
+#define VMEMMAP_BASE		_AC(0x0000000200000000,UL)
+
+#define vmemmap			((struct page *)VMEMMAP_BASE)
 
 /* XXX All of this needs to be rethought so we can take advantage
  * XXX cheetah's full 64-bit virtual address space, ie. no more hole

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
