Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5973C6B03BA
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:35:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 8so8688231wms.11
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:35:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o91si12639813wrb.89.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 32/35] mm: Convert truncate code to pagevec_lookup_entries_range()
Date: Thu,  1 Jun 2017 11:32:42 +0200
Message-Id: <20170601093245.29238-33-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

All radix tree scanning code in truncate paths is interested only in
pages from given range. Convert them to pagevec_lookup_entries_range().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/truncate.c | 52 +++++++++-------------------------------------------
 1 file changed, 9 insertions(+), 43 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 9efc82f18b74..31d5c5f3da30 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -289,16 +289,11 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index < end && pagevec_lookup_entries(&pvec, mapping, &index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE),
-			indices)) {
+	while (index < end && pagevec_lookup_entries_range(&pvec, mapping,
+			&index, end - 1, PAGEVEC_SIZE, indices)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			/* We rely upon deletion not changing page->index */
-			if (indices[i] >= end)
-				break;
-
 			if (radix_tree_exceptional_entry(page)) {
 				truncate_exceptional_entry(mapping, indices[i],
 							   page);
@@ -352,20 +347,14 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			put_page(page);
 		}
 	}
-	/*
-	 * If the truncation happened within a single page no pages
-	 * will be released, just zeroed, so we can bail out now.
-	 */
-	if (start >= end)
-		goto out;
 
 	index = start;
-	for ( ; ; ) {
+	while (index < end) {
 		pgoff_t lookup_start = index;
 
 		cond_resched();
-		if (!pagevec_lookup_entries(&pvec, mapping, &index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE), indices)) {
+		if (!pagevec_lookup_entries_range(&pvec, mapping, &index,
+					end - 1, PAGEVEC_SIZE, indices)) {
 			/* If all gone from start onwards, we're done */
 			if (lookup_start == start)
 				break;
@@ -373,22 +362,9 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			index = start;
 			continue;
 		}
-		if (lookup_start == start && indices[0] >= end) {
-			/* All gone out of hole to be punched, we're done */
-			pagevec_remove_exceptionals(&pvec);
-			pagevec_release(&pvec);
-			break;
-		}
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			/* We rely upon deletion not changing page->index */
-			if (indices[i] >= end) {
-				/* Restart punch to make sure all gone */
-				index = start;
-				break;
-			}
-
 			if (radix_tree_exceptional_entry(page)) {
 				truncate_exceptional_entry(mapping, indices[i],
 							   page);
@@ -499,16 +475,11 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	int i;
 
 	pagevec_init(&pvec, 0);
-	while (index <= end && pagevec_lookup_entries(&pvec, mapping, &index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
-			indices)) {
+	while (index <= end && pagevec_lookup_entries_range(&pvec, mapping,
+			&index, end, PAGEVEC_SIZE, indices)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			/* We rely upon deletion not changing page->index */
-			if (indices[i] > end)
-				break;
-
 			if (radix_tree_exceptional_entry(page)) {
 				invalidate_exceptional_entry(mapping,
 							     indices[i], page);
@@ -629,16 +600,11 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index <= end && pagevec_lookup_entries(&pvec, mapping, &index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
-			indices)) {
+	while (index <= end && pagevec_lookup_entries_range(&pvec, mapping,
+			&index, end, PAGEVEC_SIZE, indices)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			/* We rely upon deletion not changing page->index */
-			if (indices[i] > end)
-				break;
-
 			if (radix_tree_exceptional_entry(page)) {
 				if (!invalidate_exceptional_entry2(mapping,
 							indices[i], page))
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
