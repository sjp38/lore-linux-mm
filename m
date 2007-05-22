Date: Tue, 22 May 2007 09:39:10 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/3] slob: rework freelist handling
Message-ID: <20070522073910.GD17051@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Here are some patches I have been working on for SLOB, which makes
it significantly faster, and also using less dynamic memory... at
the cost of being slightly larger static footprint and more complex
code.

Matt was happy for the first 2 to go into -mm (and hasn't seen patch 3 yet).

--

Improve slob by turning the freelist into a list of pages using struct page
fields, then each page has a singly linked freelist of slob blocks via a
pointer in the struct page.

- The first benefit is that the slob freelists can be indexed by a smaller
  type (2 bytes, if the PAGE_SIZE is reasonable).

- Next is that freeing is much quicker because it does not have to traverse
  the entire freelist. Allocation can be slightly faster too, because we can
  skip almost-full freelist pages completely.

- Slob pages are then freed immediately when they become empty, rather than
  having a periodic timer try to free them. This gives efficiency and memory
  consumption improvement.


Then, we don't encode seperate size and next fields into each slob block,
rather we use the sign bit to distinguish between "size" or "next". Then
size 1 blocks contain a "next" offset, and others contain the "size" in
the first unit and "next" in the second unit.

- This allows minimum slob allocation alignment to go from 8 bytes to 2
  bytes on 32-bit and 12 bytes to 2 bytes on 64-bit. In practice, it is
  best to align them to word size, however some architectures (eg. cris)
  could gain space savings from turning off this extra alignment.


Then, make kmalloc use its own slob_block at the front of the allocation
in order to encode allocation size, rather than rely on not overwriting
slob's existing header block.

- This reduces kmalloc allocation overhead similarly to alignment reductions.

- Decouples kmalloc layer from the slob allocator.


Then, add a page flag specific to slob pages.

- This means kfree of a page aligned slob block doesn't have to traverse
  the bigblock list.


I would get benchmarks, but my test box's network doesn't come up with
slob before this patch. I think something is timing out. Anyway, things
are faster after the patch.

Code size goes up about 1K, however dynamic memory usage _should_ be
lower even on relatively small memory systems.

Future todo item is to restore the cyclic free list search, rather than
to always begin at the start.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 mm/slob.c |  271 +++++++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 200 insertions(+), 71 deletions(-)

Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c
+++ linux-2.6/mm/slob.c
@@ -7,53 +7,148 @@
  *
  * The core of SLOB is a traditional K&R style heap allocator, with
  * support for returning aligned objects. The granularity of this
- * allocator is 8 bytes on x86, though it's perhaps possible to reduce
- * this to 4 if it's deemed worth the effort. The slob heap is a
- * singly-linked list of pages from __get_free_page, grown on demand
- * and allocation from the heap is currently first-fit.
+ * allocator is 4 bytes on 32-bit and 8 bytes on 64-bit, though it
+ * could be as low as 2 if the compiler alignment requirements allow.
+ *
+ * The slob heap is a linked list of pages from __get_free_page, and
+ * within each page, there is a singly-linked list of free blocks (slob_t).
+ * The heap is grown on demand and allocation from the heap is currently
+ * first-fit.
  *
  * Above this is an implementation of kmalloc/kfree. Blocks returned
- * from kmalloc are 8-byte aligned and prepended with a 8-byte header.
+ * from kmalloc are 4-byte aligned and prepended with a 4-byte header.
  * If kmalloc is asked for objects of PAGE_SIZE or larger, it calls
  * __get_free_pages directly so that it can return page-aligned blocks
  * and keeps a linked list of such pages and their orders. These
  * objects are detected in kfree() by their page alignment.
  *
  * SLAB is emulated on top of SLOB by simply calling constructors and
- * destructors for every SLAB allocation. Objects are returned with
- * the 8-byte alignment unless the SLAB_HWCACHE_ALIGN flag is
- * set, in which case the low-level allocator will fragment blocks to
- * create the proper alignment. Again, objects of page-size or greater
- * are allocated by calling __get_free_pages. As SLAB objects know
- * their size, no separate size bookkeeping is necessary and there is
- * essentially no allocation space overhead.
+ * destructors for every SLAB allocation. Objects are returned with the
+ * 4-byte alignment unless the SLAB_HWCACHE_ALIGN flag is set, in which
+ * case the low-level allocator will fragment blocks to create the proper
+ * alignment. Again, objects of page-size or greater are allocated by
+ * calling __get_free_pages. As SLAB objects know their size, no separate
+ * size bookkeeping is necessary and there is essentially no allocation
+ * space overhead.
  */
 
+#include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/cache.h>
 #include <linux/init.h>
 #include <linux/module.h>
-#include <linux/timer.h>
 #include <linux/rcupdate.h>
+#include <linux/list.h>
+#include <asm/atomic.h>
+
+/* SLOB_MIN_ALIGN == sizeof(long) */
+#if BITS_PER_BYTE == 32
+#define SLOB_MIN_ALIGN	4
+#else
+#define SLOB_MIN_ALIGN	8
+#endif
+
+/*
+ * slob_block has a field 'units', which indicates size of block if +ve,
+ * or offset of next block if -ve (in SLOB_UNITs).
+ *
+ * Free blocks of size 1 unit simply contain the offset of the next block.
+ * Those with larger size contain their size in the first SLOB_UNIT of
+ * memory, and the offset of the next free block in the second SLOB_UNIT.
+ */
+#if PAGE_SIZE <= (32767 * SLOB_MIN_ALIGN)
+typedef s16 slobidx_t;
+#else
+typedef s32 slobidx_t;
+#endif
 
+/*
+ * Align struct slob_block to long for now, but can some embedded
+ * architectures get away with less?
+ */
 struct slob_block {
-	int units;
-	struct slob_block *next;
-};
+	slobidx_t units;
+} __attribute__((aligned(SLOB_MIN_ALIGN)));
 typedef struct slob_block slob_t;
 
