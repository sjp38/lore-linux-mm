Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CA9AA6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 23:55:06 -0400 (EDT)
Date: Wed, 11 Mar 2009 04:55:03 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/2] fs: fix page_mkwrite error cases in core code and btrfs
Message-ID: <20090311035503.GI16561@wotan.suse.de>
References: <20090311035318.GH16561@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311035318.GH16561@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>


page_mkwrite is called with neither the page lock nor the ptl held. This
means a page can be concurrently truncated or invalidated out from underneath
it. Callers are supposed to prevent truncate races themselves, however
previously the only thing they can do in case they hit one is to raise a
SIGBUS. A sigbus is wrong for the case that the page has been invalidated
or truncated within i_size (eg. hole punched). Callers may also have to
perform memory allocations in this path, where again, SIGBUS would be wrong.

The previous patch made it possible to properly specify errors. Convert
the generic buffer.c code and btrfs to return sane error values
(in the case of page removed from pagecache, VM_FAULT_NOPAGE will cause the
fault handler to exit without doing anything, and the fault will be retried 
properly).

This fixes core code, and converts btrfs as a template/example. All other
filesystems defining their own page_mkwrite should be fixed in a similar
manner.

Acked-by: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 fs/btrfs/inode.c |   11 +++++++----
 fs/buffer.c      |   12 ++++++++----
 2 files changed, 15 insertions(+), 8 deletions(-)

Index: linux-2.6/fs/btrfs/inode.c
===================================================================
--- linux-2.6.orig/fs/btrfs/inode.c
+++ linux-2.6/fs/btrfs/inode.c
@@ -4307,10 +4307,15 @@ int btrfs_page_mkwrite(struct vm_area_st
 	u64 page_end;
 
 	ret = btrfs_check_data_free_space(root, inode, PAGE_CACHE_SIZE);
-	if (ret)
+	if (ret) {
+		if (ret == -ENOMEM)
+			ret = VM_FAULT_OOM;
+		else /* -ENOSPC, -EIO, etc */
+			ret = VM_FAULT_SIGBUS;
 		goto out;
+	}
 
-	ret = -EINVAL;
+	ret = VM_FAULT_NOPAGE; /* make the VM retry the fault */
 again:
 	lock_page(page);
 	size = i_size_read(inode);
@@ -4363,8 +4368,6 @@ again:
 out_unlock:
 	unlock_page(page);
 out:
-	if (ret)
-		ret = VM_FAULT_SIGBUS;
 	return ret;
 }
 
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2473,7 +2473,7 @@ block_page_mkwrite(struct vm_area_struct
 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
 	unsigned long end;
 	loff_t size;
-	int ret = -EINVAL;
+	int ret = VM_FAULT_NOPAGE; /* make the VM retry the fault */
 
 	lock_page(page);
 	size = i_size_read(inode);
@@ -2493,10 +2493,14 @@ block_page_mkwrite(struct vm_area_struct
 	if (!ret)
 		ret = block_commit_write(page, 0, end);
 
-out_unlock:
-	if (ret)
-		ret = VM_FAULT_SIGBUS;
+	if (unlikely(ret)) {
+		if (ret == -ENOMEM)
+			ret = VM_FAULT_OOM;
+		else /* -ENOSPC, -EIO, etc */
+			ret = VM_FAULT_SIGBUS;
+	}
 
+out_unlock:
 	unlock_page(page);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
