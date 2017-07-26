Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 458906B02FD
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:47:28 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z195so267819wmz.8
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:47:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c74si1312585wme.10.2017.07.26.04.47.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:47:27 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 05/10] ext4: Use pagevec_lookup_range() in ext4_find_unwritten_pgoff()
Date: Wed, 26 Jul 2017 13:46:59 +0200
Message-Id: <20170726114704.7626-6-jack@suse.cz>
In-Reply-To: <20170726114704.7626-1-jack@suse.cz>
References: <20170726114704.7626-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>

Use pagevec_lookup_range() in ext4_find_unwritten_pgoff() since we are
interested only in pages in the given range. Simplify the logic as a
result of not getting pages out of range and index getting automatically
advanced.

CC: linux-ext4@vger.kernel.org
CC: "Theodore Ts'o" <tytso@mit.edu>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/file.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index ab09cb6fcce3..ac39a6a1ea5d 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -494,12 +494,11 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 
 	pagevec_init(&pvec, 0);
 	do {
-		int i, num;
+		int i;
 		unsigned long nr_pages;
 
-		num = min_t(pgoff_t, end - index, PAGEVEC_SIZE - 1) + 1;
-		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, &index,
-					  (pgoff_t)num);
+		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping,
+					&index, end, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 
@@ -518,9 +517,6 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 				goto out;
 			}
 
-			if (page->index > end)
-				goto out;
-
 			lock_page(page);
 
 			if (unlikely(page->mapping != inode->i_mapping)) {
@@ -560,12 +556,10 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 			unlock_page(page);
 		}
 
-		/* The no. of pages is less than our desired, we are done. */
-		if (nr_pages < num)
-			break;
 		pagevec_release(&pvec);
 	} while (index <= end);
 
+	/* There are no pages upto endoff - that would be a hole in there. */
 	if (whence == SEEK_HOLE && lastoff < endoff) {
 		found = 1;
 		*offset = lastoff;
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
