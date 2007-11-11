Date: Sun, 11 Nov 2007 09:52:21 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 6/6] mm: speculative refcount debug
Message-ID: <20071111085221.GI19816@wotan.suse.de>
References: <20071111084556.GC19816@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071111084556.GC19816@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add some debugging for lockless pagecache.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -236,9 +236,30 @@ static inline struct page *compound_head
 	return page;
 }
 
+#ifdef CONFIG_DEBUG_VM
+extern int ll_counter;
+#endif
+
 static inline int page_count(struct page *page)
 {
+#ifndef CONFIG_DEBUG_VM
 	return atomic_read(&compound_head(page)->_count);
+#else
+
+	int count;
+	/*
+	 * debug testing for lockless pagecache. add a random value to
+	 * page_count every now and then, to simulate speculative references
+	 * to it.
+	 */
+	count = atomic_read(&compound_head(page)->_count);
+	if (count) {
+		ll_counter++;
+		if (ll_counter % 5 == 0 || ll_counter % 7 == 0)
+			count += ll_counter % 11;
+	}
+	return count;
+#endif
 }
 
 static inline void get_page(struct page *page)
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -173,6 +173,8 @@ static void set_pageblock_migratetype(st
 }
 
 #ifdef CONFIG_DEBUG_VM
+int ll_counter; /* used in include/linux/mm.h, for lockless pagecache */
+EXPORT_SYMBOL(ll_counter);
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
 	int ret = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
