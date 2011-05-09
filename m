Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 432456B0022
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:03:56 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p49MbiFt032702
	for <linux-mm@kvack.org>; Mon, 9 May 2011 18:37:44 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p49N3ssB909414
	for <linux-mm@kvack.org>; Mon, 9 May 2011 19:03:54 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p49N3pgH009904
	for <linux-mm@kvack.org>; Mon, 9 May 2011 20:03:53 -0300
Subject: [PATCH 4/7] ext4: Clean up some wait_on_page_writeback calls
From: "Darrick J. Wong" <djwong@us.ibm.com>
Date: Mon, 09 May 2011 16:03:49 -0700
Message-ID: <20110509230349.19566.27020.stgit@elm3c44.beaverton.ibm.com>
In-Reply-To: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

wait_on_page_writeback already checks the writeback bit, so callers of it
needn't do that test.

Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
---
 fs/ext4/inode.c       |    4 +---
 fs/ext4/move_extent.c |    3 +--
 2 files changed, 2 insertions(+), 5 deletions(-)


diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index f2fa5e8..3db34b2 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2796,9 +2796,7 @@ static int write_cache_pages_da(struct address_space *mapping,
 				continue;
 			}
 
-			if (PageWriteback(page))
-				wait_on_page_writeback(page);
-
+			wait_on_page_writeback(page);
 			BUG_ON(PageWriteback(page));
 
 			if (mpd->next_page != page->index)
diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index b9f3e78..2b8304b 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -876,8 +876,7 @@ move_extent_per_page(struct file *o_filp, struct inode *donor_inode,
 	 * It needs to call wait_on_page_writeback() to wait for the
 	 * writeback of the page.
 	 */
-	if (PageWriteback(page))
-		wait_on_page_writeback(page);
+	wait_on_page_writeback(page);
 
 	/* Release old bh and drop refs */
 	try_to_release_page(page, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
