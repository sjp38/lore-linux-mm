Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C76B6B03AC
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:35:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d127so8645154wmf.15
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:35:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o23si19538697wra.77.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 33/35] mm: Remove nr_entries argument from pagevec_lookup_entries{,_range}()
Date: Thu,  1 Jun 2017 11:32:43 +0200
Message-Id: <20170601093245.29238-34-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

All users pass PAGEVEC_SIZE as the number of entries now. Remove the
argument.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/pagevec.h | 7 +++----
 mm/shmem.c              | 4 ++--
 mm/swap.c               | 6 ++----
 mm/truncate.c           | 8 ++++----
 4 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 93308689d6a7..f765fc5eca31 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -25,14 +25,13 @@ void __pagevec_lru_add(struct pagevec *pvec);
 unsigned pagevec_lookup_entries_range(struct pagevec *pvec,
 				struct address_space *mapping,
 				pgoff_t *start, pgoff_t end,
-				unsigned nr_entries, pgoff_t *indices);
+				pgoff_t *indices);
 static inline unsigned pagevec_lookup_entries(struct pagevec *pvec,
 				struct address_space *mapping,
-				pgoff_t *start, unsigned nr_entries,
-				pgoff_t *indices)
+				pgoff_t *start, pgoff_t *indices)
 {
 	return pagevec_lookup_entries_range(pvec, mapping, start, (pgoff_t)-1,
-					    nr_entries, indices);
+					    indices);
 }
 void pagevec_remove_exceptionals(struct pagevec *pvec);
 unsigned pagevec_lookup_range(struct pagevec *pvec,
diff --git a/mm/shmem.c b/mm/shmem.c
index e5ea044aae24..dd8144230ecf 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -769,7 +769,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	index = start;
 	while (index < end) {
 		if (!pagevec_lookup_entries_range(&pvec, mapping, &index,
-				end - 1, PAGEVEC_SIZE, indices))
+				end - 1, indices))
 			break;
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
@@ -857,7 +857,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		cond_resched();
 
 		if (!pagevec_lookup_entries_range(&pvec, mapping, &index,
-				end - 1, PAGEVEC_SIZE, indices)) {
+				end - 1, indices)) {
 			/* If all gone or hole-punch or unfalloc, we're done */
 			if (lookup_start == start || end != -1)
 				break;
diff --git a/mm/swap.c b/mm/swap.c
index 88c7eb4e97db..1640bbb34e59 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -894,7 +894,6 @@ EXPORT_SYMBOL(__pagevec_lru_add);
  * @mapping:	The address_space to search
  * @start:	The starting entry index
  * @end:	The final entry index (inclusive)
- * @nr_entries:	The maximum number of entries
  * @indices:	The cache indices corresponding to the entries in @pvec
  *
  * pagevec_lookup_entries() will search for and return a group of up
@@ -911,10 +910,9 @@ EXPORT_SYMBOL(__pagevec_lru_add);
  */
 unsigned pagevec_lookup_entries_range(struct pagevec *pvec,
 				struct address_space *mapping,
-				pgoff_t *start, pgoff_t end, unsigned nr_pages,
-				pgoff_t *indices)
+				pgoff_t *start, pgoff_t end, pgoff_t *indices)
 {
-	pvec->nr = find_get_entries_range(mapping, start, end, nr_pages,
+	pvec->nr = find_get_entries_range(mapping, start, end, PAGEVEC_SIZE,
 					  pvec->pages, indices);
 	return pagevec_count(pvec);
 }
diff --git a/mm/truncate.c b/mm/truncate.c
index 31d5c5f3da30..d35531d83cb3 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -290,7 +290,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index < end && pagevec_lookup_entries_range(&pvec, mapping,
-			&index, end - 1, PAGEVEC_SIZE, indices)) {
+			&index, end - 1, indices)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -354,7 +354,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 		cond_resched();
 		if (!pagevec_lookup_entries_range(&pvec, mapping, &index,
-					end - 1, PAGEVEC_SIZE, indices)) {
+					end - 1, indices)) {
 			/* If all gone from start onwards, we're done */
 			if (lookup_start == start)
 				break;
@@ -476,7 +476,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	while (index <= end && pagevec_lookup_entries_range(&pvec, mapping,
-			&index, end, PAGEVEC_SIZE, indices)) {
+			&index, end, indices)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
@@ -601,7 +601,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index <= end && pagevec_lookup_entries_range(&pvec, mapping,
-			&index, end, PAGEVEC_SIZE, indices)) {
+			&index, end, indices)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
