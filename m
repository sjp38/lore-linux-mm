Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 89D25900118
	for <linux-mm@kvack.org>; Tue, 10 May 2011 13:13:23 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4AGxWkG009028
	for <linux-mm@kvack.org>; Tue, 10 May 2011 10:59:32 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p4AHCxNr111146
	for <linux-mm@kvack.org>; Tue, 10 May 2011 11:13:02 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4ABCpuV019789
	for <linux-mm@kvack.org>; Tue, 10 May 2011 05:12:57 -0600
Date: Tue, 10 May 2011 10:12:45 -0700
From: "Darrick J. Wong" <djwong@us.ibm.com>
Subject: Re: [PATCH 2/7] fs: block_page_mkwrite should wait for writeback
	to finish
Message-ID: <20110510171245.GF18929@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com> <20110509230334.19566.17603.stgit@elm3c44.beaverton.ibm.com> <20110510124103.GC4402@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110510124103.GC4402@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

For filesystems such as nilfs2 and xfs that use block_page_mkwrite, modify that
function to wait for pending writeback before allowing the page to become
writable.  This is needed to stabilize pages during writeback for those two
filesystems.

Slight rework based on Jan Kara's suggestion.

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
