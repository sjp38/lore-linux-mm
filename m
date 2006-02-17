Subject: [RFC] 1/4 - Migration Cache Core Implementation
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 17 Feb 2006 10:35:46 -0500
Message-Id: <1140190546.5219.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Migration Cache "V8" 1/4

This patch contains the core implementation of a "migration cache"
for 2.6.16+ direct migration.  Because the migration cache is
essentially a "pseudo-swap device"--it steals the maximum swap
device id--the core implementation now resides in mm/swap_state.c
along with the real swap address space functions.  Also, a few
changes were required--especially in page locking--to accomodate
the 2.6.16 usage and "migration_move_to_swap()"--provided in a
separate patch.

Subsequent patches will add the necessary checks for pages that
are in the migration cache and for migration cache pte entries
throughout the MM subsystem, and will modify the direct migration
functions to use the migration cache when destination pages are
available.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc3-mm1/mm/swap_state.c
===================================================================
--- linux-2.6.16-rc3-mm1.orig/mm/swap_state.c	2006-02-15 10:50:43.000000000 -0500
+++ linux-2.6.16-rc3-mm1/mm/swap_state.c	2006-02-15 10:50:47.000000000 -0500
@@ -18,6 +18,250 @@
 
 #include <asm/pgtable.h>
 
+#ifdef CONFIG_MIGRATION
+#include <linux/idr.h>
+#include <linux/swapops.h>
+
+/*
+ * Migration Cache:  a pseudo-swap device and separate address space
+ * for anon pages that have been unmapped for migration.
+ */
+
+struct counter {
+	int i;	/* references to this migration cache entry */
+};
+
+struct idr migration_idr;
+
+static struct address_space_operations migration_aops = {
+	.writepage      = NULL,
+	.sync_page      = NULL,
+	.set_page_dirty = __set_page_dirty_nobuffers,
+	.migratepage	= migrate_page,
+};
+
+static struct backing_dev_info migration_backing_dev_info = {
+	.capabilities   = BDI_CAP_NO_ACCT_DIRTY|BDI_CAP_NO_WRITEBACK,
+	.unplug_io_fn   = NULL,
+};
+
+struct address_space migration_space = {
+	.page_tree      = RADIX_TREE_INIT(GFP_ATOMIC),
+	.tree_lock      = RW_LOCK_UNLOCKED,
+	.a_ops          = &migration_aops,
+	.flags          = GFP_HIGHUSER,
+	.i_mmap_nonlinear = LIST_HEAD_INIT(migration_space.i_mmap_nonlinear),
+	.backing_dev_info = &migration_backing_dev_info,
+};
+
+int __init init_migration_cache(void)
+{
+	idr_init(&migration_idr);
+
+	return 0;
+}
+
+__initcall(init_migration_cache);
+
+/*
+ * is page in migration cache?
+ */
+int page_is_migration(struct page *page)
+{
+        swp_entry_t entry;
+
+	if (!PageSwapCache(page))
+		return 0;
+
+	entry.val = page->private;
+
+	if (swp_type(entry) != MIGRATION_TYPE)
+		return 0;
+
+	return 1;
+}
+
+struct page *lookup_migration_cache(swp_entry_t entry)
+{
+	return find_get_page(&migration_space, entry.val);
+}
+
+void migration_duplicate(swp_entry_t entry)
+{
+	struct counter *cnt;
+
+	read_lock_irq(&migration_space.tree_lock);
+
+	cnt = idr_find(&migration_idr, (int)swp_offset(entry));
+	if (!cnt) {
+		read_unlock_irq(&migration_space.tree_lock);
+		BUG();
+	}
+	cnt->i = cnt->i + 1;
+
+	read_unlock_irq(&migration_space.tree_lock);
+}
+
+/*
+ * Number of references to migration cache page.
+ * Unlike swap cache, migration cache does not include
+ * a count for the cache itself.  The existence of the
+ * counter serves as the cache ref.
+ */
+int migration_ref_count(swp_entry_t entry)
+{
+	struct counter *cnt;
+	int ref;
+
+	read_lock_irq(&migration_space.tree_lock);
+
+	cnt = idr_find(&migration_idr, (int)swp_offset(entry));
+	if (!cnt) {
+		read_unlock_irq(&migration_space.tree_lock);
+		BUG();
+	}
+	ref = cnt->i;
+
+	read_unlock_irq(&migration_space.tree_lock);
+	return ref;
+}
+
+/*
+ * Unconditionally remove page from migration cache at 'id'
+ */
+static void remove_from_migration_cache(struct page *page, unsigned long id)
+{
+	write_lock_irq(&migration_space.tree_lock);
+	idr_remove(&migration_idr, (int)id);
+	radix_tree_delete(&migration_space.page_tree, id);
+	if (page) {
+		ClearPageSwapCache(page);
+		page->private = 0;
+	}
+	write_unlock_irq(&migration_space.tree_lock);
+}
+
+
+/*
+ * decrement reference on migration cache entry by @dec;
+ * free if goes to zero.
+ * page, if !NULL, must be locked
+ */
+void __migration_remove_reference(struct page *page, swp_entry_t entry,
+			int dec)
+{
+	struct counter *c;
+
+	read_lock_irq(&migration_space.tree_lock);
+	c = idr_find(&migration_idr, (int)swp_offset(entry));
+	if (!c) {
+		read_unlock_irq(&migration_space.tree_lock);
+		if (dec)
+			BUG();
+		return;		/* TODO:  warn? bug? */
+	}
+
+	BUG_ON(c->i < dec);
+	c->i -= dec;
+	read_unlock_irq(&migration_space.tree_lock);
+
+	if (!c->i) {
+		remove_from_migration_cache(page, entry.val);
+		kfree(c);
+		if (page)
+			page_cache_release(page); /* cache's ref */
+	}
+}
+
+/*
+ * remove reference on migration cache entry, given a page
+ * in the migration cache
+ */
+void migration_remove_reference(struct page *page, int dec)
+{
+	swp_entry_t entry;
+
+	entry.val = page_private(page);
+	BUG_ON(!entry.val);
+
+	__migration_remove_reference(page, entry, dec);
+
+}
+
+/*
+ * remove entry's reference on page in migration cache
+ * page may be locked or not.
+ */
+void migration_remove_entry(swp_entry_t entry, int locked)
+{
+	struct page *page;
+
+	page = find_get_page(&migration_space, entry.val);
+
+	if (!page)
+		BUG();
+
+	if (locked)
+		BUG_ON(!PageLocked(page));
+	else
+		lock_page(page);
+
+	migration_remove_reference(page, 1);
+
+	if (!locked)
+		unlock_page(page);
+
+	page_cache_release(page);	/* our ref */
+}
+
+int add_to_migration_cache(struct page *page, int gfp_mask)
+{
+	int error, offset;
+	struct counter *counter;
+	swp_entry_t entry;
+
+	BUG_ON(!PageLocked(page));
+	BUG_ON(PageSwapCache(page));
+	BUG_ON(PagePrivate(page));
+
+        if (idr_pre_get(&migration_idr, GFP_ATOMIC) == 0)
+                return -ENOMEM;
+
+	counter = kmalloc(sizeof(struct counter), GFP_KERNEL);
+
+	if (!counter)
+		return -ENOMEM;
+
+	error = radix_tree_preload(gfp_mask);
+
+	counter->i = 0;
+
+	if (!error) {
+		write_lock_irq(&migration_space.tree_lock);
+	        error = idr_get_new_above(&migration_idr, counter, 1, &offset);
+
+		if (error < 0)
+			BUG();
+
+		entry = swp_entry(MIGRATION_TYPE, offset);
+
+		error = radix_tree_insert(&migration_space.page_tree, entry.val,
+							page);
+		if (!error) {
+			page_cache_get(page);
+			page->private = entry.val;
+			SetPageSwapCache(page);
+			SetPageUptodate(page);		/* like add_to_swap() */
+		}
+		write_unlock_irq(&migration_space.tree_lock);
+		radix_tree_preload_end();
+
+	}
+
+	return error;
+}
+#endif /* CONFIG_MIGRATION */
+
 /*
  * swapper_space is a fiction, retained to simplify the path through
  * vmscan's shrink_list, to make sync_page look nicer, and to allow
Index: linux-2.6.16-rc3-mm1/include/linux/swapops.h
===================================================================
--- linux-2.6.16-rc3-mm1.orig/include/linux/swapops.h	2006-02-15 10:50:43.000000000 -0500
+++ linux-2.6.16-rc3-mm1/include/linux/swapops.h	2006-02-15 10:50:47.000000000 -0500
@@ -67,3 +67,35 @@ static inline pte_t swp_entry_to_pte(swp
 	BUG_ON(pte_file(__swp_entry_to_pte(arch_entry)));
 	return __swp_entry_to_pte(arch_entry);
 }
+
+#ifdef CONFIG_MIGRATION
+
+#define MIGRATION_TYPE  (MAX_SWAPFILES - 1)
+
+/*
+ * test '>=' for validating type in sys_swapon();
+ * strictly speaking, '==' should be sufficient.
+ */
+static inline int migration_type(unsigned int type)
+{
+	return (type >= MIGRATION_TYPE);
+}
+
+static inline int pte_is_migrant(pte_t pte)
+{
+	unsigned long swp_type;
+	swp_entry_t arch_entry;
+
+	arch_entry = __pte_to_swp_entry(pte);
+	swp_type = __swp_type(arch_entry);
+
+	return swp_type == MIGRATION_TYPE;
+}
+
+
+#else /* !CONFIG_MIGRATION */
+
+#define migration_type(type) (0)
+#define pte_is_migrant(pte)  (0)
+
+#endif /* CONFIG_MIGRATION */
Index: linux-2.6.16-rc3-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.16-rc3-mm1.orig/include/linux/swap.h	2006-02-15 10:50:43.000000000 -0500
+++ linux-2.6.16-rc3-mm1/include/linux/swap.h	2006-02-15 10:50:47.000000000 -0500
@@ -197,6 +197,15 @@ extern int migrate_page_remove_reference
 extern unsigned long migrate_pages(struct list_head *l, struct list_head *t,
 		struct list_head *moved, struct list_head *failed);
 extern int fail_migrate_page(struct page *, struct page *);
