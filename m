Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 89EAB6B0062
	for <linux-mm@kvack.org>; Sun,  9 Dec 2012 20:24:48 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so1681816pad.14
        for <linux-mm@kvack.org>; Sun, 09 Dec 2012 17:24:47 -0800 (PST)
Date: Mon, 10 Dec 2012 09:24:39 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 1/2]swap: make each swap partition have one address_space
Message-ID: <20121210012439.GA18570@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, minchan@kernel.org

When I use several fast SSD to do swap, swapper_space.tree_lock is heavily
contended. This makes each swap partition have one address_space to reduce the
lock contention. There is an array of address_space for swap. The swap entry
type is the index to the array.

In my test with 3 SSD, this increases the swapout throughput 20%.

There are some code here which looks unnecessary, for example, moving some code
from swapops.h to swap.h and soem changes in audit_tree.c. Those are to make
the code compile.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 fs/proc/meminfo.c       |    4 +--
 include/linux/mm.h      |   11 ++++++---
 include/linux/swap.h    |   55 ++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/swapops.h |   46 ----------------------------------------
 kernel/audit_tree.c     |   30 +++++++++++++-------------
 mm/memcontrol.c         |    4 +--
 mm/mincore.c            |    5 ++--
 mm/swap.c               |    7 +++++-
 mm/swap_state.c         |   52 +++++++++++++++++++++++++++++----------------
 mm/swapfile.c           |    5 ++--
 10 files changed, 126 insertions(+), 93 deletions(-)

Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2012-12-10 08:51:21.809919763 +0800
+++ linux/include/linux/mm.h	2012-12-10 09:02:45.029330611 +0800
@@ -17,6 +17,7 @@
 #include <linux/pfn.h>
 #include <linux/bit_spinlock.h>
 #include <linux/shrinker.h>
+#include <linux/swap.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -788,15 +789,17 @@ void page_address_init(void);
 #define PAGE_MAPPING_KSM	2
 #define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
 
-extern struct address_space swapper_space;
 static inline struct address_space *page_mapping(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
 
 	VM_BUG_ON(PageSlab(page));
-	if (unlikely(PageSwapCache(page)))
-		mapping = &swapper_space;
-	else if ((unsigned long)mapping & PAGE_MAPPING_ANON)
+	if (unlikely(PageSwapCache(page))) {
+		swp_entry_t entry;
+
+		entry.val = page_private(page);
+		mapping = swap_address_space(entry);
+	} else if ((unsigned long)mapping & PAGE_MAPPING_ANON)
 		mapping = NULL;
 	return mapping;
 }
Index: linux/include/linux/swap.h
===================================================================
--- linux.orig/include/linux/swap.h	2012-12-10 08:51:21.801919864 +0800
+++ linux/include/linux/swap.h	2012-12-10 09:02:45.029330611 +0800
@@ -9,6 +9,10 @@
 #include <linux/sched.h>
 #include <linux/node.h>
 
+#include <linux/radix-tree.h>
+
+#include <linux/fs.h>
+
 #include <linux/atomic.h>
 #include <asm/page.h>
 
@@ -107,6 +111,52 @@ typedef struct {
 } swp_entry_t;
 
 /*
+ * swapcache pages are stored in the swapper_space radix tree.  We want to
+ * get good packing density in that tree, so the index should be dense in
+ * the low-order bits.
+ *
+ * We arrange the `type' and `offset' fields so that `type' is at the seven
+ * high-order bits of the swp_entry_t and `offset' is right-aligned in the
+ * remaining bits.  Although `type' itself needs only five bits, we allow for
+ * shmem/tmpfs to shift it all up a further two bits: see swp_to_radix_entry().
+ *
+ * swp_entry_t's are *never* stored anywhere in their arch-dependent format.
+ */
+#define SWP_TYPE_SHIFT(e)	((sizeof(e.val) * 8) - \
+			(MAX_SWAPFILES_SHIFT + RADIX_TREE_EXCEPTIONAL_SHIFT))
+#define SWP_OFFSET_MASK(e)	((1UL << SWP_TYPE_SHIFT(e)) - 1)
+
+/*
+ * Store a type+offset into a swp_entry_t in an arch-independent format
+ */
+static inline swp_entry_t swp_entry(unsigned long type, pgoff_t offset)
+{
+	swp_entry_t ret;
+
+	ret.val = (type << SWP_TYPE_SHIFT(ret)) |
+			(offset & SWP_OFFSET_MASK(ret));
+	return ret;
+}
+
+/*
+ * Extract the `type' field from a swp_entry_t.  The swp_entry_t is in
+ * arch-independent format
+ */
+static inline unsigned swp_type(swp_entry_t entry)
+{
+	return entry.val >> SWP_TYPE_SHIFT(entry);
+}
+
+/*
+ * Extract the `offset' field from a swp_entry_t.  The swp_entry_t is in
+ * arch-independent format
+ */
+static inline pgoff_t swp_offset(swp_entry_t entry)
+{
+	return entry.val & SWP_OFFSET_MASK(entry);
+}
+
+/*
  * current->reclaim_state points to one of these when a task is running
  * memory reclaim
  */
