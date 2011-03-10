Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1A0B28D003A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 16:26:32 -0500 (EST)
Message-Id: <201103102125.p2ALPupL017020@farm-0012.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 10 Mar 2011 13:05:14 -0500
Subject: [PATCH] arch/tile: optimize icache flush
In-Reply-To: <4D6FCE5D.4030904@tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: a.p.zijlstra@chello.nl, torvalds@linux-foundation.org, aarcange@redhat.com, tglx@linutronix.de, riel@redhat.com, mingo@elte.hu, akpm@linux-foundation.org, "David Miller <davem@davemloft.net>" <linux-arch@vger.kernel.org>, linux-mm@kvack.org, benh@kernel.crashing.org, hugh.dickins@tiscali.co.uk, mel@csn.ul.ie, npiggin@kernel.dk, rmk@arm.linux.org.uk, schwidefsky@de.ibm.com

Tile has incoherent icaches, so they must be explicitly invalidated
when necessary.  Until now we have done so at tlb flush and context
switch time, which means more invalidation than strictly necessary.
The new model for icache flush is:

- When we fault in a page as executable, we set an "Exec" bit in the
  "struct page" information; the bit stays set until page free time.
  (We use the arch_1 page bit for our "Exec" bit.)

- At page free time, if the Exec bit is set, we do an icache flush.
  This should happen relatively rarely: e.g., deleting a binary from disk,
  or evicting a binary's pages from the page cache due to memory pressure.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---

This change was motivated initially by Peter Zijlstra's attempt to
handle tlb_flush_range() without the vm_flags.  Since we no longer do I$
flushing at TLB flush time, this is arguably a step in that direction,
though in practice Peter gave up and is now passing the vm_flags anyway.

This change is also much simpler than the one I proposed a few days ago:

https://lkml.org/lkml/2011/3/3/284

since I decided that it would be overkill to track page free times in
the struct page and compare it as part of this.

Note that Tilera's shipping sources have support for some amortizing
code that collects freed pages on a separate list if they need any kind
of special cache-management attention, so in that code we are deferring
the icache frees until even later.  This code involves enough hooks into
the platform-independent kernel mm sources that I haven't tried to push
it back to the community yet; it's basically performance optimization
code for our architecture.

 arch/tile/include/asm/page.h    |    3 +++
 arch/tile/include/asm/pgtable.h |   18 +++++++++++++-----
 arch/tile/kernel/module.c       |    1 +
 arch/tile/kernel/tlb.c          |   24 ++++++------------------
 arch/tile/mm/homecache.c        |   14 ++++++++++++++
 arch/tile/mm/init.c             |    4 ++++
 6 files changed, 41 insertions(+), 23 deletions(-)

diff --git a/arch/tile/include/asm/page.h b/arch/tile/include/asm/page.h
index 3eb5352..24e0f8c 100644
--- a/arch/tile/include/asm/page.h
+++ b/arch/tile/include/asm/page.h
@@ -324,6 +324,9 @@ static inline int pfn_valid(unsigned long pfn)
 struct mm_struct;
 extern pte_t *virt_to_pte(struct mm_struct *mm, unsigned long addr);
 
+void arch_free_page(struct page *page, int order);
+#define HAVE_ARCH_FREE_PAGE
+
 #endif /* !__ASSEMBLY__ */
 
 #define VM_DATA_DEFAULT_FLAGS \
diff --git a/arch/tile/include/asm/pgtable.h b/arch/tile/include/asm/pgtable.h
index 1a20b7e..39a2c3d 100644
--- a/arch/tile/include/asm/pgtable.h
+++ b/arch/tile/include/asm/pgtable.h
@@ -27,6 +27,7 @@
 #include <linux/slab.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
+#include <linux/page-flags.h>
 #include <asm/processor.h>
 #include <asm/fixmap.h>
 #include <asm/system.h>
@@ -351,11 +352,18 @@ do {						\
 	local_flush_tlb_page(FLUSH_NONEXEC, (vaddr), PAGE_SIZE); \
 } while (0)
 
-/*
- * The kernel page tables contain what we need, and we flush when we
- * change specific page table entries.
- */
-#define update_mmu_cache(vma, address, pte) do { } while (0)
+/* Use this bit to track whether a page may have been cached in an icache. */
+PAGEFLAG(Exec, arch_1)
+__TESTCLEARFLAG(Exec, arch_1)
+
+static inline void update_mmu_cache(struct vm_area_struct *vma,
+				    unsigned long address,
+				    pte_t *pte)
+{
+	pte_t pteval = *pte;
+	if (pte_exec(pteval))
+		SetPageExec(pte_page(pteval));
+}
 
 #ifdef CONFIG_FLATMEM
 #define kern_addr_valid(addr)	(1)
diff --git a/arch/tile/kernel/module.c b/arch/tile/kernel/module.c
index e2ab82b..37615b3 100644
--- a/arch/tile/kernel/module.c
+++ b/arch/tile/kernel/module.c
@@ -61,6 +61,7 @@ void *module_alloc(unsigned long size)
 		pages[i] = alloc_page(GFP_KERNEL | __GFP_HIGHMEM);
 		if (!pages[i])
 			goto error;
