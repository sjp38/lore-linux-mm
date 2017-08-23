Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4164628038B
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 09:51:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p2so1204172pfi.4
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 06:51:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r18si1088401pgd.381.2017.08.23.06.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 06:51:23 -0700 (PDT)
Subject: Re: [RESEND PATCH 2/3] mm: Add page colored allocation path
References: <20170823100205.17311-1-lukasz.daniluk@intel.com>
 <20170823100205.17311-3-lukasz.daniluk@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b1fcdc2e-51a2-8258-fde3-e30231e3db4f@intel.com>
Date: Wed, 23 Aug 2017 06:51:21 -0700
MIME-Version: 1.0
In-Reply-To: <20170823100205.17311-3-lukasz.daniluk@intel.com>
Content-Type: multipart/mixed;
 boundary="------------AFB806B320FF3C36625E295F"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?=c5=81ukasz_Daniluk?= <lukasz.daniluk@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: lukasz.anaczkowski@intel.com

This is a multi-part message in MIME format.
--------------AFB806B320FF3C36625E295F
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

On 08/23/2017 03:02 AM, A?ukasz Daniluk wrote:
> +	cache_color_size=
> +			[KNL] Set cache size for purposes of cache coloring
> +			mechanism in buddy allocator.
> +
> +	cache_color_min_order=
> +			[KNL] Set minimal order for which page coloring
> +			mechanism will be enabled in buddy allocator.

I guess I should send along the code I've been playing with.  I have
this broken out into a bunch of helper patches, but I'll just attach the
combined patch.

This also uses an rbtree, but it puts 'struct page' itself in the
rbtree.  Further, it reuses the zone->free_area list_heads' storage for
the rbtree head.  This means no additional space overhead and you can
also enable it at runtime without boot options.  You can also have it
enabled for any order(s) you want.

The rbtree(s) you've grafted on will not need to be walked or rebalanced
as much as the ones in my version, so that's a plus for your version.

The trick with either of these is trying to make sure the cost of all
the new branches very low.

--------------AFB806B320FF3C36625E295F
Content-Type: text/x-patch;
 name="rbtree-buddy-20170706.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rbtree-buddy-20170706.patch"

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 45cdb27..b7dd66d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -104,6 +104,16 @@ struct page {
 		};
 	};
 
