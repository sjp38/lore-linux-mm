Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 002456B0011
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:03:42 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p49FUP6i002984
	for <linux-mm@kvack.org>; Mon, 9 May 2011 09:30:25 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p49N3b8F159524
	for <linux-mm@kvack.org>; Mon, 9 May 2011 17:03:37 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p49N3afA025263
	for <linux-mm@kvack.org>; Mon, 9 May 2011 17:03:37 -0600
Subject: [PATCH 2/7] fs: block_page_mkwrite should wait for writeback to finish
From: "Darrick J. Wong" <djwong@us.ibm.com>
Date: Mon, 09 May 2011 16:03:34 -0700
Message-ID: <20110509230334.19566.17603.stgit@elm3c44.beaverton.ibm.com>
In-Reply-To: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

For filesystems such as nilfs2 and xfs that use block_page_mkwrite, modify that
function to wait for pending writeback before allowing the page to become
writable.  This is needed to stabilize pages during writeback for those two
filesystems.

Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
---
 fs/buffer.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/fs/buffer.c b/fs/buffer.c
index a08bb8e..cf9a795 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2361,6 +2361,7 @@ block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (!ret)
 		ret = block_commit_write(page, 0, end);
 
+	wait_on_page_writeback(page);
 	if (unlikely(ret)) {
 		unlock_page(page);
 		if (ret == -ENOMEM)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
