Message-Id: <20080605094825.530462000@nick.local0.net>
References: <20080605094300.295184000@nick.local0.net>
Date: Thu, 05 Jun 2008 19:43:01 +1000
From: npiggin@suse.de
Subject: [patch 1/7] mm: readahead scan lockless
Content-Disposition: inline; filename=mm-readahead-scan-lockless.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

radix_tree_next_hole is implemented as a series of radix_tree_lookup()s. So
it can be called locklessly, under rcu_read_lock().

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/readahead.c
===================================================================
--- linux-2.6.orig/mm/readahead.c
+++ linux-2.6/mm/readahead.c
@@ -382,9 +382,9 @@ ondemand_readahead(struct address_space 
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
