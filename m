Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 230AD440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 11:42:50 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p75so2717264wmg.2
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 08:42:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i34si3966022edi.396.2017.11.08.08.42.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 08:42:48 -0800 (PST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm, truncate: remove all exceptional entries from pagevec under one lock -fix
Date: Wed,  8 Nov 2017 17:42:26 +0100
Message-Id: <20171108164226.26788-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Patch "mm, truncate: remove all exceptional entries from pagevec" had a
problem that truncate_exceptional_pvec_entries() didn't remove exceptional
entries that were beyond end of truncated range from the pagevec. As a result
pagevec_release() oopsed trying to treat exceptional entry as a page pointer.
This can be reproduced by running xfstests generic/269 in a loop while
applying memory pressure until the bug triggers.

Rip out fragile passing of index of the first exceptional entry in the
pagevec and scan the full pagevec instead. Additional pagevec pass doesn't
have measurable overhead and the code is more robust that way.

This is a fix to the mmotm patch
mm-truncate-remove-all-exceptional-entries-from-pagevec-under-one-lock.patch

Signed-off-by: Jan Kara <jack@suse.cz>

diff -rupX /crypted/home/jack/.kerndiffexclude linux-4.12-users_jack_SLE15_for-next/mm/truncate.c linux-4.12-users_jack_SLE15_for-next-truncate_exceptional_fix/mm/truncate.c
--- linux-4.12-users_jack_SLE15_for-next/mm/truncate.c	2017-11-01 17:46:40.338638935 +0100
+++ linux-4.12-users_jack_SLE15_for-next-truncate_exceptional_fix/mm/truncate.c	2017-11-08 12:10:40.010515314 +0100
@@ -59,24 +59,29 @@ static void clear_shadow_entry(struct ad
  * exceptional entries similar to what pagevec_remove_exceptionals does.
  */
 static void truncate_exceptional_pvec_entries(struct address_space *mapping,
-				struct pagevec *pvec, pgoff_t *indices, int ei)
+				struct pagevec *pvec, pgoff_t *indices,
+				pgoff_t end)
 {
 	int i, j;
-	bool dax;
-
-	/* Return immediately if caller indicates there are no entries */
-	if (ei == PAGEVEC_SIZE)
-		return;
+	bool dax, lock;
 
 	/* Handled by shmem itself */
 	if (shmem_mapping(mapping))
 		return;
 
+	for (j = 0; j < pagevec_count(pvec); j++)
+		if (radix_tree_exceptional_entry(pvec->pages[j]))
+			break;
+
+	if (j == pagevec_count(pvec))
+		return;
+
 	dax = dax_mapping(mapping);
-	if (!dax)
+	lock = !dax && indices[j] < end;
+	if (lock)
 		spin_lock_irq(&mapping->tree_lock);
 
-	for (i = ei, j = ei; i < pagevec_count(pvec); i++) {
+	for (i = j; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
 		pgoff_t index = indices[i];
 
@@ -85,6 +90,9 @@ static void truncate_exceptional_pvec_en
 			continue;
 		}
 
+		if (index >= end)
+			continue;
+
 		if (unlikely(dax)) {
 			dax_delete_mapping_entry(mapping, index);
 			continue;
@@ -93,7 +101,7 @@ static void truncate_exceptional_pvec_en
 		__clear_shadow_entry(mapping, index, page);
 	}
 
-	if (!dax)
+	if (lock)
 		spin_unlock_irq(&mapping->tree_lock);
 	pvec->nr = j;
 }
@@ -333,7 +341,6 @@ void truncate_inode_pages_range(struct a
 		 * in a new pagevec.
 		 */
 		struct pagevec locked_pvec;
-		int ei = PAGEVEC_SIZE;
 
 		pagevec_init(&locked_pvec);
 		for (i = 0; i < pagevec_count(&pvec); i++) {
@@ -344,11 +351,8 @@ void truncate_inode_pages_range(struct a
 			if (index >= end)
 				break;
 
-			if (radix_tree_exceptional_entry(page)) {
-				if (ei == PAGEVEC_SIZE)
-					ei = i;
+			if (radix_tree_exceptional_entry(page))
 				continue;
-			}
 
 			if (!trylock_page(page))
 				continue;
@@ -368,7 +372,7 @@ void truncate_inode_pages_range(struct a
 		delete_from_page_cache_batch(mapping, &locked_pvec);
 		for (i = 0; i < pagevec_count(&locked_pvec); i++)
 			unlock_page(locked_pvec.pages[i]);
-		truncate_exceptional_pvec_entries(mapping, &pvec, indices, ei);
+		truncate_exceptional_pvec_entries(mapping, &pvec, indices, end);
 		pagevec_release(&pvec);
 		cond_resched();
 		index++;
@@ -414,8 +418,6 @@ void truncate_inode_pages_range(struct a
 
 	index = start;
 	for ( ; ; ) {
-		int ei = PAGEVEC_SIZE;
-
 		cond_resched();
 		if (!pagevec_lookup_entries(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE), indices)) {
@@ -444,11 +446,8 @@ void truncate_inode_pages_range(struct a
 				break;
 			}
 
-			if (radix_tree_exceptional_entry(page)) {
-				if (ei == PAGEVEC_SIZE)
-					ei = i;
+			if (radix_tree_exceptional_entry(page))
 				continue;
-			}
 
 			lock_page(page);
 			WARN_ON(page_to_index(page) != index);
@@ -456,7 +455,7 @@ void truncate_inode_pages_range(struct a
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
-		truncate_exceptional_pvec_entries(mapping, &pvec, indices, ei);
+		truncate_exceptional_pvec_entries(mapping, &pvec, indices, end);
 		pagevec_release(&pvec);
 		index++;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
