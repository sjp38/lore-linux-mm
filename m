Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 66D066B00D7
	for <linux-mm@kvack.org>; Tue,  7 May 2013 17:20:02 -0400 (EDT)
Subject: [RFC][PATCH 5/7] create __remove_mapping_batch()
From: Dave Hansen <dave@sr71.net>
Date: Tue, 07 May 2013 14:20:01 -0700
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
In-Reply-To: <20130507211954.9815F9D1@viggo.jf.intel.com>
Message-Id: <20130507212001.49F5E197@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

__remove_mapping_batch() does logically the same thing as
__remove_mapping().

We batch like this so that several pages can be freed with a
single mapping->tree_lock acquisition/release pair.  This reduces
the number of atomic operations and ensures that we do not bounce
cachelines around.

It has shown some substantial performance benefits on
microbenchmarks.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/mm/vmscan.c |   50 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff -puN mm/vmscan.c~create-remove_mapping_batch mm/vmscan.c
--- linux.git/mm/vmscan.c~create-remove_mapping_batch	2013-05-07 14:00:01.432361260 -0700
+++ linux.git-davehans/mm/vmscan.c	2013-05-07 14:19:32.341148892 -0700
@@ -555,6 +555,56 @@ int remove_mapping(struct address_space
 	return 0;
 }
 
+/*
+ * pages come in here (via remove_list) locked and leave unlocked
+ * (on either ret_pages or free_pages)
+ *
+ * We do this batching so that we free batches of pages with a
+ * single mapping->tree_lock acquisition/release.  This optimization
+ * only makes sense when the pages on remove_list all share a
+ * page->mapping.  If this is violated you will BUG_ON().
+ */
+static int __remove_mapping_batch(struct list_head *remove_list,
+				  struct list_head *ret_pages,
+				  struct list_head *free_pages)
+{
+	int nr_reclaimed = 0;
+	struct address_space *mapping;
+	struct page *page;
+	LIST_HEAD(need_free_mapping);
+
+	if (list_empty(remove_list))
+		return 0;
+
+	mapping = lru_to_page(remove_list)->mapping;
+	spin_lock_irq(&mapping->tree_lock);
+	while (!list_empty(remove_list)) {
+		int freed;
+		page = lru_to_page(remove_list);
+		BUG_ON(!PageLocked(page));
+		BUG_ON(page->mapping != mapping);
+		list_del(&page->lru);
+
+		freed = __remove_mapping_nolock(mapping, page);
+		if (freed) {
+			list_add(&page->lru, &need_free_mapping);
+		} else {
+			unlock_page(page);
+			list_add(&page->lru, ret_pages);
+		}
+	}
+	spin_unlock_irq(&mapping->tree_lock);
+
+	while (!list_empty(&need_free_mapping)) {
+		page = lru_to_page(&need_free_mapping);
+		list_move(&page->list, free_pages);
+		free_mapping_page(mapping, page);
+		unlock_page(page);
+		nr_reclaimed++;
+	}
+	return nr_reclaimed;
+}
+
 /**
  * putback_lru_page - put previously isolated page onto appropriate LRU list
  * @page: page to be put back to appropriate lru list
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
