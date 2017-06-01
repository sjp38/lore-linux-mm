Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 744FA6B02F3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:34:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a77so8700844wma.12
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:34:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a143si32832132wme.119.2017.06.01.02.33.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:16 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 12/35] xfs: Use pagevec_lookup_range() in xfs_find_get_desired_pgoff()
Date: Thu,  1 Jun 2017 11:32:22 +0200
Message-Id: <20170601093245.29238-13-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

We want only pages from given range in xfs_find_get_desired_pgoff(). Use
pagevec_lookup_range() instead of pagevec_lookup() and remove
unnecessary code. Note that the check for getting less pages than
desired can be removed because index gets updated by
pagevec_lookup_range().

CC: Darrick J. Wong <darrick.wong@oracle.com>
CC: linux-xfs@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/xfs/xfs_file.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 487342078fc7..f9343dac7ff9 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1045,13 +1045,11 @@ xfs_find_get_desired_pgoff(
 	endoff = XFS_FSB_TO_B(mp, map->br_startoff + map->br_blockcount);
 	end = (endoff - 1) >> PAGE_SHIFT;
 	do {
-		int		want;
 		unsigned	nr_pages;
 		unsigned int	i;
 
-		want = min_t(pgoff_t, end - index, PAGEVEC_SIZE - 1) + 1;
-		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, &index,
-					  want);
+		nr_pages = pagevec_lookup_range(&pvec, inode->i_mapping,
+						&index, end, PAGEVEC_SIZE);
 		if (nr_pages == 0)
 			break;
 
@@ -1075,9 +1073,6 @@ xfs_find_get_desired_pgoff(
 				*offset = lastoff;
 				goto out;
 			}
-			/* Searching done if the page index is out of range. */
-			if (page->index > end)
-				goto out;
 
 			lock_page(page);
 			/*
@@ -1117,13 +1112,6 @@ xfs_find_get_desired_pgoff(
 			unlock_page(page);
 		}
 
-		/*
-		 * The number of returned pages less than our desired, search
-		 * done.
-		 */
-		if (nr_pages < want)
-			break;
-
 		pagevec_release(&pvec);
 	} while (index <= end);
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
