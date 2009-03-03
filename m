Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D42F36B004F
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 05:41:17 -0500 (EST)
Date: Tue, 3 Mar 2009 11:41:14 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 2/2] buffer, btrfs: fix page_mkwrite error cases
Message-ID: <20090303104114.GD17042@wotan.suse.de>
References: <20090303103838.GC17042@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090303103838.GC17042@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
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

Should fix all filesystems, but this is just a demonstration/rfc. The
other fses are slightly less trivial :) If anybody cares to fix their
filesystem and send me a patch, that would be nice (but not required,
because patch 1/2 is back compatible).

---
 fs/btrfs/inode.c |   10 ++++++----
 fs/buffer.c      |   12 ++++++++----
 2 files changed, 14 insertions(+), 8 deletions(-)

Index: linux-2.6/fs/btrfs/inode.c
===================================================================
--- linux-2.6.orig/fs/btrfs/inode.c
+++ linux-2.6/fs/btrfs/inode.c
@@ -4307,10 +4307,14 @@ int btrfs_page_mkwrite(struct vm_area_st
 	u64 page_end;
 
 	ret = btrfs_check_data_free_space(root, inode, PAGE_CACHE_SIZE);
-	if (ret)
+	if (ret) {
+		if (ret == -ENOMEM)
+			ret = VM_FAULT_OOM;
+		else /* -ENOSPC, -EIO, etc */
+			ret = VM_FAULT_SIGBUS;
 		goto out;
 
-	ret = -EINVAL;
+	ret = VM_FAULT_NOPAGE; /* make the VM retry the fault */
 again:
 	lock_page(page);
 	size = i_size_read(inode);
@@ -4363,8 +4367,6 @@ again:
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
