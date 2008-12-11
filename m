Return-Path: <linux-kernel-owner+w=401wt.eu-S1757226AbYLKTGS@vger.kernel.org>
Message-ID: <49416494.6040009@goop.org>
Date: Thu, 11 Dec 2008 11:05:56 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Hi Nick,

In Xen when we're killing the lazy vmalloc aliases, we're only concerned 
about the pagetable references to the mapped pages, not the TLB entries. 
For the most part eliminating the TLB flushes would be a performance 
optimisation, but there's at least one case where we need to shoot down 
aliases in an interrupt-disabled section, so the TLB shootdown IPIs 
would potentially deadlock.

I'm wondering what your thoughts are about this approach?

I'm not super-happy with the changes to __purge_vmap_area_lazy(), but 
given that we need a tri-state policy selection there, adding an enum is 
clearer than adding another boolean argument.

It also raises the question of how many callers of vm_unmap_aliases() 
really care about flushing the tlbs. Presumably if we're shooting down 
some stray vmalloc mappings then nobody is actually using them at the 
time, and any corresponding TLB entries are residual. Or does leaving 
them around leave open the possibility of unwanted speculative 
references which could violate memory type rules?  Perhaps callers who 
care about that could arrange their own tlb flush?

Thanks,
    J

===================================================================
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -41,6 +41,7 @@
 extern void *vm_map_ram(struct page **pages, unsigned int count,
 				int node, pgprot_t prot);
 extern void vm_unmap_aliases(void);
+extern void __vm_unmap_aliases(int allow_flush);
 
 #ifdef CONFIG_MMU
 extern void __init vmalloc_init(void);
===================================================================
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -458,18 +458,26 @@
 
 static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
 
+enum purge_flush {
+	PURGE_FLUSH_NEVER,
+	PURGE_FLUSH_IF_NEEDED,
+	PURGE_FLUSH_FORCE
+};
+
 /*
  * Purges all lazily-freed vmap areas.
  *
  * If sync is 0 then don't purge if there is already a purge in progress.
- * If force_flush is 1, then flush kernel TLBs between *start and *end even
- * if we found no lazy vmap areas to unmap (callers can use this to optimise
- * their own TLB flushing).
+ * 'flush' sets the TLB flushing policy between *start and *end:
+ *    PURGE_FLUSH_NEVER     caller doesn't care about TLB state, so don't flush
+ *    PURGE_FLUSH_IF_NEEDED flush if we found a lazy vmap area to unmap
+ *    PURGE_FLUSH_FORCE     always flush, to allow callers to optimise their own flushing
+ *
  * Returns with *start = min(*start, lowest purged address)
  *              *end = max(*end, highest purged address)
  */
 static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
-					int sync, int force_flush)
+				   int sync, enum purge_flush flush)
 {
 	static DEFINE_SPINLOCK(purge_lock);
 	LIST_HEAD(valist);
@@ -481,7 +489,7 @@
 	 * should not expect such behaviour. This just simplifies locking for
 	 * the case that isn't actually used at the moment anyway.
 	 */
-	if (!sync && !force_flush) {
+	if (!sync && flush != PURGE_FLUSH_FORCE) {
 		if (!spin_trylock(&purge_lock))
 			return;
 	} else
@@ -508,7 +516,7 @@
 		atomic_sub(nr, &vmap_lazy_nr);
 	}
 
-	if (nr || force_flush)
+	if ((nr && flush == PURGE_FLUSH_IF_NEEDED) || flush == PURGE_FLUSH_FORCE)
 		flush_tlb_kernel_range(*start, *end);
 
 	if (nr) {
@@ -528,7 +536,7 @@
 {
 	unsigned long start = ULONG_MAX, end = 0;
 
-	__purge_vmap_area_lazy(&start, &end, 0, 0);
+	__purge_vmap_area_lazy(&start, &end, 0, PURGE_FLUSH_IF_NEEDED);
 }
 
 /*
@@ -538,7 +546,7 @@
 {
 	unsigned long start = ULONG_MAX, end = 0;
 
-	__purge_vmap_area_lazy(&start, &end, 1, 0);
+	__purge_vmap_area_lazy(&start, &end, 1, PURGE_FLUSH_IF_NEEDED);
 }
 
 /*
@@ -847,11 +855,11 @@
  * be sure that none of the pages we have control over will have any aliases
  * from the vmap layer.
  */
-void vm_unmap_aliases(void)
+void __vm_unmap_aliases(int allow_flush)
 {
 	unsigned long start = ULONG_MAX, end = 0;
 	int cpu;
-	int flush = 0;
+	enum purge_flush flush = PURGE_FLUSH_IF_NEEDED;
 
 	if (unlikely(!vmap_initialized))
 		return;
@@ -875,7 +883,7 @@
 				s = vb->va->va_start + (i << PAGE_SHIFT);
 				e = vb->va->va_start + (j << PAGE_SHIFT);
 				vunmap_page_range(s, e);
-				flush = 1;
+				flush = PURGE_FLUSH_FORCE;
 
 				if (s < start)
 					start = s;
@@ -891,7 +899,13 @@
 		rcu_read_unlock();
 	}
 
-	__purge_vmap_area_lazy(&start, &end, 1, flush);
+	__purge_vmap_area_lazy(&start, &end, 1,
+			       allow_flush ? flush : PURGE_FLUSH_NEVER);
+}
+
+void vm_unmap_aliases(void)
+{
+	__vm_unmap_aliases(1);
 }
 EXPORT_SYMBOL_GPL(vm_unmap_aliases);
 
