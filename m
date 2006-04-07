Received: from smtp1.fc.hp.com (smtp.fc.hp.com [15.15.136.127])
	by atlrel6.hp.com (Postfix) with ESMTP id 5A53E341C2
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:22:22 -0400 (EDT)
Received: from ldl.fc.hp.com (ldl.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id 361921097F
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:22:22 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 10CF5134225
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:22:22 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 21216-07 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:22:20 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 600CE134250
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:22:19 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 3/6] Migrate-on-fault - migrate
	misplaced page
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441108.5198.36.camel@localhost.localdomain>
References: <1144441108.5198.36.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:23:43 -0400
Message-Id: <1144441424.5198.42.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Migrate-on-fault prototype 3/6 V0.2 - migrate misplaced page

V0.2 - reworked against 2.6.17-rc1-mm1 with Christoph's migration
       code reorg.

This patch adds a new function migrate_misplaced_page() to mm/migrate.c
[where most of the other page migration functions live] to migrate a
misplace page to a specified destination node.  This function will be
called from the fault path.  Because we already know the destination
node for the migration, we allocate pages directly rather than rerunning
the policy node computation in alloc_page_vma().

migrate_misplaced_page() will need to put a single page [the old or
new page] back to the lru, so this patch also splits out a
"putback_lru_page()" function from move_lru_page().  This avoids having
to insert the page on a dummy list just to have move_lru_page() delete
it from the list.

The patch also updates the address space migratepage operations to
skip the attempt to unmap the page, if the operation is being called
in the fault path to migrate a misplaced page.  To accomplish this, I
added an additional boolean [int] argument "faulting" to the migratepage
op functions.   This argument also adjusts the # of expected page
references because we have an extra count when called in the fault
path.

The migratepage operations now use the migrate_page_try_to_unmap()
and migrate_page_replace_in_mapping() functions separated out in a
previous patch.

I believe that we can now delete migrate_page_remove_references().
But, I haven't, yet.

Finally, the page adds the static inline function 
check_migrate_misplaced_page() to mempolicy.h to check whether a
page has no mappings [no pte references] and is "misplaced"--i.e.
on a node different from what the policy for (vma, address) dictates.
In this case, the page will be migrated to the "correct" node, if
possible.  If migration fails for any reason, we just use the
original page.

Note that when NUMA or MIGRATION is not configured, the
check_migrate_misplaced_page() function becomes a macro that
evaluates to its page argument.

Subsequent patches will hook the fault handlers [anon, file, shmem]
to check_migrate_misplaced_page().

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.17-rc1-mm1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.17-rc1-mm1.orig/include/linux/mempolicy.h	2006-04-05 10:14:39.000000000 -0400
+++ linux-2.6.17-rc1-mm1/include/linux/mempolicy.h	2006-04-05 10:14:41.000000000 -0400
@@ -34,6 +34,7 @@
 #include <linux/rbtree.h>
 #include <linux/spinlock.h>
 #include <linux/nodemask.h>
+#include <linux/migrate.h>
 
 struct vm_area_struct;
 
