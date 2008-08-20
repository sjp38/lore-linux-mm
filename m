Date: Wed, 20 Aug 2008 19:48:26 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: rewrite vmap layer
Message-ID: <20080820174826.GB19656@wotan.suse.de>
References: <20080818133224.GA5258@wotan.suse.de> <48AADBDC.2000608@linux-foundation.org> <20080820090234.GA7018@wotan.suse.de> <48AC244F.1030104@linux-foundation.org> <20080820162235.GA26894@wotan.suse.de> <48AC4B41.8080908@linux-foundation.org> <20080820165947.GA19656@wotan.suse.de> <48AC4EE0.4050603@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48AC4EE0.4050603@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 20, 2008 at 12:05:36PM -0500, Christoph Lameter wrote:
> Nick Piggin wrote:
> > On Wed, Aug 20, 2008 at 11:50:09AM -0500, Christoph Lameter wrote:
> >> Nick Piggin wrote:
> >>
> >>> Indeed that would be a good use for it if this general fallback mechanism
> >>> were to be merged.
> >> Want me to rebase my virtualizable compound patchset on top of your vmap changes?
> > 
> > Is there much clash between them? Or just the fact that you'll have to
> > use vm_map_ram/vm_unmap_ram?
> 
> There is not much of a clash. If you would make vmap/unmap atomic then there
> is barely any overlap at all and the patchset becomes much smaller and even
> the initial version of it can support in interrupt alloc / free.

Well the following (untested) incremental patch is about all that
would be required for the higher level vmap layer.

We then still need to make kernel page table allocations take a gfp
mask and make the init_mm ptl interrupt safe. Hopefully I didn't miss
anything else... it should be possible, but as you can see not
something we want to add unless there is a good reason.

Making only vunmap interrupt safe would be less work. 

 
> > I probably wouldn't be able to find time to look at that patchset again
> > for a while... but anyway, I've been running the vmap rewrite for quite
> > a while on several different systems and workloads without problems, so
> > it should be stable enough to test out. And the APIs should not change.
> 
> Yes I think this is good stuff. Hopefully I will get enough time to check it
> out in detail.

Thanks, more reviews would always be helpful.

