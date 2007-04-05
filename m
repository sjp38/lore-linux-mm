Date: Thu, 05 Apr 2007 14:29:00 -0700 (PDT)
Message-Id: <20070405.142900.59466568.davem@davemloft.net>
Subject: Re: [PATCH 1/4] Generic Virtual Memmap suport for SPARSEMEM V3
From: David Miller <davem@davemloft.net>
In-Reply-To: <20070404230619.20292.4475.sendpatchset@schroedinger.engr.sgi.com>
References: <20070404230619.20292.4475.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Wed,  4 Apr 2007 16:06:19 -0700 (PDT)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@google.com, linux-mm@kvack.org, ak@suse.de, hansendc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> Sparse Virtual: Virtual Memmap support for SPARSEMEM V4
> 
> V1->V3
>  - Add IA64 16M vmemmap size support (reduces TLB pressure)
>  - Add function to test for eventual node/node vmemmap overlaps
>  - Upper / Lower boundary fix.

Hey Christoph, here is sparc64 support for this stuff.

After implementing this and seeing more and more how it works, I
really like it :-)

Thanks a lot for doing this work Christoph!

diff --git a/arch/sparc64/Kconfig b/arch/sparc64/Kconfig
index 1a6348b..4da8012 100644
--- a/arch/sparc64/Kconfig
+++ b/arch/sparc64/Kconfig
@@ -215,6 +215,12 @@ config ARCH_SPARSEMEM_ENABLE
 config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
 
+config SPARSE_VIRTUAL
+	def_bool y
+
+config ARCH_POPULATES_VIRTUAL_MEMMAP
+	def_bool y
+
 config LARGE_ALLOCS
 	def_bool y
 
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
index f146071..9b73933 100644
--- a/arch/sparc64/mm/init.c
+++ b/arch/sparc64/mm/init.c
@@ -1687,6 +1687,56 @@ EXPORT_SYMBOL(_PAGE_E);
 unsigned long _PAGE_CACHE __read_mostly;
 EXPORT_SYMBOL(_PAGE_CACHE);
 
+#define VMEMMAP_CHUNK_SHIFT	22
+#define VMEMMAP_CHUNK		(1UL << VMEMMAP_CHUNK_SHIFT)
+#define VMEMMAP_CHUNK_MASK	~(VMEMMAP_CHUNK - 1UL)
+#define VMEMMAP_ALIGN(x)	(((x)+VMEMMAP_CHUNK-1UL)&VMEMMAP_CHUNK_MASK)
+
+#define VMEMMAP_SIZE	((((1UL << MAX_PHYSADDR_BITS) >> PAGE_SHIFT) * \
+			  sizeof(struct page *)) >> VMEMMAP_CHUNK_SHIFT)
+unsigned long vmemmap_table[VMEMMAP_SIZE];
+
+int vmemmap_populate(struct page *start, unsigned long nr, int node)
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
+	for(; addr < end; addr += VMEMMAP_CHUNK) {
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
+
+
 static void prot_init_common(unsigned long page_none,
 			     unsigned long page_shared,
 			     unsigned long page_copy,
diff --git a/include/asm-sparc64/page.h b/include/asm-sparc64/page.h
index ff736ea..f1f1a58 100644
--- a/include/asm-sparc64/page.h
+++ b/include/asm-sparc64/page.h
@@ -22,6 +22,9 @@
 #define PAGE_SIZE    (_AC(1,UL) << PAGE_SHIFT)
 #define PAGE_MASK    (~(PAGE_SIZE-1))
 
+#define VMEMMAP_BASE		_AC(0x0000000200000000,UL)
+#define vmemmap			((struct page *)VMEMMAP_BASE)
+
 /* Flushing for D-cache alias handling is only needed if
  * the page size is smaller than 16K.
  */
diff --git a/include/asm-sparc64/pgtable.h b/include/asm-sparc64/pgtable.h
index b12be7a..9cbd149 100644
--- a/include/asm-sparc64/pgtable.h
+++ b/include/asm-sparc64/pgtable.h
@@ -42,6 +42,9 @@
 #define HI_OBP_ADDRESS		_AC(0x0000000100000000,UL)
 #define VMALLOC_START		_AC(0x0000000100000000,UL)
 #define VMALLOC_END		_AC(0x0000000200000000,UL)
+/* see asm-sparc64/page.h for VMEMMAP_BASE which sits right
+ * at VMALLOC_END
+ */
 
 /* XXX All of this needs to be rethought so we can take advantage
  * XXX cheetah's full 64-bit virtual address space, ie. no more hole

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
