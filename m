Date: Sat, 6 Oct 2007 21:47:48 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 6/7] shmem_file_write is redundant
In-Reply-To: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0710062146370.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

With the old aops, writing to a tmpfs file had to use its own special
method: the generic method would pass in a fresh page to prepare_write
when the right page was there in swapcache - which was inefficient to
handle, even once we'd concocted the code to handle it.

With the new aops, the generic method uses shmem_write_end, which lets
shmem_getpage find the right page: so now abandon shmem_file_write in
favour of the generic method.  Yes, that does do several things that
tmpfs hasn't really needed (notably balance_dirty_pages_ratelimited,
which ramfs also calls); but more use of common code is preferable.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/shmem.c |  109 +--------------------------------------------------
 1 file changed, 3 insertions(+), 106 deletions(-)

--- patch5/mm/shmem.c	2007-10-04 19:24:41.000000000 +0100
+++ patch6/mm/shmem.c	2007-10-04 19:24:44.000000000 +0100
@@ -1091,7 +1091,7 @@ static int shmem_getpage(struct inode *i
 	 * Normally, filepage is NULL on entry, and either found
 	 * uptodate immediately, or allocated and zeroed, or read
 	 * in under swappage, which is then assigned to filepage.
-	 * But shmem_readpage and shmem_write_begin pass in a locked
+	 * But shmem_readpage (required for splice) passes in a locked
 	 * filepage, which may be found not uptodate by other callers
 	 * too, and may need to be copied from the swappage read in.
 	 */
@@ -1460,110 +1460,6 @@ shmem_write_end(struct file *file, struc
 	return copied;
 }
 
-static ssize_t
-shmem_file_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos)
-{
-	struct inode	*inode = file->f_path.dentry->d_inode;
-	loff_t		pos;
-	unsigned long	written;
-	ssize_t		err;
-
-	if ((ssize_t) count < 0)
-		return -EINVAL;
-
-	if (!access_ok(VERIFY_READ, buf, count))
-		return -EFAULT;
-
-	mutex_lock(&inode->i_mutex);
-
-	pos = *ppos;
-	written = 0;
-
-	err = generic_write_checks(file, &pos, &count, 0);
-	if (err || !count)
-		goto out;
-
-	err = remove_suid(file->f_path.dentry);
-	if (err)
-		goto out;
-
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
-
-	do {
-		struct page *page = NULL;
-		unsigned long bytes, index, offset;
-		char *kaddr;
-		int left;
-
-		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
-		index = pos >> PAGE_CACHE_SHIFT;
-		bytes = PAGE_CACHE_SIZE - offset;
-		if (bytes > count)
-			bytes = count;
-
-		/*
-		 * We don't hold page lock across copy from user -
-		 * what would it guard against? - so no deadlock here.
-		 * But it still may be a good idea to prefault below.
-		 */
-
-		err = shmem_getpage(inode, index, &page, SGP_WRITE, NULL);
-		if (err)
-			break;
-
-		unlock_page(page);
-		left = bytes;
-		if (PageHighMem(page)) {
-			volatile unsigned char dummy;
-			__get_user(dummy, buf);
-			__get_user(dummy, buf + bytes - 1);
-
-			kaddr = kmap_atomic(page, KM_USER0);
-			left = __copy_from_user_inatomic(kaddr + offset,
-							buf, bytes);
-			kunmap_atomic(kaddr, KM_USER0);
-		}
-		if (left) {
-			kaddr = kmap(page);
-			left = __copy_from_user(kaddr + offset, buf, bytes);
-			kunmap(page);
-		}
-
-		written += bytes;
-		count -= bytes;
-		pos += bytes;
-		buf += bytes;
-		if (pos > inode->i_size)
-			i_size_write(inode, pos);
-
-		flush_dcache_page(page);
-		set_page_dirty(page);
-		mark_page_accessed(page);
-		page_cache_release(page);
-
-		if (left) {
-			pos -= left;
-			written -= left;
-			err = -EFAULT;
-			break;
-		}
-
-		/*
-		 * Our dirty pages are not counted in nr_dirty,
-		 * and we do not attempt to balance dirty pages.
-		 */
-
-		cond_resched();
-	} while (count);
-
-	*ppos = pos;
-	if (written)
-		err = written;
-out:
-	mutex_unlock(&inode->i_mutex);
-	return err;
-}
-
 static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_t *desc, read_actor_t actor)
 {
 	struct inode *inode = filp->f_path.dentry->d_inode;
@@ -2338,7 +2234,8 @@ static const struct file_operations shme
 #ifdef CONFIG_TMPFS
 	.llseek		= generic_file_llseek,
 	.read		= shmem_file_read,
-	.write		= shmem_file_write,
+	.write		= do_sync_write,
+	.aio_write	= generic_file_aio_write,
 	.fsync		= simple_sync_file,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
