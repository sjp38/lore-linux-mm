Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id EC8EE6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 21:03:30 -0500 (EST)
Received: by mail-da0-f53.google.com with SMTP id x6so430070dac.40
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:03:30 -0800 (PST)
Date: Fri, 25 Jan 2013 18:03:31 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 7/11] ksm: make KSM page migration possible
In-Reply-To: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1301251802050.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

KSM page migration is already supported in the case of memory hotremove,
which takes the ksm_thread_mutex across all its migrations to keep life
simple.

But the new KSM NUMA merge_across_nodes knob introduces a problem, when
it's set to non-default 0: if a KSM page is migrated to a different NUMA
node, how do we migrate its stable node to the right tree?  And what if
that collides with an existing stable node?

So far there's no provision for that, and this patch does not attempt
to deal with it either.  But how will I test a solution, when I don't
know how to hotremove memory?  The best answer is to enable KSM page
migration in all cases now, and test more common cases.  With THP and
compaction added since KSM came in, page migration is now mainstream,
and it's a shame that a KSM page can frustrate freeing a page block.

Without worrying about merge_across_nodes 0 for now, this patch gets
KSM page migration working reliably for default merge_across_nodes 1
(but leave the patch enabling it until near the end of the series).

It's much simpler than I'd originally imagined, and does not require
an additional tier of locking: page migration relies on the page lock,
KSM page reclaim relies on the page lock, the page lock is enough for
KSM page migration too.

Almost all the care has to be in get_ksm_page(): that's the function
which worries about when a stable node is stale and should be freed,
now it also has to worry about the KSM page being migrated.

The only new overhead is an additional put/get/lock/unlock_page when
stable_tree_search() arrives at a matching node: to make sure migration
respects the raised page count, and so does not migrate the page while
we're busy with it here.  That's probably avoidable, either by changing
internal interfaces from using kpage to stable_node, or by moving the
ksm_migrate_page() callsite into a page_freeze_refs() section (even if
not swapcache); but this works well, I've no urge to pull it apart now.