@@ -184,6 +185,31 @@ int do_migrate_pages(struct mm_struct *m
 int mpol_misplaced(struct page *, struct vm_area_struct *,
 		unsigned long, int *);
 
+#if defined(CONFIG_MIGRATION) && defined(_LINUX_MM_H)
+/*
+ * called in fault path, where _LINUX_MM_H will be defined.
+ * page is uptodate and locked.
+ */
+static inline struct page *check_migrate_misplaced_page(struct page *page,
+		struct vm_area_struct *vma, unsigned long address)
+{
+	int polnid, misplaced;
+
+	if (page_mapcount(page) || PageWriteback(page))
+		return page;
+
+	misplaced = mpol_misplaced(page, vma, address, &polnid);
+	if (!misplaced)
+		return page;
+
+	return migrate_misplaced_page(page, polnid,
+			misplaced_is_interleaved(misplaced));
+
+}
+#else
+#define check_migrate_misplaced_page(page, vma, address) (page)
+#endif
+
 extern void *cpuset_being_rebound;	/* Trigger mpol_copy vma rebind */
 
 #else
@@ -279,6 +305,8 @@ static inline int do_migrate_pages(struc
 	return 0;
 }
 
+#define check_migrate_misplaced_page(page, vma, address) (page)
+
 static inline void check_highest_zone(int k)
 {
 }
Index: linux-2.6.17-rc1-mm1/include/linux/fs.h
===================================================================
--- linux-2.6.17-rc1-mm1.orig/include/linux/fs.h	2006-04-05 10:14:36.000000000 -0400
+++ linux-2.6.17-rc1-mm1/include/linux/fs.h	2006-04-05 10:14:41.000000000 -0400
@@ -373,7 +373,7 @@ struct address_space_operations {
 	struct page* (*get_xip_page)(struct address_space *, sector_t,
 			int);
 	/* migrate the contents of a page to the specified target */
-	int (*migratepage) (struct page *, struct page *);
+	int (*migratepage) (struct page *, struct page *, int);
 };
 
 struct backing_dev_info;
@@ -1760,7 +1760,7 @@ extern void simple_release_fs(struct vfs
 extern ssize_t simple_read_from_buffer(void __user *, size_t, loff_t *, const void *, size_t);
 
 #ifdef CONFIG_MIGRATION
-extern int buffer_migrate_page(struct page *, struct page *);
+extern int buffer_migrate_page(struct page *, struct page *, int);
 #else
 #define buffer_migrate_page NULL
 #endif
Index: linux-2.6.17-rc1-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.17-rc1-mm1.orig/include/linux/gfp.h	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.17-rc1-mm1/include/linux/gfp.h	2006-04-05 10:14:41.000000000 -0400
@@ -131,10 +131,13 @@ alloc_pages(gfp_t gfp_mask, unsigned int
 }
 extern struct page *alloc_page_vma(gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr);
+extern struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
+					unsigned nid);
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
 #define alloc_page_vma(gfp_mask, vma, addr) alloc_pages(gfp_mask, 0)
+#define alloc_page_interleave(gfp_mask, order, nid) alloc_pages(gfp_mask, 0)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 
Index: linux-2.6.17-rc1-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc1-mm1.orig/mm/mempolicy.c	2006-04-05 10:14:39.000000000 -0400
+++ linux-2.6.17-rc1-mm1/mm/mempolicy.c	2006-04-05 10:14:41.000000000 -0400
@@ -1179,7 +1179,7 @@ struct zonelist *huge_zonelist(struct vm
 
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */
-static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
+struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 					unsigned nid)
 {
 	struct zonelist *zl;
Index: linux-2.6.17-rc1-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc1-mm1.orig/mm/migrate.c	2006-04-05 10:14:38.000000000 -0400
+++ linux-2.6.17-rc1-mm1/mm/migrate.c	2006-04-05 10:14:41.000000000 -0400
@@ -59,7 +59,8 @@ int isolate_lru_page(struct page *page, 
 				del_page_from_active_list(zone, page);
 			else
 				del_page_from_inactive_list(zone, page);
-			list_add_tail(&page->lru, pagelist);
+			if (pagelist)
+				list_add_tail(&page->lru, pagelist);
 		}
 		spin_unlock_irq(&zone->lru_lock);
 	}
@@ -88,9 +89,14 @@ int migrate_prep(void)
 	return 0;
 }
 
