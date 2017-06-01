Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6956B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r203so8693007wmb.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v49si18517323wrb.306.2017.06.01.02.33.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:14 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 02/35] ext4: Fix SEEK_HOLE
Date: Thu,  1 Jun 2017 11:32:12 +0200
Message-Id: <20170601093245.29238-3-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>, stable@vger.kernel.org, Zheng Liu <wenqing.lz@taobao.com>

Currently, SEEK_HOLE implementation in ext4 may both return that there's
a hole at some offset although that offset already has data and skip
some holes during a search for the next hole. The first problem is
demostrated by:

xfs_io -c "falloc 0 256k" -c "pwrite 0 56k" -c "seek -h 0" file
wrote 57344/57344 bytes at offset 0
56 KiB, 14 ops; 0.0000 sec (2.054 GiB/sec and 538461.5385 ops/sec)
Whence	Result
HOLE	0

Where we can see that SEEK_HOLE wrongly returned offset 0 as containing
a hole although we have written data there. The second problem can be
demonstrated by:

xfs_io -c "falloc 0 256k" -c "pwrite 0 56k" -c "pwrite 128k 8k"
       -c "seek -h 0" file

wrote 57344/57344 bytes at offset 0
56 KiB, 14 ops; 0.0000 sec (1.978 GiB/sec and 518518.5185 ops/sec)
wrote 8192/8192 bytes at offset 131072
8 KiB, 2 ops; 0.0000 sec (2 GiB/sec and 500000.0000 ops/sec)
Whence	Result
HOLE	139264

Where we can see that hole at offsets 56k..128k has been ignored by the
SEEK_HOLE call.

The underlying problem is in the ext4_find_unwritten_pgoff() which is
just buggy. In some cases it fails to update returned offset when it
finds a hole (when no pages are found or when the first found page has
higher index than expected), in some cases conditions for detecting hole
are just missing (we fail to detect a situation where indices of
returned pages are not contiguous).

Fix ext4_find_unwritten_pgoff() to properly detect non-contiguous page
indices and also handle all cases where we got less pages then expected
in one place and handle it properly there.

CC: stable@vger.kernel.org
Fixes: c8c0df241cc2719b1262e627f999638411934f60
CC: Zheng Liu <wenqing.lz@taobao.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/file.c | 50 ++++++++++++++------------------------------------
 1 file changed, 14 insertions(+), 36 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 831fd6beebf0..bbea2dccd584 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -484,47 +484,27 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 		num = min_t(pgoff_t, end - index, PAGEVEC_SIZE);
 		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, index,
 					  (pgoff_t)num);
-		if (nr_pages == 0) {
-			if (whence == SEEK_DATA)
-				break;
-
-			BUG_ON(whence != SEEK_HOLE);
-			/*
-			 * If this is the first time to go into the loop and
-			 * offset is not beyond the end offset, it will be a
-			 * hole at this offset
-			 */
-			if (lastoff == startoff || lastoff < endoff)
-				found = 1;
-			break;
-		}
-
-		/*
-		 * If this is the first time to go into the loop and
-		 * offset is smaller than the first page offset, it will be a
-		 * hole at this offset.
-		 */
-		if (lastoff == startoff && whence == SEEK_HOLE &&
-		    lastoff < page_offset(pvec.pages[0])) {
-			found = 1;
+		if (nr_pages == 0)
 			break;
-		}
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 			struct buffer_head *bh, *head;
 
 			/*
-			 * If the current offset is not beyond the end of given
-			 * range, it will be a hole.
+			 * If current offset is smaller than the page offset,
+			 * there is a hole at this offset.
 			 */
-			if (lastoff < endoff && whence == SEEK_HOLE &&
-			    page->index > end) {
+			if (whence == SEEK_HOLE && lastoff < endoff &&
+			    lastoff < page_offset(pvec.pages[i])) {
 				found = 1;
 				*offset = lastoff;
 				goto out;
 			}
 
+			if (page->index > end)
+				goto out;
+
 			lock_page(page);
 
 			if (unlikely(page->mapping != inode->i_mapping)) {
@@ -564,20 +544,18 @@ static int ext4_find_unwritten_pgoff(struct inode *inode,
 			unlock_page(page);
 		}
 
-		/*
-		 * The no. of pages is less than our desired, that would be a
-		 * hole in there.
-		 */
-		if (nr_pages < num && whence == SEEK_HOLE) {
-			found = 1;
-			*offset = lastoff;
+		/* The no. of pages is less than our desired, we are done. */
+		if (nr_pages < num)
 			break;
-		}
 
 		index = pvec.pages[i - 1]->index + 1;
 		pagevec_release(&pvec);
 	} while (index <= end);
 
+	if (whence == SEEK_HOLE && lastoff < endoff) {
+		found = 1;
+		*offset = lastoff;
+	}
 out:
 	pagevec_release(&pvec);
 	return found;
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
