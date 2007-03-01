Message-ID: <45E6EEC5.4060902@yahoo.com.au>
Date: Fri, 02 Mar 2007 02:18:29 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Remove page flags for software suspend
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <20070228101403.GA8536@elf.ucw.cz> <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com> <200702281813.04643.rjw@sisk.pl>
In-Reply-To: <200702281813.04643.rjw@sisk.pl>
Content-Type: multipart/mixed;
 boundary="------------080306070500080903020309"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080306070500080903020309
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Rafael J. Wysocki wrote:
> On Wednesday, 28 February 2007 16:25, Christoph Lameter wrote:
> 
>>On Wed, 28 Feb 2007, Pavel Machek wrote:
>>
>>
>>>I... actually do not like that patch. It adds code... at little or no
>>>benefit.
>>
>>We are looking into saving page flags since we are running out. The two 
>>page flags used by software suspend are rarely needed and should be taken 
>>out of the flags. If you can do it a different way then please do.
> 
> 
> As I have already said for a couple of times, I think we can and I'm going to
> do it, but right now I'm a bit busy with other things that I consider as more
> urgent.

I need one bit for lockless pagecache ;)

Anyway, I guess if you want something done you have to do it yourself.

This patch still needs work (and I don't know if it even works, because
I can't make swsusp resume even on a vanilla kernel). But this is my
WIP for removing swsusp page flags.

This patch adds a simple extent based nosave region tracker, and
rearranges some of the snapshot code to be a bit simpler and more
amenable to having dynamically allocated flags (they aren't actually
dynamically allocated in this patch, however).

-- 
SUSE Labs, Novell Inc.

--------------080306070500080903020309
Content-Type: text/plain;
 name="swsusp-Nosave-use-extents.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="swsusp-Nosave-use-extents.patch"

---
 arch/x86_64/kernel/e820.c  |    8 --
 include/linux/page-flags.h |   33 ++++----
 include/linux/suspend.h    |   12 ++-
 kernel/power/Makefile      |    2 
 kernel/power/main.c        |    4 +
 kernel/power/nosave.c      |  103 +++++++++++++++++++++++++++
 kernel/power/power.h       |    1 
 kernel/power/snapshot.c    |  167 ++++++++++++++++++++++-----------------------
 mm/page_alloc.c            |   34 ---------
 9 files changed, 222 insertions(+), 142 deletions(-)

Index: linux-2.6/include/linux/suspend.h
===================================================================
--- linux-2.6.orig/include/linux/suspend.h	2007-03-02 01:51:08.000000000 +1100
+++ linux-2.6/include/linux/suspend.h	2007-03-02 02:06:07.000000000 +1100
@@ -21,7 +21,6 @@ struct pbe {
 
 /* mm/page_alloc.c */
 extern void drain_local_pages(void);
-extern void mark_free_pages(struct zone *zone);
 
 #ifdef CONFIG_PM
 /* kernel/power/swsusp.c */
@@ -42,6 +41,17 @@ static inline int software_suspend(void)
 }
 #endif /* CONFIG_PM */
 
+#ifdef CONFIG_SOFTWARE_SUSPEND
+/* kernel/power/nosave.c */
+extern int __init register_nosave_region(unsigned long start_pfn, unsigned long end_pfn);
+#else
+static inline int register_nosave_region(unsigned long start_pfn, unsigned long end_pfn)
+{
+	return 0;
+}
+#endif
+
+
 void save_processor_state(void);
 void restore_processor_state(void);
 struct saved_context;
Index: linux-2.6/kernel/power/Makefile
===================================================================
--- linux-2.6.orig/kernel/power/Makefile	2007-03-02 01:51:08.000000000 +1100
+++ linux-2.6/kernel/power/Makefile	2007-03-02 02:06:07.000000000 +1100
@@ -5,6 +5,6 @@ endif
 
 obj-y				:= main.o process.o console.o
 obj-$(CONFIG_PM_LEGACY)		+= pm.o
-obj-$(CONFIG_SOFTWARE_SUSPEND)	+= swsusp.o disk.o snapshot.o swap.o user.o
+obj-$(CONFIG_SOFTWARE_SUSPEND)	+= swsusp.o disk.o snapshot.o swap.o user.o nosave.o
 
 obj-$(CONFIG_MAGIC_SYSRQ)	+= poweroff.o
Index: linux-2.6/kernel/power/nosave.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/kernel/power/nosave.c	2007-03-02 02:06:07.000000000 +1100
@@ -0,0 +1,103 @@
+/*
+ * Provide a way of tracking a set of "nosave" pfn ranges, registered by
+ * architecture code, and used by swsusp when deciding what memory to
+ * save.
+ */
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/rbtree.h>
+#include <linux/spinlock.h>
+#include <linux/slab.h>
+#include <linux/suspend.h>
+
+struct nosave_extent {
+	struct rb_node rb_node;
+	unsigned long start;
+	unsigned long end;
+};
+
+static spinlock_t nosave_lock = SPIN_LOCK_UNLOCKED;
+static struct rb_root nosave_extents = RB_ROOT;
+
+#define rb_entry_extent(node)	rb_entry(node, struct nosave_extent, rb_node)
+#define rb_next_extent(node)	rb_entry_extent(rb_next(node))
+#define rb_prev_extent(node)	rb_entry_extent(rb_prev(node))
+
+static int __is_nosave_region(unsigned long start_pfn, unsigned long end_pfn)
+{
+	struct rb_node *n = nosave_extents.rb_node;
+
+	BUG_ON(end_pfn < start_pfn);
+
+	while (n) {
+		struct nosave_extent *ext = rb_entry_extent(n);
+
+		if (start_pfn < ext->start) {
+			if (end_pfn >= ext->start)
+				return 1;
+			n = n->rb_left;
+		} else if (end_pfn > ext->end) {
+			if (start_pfn <= ext->end)
+				return 1;
+			n = n->rb_right;
+		} else
+			return 1;
+	}
+
+	return 0;
+}
+
+static int is_nosave_region(unsigned long start_pfn, unsigned long end_pfn)
+{
+	int ret;
+	spin_lock(&nosave_lock);
+	ret = __is_nosave_region(start_pfn, end_pfn);
+	spin_unlock(&nosave_lock);
+	return ret;
+}
+
+int __init register_nosave_region(unsigned long start_pfn, unsigned long end_pfn)
+{
+	struct rb_node **p = &nosave_extents.rb_node;
+	struct rb_node *parent = NULL;
+	struct nosave_extent *ext, *new_extent;
+	int ret = 0;
+
+	spin_lock(&nosave_lock);
+	if (__is_nosave_region(start_pfn, end_pfn)) {
+		ret = -EEXIST;
+		goto out;
+	}
+
+	new_extent = kmalloc(sizeof(struct nosave_extent), GFP_ATOMIC);
+	if (!new_extent) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	new_extent->start = start_pfn;
+	new_extent->end = end_pfn;
+
+	while (*p) {
+		parent = *p;
+		ext = rb_entry_extent(parent);
+
+		if (start_pfn < ext->start)
+			p = &(*p)->rb_left;
+		else if (start_pfn > ext->start)
+			p = &(*p)->rb_right;
+		else
+			BUG();
+	}
+
+	rb_link_node(&new_extent->rb_node, parent, p);
+	rb_insert_color(&new_extent->rb_node, &nosave_extents);
+
+out:
+	spin_unlock(&nosave_lock);
+	return ret;
+}
+
+int is_nosave_pfn(unsigned long pfn)
+{
+	return is_nosave_region(pfn, pfn);
+}
Index: linux-2.6/kernel/power/power.h
===================================================================
--- linux-2.6.orig/kernel/power/power.h	2007-03-02 01:51:08.000000000 +1100
+++ linux-2.6/kernel/power/power.h	2007-03-02 02:06:07.000000000 +1100
@@ -15,6 +15,7 @@ struct swsusp_info {
 
 #ifdef CONFIG_SOFTWARE_SUSPEND
 extern int pm_suspend_disk(void);
+extern int is_nosave_pfn(unsigned long pfn);
 
 #else
 static inline int pm_suspend_disk(void)
Index: linux-2.6/kernel/power/snapshot.c
===================================================================
--- linux-2.6.orig/kernel/power/snapshot.c	2007-03-02 01:51:08.000000000 +1100
+++ linux-2.6/kernel/power/snapshot.c	2007-03-02 02:16:10.000000000 +1100
@@ -47,17 +47,15 @@ static void *buffer;
 /**
  *	@safe_needed - on resume, for storing the PBE list and the image,
  *	we can only use memory pages that do not conflict with the pages
- *	used before suspend.  The unsafe pages have PageNosaveFree set
- *	and we count them using unsafe_pages.
+ *	saved before suspend. mark_saved_pages finds these and marks them
+ *	with PageSwsuspSaved.
  *
- *	Each allocated image page is marked as PageNosave and PageNosaveFree
- *	so that swsusp_free() can release it.
+ *	Each allocated image page is marked as PageSwsuspImage so that
+ *	swsusp_free() will release it.
  */
 
 #define PG_ANY		0
 #define PG_SAFE		1
-#define PG_UNSAFE_CLEAR	1
-#define PG_UNSAFE_KEEP	0
 
 static unsigned int allocated_unsafe_pages;
 
@@ -66,21 +64,24 @@ static void *get_image_page(gfp_t gfp_ma
 	void *res;
 
 	res = (void *)get_zeroed_page(gfp_mask);
-	if (safe_needed)
-		while (res && PageNosaveFree(virt_to_page(res))) {
-			/* The page is unsafe, mark it for swsusp_free() */
-			SetPageNosave(virt_to_page(res));
+#if 0
+	if (safe_needed) /* XXX: should _always_ allocate "safe" pages */
+#endif
+		while (res && PageSwsuspSaved(virt_to_page(res))) {
+			/*
+			 * Not actually an image page, but we must mark it
+			 * as such for swsusp_free()
+			 */
+			SetPageSwsuspImage(virt_to_page(res));
 			allocated_unsafe_pages++;
 			res = (void *)get_zeroed_page(gfp_mask);
 		}
-	if (res) {
-		SetPageNosave(virt_to_page(res));
-		SetPageNosaveFree(virt_to_page(res));
-	}
+	if (res)
+		SetPageSwsuspImage(virt_to_page(res));
 	return res;
 }
 
-unsigned long get_safe_page(gfp_t gfp_mask)
+unsigned long get_safe_page(gfp_t gfp_mask) /*  XXX: used in arch code */
 {
 	return (unsigned long)get_image_page(gfp_mask, PG_SAFE);
 }
@@ -90,10 +91,8 @@ static struct page *alloc_image_page(gfp
 	struct page *page;
 
 	page = alloc_page(gfp_mask);
-	if (page) {
-		SetPageNosave(page);
-		SetPageNosaveFree(page);
-	}
+	if (page)
+		SetPageSwsuspImage(page);
 	return page;
 }
 
@@ -102,7 +101,7 @@ static struct page *alloc_image_page(gfp
  *	get_image_page (page flags set by it must be cleared)
  */
 
-static inline void free_image_page(void *addr, int clear_nosave_free)
+static inline void free_image_page(void *addr)
 {
 	struct page *page;
 
@@ -110,9 +109,8 @@ static inline void free_image_page(void 
 
 	page = virt_to_page(addr);
 
-	ClearPageNosave(page);
-	if (clear_nosave_free)
-		ClearPageNosaveFree(page);
+	BUG_ON(!PageSwsuspImage(page));
+	ClearPageSwsuspImage(page);
 
 	__free_page(page);
 }
@@ -127,12 +125,12 @@ struct linked_page {
 } __attribute__((packed));
 
 static inline void
-free_list_of_pages(struct linked_page *list, int clear_page_nosave)
+free_list_of_pages(struct linked_page *list)
 {
 	while (list) {
 		struct linked_page *lp = list->next;
 
-		free_image_page(list, clear_page_nosave);
+		free_image_page(list);
 		list = lp;
 	}
 }
@@ -188,9 +186,9 @@ static void *chain_alloc(struct chain_al
 	return ret;
 }
 
-static void chain_free(struct chain_allocator *ca, int clear_page_nosave)
+static void chain_free(struct chain_allocator *ca)
 {
-	free_list_of_pages(ca->chain, clear_page_nosave);
+	free_list_of_pages(ca->chain);
 	memset(ca, 0, sizeof(struct chain_allocator));
 }
 
@@ -289,7 +287,7 @@ static void memory_bm_position_reset(str
 	memory_bm_reset_chunk(bm);
 }
 
-static void memory_bm_free(struct memory_bitmap *bm, int clear_nosave_free);
+static void memory_bm_free(struct memory_bitmap *bm);
 
 /**
  *	create_bm_block_list - create a list of block bitmap objects
@@ -360,7 +358,7 @@ memory_bm_create(struct memory_bitmap *b
 	zone_bm = create_zone_bm_list(nr, &ca);
 	bm->zone_bm_list = zone_bm;
 	if (!zone_bm) {
-		chain_free(&ca, PG_UNSAFE_CLEAR);
+		chain_free(&ca);
 		return -ENOMEM;
 	}
 
@@ -413,7 +411,7 @@ memory_bm_create(struct memory_bitmap *b
 
  Free:
 	bm->p_list = ca.chain;
-	memory_bm_free(bm, PG_UNSAFE_CLEAR);
+	memory_bm_free(bm);
 	return -ENOMEM;
 }
 
@@ -421,7 +419,7 @@ memory_bm_create(struct memory_bitmap *b
   *	memory_bm_free - free memory occupied by the memory bitmap @bm
   */
 
-static void memory_bm_free(struct memory_bitmap *bm, int clear_nosave_free)
+static void memory_bm_free(struct memory_bitmap *bm)
 {
 	struct zone_bitmap *zone_bm;
 
@@ -433,12 +431,12 @@ static void memory_bm_free(struct memory
 		bb = zone_bm->bm_blocks;
 		while (bb) {
 			if (bb->data)
-				free_image_page(bb->data, clear_nosave_free);
+				free_image_page(bb->data);
 			bb = bb->next;
 		}
 		zone_bm = zone_bm->next;
 	}
-	free_list_of_pages(bm->p_list, clear_nosave_free);
+	free_list_of_pages(bm->p_list);
 	bm->zone_bm_list = NULL;
 }
 
@@ -600,8 +598,9 @@ static unsigned int count_free_highmem_p
  *	saveable_highmem_page - Determine whether a highmem page should be
  *	included in the suspend image.
  *
- *	We should save the page if it isn't Nosave or NosaveFree, or Reserved,
- *	and it isn't a part of a free chunk of pages.
+ *	We should save the page if it isn't in a nosave_pfn region, and if
+ *	it isn't already free (page_count()==0), and if it isn't part of our
+ *	suspend image.
  */
 
 static struct page *saveable_highmem_page(unsigned long pfn)
@@ -611,11 +610,22 @@ static struct page *saveable_highmem_pag
 	if (!pfn_valid(pfn))
 		return NULL;
 
+	if (is_nosave_pfn(pfn))
+		return NULL;
+
 	page = pfn_to_page(pfn);
 
 	BUG_ON(!PageHighMem(page));
 
-	if (PageNosave(page) || PageReserved(page) || PageNosaveFree(page))
+	/* XXX: this is racy if there is other stuff running... we
+	 * could just use the free page count to estimate this for
+	 * use in shrink_memory.
+	 */
+	if (page_count(page) == 0)
+		return NULL;
+
+	/* XXX: really need to check PageReserved? */
+	if (PageReserved(page) || PageSwsuspImage(page))
 		return NULL;
 
 	return page;
@@ -637,7 +647,6 @@ unsigned int count_highmem_pages(void)
 		if (!is_highmem(zone))
 			continue;
 
-		mark_free_pages(zone);
 		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 			if (saveable_highmem_page(pfn))
@@ -651,23 +660,11 @@ static inline unsigned int count_highmem
 #endif /* CONFIG_HIGHMEM */
 
 /**
- *	pfn_is_nosave - check if given pfn is in the 'nosave' section
- */
-
-static inline int pfn_is_nosave(unsigned long pfn)
-{
-	unsigned long nosave_begin_pfn = __pa(&__nosave_begin) >> PAGE_SHIFT;
-	unsigned long nosave_end_pfn = PAGE_ALIGN(__pa(&__nosave_end)) >> PAGE_SHIFT;
-	return (pfn >= nosave_begin_pfn) && (pfn < nosave_end_pfn);
-}
-
-/**
  *	saveable - Determine whether a non-highmem page should be included in
  *	the suspend image.
  *
- *	We should save the page if it isn't Nosave, and is not in the range
- *	of pages statically defined as 'unsaveable', and it isn't a part of
- *	a free chunk of pages.
+ *	We should save the page based on criteria similar to
+ *	saveable_highmem_page.
  */
 
 static struct page *saveable_page(unsigned long pfn)
@@ -677,14 +674,17 @@ static struct page *saveable_page(unsign
 	if (!pfn_valid(pfn))
 		return NULL;
 
+	if (is_nosave_pfn(pfn))
+		return NULL;
+
 	page = pfn_to_page(pfn);
 
 	BUG_ON(PageHighMem(page));
 
-	if (PageNosave(page) || PageNosaveFree(page))
+	if (page_count(page) == 0)
 		return NULL;
 
-	if (PageReserved(page) && pfn_is_nosave(pfn))
+	if (PageSwsuspImage(page))
 		return NULL;
 
 	return page;
@@ -705,7 +705,6 @@ unsigned int count_data_pages(void)
 		if (is_highmem(zone))
 			continue;
 
-		mark_free_pages(zone);
 		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 			if(saveable_page(pfn))
@@ -783,11 +782,14 @@ copy_data_pages(struct memory_bitmap *co
 	for_each_zone(zone) {
 		unsigned long max_zone_pfn;
 
-		mark_free_pages(zone);
 		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
-		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
-			if (page_is_saveable(zone, pfn))
+		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++) {
+			struct page *page = page_is_saveable(zone, pfn);
+			if (page) {
+				SetPageSwsuspSaved(page);
 				memory_bm_set_bit(orig_bm, pfn);
+			}
+		}
 	}
 	memory_bm_position_reset(orig_bm);
 	memory_bm_position_reset(copy_bm);
@@ -821,9 +823,10 @@ void swsusp_free(void)
 			if (pfn_valid(pfn)) {
 				struct page *page = pfn_to_page(pfn);
 
-				if (PageNosave(page) && PageNosaveFree(page)) {
-					ClearPageNosave(page);
-					ClearPageNosaveFree(page);
+				if (PageSwsuspSaved(page))
+					ClearPageSwsuspSaved(page);
+				if (PageSwsuspImage(page)) {
+					ClearPageSwsuspImage(page);
 					__free_page(page);
 				}
 			}
@@ -1131,22 +1134,21 @@ int snapshot_read_next(struct snapshot_h
 }
 
 /**
- *	mark_unsafe_pages - mark the pages that cannot be used for storing
+ *	mark_saved_pages - mark the pages that cannot be used for storing
  *	the image during resume, because they conflict with the pages that
- *	had been used before suspend
+ *	had been in use before suspending (ie. they were "saved").
  */
 
-static int mark_unsafe_pages(struct memory_bitmap *bm)
+static int mark_saved_pages(struct memory_bitmap *bm)
 {
 	struct zone *zone;
 	unsigned long pfn, max_zone_pfn;
 
-	/* Clear page flags */
+	/* Check page flags */
 	for_each_zone(zone) {
 		max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
 		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
-			if (pfn_valid(pfn))
-				ClearPageNosaveFree(pfn_to_page(pfn));
+			WARN_ON(pfn_valid(pfn) && PageSwsuspSaved(pfn_to_page(pfn)));
 	}
 
 	/* Mark pages that correspond to the "original" pfns as "unsafe" */
@@ -1155,7 +1157,7 @@ static int mark_unsafe_pages(struct memo
 		pfn = memory_bm_next_pfn(bm);
 		if (likely(pfn != BM_END_OF_MAP)) {
 			if (likely(pfn_valid(pfn)))
-				SetPageNosaveFree(pfn_to_page(pfn));
+				SetPageSwsuspSaved(pfn_to_page(pfn));
 			else
 				return -EFAULT;
 		}
@@ -1321,14 +1323,13 @@ prepare_highmem_image(struct memory_bitm
 		struct page *page;
 
 		page = alloc_page(__GFP_HIGHMEM);
-		if (!PageNosaveFree(page)) {
+		if (!PageSwsuspSaved(page)) {
 			/* The page is "safe", set its bit the bitmap */
 			memory_bm_set_bit(bm, page_to_pfn(page));
 			safe_highmem_pages++;
 		}
 		/* Mark the page as allocated */
-		SetPageNosave(page);
-		SetPageNosaveFree(page);
+		SetPageSwsuspImage(page);
 	}
 	memory_bm_position_reset(bm);
 	safe_highmem_bm = bm;
@@ -1360,7 +1361,7 @@ get_highmem_page_buffer(struct page *pag
 	struct highmem_pbe *pbe;
 	void *kaddr;
 
-	if (PageNosave(page) && PageNosaveFree(page)) {
+	if (PageSwsuspSaved(page) && PageSwsuspImage(page)) {
 		/* We have allocated the "original" page frame and we can
 		 * use it directly to store the loaded page.
 		 */
@@ -1422,10 +1423,10 @@ static inline int last_highmem_page_copi
 static inline void free_highmem_data(void)
 {
 	if (safe_highmem_bm)
-		memory_bm_free(safe_highmem_bm, PG_UNSAFE_CLEAR);
+		memory_bm_free(safe_highmem_bm);
 
 	if (buffer)
-		free_image_page(buffer, PG_UNSAFE_CLEAR);
+		free_image_page(buffer);
 }
 #else
 static inline int get_safe_write_buffer(void) { return 0; }
@@ -1474,11 +1475,11 @@ prepare_image(struct memory_bitmap *new_
 	int error;
 
 	/* If there is no highmem, the buffer will not be necessary */
-	free_image_page(buffer, PG_UNSAFE_CLEAR);
+	free_image_page(buffer);
 	buffer = NULL;
 
 	nr_highmem = count_highmem_image_pages(bm);
-	error = mark_unsafe_pages(bm);
+	error = mark_saved_pages(bm);
 	if (error)
 		goto Free;
 
@@ -1487,7 +1488,8 @@ prepare_image(struct memory_bitmap *new_
 		goto Free;
 
 	duplicate_memory_bitmap(new_bm, bm);
-	memory_bm_free(bm, PG_UNSAFE_KEEP);
+	memory_bm_free(bm);
+
 	if (nr_highmem > 0) {
 		error = prepare_highmem_image(bm, &nr_highmem);
 		if (error)
@@ -1522,20 +1524,19 @@ prepare_image(struct memory_bitmap *new_
 			error = -ENOMEM;
 			goto Free;
 		}
-		if (!PageNosaveFree(virt_to_page(lp))) {
+		if (!PageSwsuspSaved(virt_to_page(lp))) {
 			/* The page is "safe", add it to the list */
 			lp->next = safe_pages_list;
 			safe_pages_list = lp;
 		}
 		/* Mark the page as allocated */
-		SetPageNosave(virt_to_page(lp));
-		SetPageNosaveFree(virt_to_page(lp));
+		SetPageSwsuspImage(virt_to_page(lp));
 		nr_pages--;
 	}
 	/* Free the reserved safe pages so that chain_alloc() can use them */
 	while (sp_list) {
 		lp = sp_list->next;
-		free_image_page(sp_list, PG_UNSAFE_CLEAR);
+		free_image_page(sp_list);
 		sp_list = lp;
 	}
 	return 0;
@@ -1558,7 +1559,7 @@ static void *get_buffer(struct memory_bi
 	if (PageHighMem(page))
 		return get_highmem_page_buffer(page, ca);
 
-	if (PageNosave(page) && PageNosaveFree(page))
+	if (PageSwsuspSaved(page) && PageSwsuspImage(page))
 		/* We have allocated the "original" page frame and we can
 		 * use it directly to store the loaded page.
 		 */
@@ -1680,7 +1681,7 @@ void snapshot_write_finalize(struct snap
 	copy_last_highmem_page();
 	/* Free only if we have loaded the image entirely */
 	if (handle->prev && handle->cur > nr_meta_pages + nr_copy_pages) {
-		memory_bm_free(&orig_bm, PG_UNSAFE_CLEAR);
+		memory_bm_free(&orig_bm);
 		free_highmem_data();
 	}
 }
@@ -1733,7 +1734,7 @@ int restore_highmem(void)
 		swap_two_pages_data(pbe->copy_page, pbe->orig_page, buf);
 		pbe = pbe->next;
 	}
-	free_image_page(buf, PG_UNSAFE_CLEAR);
+	free_image_page(buf);
 	return 0;
 }
 #endif /* CONFIG_HIGHMEM */
Index: linux-2.6/arch/x86_64/kernel/e820.c
===================================================================
--- linux-2.6.orig/arch/x86_64/kernel/e820.c	2007-03-02 01:51:09.000000000 +1100
+++ linux-2.6/arch/x86_64/kernel/e820.c	2007-03-02 02:06:07.000000000 +1100
@@ -259,16 +259,12 @@ void __init e820_reserve_resources(void)
 static void __init
 e820_mark_nosave_range(unsigned long start, unsigned long end)
 {
-	unsigned long pfn, max_pfn;
-
 	if (start >= end)
 		return;
 
 	printk("Nosave address range: %016lx - %016lx\n", start, end);
-	max_pfn = end >> PAGE_SHIFT;
-	for (pfn = start >> PAGE_SHIFT; pfn < max_pfn; pfn++)
-		if (pfn_valid(pfn))
-			SetPageNosave(pfn_to_page(pfn));
+	if (register_nosave_region(start >> PAGE_SHIFT, end >> PAGE_SHIFT))
+		panic("Could not register nosave region\n");
 }
 
 /*
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2007-03-02 01:51:08.000000000 +1100
+++ linux-2.6/include/linux/page-flags.h	2007-03-02 02:06:07.000000000 +1100
@@ -82,14 +82,15 @@
 #define PG_private		11	/* If pagecache, has fs-private data */
 
 #define PG_writeback		12	/* Page is under writeback */
-#define PG_nosave		13	/* Used for system suspend/resume */
-#define PG_compound		14	/* Part of a compound page */
-#define PG_swapcache		15	/* Swap page: swp_entry_t in private */
-
-#define PG_mappedtodisk		16	/* Has blocks allocated on-disk */
-#define PG_reclaim		17	/* To be reclaimed asap */
-#define PG_nosave_free		18	/* Used for system suspend/resume */
-#define PG_buddy		19	/* Page is free, on buddy lists */
+#define PG_compound		13	/* Part of a compound page */
+#define PG_swapcache		14	/* Swap page: swp_entry_t in private */
+#define PG_mappedtodisk		15	/* Has blocks allocated on-disk */
+
+#define PG_reclaim		16	/* To be reclaimed asap */
+#define PG_buddy		17	/* Page is free, on buddy lists */
+
+#define PG_swsusp_image		18
+#define PG_swsusp_saved		19
 
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
@@ -214,15 +215,13 @@ static inline void SetPageUptodate(struc
 		ret;							\
 	})
 
-#define PageNosave(page)	test_bit(PG_nosave, &(page)->flags)
-#define SetPageNosave(page)	set_bit(PG_nosave, &(page)->flags)
-#define TestSetPageNosave(page)	test_and_set_bit(PG_nosave, &(page)->flags)
-#define ClearPageNosave(page)		clear_bit(PG_nosave, &(page)->flags)
-#define TestClearPageNosave(page)	test_and_clear_bit(PG_nosave, &(page)->flags)
-
-#define PageNosaveFree(page)	test_bit(PG_nosave_free, &(page)->flags)
-#define SetPageNosaveFree(page)	set_bit(PG_nosave_free, &(page)->flags)
-#define ClearPageNosaveFree(page)		clear_bit(PG_nosave_free, &(page)->flags)
+#define PageSwsuspImage(page)	test_bit(PG_swsusp_image, &(page)->flags)
+#define SetPageSwsuspImage(page) set_bit(PG_swsusp_image, &(page)->flags)
+#define ClearPageSwsuspImage(page) clear_bit(PG_swsusp_image, &(page)->flags)
+
+#define PageSwsuspSaved(page)	test_bit(PG_swsusp_saved, &(page)->flags)
+#define SetPageSwsuspSaved(page) set_bit(PG_swsusp_saved, &(page)->flags)
+#define ClearPageSwsuspSaved(page) clear_bit(PG_swsusp_saved, &(page)->flags)
 
 #define PageBuddy(page)		test_bit(PG_buddy, &(page)->flags)
 #define __SetPageBuddy(page)	__set_bit(PG_buddy, &(page)->flags)
Index: linux-2.6/kernel/power/main.c
===================================================================
--- linux-2.6.orig/kernel/power/main.c	2007-03-02 01:51:09.000000000 +1100
+++ linux-2.6/kernel/power/main.c	2007-03-02 02:06:07.000000000 +1100
@@ -334,6 +334,10 @@ static int __init pm_init(void)
 	int error = subsystem_register(&power_subsys);
 	if (!error)
 		error = sysfs_create_group(&power_subsys.kset.kobj,&attr_group);
+	if (!error)
+		error = register_nosave_region(
+				__pa(&__nosave_begin) >> PAGE_SHIFT,
+				PAGE_ALIGN(__pa(&__nosave_end)) >> PAGE_SHIFT);
 	return error;
 }
 
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-03-02 01:51:09.000000000 +1100
+++ linux-2.6/mm/page_alloc.c	2007-03-02 02:06:07.000000000 +1100
@@ -752,40 +752,6 @@ static void __drain_pages(unsigned int c
 }
 
 #ifdef CONFIG_PM
-
-void mark_free_pages(struct zone *zone)
-{
-	unsigned long pfn, max_zone_pfn;
-	unsigned long flags;
-	int order;
-	struct list_head *curr;
-
-	if (!zone->spanned_pages)
-		return;
-
-	spin_lock_irqsave(&zone->lock, flags);
-
-	max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
-		if (pfn_valid(pfn)) {
-			struct page *page = pfn_to_page(pfn);
-
-			if (!PageNosave(page))
-				ClearPageNosaveFree(page);
-		}
-
-	for (order = MAX_ORDER - 1; order >= 0; --order)
-		list_for_each(curr, &zone->free_area[order].free_list) {
-			unsigned long i;
-
-			pfn = page_to_pfn(list_entry(curr, struct page, lru));
-			for (i = 0; i < (1UL << order); i++)
-				SetPageNosaveFree(pfn_to_page(pfn + i));
-		}
-
-	spin_unlock_irqrestore(&zone->lock, flags);
-}
-
 /*
  * Spill all of this CPU's per-cpu pages back into the buddy allocator.
  */

--------------080306070500080903020309--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
