Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 819476B00E7
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:54:31 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/7] 9p: Push file_update_time() into v9fs_vm_page_mkwrite()
Date: Mon,  5 Mar 2012 15:54:15 +0100
Message-Id: <1330959258-23211-5-git-send-email-jack@suse.cz>
In-Reply-To: <1330959258-23211-1-git-send-email-jack@suse.cz>
References: <1330959258-23211-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, v9fs-developer@lists.sourceforge.net

CC: Eric Van Hensbergen <ericvh@gmail.com>
CC: Ron Minnich <rminnich@sandia.gov>
CC: Latchesar Ionkov <lucho@ionkov.net>
CC: v9fs-developer@lists.sourceforge.net
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/9p/vfs_file.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index fc06fd2..dd6f7ee 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -610,6 +610,9 @@ v9fs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	p9_debug(P9_DEBUG_VFS, "page %p fid %lx\n",
 		 page, (unsigned long)filp->private_data);
 
+	/* Update file times before taking page lock */
+	file_update_time(filp);
+
 	v9inode = V9FS_I(inode);
 	/* make sure the cache has finished storing the page */
 	v9fs_fscache_wait_on_page_write(inode, page);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
