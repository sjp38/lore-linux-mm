Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A9C2E6B007B
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 11:57:11 -0500 (EST)
Date: Tue, 24 Nov 2009 16:56:47 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 8/9] ksm: memory hotremove migration only
In-Reply-To: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
Message-ID: <Pine.LNX.4.64.0911241654230.25288@sister.anvils>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The previous patch enables page migration of ksm pages, but that soon
gets into trouble: not surprising, since we're using the ksm page lock
to lock operations on its stable_node, but page migration switches the
page whose lock is to be used for that.  Another layer of locking would
fix it, but do we need that yet?

Do we actually need page migration of ksm pages?  Yes, memory hotremove
needs to offline sections of memory: and since we stopped allocating
ksm pages with GFP_HIGHUSER, they will tend to be GFP_HIGHUSER_MOVABLE
candidates for migration.

But KSM is currently unconscious of NUMA issues, happily merging pages
from different NUMA nodes: at present the rule must be, not to use
MADV_MERGEABLE where you care about NUMA.  So no, NUMA page migration
of ksm pages does not make sense yet.

So, to complete support for ksm swapping we need to make hotremove safe.
ksm_memory_callback() take ksm_thread_mutex when MEM_GOING_OFFLINE and
release it when MEM_OFFLINE or MEM_CANCEL_OFFLINE.  But if mapped pages
are freed before migration reaches them, stable_nodes may be left still
pointing to struct pages which have been removed from the system: the
stable_node needs to identify a page by pfn rather than page pointer,
then it can safely prune them when MEM_OFFLINE.

And make NUMA migration skip PageKsm pages where it skips PageReserved.
But it's only when we reach unmap_and_move() that the page lock is taken
and we can be sure that raised pagecount has prevented a PageAnon from
being upgraded: so add offlining arg to migrate_pages(), to migrate ksm
page when offlining (has sufficient locking) but reject it otherwise.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/migrate.h |    8 +--
 mm/ksm.c                |   84 ++++++++++++++++++++++++++++++++------
 mm/memory_hotplug.c     |    2 
 mm/mempolicy.c          |   19 +++-----
 mm/migrate.c            |   27 +++++++++---
 5 files changed, 103 insertions(+), 37 deletions(-)

