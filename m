From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 47/47] nfs: trace nfs_commit_release()
Date: Mon, 13 Dec 2010 14:43:36 +0800
Message-ID: <20101213064842.818298449@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2Fy-00062X-2j
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:51:34 +0100
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C4E5A6B00A5
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:45 -0500 (EST)
Content-Disposition: inline; filename=trace-nfs-commit-release.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org


Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c             |    3 +++
 include/trace/events/nfs.h |   31 +++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

--- linux-next.orig/fs/nfs/write.c	2010-12-08 22:44:38.000000000 +0800
+++ linux-next/fs/nfs/write.c	2010-12-08 22:44:38.000000000 +0800
@@ -1475,6 +1475,9 @@ static void nfs_commit_release(void *cal
 	}
 	nfs_commit_clear_lock(NFS_I(data->inode));
 	nfs_commit_wakeup(NFS_SERVER(data->inode));
+	trace_nfs_commit_release(data->inode,
+				 data->args.offset,
+				 data->args.count);
 	nfs_commitdata_release(calldata);
 }
 
--- linux-next.orig/include/trace/events/nfs.h	2010-12-08 22:44:38.000000000 +0800
+++ linux-next/include/trace/events/nfs.h	2010-12-08 22:44:38.000000000 +0800
@@ -51,6 +51,37 @@ TRACE_EVENT(nfs_commit_unstable_pages,
 	)
 );
 
+TRACE_EVENT(nfs_commit_release,
+
+	TP_PROTO(struct inode *inode,
+		 unsigned long offset,
+		 unsigned long len),
+
+	TP_ARGS(inode, offset, len),
+
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long,	ino)
+		__field(unsigned long,	offset)
+		__field(unsigned long,	len)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->name,
+			dev_name(inode->i_mapping->backing_dev_info->dev), 32);
+		__entry->ino		= inode->i_ino;
+		__entry->offset		= offset;
+		__entry->len		= len;
+	),
+
+	TP_printk("bdi %s: ino=%lu offset=%lu len=%lu",
+		  __entry->name,
+		  __entry->ino,
+		  __entry->offset,
+		  __entry->len
+	)
+);
+
 
 #endif /* _TRACE_NFS_H */
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
