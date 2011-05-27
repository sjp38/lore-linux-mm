Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F29EA6B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 15:24:56 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4RJ7WPd000458
	for <linux-mm@kvack.org>; Fri, 27 May 2011 13:07:32 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RJQBlv032462
	for <linux-mm@kvack.org>; Fri, 27 May 2011 13:26:14 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RJNibE030257
	for <linux-mm@kvack.org>; Fri, 27 May 2011 13:23:45 -0600
Subject: [PATCH 2/2] fs: block_page_mkwrite should wait for writeback to finish
From: "Darrick J. Wong" <djwong@us.ibm.com>
Date: Fri, 27 May 2011 12:23:41 -0700
Message-ID: <20110527192341.32105.95751.stgit@elm3c44.beaverton.ibm.com>
In-Reply-To: <20110527192326.32105.34164.stgit@elm3c44.beaverton.ibm.com>
References: <20110527192326.32105.34164.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Jens Axboe <axboe@kernel.dk>, Theodore Tso <tytso@mit.edu>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

For filesystems such as nilfs2 and xfs that use block_page_mkwrite, modify that
function to wait for pending writeback before allowing the page to become
writable.  This is needed to stabilize pages during writeback for those two
filesystems.

Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
---
 fs/buffer.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/fs/buffer.c b/fs/buffer.c
index 698c6b2..49c9aad 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2382,6 +2382,7 @@ int __block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 		ret = -EAGAIN;
 		goto out_unlock;
 	}
+	wait_on_page_writeback(page);
 	return 0;
 out_unlock:
 	unlock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
