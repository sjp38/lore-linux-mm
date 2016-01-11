Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 17:07:58 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 12/13] aio: add support for aio readahead
Message-ID: <130a393a298209223b5ed3c3d3fe9023e56eddcb.1452549431.git.bcrl@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1452549431.git.bcrl@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Introduce an asynchronous operation to populate the page cache with
pages at a given offset and length.  This operation is conceptually
similar to performing an asynchronous read except that it does not
actually copy the data from the page cache into userspace, rather it
performs readahead and notifies userspace when all pages have been read.

The motivation for this came about as a result of investigation into a
performace degradation when reading from disk.  In the case of a heavily
loaded system, the copy_to_user() performed for an asynchronous read was
temporally quite distant from when the data was actually used.  By only
reading the data into the kernel's page cache, the cache pollution
caused by copying the data into userspace is avoided, and overall system
performance is improved.

Signed-off-by: Benjamin LaHaise <ben.lahaise@solacesystems.com>
Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 fs/aio.c                     | 141 +++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/aio_abi.h |   1 +
 2 files changed, 142 insertions(+)

diff --git a/fs/aio.c b/fs/aio.c
index 3a70492..5cb3d74 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -42,6 +42,7 @@
 #include <linux/mount.h>
 #include <linux/fdtable.h>
 #include <linux/fs_struct.h>
+#include <../mm/internal.h>
 
 #include <asm/kmap_types.h>
 #include <asm/uaccess.h>
@@ -238,6 +239,8 @@ long aio_do_openat(int fd, const char *filename, int flags, int mode);
 long aio_do_unlinkat(int fd, const char *filename, int flags, int mode);
 long aio_foo_at(struct aio_kiocb *req, do_foo_at_t do_foo_at);
 
+long aio_readahead(struct aio_kiocb *iocb, unsigned long len);
+
 static __always_inline bool aio_may_use_threads(void)
 {
 #if IS_ENABLED(CONFIG_AIO_THREAD)
@@ -1812,6 +1815,137 @@ long aio_foo_at(struct aio_kiocb *req, do_foo_at_t do_foo_at)
 				     AIO_THREAD_NEED_FILES |
 				     AIO_THREAD_NEED_CRED);
 }
+
+static int aio_ra_filler(void *data, struct page *page)
+{
+	struct file *file = data;
+
+	return file->f_mapping->a_ops->readpage(file, page);
+}
+
+static long aio_ra_wait_on_pages(struct file *file, pgoff_t start,
+				 unsigned long nr)
+{
+	struct address_space *mapping = file->f_mapping;
+	unsigned long i;
+
+	/* Wait on pages starting at the end to holdfully avoid too many
+	 * wakeups.
+	 */
+	for (i = nr; i-- > 0; ) {
+		pgoff_t index = start + i;
+		struct page *page;
+
+		/* First do the quick check to see if the page is present and
+		 * uptodate.
+		 */
+		rcu_read_lock();
+		page = radix_tree_lookup(&mapping->page_tree, index);
+		rcu_read_unlock();
+
+		if (page && !radix_tree_exceptional_entry(page) &&
+		    PageUptodate(page)) {
+			continue;
+		}
+
+		page = read_cache_page(mapping, index, aio_ra_filler, file);
+		if (IS_ERR(page))
+			return PTR_ERR(page);
+		page_cache_release(page);
+	}
+	return 0;
+}
+
+static long aio_thread_op_readahead(struct aio_kiocb *iocb)
+{
+	pgoff_t start, end, nr, offset;
+	long ret = 0;
+
+	start = iocb->common.ki_pos >> PAGE_CACHE_SHIFT;
+	end = (iocb->common.ki_pos + iocb->ki_data - 1) >> PAGE_CACHE_SHIFT;
+	nr = end - start + 1;
+
+	for (offset = 0; offset < nr; ) {
+		pgoff_t chunk = nr - offset;
+		unsigned long max_chunk = (2 * 1024 * 1024) / PAGE_CACHE_SIZE;
+
+		if (chunk > max_chunk)
+			chunk = max_chunk;
+
+		ret = __do_page_cache_readahead(iocb->common.ki_filp->f_mapping,
+						iocb->common.ki_filp,
+						start + offset, chunk, 0, 1);
+		if (ret <= 0)
+			break;
+		offset += ret;
+	}
+
+	if (!offset && ret < 0)
+		return ret;
+
+	if (offset > 0) {
+		ret = aio_ra_wait_on_pages(iocb->common.ki_filp, start, offset);
+		if (ret < 0)
+			return ret;
+	}
+
+	if (offset == nr)
+		return iocb->ki_data;
+	if (offset > 0)
+		return ((start + offset) << PAGE_CACHE_SHIFT) -
+			iocb->common.ki_pos;
+	return 0;
+}
+
+long aio_readahead(struct aio_kiocb *iocb, unsigned long len)
+{
+	struct address_space *mapping = iocb->common.ki_filp->f_mapping;
+	pgoff_t index, end;
+	loff_t epos, isize;
+	int do_io = 0;
+
+	if (!mapping || !mapping->a_ops)
+		return -EBADF;
+	if (!mapping->a_ops->readpage && !mapping->a_ops->readpages)
+		return -EBADF;
+	if (!len)
+		return 0;
+
+	epos = iocb->common.ki_pos + len;
+	if (epos < 0)
+		return -EINVAL;
+	isize = i_size_read(mapping->host);
+	if (isize < epos) {
+		epos = isize - iocb->common.ki_pos;
+		if (epos <= 0)
+			return 0;
+		if ((unsigned long)epos != epos)
+			return -EINVAL;
+		len = epos;
+	}
+
+	index = iocb->common.ki_pos >> PAGE_CACHE_SHIFT;
+	end = (iocb->common.ki_pos + len - 1) >> PAGE_CACHE_SHIFT;
+	iocb->ki_data = len;
+	if (end < index)
+		return -EINVAL;
+
+	do {
+		struct page *page;
+
+		rcu_read_lock();
+		page = radix_tree_lookup(&mapping->page_tree, index);
+		rcu_read_unlock();
+
+		if (!page || radix_tree_exceptional_entry(page) ||
+		    !PageUptodate(page))
+			do_io = 1;
+	} while (!do_io && (index++ < end));
+
+	if (do_io)
+		return aio_thread_queue_iocb(iocb, aio_thread_op_readahead, 0);
+	return len;
+}
 #endif /* IS_ENABLED(CONFIG_AIO_THREAD) */
 
 /*
@@ -1922,6 +2056,13 @@ rw_common:
 			ret = aio_foo_at(req, aio_do_unlinkat);
 		break;
 
+	case IOCB_CMD_READAHEAD:
+		if (user_iocb->aio_buf)
+			return -EINVAL;
+		if (aio_may_use_threads())
+			ret = aio_readahead(req, user_iocb->aio_nbytes);
+		break;
+
 	default:
 		pr_debug("EINVAL: no operation provided\n");
 		return -EINVAL;
diff --git a/include/uapi/linux/aio_abi.h b/include/uapi/linux/aio_abi.h
index 63a0d41..4def682 100644
--- a/include/uapi/linux/aio_abi.h
+++ b/include/uapi/linux/aio_abi.h
@@ -47,6 +47,7 @@ enum {
 
 	IOCB_CMD_OPENAT = 9,
 	IOCB_CMD_UNLINKAT = 10,
+	IOCB_CMD_READAHEAD = 12,
 };
 
 /*
-- 
2.5.0


-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