--- ksm7/include/linux/migrate.h	2009-03-23 23:12:14.000000000 +0000
+++ ksm8/include/linux/migrate.h	2009-11-22 20:40:53.000000000 +0000
@@ -12,7 +12,8 @@ typedef struct page *new_page_t(struct p
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
-extern int migrate_pages(struct list_head *l, new_page_t x, unsigned long);
+extern int migrate_pages(struct list_head *l, new_page_t x,
+			unsigned long private, int offlining);
 
 extern int fail_migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -26,10 +27,7 @@ extern int migrate_vmas(struct mm_struct
 
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
 static inline int migrate_pages(struct list_head *l, new_page_t x,
-		unsigned long private) { return -ENOSYS; }
-
-static inline int migrate_pages_to(struct list_head *pagelist,
-			struct vm_area_struct *vma, int dest) { return 0; }
+		unsigned long private, int offlining) { return -ENOSYS; }
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 
--- ksm7/mm/ksm.c	2009-11-22 20:40:46.000000000 +0000
+++ ksm8/mm/ksm.c	2009-11-22 20:40:53.000000000 +0000
@@ -29,6 +29,7 @@
 #include <linux/wait.h>
 #include <linux/slab.h>
 #include <linux/rbtree.h>
+#include <linux/memory.h>
 #include <linux/mmu_notifier.h>
 #include <linux/swap.h>
 #include <linux/ksm.h>
@@ -108,14 +109,14 @@ struct ksm_scan {
 
 /**
  * struct stable_node - node of the stable rbtree
- * @page: pointer to struct page of the ksm page
  * @node: rb node of this ksm page in the stable tree
  * @hlist: hlist head of rmap_items using this ksm page
+ * @kpfn: page frame number of this ksm page
  */
 struct stable_node {
-	struct page *page;
 	struct rb_node node;
 	struct hlist_head hlist;
+	unsigned long kpfn;
 };
 
 /**
@@ -515,7 +516,7 @@ static struct page *get_ksm_page(struct
 	struct page *page;
 	void *expected_mapping;
 
-	page = stable_node->page;
+	page = pfn_to_page(stable_node->kpfn);
 	expected_mapping = (void *)stable_node +
 				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
 	rcu_read_lock();
@@ -973,7 +974,7 @@ static struct page *try_to_merge_two_pag
  * This function returns the stable tree node of identical content if found,
  * NULL otherwise.
  */
-static struct stable_node *stable_tree_search(struct page *page)
+static struct page *stable_tree_search(struct page *page)
 {
 	struct rb_node *node = root_stable_tree.rb_node;
 	struct stable_node *stable_node;
@@ -981,7 +982,7 @@ static struct stable_node *stable_tree_s
 	stable_node = page_stable_node(page);
 	if (stable_node) {			/* ksm page forked */
 		get_page(page);
-		return stable_node;
+		return page;
 	}
 
 	while (node) {
@@ -1003,7 +1004,7 @@ static struct stable_node *stable_tree_s
 			put_page(tree_page);
 			node = node->rb_right;
 		} else
-			return stable_node;
+			return tree_page;
 	}
 
 	return NULL;
@@ -1059,7 +1060,7 @@ static struct stable_node *stable_tree_i
 
 	INIT_HLIST_HEAD(&stable_node->hlist);
 
-	stable_node->page = kpage;
+	stable_node->kpfn = page_to_pfn(kpage);
 	set_page_stable_node(kpage, stable_node);
 
 	return stable_node;
@@ -1170,9 +1171,8 @@ static void cmp_and_merge_page(struct pa
 	remove_rmap_item_from_tree(rmap_item);
 
 	/* We first start with searching the page inside the stable tree */
-	stable_node = stable_tree_search(page);
-	if (stable_node) {
-		kpage = stable_node->page;
+	kpage = stable_tree_search(page);
+	if (kpage) {
 		err = try_to_merge_with_ksm_page(rmap_item, page, kpage);
 		if (!err) {
 			/*
@@ -1180,7 +1180,7 @@ static void cmp_and_merge_page(struct pa
 			 * add its rmap_item to the stable tree.
 			 */
 			lock_page(kpage);
-			stable_tree_append(rmap_item, stable_node);
+			stable_tree_append(rmap_item, page_stable_node(kpage));
 			unlock_page(kpage);
 		}
 		put_page(kpage);
@@ -1715,12 +1715,63 @@ void ksm_migrate_page(struct page *newpa
 
 	stable_node = page_stable_node(newpage);
 	if (stable_node) {
-		VM_BUG_ON(stable_node->page != oldpage);
-		stable_node->page = newpage;
+		VM_BUG_ON(stable_node->kpfn != page_to_pfn(oldpage));
+		stable_node->kpfn = page_to_pfn(newpage);
 	}
 }
 #endif /* CONFIG_MIGRATION */
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+static struct stable_node *ksm_check_stable_tree(unsigned long start_pfn,
+						 unsigned long end_pfn)
+{
+	struct rb_node *node;
+
+	for (node = rb_first(&root_stable_tree); node; node = rb_next(node)) {
+		struct stable_node *stable_node;
+
+		stable_node = rb_entry(node, struct stable_node, node);
+		if (stable_node->kpfn >= start_pfn &&
+		    stable_node->kpfn < end_pfn)
+			return stable_node;
+	}
+	return NULL;
+}
+
+static int ksm_memory_callback(struct notifier_block *self,
+			       unsigned long action, void *arg)
+{
+	struct memory_notify *mn = arg;
+	struct stable_node *stable_node;
+
+	switch (action) {
+	case MEM_GOING_OFFLINE:
+		/*
+		 * Keep it very simple for now: just lock out ksmd and
+		 * MADV_UNMERGEABLE while any memory is going offline.
+		 */
+		mutex_lock(&ksm_thread_mutex);
+		break;
+
+	case MEM_OFFLINE:
+		/*
+		 * Most of the work is done by page migration; but there might
+		 * be a few stable_nodes left over, still pointing to struct
+		 * pages which have been offlined: prune those from the tree.
+		 */
+		while ((stable_node = ksm_check_stable_tree(mn->start_pfn,
+					mn->start_pfn + mn->nr_pages)) != NULL)
+			remove_node_from_stable_tree(stable_node);
+		/* fallthrough */
+
+	case MEM_CANCEL_OFFLINE:
+		mutex_unlock(&ksm_thread_mutex);
+		break;
+	}
+	return NOTIFY_OK;
+}
+#endif /* CONFIG_MEMORY_HOTREMOVE */
+
 #ifdef CONFIG_SYSFS
 /*
  * This all compiles without CONFIG_SYSFS, but is a waste of space.
@@ -1946,6 +1997,13 @@ static int __init ksm_init(void)
 
 #endif /* CONFIG_SYSFS */
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+	/*
+	 * Choose a high priority since the callback takes ksm_thread_mutex:
+	 * later callbacks could only be taking locks which nest within that.
+	 */
+	hotplug_memory_notifier(ksm_memory_callback, 100);
+#endif
 	return 0;
 
 out_free2:
--- ksm7/mm/memory_hotplug.c	2009-11-14 10:17:02.000000000 +0000
+++ ksm8/mm/memory_hotplug.c	2009-11-22 20:40:53.000000000 +0000
@@ -698,7 +698,7 @@ do_migrate_range(unsigned long start_pfn
 	if (list_empty(&source))
 		goto out;
 	/* this function returns # of failed pages */
-	ret = migrate_pages(&source, hotremove_migrate_alloc, 0);
+	ret = migrate_pages(&source, hotremove_migrate_alloc, 0, 1);
 
 out:
 	return ret;
--- ksm7/mm/mempolicy.c	2009-11-14 10:17:02.000000000 +0000
+++ ksm8/mm/mempolicy.c	2009-11-22 20:40:53.000000000 +0000
@@ -85,6 +85,7 @@
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/migrate.h>
+#include <linux/ksm.h>
 #include <linux/rmap.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
@@ -413,17 +414,11 @@ static int check_pte_range(struct vm_are
 		if (!page)
 			continue;
 		/*
-		 * The check for PageReserved here is important to avoid
-		 * handling zero pages and other pages that may have been
-		 * marked special by the system.
-		 *
-		 * If the PageReserved would not be checked here then f.e.
-		 * the location of the zero page could have an influence
-		 * on MPOL_MF_STRICT, zero pages would be counted for
-		 * the per node stats, and there would be useless attempts
-		 * to put zero pages on the migration list.
+		 * vm_normal_page() filters out zero pages, but there might
+		 * still be PageReserved pages to skip, perhaps in a VDSO.
+		 * And we cannot move PageKsm pages sensibly or safely yet.
 		 */
-		if (PageReserved(page))
+		if (PageReserved(page) || PageKsm(page))
 			continue;
 		nid = page_to_nid(page);
 		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
@@ -839,7 +834,7 @@ static int migrate_to_node(struct mm_str
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist))
-		err = migrate_pages(&pagelist, new_node_page, dest);
+		err = migrate_pages(&pagelist, new_node_page, dest, 0);
 
 	return err;
 }
@@ -1056,7 +1051,7 @@ static long do_mbind(unsigned long start
 
 		if (!list_empty(&pagelist))
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
-						(unsigned long)vma);
+						(unsigned long)vma, 0);
 
 		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
--- ksm7/mm/migrate.c	2009-11-22 20:40:46.000000000 +0000
+++ ksm8/mm/migrate.c	2009-11-22 20:40:53.000000000 +0000
@@ -543,7 +543,7 @@ static int move_to_new_page(struct page
  * to the newly allocated page in newpage.
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
-			struct page *page, int force)
+			struct page *page, int force, int offlining)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -569,6 +569,20 @@ static int unmap_and_move(new_page_t get
 		lock_page(page);
 	}
 
+	/*
+	 * Only memory hotplug's offline_pages() caller has locked out KSM,
+	 * and can safely migrate a KSM page.  The other cases have skipped
+	 * PageKsm along with PageReserved - but it is only now when we have
+	 * the page lock that we can be certain it will not go KSM beneath us
+	 * (KSM will not upgrade a page from PageAnon to PageKsm when it sees
+	 * its pagecount raised, but only here do we take the page lock which
+	 * serializes that).
+	 */
+	if (PageKsm(page) && !offlining) {
+		rc = -EBUSY;
+		goto unlock;
+	}
+
 	/* charge against new page */
 	charge = mem_cgroup_prepare_migration(page, &mem);
 	if (charge == -ENOMEM) {
@@ -685,7 +699,7 @@ move_newpage:
  * Return: Number of pages not migrated or error code.
  */
 int migrate_pages(struct list_head *from,
-		new_page_t get_new_page, unsigned long private)
+		new_page_t get_new_page, unsigned long private, int offlining)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -705,7 +719,7 @@ int migrate_pages(struct list_head *from
 			cond_resched();
 
 			rc = unmap_and_move(get_new_page, private,
-						page, pass > 2);
+						page, pass > 2, offlining);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -801,7 +815,8 @@ static int do_move_page_to_node_array(st
 		if (!page)
 			goto set_status;
 
-		if (PageReserved(page))		/* Check for zero page */
+		/* Use PageReserved to check for zero page */
+		if (PageReserved(page) || PageKsm(page))
 			goto put_and_set;
 
 		pp->page = page;
@@ -838,7 +853,7 @@ set_status:
 	err = 0;
 	if (!list_empty(&pagelist))
 		err = migrate_pages(&pagelist, new_page_node,
-				(unsigned long)pm);
+				(unsigned long)pm, 0);
 
 	up_read(&mm->mmap_sem);
 	return err;
@@ -959,7 +974,7 @@ static void do_pages_stat_array(struct m
 
 		err = -ENOENT;
 		/* Use PageReserved to check for zero page */
-		if (!page || PageReserved(page))
+		if (!page || PageReserved(page) || PageKsm(page))
 			goto set_status;
 
 		err = page_to_nid(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
