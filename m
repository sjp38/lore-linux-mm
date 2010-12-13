From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 34/35] nfs: trace nfs_commit_unstable_pages()
Date: Mon, 13 Dec 2010 22:47:20 +0800
Message-ID: <20101213150330.441472077@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA2H-00029d-8H
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:09:57 +0100
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 563976B00A7
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:08:51 -0500 (EST)
Content-Disposition: inline; filename=nfs-trace-write_inode.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c             |   10 ++++--
 include/trace/events/nfs.h |   58 +++++++++++++++++++++++++++++++++++
 2 files changed, 66 insertions(+), 2 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2010-12-13 21:46:22.000000000 +0800
+++ linux-next/fs/nfs/write.c	2010-12-13 21:46:23.000000000 +0800
@@ -29,6 +29,9 @@
 #include "nfs4_fs.h"
 #include "fscache.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/nfs.h>
+
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
 #define MIN_POOL_WRITE		(32)
@@ -1566,10 +1569,13 @@ static int nfs_commit_unstable_pages(str
 
 	ret = nfs_commit_inode(inode, flags);
 	if (ret >= 0)
-		return 0;
+		goto out;
+
 out_mark_dirty:
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
-	return ret;
+out:
+	trace_nfs_commit_unstable_pages(inode, wbc, flags, ret);
+	return ret >= 0 ? 0 : ret;
 }
 #else
 static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-next/include/trace/events/nfs.h	2010-12-13 21:46:23.000000000 +0800
@@ -0,0 +1,58 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM nfs
+
+#if !defined(_TRACE_NFS_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_NFS_H
+
+#include <linux/nfs_fs.h>
+
+
+TRACE_EVENT(nfs_commit_unstable_pages,
+
+	TP_PROTO(struct inode *inode,
+		 struct writeback_control *wbc,
+		 int sync,
+		 int ret
+	),
+
+	TP_ARGS(inode, wbc, sync, ret),
+
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(unsigned long,	ino)
+		__field(unsigned long,	npages)
+		__field(unsigned long,	in_commit)
+		__field(unsigned long,	write_chunk)
+		__field(int,		sync)
+		__field(int,		ret)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->name,
+			dev_name(inode->i_mapping->backing_dev_info->dev), 32);
+		__entry->ino		= inode->i_ino;
+		__entry->npages		= NFS_I(inode)->npages;
+		__entry->in_commit	=
+			atomic_long_read(&NFS_SERVER(inode)->in_commit);
+		__entry->write_chunk	= wbc->per_file_limit;
+		__entry->sync		= sync;
+		__entry->ret		= ret;
+	),
+
+	TP_printk("bdi %s: ino=%lu npages=%ld "
+		  "incommit=%lu write_chunk=%lu sync=%d ret=%d",
+		  __entry->name,
+		  __entry->ino,
+		  __entry->npages,
+		  __entry->in_commit,
+		  __entry->write_chunk,
+		  __entry->sync,
+		  __entry->ret
+	)
+);
+
+
+#endif /* _TRACE_NFS_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
