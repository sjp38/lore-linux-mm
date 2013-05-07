Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 326D66B00D9
	for <linux-mm@kvack.org>; Tue,  7 May 2013 17:20:04 -0400 (EDT)
Subject: [RFC][PATCH 3/7] break up __remove_mapping()
From: Dave Hansen <dave@sr71.net>
Date: Tue, 07 May 2013 14:19:58 -0700
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
In-Reply-To: <20130507211954.9815F9D1@viggo.jf.intel.com>
Message-Id: <20130507211958.756AC1A6@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

Our goal here is to eventually reduce the number of repetitive
acquire/release operations on mapping->tree_lock.

To start out, we make a version of __remove_mapping() called
__remove_mapping_nolock().  This actually makes the locking
_much_ more straighforward.

One non-obvious part of this patch: the

	freepage = mapping->a_ops->freepage;

used to happen under the mapping->tree_lock, but this patch
moves it to outside of the lock.  All of the other
a_ops->freepage users do it outside the lock, and we only
assign it when we create inodes, so that makes it safe.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/mm/vmscan.c |   41 +++++++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 16 deletions(-)

diff -puN mm/vmscan.c~make-remove-mapping-without-locks mm/vmscan.c
--- linux.git/mm/vmscan.c~make-remove-mapping-without-locks	2013-05-07 13:48:14.271069843 -0700
+++ linux.git-davehans/mm/vmscan.c	2013-05-07 13:48:14.275070019 -0700
@@ -450,12 +450,12 @@ static pageout_t pageout(struct page *pa
  * Same as remove_mapping, but if the page is removed from the mapping, it
  * gets returned with a refcount of 0.
  */
-static int __remove_mapping(struct address_space *mapping, struct page *page)
+static int __remove_mapping_nolock(struct address_space *mapping,
+				   struct page *page)
 {
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	spin_lock_irq(&mapping->tree_lock);
 	/*
 	 * The non racy check for a busy page.
 	 *
@@ -482,37 +482,46 @@ static int __remove_mapping(struct addre
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
+static int __remove_mapping(struct address_space *mapping, struct page *page)
+{
+	int ret;
+	BUG_ON(!PageLocked(page));
+
+	spin_lock_irq(&mapping->tree_lock);
+	ret = __remove_mapping_nolock(mapping, page);
+	spin_unlock_irq(&mapping->tree_lock);
+
+	/* unable to free */
+	if (!ret)
+		return 0;
+
+	if (PageSwapCache(page)) {
 		swapcache_free_page_entry(page);
 		set_page_private(page, 0);
 		ClearPageSwapCache(page);
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
