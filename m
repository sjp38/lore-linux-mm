Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAB36B02F4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d127so8635339wmf.15
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q22si17870798wrc.256.2017.06.01.02.33.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:15 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 09/35] ext4: Use pagevec_lookup_range() in ext4_find_unwritten_pgoff()
Date: Thu,  1 Jun 2017 11:32:19 +0200
Message-Id: <20170601093245.29238-10-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

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
index ddca17c7875a..6821070a388b 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -478,12 +478,11 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 
 	pagevec_init(&pvec, 0);
 	do {
-		int i, num;
+		int i;
 		unsigned long nr_pages;
 
-		num = min_t(pgoff_t, end - index, PAGEVEC_SIZE);
-		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, &index,
-					  (pgoff_t)num);
+		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping,
+					&index, end, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 
@@ -502,9 +501,6 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 				goto out;
 			}
 
-			if (page->index > end)
-				goto out;
-
 			lock_page(page);
 
 			if (unlikely(page->mapping != inode->i_mapping)) {
@@ -544,12 +540,10 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
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