+	union {
+		/*
+		 * This is fugly, but it works for now.
+		 *
+		 * An rb_node needs three pointers.  Take
+		 * the space from page->lru (2) and
+		 * page->private (1).
+		 */
+		struct rb_node rb;
+	struct {
 	/*
 	 * Third double word block
 	 *
@@ -185,7 +195,9 @@ struct page {
 #endif
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
 	};
+	};
 
+	};
 #ifdef CONFIG_MEMCG
 	struct mem_cgroup *mem_cgroup;
 #endif
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ef6a13b..c70cb02 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -17,6 +17,7 @@
 #include <linux/pageblock-flags.h>
 #include <linux/page-flags-layout.h>
 #include <linux/atomic.h>
+#include <linux/rbtree.h>
 #include <asm/page.h>
 
 /* Free memory management - zoned buddy allocator.  */
@@ -92,8 +93,18 @@ static inline bool is_migrate_movable(int mt)
 	get_pfnblock_flags_mask(page, page_to_pfn(page),		\
 			PB_migrate_end, MIGRATETYPE_MASK)
 
+union free_area_list {
+	/* Used for orders where !tree_free_order(): */
+	struct list_head list;
+	/* Used for orders where tree_free_order()==true: */
+	struct {
+		struct rb_root rb_root;
+		unsigned long  rb_color;
+	};
+};
+
 struct free_area {
-	struct list_head	free_list[MIGRATE_TYPES];
+	union free_area_list	free_pages[MIGRATE_TYPES];
 	unsigned long		nr_free;
 };
 
@@ -828,6 +839,9 @@ static inline bool populated_zone(struct zone *zone)
 
 extern int movable_zone;
 
+extern unsigned long free_page_count(struct zone *zone, int order, int mt);
+extern bool free_area_empty(int order, struct free_area *area, int mt);
+
 #ifdef CONFIG_HIGHMEM
 static inline int zone_movable_is_highmem(void)
 {
diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index fcbd568..fd1bd46 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -408,14 +408,14 @@ static int __init crash_save_vmcoreinfo_init(void)
 	VMCOREINFO_OFFSET(zone, free_area);
 	VMCOREINFO_OFFSET(zone, vm_stat);
 	VMCOREINFO_OFFSET(zone, spanned_pages);
-	VMCOREINFO_OFFSET(free_area, free_list);
+	VMCOREINFO_OFFSET(free_area, free_pages);
 	VMCOREINFO_OFFSET(list_head, next);
 	VMCOREINFO_OFFSET(list_head, prev);
 	VMCOREINFO_OFFSET(vmap_area, va_start);
 	VMCOREINFO_OFFSET(vmap_area, list);
 	VMCOREINFO_LENGTH(zone.free_area, MAX_ORDER);
 	log_buf_vmcoreinfo_setup();
-	VMCOREINFO_LENGTH(free_area.free_list, MIGRATE_TYPES);
+	VMCOREINFO_LENGTH(free_area.free_pages, MIGRATE_TYPES);
 	VMCOREINFO_NUMBER(NR_FREE_PAGES);
 	VMCOREINFO_NUMBER(PG_lru);
 	VMCOREINFO_NUMBER(PG_private);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 4dfba1a..c48229a 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -113,6 +113,10 @@
 #ifndef CONFIG_MMU
 extern int sysctl_nr_trim_pages;
 #endif
+extern int sysctl_tree_free_order;
+extern int tree_free_order_sysctl_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos);
+
 
 /* Constants used for minimum and  maximum */
 #ifdef CONFIG_LOCKUP_DETECTOR
@@ -134,6 +138,7 @@
 #ifdef CONFIG_PERF_EVENTS
 static int six_hundred_forty_kb = 640 * 1024;
 #endif
+static int max_order_minus_one = MAX_ORDER-1;
 
 /* this is needed for the proc_doulongvec_minmax of vm_dirty_bytes */
 static unsigned long dirty_bytes_min = 2 * PAGE_SIZE;
@@ -1387,6 +1392,15 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.extra1		= &one,
 		.extra2		= &four,
 	},
+	{
+		.procname	= "tree_free_order",
+		.data		= &sysctl_tree_free_order,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= tree_free_order_sysctl_handler,
+		.extra1		= &neg_one,
+		.extra2		= &max_order_minus_one,
+	},
 #ifdef CONFIG_COMPACTION
 	{
 		.procname	= "compact_memory",
diff --git a/mm/compaction.c b/mm/compaction.c
index 613c59e..73c0e71 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1335,13 +1335,13 @@ static enum compact_result __compact_finished(struct zone *zone,
 		bool can_steal;
 
 		/* Job done if page is free of the right migratetype */
-		if (!list_empty(&area->free_list[migratetype]))
+		if (!free_area_empty(order, area, migratetype))
 			return COMPACT_SUCCESS;
 
 #ifdef CONFIG_CMA
 		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
 		if (migratetype == MIGRATE_MOVABLE &&
-			!list_empty(&area->free_list[MIGRATE_CMA]))
+			!free_area_empty(order, area, MIGRATE_CMA))
 			return COMPACT_SUCCESS;
 #endif
 		/*
diff --git a/mm/internal.h b/mm/internal.h
index 0e4f558..716dd90 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -227,7 +227,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 static inline unsigned int page_order(struct page *page)
 {
 	/* PageBuddy() must be checked by the caller */
-	return page_private(page);
+	return page->index;
 }
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2302f25..184197c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -66,6 +66,7 @@
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
 #include <linux/ftrace.h>
+#include <linux/debugfs.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -718,14 +719,14 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
 
 static inline void set_page_order(struct page *page, unsigned int order)
 {
-	set_page_private(page, order);
+	page->index = order;
 	__SetPageBuddy(page);
 }
 
 static inline void rmv_page_order(struct page *page)
 {
 	__ClearPageBuddy(page);
-	set_page_private(page, 0);
+	page->index = 0;
 }
 
 /*
@@ -771,6 +772,443 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	return 0;
 }
 
+#define DEFAULT_TREE_FREE_ORDER 99
+int __tree_free_order = DEFAULT_TREE_FREE_ORDER;
+static bool tree_free_order(int order)
+{
+	if (order >= __tree_free_order)
+		return true;
+	return false;
+}
+
+int rb_count(struct rb_root *root)
+{
+	int count = 0;
+	struct page *page;
+	struct page *next;
+
+	rbtree_postorder_for_each_entry_safe(page, next, root, rb)
+		count++;
+
+	return count;
+}
+
+struct page *struct_page_from_rb(struct rb_node *rb)
+{
+	return rb_entry(rb, struct page, rb);
+}
+
+u64 pfn_cache_colors = 0;
+static unsigned long pfn_cache_color(unsigned long pfn)
+{
+	if (!pfn_cache_colors)
+		return 0;
+	return pfn % pfn_cache_colors;
+}
+
+static int __init pfn_cache_colors_debugfs(void)
+{
+	umode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
+
+	if (!debugfs_create_u64("pfn-cache-colors", mode, NULL,
+				&pfn_cache_colors))
+		return -ENOMEM;
+
+	return 0;
+}
+late_initcall(pfn_cache_colors_debugfs);
+
+static int rb_cmp_page(struct page *p1, struct page *p2)
+{
+	unsigned long pfn1 = page_to_pfn(p1);
+	unsigned long pfn2 = page_to_pfn(p2);
+	unsigned long color1 = pfn_cache_color(pfn1);
+	unsigned long color2 = pfn_cache_color(pfn2);
+
+	/*
+	 * Sort first by color:
+	 */
+	if (color1 != color2)
+		return color1 < color2;
+
+	/*
+	 * Then sort by pfn.
+	 *
+	 * We really only need to sort on the non-color bits, but
+	 * this comparison yields the same results and is cheaper
+	 * than masking the color bits off.
+	 */
+	return pfn1 < pfn2;
+}
+
+static void rb_free_area_insert(struct page *page, struct rb_root *root)
+{
+	struct rb_node **rbp = &root->rb_node;
+	struct rb_node *parent = NULL;
+
+	while (*rbp) {
+		parent = *rbp;
+		if (rb_cmp_page(page, struct_page_from_rb(parent)))
+			rbp = &(*rbp)->rb_left;
+		else
+			rbp = &(*rbp)->rb_right;
+	}
+
+	rb_link_node(&page->rb, parent, rbp);
+	rb_insert_color(&page->rb, root);
+}
+
+/* Used for pages not on another list */
+static void add_to_free_area(struct page *page, int order,
+			     struct free_area *area,
+			     int migratetype)
+{
+	if (tree_free_order(order)) {
+		rb_free_area_insert(page, &area->free_pages[migratetype].rb_root);
+	} else {
+		list_add(&page->lru, &area->free_pages[migratetype].list);
+	}
+}
+
+/* Used for pages not on another list */
+static void add_to_free_area_tail(struct page *page, int order,
+				  struct free_area *area,
+				  int migratetype)
+{
+	/*
+	 * We are doing ordering based on paddr, not hot/cold,
+	 * so this is just a normal insert:
+	 */
+	if (tree_free_order(order)) {
+		add_to_free_area(page, order, area, migratetype);
+	} else {
+		list_add_tail(&page->lru, &area->free_pages[migratetype].list);
+	}
+}
+
+struct rb_root *page_rb_root(struct page *page, struct free_area *area)
+{
+	int i;
+	struct rb_node *tmp;
+	struct rb_node *head_node;
+	struct rb_root *root = NULL;
+
+	/* Walk up tree to find head node: */
+	tmp = &page->rb;
+	while (rb_parent(tmp))
+		tmp = rb_parent(tmp);
+	head_node = tmp;
+
+	/* Now go find the root among the migratetype rbtrees: */
+	for (i = 0; i < MIGRATE_TYPES; i++) {
+		if (area->free_pages[i].rb_root.rb_node == head_node) {
+			root = &area->free_pages[i].rb_root;
+			break;
+		}
+	}
+	VM_BUG_ON(!root);
+	return root;
+}
+
+/* Used for pages which are on another list */
+static void move_to_free_area(struct page *page, int order,
+			      struct free_area *area,
+			     int migratetype)
+{
+	if (tree_free_order(order)) {
+		/*
+		 * We found this page through physical scanning,
+		 * so we have no idea what migratetype it is.
+		 * We need to scan all the migratetype rbtree
+		 * roots to find the root:
+		 */
+		struct rb_root *old_root = page_rb_root(page, area);
+
+		/* Erase page from root: */
+		rb_erase(&page->rb, old_root);
+
+		rb_free_area_insert(page, &area->free_pages[migratetype].rb_root);
+	} else {
+		list_move(&page->lru, &area->free_pages[migratetype].list);
+	}
+}
+
+/*
+ * Find a page in the rbtree with the given cache color.
+ *
+ * This is confusing because we have an rbtree that has
+ * colored (red/black) nodes, and we also have the cache
+ * color of the pages, which we are searching for.
+ *
+ * This entire function refers only to the cache color
+ * of the memory, *NOT* its color in the rbtree.
+ */
+struct rb_node *rb_find_page(struct rb_root *root, unsigned long *rb_color, int order)
+{
+	struct rb_node *n;
+
+	n = root->rb_node;
+	if (!n)
+		return NULL;
+
+	/*
+	 * We do not initialize this, so rb_color can be
+	 * basically random values.  Sanitize it before
+	 * using it.
+	 */
+	if (*rb_color >= pfn_cache_colors)
+		*rb_color = 0;
+
+	/* Walk down the tree: */
+	while (n) {
+		struct page *tmp = struct_page_from_rb(n);
+		unsigned long pfn = page_to_pfn(tmp);
+
+		if (pfn_cache_color(pfn) > *rb_color) {
+			//trace_printk("going left  at color: %lx\n", pfn_cache_color(pfn));
+			/* Dead end, color not found.  Return something: */
+			if (!n->rb_left)
+				break;
+			/* Walk down the tree looking for the color: */
+			n = n->rb_left;
+		} else if (pfn_cache_color(pfn) < *rb_color) {
+			//trace_printk("going right at color: %lx\n", pfn_cache_color(pfn));
+			/*
+			 * Dead end, color not found.  Return something: */
+			if (!n->rb_right)
+				break;
+			/* Walk down the tree looking for the color: */
+			n = n->rb_right;
+		} else {
+			/* Found the color we want, return it: */
+			break;
+		}
+	}
+
+	if (pfn_cache_colors) {
+		trace_printk("rb_color search: %ld result color: %ld colors: %ld\n",
+				*rb_color,
+				pfn_cache_color(page_to_pfn(struct_page_from_rb(n))),
+				(unsigned long)pfn_cache_colors);
+		/*
+		 * Order-1 pages contain two subpages, one of each color
+		 * Order-2 pages always have 4 colors
+		 * etc...
+		 *
+		 * We increment this for the colors of all the subpages.
+		 * We need to do this because we only search by the head
+		 * page color.
+		 */
+		(*rb_color) += (1 << order);
+	}
+	return n;
+}
+
+static struct page *get_page_from_free_area(int order, struct free_area *area,
+					    int migratetype)
+{
+	struct page *page;
+	struct rb_root *root = &area->free_pages[migratetype].rb_root;
+	unsigned long *rb_color = &area->free_pages[migratetype].rb_color;
+	if (tree_free_order(order)) {
+		struct rb_node *rb = rb_find_page(root, rb_color, order);
+
+		if (!rb)
+			return NULL;
+
+		page = rb_entry(rb, struct page, rb);
+		return page;
+	} else {
+		page = list_first_entry_or_null(&area->free_pages[migratetype].list,
+					struct page, lru);
+
+		return page;
+	}
+}
+
+static void del_page_from_free_area(struct page *page, int order,
+				    struct free_area *area,
+				    int migratetype)
+{
+	if (tree_free_order(order)) {
+		struct rb_root *root = &area->free_pages[migratetype].rb_root;
+		/*
+		 * rb->__parent_color has low bits set, while list_heads do
+		 * not.  We must clear this to make PageTail() not trigger.
+		 */
+		rb_erase(&page->rb, root);
+		page->compound_head = 0;
+	} else {
+		list_del(&page->lru);
+	}
+}
+
+bool free_area_empty(int order, struct free_area *area, int migratetype)
+{
+	if (tree_free_order(order)) {
+		struct rb_root *root = &area->free_pages[migratetype].rb_root;
+		return RB_EMPTY_ROOT(root);
+	} else {
+		return list_empty(&area->free_pages[migratetype].list);
+	}
+}
+
+static void __tree_to_list(struct zone *zone, int order, struct free_area *area, int migratetype)
+{
+	struct rb_root *root = &area->free_pages[migratetype].rb_root;
+	struct list_head *new_head = &area->free_pages[migratetype].list;
+	struct list_head tmp_head;
+	struct page *page;
+	struct page *next;
+
+	INIT_LIST_HEAD(&tmp_head);
+
+	/*
+	 * rbtree_postorder_for_each_entry_safe() is not safe if
+	 * 'page' has rb_erase() called on it.  So just do this
+	 * an entry at a time until empty.
+	 */
+	while (!free_area_empty(order, area, migratetype)) {
+		rbtree_postorder_for_each_entry_safe(page, next, root, rb) {
+			rb_erase(&page->rb, root);
+			list_add(&page->lru, &tmp_head);
+			break;
+		}
+	}
+	INIT_LIST_HEAD(new_head);
+	list_splice(&tmp_head, new_head);
+}
+
+static void tree_to_list(struct zone *zone, int order)
+{
+	struct free_area *area = &(zone->free_area[order]);
+	int i;
+
+	for (i = 0; i < MIGRATE_TYPES; i++)
+		__tree_to_list(zone, order, area, i);
+}
+
+static void __list_to_tree(struct zone *zone, int order, struct free_area *area, int migratetype)
+{
+	struct list_head *head = &area->free_pages[migratetype].list;
+	struct rb_root *new_root = &area->free_pages[migratetype].rb_root;
+	struct rb_root tmp_root = RB_ROOT;
+	struct page *page;
+	struct page *next;
+
+	if (list_empty(head))
+		goto out;
+
+	list_for_each_entry_safe(page, next, head, lru) {
+		list_del_init(&page->lru);
+		rb_free_area_insert(page, &tmp_root);
+	}
+out:
+	new_root->rb_node = tmp_root.rb_node;
+}
+
+static void list_to_tree(struct zone *zone, int order)
+{
+	struct free_area *area = &(zone->free_area[order]);
+	int i;
+
+	for (i = 0; i < MIGRATE_TYPES; i++) {
+		__list_to_tree(zone, order, area, i);
+	}
+}
+
+static void set_zone_tree_free_order(struct zone *zone, int new_order)
+{
+	int i;
+
+	if (!zone_is_initialized(zone))
+		return;
+	if (!populated_zone(zone))
+		return;
+
+	for (i = 0; i < MAX_ORDER; i++) {
+		if (i < new_order && i < __tree_free_order) {
+			/* Not a tree order now, not going to be */
+		} else if (i >= new_order && i <  __tree_free_order) {
+			/* needs to be a tree and is a list now*/
+			list_to_tree(zone, i);
+		} else if (i < new_order  && i >= __tree_free_order) {
+			/* needs to be a list, but is a tree */
+			tree_to_list(zone, i);
+		} else if (i >= new_order && i >= __tree_free_order) {
+			/* Tree order now, and staying that way */
+		}
+	}
+}
+
+static void set_tree_free_order(int new_order)
+{
+	struct zone *zone;
+	unsigned long flags;
+
+	/*
+	 * Just totally disable irqs so we do not have to store
+	 * a per-zone flags for each spin_lock_irq().
+	 */
+	local_irq_save(flags);
+
+	/*
+	 * There is only one __tree_free_order for all zones,
+	 * so we need to lock them all before we make a change.
+	 */
+
+	for_each_populated_zone(zone) {
+		spin_lock(&zone->lock);
+	}
+
+	for_each_populated_zone(zone)
+		set_zone_tree_free_order(zone, new_order);
+	__tree_free_order = new_order;
+
+	for_each_populated_zone(zone) {
+		spin_unlock(&zone->lock);
+	}
+
+	local_irq_restore(flags);
+}
+
+int sysctl_tree_free_order = DEFAULT_TREE_FREE_ORDER;
+int tree_free_order_sysctl_handler(struct ctl_table *table, int write,
+				   void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int new_tree_free_order;
+	int ret;
+
+	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (ret)
+		return ret;
+
+	new_tree_free_order = sysctl_tree_free_order;
+	if (new_tree_free_order == -1)
+		new_tree_free_order = MAX_ORDER;
+
+	set_tree_free_order(new_tree_free_order);
+
+	return 0;
+}
+
+unsigned long free_page_count(struct zone *zone, int order, int mt)
+{
+	unsigned long ret = 0;
+	struct list_head *curr;
+	struct free_area *area = &(zone->free_area[order]);
+	union free_area_list *pages = &area->free_pages[mt];
+
+	if (tree_free_order(order)) {
+		ret = rb_count(&pages->rb_root);
+	} else {
+		list_for_each(curr, &pages->list)
+			ret++;
+	}
+
+	return ret;
+}
+
 /*
  * Freeing function for a buddy system allocator.
  *
@@ -834,7 +1272,7 @@ static inline void __free_one_page(struct page *page,
 		if (page_is_guard(buddy)) {
 			clear_page_guard(zone, buddy, order, migratetype);
 		} else {
-			list_del(&buddy->lru);
+			del_page_from_free_area(buddy, order, &zone->free_area[order], migratetype);
 			zone->free_area[order].nr_free--;
 			rmv_page_order(buddy);
 		}
@@ -887,13 +1325,13 @@ static inline void __free_one_page(struct page *page,
 		higher_buddy = higher_page + (buddy_pfn - combined_pfn);
 		if (pfn_valid_within(buddy_pfn) &&
 		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
-			list_add_tail(&page->lru,
-				&zone->free_area[order].free_list[migratetype]);
+			add_to_free_area_tail(page, order, &zone->free_area[order],
+					      migratetype);
 			goto out;
 		}
 	}
 
-	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
+	add_to_free_area(page, order, &zone->free_area[order], migratetype);
 out:
 	zone->free_area[order].nr_free++;
 }
@@ -1653,7 +2091,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		list_add(&page[size].lru, &area->free_list[migratetype]);
+		add_to_free_area(&page[size], high, area, migratetype);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -1795,11 +2233,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	/* Find a page of the appropriate size in the preferred list */
 	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
 		area = &(zone->free_area[current_order]);
