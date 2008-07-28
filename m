Date: Mon, 28 Jul 2008 14:34:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 1/3] mm: vmap rewrite
Message-ID: <20080728123438.GA13926@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com, xen-devel@lists.xensource.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, dri-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi all,

I plan to submit my vmap rewrite to -mm. Although I am not planning to submit
fsblock to be merged, I figure that at least XFS wants a fast, scalable vmap
in some configurations. Others may want as well (didn't look too hard, but
the DRM subsystem needs or will need much better performance so I have heard).
And yet others might discover interesting new ways to use a sanely performing
vmap.

The code is in reasonable shape (aside from checkpatch 80 column vomit), so
I figure it is better to submit this rather than let it rot.

Comments?

--
Rewrite the vmap allocator to use rbtrees and lazy tlb flushing, and provide a
fast, scalable percpu frontend for small vmaps (requires a slightly different
API, though).

The biggest problem with vmap is actually vunmap. Presently this requires
a global kernel TLB flush, which on most architectures is a broadcast IPI
to all CPUs to flush the cache. This is all done under a global lock. As
the number of CPUs increases, so will the number of vunmaps a scaled workload
will want to perform, and so will the cost of a global TLB flush. This gives
terrible quadratic scalability characteristics.

Another problem is that the entire vmap subsystem works under a single
lock. It is a rwlock, but it is actually taken for write in all the fast
paths, and the read locking would likely never be run concurrently anyway,
so it's just pointless.

This is a rewrite of vmap subsystem to solve those problems. The existing
vmalloc API is implemented on top of the rewritten subsystem.

The TLB flushing problem is solved by using lazy TLB unmapping. vmap
addresses do not have to be flushed immediately when they are vunmapped,
because the kernel will not reuse them again (would be a use-after-free)
until they are reallocated. So the addresses aren't allocated again until 
a subsequent TLB flush. A single TLB flush then can flush multiple vunmaps
from each CPU.

XEN and PAT and such do not like deferred TLB flushing because they can't
always handle multiple aliasing virtual addresses to a physical address. They
now call vm_unmap_aliases() in order to flush any deferred mappings.  That call
is very expensive (well, actually not a lot more expensive than a single vunmap
under the old scheme), however it should be OK if not called too often.

The virtual memory extent information is stored in an rbtree rather than a
linked list to improve the algorithmic scalability.

There is a per-CPU allocator for small vmaps, which amortizes or avoids global
locking.

To use the per-CPU interface, the vm_map_ram / vm_unmap_ram interfaces must
be used in place of vmap and vunmap. Vmalloc does not use these interfaces
at the moment, so it will not be quite so scalable (although it will use
lazy TLB flushing).

As a quick test of performance, I ran a test that loops in the kernel,
linearly mapping then touching then unmapping 4 pages. Different numbers of
tests were run in parallel on an 4 core, 2 socket opteron. Results are in
nanoseconds per map+touch+unmap.

threads           vanilla         vmap rewrite
1                 14700           2900
2                 33600           3000
4                 49500           2800
8                 70631           2900

So with a 8 cores, the rewritten version is already 25x faster.

In a slightly more realistic test (although with an older and less scalable
version of the patch), I ripped the not-very-good vunmap batching code out of
XFS, and implemented the large buffer mapping with vm_map_ram and
vm_unmap_ram... along with a couple of other tricks, I was able to speed up a
large directory workload by 20x on a 64 CPU system. I believe vmap/vunmap is
actually sped up a lot more than 20x on such a system, but I'm running into
other locks now. vmap is pretty well blown off the profiles.

Before:
1352059 total                                      0.1401
798784 _write_lock                              8320.6667 <- vmlist_lock
529313 default_idle                             1181.5022
 15242 smp_call_function                         15.8771  <- vmap tlb flushing
  2472 __get_vm_area_node                         1.9312  <- vmap
  1762 remove_vm_area                             4.5885  <- vunmap
   316 map_vm_area                                0.2297  <- vmap
   312 kfree                                      0.1950
   300 _spin_lock                                 3.1250
   252 sn_send_IPI_phys                           0.4375  <- tlb flushing
   238 vmap                                       0.8264  <- vmap
   216 find_lock_page                             0.5192
   196 find_next_bit                              0.3603
   136 sn2_send_IPI                               0.2024
   130 pio_phys_write_mmr                         2.0312
   118 unmap_kernel_range                         0.1229

After:
 78406 total                                      0.0081
 40053 default_idle                              89.4040
 33576 ia64_spinlock_contention                 349.7500 
  1650 _spin_lock                                17.1875
   319 __reg_op                                   0.5538
   281 _atomic_dec_and_lock                       1.0977
   153 mutex_unlock                               1.5938
   123 iget_locked                                0.1671
   117 xfs_dir_lookup                             0.1662
   117 dput                                       0.1406
   114 xfs_iget_core                              0.0268
    92 xfs_da_hashname                            0.1917
    75 d_alloc                                    0.0670
    68 vmap_page_range                            0.0462 <- vmap
    58 kmem_cache_alloc                           0.0604
    57 memset                                     0.0540
    52 rb_next                                    0.1625
    50 __copy_user                                0.0208
    49 bitmap_find_free_region                    0.2188 <- vmap
    46 ia64_sn_udelay                             0.1106
    45 find_inode_fast                            0.1406
    42 memcmp                                     0.2188
    42 finish_task_switch                         0.1094
    42 __d_lookup                                 0.0410
    40 radix_tree_lookup_slot                     0.1250
    37 _spin_unlock_irqrestore                    0.3854
    36 xfs_bmapi                                  0.0050
    36 kmem_cache_free                            0.0256
    35 xfs_vn_getattr                             0.0322
    34 radix_tree_lookup                          0.1062
    33 __link_path_walk                           0.0035
    31 xfs_da_do_buf                              0.0091
    30 _xfs_buf_find                              0.0204
    28 find_get_page                              0.0875
    27 xfs_iread                                  0.0241
    27 __strncpy_from_user                        0.2812
    26 _xfs_buf_initialize                        0.0406
    24 _xfs_buf_lookup_pages                      0.0179
    24 vunmap_page_range                          0.0250 <- vunmap
    23 find_lock_page                             0.0799
    22 vm_map_ram                                 0.0087 <- vmap
    20 kfree                                      0.0125
    19 put_page                                   0.0330
    18 __kmalloc                                  0.0176
    17 xfs_da_node_lookup_int                     0.0086
    17 _read_lock                                 0.0885
    17 page_waitqueue                             0.0664

