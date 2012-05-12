Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 740326B004D
	for <linux-mm@kvack.org>; Sat, 12 May 2012 08:27:47 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5910187dak.14
        for <linux-mm@kvack.org>; Sat, 12 May 2012 05:27:46 -0700 (PDT)
Date: Sat, 12 May 2012 05:27:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 10/10] tmpfs: support SEEK_DATA and SEEK_HOLE
In-Reply-To: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205120521310.28861@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Josef Bacik <josef@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andreas Dilger <adilger@dilger.ca>, Dave Chinner <david@fromorbit.com>, Marco Stornelli <marco.stornelli@gmail.com>, Jeff liu <jeff.liu@oracle.com>, Chris Mason <chris.mason@oracle.com>, Sunil Mushran <sunil.mushran@oracle.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

It's quite easy for tmpfs to scan the radix_tree to support llseek's
new SEEK_DATA and SEEK_HOLE options: so add them while the minutiae
are still on my mind (in particular, the !PageUptodate-ness of pages
fallocated but still unwritten).

But I don't know who actually uses SEEK_DATA or SEEK_HOLE, and whether
it would be of any use to them on tmpfs.  This code adds 92 lines and
752 bytes on x86_64 - is that bloat or worthwhile?

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |   94 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 93 insertions(+), 1 deletion(-)

--- 3045N.orig/mm/shmem.c	2012-05-05 10:47:02.216063339 -0700
+++ 3045N/mm/shmem.c	2012-05-05 10:47:09.724063528 -0700
@@ -439,6 +439,56 @@ void shmem_unlock_mapping(struct address
 }
 
 /*
+ * llseek SEEK_DATA or SEEK_HOLE through the radix_tree.
+ */
+static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
+				    pgoff_t index, pgoff_t end, int origin)
+{
+	struct page *page;
+	struct pagevec pvec;
+	pgoff_t indices[PAGEVEC_SIZE];
+	bool done = false;
+	int i;
+
+	pagevec_init(&pvec, 0);
+	pvec.nr = 1;		/* start small: we may be there already */
+	while (!done) {
+		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
+					pvec.nr, pvec.pages, indices);
+		if (!pvec.nr) {
+			if (origin == SEEK_DATA)
+				index = end;
+			break;
+		}
+		for (i = 0; i < pvec.nr; i++, index++) {
+			if (index < indices[i]) {
+				if (origin == SEEK_HOLE) {
+					done = true;
+					break;
+				}
+				index = indices[i];
+			}
+			page = pvec.pages[i];
+			if (page && !radix_tree_exceptional_entry(page)) {
+				if (!PageUptodate(page))
+					page = NULL;
+			}
+			if (index >= end ||
+			    (page && origin == SEEK_DATA) ||
+			    (!page && origin == SEEK_HOLE)) {
+				done = true;
+				break;
+			}
+		}
+		shmem_deswap_pagevec(&pvec);
+		pagevec_release(&pvec);
+		pvec.nr = PAGEVEC_SIZE;
+		cond_resched();
+	}
+	return index;
+}
+
+/*
  * Remove range of pages and swap entries from radix tree, and free them.
  * If !unfalloc, truncate or punch hole; if unfalloc, undo failed fallocate.
  */
@@ -1674,6 +1724,48 @@ static ssize_t shmem_file_splice_read(st
 	return error;
 }
 
+static loff_t shmem_file_llseek(struct file *file, loff_t offset, int origin)
+{
+	struct address_space *mapping;
+	struct inode *inode;
+	pgoff_t start, end;
+	loff_t new_offset;
+
+	if (origin != SEEK_DATA && origin != SEEK_HOLE)
+		return generic_file_llseek_size(file, offset, origin,
+							MAX_LFS_FILESIZE);
+	mapping = file->f_mapping;
+	inode = mapping->host;
+	mutex_lock(&inode->i_mutex);
+	/* We're holding i_mutex so we can access i_size directly */
+
+	if (offset < 0)
+		offset = -EINVAL;
+	else if (offset >= inode->i_size)
+		offset = -ENXIO;
+	else {
+		start = offset >> PAGE_CACHE_SHIFT;
+		end = (inode->i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		new_offset = shmem_seek_hole_data(mapping, start, end, origin);
+		new_offset <<= PAGE_CACHE_SHIFT;
+		if (new_offset > offset) {
+			if (new_offset < inode->i_size)
+				offset = new_offset;
+			else if (origin == SEEK_DATA)
+				offset = -ENXIO;
+			else
+				offset = inode->i_size;
+		}
+	}
+
+	if (offset >= 0 && offset != file->f_pos) {
+		file->f_pos = offset;
+		file->f_version = 0;
+	}
+	mutex_unlock(&inode->i_mutex);
+	return offset;
+}
+
 static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 							 loff_t len)
 {
@@ -2667,7 +2759,7 @@ static const struct address_space_operat
 static const struct file_operations shmem_file_operations = {
 	.mmap		= shmem_mmap,
 #ifdef CONFIG_TMPFS
-	.llseek		= generic_file_llseek,
+	.llseek		= shmem_file_llseek,
 	.read		= do_sync_read,
 	.write		= do_sync_write,
 	.aio_read	= shmem_file_aio_read,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