+		SetPageExec(pages[i]);   /* do icache flush when we free */
 	}
 
 	area = __get_vm_area(size, VM_ALLOC, MEM_MODULE_START, MEM_MODULE_END);
diff --git a/arch/tile/kernel/tlb.c b/arch/tile/kernel/tlb.c
index 2dffc10..e8b9062 100644
--- a/arch/tile/kernel/tlb.c
+++ b/arch/tile/kernel/tlb.c
@@ -23,13 +23,6 @@
 DEFINE_PER_CPU(int, current_asid);
 int min_asid, max_asid;
 
-/*
- * Note that we flush the L1I (for VM_EXEC pages) as well as the TLB
- * so that when we are unmapping an executable page, we also flush it.
- * Combined with flushing the L1I at context switch time, this means
- * we don't have to do any other icache flushes.
- */
-
 void flush_tlb_mm(struct mm_struct *mm)
 {
 	HV_Remote_ASID asids[NR_CPUS];
@@ -40,8 +33,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 		asid->x = cpu % smp_topology.width;
 		asid->asid = per_cpu(current_asid, cpu);
 	}
-	flush_remote(0, HV_FLUSH_EVICT_L1I, &mm->cpu_vm_mask,
-		     0, 0, 0, NULL, asids, i);
+	flush_remote(0, 0, NULL, 0, 0, 0, NULL, asids, i);
 }
 
 void flush_tlb_current_task(void)
@@ -53,9 +45,7 @@ void flush_tlb_page_mm(const struct vm_area_struct *vma, struct mm_struct *mm,
 		       unsigned long va)
 {
 	unsigned long size = hv_page_size(vma);
-	int cache = (vma->vm_flags & VM_EXEC) ? HV_FLUSH_EVICT_L1I : 0;
-	flush_remote(0, cache, &mm->cpu_vm_mask,
-		     va, size, size, &mm->cpu_vm_mask, NULL, 0);
+	flush_remote(0, 0, NULL, va, size, size, &mm->cpu_vm_mask, NULL, 0);
 }
 
 void flush_tlb_page(const struct vm_area_struct *vma, unsigned long va)
@@ -68,10 +58,8 @@ void flush_tlb_range(const struct vm_area_struct *vma,
 		     unsigned long start, unsigned long end)
 {
 	unsigned long size = hv_page_size(vma);
-	struct mm_struct *mm = vma->vm_mm;
-	int cache = (vma->vm_flags & VM_EXEC) ? HV_FLUSH_EVICT_L1I : 0;
-	flush_remote(0, cache, &mm->cpu_vm_mask, start, end - start, size,
-		     &mm->cpu_vm_mask, NULL, 0);
+	flush_remote(0, 0, NULL, start, end - start, size,
+		     &vma->vm_mm->cpu_vm_mask, NULL, 0);
 }
 
 void flush_tlb_all(void)
@@ -81,7 +69,7 @@ void flush_tlb_all(void)
 		HV_VirtAddrRange r = hv_inquire_virtual(i);
 		if (r.size == 0)
 			break;
-		flush_remote(0, HV_FLUSH_EVICT_L1I, cpu_online_mask,
+		flush_remote(0, 0, NULL,
 			     r.start, r.size, PAGE_SIZE, cpu_online_mask,
 			     NULL, 0);
 		flush_remote(0, 0, NULL,
@@ -92,6 +80,6 @@ void flush_tlb_all(void)
 
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)
 {
-	flush_remote(0, HV_FLUSH_EVICT_L1I, cpu_online_mask,
+	flush_remote(0, 0, NULL,
 		     start, end - start, PAGE_SIZE, cpu_online_mask, NULL, 0);
 }
diff --git a/arch/tile/mm/homecache.c b/arch/tile/mm/homecache.c
index cbe6f4f..e020b54 100644
--- a/arch/tile/mm/homecache.c
+++ b/arch/tile/mm/homecache.c
@@ -455,3 +455,17 @@ void homecache_free_pages(unsigned long addr, unsigned int order)
 			__free_page(page++);
 	}
 }
+
+/*
+ * When freeing a page that was executable, we flush all icaches to
+ * avoid incoherence.  This should be relatively rare, e.g. deleting a
+ * binary or evicting an executable page-cache page.  Enabling dynamic
+ * homecaching support amortizes this overhead even further.
+ */
+void arch_free_page(struct page *page, int order)
+{
+	if (__TestClearPageExec(page)) {
+		flush_remote(0, HV_FLUSH_EVICT_L1I, cpu_online_mask,
+			     0, 0, 0, NULL, NULL, 0);
+	}
+}
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index d6e87fd..6332347 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -1082,4 +1082,8 @@ void free_initmem(void)
 
 	/* Do a global TLB flush so everyone sees the changes. */
 	flush_tlb_all();
+
+	/* Do a global L1I flush now that we've freed kernel text. */
+	flush_remote(0, HV_FLUSH_EVICT_L1I, cpu_online_mask,
+		     0, 0, 0, NULL, NULL, 0);
 }
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