-		page = list_first_entry_or_null(&area->free_list[migratetype],
-							struct page, lru);
+		page = get_page_from_free_area(current_order, area, migratetype);
 		if (!page)
 			continue;
-		list_del(&page->lru);
+		del_page_from_free_area(page, current_order, area, migratetype);
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
@@ -1889,8 +2326,7 @@ static int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
+		move_to_free_area(page, order, &zone->free_area[order], migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -2039,7 +2475,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 
 single_page:
 	area = &zone->free_area[current_order];
-	list_move(&page->lru, &area->free_list[start_type]);
+	move_to_free_area(page, current_order, area, start_type);
 }
 
 /*
@@ -2063,7 +2499,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 		if (fallback_mt == MIGRATE_TYPES)
 			break;
 
-		if (list_empty(&area->free_list[fallback_mt]))
+		if (free_area_empty(order, area, fallback_mt))
 			continue;
 
 		if (can_steal_fallback(order, migratetype))
@@ -2150,9 +2586,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 		for (order = 0; order < MAX_ORDER; order++) {
 			struct free_area *area = &(zone->free_area[order]);
 
-			page = list_first_entry_or_null(
-					&area->free_list[MIGRATE_HIGHATOMIC],
-					struct page, lru);
+			page = get_page_from_free_area(order, area, MIGRATE_HIGHATOMIC);
 			if (!page)
 				continue;
 
@@ -2224,8 +2658,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 		if (fallback_mt == -1)
 			continue;
 
-		page = list_first_entry(&area->free_list[fallback_mt],
-						struct page, lru);
+		page = get_page_from_free_area(current_order, area, fallback_mt);
 
 		steal_suitable_fallback(zone, page, start_migratetype,
 								can_steal);
@@ -2491,6 +2924,15 @@ void drain_all_pages(struct zone *zone)
 
 #ifdef CONFIG_HIBERNATION
 
+void mark_free_page(struct page *page, order)
+{
+	unsigned long i;
+	unsigned long pfn = page_to_pfn(page);
+
+	for (i = 0; i < (1UL << order); i++)
+		swsusp_set_page_free(pfn_to_page(pfn + i));
+}
+
 void mark_free_pages(struct zone *zone)
 {
 	unsigned long pfn, max_zone_pfn;
@@ -2516,13 +2958,17 @@ void mark_free_pages(struct zone *zone)
 		}
 
 	for_each_migratetype_order(order, t) {
-		list_for_each_entry(page,
-				&zone->free_area[order].free_list[t], lru) {
-			unsigned long i;
+		if (!tree_free_order(order)) {
+			list_for_each_entry(page,
+				&zone->free_area[order].free_pages[t].list, lru)
+				mark_free_page(page, order);
+		} else {
+			struct page *page, next;
+			struct rb_root *root = &zone->free_area[order].free_pages[t].rb_root;
 
-			pfn = page_to_pfn(page);
-			for (i = 0; i < (1UL << order); i++)
-				swsusp_set_page_free(pfn_to_page(pfn + i));
+			rbtree_postorder_for_each_entry_safe(page, next, root, rb) {
+				mark_free_page(page, order);
+			}
 		}
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -2649,7 +3095,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	}
 
 	/* Remove page from free list */
