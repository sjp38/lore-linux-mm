Date: Fri, 12 Aug 2005 17:21:04 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Zoned CART
Message-ID: <20050812202104.GA8925@dmt.cnet>
References: <1123857429.14899.59.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1123857429.14899.59.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Rahul Iyer <rni@andrew.cmu.edu>
List-ID: <linux-mm.kvack.org>

Hi!

On Fri, Aug 12, 2005 at 04:37:09PM +0200, Peter Zijlstra wrote:
> Hi All,
> 
> I've been thinking on how to implement a zoned CART; and I think I have
> found a nice concept.
> 
> My ideas are based on the initial cart patch by Rahul and the
> non-resident code of Rik.
> 
> For a zoned page replacement algorithm we have per zone resident list(s)
> and global non-resident list(s). CART specific we would have a T1_i and
> T2_i, where 0 <= i <= nr_zones, and global B1 and B2 lists.
> 
> Because B1 and B2 are variable size and the B1_i target size q_i is zone
> specific we need some tricks. However since |B1| + |B2| = c we could get
> away with a single hash_table of c entries if we can manage to balance
> the entries within.
> 
> I propose to do this by using a 2 hand bucket and using the 2 MSB of the
> cookie (per bucket uniqueness; 30 bits of uniqueness should be enough on
> a ~64 count bucket). The cookies MSB is used to distinguish B1/B2 and
> the MSB-1 is used for the filter bit.
> 
> Let us denote the buckets with the subscript j: |B1_j| + |B2_j| = c_j.
> Each hand keeps a FIFO for its corresponding type: B1/B2; eg. rotating
> H1_j will select the next oldest B1_j page for removal.
> 
> We need to balance the per zone values:
>  T1_i, T2_i, |T1_i|, |T2_i|
>  p_i, Ns_i, Nl_i
> 
>  |B1_i|, |B2_i|, q_i
> 
> agains the per bucket values:
>  B1_j, B2_j.
> 
> This can be done with two simple modifications to the algorithm:
>  - explicitly keep |B1_i| and |B2_i| - needed for the p,q targets
>  - merge the history replacement (lines 6-10) in the replace (lines
>    36-40) code so that: adding the new MRU page and removing the old LRU
>    page becomes one action.
>
> This will keep:
> 
>  |B1_j|     |B1|     Sum^i(|B1_i|)
> -------- ~ ------ = -------------
>  |B2_j|     |B2|     Sum^i(|B2_i|)
> 
> however it will violate strict FIFO order within the buckets; although I
> guess it won't be too bad.
> 
> This approach does away with explicitly keeping the FIFO lists for the
> non-resident pages and merges them.

Looks plausible, while keeping lower overhead of the hash table. 

I have no useful technical comments on your idea at the moment, sorry 
(hope to have on the future!).

One thing which which we would like to see done is an investigation of the 
behaviour of the hashing function under different sets of input.

> Attached is a modification of rik his non-resident code that implements
> the buckets described herein.
> 
> I shall attempt to merge this code into the Rahuls new cart-patch-2 if
> you guys don't see any big problems with the approach, or beat me to it.

IMHO the most important thing in trying to adapt ARC's dynamically
adaptable "recency/frequency" mechanism into Linux is to _really_
understand the behaviour of the page reclaiming process under different
workloads and system configurations.

Good question is: For which situations the current strategy is suboptimal
and why.

It certainly suffers from some of the well-studied LRU problems, most
notably the frequency metric is not weighted into the likeness of future
usage. The "likeness" is currently implemented by LRU list order.

There are further complications in an operating system compared to
a plain cache, such as:

- swap allocation
- laundering of dirty pages
- destruction of pagetable mappings for reclaiming purposes
- balancing between pagecache and kernel cache reclamation
- special cases such:
	- VM_LOCKED mappings
	- locked pages
	- pages under writeback - right now these pages are sent up the top
	of the LRU stack (either active or inactive) once encountered by 
	the page reclaiming codepath, meaning that they effectively become 
	more "recent" then all the pages in their respective stack.

The following ARC experiment uses a radix tree as the backend for
non-resident cache.

In some situations it performs better (increases cache hits, that is)
than the current v2.6 algorithm, sometimes way worse - probably due to
a short period in which active (L2) pages remain in memory when the
inactive target is large, as Rik commented on lkml the other day.

Rahul, do you have any promising performance results of your ARC
implementation?

Note: this one dies horribly with highmem machines, probably due to 
atomic allocation of nodes - an improvement would be to 


diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/include/linux/mm_inline.h linux-2.6.12-arc/include/linux/mm_inline.h
--- linux-2.6.12/include/linux/mm_inline.h	2005-06-17 16:48:29.000000000 -0300
+++ linux-2.6.12-arc/include/linux/mm_inline.h	2005-08-09 17:46:22.000000000 -0300
@@ -27,6 +27,12 @@ del_page_from_inactive_list(struct zone 
 	zone->nr_inactive--;
 }
 
