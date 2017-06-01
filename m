Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 121586B033C
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g15so8664963wmc.8
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y16si2973357wry.133.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 31/35] shmem: Convert to pagevec_lookup_entries_range()
Date: Thu,  1 Jun 2017 11:32:41 +0200
Message-Id: <20170601093245.29238-32-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Convert radix tree scanners to use pagevec_lookup_entries_range() and
find_get_entries_range() since they all want only entries from given
range.

CC: Hugh Dickins <hughd@google.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/shmem.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index f9c4afbdd70c..e5ea044aae24 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -768,16 +768,12 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index < end) {
-		if (!pagevec_lookup_entries(&pvec, mapping, &index,
-				min(end - index, (pgoff_t)PAGEVEC_SIZE),
-				indices))
+		if (!pagevec_lookup_entries_range(&pvec, mapping, &index,
+				end - 1, PAGEVEC_SIZE, indices))
 			break;
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			if (indices[i] >= end)
-				break;
-
 			if (radix_tree_exceptional_entry(page)) {
 				if (unfalloc)
 					continue;
@@ -860,9 +856,8 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 
 		cond_resched();
 
-		if (!pagevec_lookup_entries(&pvec, mapping, &index,
-				min(end - index, (pgoff_t)PAGEVEC_SIZE),
-				indices)) {
+		if (!pagevec_lookup_entries_range(&pvec, mapping, &index,
+				end - 1, PAGEVEC_SIZE, indices)) {
 			/* If all gone or hole-punch or unfalloc, we're done */
 			if (lookup_start == start || end != -1)
 				break;
@@ -873,9 +868,6 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			if (indices[i] >= end)
-				break;
-
 			if (radix_tree_exceptional_entry(page)) {
 				if (unfalloc)
 					continue;
@@ -2494,9 +2486,9 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	pvec.nr = 1;		/* start small: we may be there already */
-	while (!done) {
+	while (!done && index < end) {
 		last = index;
-		pvec.nr = find_get_entries(mapping, &index,
+		pvec.nr = find_get_entries_range(mapping, &index, end - 1,
 					pvec.nr, pvec.pages, indices);
 		if (!pvec.nr) {
 			if (whence == SEEK_DATA)
@@ -2516,8 +2508,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 				if (!PageUptodate(page))
 					page = NULL;
 			}
-			if (last >= end ||
-			    (page && whence == SEEK_DATA) ||
+			if ((page && whence == SEEK_DATA) ||
 			    (!page && whence == SEEK_HOLE)) {
 				done = true;
 				break;
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
