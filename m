Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l69JL9of015966
	for <linux-mm@kvack.org>; Mon, 9 Jul 2007 15:21:09 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l69JQURR250200
	for <linux-mm@kvack.org>; Mon, 9 Jul 2007 13:26:31 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l69JQU1m030776
	for <linux-mm@kvack.org>; Mon, 9 Jul 2007 13:26:30 -0600
Subject: [RFC][PATCH] hugetlbfs read support
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Mon, 09 Jul 2007 12:28:11 -0700
Message-Id: <1184009291.31638.8.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: nacc@us.ibm.com, clameter@sgi.com, Bill Irwin <bill.irwin@oracle.com>, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

Comments/flames ?

Thanks,
Badari

Support for reading from hugetlbfs files. libhugetlbfs lets application
text/data to be placed in large pages. When we do that, oprofile doesn't
work - since it tries to read from it.

This code is very similar to what do_generic_mapping_read() does, but
I can't use it since it has PAGE_CACHE_SIZE assumptions. Christoph
Lamater's cleanup to pagecache would hopefully give me all of this.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

 fs/hugetlbfs/inode.c |  109 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 109 insertions(+)

Index: linux-2.6.22/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.22.orig/fs/hugetlbfs/inode.c	2007-07-08 16:32:17.000000000 -0700
+++ linux-2.6.22/fs/hugetlbfs/inode.c	2007-07-09 13:37:00.000000000 -0700
@@ -156,6 +156,114 @@ full_search:
 }
 #endif
 
+static int
+hugetlbfs_read_actor(struct page *page, unsigned long offset,
+			char __user *buf, unsigned long count,
+			unsigned long size)
+{
+	char *kaddr;
+	unsigned long to_copy;
+	int i, chunksize;
+
+	if (size > count)
+		size = count;
+
+	/* Find which 4k chunk and offset with in that chunk */
+	i = offset >> PAGE_CACHE_SHIFT;
+	offset = offset & ~PAGE_CACHE_MASK;
+	to_copy = size;
+
+	while (to_copy) {
+		chunksize = PAGE_CACHE_SIZE;
+		if (offset)
+			chunksize -= offset;
+		if (chunksize > to_copy)
+			chunksize = to_copy;
+		kaddr = kmap(&page[i]);
+		memcpy(buf, kaddr + offset, chunksize);
+		kunmap(&page[i]);
+		offset = 0;
+		to_copy -= chunksize;
+		buf += chunksize;
+		i++;
+	}
+	return size;
+}
+
+/*
+ * Support for read() - Find the page attached to f_mapping and copy out the
+ * data. Its *very* similar to do_generic_mapping_read(), we can't use that
+ * since it has PAGE_CACHE_SIZE assumptions.
+ */
+ssize_t
+hugetlbfs_read(struct file *filp, char __user *buf, size_t len, loff_t *ppos)
+{
+	struct address_space *mapping = filp->f_mapping;
+	struct inode *inode = mapping->host;
+	unsigned long index = *ppos >> HPAGE_SHIFT;
+	unsigned long end_index;
+	loff_t isize;
+	unsigned long offset;
+	ssize_t retval = 0;
+
+	/* validate len */
+	if (len == 0)
+		goto out;
+
+	isize = i_size_read(inode);
+	if (!isize)
+		goto out;
+
+	offset = *ppos & ~HPAGE_MASK;
+	end_index = (isize - 1) >> HPAGE_SHIFT;
+	for (;;) {
+		struct page *page;
+		unsigned long nr, ret;
+
+		/* nr is the maximum number of bytes to copy from this page */
+		nr = HPAGE_SIZE;
+		if (index >= end_index) {
+			if (index > end_index)
+				goto out;
+			nr = ((isize - 1) & ~HPAGE_MASK) + 1;
+			if (nr <= offset) {
+				goto out;
+			}
+		}
+		nr = nr - offset;
+
+		/* Find the page */
+		page = find_get_page(mapping, index);
+		if (unlikely(page == NULL)) {
+			/*
+			 * We can't find the page in the cache - bail out ?
+			 */
+			goto out;
+		}
+		/*
+		 * Ok, we have the page, so now we can copy it to user space...
+		 */
+		ret = hugetlbfs_read_actor(page, offset, buf, len, nr);
+		if (ret < 0) {
+			retval = retval ? : ret;
+			goto out;
+		}
+
+		offset += ret;
+		retval += ret;
+		len -= ret;
+		index += offset >> HPAGE_SHIFT;
+		offset &= ~HPAGE_MASK;
+
+		page_cache_release(page);
+		if (ret == nr && len)
+			continue;
+		goto out;
+	}
+out:
+	return retval;
+}
+
 /*
  * Read a page. Again trivial. If it didn't already exist
  * in the page cache, it is zero-filled.
@@ -560,6 +668,7 @@ static void init_once(void *foo, struct 
 }
 
 const struct file_operations hugetlbfs_file_operations = {
+	.read			= hugetlbfs_read,
 	.mmap			= hugetlbfs_file_mmap,
 	.fsync			= simple_sync_file,
 	.get_unmapped_area	= hugetlb_get_unmapped_area,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