@@ -330,8 +380,9 @@ int generic_swapfile_activate(struct swa
 		sector_t *);
 
 /* linux/mm/swap_state.c */
-extern struct address_space swapper_space;
-#define total_swapcache_pages  swapper_space.nrpages
+extern struct address_space swapper_spaces[];
+#define swap_address_space(entry) (&swapper_spaces[swp_type(entry)])
+extern unsigned long total_swapcache_pages(void);
 extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *);
 extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
Index: linux/mm/memcontrol.c
===================================================================
--- linux.orig/mm/memcontrol.c	2012-12-10 08:51:21.777920164 +0800
+++ linux/mm/memcontrol.c	2012-12-10 09:02:45.029330611 +0800
@@ -5166,7 +5166,7 @@ static struct page *mc_handle_swap_pte(s
 	 * Because lookup_swap_cache() updates some statistics counter,
 	 * we call find_get_page() with swapper_space directly.
 	 */
-	page = find_get_page(&swapper_space, ent.val);
+	page = find_get_page(swap_address_space(entry), ent.val);
 	if (do_swap_account)
 		entry->val = ent.val;
 
@@ -5207,7 +5207,7 @@ static struct page *mc_handle_file_pte(s
 		swp_entry_t swap = radix_to_swp_entry(page);
 		if (do_swap_account)
 			*entry = swap;
-		page = find_get_page(&swapper_space, swap.val);
+		page = find_get_page(swap_address_space(swap), swap.val);
 	}
 #endif
 	return page;
Index: linux/mm/mincore.c
===================================================================
--- linux.orig/mm/mincore.c	2012-12-10 08:51:21.757920416 +0800
+++ linux/mm/mincore.c	2012-12-10 09:02:45.037330401 +0800
@@ -75,7 +75,7 @@ static unsigned char mincore_page(struct
 	/* shmem/tmpfs may return swap: account for swapcache page too. */
 	if (radix_tree_exceptional_entry(page)) {
 		swp_entry_t swap = radix_to_swp_entry(page);
-		page = find_get_page(&swapper_space, swap.val);
+		page = find_get_page(swap_address_space(swap), swap.val);
 	}
 #endif
 	if (page) {
@@ -135,7 +135,8 @@ static void mincore_pte_range(struct vm_
 			} else {
 #ifdef CONFIG_SWAP
 				pgoff = entry.val;
-				*vec = mincore_page(&swapper_space, pgoff);
+				*vec = mincore_page(swap_address_space(entry),
+					pgoff);
 #else
 				WARN_ON(1);
 				*vec = 1;
Index: linux/mm/swap.c
===================================================================
--- linux.orig/mm/swap.c	2012-12-10 08:51:21.765920314 +0800
+++ linux/mm/swap.c	2012-12-10 09:02:45.037330401 +0800
@@ -855,9 +855,14 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
 void __init swap_setup(void)
 {
 	unsigned long megs = totalram_pages >> (20 - PAGE_SHIFT);
+	int i;
 
 #ifdef CONFIG_SWAP
-	bdi_init(swapper_space.backing_dev_info);
+	for (i = 0; i < MAX_SWAPFILES; i++) {
+		bdi_init(swapper_spaces[i].backing_dev_info);
+		spin_lock_init(&swapper_spaces[i].tree_lock);
+		INIT_LIST_HEAD(&swapper_spaces[i].i_mmap_nonlinear);
+	}
 #endif
 
 	/* Use a smaller cluster for small-memory machines */
Index: linux/mm/swap_state.c
===================================================================
--- linux.orig/mm/swap_state.c	2012-12-10 08:51:21.745920568 +0800
+++ linux/mm/swap_state.c	2012-12-10 09:02:45.037330401 +0800
@@ -36,12 +36,12 @@ static struct backing_dev_info swap_back
 	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK | BDI_CAP_SWAP_BACKED,
 };
 
-struct address_space swapper_space = {
-	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
-	.tree_lock	= __SPIN_LOCK_UNLOCKED(swapper_space.tree_lock),
-	.a_ops		= &swap_aops,
-	.i_mmap_nonlinear = LIST_HEAD_INIT(swapper_space.i_mmap_nonlinear),
-	.backing_dev_info = &swap_backing_dev_info,
+struct address_space swapper_spaces[MAX_SWAPFILES] = {
+	[0 ... MAX_SWAPFILES - 1] = {
+		.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
+		.a_ops		= &swap_aops,
+		.backing_dev_info = &swap_backing_dev_info,
+	}
 };
 
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
@@ -53,9 +53,19 @@ static struct {
 	unsigned long find_total;
 } swap_cache_info;
 
+unsigned long total_swapcache_pages(void)
+{
+	int i;
+	unsigned long ret = 0;
+
+	for (i = 0; i < MAX_SWAPFILES; i++)
+		ret += swapper_spaces[i].nrpages;
+	return ret;
+}
+
 void show_swap_cache_info(void)
 {
-	printk("%lu pages in swap cache\n", total_swapcache_pages);
+	printk("%lu pages in swap cache\n", total_swapcache_pages());
 	printk("Swap cache stats: add %lu, delete %lu, find %lu/%lu\n",
 		swap_cache_info.add_total, swap_cache_info.del_total,
 		swap_cache_info.find_success, swap_cache_info.find_total);
@@ -76,17 +86,18 @@ static int __add_to_swap_cache(struct pa
 	VM_BUG_ON(!PageSwapBacked(page));
 
 	page_cache_get(page);
-	SetPageSwapCache(page);
 	set_page_private(page, entry.val);
+	SetPageSwapCache(page);
 
-	spin_lock_irq(&swapper_space.tree_lock);
-	error = radix_tree_insert(&swapper_space.page_tree, entry.val, page);
+	spin_lock_irq(&swap_address_space(entry)->tree_lock);
+	error = radix_tree_insert(&swap_address_space(entry)->page_tree,
+					entry.val, page);
 	if (likely(!error)) {
-		total_swapcache_pages++;
+		swap_address_space(entry)->nrpages++;
 		__inc_zone_page_state(page, NR_FILE_PAGES);
 		INC_CACHE_INFO(add_total);
 	}
-	spin_unlock_irq(&swapper_space.tree_lock);
+	spin_unlock_irq(&swap_address_space(entry)->tree_lock);
 
 	if (unlikely(error)) {
 		/*
@@ -122,14 +133,18 @@ int add_to_swap_cache(struct page *page,
  */
 void __delete_from_swap_cache(struct page *page)
 {
+	swp_entry_t entry;
+
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(!PageSwapCache(page));
 	VM_BUG_ON(PageWriteback(page));
 
-	radix_tree_delete(&swapper_space.page_tree, page_private(page));
+	entry.val = page_private(page);
+	radix_tree_delete(&swap_address_space(entry)->page_tree,
+		page_private(page));
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
-	total_swapcache_pages--;
+	swap_address_space(entry)->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
 }
@@ -198,9 +213,9 @@ void delete_from_swap_cache(struct page
 
 	entry.val = page_private(page);
 
-	spin_lock_irq(&swapper_space.tree_lock);
+	spin_lock_irq(&swap_address_space(entry)->tree_lock);
 	__delete_from_swap_cache(page);
-	spin_unlock_irq(&swapper_space.tree_lock);
+	spin_unlock_irq(&swap_address_space(entry)->tree_lock);
 
 	swapcache_free(entry, page);
 	page_cache_release(page);
@@ -263,7 +278,7 @@ struct page * lookup_swap_cache(swp_entr
 {
 	struct page *page;
 
-	page = find_get_page(&swapper_space, entry.val);
+	page = find_get_page(swap_address_space(entry), entry.val);
 
 	if (page)
 		INC_CACHE_INFO(find_success);
@@ -290,7 +305,8 @@ struct page *read_swap_cache_async(swp_e
 		 * called after lookup_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
-		found_page = find_get_page(&swapper_space, entry.val);
+		found_page = find_get_page(swap_address_space(entry),
+					entry.val);
 		if (found_page)
 			break;
 
Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2012-12-10 08:51:21.749920518 +0800
+++ linux/mm/swapfile.c	2012-12-10 09:02:45.037330401 +0800
@@ -79,7 +79,7 @@ __try_to_reclaim_swap(struct swap_info_s
 	struct page *page;
 	int ret = 0;
 
-	page = find_get_page(&swapper_space, entry.val);
+	page = find_get_page(swap_address_space(entry), entry.val);
 	if (!page)
 		return 0;
 	/*
@@ -699,7 +699,8 @@ int free_swap_and_cache(swp_entry_t entr
 	p = swap_info_get(entry);
 	if (p) {
 		if (swap_entry_free(p, entry, 1) == SWAP_HAS_CACHE) {
-			page = find_get_page(&swapper_space, entry.val);
+			page = find_get_page(swap_address_space(entry),
+						entry.val);
 			if (page && !trylock_page(page)) {
 				page_cache_release(page);
 				page = NULL;
Index: linux/fs/proc/meminfo.c
===================================================================
--- linux.orig/fs/proc/meminfo.c	2012-12-10 08:51:21.785920064 +0800
+++ linux/fs/proc/meminfo.c	2012-12-10 09:02:45.037330401 +0800
@@ -40,7 +40,7 @@ static int meminfo_proc_show(struct seq_
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;
 
 	cached = global_page_state(NR_FILE_PAGES) -
-			total_swapcache_pages - i.bufferram;
+			total_swapcache_pages() - i.bufferram;
 	if (cached < 0)
 		cached = 0;
 
@@ -109,7 +109,7 @@ static int meminfo_proc_show(struct seq_
 		K(i.freeram),
 		K(i.bufferram),
 		K(cached),
-		K(total_swapcache_pages),
+		K(total_swapcache_pages()),
 		K(pages[LRU_ACTIVE_ANON]   + pages[LRU_ACTIVE_FILE]),
 		K(pages[LRU_INACTIVE_ANON] + pages[LRU_INACTIVE_FILE]),
 		K(pages[LRU_ACTIVE_ANON]),
Index: linux/kernel/audit_tree.c
===================================================================
--- linux.orig/kernel/audit_tree.c	2012-12-10 08:51:21.793919964 +0800
+++ linux/kernel/audit_tree.c	2012-12-10 09:02:45.037330401 +0800
@@ -28,7 +28,7 @@ struct audit_chunk {
 	int count;
 	atomic_long_t refs;
 	struct rcu_head head;
-	struct node {
+	struct audit_node {
 		struct list_head list;
 		struct audit_tree *owner;
 		unsigned index;		/* index; upper bit indicates 'will prune' */
@@ -62,7 +62,7 @@ static LIST_HEAD(prune_list);
  * chunk is refcounted by embedded fsnotify_mark + .refs (non-zero refcount
  * of watch contributes 1 to .refs).
  *
- * node.index allows to get from node.list to containing chunk.
+ * audit_node.index allows to get from audit_node.list to containing chunk.
  * MSB of that sucker is stolen to mark taggings that we might have to
  * revert - several operations have very unpleasant cleanup logics and
  * that makes a difference.  Some.
@@ -140,7 +140,8 @@ static struct audit_chunk *alloc_chunk(i
 	size_t size;
 	int i;
 
-	size = offsetof(struct audit_chunk, owners) + count * sizeof(struct node);
+	size = offsetof(struct audit_chunk, owners) +
+			count * sizeof(struct audit_node);
 	chunk = kzalloc(size, GFP_KERNEL);
 	if (!chunk)
 		return NULL;
@@ -206,14 +207,14 @@ int audit_tree_match(struct audit_chunk
 
 /* tagging and untagging inodes with trees */
 
-static struct audit_chunk *find_chunk(struct node *p)
+static struct audit_chunk *find_chunk(struct audit_node *p)
 {
 	int index = p->index & ~(1U<<31);
 	p -= index;
 	return container_of(p, struct audit_chunk, owners[0]);
 }
 
-static void untag_chunk(struct node *p)
+static void untag_chunk(struct audit_node *p)
 {
 	struct audit_chunk *chunk = find_chunk(p);
 	struct fsnotify_mark *entry = &chunk->mark;
@@ -356,7 +357,7 @@ static int tag_chunk(struct inode *inode
 	struct fsnotify_mark *old_entry, *chunk_entry;
 	struct audit_tree *owner;
 	struct audit_chunk *chunk, *old;
-	struct node *p;
+	struct audit_node *p;
 	int n;
 
 	old_entry = fsnotify_find_inode_mark(audit_tree_group, inode);
@@ -484,9 +485,9 @@ static void prune_one(struct audit_tree
 {
 	spin_lock(&hash_lock);
 	while (!list_empty(&victim->chunks)) {
-		struct node *p;
+		struct audit_node *p;
 
-		p = list_entry(victim->chunks.next, struct node, list);
+		p = list_entry(victim->chunks.next, struct audit_node, list);
 
 		untag_chunk(p);
 	}
@@ -506,7 +507,8 @@ static void trim_marked(struct audit_tre
 	}
 	/* reorder */
 	for (p = tree->chunks.next; p != &tree->chunks; p = q) {
-		struct node *node = list_entry(p, struct node, list);
+		struct audit_node *node = list_entry(p, struct audit_node,
+						list);
 		q = p->next;
 		if (node->index & (1U<<31)) {
 			list_del_init(p);
@@ -515,9 +517,9 @@ static void trim_marked(struct audit_tre
 	}
 
 	while (!list_empty(&tree->chunks)) {
-		struct node *node;
+		struct audit_node *node;
 
-		node = list_entry(tree->chunks.next, struct node, list);
+		node = list_entry(tree->chunks.next, struct audit_node, list);
 
 		/* have we run out of marked? */
 		if (!(node->index & (1U<<31)))
@@ -580,7 +582,7 @@ void audit_trim_trees(void)
 		struct audit_tree *tree;
 		struct path path;
 		struct vfsmount *root_mnt;
-		struct node *node;
+		struct audit_node *node;
 		int err;
 
 		tree = container_of(cursor.next, struct audit_tree, list);
@@ -679,7 +681,7 @@ int audit_add_tree_rule(struct audit_kru
 	drop_collected_mounts(mnt);
 
 	if (!err) {
-		struct node *node;
+		struct audit_node *node;
 		spin_lock(&hash_lock);
 		list_for_each_entry(node, &tree->chunks, list)
 			node->index &= ~(1U<<31);
@@ -781,7 +783,7 @@ int audit_tag_tree(char *old, char *new)
 		mutex_unlock(&audit_filter_mutex);
 
 		if (!failed) {
-			struct node *node;
+			struct audit_node *node;
 			spin_lock(&hash_lock);
 			list_for_each_entry(node, &tree->chunks, list)
 				node->index &= ~(1U<<31);
Index: linux/include/linux/swapops.h
===================================================================
--- linux.orig/include/linux/swapops.h	2012-12-10 08:51:21.821919610 +0800
+++ linux/include/linux/swapops.h	2012-12-10 09:02:45.037330401 +0800
@@ -4,52 +4,6 @@
 #include <linux/radix-tree.h>
 #include <linux/bug.h>
 
-/*
- * swapcache pages are stored in the swapper_space radix tree.  We want to
- * get good packing density in that tree, so the index should be dense in
- * the low-order bits.
- *
- * We arrange the `type' and `offset' fields so that `type' is at the seven
- * high-order bits of the swp_entry_t and `offset' is right-aligned in the
- * remaining bits.  Although `type' itself needs only five bits, we allow for
- * shmem/tmpfs to shift it all up a further two bits: see swp_to_radix_entry().
- *
- * swp_entry_t's are *never* stored anywhere in their arch-dependent format.
- */
-#define SWP_TYPE_SHIFT(e)	((sizeof(e.val) * 8) - \
-			(MAX_SWAPFILES_SHIFT + RADIX_TREE_EXCEPTIONAL_SHIFT))
-#define SWP_OFFSET_MASK(e)	((1UL << SWP_TYPE_SHIFT(e)) - 1)
-
-/*
- * Store a type+offset into a swp_entry_t in an arch-independent format
- */
-static inline swp_entry_t swp_entry(unsigned long type, pgoff_t offset)
-{
-	swp_entry_t ret;
-
-	ret.val = (type << SWP_TYPE_SHIFT(ret)) |
-			(offset & SWP_OFFSET_MASK(ret));
-	return ret;
-}
-
-/*
- * Extract the `type' field from a swp_entry_t.  The swp_entry_t is in
- * arch-independent format
- */
-static inline unsigned swp_type(swp_entry_t entry)
-{
-	return (entry.val >> SWP_TYPE_SHIFT(entry));
-}
-
-/*
- * Extract the `offset' field from a swp_entry_t.  The swp_entry_t is in
- * arch-independent format
- */
-static inline pgoff_t swp_offset(swp_entry_t entry)
-{
-	return entry.val & SWP_OFFSET_MASK(entry);
-}
-
 #ifdef CONFIG_MMU
 /* check whether a pte points to a swap entry */
 static inline int is_swap_pte(pte_t pte)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
