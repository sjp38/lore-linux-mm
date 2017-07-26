Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 466436B03A1
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:47:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r7so31535626wrb.0
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:47:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3si12083049wra.364.2017.07.26.04.47.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:47:26 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 07/10] hugetlbfs: Use pagevec_lookup_range() in remove_inode_hugepages()
Date: Wed, 26 Jul 2017 13:47:01 +0200
Message-Id: <20170726114704.7626-8-jack@suse.cz>
In-Reply-To: <20170726114704.7626-1-jack@suse.cz>
References: <20170726114704.7626-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Nadia Yvette Chambers <nyc@holomorphy.com>

We want only pages from given range in remove_inode_hugepages(). Use
pagevec_lookup_range() instead of pagevec_lookup().

CC: Nadia Yvette Chambers <nyc@holomorphy.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/hugetlbfs/inode.c | 18 ++----------------
 1 file changed, 2 insertions(+), 16 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index b9678ce91e25..8931236f3ef4 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -403,7 +403,6 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 	struct pagevec pvec;
 	pgoff_t next, index;
 	int i, freed = 0;
-	long lookup_nr = PAGEVEC_SIZE;
 	bool truncate_op = (lend == LLONG_MAX);
 
 	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
@@ -412,30 +411,17 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 	next = start;
 	while (next < end) {
 		/*
-		 * Don't grab more pages than the number left in the range.
-		 */
-		if (end - next < lookup_nr)
-			lookup_nr = end - next;
-
-		/*
 		 * When no more pages are found, we are done.
 		 */
-		if (!pagevec_lookup(&pvec, mapping, &next, lookup_nr))
+		if (!pagevec_lookup_range(&pvec, mapping, &next, end - 1,
+					  PAGEVEC_SIZE))
 			break;
 
 		for (i = 0; i < pagevec_count(&pvec); ++i) {
 			struct page *page = pvec.pages[i];
 			u32 hash;
 
-			/*
-			 * The page (index) could be beyond end.  This is
-			 * only possible in the punch hole case as end is
-			 * max page offset in the truncate case.
-			 */
 			index = page->index;
-			if (index >= end)
-				break;
-
 			hash = hugetlb_fault_mutex_hash(h, current->mm,
 							&pseudo_vma,
 							mapping, index, 0);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
