Message-Id: <20070128132435.804546000@programming.kicks-ass.net>
References: <20070128131343.628722000@programming.kicks-ass.net>
Date: Sun, 28 Jan 2007 14:13:50 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 07/14] mm: speculative find_get_pages_tag
Content-Disposition: inline; filename=mm-lockless-find_get_pages_tag.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

implement the speculative find_get_pages_tag.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/filemap.c |   42 +++++++++++++++++++++++++++++++++---------
 1 file changed, 33 insertions(+), 9 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-01-22 20:11:07.000000000 +0100
+++ linux-2.6/mm/filemap.c	2007-01-22 20:11:09.000000000 +0100
@@ -849,16 +849,40 @@ unsigned find_get_pages_tag(struct addre
 {
 	unsigned int i;
 	unsigned int ret;
+	unsigned int nr_found;
 
-	read_lock_irq(&mapping->tree_lock);
-	/* TODO: implement lookup_tag_slot and make this lockless */
-	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
-				(void **)pages, *index, nr_pages, tag);
-	for (i = 0; i < ret; i++)
-		page_cache_get(pages[i]);
-	if (ret)
-		*index = pages[ret - 1]->index + 1;
-	read_unlock_irq(&mapping->tree_lock);
+	rcu_read_lock();
+restart:
+	nr_found = radix_tree_gang_lookup_tag_slot(&mapping->page_tree,
+			(void ***)pages, *index, nr_pages, tag);
+
+	ret = 0;
+	for (i = 0; i < nr_found; i++) {
+		struct page *page;
+repeat:
+		page = radix_tree_deref_slot((void**)pages[i]);
+		if (unlikely(!page))
+			continue;
+		/*
+		 * this can only trigger if nr_found == 1, making livelocks
+		 * a non issue.
+		 */
+		if (unlikely(page == RADIX_TREE_RETRY))
+			goto restart;
+
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/* Has the page moved? */
+		if (unlikely(page != *((void **)pages[i]))) {
+			page_cache_release(page);
+			goto repeat;
+		}
+
+		pages[ret] = page;
+		ret++;
+	}
+	rcu_read_unlock();
 	return ret;
 }
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