(Descents of the stable tree may pass through nodes whose KSM pages are
under migration: being unlocked, the raised page count does not prevent
that, nor need it: it's safe to memcmp against either old or new page.)

You might worry about mremap, and whether page migration's rmap_walk
to remove migration entries will find all the KSM locations where it
inserted earlier: that should already be handled, by the satisfyingly
heavy hammer of move_vma()'s call to ksm_madvise(,,,MADV_UNMERGEABLE,).

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/ksm.c     |   94 ++++++++++++++++++++++++++++++++++++++-----------
 mm/migrate.c |    5 ++
 2 files changed, 77 insertions(+), 22 deletions(-)

--- mmotm.orig/mm/ksm.c	2013-01-25 14:37:00.768206145 -0800
+++ mmotm/mm/ksm.c	2013-01-25 14:37:03.832206218 -0800
@@ -499,6 +499,7 @@ static void remove_node_from_stable_tree
  * In which case we can trust the content of the page, and it
  * returns the gotten page; but if the page has now been zapped,
  * remove the stale node from the stable tree and return NULL.
+ * But beware, the stable node's page might be being migrated.
  *
  * You would expect the stable_node to hold a reference to the ksm page.
  * But if it increments the page's count, swapping out has to wait for
@@ -509,44 +510,77 @@ static void remove_node_from_stable_tree
  * pointing back to this stable node.  This relies on freeing a PageAnon
  * page to reset its page->mapping to NULL, and relies on no other use of
  * a page to put something that might look like our key in page->mapping.
- *
- * include/linux/pagemap.h page_cache_get_speculative() is a good reference,
- * but this is different - made simpler by ksm_thread_mutex being held, but
- * interesting for assuming that no other use of the struct page could ever
- * put our expected_mapping into page->mapping (or a field of the union which
- * coincides with page->mapping).
- *
- * Note: it is possible that get_ksm_page() will return NULL one moment,
- * then page the next, if the page is in between page_freeze_refs() and
- * page_unfreeze_refs(): this shouldn't be a problem anywhere, the page
  * is on its way to being freed; but it is an anomaly to bear in mind.
  */
 static struct page *get_ksm_page(struct stable_node *stable_node, bool locked)
 {
 	struct page *page;
 	void *expected_mapping;
+	unsigned long kpfn;
 
-	page = pfn_to_page(stable_node->kpfn);
 	expected_mapping = (void *)stable_node +
 				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
-	if (page->mapping != expected_mapping)
-		goto stale;
-	if (!get_page_unless_zero(page))
+again:
+	kpfn = ACCESS_ONCE(stable_node->kpfn);
+	page = pfn_to_page(kpfn);
+
+	/*
+	 * page is computed from kpfn, so on most architectures reading
+	 * page->mapping is naturally ordered after reading node->kpfn,
+	 * but on Alpha we need to be more careful.
+	 */
+	smp_read_barrier_depends();
+	if (ACCESS_ONCE(page->mapping) != expected_mapping)
 		goto stale;
-	if (page->mapping != expected_mapping) {
+
+	/*
+	 * We cannot do anything with the page while its refcount is 0.
+	 * Usually 0 means free, or tail of a higher-order page: in which
+	 * case this node is no longer referenced, and should be freed;
+	 * however, it might mean that the page is under page_freeze_refs().
+	 * The __remove_mapping() case is easy, again the node is now stale;
+	 * but if page is swapcache in migrate_page_move_mapping(), it might
+	 * still be our page, in which case it's essential to keep the node.
+	 */
+	while (!get_page_unless_zero(page)) {
+		/*
+		 * Another check for page->mapping != expected_mapping would
+		 * work here too.  We have chosen the !PageSwapCache test to
+		 * optimize the common case, when the page is or is about to
+		 * be freed: PageSwapCache is cleared (under spin_lock_irq)
+		 * in the freeze_refs section of __remove_mapping(); but Anon
+		 * page->mapping reset to NULL later, in free_pages_prepare().
+		 */
+		if (!PageSwapCache(page))
+			goto stale;
+		cpu_relax();
+	}
+
+	if (ACCESS_ONCE(page->mapping) != expected_mapping) {
 		put_page(page);
 		goto stale;
 	}
+
 	if (locked) {
 		lock_page(page);
-		if (page->mapping != expected_mapping) {
+		if (ACCESS_ONCE(page->mapping) != expected_mapping) {
 			unlock_page(page);
 			put_page(page);
 			goto stale;
 		}
 	}
 	return page;
+
 stale:
+	/*
+	 * We come here from above when page->mapping or !PageSwapCache
+	 * suggests that the node is stale; but it might be under migration.
+	 * We need smp_rmb(), matching the smp_wmb() in ksm_migrate_page(),
+	 * before checking whether node->kpfn has been changed.
+	 */
+	smp_rmb();
+	if (ACCESS_ONCE(stable_node->kpfn) != kpfn)
+		goto again;
 	remove_node_from_stable_tree(stable_node);
 	return NULL;
 }
@@ -1103,15 +1137,25 @@ static struct page *stable_tree_search(s
 			return NULL;
 
 		ret = memcmp_pages(page, tree_page);
+		put_page(tree_page);
 
-		if (ret < 0) {
-			put_page(tree_page);
+		if (ret < 0)
 			node = node->rb_left;
-		} else if (ret > 0) {
-			put_page(tree_page);
+		else if (ret > 0)
 			node = node->rb_right;
-		} else
+		else {
+			/*
+			 * Lock and unlock the stable_node's page (which
+			 * might already have been migrated) so that page
+			 * migration is sure to notice its raised count.
+			 * It would be more elegant to return stable_node
+			 * than kpage, but that involves more changes.
+			 */
+			tree_page = get_ksm_page(stable_node, true);
+			if (tree_page)
+				unlock_page(tree_page);
 			return tree_page;
+		}
 	}
 
 	return NULL;
@@ -1903,6 +1947,14 @@ void ksm_migrate_page(struct page *newpa
 	if (stable_node) {
 		VM_BUG_ON(stable_node->kpfn != page_to_pfn(oldpage));
 		stable_node->kpfn = page_to_pfn(newpage);
+		/*
+		 * newpage->mapping was set in advance; now we need smp_wmb()
+		 * to make sure that the new stable_node->kpfn is visible
+		 * to get_ksm_page() before it can see that oldpage->mapping
+		 * has gone stale (or that PageSwapCache has been cleared).
+		 */
+		smp_wmb();
+		set_page_stable_node(oldpage, NULL);
 	}
 }
 #endif /* CONFIG_MIGRATION */
--- mmotm.orig/mm/migrate.c	2013-01-25 14:27:58.140193249 -0800
+++ mmotm/mm/migrate.c	2013-01-25 14:37:03.832206218 -0800
@@ -464,7 +464,10 @@ void migrate_page_copy(struct page *newp
 
 	mlock_migrate_page(newpage, page);
 	ksm_migrate_page(newpage, page);
-
+	/*
+	 * Please do not reorder this without considering how mm/ksm.c's
+	 * get_ksm_page() depends upon ksm_migrate_page() and PageSwapCache().
+	 */
 	ClearPageSwapCache(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