-static inline void move_to_lru(struct page *page)
+/*
+ * Put a single page back to appropriate lru list via cache.
+ * Removes page reference added by isolate_lru_page, but
+ * the lru_cache_add*() will add a temporary ref while the
+ * pages resides in the cache [pagevec].
+ */
+static inline void putback_lru_page(struct page *page)
 {
-	list_del(&page->lru);
 	if (PageActive(page)) {
 		/*
 		 * lru_cache_add_active checks that
@@ -104,6 +110,12 @@ static inline void move_to_lru(struct pa
 	put_page(page);
 }
 
+static inline void move_to_lru(struct page *page)
+{
+	list_del(&page->lru);
+	putback_lru_page(page);
+}
+
 /*
  * Add isolated pages on the list back to the LRU.
  *
@@ -125,7 +137,7 @@ int putback_lru_pages(struct list_head *
 /*
  * Non migratable page
  */
-int fail_migrate_page(struct page *newpage, struct page *page)
+int fail_migrate_page(struct page *newpage, struct page *page, int faulting)
 {
 	return -EIO;
 }
@@ -335,29 +347,35 @@ EXPORT_SYMBOL(migrate_page_copy);
  *
  * Pages are locked upon entry and exit.
  */
-int migrate_page(struct page *newpage, struct page *page)
+int migrate_page(struct page *newpage, struct page *page, int faulting)
 {
-	int rc;
-	int nr_refs = 2;	/* cache + current */
+	int rc = 0;
+	/*
+	 * nr_refs:  cache + current [+ fault path]
+	 */
+	int nr_refs = 2 + !!faulting;
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_unmap_and_replace(newpage, page, nr_refs);
-
+	if (!faulting)
+		rc = migrate_page_try_to_unmap(page, nr_refs);
+	if (!rc)
+		rc = migrate_page_replace_in_mapping(newpage, page, nr_refs);
 	if (rc)
 		return rc;
 
 	migrate_page_copy(newpage, page);
 
 	/*
-	 * Remove auxiliary swap entries and replace
-	 * them with real ptes.
+	 * If we are not already in the fault path, remove auxiliary swap
+	 * entries and replace them with real ptes.
 	 *
 	 * Note that a real pte entry will allow processes that are not
 	 * waiting on the page lock to use the new page via the page tables
 	 * before the new page is unlocked.
 	 */
-	remove_from_swap(newpage);
+	if (!faulting)
+		remove_from_swap(newpage);
 	return 0;
 }
 EXPORT_SYMBOL(migrate_page);
@@ -468,7 +486,7 @@ redo:
 			 * own migration function. This is the most common
 			 * path for page migration.
 			 */
-			rc = mapping->a_ops->migratepage(newpage, page);
+			rc = mapping->a_ops->migratepage(newpage, page, 0);
 			goto unlock_both;
                 }
 
@@ -498,7 +516,7 @@ redo:
 		 */
 		if (!page_has_buffers(page) ||
 		    try_to_release_page(page, GFP_KERNEL)) {
-			rc = migrate_page(newpage, page);
+			rc = migrate_page(newpage, page, 0);
 			goto unlock_both;
 		}
 
@@ -555,23 +573,28 @@ next:
  * if the underlying filesystem guarantees that no other references to "page"
  * exist.
  */
-int buffer_migrate_page(struct page *newpage, struct page *page)
+int buffer_migrate_page(struct page *newpage, struct page *page, int faulting)
 {
 	struct address_space *mapping = page->mapping;
 	struct buffer_head *bh, *head;
-	int nr_refs = 3;	/* cache + bufs + current */
-	int rc;
+	int rc = 0;
+	/*
+	 * nr_refs:  cache + bufs + current [+ fault path]
+	 */
+	int nr_refs = 3 + !!faulting;
 
 	if (!mapping)
 		return -EAGAIN;
 
 	if (!page_has_buffers(page))
-		return migrate_page(newpage, page);
+		return migrate_page(newpage, page, faulting);
 
 	head = page_buffers(page);
 
- 	rc = migrate_page_unmap_and_replace(newpage, page, nr_refs);
-
+	if (!faulting)
+		rc = migrate_page_try_to_unmap(page, nr_refs);
+	if (!rc)
+		rc = migrate_page_replace_in_mapping(newpage, page, nr_refs);
 	if (rc)
 		return rc;
 
@@ -683,3 +706,71 @@ out:
 		nr_pages++;
 	return nr_pages;
 }
+
+/*
+ * attempt to migrate a misplaced page to the specified destination
+ * node.  Page is already unmapped and locked by caller. Anon pages
+ * are in the swap cache.
+ *
+ * page refs on entry/exit:  cache + fault path [+ bufs]
+ */
+struct page *migrate_misplaced_page(struct page *page,
+				 int dest, int interleaved)
+{
+	struct page *newpage;
+	struct address_space *mapping = page_mapping(page);
+	unsigned int gfp;
+
+//TODO:  explicit assertions during debug/testing
+	BUG_ON(!PageLocked(page));
+	BUG_ON(page_mapcount(page));
+	if (PageAnon(page))
+		BUG_ON(!PageSwapCache(page));
+	BUG_ON(!mapping);
+
+	if (isolate_lru_page(page, NULL)) /* incrs page count on success */
+		goto out_nolru;	/* we lost */
+
+//TODO:  or just use GFP_HIGHUSER ?
+	gfp = (unsigned int)mapping_gfp_mask(mapping);
+
+	if (interleaved)
+		newpage = alloc_page_interleave(gfp, 0, dest);
+	else
+		newpage = alloc_pages_node(dest, gfp, 0);
+
+	if (!newpage)
+		goto out;	/* give up */
+	lock_page(newpage);
+
+	if (mapping->a_ops->migratepage) {
+		/*
+		 * migrating in fault path.
+		 * migrate a_op transfers cache [+ buf] refs
+		 */
+		int rc = mapping->a_ops->migratepage(newpage, page, 1);
+		if (rc) {
+			unlock_page(newpage);
+			__free_page(newpage);
+		} else {
+			get_page(newpage);	/* add isolate_lru_page ref */
+			put_page(page);		/* drop       "          "  */
+
+			unlock_page(page);
+			put_page(page);		/* drop fault path ref & free */
+
+			page = newpage;
+		}
+		goto out;
+	} else {
+//TODO:  for now, give up if no address space migrate op.
+//       later, handle w/ default mechanism, like migrate_pages?
+	}
+
+out:
+	putback_lru_page(page);		/* drops a page ref */
+
+out_nolru:
+	return page;
+
+}
Index: linux-2.6.17-rc1-mm1/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc1-mm1.orig/include/linux/migrate.h	2006-04-05 10:14:38.000000000 -0400
+++ linux-2.6.17-rc1-mm1/include/linux/migrate.h	2006-04-05 10:14:41.000000000 -0400
@@ -7,7 +7,7 @@
 #ifdef CONFIG_MIGRATION
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
-extern int migrate_page(struct page *, struct page *);
+extern int migrate_page(struct page *, struct page *, int);
 extern void migrate_page_copy(struct page *, struct page *);
 extern int migrate_page_try_to_unmap(struct page *, int);
 extern int migrate_page_replace_in_mapping(struct page *, struct page *, int);
@@ -16,7 +16,8 @@ extern int migrate_pages(struct list_hea
 		struct list_head *moved, struct list_head *failed);
 extern int migrate_pages_to(struct list_head *pagelist,
 			struct vm_area_struct *vma, int dest);
-extern int fail_migrate_page(struct page *, struct page *);
+struct page *migrate_misplaced_page(struct page *, int, int);
+extern int fail_migrate_page(struct page *, struct page *, int);
 
 extern int migrate_prep(void);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
