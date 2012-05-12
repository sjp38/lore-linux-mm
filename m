Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 6DB6D6B004D
	for <linux-mm@kvack.org>; Sat, 12 May 2012 08:06:07 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5887413dak.14
        for <linux-mm@kvack.org>; Sat, 12 May 2012 05:06:06 -0700 (PDT)
Date: Sat, 12 May 2012 05:05:51 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/10] tmpfs: support fallocate FALLOC_FL_PUNCH_HOLE
In-Reply-To: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205120504230.28861@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

tmpfs has supported hole-punching since 2.6.16, via madvise(,,MADV_REMOVE).
But nowadays fallocate(,FALLOC_FL_PUNCH_HOLE|FALLOC_FL_KEEP_SIZE,,) is the
agreed way to punch holes.

So add shmem_fallocate() to support that, and tweak shmem_truncate_range()
to support partial pages at both the beginning and end of range (never
needed for madvise, which demands rounded addr and rounds up length).

Based-on-patch-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |   68 ++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 57 insertions(+), 11 deletions(-)

--- 3045N.orig/mm/shmem.c	2012-05-05 10:46:12.316062172 -0700
+++ 3045N/mm/shmem.c	2012-05-05 10:46:18.768062321 -0700
@@ -53,6 +53,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/blkdev.h>
 #include <linux/pagevec.h>
 #include <linux/percpu_counter.h>
+#include <linux/falloc.h>
 #include <linux/splice.h>
 #include <linux/security.h>
 #include <linux/swapops.h>
@@ -432,21 +433,23 @@ void shmem_truncate_range(struct inode *
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
 	pgoff_t start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
-	pgoff_t end = (lend >> PAGE_CACHE_SHIFT);
+	pgoff_t end = (lend + 1) >> PAGE_CACHE_SHIFT;
+	unsigned int partial_start = lstart & (PAGE_CACHE_SIZE - 1);
+	unsigned int partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
 	struct pagevec pvec;
 	pgoff_t indices[PAGEVEC_SIZE];
 	long nr_swaps_freed = 0;
 	pgoff_t index;
 	int i;
 
-	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
+	if (lend == -1)
+		end = -1;	/* unsigned, so actually very big */
 
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index <= end) {
+	while (index < end) {
 		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
+				min(end - index, (pgoff_t)PAGEVEC_SIZE),
 							pvec.pages, indices);
 		if (!pvec.nr)
 			break;
@@ -455,7 +458,7 @@ void shmem_truncate_range(struct inode *
 			struct page *page = pvec.pages[i];
 
 			index = indices[i];
-			if (index > end)
+			if (index >= end)
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
@@ -479,22 +482,39 @@ void shmem_truncate_range(struct inode *
 		index++;
 	}
 
-	if (partial) {
+	if (partial_start) {
 		struct page *page = NULL;
 		shmem_getpage(inode, start - 1, &page, SGP_READ, NULL);
 		if (page) {
-			zero_user_segment(page, partial, PAGE_CACHE_SIZE);
+			unsigned int top = PAGE_CACHE_SIZE;
+			if (start > end) {
+				top = partial_end;
+				partial_end = 0;
+			}
+			zero_user_segment(page, partial_start, top);
 			set_page_dirty(page);
 			unlock_page(page);
 			page_cache_release(page);
 		}
 	}
+	if (partial_end) {
+		struct page *page = NULL;
+		shmem_getpage(inode, end, &page, SGP_READ, NULL);
+		if (page) {
+			zero_user_segment(page, 0, partial_end);
+			set_page_dirty(page);
+			unlock_page(page);
+			page_cache_release(page);
+		}
+	}
+	if (start >= end)
+		return;
 
 	index = start;
 	for ( ; ; ) {
 		cond_resched();
 		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
+				min(end - index, (pgoff_t)PAGEVEC_SIZE),
 							pvec.pages, indices);
 		if (!pvec.nr) {
 			if (index == start)
@@ -502,7 +522,7 @@ void shmem_truncate_range(struct inode *
 			index = start;
 			continue;
 		}
-		if (index == start && indices[0] > end) {
+		if (index == start && indices[0] >= end) {
 			shmem_deswap_pagevec(&pvec);
 			pagevec_release(&pvec);
 			break;
@@ -512,7 +532,7 @@ void shmem_truncate_range(struct inode *
 			struct page *page = pvec.pages[i];
 
 			index = indices[i];
-			if (index > end)
+			if (index >= end)
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
@@ -1578,6 +1598,31 @@ static ssize_t shmem_file_splice_read(st
 	return error;
 }
 
+static long shmem_fallocate(struct file *file, int mode, loff_t offset,
+							 loff_t len)
+{
+	struct inode *inode = file->f_path.dentry->d_inode;
+	int error = -EOPNOTSUPP;
+
+	mutex_lock(&inode->i_mutex);
+
+	if (mode & FALLOC_FL_PUNCH_HOLE) {
+		struct address_space *mapping = file->f_mapping;
+		loff_t unmap_start = round_up(offset, PAGE_SIZE);
+		loff_t unmap_end = round_down(offset + len, PAGE_SIZE) - 1;
+
+		if ((u64)unmap_end > (u64)unmap_start)
+			unmap_mapping_range(mapping, unmap_start,
+					    1 + unmap_end - unmap_start, 0);
+		shmem_truncate_range(inode, offset, offset + len - 1);
+		/* No need to unmap again: hole-punching leaves COWed pages */
+		error = 0;
+	}
+
+	mutex_unlock(&inode->i_mutex);
+	return error;
+}
+
 static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	struct shmem_sb_info *sbinfo = SHMEM_SB(dentry->d_sb);
@@ -2478,6 +2523,7 @@ static const struct file_operations shme
 	.fsync		= noop_fsync,
 	.splice_read	= shmem_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.fallocate	= shmem_fallocate,
 #endif
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