+/*
+ * We use struct page fields to manage some slob allocation aspects,
+ * however to avoid the horrible mess in include/linux/mm_types.h, we'll
+ * just define our own struct page type variant here.
+ */
+struct slob_page {
+	union {
+		struct {
+			unsigned long flags;	/* mandatory */
+			atomic_t _count;	/* mandatory */
+			slobidx_t units;	/* free units left in page */
+			unsigned long pad[2];
+			slob_t *free;		/* first free slob_t in page */
+			struct list_head list;	/* linked list of free pages */
+		};
+		struct page page;
+	};
+};
+static inline void struct_slob_page_wrong_size(void)
+{ BUILD_BUG_ON(sizeof(struct slob_page) != sizeof(struct page)); }
+
+/*
+ * free_slob_page: call before a slob_page is returned to the page allocator.
+ */
+static inline void free_slob_page(struct slob_page *sp)
+{
+	reset_page_mapcount(&sp->page);
+	sp->page.mapping = NULL;
+}
+
+/*
+ * All (partially) free slob pages go on this list.
+ */
+static LIST_HEAD(free_slob_pages);
+
+/*
+ * slob_page: True for all slob pages (false for bigblock pages)
+ */
+static inline int slob_page(struct slob_page *sp)
+{
+	return test_bit(PG_active, &sp->flags);
+}
+
+static inline void set_slob_page(struct slob_page *sp)
+{
+	__set_bit(PG_active, &sp->flags);
+}
+
+static inline void clear_slob_page(struct slob_page *sp)
+{
+	__clear_bit(PG_active, &sp->flags);
+}
+
+/*
+ * slob_page_free: true for pages on free_slob_pages list.
+ */
+static inline int slob_page_free(struct slob_page *sp)
+{
+	return test_bit(PG_private, &sp->flags);
+}
+
+static inline void set_slob_page_free(struct slob_page *sp)
+{
+	list_add(&sp->list, &free_slob_pages);
+	__set_bit(PG_private, &sp->flags);
+}
+
+static inline void clear_slob_page_free(struct slob_page *sp)
+{
+	list_del(&sp->list);
+	__clear_bit(PG_private, &sp->flags);
+}
+
 #define SLOB_UNIT sizeof(slob_t)
 #define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT)
 #define SLOB_ALIGN L1_CACHE_BYTES
 
