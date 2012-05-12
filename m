Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 95CB26B004D
	for <linux-mm@kvack.org>; Sat, 12 May 2012 08:17:40 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5899717dak.14
        for <linux-mm@kvack.org>; Sat, 12 May 2012 05:17:39 -0700 (PDT)
Date: Sat, 12 May 2012 05:17:24 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 7/10] tmpfs: support fallocate preallocation
In-Reply-To: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205120515080.28861@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, Kay Sievers <kay@vrfy.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

The systemd plumbers expressed a wish that tmpfs support preallocation.
Cong Wang wrote a patch, but several kernel guys expressed scepticism:
https://lkml.org/lkml/2011/11/18/137

Christoph Hellwig: What for exactly?  Please explain why preallocating
on tmpfs would make any sense.
Kay Sievers: To be able to safely use mmap(), regarding SIGBUS, on files
on the /dev/shm filesystem.  The glibc fallback loop for -ENOSYS [or
-EOPNOTSUPP] on fallocate is just ugly.
Hugh Dickins: If tmpfs is going to support fallocate(FALLOC_FL_PUNCH_HOLE),
it would seem perverse to permit the deallocation but fail the allocation.
Christoph Hellwig: Agreed.

Now that we do have shmem_fallocate() for hole-punching, plumb in basic
support for preallocation mode too.  It's fairly straightforward (though
quite a few details needed attention), except for when it fails part way
through.  What a pity that fallocate(2) was not specified to return the
length allocated, permitting short fallocations!

As it is, when it fails part way through, we ought to free what has just
been allocated by this system call; but must be very sure not to free any
allocated earlier, or any allocated by racing accesses (not all excluded
by i_mutex).

But we cannot distinguish them: so in this patch simply leak allocations
on partial failure (they will be freed later if the file is removed).

An attractive alternative approach would have been for fallocate() not to
allocate pages at all, but note reservations by entries in the radix-tree.
But that would give less assurance, and, critically, would be hard to fit
with mem cgroups (who owns the reservations?): allocating pages lets
fallocate() behave in just the same way as write().

Based-on-patch-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 60 insertions(+), 1 deletion(-)

--- 3045N.orig/mm/shmem.c	2012-05-05 10:46:35.224062700 -0700
+++ 3045N/mm/shmem.c	2012-05-05 10:46:45.312062979 -0700
@@ -1602,7 +1602,9 @@ static long shmem_fallocate(struct file
 							 loff_t len)
 {
 	struct inode *inode = file->f_path.dentry->d_inode;
-	int error = -EOPNOTSUPP;
+	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+	pgoff_t start, index, end;
+	int error;
 
 	mutex_lock(&inode->i_mutex);
 
@@ -1617,8 +1619,65 @@ static long shmem_fallocate(struct file
 		shmem_truncate_range(inode, offset, offset + len - 1);
 		/* No need to unmap again: hole-punching leaves COWed pages */
 		error = 0;
+		goto out;
 	}
 
+	/* We need to check rlimit even when FALLOC_FL_KEEP_SIZE */
+	error = inode_newsize_ok(inode, offset + len);
+	if (error)
+		goto out;
+
+	start = offset >> PAGE_CACHE_SHIFT;
+	end = (offset + len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	/* Try to avoid a swapstorm if len is impossible to satisfy */
+	if (sbinfo->max_blocks && end - start > sbinfo->max_blocks) {
+		error = -ENOSPC;
+		goto out;
+	}
+
+	for (index = start; index < end; index++) {
+		struct page *page;
+
+		/*
+		 * Good, the fallocate(2) manpage permits EINTR: we may have
+		 * been interrupted because we are using up too much memory.
+		 */
+		if (signal_pending(current))
+			error = -EINTR;
+		else
+			error = shmem_getpage(inode, index, &page, SGP_WRITE,
+									NULL);
+		if (error) {
+			/*
+			 * We really ought to free what we allocated so far,
+			 * but it would be wrong to free pages allocated
+			 * earlier, or already now in use: i_mutex does not
+			 * exclude all cases.  We do not know what to free.
+			 */
+			goto ctime;
+		}
+
+		if (!PageUptodate(page)) {
+			clear_highpage(page);
+			flush_dcache_page(page);
+			SetPageUptodate(page);
+		}
+		/*
+		 * set_page_dirty so that memory pressure will swap rather
+		 * than free the pages we are allocating (and SGP_CACHE pages
+		 * might still be clean: we now need to mark those dirty too).
+		 */
+		set_page_dirty(page);
+		unlock_page(page);
+		page_cache_release(page);
+		cond_resched();
+	}
+
+	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
+		i_size_write(inode, offset + len);
+ctime:
+	inode->i_ctime = CURRENT_TIME;
+out:
 	mutex_unlock(&inode->i_mutex);
 	return error;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
