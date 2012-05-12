Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 7C67A6B004D
	for <linux-mm@kvack.org>; Sat, 12 May 2012 08:21:38 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5904331dak.14
        for <linux-mm@kvack.org>; Sat, 12 May 2012 05:21:37 -0700 (PDT)
Date: Sat, 12 May 2012 05:21:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 9/10] tmpfs: quit when fallocate fills memory
In-Reply-To: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205120519240.28861@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, Kay Sievers <kay@vrfy.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

As it stands, a large fallocate() on tmpfs is liable to fill memory with
pages, freed on failure except when they run into swap, at which point
they become fixed into the file despite the failure.  That feels quite
wrong, to be consuming resources precisely when they're in short supply.

Go the other way instead: shmem_fallocate() indicate the range it has
fallocated to shmem_writepage(), keeping count of pages it's allocating;
shmem_writepage() reactivate instead of swapping out pages fallocated by
this syscall (but happily swap out those from earlier occasions), keeping
count; shmem_fallocate() compare counts and give up once the reactivated
pages have started to coming back to writepage (approximately: some zones
would in fact recycle faster than others).

This is a little unusual, but works well: although we could consider the
failure to swap as a bug, and fix it later with SWAP_MAP_FALLOC handling
added in swapfile.c and memcontrol.c, I doubt that we shall ever want to.

(If there's no swap, an over-large fallocate() on tmpfs is limited in the
same way as writing: stopped by rlimit, or by tmpfs mount size if that was
set sensibly, or by __vm_enough_memory() heuristics if OVERCOMMIT_GUESS or
OVERCOMMIT_NEVER.  If OVERCOMMIT_ALWAYS, then it is liable to OOM-kill
others as writing would, but stops and frees if interrupted.)

Now that everything is freed on failure, we can then skip updating ctime.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 56 insertions(+), 2 deletions(-)

--- 3045N.orig/mm/shmem.c	2012-05-05 10:46:53.860063201 -0700
+++ 3045N/mm/shmem.c	2012-05-05 10:47:02.216063339 -0700
@@ -84,6 +84,18 @@ struct shmem_xattr {
 	char value[0];
 };
 
+/*
+ * shmem_fallocate and shmem_writepage communicate via inode->i_private
+ * (with i_mutex making sure that it has only one user at a time):
+ * we would prefer not to enlarge the shmem inode just for that.
+ */
+struct shmem_falloc {
+	pgoff_t start;		/* start of range currently being fallocated */
+	pgoff_t next;		/* the next page offset to be fallocated */
+	pgoff_t nr_falloced;	/* how many new pages have been fallocated */
+	pgoff_t nr_unswapped;	/* how often writepage refused to swap out */
+};
+
 /* Flag allocation requirements to shmem_getpage */
 enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
@@ -791,8 +803,28 @@ static int shmem_writepage(struct page *
 	 * This is somewhat ridiculous, but without plumbing a SWAP_MAP_FALLOC
 	 * value into swapfile.c, the only way we can correctly account for a
 	 * fallocated page arriving here is now to initialize it and write it.
+	 *
+	 * That's okay for a page already fallocated earlier, but if we have
+	 * not yet completed the fallocation, then (a) we want to keep track
+	 * of this page in case we have to undo it, and (b) it may not be a
+	 * good idea to continue anyway, once we're pushing into swap.  So
+	 * reactivate the page, and let shmem_fallocate() quit when too many.
 	 */
 	if (!PageUptodate(page)) {
+		if (inode->i_private) {
+			struct shmem_falloc *shmem_falloc;
+			spin_lock(&inode->i_lock);
+			shmem_falloc = inode->i_private;
+			if (shmem_falloc &&
+			    index >= shmem_falloc->start &&
+			    index < shmem_falloc->next)
+				shmem_falloc->nr_unswapped++;
+			else
+				shmem_falloc = NULL;
+			spin_unlock(&inode->i_lock);
+			if (shmem_falloc)
+				goto redirty;
+		}
 		clear_highpage(page);
 		flush_dcache_page(page);
 		SetPageUptodate(page);
@@ -1647,6 +1679,7 @@ static long shmem_fallocate(struct file
 {
 	struct inode *inode = file->f_path.dentry->d_inode;
 	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+	struct shmem_falloc shmem_falloc;
 	pgoff_t start, index, end;
 	int error;
 
@@ -1679,6 +1712,14 @@ static long shmem_fallocate(struct file
 		goto out;
 	}
 
+	shmem_falloc.start = start;
+	shmem_falloc.next  = start;
+	shmem_falloc.nr_falloced = 0;
+	shmem_falloc.nr_unswapped = 0;
+	spin_lock(&inode->i_lock);
+	inode->i_private = &shmem_falloc;
+	spin_unlock(&inode->i_lock);
+
 	for (index = start; index < end; index++) {
 		struct page *page;
 
@@ -1688,6 +1729,8 @@ static long shmem_fallocate(struct file
 		 */
 		if (signal_pending(current))
 			error = -EINTR;
+		else if (shmem_falloc.nr_unswapped > shmem_falloc.nr_falloced)
+			error = -ENOMEM;
 		else
 			error = shmem_getpage(inode, index, &page, SGP_FALLOC,
 									NULL);
@@ -1696,10 +1739,18 @@ static long shmem_fallocate(struct file
 			shmem_undo_range(inode,
 				(loff_t)start << PAGE_CACHE_SHIFT,
 				(loff_t)index << PAGE_CACHE_SHIFT, true);
-			goto ctime;
+			goto undone;
 		}
 
 		/*
+		 * Inform shmem_writepage() how far we have reached.
+		 * No need for lock or barrier: we have the page lock.
+		 */
+		shmem_falloc.next++;
+		if (!PageUptodate(page))
+			shmem_falloc.nr_falloced++;
+
+		/*
 		 * If !PageUptodate, leave it that way so that freeable pages
 		 * can be recognized if we need to rollback on error later.
 		 * But set_page_dirty so that memory pressure will swap rather
@@ -1714,8 +1765,11 @@ static long shmem_fallocate(struct file
 
 	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
 		i_size_write(inode, offset + len);
-ctime:
 	inode->i_ctime = CURRENT_TIME;
+undone:
+	spin_lock(&inode->i_lock);
+	inode->i_private = NULL;
+	spin_unlock(&inode->i_lock);
 out:
 	mutex_unlock(&inode->i_mutex);
 	return error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
