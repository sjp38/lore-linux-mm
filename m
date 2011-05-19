Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7DBFD6B0022
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:49:06 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4JMhGYJ025954
	for <linux-mm@kvack.org>; Thu, 19 May 2011 16:43:16 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4JMmxiY344492
	for <linux-mm@kvack.org>; Thu, 19 May 2011 16:48:59 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4JGmvCt014173
	for <linux-mm@kvack.org>; Thu, 19 May 2011 10:48:58 -0600
Subject: [PATCH 2/3] fs: block_page_mkwrite should wait for writeback to finish
From: "Darrick J. Wong" <djwong@us.ibm.com>
Date: Thu, 19 May 2011 15:48:55 -0700
Message-ID: <20110519224855.28755.2720.stgit@elm3c44.beaverton.ibm.com>
In-Reply-To: <20110519224841.28755.80650.stgit@elm3c44.beaverton.ibm.com>
References: <20110519224841.28755.80650.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Jens Axboe <axboe@kernel.dk>, Theodore Tso <tytso@mit.edu>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

For filesystems such as nilfs2 and xfs that use block_page_mkwrite, modify that
function to wait for pending writeback before allowing the page to become
writable.  This is needed to stabilize pages during writeback for those two
filesystems.

Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
---
 fs/buffer.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)


diff --git a/fs/buffer.c b/fs/buffer.c
index a08bb8e..0e7fa16 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2367,8 +2367,10 @@ block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 			ret = VM_FAULT_OOM;
 		else /* -ENOSPC, -EIO, etc */
 			ret = VM_FAULT_SIGBUS;
-	} else
+	} else {
+		wait_on_page_writeback(page);
 		ret = VM_FAULT_LOCKED;
+	}
 
 out:
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