+
+extern int add_to_migration_cache(struct page *, int);
+extern void migration_remove_entry(swp_entry_t, int);
+extern void migration_duplicate(swp_entry_t);
+extern int migration_ref_count(swp_entry_t);
+extern void migration_remove_reference(struct page *, int);
+extern void __migration_remove_reference(struct page *, swp_entry_t,
+		 int);
+extern struct page *lookup_migration_cache(swp_entry_t);
 #else
 static inline int isolate_lru_page(struct page *p) { return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
@@ -205,6 +214,22 @@ static inline int migrate_pages(struct l
 /* Possible settings for the migrate_page() method in address_operations */
 #define migrate_page NULL
 #define fail_migrate_page NULL
+
+static inline int add_to_migration_cache(struct page *p, int i)
+{
+	return -ENOSYS;
+}
+#define migration_remove_entry(swp, locked)	/*NOTHING*/
+#define migration_duplicate(swp)		/*NOTHING*/
+#define migration_ref_count(swp)		0
+#define migration_remove_reference(page, dec)	/*NOTHING*/
+static inline void __migration_remove_reference(struct page *page,
+	 swp_entry_t entry, int dec) { }
+
+static inline struct page *lookup_migration_cache(swp_entry_t entry)
+{
+	return (struct page *)0;
+}
 #endif
 
 #ifdef CONFIG_MMU


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