vmap has gone from being the top 5 on the profiles and flushing the
crap out of all TLBs, to using less than 1% of kernel time. Who ever
said vmap is unsuitable to implement large block support? :)

---

This work is a basic requirement for my large block support in fsblock,
although I will also be using other techniques such as page-at-a-time
algorithms and atomic mappings to further reduce the reliance on vmap.
Basically, when those techniques are used, I anticipate vmap to basically
be almost unused anyway, however this is going to help transition...

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -8,6 +8,7 @@
  *  Numa awareness, Christoph Lameter, SGI, June 2005
  */
 
+#include <linux/vmalloc.h>
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/highmem.h>
@@ -18,16 +19,17 @@
 #include <linux/debugobjects.h>
 #include <linux/vmalloc.h>
 #include <linux/kallsyms.h>
+#include <linux/list.h>
+#include <linux/rbtree.h>
+#include <linux/radix-tree.h>
+#include <linux/rcupdate.h>
 
+#include <asm/atomic.h>
 #include <asm/uaccess.h>
 #include <asm/tlbflush.h>
 
 
-DEFINE_RWLOCK(vmlist_lock);
-struct vm_struct *vmlist;
-
-static void *__vmalloc_node(unsigned long size, gfp_t gfp_mask, pgprot_t prot,
-			    int node, void *caller);
+/*** Page table manipulation functions ***/
 
 static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end)
 {
@@ -40,8 +42,7 @@ static void vunmap_pte_range(pmd_t *pmd,
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 }
 
-static inline void vunmap_pmd_range(pud_t *pud, unsigned long addr,
-						unsigned long end)
+static void vunmap_pmd_range(pud_t *pud, unsigned long addr, unsigned long end)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -55,8 +56,7 @@ static inline void vunmap_pmd_range(pud_
 	} while (pmd++, addr = next, addr != end);
 }
 
-static inline void vunmap_pud_range(pgd_t *pgd, unsigned long addr,
-						unsigned long end)
+static void vunmap_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -70,12 +70,10 @@ static inline void vunmap_pud_range(pgd_
 	} while (pud++, addr = next, addr != end);
 }
 
-void unmap_kernel_range(unsigned long addr, unsigned long size)
+static void vunmap_page_range(unsigned long addr, unsigned long end)
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long start = addr;
-	unsigned long end = addr + size;
 
 	BUG_ON(addr >= end);
 	pgd = pgd_offset_k(addr);
@@ -86,16 +84,10 @@ void unmap_kernel_range(unsigned long ad
 			continue;
 		vunmap_pud_range(pgd, addr, next);
 	} while (pgd++, addr = next, addr != end);
-	flush_tlb_kernel_range(start, end);
-}
-
-static void unmap_vm_area(struct vm_struct *area)
-{
-	unmap_kernel_range((unsigned long)area->addr, area->size);
 }
 
 static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-			unsigned long end, pgprot_t prot, struct page ***pages)