-struct bigblock {
-	int order;
-	void *pages;
-	struct bigblock *next;
-};
-typedef struct bigblock bigblock_t;
-
 /*
  * struct slob_rcu is inserted at the tail of allocated slob blocks, which
  * were created with a SLAB_DESTROY_BY_RCU slab. slob_rcu is used to free
@@ -64,103 +159,240 @@ struct slob_rcu {
 	int size;
 };
 
-static slob_t arena = { .next = &arena, .units = 1 };
-static slob_t *slobfree = &arena;
-static bigblock_t *bigblocks;
+/*
+ * slob_lock protects all slob allocator structures.
+ */
 static DEFINE_SPINLOCK(slob_lock);
-static DEFINE_SPINLOCK(block_lock);
 
-static void slob_free(void *b, int size);
-static void slob_timer_cbk(void);
+/*
+ * Encode the given size and next info into a free slob block s.
+ */
+static void set_slob(slob_t *s, slobidx_t size, slob_t *next)
+{
+	slob_t *base = (slob_t *)((unsigned long)s & PAGE_MASK);
+	slobidx_t offset = next - base;
 
+	if (size > 1) {
+		s[0].units = size;
+		s[1].units = offset;
+	} else
+		s[0].units = -offset;
+}
 
-static void *slob_alloc(size_t size, gfp_t gfp, int align)
+/*
+ * Return the size of a slob block.
+ */
+static slobidx_t slob_units(slob_t *s)
+{
+	if (s->units > 0)
+		return s->units;
+	return 1;
+}
+
+/*
+ * Return the next free slob block pointer after this one.
+ */
+static slob_t *slob_next(slob_t *s)
+{
+	slob_t *base = (slob_t *)((unsigned long)s & PAGE_MASK);
+	slobidx_t next;
+
+	if (s[0].units < 0)
+		next = -s[0].units;
+	else
+		next = s[1].units;
+	return base+next;
+}
+
+/*
+ * Returns true if s is the last free block in its page.
+ */
+static int slob_last(slob_t *s)
+{
+	return !((unsigned long)slob_next(s) & ~PAGE_MASK);
+}
+
+/*
+ * Allocate a slob block within a given slob_page sp.
+ */
+static void *slob_page_alloc(struct slob_page *sp, size_t size, int align)
 {
 	slob_t *prev, *cur, *aligned = 0;
 	int delta = 0, units = SLOB_UNITS(size);
-	unsigned long flags;
 
-	spin_lock_irqsave(&slob_lock, flags);
-	prev = slobfree;
-	for (cur = prev->next; ; prev = cur, cur = cur->next) {
+	for (prev = NULL, cur = sp->free; ; prev = cur, cur = slob_next(cur)) {
+		slobidx_t avail = slob_units(cur);
+
 		if (align) {
 			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
 			delta = aligned - cur;
 		}
-		if (cur->units >= units + delta) { /* room enough? */
+		if (avail >= units + delta) { /* room enough? */
+			slob_t *next;
+
 			if (delta) { /* need to fragment head to align? */
-				aligned->units = cur->units - delta;
-				aligned->next = cur->next;
-				cur->next = aligned;
-				cur->units = delta;
+				next = slob_next(cur);
+				set_slob(aligned, avail - delta, next);
+				set_slob(cur, delta, aligned);
 				prev = cur;
 				cur = aligned;
+				avail = slob_units(cur);
 			}
 
-			if (cur->units == units) /* exact fit? */
-				prev->next = cur->next; /* unlink */
-			else { /* fragment */
-				prev->next = cur + units;
-				prev->next->units = cur->units - units;
-				prev->next->next = cur->next;
-				cur->units = units;
+			next = slob_next(cur);
+			if (avail == units) { /* exact fit? unlink. */
+				if (prev)
+					set_slob(prev, slob_units(prev), next);
+				else
+					sp->free = next;
+			} else { /* fragment */
+				if (prev)
+					set_slob(prev, slob_units(prev), cur + units);
+				else
+					sp->free = cur + units;
+				set_slob(cur + units, avail - units, next);
 			}
 
-			slobfree = prev;
-			spin_unlock_irqrestore(&slob_lock, flags);
+			sp->units -= units;
+			if (!sp->units)
+				clear_slob_page_free(sp);
 			return cur;
 		}
-		if (cur == slobfree) {
-			spin_unlock_irqrestore(&slob_lock, flags);
+		if (slob_last(cur))
+			return NULL;
+	}
+}
 
-			if (size == PAGE_SIZE) /* trying to shrink arena? */
-				return 0;
+/*
+ * slob_alloc: entry point into the slob allocator.
+ */
+static void *slob_alloc(size_t size, gfp_t gfp, int align)
+{
+	struct slob_page *sp;
+	slob_t *b = NULL;
+	unsigned long flags;
 
-			cur = (slob_t *)__get_free_page(gfp);
-			if (!cur)
-				return 0;
-
-			slob_free(cur, PAGE_SIZE);
-			spin_lock_irqsave(&slob_lock, flags);
-			cur = slobfree;
+	spin_lock_irqsave(&slob_lock, flags);
+	/* Iterate through each partially free page, try to find room */
+	list_for_each_entry(sp, &free_slob_pages, list) {
+		if (sp->units >= SLOB_UNITS(size)) {
+			b = slob_page_alloc(sp, size, align);
+			if (b)
+				break;
 		}
 	}
+	spin_unlock_irqrestore(&slob_lock, flags);
+
+	/* Not enough space: must allocate a new page */
+	if (!b) {
+		b = (slob_t *)__get_free_page(gfp);
+		if (!b)
+			return 0;
+		sp = (struct slob_page *)virt_to_page(b);
+		set_slob_page(sp);
+
+		spin_lock_irqsave(&slob_lock, flags);
+		sp->units = SLOB_UNITS(PAGE_SIZE);
+		sp->free = b;
+		INIT_LIST_HEAD(&sp->list);
+		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
+		set_slob_page_free(sp);
+		b = slob_page_alloc(sp, size, align);
+		BUG_ON(!b);
+		spin_unlock_irqrestore(&slob_lock, flags);
+	}
+	return b;
 }
 
+/*
+ * slob_free: entry point into the slob allocator.
+ */
 static void slob_free(void *block, int size)
 {
-	slob_t *cur, *b = (slob_t *)block;
+	struct slob_page *sp;
+	slob_t *prev, *next, *b = (slob_t *)block;
+	slobidx_t units;
 	unsigned long flags;
 
 	if (!block)
 		return;
+	BUG_ON(!size);
 
-	if (size)
-		b->units = SLOB_UNITS(size);
+	sp = (struct slob_page *)virt_to_page(block);
+	units = SLOB_UNITS(size);
 
-	/* Find reinsertion point */
 	spin_lock_irqsave(&slob_lock, flags);
-	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
-		if (cur >= cur->next && (b > cur || b < cur->next))
-			break;
-
-	if (b + b->units == cur->next) {
-		b->units += cur->next->units;
-		b->next = cur->next->next;
-	} else
-		b->next = cur->next;
 
-	if (cur + cur->units == b) {
-		cur->units += b->units;
-		cur->next = b->next;
-	} else
-		cur->next = b;
+	if (sp->units + units == SLOB_UNITS(PAGE_SIZE)) {
+		/* Go directly to page allocator. Do not pass slob allocator */
+		if (slob_page_free(sp))
+			clear_slob_page_free(sp);
+		clear_slob_page(sp);
+		free_slob_page(sp);
+		free_page((unsigned long)b);
+		goto out;
+	}
 
-	slobfree = cur;
+	if (!slob_page_free(sp)) {
+		/* This slob page is about to become partially free. Easy! */
+		sp->units = units;
+		sp->free = b;
+		set_slob(b, units,
+			(void *)((unsigned long)(b +
+					SLOB_UNITS(PAGE_SIZE)) & PAGE_MASK));
+		set_slob_page_free(sp);
+		goto out;
+	}
+
+	/*
+	 * Otherwise the page is already partially free, so find reinsertion
+	 * point.
+	 */
+	sp->units += units;
+
+	if (b < sp->free) {
+		set_slob(b, units, sp->free);
+		sp->free = b;
+	} else {
+		prev = sp->free;
+		next = slob_next(prev);
+		while (b > next) {
+			prev = next;
+			next = slob_next(prev);
+		}
 
+		if (!slob_last(prev) && b + units == next) {
+			units += slob_units(next);
+			set_slob(b, units, slob_next(next));
+		} else
+			set_slob(b, units, next);
+
+		if (prev + slob_units(prev) == b) {
+			units = slob_units(b) + slob_units(prev);
+			set_slob(prev, units, slob_next(b));
+		} else
+			set_slob(prev, slob_units(prev), b);
+	}
+out:
 	spin_unlock_irqrestore(&slob_lock, flags);
 }
 
+/*
+ * End of slob allocator proper. Begin kmem_cache_alloc and kmalloc frontend.
+ */
+
+struct bigblock {
+	int order;
+	void *pages;
+	struct bigblock *next;
+};
+typedef struct bigblock bigblock_t;
+
+static bigblock_t *bigblocks;
+
+static DEFINE_SPINLOCK(block_lock);
+
+
 void *__kmalloc(size_t size, gfp_t gfp)
 {
 	slob_t *m;
@@ -169,7 +401,9 @@ void *__kmalloc(size_t size, gfp_t gfp)
 
 	if (size < PAGE_SIZE - SLOB_UNIT) {
 		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
-		return m ? (void *)(m + 1) : 0;
+		if (m)
+			m->units = size;
+		return m+1;
 	}
 
 	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
@@ -227,14 +461,17 @@ EXPORT_SYMBOL(krealloc);
 
 void kfree(const void *block)
 {
+	struct slob_page *sp;
+	slob_t *m;
 	bigblock_t *bb, **last = &bigblocks;
 	unsigned long flags;
 
 	if (!block)
 		return;
 
-	if (!((unsigned long)block & (PAGE_SIZE-1))) {
-		/* might be on the big block list */
+	sp = (struct slob_page *)virt_to_page(block);
+	if (!slob_page(sp)) {
+		/* on the big block list */
 		spin_lock_irqsave(&block_lock, flags);
 		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
 			if (bb->pages == block) {
@@ -246,9 +483,12 @@ void kfree(const void *block)
 			}
 		}
 		spin_unlock_irqrestore(&block_lock, flags);
+		WARN_ON(1);
+		return;
 	}
 
-	slob_free((slob_t *)block - 1, 0);
+	m = (slob_t *)block - 1;
+	slob_free(m, m->units + SLOB_UNIT);
 	return;
 }
 
@@ -256,13 +496,15 @@ EXPORT_SYMBOL(kfree);
 
 size_t ksize(const void *block)
 {
+	struct slob_page *sp;
 	bigblock_t *bb;
 	unsigned long flags;
 
 	if (!block)
 		return 0;
 
-	if (!((unsigned long)block & (PAGE_SIZE-1))) {
+	sp = (struct slob_page *)virt_to_page(block);
+	if (!slob_page(sp)) {
 		spin_lock_irqsave(&block_lock, flags);
 		for (bb = bigblocks; bb; bb = bb->next)
 			if (bb->pages == block) {
@@ -272,7 +514,7 @@ size_t ksize(const void *block)
 		spin_unlock_irqrestore(&block_lock, flags);
 	}
 
-	return ((slob_t *)block - 1)->units * SLOB_UNIT;
+	return ((slob_t *)block - 1)->units + SLOB_UNIT;
 }
 
 struct kmem_cache {
@@ -385,9 +627,6 @@ const char *kmem_cache_name(struct kmem_
 }
 EXPORT_SYMBOL(kmem_cache_name);
 
-static struct timer_list slob_timer = TIMER_INITIALIZER(
-	(void (*)(unsigned long))slob_timer_cbk, 0, 0);
-
 int kmem_cache_shrink(struct kmem_cache *d)
 {
 	return 0;
@@ -401,15 +640,4 @@ int kmem_ptr_validate(struct kmem_cache 
 
 void __init kmem_cache_init(void)
 {
-	slob_timer_cbk();
-}
-
-static void slob_timer_cbk(void)
-{
-	void *p = slob_alloc(PAGE_SIZE, 0, PAGE_SIZE-1);
-
-	if (p)
-		free_page((unsigned long)p);
-
-	mod_timer(&slob_timer, jiffies + HZ);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
