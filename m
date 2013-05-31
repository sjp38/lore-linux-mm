Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 39AD36B0037
	for <linux-mm@kvack.org>; Fri, 31 May 2013 14:39:04 -0400 (EDT)
Subject: [v4][PATCH 3/6] mm: vmscan: break up __remove_mapping()
From: Dave Hansen <dave@sr71.net>
Date: Fri, 31 May 2013 11:38:59 -0700
References: <20130531183855.44DDF928@viggo.jf.intel.com>
In-Reply-To: <20130531183855.44DDF928@viggo.jf.intel.com>
Message-Id: <20130531183859.F179225E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

Our goal here is to eventually reduce the number of repetitive
acquire/release operations on mapping->tree_lock.

Logically, this patch has two steps:
1. rename __remove_mapping() to lock_remove_mapping() since
   "__" usually means "this us the unlocked version.
2. Recreate __remove_mapping() to _be_ the lock_remove_mapping()
   but without the locks.

I think this actually makes the code flow around the locking
_much_ more straighforward since the locking just becomes:

	spin_lock_irq(&mapping->tree_lock);
	ret = __remove_mapping(mapping, page);
	spin_unlock_irq(&mapping->tree_lock);

One non-obvious part of this patch: the

	freepage = mapping->a_ops->freepage;

used to happen under the mapping->tree_lock, but this patch
moves it to outside of the lock.  All of the other
a_ops->freepage users do it outside the lock, and we only
assign it when we create inodes, so that makes it safe.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Mel Gorman <mgorman@suse.de>

---

 linux.git-davehans/mm/vmscan.c |   43 ++++++++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 17 deletions(-)

diff -puN mm/vmscan.c~make-remove-mapping-without-locks mm/vmscan.c
--- linux.git/mm/vmscan.c~make-remove-mapping-without-locks	2013-05-30 16:07:51.210104924 -0700
+++ linux.git-davehans/mm/vmscan.c	2013-05-30 16:07:51.214105100 -0700
@@ -450,12 +450,12 @@ static pageout_t pageout(struct page *pa
  * Same as remove_mapping, but if the page is removed from the mapping, it
  * gets returned with a refcount of 0.
  */
-static int __remove_mapping(struct address_space *mapping, struct page *page)
+static int __remove_mapping(struct address_space *mapping,
+			    struct page *page)
 {
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	spin_lock_irq(&mapping->tree_lock);
 	/*
 	 * The non racy check for a busy page.
 	 *
@@ -482,35 +482,44 @@ static int __remove_mapping(struct addre
 	 * and thus under tree_lock, then this ordering is not required.
 	 */
 	if (!page_freeze_refs(page, 2))
-		goto cannot_free;
+		return 0;
 	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
 	if (unlikely(PageDirty(page))) {
 		page_unfreeze_refs(page, 2);
-		goto cannot_free;
+		return 0;
 	}
 
 	if (PageSwapCache(page)) {
 		__delete_from_swap_cache(page);
-		spin_unlock_irq(&mapping->tree_lock);
+	} else {
+		__delete_from_page_cache(page);
+	}
+	return 1;
+}
+
+static int lock_remove_mapping(struct address_space *mapping, struct page *page)
+{
+	int ret;
+	BUG_ON(!PageLocked(page));
+
+	spin_lock_irq(&mapping->tree_lock);
+	ret = __remove_mapping(mapping, page);
+	spin_unlock_irq(&mapping->tree_lock);
+
+	/* unable to free */
+	if (!ret)
+		return 0;
+
+	if (PageSwapCache(page)) {
 		swapcache_free_page_entry(page);
 	} else {
 		void (*freepage)(struct page *);
-
 		freepage = mapping->a_ops->freepage;
-
-		__delete_from_page_cache(page);
-		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_cache_page(page);
-
 		if (freepage != NULL)
 			freepage(page);
 	}
-
-	return 1;
-
-cannot_free:
-	spin_unlock_irq(&mapping->tree_lock);
-	return 0;
+	return ret;
 }
 
 /*
@@ -521,7 +530,7 @@ cannot_free:
  */
 int remove_mapping(struct address_space *mapping, struct page *page)
 {
-	if (__remove_mapping(mapping, page)) {
+	if (lock_remove_mapping(mapping, page)) {
 		/*
 		 * Unfreezing the refcount with 1 rather than 2 effectively
 		 * drops the pagecache ref for us without requiring another
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
