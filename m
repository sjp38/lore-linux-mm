Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id C1AD56B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 16:50:21 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7630667pbb.14
        for <linux-mm@kvack.org>; Sun, 13 May 2012 13:50:21 -0700 (PDT)
Date: Sun, 13 May 2012 13:50:06 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/2] xfs: hole-punch use truncate_pagecache_range
Message-ID: <alpine.LSU.2.00.1205131347120.1547@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Ben Myers <bpm@sgi.com>, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

When truncating a file, we unmap pages from userspace first, as that's
usually more efficient than relying, page by page, on the fallback in
truncate_inode_page() - particularly if the file is mapped many times.

Do the same when punching a hole: 3.4 added truncate_pagecache_range()
to do the unmap and trunc, so use it in xfs_flushinval_pages(), instead
of calling truncate_inode_pages_range() directly.

Should xfs_tosspages() be using it too?  I don't know: left unchanged.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 fs/xfs/xfs_fs_subr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- next-20120511/fs/xfs/xfs_fs_subr.c	2012-01-17 20:42:07.879627688 -0800
+++ linux/fs/xfs/xfs_fs_subr.c	2012-05-12 18:01:14.988654723 -0700
@@ -53,7 +53,7 @@ xfs_flushinval_pages(
 	ret = filemap_write_and_wait_range(mapping, first,
 				last == -1 ? LLONG_MAX : last);
 	if (!ret)
-		truncate_inode_pages_range(mapping, first, last);
+		truncate_pagecache_range(VFS_I(ip), first, last);
 	return -ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