+void add_to_inactive_evicted_list(struct zone *zone, struct address_space *mapping, unsigned long index);
+void add_to_active_evicted_list(struct zone *zone, struct address_space *mapping, unsigned long index); 
+void add_to_evicted_list(struct zone *zone, unsigned long mapping, unsigned long index, int active);
+
+unsigned long zone_target(struct zone *zone);
+
 static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/include/linux/mmzone.h linux-2.6.12-arc/include/linux/mmzone.h
--- linux-2.6.12/include/linux/mmzone.h	2005-06-17 16:48:29.000000000 -0300
+++ linux-2.6.12-arc/include/linux/mmzone.h	2005-07-14 07:15:15.000000000 -0300
@@ -137,10 +137,14 @@ struct zone {
 	spinlock_t		lru_lock;	
 	struct list_head	active_list;
 	struct list_head	inactive_list;
+	struct list_head	evicted_active_list;
+	struct list_head	evicted_inactive_list;
 	unsigned long		nr_scan_active;
 	unsigned long		nr_scan_inactive;
 	unsigned long		nr_active;
 	unsigned long		nr_inactive;
+	unsigned long		nr_evicted_active;
+	unsigned long		nr_evicted_inactive;
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/include/linux/page-flags.h linux-2.6.12-arc/include/linux/page-flags.h
--- linux-2.6.12/include/linux/page-flags.h	2005-06-17 16:48:29.000000000 -0300
+++ linux-2.6.12-arc/include/linux/page-flags.h	2005-08-05 00:59:45.000000000 -0300
@@ -76,6 +76,7 @@
 #define PG_reclaim		18	/* To be reclaimed asap */
 #define PG_nosave_free		19	/* Free, should not be written */
 #define PG_uncached		20	/* Page has been mapped as uncached */
+#define PG_referencedtwice	21	
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -132,6 +133,16 @@ struct page_state {
 
 	unsigned long pgrotated;	/* pages rotated to tail of the LRU */
 	unsigned long nr_bounce;	/* pages for bounce buffers */
+
+	unsigned long active_scan;
+	unsigned long pgscan_active_dma;
+	unsigned long pgscan_active_normal;
+	unsigned long pgscan_active_high;
+
+	unsigned long inactive_scan;
+	unsigned long pgscan_inactive_dma;
+	unsigned long pgscan_inactive_normal;
+	unsigned long pgscan_inactive_high;
 };
 
 extern void get_page_state(struct page_state *ret);
@@ -185,6 +196,11 @@ extern void __mod_page_state(unsigned of
 #define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
 #define TestClearPageReferenced(page) test_and_clear_bit(PG_referenced, &(page)->flags)
 
+#define PageReferencedTwice(page)	test_bit(PG_referencedtwice, &(page)->flags)
+#define SetPageReferencedTwice(page)	set_bit(PG_referencedtwice, &(page)->flags)
+#define ClearPageReferencedTwice(page)	clear_bit(PG_referencedtwice, &(page)->flags)
+#define TestClearPageReferencedTwice(page) test_and_clear_bit(PG_referencedtwice, &(page)->flags)
+
 #define PageUptodate(page)	test_bit(PG_uptodate, &(page)->flags)
 #ifndef SetPageUptodate
 #define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/lib/radix-tree.c linux-2.6.12-arc/lib/radix-tree.c
--- linux-2.6.12/lib/radix-tree.c	2005-06-17 16:48:29.000000000 -0300
+++ linux-2.6.12-arc/lib/radix-tree.c	2005-07-22 06:44:04.000000000 -0300
@@ -413,7 +413,7 @@ out:
 }
 EXPORT_SYMBOL(radix_tree_tag_clear);
 
-#ifndef __KERNEL__	/* Only the test harness uses this at present */
+//#ifndef __KERNEL__	/* Only the test harness uses this at present */
 /**
  *	radix_tree_tag_get - get a tag on a radix tree node
  *	@root:		radix tree root
@@ -422,8 +422,8 @@ EXPORT_SYMBOL(radix_tree_tag_clear);
  *
  *	Return the search tag corresponging to @index in the radix tree.
  *
- *	Returns zero if the tag is unset, or if there is no corresponding item
- *	in the tree.
+ *	Returns -1 if the tag is unset, or zero if there is no corresponding 
+ *	item in the tree.
  */
 int radix_tree_tag_get(struct radix_tree_root *root,
 			unsigned long index, int tag)
@@ -457,7 +457,7 @@ int radix_tree_tag_get(struct radix_tree
 			int ret = tag_get(*slot, tag, offset);
 
 			BUG_ON(ret && saw_unset_tag);
-			return ret;
+			return ret ? 1 : -1;
 		}
 		slot = (struct radix_tree_node **)((*slot)->slots + offset);
 		shift -= RADIX_TREE_MAP_SHIFT;
@@ -465,7 +465,7 @@ int radix_tree_tag_get(struct radix_tree
 	}
 }
 EXPORT_SYMBOL(radix_tree_tag_get);
