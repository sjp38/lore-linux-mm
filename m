Date: Sun, 11 Nov 2007 09:47:17 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/6] mm: readahead scan lockless
Message-ID: <20071111084717.GD19816@wotan.suse.de>
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

This can actually go upstream now...
--

radix_tree_next_hole is implemented as a series of radix_tree_lookup()s. So
it can be called locklessly, under rcu_read_lock().

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/readahead.c
===================================================================
--- linux-2.6.orig/mm/readahead.c
+++ linux-2.6/mm/readahead.c
@@ -376,9 +376,9 @@ ondemand_readahead(struct address_space 
 	if (hit_readahead_marker) {
 		pgoff_t start;
 
-		read_lock_irq(&mapping->tree_lock);
-		start = radix_tree_next_hole(&mapping->page_tree, offset, max+1);
-		read_unlock_irq(&mapping->tree_lock);
+		rcu_read_lock();
+		start = radix_tree_next_hole(&mapping->page_tree, offset,max+1);
+		rcu_read_unlock();
 
 		if (!start || start - offset > max)
 			return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
