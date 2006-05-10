From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 10 May 2006 13:42:38 +1000
Message-Id: <20060510034238.17792.43267.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060510034206.17792.82504.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
References: <20060510034206.17792.82504.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
Subject: [RFC 6/6] LVHPT - long format support functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org, Ian Wienand <ianw@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

LVHPT support

Functions for dealing with LVHPT flushing and miscellaneous other
control functions.

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

---

 arch/ia64/mm/tlb.c             |   46 +++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/mmu_context.h |   21 +++++++++++++++++-
 include/asm-ia64/page.h        |    5 ++++
 include/asm-ia64/tlb.h         |    2 +
 include/asm-ia64/tlbflush.h    |   24 +++++++++++++++++++++
 5 files changed, 97 insertions(+), 1 deletion(-)

Index: linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/mm/tlb.c
===================================================================
--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/arch/ia64/mm/tlb.c	2006-05-10 10:31:53.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/arch/ia64/mm/tlb.c	2006-05-10 10:38:33.000000000 +1000
@@ -114,6 +114,17 @@
 {
 	unsigned long i, j, flags, count0, count1, stride0, stride1, addr;
 
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	unsigned long page;
+
+	/* Admittedly 0 is a valid tag, but in that rare case the
+	 * present bit will save us */
+	for (page = LONG_VHPT_BASE;
+	     page < LONG_VHPT_BASE + lvhpt_size(smp_processor_id());
+	     page += PAGE_SIZE)
+		clear_page((void *)page);
+#endif
+
 	addr    = local_cpu_data->ptce_base;
 	count0  = local_cpu_data->ptce_count[0];
 	count1  = local_cpu_data->ptce_count[1];
@@ -132,6 +143,37 @@
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 }
 
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+static void
+flush_vhpt_range (struct mm_struct *mm, unsigned long from, unsigned long to)
+{
+	unsigned long addr;
+
+	for (addr = from; addr < to; addr += PAGE_SIZE)
+ 		flush_vhpt_page(addr);
+
+#ifdef CONFIG_SMP
+	{
+ 		/* Urgh... flush VHPTs of any other CPUs that have run this mm */
+ 		unsigned long offset;
+ 		long_pte_t *hpte;
+ 		int cpu;
+
+ 		for_each_cpu_mask(cpu, mm->cpu_vm_mask)
+ 		{
+ 			for (addr = from; addr < to; addr += PAGE_SIZE)
+ 			{
+ 				offset = ia64_thash(addr) & (lvhpt_size(cpu)-1);
+ 				hpte = (long_pte_t *)(lvhpt_per_cpu_info[cpu].base + offset);
+ 				hpte->tag = INVALID_TAG;
+ 			}
+ 		}
+ 	}
+#endif
+ }
+#endif /* CONFIG_IA64_LONG_FORMAT_VHPT */
+
+
 void
 flush_tlb_range (struct vm_area_struct *vma, unsigned long start,
 		 unsigned long end)
@@ -146,6 +188,10 @@
 	}
 #endif
 
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	flush_vhpt_range(mm, start, end);
+#endif
+
 	nbits = find_largest_page_size(end-start);
 	start &= ~((1UL << nbits) - 1);
 
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/include/asm-ia64/mmu_context.h
===================================================================
--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/include/asm-ia64/mmu_context.h	2006-05-10 10:31:53.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/include/asm-ia64/mmu_context.h	2006-05-10 10:38:33.000000000 +1000
@@ -18,7 +18,21 @@
 
 #define IA64_REGION_ID_KERNEL	0 /* the kernel's region id (tlb.c depends on this being 0) */
 
-#define ia64_rid(ctx,addr)	(((ctx) << 3) | (addr >> 61))
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+/*
+ * Due to a high number of collisions in the long format VHPT walker hash function
+ * when RIDs and similar address space layout occur "eg. fork()". The following is
+ * used to space out the RIDs we present to the hardware without messing with Linux's
+ * sequential allocation scheme.
+ * Refer to 'Intel Itanium Processor Reference Manual for Software Development'
+ * http://www.intel.com/design/itanium/manuals.htm
+ */
+#define redistribute_rid(rid)	(((rid) & ~0xffff) | (((rid) << 8) & 0xff00) | (((rid) >> 8) & 0xff))
+#else
+#define redistribute_rid(rid)	(rid)
+#endif
+
+#define ia64_rid(ctx,addr)	redistribute_rid(((ctx) << 3) | (addr >> 61))
 
 # include <asm/page.h>
 # ifndef __ASSEMBLY__