-#endif
+//#endif
 
 static unsigned int
 __lookup(struct radix_tree_root *root, void **results, unsigned long index,
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/mm/evicted.c linux-2.6.12-arc/mm/evicted.c
--- linux-2.6.12/mm/evicted.c	1969-12-31 21:00:00.000000000 -0300
+++ linux-2.6.12-arc/mm/evicted.c	2005-08-10 14:04:25.000000000 -0300
@@ -0,0 +1,301 @@
+#include <linux/mm.h>
+#include <linux/radix-tree.h>
+#include <linux/hash.h>
+#include <linux/module.h>
+#include <linux/mempool.h>
+#include <linux/debugfs.h>
+#include <linux/swap.h>
+#include <linux/kernel.h>
+#include <asm/uaccess.h>
+
+/* overload DIRTY/WRITEBACK radix tags for our own purposes... */
+#define ACTIVE_TAG 0 
+#define INACTIVE_TAG 1
+
+struct radix_tree_root evicted_radix = RADIX_TREE_INIT(GFP_ATOMIC);
+
+static mempool_t *evicted_cache;
+
+extern int total_memory;
+
+unsigned long inactive_target;
+
+struct evicted_page {
+	struct list_head evictedlist;
+	unsigned long key;
+};
+
+static void *evicted_pool_alloc(unsigned int __nocast gfp_mask, void *data)
+{
+	void *ptr = kmalloc(sizeof(struct evicted_page), gfp_mask);
+        return ptr;
+}
+
+static void evicted_pool_free(void *element, void *data)
+{
+	kfree(element);
+}
+
+int evicted_misses = 0;
+int active_evicted_hits = 0;
+int inactive_evicted_hits = 0;
+
+unsigned long zone_target(struct zone *zone)
+{
+	return (zone->present_pages * inactive_target) / totalram_pages;
+}
+
+struct dentry *evicted_dentry;
+
+int evicted_open(struct inode *ino, struct file *file)
+{
+        return 0;
+}
+
+ssize_t evicted_write(struct file *file, char __user *buf, size_t size,
+                        loff_t *ignored)
+{
+	evicted_misses = 0;
+	active_evicted_hits = 0;
+	inactive_evicted_hits = 0;
+	return 1;
+}
+
+int ran = 0;
+
+ssize_t evicted_read(struct file *file, char __user *buf, size_t size,
+                        loff_t *ignored)
+{
+	int len, a_evicted, i_evicted;
+	pg_data_t *pgdat;
+	char src[200];
+
+	len = a_evicted = i_evicted = 0;
+
+	if (ran) {
+		ran = 0;	
+		return 0;
+	}
+
+	for_each_pgdat(pgdat) {
+		struct zonelist *zonelist = pgdat->node_zonelists;
+		struct zone **zonep = zonelist->zones;
+		struct zone *zone;
+		for (zone = *zonep++; zone; zone = *zonep++) {
+			a_evicted += zone->nr_evicted_active;
+			i_evicted += zone->nr_evicted_inactive;
+		}
+	}
+
+	sprintf(src, "Misses: %d\n"
+		     "Active evicted size: %d\n"
+		     "Active evicted hits: %d\n"
+		     "Inactive evicted size: %d "
+		     "Inactive evicted hits: %d\n"
+		     "Global inactive target: %ld\n",
+			evicted_misses, a_evicted, active_evicted_hits,
+			i_evicted, inactive_evicted_hits, inactive_target);
+
+	len = strlen(src);
+	
+	if(copy_to_user(buf, src, len))
+		return -EFAULT;
+
+	ran = 1;
+
+	return len;
+}
+
+struct file_operations vmevicted_fops = {
+	.owner = THIS_MODULE,
+	.open = evicted_open,
+	.read = evicted_read,
+	.write = evicted_write,
+};
+
+void __init init_vm_evicted(void)
+{
+	printk(KERN_ERR "init_vm_evicted total_memory:%d\n", total_memory);
+
+	evicted_cache = mempool_create (total_memory, evicted_pool_alloc, evicted_pool_free, NULL);
+
+	if (evicted_cache)
+		printk(KERN_ERR "evicted cache init, using %d Kbytes\n", (total_memory * 2) * sizeof(struct evicted_page));
+	else
+		printk(KERN_ERR "mempool_alloc failure!\n");
+
+	inactive_target = total_memory/2;
+
+        evicted_dentry = debugfs_create_file("vm_evicted", 0644, NULL, NULL, &vmevicted_fops);
+}
+
+struct evicted_page *alloc_evicted_entry(unsigned long index, unsigned long mapping)
+{
+	struct evicted_page *e_page;
+
+	if (!evicted_cache)
+		return NULL;
+
+	e_page = mempool_alloc(evicted_cache, GFP_ATOMIC);
+
+	if (e_page)
+		INIT_LIST_HEAD(&e_page->evictedlist);
+
+	return e_page;
+}
+
+inline unsigned long evict_hash_fn(unsigned long mapping, unsigned long index)
+{
+	unsigned long key;
+
+	/* most significant word of "mapping" is not random */
+	key = hash_long((mapping & 0x0000FFFF) + index, BITS_PER_LONG);
+	key = hash_long(key + index, BITS_PER_LONG);
+
+	return key;
+}
+
+/* remove the LRU page from the "elist" evicted page list */
+void remove_lru_page(struct radix_tree_root *radix, struct list_head *elist)
+{
+	struct evicted_page *e_page;
+	struct list_head *last = elist->prev;
+
+	e_page = list_entry(last, struct evicted_page, evictedlist);
+
+	radix_tree_delete(radix, e_page->key);
+
+	list_del(&e_page->evictedlist);
+	mempool_free(e_page, evicted_cache);
+}
+
+void add_to_inactive_evicted_list(struct zone *zone, unsigned long mapping,
+		unsigned long index)
+{
+	struct list_head *list = &zone->evicted_inactive_list;
+	struct evicted_page *e_page;
+	unsigned long key;
+	int target, above_target, error;
+
+	/* Total amount of history recorded is twice the number of pages cached */
+	target = (zone->present_pages*2) - zone->nr_inactive;
+
+	above_target = zone->nr_evicted_inactive - target;
+
+	while (above_target > 0 && zone->nr_evicted_inactive) {
+		remove_lru_page(&evicted_radix, list);
+		zone->nr_evicted_inactive--;
+		above_target--;
+	}
+
+	e_page = alloc_evicted_entry((unsigned long)mapping, index);
+
+	if (unlikely(!e_page))
+		return;
+
+	list_add(&e_page->evictedlist, list);
+
+	e_page->key = evict_hash_fn((unsigned long) mapping, index);
+
+	error = radix_tree_preload(GFP_ATOMIC|__GFP_NOWARN);
+	if (error == 0) {
+		radix_tree_insert(&evicted_radix, e_page->key, e_page);
+		radix_tree_tag_set(&evicted_radix, e_page->key, INACTIVE_TAG);
+		zone->nr_evicted_inactive++;
+	}
+	radix_tree_preload_end();
+}
+
+void add_to_active_evicted_list(struct zone *zone, unsigned long mapping, unsigned long index)
+{
+	struct list_head *list = &zone->evicted_active_list;
+	struct evicted_page *e_page;
+	unsigned long key;
+	int target, above_target, error;
+	
+	/* Total amount of history recorded is twice the number of pages cached */
+	target = (zone->present_pages*2) - zone->nr_active;
+
+	above_target = zone->nr_evicted_active - target;
+
+	while (above_target > 0 && zone->nr_evicted_active) {
+		remove_lru_page(&evicted_radix, list);
+		zone->nr_evicted_active--;
+		above_target--;
+	}
+
+	e_page = alloc_evicted_entry((unsigned long)mapping, index);
+
+	if (!e_page)
+		return;
+
+	list_add(&e_page->evictedlist, list);
+
+	e_page->key = evict_hash_fn((unsigned long) mapping, index);
+
+	error = radix_tree_preload(GFP_ATOMIC|__GFP_NOWARN);
+	if (error == 0) {
+		radix_tree_insert(&evicted_radix, e_page->key, e_page);
+		radix_tree_tag_set(&evicted_radix, e_page->key, ACTIVE_TAG);
+		zone->nr_evicted_active++;
+	}
+	radix_tree_preload_end();
+}
+
+#define ACTIVE_HIT 1
+#define INACTIVE_HIT 2
+
+int evicted_lookup(struct address_space *mapping, unsigned long index)
+{
+	int e_page;
+	unsigned long key = evict_hash_fn((unsigned long) mapping, index);
+
+	e_page = radix_tree_tag_get(&evicted_radix, key, INACTIVE_TAG);
+
+	if (e_page == 1)
+		return INACTIVE_HIT;
+	else if (e_page == -1)
+		return ACTIVE_HIT;
+
+	return 0;
+}
+
+void add_to_evicted_list(struct zone *zone, unsigned long mapping,
+			unsigned long index, int active)
+{
+	if (active)
+		add_to_active_evicted_list(zone, mapping, index);
+	else
+		add_to_inactive_evicted_list(zone, mapping, index);
+}
+
+/* takes care of updating the inactive target */
+void evicted_account(struct address_space *mapping, unsigned long index)
+{
+	unsigned long diff;
+	evicted_misses++;
+
+	switch (evicted_lookup(mapping, index)) {
+	case ACTIVE_HIT:
+/*		if (inactive_target > (totalram_pages/2)) {
+			diff = (totalram_pages/2) - inactive_target;
+			inactive_target -= min(diff/128, 32);
+		} else */
+			inactive_target -= 8;
+
+		if ((signed long)inactive_target < 0)
+			inactive_target = 0;
+
+		active_evicted_hits++;
+		break;
+	case INACTIVE_HIT:
+/*		if (inactive_target < (totalram_pages/2)) {
+			diff = (totalram_pages/2) - inactive_target;
+			inactive_target += min(diff/128, 32);
+		} else */
+			inactive_target += 8;
+
+		inactive_evicted_hits++;
+		break;
+	}
+}
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/mm/filemap.c linux-2.6.12-arc/mm/filemap.c
--- linux-2.6.12/mm/filemap.c	2005-06-17 16:48:29.000000000 -0300
+++ linux-2.6.12-arc/mm/filemap.c	2005-08-05 02:19:14.000000000 -0300
@@ -396,12 +396,18 @@ int add_to_page_cache(struct page *page,
 
 EXPORT_SYMBOL(add_to_page_cache);
 
+extern int evicted_lookup(struct address_space *mapping, unsigned long index);
+
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t offset, int gfp_mask)
 {
 	int ret = add_to_page_cache(page, mapping, offset, gfp_mask);
-	if (ret == 0)
-		lru_cache_add(page);
+	if (ret == 0) {
+		if (evicted_lookup(mapping, offset))
+			lru_cache_add_active(page);
+		else
+			lru_cache_add(page);
+	}
 	return ret;
 }
 
@@ -493,6 +499,8 @@ void fastcall __lock_page(struct page *p
 }
 EXPORT_SYMBOL(__lock_page);
 
+extern void evicted_account(struct address_space *, unsigned long);
+
 /*
  * a rather lightweight function, finding and getting a reference to a
  * hashed page atomically.
@@ -505,6 +513,8 @@ struct page * find_get_page(struct addre
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page)
 		page_cache_get(page);
+	else
+		evicted_account(mapping, offset);
 	read_unlock_irq(&mapping->tree_lock);
 	return page;
 }
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/mm/Makefile linux-2.6.12-arc/mm/Makefile
--- linux-2.6.12/mm/Makefile	2005-06-17 16:48:29.000000000 -0300
+++ linux-2.6.12-arc/mm/Makefile	2005-07-14 07:15:15.000000000 -0300
@@ -10,7 +10,7 @@ mmu-$(CONFIG_MMU)	:= fremap.o highmem.o 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o slab.o swap.o truncate.o vmscan.o \
-			   prio_tree.o $(mmu-y)
+			   prio_tree.o evicted.o $(mmu-y)
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/mm/memory.c linux-2.6.12-arc/mm/memory.c
--- linux-2.6.12/mm/memory.c	2005-08-09 15:05:29.000000000 -0300
+++ linux-2.6.12-arc/mm/memory.c	2005-08-09 17:08:38.000000000 -0300
@@ -1314,7 +1314,7 @@ static int do_wp_page(struct mm_struct *
 			page_remove_rmap(old_page);
 		flush_cache_page(vma, address, pfn);
 		break_cow(vma, new_page, address, page_table);
-		lru_cache_add_active(new_page);
+		lru_cache_add(new_page);
 		page_add_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
@@ -1791,8 +1791,7 @@ do_anonymous_page(struct mm_struct *mm, 
 		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
 							 vma->vm_page_prot)),
 				      vma);
-		lru_cache_add_active(page);
-		SetPageReferenced(page);
+		lru_cache_add(page);
 		page_add_anon_rmap(page, vma, addr);
 	}
 
@@ -1912,7 +1911,7 @@ retry:
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
-			lru_cache_add_active(new_page);
+			lru_cache_add(new_page);
 			page_add_anon_rmap(new_page, vma, address);
 		} else
 			page_add_file_rmap(new_page);
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/mm/mempool.c linux-2.6.12-arc/mm/mempool.c
--- linux-2.6.12/mm/mempool.c	2005-06-17 16:48:29.000000000 -0300
+++ linux-2.6.12-arc/mm/mempool.c	2005-08-10 12:13:40.000000000 -0300
@@ -60,10 +60,16 @@ mempool_t * mempool_create(int min_nr, m
 	if (!pool)
 		return NULL;
 	memset(pool, 0, sizeof(*pool));
+
 	pool->elements = kmalloc(min_nr * sizeof(void *), GFP_KERNEL);
 	if (!pool->elements) {
-		kfree(pool);
-		return NULL;
+		printk(KERN_ERR "kmalloc of %d failed, trying vmalloc!\n",
+				min_nr * sizeof(void *));
+		pool->elements = vmalloc(min_nr * sizeof(void *));
+		if (!pool->elements) { 
+			kfree(pool);
+			return NULL;
+		}
 	}
 	spin_lock_init(&pool->lock);
 	pool->min_nr = min_nr;
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/mm/page_alloc.c linux-2.6.12-arc/mm/page_alloc.c
--- linux-2.6.12/mm/page_alloc.c	2005-06-17 16:48:29.000000000 -0300
+++ linux-2.6.12-arc/mm/page_alloc.c	2005-08-09 17:11:21.000000000 -0300
@@ -378,8 +378,10 @@ void __free_pages_ok(struct page *page, 
 			__put_page(page + i);
 #endif
 
-	for (i = 0 ; i < (1 << order) ; ++i)
+	for (i = 0 ; i < (1 << order) ; ++i) {
+		ClearPageActive((struct page *)(page + i));
 		free_pages_check(__FUNCTION__, page + i);
+	}
 	list_add(&page->lru, &list);
 	kernel_map_pages(page, 1<<order, 0);
 	free_pages_bulk(page_zone(page), 1, &list, order);
@@ -614,6 +616,8 @@ static void fastcall free_hot_cold_page(
 	inc_page_state(pgfree);
 	if (PageAnon(page))
 		page->mapping = NULL;
+	if (PageActive(page))
+		ClearPageActive(page);
 	free_pages_check(__FUNCTION__, page);
 	pcp = &zone->pageset[get_cpu()].pcp[cold];
 	local_irq_save(flags);
@@ -1708,11 +1712,16 @@ static void __init free_area_init_core(s
 		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
 				zone_names[j], realsize, batch);
 		INIT_LIST_HEAD(&zone->active_list);
+		INIT_LIST_HEAD(&zone->evicted_active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
+		INIT_LIST_HEAD(&zone->evicted_inactive_list);
 		zone->nr_scan_active = 0;
 		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
 		zone->nr_inactive = 0;
+		zone->nr_evicted_inactive = 0;
+		zone->nr_evicted_active = 0;
+
 		if (!size)
 			continue;
 
@@ -1896,9 +1905,17 @@ static char *vmstat_text[] = {
 	"kswapd_inodesteal",
 	"pageoutrun",
 	"allocstall",
-
 	"pgrotated",
 	"nr_bounce",
+
+	"active_scan",
+	"pgscan_active_dma",
+	"pgscan_active_normal",
+	"pgscan_active_high",
+	"inactive_scan",
+	"pgscan_inactive_dma",
+	"pgscan_inactive_normal",
+	"pgscan_inactive_high",
 };
 
 static void *vmstat_start(struct seq_file *m, loff_t *pos)
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/mm/swap.c linux-2.6.12-arc/mm/swap.c
--- linux-2.6.12/mm/swap.c	2005-06-17 16:48:29.000000000 -0300
+++ linux-2.6.12-arc/mm/swap.c	2005-08-05 01:03:05.000000000 -0300
@@ -122,8 +122,11 @@ void fastcall activate_page(struct page 
  */
 void fastcall mark_page_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
+	if (!PageActive(page) && PageReferencedTwice(page) && PageLRU(page)) {
 		activate_page(page);
+		ClearPageReferencedTwice(page);
+	} else if (!PageReferencedTwice(page) && PageReferenced(page)) {
+		SetPageReferencedTwice(page);
 		ClearPageReferenced(page);
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
diff -Nur --exclude-from=/home/marcelo/git/exclude --show-c-function linux-2.6.12/mm/vmscan.c linux-2.6.12-arc/mm/vmscan.c
--- linux-2.6.12/mm/vmscan.c	2005-08-10 14:37:14.000000000 -0300
+++ linux-2.6.12-arc/mm/vmscan.c	2005-08-10 14:55:09.000000000 -0300
@@ -79,6 +79,8 @@ struct scan_control {
 	 * In this context, it doesn't matter that we scan the
 	 * whole list at once. */
 	int swap_cluster_max;
+
+	int nr_to_isolate;
 };
 
 /*
@@ -126,7 +128,7 @@ struct shrinker {
  * From 0 .. 100.  Higher means more swappy.
  */
 int vm_swappiness = 60;
-static long total_memory;
+long total_memory;
 
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
@@ -225,27 +227,6 @@ static int shrink_slab(unsigned long sca
 	return 0;
 }
 
-/* Called without lock on whether page is mapped, so answer is unstable */
-static inline int page_mapping_inuse(struct page *page)
-{
-	struct address_space *mapping;
-
-	/* Page is in somebody's page tables. */
-	if (page_mapped(page))
-		return 1;
-
-	/* Be more reluctant to reclaim swapcache than pagecache */
-	if (PageSwapCache(page))
-		return 1;
-
-	mapping = page_mapping(page);
-	if (!mapping)
-		return 0;
-
-	/* File is mmap'd by somebody? */
-	return mapping_mapped(mapping);
-}
-
 static inline int is_page_cache_freeable(struct page *page)
 {
 	return page_count(page) - !!PagePrivate(page) == 2;
@@ -360,15 +341,54 @@ static pageout_t pageout(struct page *pa
 	return PAGE_CLEAN;
 }
 
+int should_reclaim_mapped(struct zone *zone, struct scan_control *sc)
+{ 
+	long mapped_ratio;
+	long distress;
+	long swap_tendency;
+	/*
+	 * `distress' is a measure of how much trouble we're having reclaiming
+	 * pages.  0 -> no problems.  100 -> great trouble.
+	 */
+	distress = 100 >> zone->prev_priority;
+
+	/*
+	 * The point of this algorithm is to decide when to start reclaiming
+	 * mapped memory instead of just pagecache.  Work out how much memory
+	 * is mapped.
+	 */
+	mapped_ratio = (sc->nr_mapped * 100) / total_memory;
+
+	/*
+	 * Now decide how much we really want to unmap some pages.  The mapped
+	 * ratio is downgraded - just because there's a lot of mapped memory
+	 * doesn't necessarily mean that page reclaim isn't succeeding.
+	 *
+	 * The distress ratio is important - we don't want to start going oom.
+	 *
+	 * A 100% value of vm_swappiness overrides this algorithm altogether.
+	 */
+	swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
+
+	/*
+	 * Now use this metric to decide whether to reclaim mapped pages 
+	 */
+	if (swap_tendency >= 100)
+		return 1;
+
+	return 0;
+}
+
 /*
  * shrink_list adds the number of reclaimed pages to sc->nr_reclaimed
  */
-static int shrink_list(struct list_head *page_list, struct scan_control *sc)
+static int shrink_list(struct list_head *page_list, struct scan_control *sc, struct zone *zone)
 {
 	LIST_HEAD(ret_pages);
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	int reclaimed = 0;
+	unsigned long savedmapping, savedindex, active;
 
 	cond_resched();
 
@@ -387,8 +407,6 @@ static int shrink_list(struct list_head 
 		if (TestSetPageLocked(page))
 			goto keep;
 
-		BUG_ON(PageActive(page));
-
 		sc->nr_scanned++;
 		/* Double the slab pressure for mapped and swapcache pages */
 		if (page_mapped(page) || PageSwapCache(page))
@@ -398,9 +416,18 @@ static int shrink_list(struct list_head 
 			goto keep_locked;
 
 		referenced = page_referenced(page, 1, sc->priority <= 0);
-		/* In active use or really unfreeable?  Activate it. */
-		if (referenced && page_mapping_inuse(page))
-			goto activate_locked;
+		/* In active use? */
+		if (referenced) {
+			if (PageReferencedTwice(page)) {
+				ClearPageReferencedTwice(page);
+				goto activate_locked;
+			} else
+				SetPageReferencedTwice(page);
+				goto keep_locked;
+		}
+
+		if (page_mapped(page) && !should_reclaim_mapped(zone, sc))
+			goto keep_locked;
 
 #ifdef CONFIG_SWAP
 		/*
@@ -509,18 +536,28 @@ static int shrink_list(struct list_head 
 #ifdef CONFIG_SWAP
 		if (PageSwapCache(page)) {
 			swp_entry_t swap = { .val = page->private };
+			savedmapping = (unsigned long)page->mapping;
+			savedindex = page->private;
+			active = PageActive(page);
 			__delete_from_swap_cache(page);
 			write_unlock_irq(&mapping->tree_lock);
 			swap_free(swap);
 			__put_page(page);	/* The pagecache ref */
+			local_irq_disable();
+			add_to_evicted_list(zone, savedmapping, savedindex, active);
+			local_irq_enable();
 			goto free_it;
 		}
 #endif /* CONFIG_SWAP */
-
+		savedmapping = (unsigned long)page->mapping;
+		savedindex = page->index;
+		active = PageActive(page);
 		__remove_from_page_cache(page);
 		write_unlock_irq(&mapping->tree_lock);
 		__put_page(page);
-
+		local_irq_disable();
+		add_to_evicted_list(zone, savedmapping, savedindex, active);
+		local_irq_enable();
 free_it:
 		unlock_page(page);
 		reclaimed++;
@@ -597,7 +634,7 @@ static int isolate_lru_pages(int nr_to_s
 /*
  * shrink_cache() adds the number of pages reclaimed to sc->nr_reclaimed
  */
-static void shrink_cache(struct zone *zone, struct scan_control *sc)
+static void shrink_cache(struct zone *zone, struct scan_control *sc, struct list_head *from, unsigned long *page_counter)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
@@ -613,10 +650,10 @@ static void shrink_cache(struct zone *zo
 		int nr_scan;
 		int nr_freed;
 
-		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
-					     &zone->inactive_list,
+		nr_taken = isolate_lru_pages(sc->nr_to_isolate,
+					     from,
 					     &page_list, &nr_scan);
-		zone->nr_inactive -= nr_taken;
+		*page_counter -= nr_taken;
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
@@ -628,7 +665,7 @@ static void shrink_cache(struct zone *zo
 			mod_page_state_zone(zone, pgscan_kswapd, nr_scan);
 		else
 			mod_page_state_zone(zone, pgscan_direct, nr_scan);
-		nr_freed = shrink_list(&page_list, sc);
+		nr_freed = shrink_list(&page_list, sc, zone);
 		if (current_is_kswapd())
 			mod_page_state(kswapd_steal, nr_freed);
 		mod_page_state_zone(zone, pgsteal, nr_freed);
@@ -676,6 +713,7 @@ done:
  * The downside is that we have to touch page->_count against each page.
  * But we had to alter page->flags anyway.
  */
+#if 0 
 static void
 refill_inactive_zone(struct zone *zone, struct scan_control *sc)
 {
@@ -802,6 +840,10 @@ refill_inactive_zone(struct zone *zone, 
 	mod_page_state_zone(zone, pgrefill, pgscanned);
 	mod_page_state(pgdeactivate, pgdeactivate);
 }
+#endif
+
+#define RECLAIM_BALANCE 16
+DEFINE_PER_CPU(int, act_inact_scan) = RECLAIM_BALANCE;
 
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
@@ -809,44 +851,65 @@ refill_inactive_zone(struct zone *zone, 
 static void
 shrink_zone(struct zone *zone, struct scan_control *sc)
 {
-	unsigned long nr_active;
-	unsigned long nr_inactive;
+	unsigned long reclaim_saved, reclaimed;
+	int inactive_scan = 0;
+	int scan_protected = 0;
+	int *local_act_inact_scan = &__get_cpu_var(act_inact_scan);
+
+	sc->nr_to_reclaim = (zone->present_pages * sc->swap_cluster_max) /
+				total_memory;
+
+	reclaim_saved = sc->nr_reclaimed;
+
+	sc->nr_to_isolate = sc->nr_to_reclaim;
+
+	if (zone->nr_inactive >= zone_target(zone)) {
+		sc->nr_to_scan = (zone->nr_inactive >> sc->priority) + 1;
+		inc_page_state(inactive_scan);
+		mod_page_state_zone(zone, pgscan_inactive, sc->nr_to_scan);
+		shrink_cache(zone, sc,  &zone->inactive_list, &zone->nr_inactive);
+		inactive_scan = 1;
+		*local_act_inact_scan--;
+	} else {
+		sc->nr_to_scan = (zone->nr_active >> sc->priority) + 1;
+		inc_page_state(active_scan);
+		mod_page_state_zone(zone, pgscan_active, sc->nr_to_scan);
+		shrink_cache(zone, sc, &zone->active_list, &zone->nr_active);
+		*local_act_inact_scan++;
+	}
+
+	/* 
+	 * Scan the "protected" list once in a while if the target
+	 * list remains the same for a long period.
+	 */
+	if (*local_act_inact_scan >= RECLAIM_BALANCE*2) {
+		scan_protected = 1;
+		inactive_scan = 1;
+		*local_act_inact_scan = RECLAIM_BALANCE;
+	} else if (*local_act_inact_scan <= 0) {
+		scan_protected = 1;
+		inactive_scan = 0;
+                *local_act_inact_scan = RECLAIM_BALANCE;
+	}
 
-	/*
-	 * Add one to `nr_to_scan' just to make sure that the kernel will
-	 * slowly sift through the active list.
+	reclaimed = sc->nr_reclaimed - reclaim_saved;  
+
+	/* 
+	 * if no pages have been reclaimed and we're in trouble, ignore
+	 * the inactive target.
 	 */
-	zone->nr_scan_active += (zone->nr_active >> sc->priority) + 1;
-	nr_active = zone->nr_scan_active;
-	if (nr_active >= sc->swap_cluster_max)
-		zone->nr_scan_active = 0;
-	else
-		nr_active = 0;
-
-	zone->nr_scan_inactive += (zone->nr_inactive >> sc->priority) + 1;
-	nr_inactive = zone->nr_scan_inactive;
-	if (nr_inactive >= sc->swap_cluster_max)
-		zone->nr_scan_inactive = 0;
-	else
-		nr_inactive = 0;
-
-	sc->nr_to_reclaim = sc->swap_cluster_max;
-
-	while (nr_active || nr_inactive) {
-		if (nr_active) {
-			sc->nr_to_scan = min(nr_active,
-					(unsigned long)sc->swap_cluster_max);
-			nr_active -= sc->nr_to_scan;
-			refill_inactive_zone(zone, sc);
-		}
-
-		if (nr_inactive) {
-			sc->nr_to_scan = min(nr_inactive,
-					(unsigned long)sc->swap_cluster_max);
-			nr_inactive -= sc->nr_to_scan;
-			shrink_cache(zone, sc);
-			if (sc->nr_to_reclaim <= 0)
-				break;
+	if (!reclaimed && sc->priority < 2)
+		scan_protected = 1;
+
+	if (scan_protected) {
+		sc->nr_to_reclaim = (zone->present_pages * sc->swap_cluster_max) /
+				total_memory;
+		if (inactive_scan) {
+			sc->nr_to_scan = (zone->nr_active >> sc->priority) + 1;
+			shrink_cache(zone, sc, &zone->active_list, &zone->nr_active);
+		} else {
+			sc->nr_to_scan = (zone->nr_inactive >> sc->priority) + 1;
+			shrink_cache(zone, sc,  &zone->inactive_list, &zone->nr_inactive);
 		}
 	}
 
@@ -968,6 +1031,7 @@ int try_to_free_pages(struct zone **zone
 		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
 			blk_congestion_wait(WRITE, HZ/10);
 	}
+	ret = !!total_reclaimed;
 out:
 	for (i = 0; zones[i] != 0; i++) {
 		struct zone *zone = zones[i];
@@ -1296,6 +1360,8 @@ static int __devinit cpu_callback(struct
 }
 #endif /* CONFIG_HOTPLUG_CPU */
 
+extern void init_vm_evicted(void);
+
 static int __init kswapd_init(void)
 {
 	pg_data_t *pgdat;
@@ -1305,6 +1371,7 @@ static int __init kswapd_init(void)
 		= find_task_by_pid(kernel_thread(kswapd, pgdat, CLONE_KERNEL));
 	total_memory = nr_free_pagecache_pages();
 	hotcpu_notifier(cpu_callback, 0);
+	init_vm_evicted();
 	return 0;
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