---

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -296,6 +296,7 @@ static struct vmap_area *alloc_vmap_area
 				unsigned long vstart, unsigned long vend,
 				int node, gfp_t gfp_mask)
 {
+	unsigned long flags;
 	struct vmap_area *va;
 	struct rb_node *n;
 	unsigned long addr;
@@ -311,7 +312,7 @@ static struct vmap_area *alloc_vmap_area
 		return ERR_PTR(-ENOMEM);
 
 retry:
-	spin_lock(&vmap_area_lock);
+	spin_lock_irqsave(&vmap_area_lock, flags);
 	/* XXX: could have a last_hole cache */
 	n = vmap_area_root.rb_node;
 	if (n) {
@@ -353,7 +354,7 @@ retry:
 	}
 found:
 	if (addr + size > vend) {
-		spin_unlock(&vmap_area_lock);
+		spin_unlock_irqrestore(&vmap_area_lock, flags);
 		if (!purged) {
 			purge_vmap_area_lazy();
 			purged = 1;
@@ -371,7 +372,7 @@ found:
 	va->va_end = addr + size;
 	va->flags = 0;
 	__insert_vmap_area(va);
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 
 	return va;
 }
@@ -398,9 +399,11 @@ static void __free_vmap_area(struct vmap
  */
 static void free_vmap_area(struct vmap_area *va)
 {
-	spin_lock(&vmap_area_lock);
+	unsigned long flags;
+
+	spin_lock_irqsave(&vmap_area_lock, flags);
 	__free_vmap_area(va);
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 }
 
 /*
@@ -456,6 +459,8 @@ static void __purge_vmap_area_lazy(unsig
 	struct vmap_area *va;
 	int nr = 0;
 
+	BUG_ON(in_interrupt());
+
 	/*
 	 * If sync is 0 but force_flush is 1, we'll go sync anyway but callers
 	 * should not expect such behaviour. This just simplifies locking for
@@ -492,10 +497,10 @@ static void __purge_vmap_area_lazy(unsig
 		flush_tlb_kernel_range(*start, *end);
 
 	if (nr) {
-		spin_lock(&vmap_area_lock);
+		spin_lock_irq(&vmap_area_lock);
 		list_for_each_entry(va, &valist, purge_list)
 			__free_vmap_area(va);
-		spin_unlock(&vmap_area_lock);
+		spin_unlock_irq(&vmap_area_lock);
 	}
 	spin_unlock(&purge_lock);
 }
@@ -510,6 +515,13 @@ static void purge_vmap_area_lazy(void)
 	__purge_vmap_area_lazy(&start, &end, 0, 0);
 }
 
+static void purge_work_fn(struct work_struct *w)
+{
+	purge_vmap_area_lazy();
+}
+
+static DECLARE_WORK(purge_work, purge_work_fn);
+
 /*
  * Free and unmap a vmap area
  */
@@ -517,17 +529,22 @@ static void free_unmap_vmap_area(struct 
 {
 	va->flags |= VM_LAZY_FREE;
 	atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
-	if (unlikely(atomic_read(&vmap_lazy_nr) > lazy_max_pages()))
-		purge_vmap_area_lazy();
+	if (unlikely(atomic_read(&vmap_lazy_nr) > lazy_max_pages())) {
+		if (!in_interrupt())
+			purge_vmap_area_lazy();
+		else
+			schedule_work(&purge_work);
+	}
 }
 
 static struct vmap_area *find_vmap_area(unsigned long addr)
 {
+	unsigned long flags;
 	struct vmap_area *va;
 
-	spin_lock(&vmap_area_lock);
+	spin_lock_irqsave(&vmap_area_lock, flags);
 	va = __find_vmap_area(addr);
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 
 	return va;
 }
@@ -621,6 +638,7 @@ static unsigned long addr_to_vb_idx(unsi
 
 static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 {
+	unsigned long flags;
 	struct vmap_block_queue *vbq;
 	struct vmap_block *vb;
 	struct vmap_area *va;
@@ -659,6 +677,7 @@ static struct vmap_block *new_vmap_block
 	INIT_LIST_HEAD(&vb->dirty_list);
 
 	vb_idx = addr_to_vb_idx(va->va_start);
+	local_irq_save(flags);
 	spin_lock(&vmap_block_tree_lock);
 	err = radix_tree_insert(&vmap_block_tree, vb_idx, vb);
 	spin_unlock(&vmap_block_tree_lock);
@@ -671,6 +690,7 @@ static struct vmap_block *new_vmap_block
 	list_add(&vb->free_list, &vbq->free);
 	spin_unlock(&vbq->lock);
 	put_cpu_var(vmap_cpu_blocks);
+	local_irq_restore(flags);
 
 	return vb;
 }
@@ -684,9 +704,11 @@ static void rcu_free_vb(struct rcu_head 
 
 static void free_vmap_block(struct vmap_block *vb)
 {
+	unsigned long flags;
 	struct vmap_block *tmp;
 	unsigned long vb_idx;
 
+	local_irq_save(flags);
 	spin_lock(&vb->vbq->lock);
 	if (!list_empty(&vb->free_list))
 		list_del(&vb->free_list);
@@ -698,6 +720,7 @@ static void free_vmap_block(struct vmap_
 	spin_lock(&vmap_block_tree_lock);
 	tmp = radix_tree_delete(&vmap_block_tree, vb_idx);
 	spin_unlock(&vmap_block_tree_lock);
+	local_irq_restore(flags);
 	BUG_ON(tmp != vb);
 
 	free_unmap_vmap_area(vb->va);
@@ -719,9 +742,10 @@ again:
 	rcu_read_lock();
 	vbq = &get_cpu_var(vmap_block_queue);
 	list_for_each_entry_rcu(vb, &vbq->free, free_list) {
+		unsigned long flags;
 		int i;
 
-		spin_lock(&vb->lock);
+		spin_lock_irqsave(&vb->lock, flags);
 		i = bitmap_find_free_region(vb->alloc_map,
 						VMAP_BBMAP_BITS, order);
 
@@ -738,7 +762,7 @@ again:
 			spin_unlock(&vb->lock);
 			break;
 		}
-		spin_unlock(&vb->lock);
+		spin_unlock_irqrestore(&vb->lock, flags);
 	}
 	put_cpu_var(vmap_cpu_blocks);
 	rcu_read_unlock();
@@ -755,6 +779,7 @@ again:
 
 static void vb_free(const void *addr, unsigned long size)
 {
+	unsigned long flags;
 	unsigned long offset;
 	unsigned long vb_idx;
 	unsigned int order;
@@ -772,7 +797,7 @@ static void vb_free(const void *addr, un
 	rcu_read_unlock();
 	BUG_ON(!vb);
 
-	spin_lock(&vb->lock);
+	spin_lock_irqsave(&vb->lock, flags);
 	bitmap_allocate_region(vb->dirty_map, offset >> PAGE_SHIFT, order);
 	if (!vb->dirty) {
 		spin_lock(&vb->vbq->lock);
@@ -782,10 +807,10 @@ static void vb_free(const void *addr, un
 	vb->dirty += 1UL << order;
 	if (vb->dirty == VMAP_BBMAP_BITS) {
 		BUG_ON(vb->free || !list_empty(&vb->free_list));
-		spin_unlock(&vb->lock);
+		spin_unlock_irqrestore(&vb->lock, flags);
 		free_vmap_block(vb);
 	} else
-		spin_unlock(&vb->lock);
+		spin_unlock_irqrestore(&vb->lock, flags);
 }
 
 /**
@@ -807,6 +832,8 @@ void vm_unmap_aliases(void)
 	int cpu;
 	int flush = 0;
 
+	BUG_ON(in_interrupt());
+
 	for_each_possible_cpu(cpu) {
 		struct vmap_block_queue *vbq = &per_cpu(vmap_block_queue, cpu);
 		struct vmap_block *vb;
@@ -815,7 +842,7 @@ void vm_unmap_aliases(void)
 		list_for_each_entry_rcu(vb, &vbq->free, free_list) {
 			int i;
 
-			spin_lock(&vb->lock);
+			spin_lock_irq(&vb->lock);
 			i = find_first_bit(vb->dirty_map, VMAP_BBMAP_BITS);
 			while (i < VMAP_BBMAP_BITS) {
 				unsigned long s, e;
@@ -837,7 +864,7 @@ void vm_unmap_aliases(void)
 				i = find_next_bit(vb->dirty_map,
 							VMAP_BBMAP_BITS, i);
 			}
-			spin_unlock(&vb->lock);
+			spin_unlock_irq(&vb->lock);
 		}
 		rcu_read_unlock();
 	}
@@ -878,21 +905,21 @@ EXPORT_SYMBOL(vm_unmap_ram);
  * @prot: memory protection to use. PAGE_KERNEL for regular RAM
  * @returns: a pointer to the address that has been mapped, or NULL on failure
  */
-void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
+void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot, gfp_t gfp_mask)
 {
 	unsigned long size = count << PAGE_SHIFT;
 	unsigned long addr;
 	void *mem;
 
 	if (likely(count <= VMAP_MAX_ALLOC)) {
-		mem = vb_alloc(size, GFP_KERNEL);
+		mem = vb_alloc(size, gfp_mask);
 		if (IS_ERR(mem))
 			return NULL;
 		addr = (unsigned long)mem;
 	} else {
 		struct vmap_area *va;
 		va = alloc_vmap_area(size, PAGE_SIZE,
-				VMALLOC_START, VMALLOC_END, node, GFP_KERNEL);
+				VMALLOC_START, VMALLOC_END, node, gfp_mask);
 		if (IS_ERR(va))
 			return NULL;
 
Index: linux-2.6/include/linux/vmalloc.h
===================================================================
--- linux-2.6.orig/include/linux/vmalloc.h
+++ linux-2.6/include/linux/vmalloc.h
@@ -38,7 +38,7 @@ struct vm_struct {
  */
 extern void vm_unmap_ram(const void *mem, unsigned int count);
 extern void *vm_map_ram(struct page **pages, unsigned int count,
-				int node, pgprot_t prot);
+				int node, pgprot_t prot, gfp_t gfp_mask);
 extern void vm_unmap_aliases(void);
 
 extern void *vmalloc(unsigned long size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