@@ -135,7 +149,12 @@
 
 	old_rr4 = ia64_get_rr(RGN_BASE(RGN_HPAGE));
 	rid = context << 3;	/* make space for encoding the region number */
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	rid = redistribute_rid(rid);
+	rid_incr = 1 << 16;
+#else
 	rid_incr = 1 << 8;
+#endif
 
 	/* encode the region id, preferred page size, and VHPT enable bit: */
 	rr0 = (rid << 8) | (PAGE_SHIFT << 2) | 1;
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/include/asm-ia64/page.h
===================================================================
--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/include/asm-ia64/page.h	2006-05-10 10:31:53.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/include/asm-ia64/page.h	2006-05-10 10:38:33.000000000 +1000
@@ -175,6 +175,11 @@
 	return order;
 }
 
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+/* Long format VHPT entry */
+typedef struct { unsigned long pte, itir, tag, ig; } long_pte_t;
+#endif
+
 # endif /* __KERNEL__ */
 #endif /* !__ASSEMBLY__ */
 
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/include/asm-ia64/tlbflush.h
===================================================================
--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/include/asm-ia64/tlbflush.h	2006-05-10 10:31:53.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/include/asm-ia64/tlbflush.h	2006-05-10 10:38:33.000000000 +1000
@@ -19,6 +19,21 @@
  * can be very expensive, so try to avoid them whenever possible.
  */
 
+/* Flushing a translation from the long format VHPT */
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+# define INVALID_TAG (1UL << 63)
+
+static inline void
+flush_vhpt_page(unsigned long addr)
+{
+	long_pte_t *hpte;
+	hpte = (long_pte_t *)ia64_thash(addr);
+	hpte->tag = INVALID_TAG;
+}
+#else
+# define flush_vhpt_page(addr)	do { } while (0)
+#endif
+
 /*
  * Flush everything (kernel mapping may also have changed due to
  * vmalloc/vfree).
@@ -54,6 +69,12 @@
 	set_bit(mm->context, ia64_ctx.flushmap);
 	mm->context = 0;
 
+	/* XXX smp_flush_tlb_mm actually enables and disables preempt
+	 * ... maybe we should refactor all this
+	 */
+	cpu_clear(get_cpu(), mm->cpu_vm_mask);
+	put_cpu();
+
 	if (atomic_read(&mm->mm_users) == 0)
 		return;		/* happens as a result of exit_mmap() */
 
@@ -76,7 +97,10 @@
 	flush_tlb_range(vma, (addr & PAGE_MASK), (addr & PAGE_MASK) + PAGE_SIZE);
 #else
 	if (vma->vm_mm == current->active_mm)
+	{
+		flush_vhpt_page(addr);
 		ia64_ptcl(addr, (PAGE_SHIFT << 2));
+	}
 	else
 		vma->vm_mm->context = 0;
 #endif
Index: linux-2.6.17-rc3-lvhpt-v2-fresh/include/asm-ia64/tlb.h
===================================================================
--- linux-2.6.17-rc3-lvhpt-v2-fresh.orig/include/asm-ia64/tlb.h	2006-05-10 10:31:53.000000000 +1000
+++ linux-2.6.17-rc3-lvhpt-v2-fresh/include/asm-ia64/tlb.h	2006-05-10 10:38:33.000000000 +1000
@@ -107,8 +107,10 @@
 		vma.vm_mm = tlb->mm;
 		/* flush the address range from the tlb: */
 		flush_tlb_range(&vma, start, end);
+#ifndef CONFIG_IA64_LONG_FORMAT_VHPT
 		/* now flush the virt. page-table area mapping the address range: */
 		flush_tlb_range(&vma, ia64_thash(start), ia64_thash(end));
+#endif
 	}
 
 	/* lastly, release the freed pages */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