-	list_del(&page->lru);
+	del_page_from_free_area(page, order, &zone->free_area[order], mt);
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
 
@@ -2938,13 +3384,13 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 			return true;
 
 		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
-			if (!list_empty(&area->free_list[mt]))
+			if (!free_area_empty(o, area, mt))
 				return true;
 		}
 
 #ifdef CONFIG_CMA
 		if ((alloc_flags & ALLOC_CMA) &&
-		    !list_empty(&area->free_list[MIGRATE_CMA])) {
+		    !free_area_empty(o, area, MIGRATE_CMA)) {
 			return true;
 		}
 #endif
@@ -4671,7 +5117,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 			types[order] = 0;
 			for (type = 0; type < MIGRATE_TYPES; type++) {
-				if (!list_empty(&area->free_list[type]))
+				if (!free_area_empty(order, area, type))
 					types[order] |= 1 << type;
 			}
 		}
@@ -5343,7 +5789,10 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 {
 	unsigned int order, t;
 	for_each_migratetype_order(order, t) {
-		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
+		if (tree_free_order(order))
+			zone->free_area[order].free_pages[t].rb_root = RB_ROOT;
+		else
+			INIT_LIST_HEAD(&zone->free_area[order].free_pages[t].list);
 		zone->free_area[order].nr_free = 0;
 	}
 }
@@ -7686,6 +8135,7 @@ void zone_pcp_reset(struct zone *zone)
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
 #endif
+		BUG_ON(1); // FIXME
 		list_del(&page->lru);
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 76f7367..18f23c1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1180,15 +1180,8 @@ static void pagetypeinfo_showfree_print(struct seq_file *m,
 					zone->name,
 					migratetype_names[mtype]);
 		for (order = 0; order < MAX_ORDER; ++order) {
-			unsigned long freecount = 0;
-			struct free_area *area;
-			struct list_head *curr;
-
-			area = &(zone->free_area[order]);
-
-			list_for_each(curr, &area->free_list[mtype])
-				freecount++;
-			seq_printf(m, "%6lu ", freecount);
+			seq_printf(m, "%6lu ",
+					free_page_count(zone, order, mtype));
 		}
 		seq_putc(m, '\n');
 	}

--------------AFB806B320FF3C36625E295F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