+		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
 {
 	pte_t *pte;
 
@@ -103,18 +95,24 @@ static int vmap_pte_range(pmd_t *pmd, un
 	if (!pte)
 		return -ENOMEM;
 	do {
-		struct page *page = **pages;
-		WARN_ON(!pte_none(*pte));
-		if (!page)
+		struct page *page = pages[*nr];
+
+		if (unlikely(!pte_none(*pte))) {
+			WARN_ON(1);
+			return -EBUSY;
+		}
+		if (unlikely(!page)) {
+			WARN_ON(1);
 			return -ENOMEM;
+		}
 		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
-		(*pages)++;
+		(*nr)++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	return 0;
 }
 
-static inline int vmap_pmd_range(pud_t *pud, unsigned long addr,
-			unsigned long end, pgprot_t prot, struct page ***pages)
+static int vmap_pmd_range(pud_t *pud, unsigned long addr,
+		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -124,14 +122,14 @@ static inline int vmap_pmd_range(pud_t *
 		return -ENOMEM;
 	do {
 		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages))
+		if (vmap_pte_range(pmd, addr, next, prot, pages, nr))
 			return -ENOMEM;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
 
-static inline int vmap_pud_range(pgd_t *pgd, unsigned long addr,
-			unsigned long end, pgprot_t prot, struct page ***pages)
+static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
+		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -141,50 +139,48 @@ static inline int vmap_pud_range(pgd_t *
 		return -ENOMEM;
 	do {
 		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages))
+		if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
 			return -ENOMEM;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
-int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
+static int vmap_page_range(unsigned long addr, unsigned long end,
+				pgprot_t prot, struct page **pages)
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long addr = (unsigned long) area->addr;
-	unsigned long end = addr + area->size - PAGE_SIZE;
-	int err;
+	int err = 0;
+	int nr = 0;
 
 	BUG_ON(addr >= end);
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = vmap_pud_range(pgd, addr, next, prot, pages);
+		err = vmap_pud_range(pgd, addr, next, prot, pages, &nr);
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
-	flush_cache_vmap((unsigned long) area->addr, end);
-	return err;
+	flush_cache_vmap(addr, end);
+	return err ? : nr;
 }
-EXPORT_SYMBOL_GPL(map_vm_area);
 
 /*
- * Map a vmalloc()-space virtual address to the physical page.
+ * Walk a vmap address to the struct page it maps.
  */
 struct page *vmalloc_to_page(const void *vmalloc_addr)
 {
 	unsigned long addr = (unsigned long) vmalloc_addr;
 	struct page *page = NULL;
 	pgd_t *pgd = pgd_offset_k(addr);
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *ptep, pte;
 
 	if (!pgd_none(*pgd)) {
-		pud = pud_offset(pgd, addr);
+		pud_t *pud = pud_offset(pgd, addr);
 		if (!pud_none(*pud)) {
-			pmd = pmd_offset(pud, addr);
+			pmd_t *pmd = pmd_offset(pud, addr);
 			if (!pmd_none(*pmd)) {
+				pte_t *ptep, pte;
+
 				ptep = pte_offset_map(pmd, addr);
 				pte = *ptep;
 				if (pte_present(pte))
@@ -206,13 +202,637 @@ unsigned long vmalloc_to_pfn(const void 
 }
 EXPORT_SYMBOL(vmalloc_to_pfn);
 
-static struct vm_struct *
-__get_vm_area_node(unsigned long size, unsigned long flags, unsigned long start,
-		unsigned long end, int node, gfp_t gfp_mask, void *caller)
+
+/*** Global kva allocator ***/
+
+#define VM_LAZY_FREE	0x01
+#define VM_LAZY_FREEING	0x02
+#define VM_VM_AREA	0x04
+
+struct vmap_area {
+	unsigned long va_start;
+	unsigned long va_end;
+	unsigned long flags;
+	struct rb_node rb_node;
+	struct list_head list;
+	struct list_head purge_list;
+	void *private;
+	struct rcu_head rcu_head;
+};
+
+static DEFINE_SPINLOCK(vmap_area_lock);
+static struct rb_root vmap_area_root = RB_ROOT;
+static LIST_HEAD(vmap_area_list);
+
+static struct vmap_area *__find_vmap_area(unsigned long addr)
+{
+	struct rb_node *n = vmap_area_root.rb_node;
+
+	while (n) {
+		struct vmap_area *va;
+
+		va = rb_entry(n, struct vmap_area, rb_node);
+		if (addr < va->va_start)
+			n = n->rb_left;
+		else if (addr > va->va_start)
+			n = n->rb_right;
+		else
+			return va;
+	}
+
+	return NULL;
+}
+
+static void __insert_vmap_area(struct vmap_area *va)
 {
-	struct vm_struct **p, *tmp, *area;
-	unsigned long align = 1;
+	struct rb_node **p = &vmap_area_root.rb_node;
+	struct rb_node *parent = NULL;
+	struct rb_node *tmp;
+
+	while (*p) {
+		struct vmap_area *tmp;
+
+		parent = *p;
+		tmp = rb_entry(parent, struct vmap_area, rb_node);
+		if (va->va_start < tmp->va_end)
+			p = &(*p)->rb_left;
+		else if (va->va_end > tmp->va_start)
+			p = &(*p)->rb_right;
+		else
+			BUG();
+	}
+
+	rb_link_node(&va->rb_node, parent, p);
+	rb_insert_color(&va->rb_node, &vmap_area_root);
+
+	/* address-sort this list so it is usable like the vmlist */
+	tmp = rb_prev(&va->rb_node);
+	if (tmp) {
+		struct vmap_area *prev;
+		prev = rb_entry(tmp, struct vmap_area, rb_node);
+		list_add_rcu(&va->list, &prev->list);
+	} else
+		list_add_rcu(&va->list, &vmap_area_list);
+}
+
+static void purge_vmap_area_lazy(void);
+
+static struct vmap_area *alloc_vmap_area(unsigned long size, unsigned long align,
+				unsigned long vstart, unsigned long vend,
+				int node, gfp_t gfp_mask)
+{
+	struct vmap_area *va;
+	struct rb_node *n;
 	unsigned long addr;
+	int purged = 0;
+
+	BUG_ON(size & ~PAGE_MASK);
+
+	addr = ALIGN(vstart, align);
+
+	va = kmalloc_node(sizeof(struct vmap_area),
+			gfp_mask & GFP_RECLAIM_MASK, node);
+	if (unlikely(!va))
+		return ERR_PTR(-ENOMEM);
+
+retry:
+	spin_lock(&vmap_area_lock);
+	/* XXX: could have a last_hole cache */
+	n = vmap_area_root.rb_node;
+	if (n) {
+		struct vmap_area *first = NULL;
+
+		do {
+			struct vmap_area *tmp;
+			tmp = rb_entry(n, struct vmap_area, rb_node);
+			if (tmp->va_end >= addr) {
+				if (!first && tmp->va_start <= addr)
+					first = tmp;
+				n = n->rb_left;
+			} else {
+				first = tmp;
+				n = n->rb_right;
+			}
+		} while (n);
+
+		if (!first)
+			goto found;
+
+		if (first->va_end < addr) {
+			n = rb_next(&first->rb_node);
+			if (n)
+				first = rb_entry(n, struct vmap_area, rb_node);
+			else
+				goto found;
+		}
+
+		while (addr + size >= first->va_start && addr + size <= vend) {
+			addr = ALIGN(first->va_end + PAGE_SIZE, align);
+
+			n = rb_next(&first->rb_node);
+			if (n)
+				first = rb_entry(n, struct vmap_area, rb_node);
+			else
+				goto found;
+		}
+	}
+found:
+	if (addr + size > vend) {
+		spin_unlock(&vmap_area_lock);
+		if (!purged) {
+			purge_vmap_area_lazy();
+			purged = 1;
+			goto retry;
+		}
+		if (printk_ratelimit())
+			printk(KERN_WARNING "vmap allocation failed: "
+				 "use vmalloc=<size> to increase size.\n");
+		return ERR_PTR(-EBUSY);
+	}
+
+	BUG_ON(addr & (align-1));
+
+	va->va_start = addr;
+	va->va_end = addr + size;
+	va->flags = 0;
+	__insert_vmap_area(va);
+	spin_unlock(&vmap_area_lock);
+
+	return va;
+}
+
+static void rcu_free_va(struct rcu_head *head)
+{
+	struct vmap_area *va = container_of(head, struct vmap_area, rcu_head);
+
+	kfree(va);
+}
+
+static void __free_vmap_area(struct vmap_area *va)
+{
+	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
+	rb_erase(&va->rb_node, &vmap_area_root);
+	RB_CLEAR_NODE(&va->rb_node);
+	list_del_rcu(&va->list);
+
+	call_rcu(&va->rcu_head, rcu_free_va);
+}
+
+static void free_vmap_area(struct vmap_area *va)
+{
+	spin_lock(&vmap_area_lock);
+	__free_vmap_area(va);
+	spin_unlock(&vmap_area_lock);
+}
+
+static void unmap_vmap_area(struct vmap_area *va)
+{
+	vunmap_page_range(va->va_start, va->va_end);
+}
+
+#define LAZY_MAX (64*1024*1024 / PAGE_SIZE)
+static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
+
+static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
+					int sync, int force_flush)
+{
+	static DEFINE_SPINLOCK(purge_lock);
+	LIST_HEAD(valist);
+	struct vmap_area *va;
+	int nr = 0;
+
+	if (!sync && !force_flush) {
+		if (!spin_trylock(&purge_lock))
+			return;
+	} else
+		spin_lock(&purge_lock);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(va, &vmap_area_list, list) {
+		if (va->flags & VM_LAZY_FREE) {
+			if (va->va_start < *start)
+				*start = va->va_start;
+			if (va->va_end > *end)
+				*end = va->va_end;
+			nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
+			unmap_vmap_area(va);
+			list_add_tail(&va->purge_list, &valist);
+			va->flags |= VM_LAZY_FREEING;
+			va->flags &= ~VM_LAZY_FREE;
+		}
+	}
+	rcu_read_unlock();
+
+	if (nr) {
+		BUG_ON(nr > atomic_read(&vmap_lazy_nr));
+		atomic_sub(nr, &vmap_lazy_nr);
+	}
+
+	if (nr || force_flush)
+		flush_tlb_kernel_range(*start, *end);
+
+	if (nr) {
+		spin_lock(&vmap_area_lock);
+		list_for_each_entry(va, &valist, purge_list)
+			__free_vmap_area(va);
+		spin_unlock(&vmap_area_lock);
+	}
+	spin_unlock(&purge_lock);
+}
+
+static void purge_vmap_area_lazy(void)
+{
+	unsigned long start = ULONG_MAX, end = 0;
+
+	__purge_vmap_area_lazy(&start, &end, 0, 0);
+}
+
+static void free_unmap_vmap_area(struct vmap_area *va)
+{
+	va->flags |= VM_LAZY_FREE;
+	atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
+	if (unlikely(atomic_read(&vmap_lazy_nr) > LAZY_MAX))
+		purge_vmap_area_lazy();
+}
+
+static struct vmap_area *find_vmap_area(unsigned long addr)
+{
+	struct vmap_area *va;
+
+	spin_lock(&vmap_area_lock);
+	va = __find_vmap_area(addr);
+	spin_unlock(&vmap_area_lock);
+
+	return va;
+}
+
+static void free_unmap_vmap_area_addr(unsigned long addr)
+{
+	struct vmap_area *va;
+
+	va = find_vmap_area(addr);
+	BUG_ON(!va);
+	free_unmap_vmap_area(va);
+}
+
+
+/*** Per cpu kva allocator ***/
+
+/*
+ * vmap space is limited especially on 32 bit architectures. Ensure there is
+ * room for at least 16 percpu vmap blocks per CPU.
+ */
+#if 0 /* constant vmalloc space size */
+#define VMALLOC_SPACE		(VMALLOC_END-VMALLOC_START)
+#else
+#if BITS_PER_LONG == 32
+#define VMALLOC_SPACE		(128*1024*1024)
+#else
+#define VMALLOC_SPACE		(128*1024*1024*1024)
+#endif
+#endif
+
+#define VMALLOC_PAGES		(VMALLOC_SPACE / PAGE_SIZE)
+#define VMAP_MAX_ALLOC		BITS_PER_LONG	/* 256K with 4K pages */
+#define VMAP_BBMAP_BITS_MAX	1024	/* 4MB with 4K pages */
+#define VMAP_BBMAP_BITS_MIN	(VMAP_MAX_ALLOC*2)
+#define VMAP_MIN(x, y)		((x) < (y) ? (x) : (y)) /* can't use min() */
+#define VMAP_MAX(x, y)		((x) > (y) ? (x) : (y)) /* can't use max() */
+#define VMAP_BBMAP_BITS		VMAP_MIN(VMAP_BBMAP_BITS_MAX, VMAP_MAX(VMAP_BBMAP_BITS_MIN, VMALLOC_PAGES / NR_CPUS / 16))
+
+#define VMAP_BLOCK_SIZE		(VMAP_BBMAP_BITS * PAGE_SIZE)
+
+struct vmap_block_queue {
+	spinlock_t lock;
+	struct list_head free;
+	struct list_head dirty;
+	unsigned int nr_dirty;
+};
+
+struct vmap_block {
+	spinlock_t lock;
+	struct vmap_area *va;
+	struct vmap_block_queue *vbq;
+	unsigned long free, dirty;
+	DECLARE_BITMAP(alloc_map, VMAP_BBMAP_BITS);
+	DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
+	union {
+		struct {
+			struct list_head free_list;
+			struct list_head dirty_list;
+		};
+		struct rcu_head rcu_head;
+	};
+};
+
+static DEFINE_PER_CPU(struct vmap_block_queue, vmap_block_queue);
+
+static DEFINE_SPINLOCK(vmap_block_tree_lock);
+static RADIX_TREE(vmap_block_tree, GFP_ATOMIC);
+/* XXX: have global list of vmap blocks to fall back on? */
+
+static unsigned long addr_to_vb_idx(unsigned long addr)
+{
+	addr -= VMALLOC_START & ~(VMAP_BLOCK_SIZE-1);
+	addr /= VMAP_BLOCK_SIZE;
+	return addr;
+}
+
+static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
+{
+	struct vmap_block_queue *vbq;
+	struct vmap_block *vb;
+	struct vmap_area *va;
+	int node, err;
+
+	node = numa_node_id();
+
+	vb = kmalloc_node(sizeof(struct vmap_block),
+			gfp_mask & GFP_RECLAIM_MASK, node);
+	if (unlikely(!vb))
+		return ERR_PTR(-ENOMEM);
+
+	va = alloc_vmap_area(VMAP_BLOCK_SIZE, VMAP_BLOCK_SIZE,
+					VMALLOC_START, VMALLOC_END,
+					node, gfp_mask);
+	if (unlikely(IS_ERR(va))) {
+		kfree(vb);
+		return ERR_PTR(PTR_ERR(va));
+	}
+
+	err = radix_tree_preload(gfp_mask);
+	if (unlikely(err)) {
+		kfree(vb);
+		free_vmap_area(va);
+		return ERR_PTR(err);
+	}
+
+	spin_lock_init(&vb->lock);
+	vb->va = va;
+	vb->free = VMAP_BBMAP_BITS;
+	vb->dirty = 0;
+	bitmap_zero(vb->alloc_map, VMAP_BBMAP_BITS);
+	bitmap_zero(vb->dirty_map, VMAP_BBMAP_BITS);
+	INIT_LIST_HEAD(&vb->free_list);
+	INIT_LIST_HEAD(&vb->dirty_list);
+
+	spin_lock(&vmap_block_tree_lock);
+	err = radix_tree_insert(&vmap_block_tree, addr_to_vb_idx(va->va_start), vb);
+	spin_unlock(&vmap_block_tree_lock);
+	BUG_ON(err);
+	radix_tree_preload_end();
+
+	vbq = &get_cpu_var(vmap_block_queue);
+	vb->vbq = vbq;
+	spin_lock(&vbq->lock);
+	list_add(&vb->free_list, &vbq->free);
+	spin_unlock(&vbq->lock);
+	put_cpu_var(vmap_cpu_blocks);
+
+	return vb;
+}
+
+static void rcu_free_vb(struct rcu_head *head)
+{
+	struct vmap_block *vb = container_of(head, struct vmap_block, rcu_head);
+
+	kfree(vb);
+}
+
+static void free_vmap_block(struct vmap_block *vb)
+{
+	struct vmap_block *tmp;
+
+	spin_lock(&vb->vbq->lock);
+	if (!list_empty(&vb->free_list))
+		list_del(&vb->free_list);
+	if (!list_empty(&vb->dirty_list))
+		list_del(&vb->dirty_list);
+	spin_unlock(&vb->vbq->lock);
+
+	spin_lock(&vmap_block_tree_lock);
+	tmp = radix_tree_delete(&vmap_block_tree, addr_to_vb_idx(vb->va->va_start));
+	spin_unlock(&vmap_block_tree_lock);
+	BUG_ON(tmp != vb);
+
+	free_unmap_vmap_area(vb->va);
+	call_rcu(&vb->rcu_head, rcu_free_vb);
+}
+
+static void *vb_alloc(unsigned long size,
+			gfp_t gfp_mask)
+{
+	struct vmap_block_queue *vbq;
+	struct vmap_block *vb;
+	unsigned long addr = 0;
+	unsigned int order;
+
+	BUG_ON(size & ~PAGE_MASK);
+	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
+	order = get_order(size);
+
+again:
+	rcu_read_lock();
+	vbq = &get_cpu_var(vmap_block_queue);
+	list_for_each_entry_rcu(vb, &vbq->free, free_list) {
+		int i;
+
+		spin_lock(&vb->lock);
+		i = bitmap_find_free_region(vb->alloc_map, VMAP_BBMAP_BITS, order);
+
+		if (i >= 0) {
+			addr = vb->va->va_start + (i << PAGE_SHIFT);
+			BUG_ON(addr_to_vb_idx(addr) != addr_to_vb_idx(vb->va->va_start));
+			vb->free -= 1UL << order;
+			if (vb->free == 0) {
+				spin_lock(&vbq->lock);
+				list_del_init(&vb->free_list);
+				spin_unlock(&vbq->lock);
+			}
+			spin_unlock(&vb->lock);
+			break;
+		}
+		spin_unlock(&vb->lock);
+	}
+	put_cpu_var(vmap_cpu_blocks);
+	rcu_read_unlock();
+
+	if (!addr) {
+		vb = new_vmap_block(gfp_mask);
+		if (IS_ERR(vb))
+			return vb;
+		goto again;
+	}
+
+	return (void *)addr;
+}
+
+static void vb_free(const void *addr, unsigned long size)
+{
+	unsigned long offset;
+	unsigned int order;
+	struct vmap_block *vb;
+
+	BUG_ON(size & ~PAGE_MASK);
+	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
+	order = get_order(size);
+
+	offset = (unsigned long)addr & (VMAP_BLOCK_SIZE - 1);
+
+	rcu_read_lock();
+	vb = radix_tree_lookup(&vmap_block_tree, addr_to_vb_idx((unsigned long)addr));
+	rcu_read_unlock();
+	BUG_ON(!vb);
+
+	spin_lock(&vb->lock);
+	bitmap_allocate_region(vb->dirty_map, offset >> PAGE_SHIFT, order);
+	if (!vb->dirty) {
+		spin_lock(&vb->vbq->lock);
+		list_add(&vb->dirty_list, &vb->vbq->dirty);
+		spin_unlock(&vb->vbq->lock);
+	}
+	vb->dirty += 1UL << order;
+	if (vb->dirty == VMAP_BBMAP_BITS) {
+		BUG_ON(vb->free || !list_empty(&vb->free_list));
+		spin_unlock(&vb->lock);
+		free_vmap_block(vb);
+	} else
+		spin_unlock(&vb->lock);
+}
+
+void vm_unmap_aliases(void)
+{
+	unsigned long start = ULONG_MAX, end = 0;
+	int cpu;
+	int flush = 0;
+
+	for_each_possible_cpu(cpu) {
+		struct vmap_block_queue *vbq = &per_cpu(vmap_block_queue, cpu);
+		struct vmap_block *vb;
+
+		rcu_read_lock();
+		list_for_each_entry_rcu(vb, &vbq->free, free_list) {
+			int i;
+
+			spin_lock(&vb->lock);
+			for (i = find_first_bit(vb->dirty_map, VMAP_BBMAP_BITS);
+			  i < VMAP_BBMAP_BITS;
+			  i = find_next_bit(vb->dirty_map, VMAP_BBMAP_BITS, i)){
+				unsigned long s, e;
+				int j;
+				j = find_next_zero_bit(vb->dirty_map,
+					VMAP_BBMAP_BITS, i);
+
+				s = vb->va->va_start + (i << PAGE_SHIFT);
+				e = vb->va->va_start + (j << PAGE_SHIFT);
+				vunmap_page_range(s, e);
+				flush = 1;
+
+				if (s < start)
+					start = s;
+				if (e > end)
+					end = e;
+
+				i = j;
+			}
+			spin_unlock(&vb->lock);
+		}
+		rcu_read_unlock();
+	}
+
+	__purge_vmap_area_lazy(&start, &end, 1, flush);
+}
+
+void vm_unmap_ram(const void *mem, unsigned int count)
+{
+	unsigned long size = count << PAGE_SHIFT;
+	unsigned long addr = (unsigned long)mem;
+
+	BUG_ON(!addr || addr < VMALLOC_START || addr > VMALLOC_END || (addr & (PAGE_SIZE-1)));
+
+	debug_check_no_locks_freed(mem, size);
+
+	if (likely(count <= VMAP_MAX_ALLOC))
+		vb_free(mem, size);
+	else
+		free_unmap_vmap_area_addr(addr);
+}
+
+void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
+{
+	unsigned long size = count << PAGE_SHIFT;
+	unsigned long addr;
+	void *mem;
+
+	if (likely(count <= VMAP_MAX_ALLOC)) {
+		mem = vb_alloc(size, GFP_KERNEL);
+		if (IS_ERR(mem))
+			return NULL;
+		addr = (unsigned long)mem;
+	} else {
+		struct vmap_area *va;
+		va = alloc_vmap_area(size, PAGE_SIZE, VMALLOC_START, VMALLOC_END, node, GFP_KERNEL);
+		if (IS_ERR(va))
+			return NULL;
+
+		addr = va->va_start;
+		mem = (void *)addr;
+	}
+	if (vmap_page_range(addr, addr + size, prot, pages) < 0) {
+		vm_unmap_ram(mem, count);
+		return NULL;
+	}
+	return mem;
+}
+
+void __init vmalloc_init(void)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct vmap_block_queue *vbq;
+
+		vbq = &per_cpu(vmap_block_queue, i);
+		spin_lock_init(&vbq->lock);
+		INIT_LIST_HEAD(&vbq->free);
+		INIT_LIST_HEAD(&vbq->dirty);
+		vbq->nr_dirty = 0;
+	}
+}
+
+void unmap_kernel_range(unsigned long addr, unsigned long size)
+{
+	unsigned long end = addr + size;
+	vunmap_page_range(addr, end);
+	flush_tlb_kernel_range(addr, end);
+}
+
+int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
+{
+	unsigned long addr = (unsigned long)area->addr;
+	int err;
+	err = vmap_page_range(addr, addr + area->size- PAGE_SIZE, prot, *pages);
+	if (err > 0) {
+		*pages += err;
+		err = 0;
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(map_vm_area);
+
+/*** Old vmalloc interfaces ***/
+DEFINE_RWLOCK(vmlist_lock);
+struct vm_struct *vmlist;
+
+static struct vm_struct *__get_vm_area_node(unsigned long size,
+		unsigned long flags, unsigned long start, unsigned long end,
+		int node, gfp_t gfp_mask, void *caller)
+{
+	static struct vmap_area *va;
+	struct vm_struct *area;
+	struct vm_struct *tmp, **p;
+	unsigned long align = 1;
 
 	BUG_ON(in_interrupt());
 	if (flags & VM_IOREMAP) {
@@ -225,13 +845,12 @@ __get_vm_area_node(unsigned long size, u
 
 		align = 1ul << bit;
 	}
-	addr = ALIGN(start, align);
+
 	size = PAGE_ALIGN(size);
 	if (unlikely(!size))
 		return NULL;
 
 	area = kmalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node);
-
 	if (unlikely(!area))
 		return NULL;
 
@@ -240,48 +859,32 @@ __get_vm_area_node(unsigned long size, u
 	 */
 	size += PAGE_SIZE;
 
-	write_lock(&vmlist_lock);
-	for (p = &vmlist; (tmp = *p) != NULL ;p = &tmp->next) {
-		if ((unsigned long)tmp->addr < addr) {
-			if((unsigned long)tmp->addr + tmp->size >= addr)
-				addr = ALIGN(tmp->size + 
-					     (unsigned long)tmp->addr, align);
-			continue;
-		}
-		if ((size + addr) < addr)
-			goto out;
-		if (size + addr <= (unsigned long)tmp->addr)
-			goto found;
-		addr = ALIGN(tmp->size + (unsigned long)tmp->addr, align);
-		if (addr > end - size)
-			goto out;
-	}
-	if ((size + addr) < addr)
-		goto out;
-	if (addr > end - size)
-		goto out;
-
-found:
-	area->next = *p;
-	*p = area;
+	va = alloc_vmap_area(size, align, start, end, node, gfp_mask);
+	if (IS_ERR(va)) {
+		kfree(area);
+		return NULL;
+	}
 
 	area->flags = flags;
-	area->addr = (void *)addr;
+	area->addr = (void *)va->va_start;
 	area->size = size;
 	area->pages = NULL;
 	area->nr_pages = 0;
 	area->phys_addr = 0;
 	area->caller = caller;
+	va->private = area;
+	va->flags |= VM_VM_AREA;
+
+	write_lock(&vmlist_lock);
+	for (p = &vmlist; (tmp = *p) != NULL; p = &tmp->next) {
+		if (tmp->addr >= area->addr)
+			break;
+	}
+	area->next = *p;
+	*p = area;
 	write_unlock(&vmlist_lock);
 
 	return area;
-
-out:
-	write_unlock(&vmlist_lock);
-	kfree(area);
-	if (printk_ratelimit())
-		printk(KERN_WARNING "allocation failed: out of vmalloc space - use vmalloc=<size> to increase size.\n");
-	return NULL;
 }
 
 struct vm_struct *__get_vm_area(unsigned long size, unsigned long flags,
@@ -321,39 +924,15 @@ struct vm_struct *get_vm_area_node(unsig
 				  gfp_mask, __builtin_return_address(0));
 }
 
-/* Caller must hold vmlist_lock */
-static struct vm_struct *__find_vm_area(const void *addr)
+static struct vm_struct *find_vm_area(const void *addr)
 {
-	struct vm_struct *tmp;
+	struct vmap_area *va;
 
-	for (tmp = vmlist; tmp != NULL; tmp = tmp->next) {
-		 if (tmp->addr == addr)
-			break;
-	}
-
-	return tmp;
-}
+	va = find_vmap_area((unsigned long)addr);
+	if (va && va->flags & VM_VM_AREA)
+		return va->private;
 
-/* Caller must hold vmlist_lock */
-static struct vm_struct *__remove_vm_area(const void *addr)
-{
-	struct vm_struct **p, *tmp;
-
-	for (p = &vmlist ; (tmp = *p) != NULL ;p = &tmp->next) {
-		 if (tmp->addr == addr)
-			 goto found;
-	}
 	return NULL;
-
-found:
-	unmap_vm_area(tmp);
-	*p = tmp->next;
-
-	/*
-	 * Remove the guard page.
-	 */
-	tmp->size -= PAGE_SIZE;
-	return tmp;
 }
 
 /**
@@ -366,11 +945,24 @@ found:
  */
 struct vm_struct *remove_vm_area(const void *addr)
 {
-	struct vm_struct *v;
-	write_lock(&vmlist_lock);
-	v = __remove_vm_area(addr);
-	write_unlock(&vmlist_lock);
-	return v;
+	struct vmap_area *va;
+
+	va = find_vmap_area((unsigned long)addr);
+	if (va && va->flags & VM_VM_AREA) {
+		struct vm_struct *vm = va->private;
+		struct vm_struct *tmp, **p;
+		free_unmap_vmap_area(va);
+		vm->size -= PAGE_SIZE;
+
+		write_lock(&vmlist_lock);
+		for (p = &vmlist; (tmp = *p) != vm; p = &tmp->next)
+			;
+		*p = tmp->next;
+		write_unlock(&vmlist_lock);
+
+		return vm;
+	}
+	return NULL;
 }
 
 static void __vunmap(const void *addr, int deallocate_pages)
@@ -480,6 +1072,8 @@ void *vmap(struct page **pages, unsigned
 }
 EXPORT_SYMBOL(vmap);
 
+static void *__vmalloc_node(unsigned long size, gfp_t gfp_mask, pgprot_t prot,
+			    int node, void *caller);
 static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 				 pgprot_t prot, int node, void *caller)
 {
@@ -606,10 +1200,8 @@ void *vmalloc_user(unsigned long size)
 
 	ret = __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
 	if (ret) {
-		write_lock(&vmlist_lock);
-		area = __find_vm_area(ret);
+		area = find_vm_area(ret);
 		area->flags |= VM_USERMAP;
-		write_unlock(&vmlist_lock);
 	}
 	return ret;
 }
@@ -689,10 +1281,8 @@ void *vmalloc_32_user(unsigned long size
 
 	ret = __vmalloc(size, GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL);
 	if (ret) {
-		write_lock(&vmlist_lock);
-		area = __find_vm_area(ret);
+		area = find_vm_area(ret);
 		area->flags |= VM_USERMAP;
-		write_unlock(&vmlist_lock);
 	}
 	return ret;
 }
@@ -793,26 +1383,25 @@ int remap_vmalloc_range(struct vm_area_s
 	struct vm_struct *area;
 	unsigned long uaddr = vma->vm_start;
 	unsigned long usize = vma->vm_end - vma->vm_start;
-	int ret;
 
 	if ((PAGE_SIZE-1) & (unsigned long)addr)
 		return -EINVAL;
 
-	read_lock(&vmlist_lock);
-	area = __find_vm_area(addr);
+	area = find_vm_area(addr);
 	if (!area)
-		goto out_einval_locked;
+		return -EINVAL;
 
 	if (!(area->flags & VM_USERMAP))
-		goto out_einval_locked;
+		return -EINVAL;
 
 	if (usize + (pgoff << PAGE_SHIFT) > area->size - PAGE_SIZE)
-		goto out_einval_locked;
-	read_unlock(&vmlist_lock);
+		return -EINVAL;
 
 	addr += pgoff << PAGE_SHIFT;
 	do {
 		struct page *page = vmalloc_to_page(addr);
+		int ret;
+
 		ret = vm_insert_page(vma, uaddr, page);
 		if (ret)
 			return ret;
@@ -825,11 +1414,7 @@ int remap_vmalloc_range(struct vm_area_s
 	/* Prevent "things" like memory migration? VM_flags need a cleanup... */
 	vma->vm_flags |= VM_RESERVED;
 
-	return ret;
-
-out_einval_locked:
-	read_unlock(&vmlist_lock);
-	return -EINVAL;
+	return 0;
 }
 EXPORT_SYMBOL(remap_vmalloc_range);
 
Index: linux-2.6/include/linux/vmalloc.h
===================================================================
--- linux-2.6.orig/include/linux/vmalloc.h
+++ linux-2.6/include/linux/vmalloc.h
@@ -23,7 +23,6 @@ struct vm_area_struct;
 #endif
 
 struct vm_struct {
-	/* keep next,addr,size together to speedup lookups */
 	struct vm_struct	*next;
 	void			*addr;
 	unsigned long		size;
@@ -37,6 +36,11 @@ struct vm_struct {
 /*
  *	Highlevel APIs for driver use
  */
+extern void vm_unmap_ram(const void *mem, unsigned int count);
+extern void *vm_map_ram(struct page **pages, unsigned int count,
+				int node, pgprot_t prot);
+extern void vm_unmap_aliases(void);
+
 extern void *vmalloc(unsigned long size);
 extern void *vmalloc_user(unsigned long size);
 extern void *vmalloc_node(unsigned long size, int node);
Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c
+++ linux-2.6/init/main.c
@@ -89,6 +89,7 @@ extern void mca_init(void);
 extern void sbus_init(void);
 extern void prio_tree_init(void);
 extern void radix_tree_init(void);
+extern void vmalloc_init(void);
 extern void free_initmem(void);
 #ifdef	CONFIG_ACPI
 extern void acpi_early_init(void);
@@ -642,6 +643,7 @@ asmlinkage void __init start_kernel(void
 		initrd_start = 0;
 	}
 #endif
+	vmalloc_init();
 	vfs_caches_init_early();
 	cpuset_init_early();
 	mem_init();
Index: linux-2.6/arch/x86/xen/enlighten.c
===================================================================
--- linux-2.6.orig/arch/x86/xen/enlighten.c
+++ linux-2.6/arch/x86/xen/enlighten.c
@@ -853,6 +853,7 @@ static void xen_alloc_ptpage(struct mm_s
 			/* make sure there are no stray mappings of
 			   this page */
 			kmap_flush_unused();
+			vm_unmap_aliases();
 	}
 }
 
Index: linux-2.6/arch/x86/xen/mmu.c
===================================================================
--- linux-2.6.orig/arch/x86/xen/mmu.c
+++ linux-2.6/arch/x86/xen/mmu.c
@@ -723,6 +723,7 @@ void xen_pgd_pin(pgd_t *pgd)
 		/* re-enable interrupts for kmap_flush_unused */
 		xen_mc_issue(0);
 		kmap_flush_unused();
+		vm_unmap_aliases();
 		xen_mc_batch();
 	}
 
Index: linux-2.6/arch/x86/mm/pageattr.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/pageattr.c
+++ linux-2.6/arch/x86/mm/pageattr.c
@@ -777,6 +777,8 @@ static int change_page_attr_set_clr(unsi
 		WARN_ON_ONCE(1);
 	}
 
+	vm_unmap_aliases();
+
 	cpa.vaddr = addr;
 	cpa.numpages = numpages;
 	cpa.mask_set = mask_set;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
