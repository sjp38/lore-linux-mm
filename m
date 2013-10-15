Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 74C806B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 20:13:27 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so8013981pbc.12
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:13:27 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so8206235pab.38
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:13:24 -0700 (PDT)
Date: Mon, 14 Oct 2013 17:13:20 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCH 08/12] mm, thp, tmpfs: huge page support in do_shmem_file_read
Message-ID: <20131015001320.GI3432@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

Support huge page in do_shmem_file_read when possible.

Still have room to improve, since we re-search the page in
page cache everytime, but for huge page, we might save some
searches and reuse the huge page for the next read across
page boundary.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 52 ++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 38 insertions(+), 14 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 90f2e0e..7065ae5 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1765,13 +1765,25 @@ shmem_write_end(struct file *file, struct address_space *mapping,
 	return copied;
 }
 
+static unsigned long page_cache_to_mask(struct page *page)
+{
+	if (page && PageTransHugeCache(page))
+		return HPAGE_PMD_MASK;
+	else
+		return PAGE_CACHE_MASK;
+}
+
+static unsigned long pos_to_off(struct page *page, loff_t pos)
+{
+	return pos & ~page_cache_to_mask(page);
+}
+
 static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_t *desc, read_actor_t actor)
 {
 	struct inode *inode = file_inode(filp);
 	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
 	struct address_space *mapping = inode->i_mapping;
 	pgoff_t index;
-	unsigned long offset;
 	enum sgp_type sgp = SGP_READ;
 
 	/*
@@ -1783,25 +1795,29 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 		sgp = SGP_DIRTY;
 
 	index = *ppos >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
 
+	i_split_down_read(inode);
 	for (;;) {
 		struct page *page = NULL;
 		pgoff_t end_index;
 		unsigned long nr, ret;
 		loff_t i_size = i_size_read(inode);
+		int flags = 0;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+		flags |= AOP_FLAG_TRANSHUGE;
+#endif
 
 		end_index = i_size >> PAGE_CACHE_SHIFT;
 		if (index > end_index)
 			break;
 		if (index == end_index) {
 			nr = i_size & ~PAGE_CACHE_MASK;
-			if (nr <= offset)
+			if (nr <= pos_to_off(page, *ppos))
 				break;
 		}
 
 		desc->error = shmem_getpage(inode, index, &page, sgp, gfp,
-						0, NULL);
+					flags, NULL);
 		if (desc->error) {
 			if (desc->error == -EINVAL)
 				desc->error = 0;
@@ -1814,18 +1830,27 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 		 * We must evaluate after, since reads (unlike writes)
 		 * are called without i_mutex protection against truncate
 		 */
-		nr = PAGE_CACHE_SIZE;
 		i_size = i_size_read(inode);
 		end_index = i_size >> PAGE_CACHE_SHIFT;
+
+		nr = PAGE_CACHE_SIZE;
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+		if (page && PageTransHugeCache(page)) {
+			index &= ~HPAGE_CACHE_INDEX_MASK;
+			end_index &= ~HPAGE_CACHE_INDEX_MASK;
+			nr = PAGE_CACHE_SIZE << compound_order(page);
+		}
+#endif
+
 		if (index == end_index) {
-			nr = i_size & ~PAGE_CACHE_MASK;
-			if (nr <= offset) {
+			nr = ((i_size - 1) & ~page_cache_to_mask(page)) + 1;
+			if (nr <= pos_to_off(page, *ppos)) {
 				if (page)
 					page_cache_release(page);
 				break;
 			}
 		}
-		nr -= offset;
+		nr = nr - pos_to_off(page, *ppos);
 
 		if (page) {
 			/*
@@ -1838,7 +1863,7 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 			/*
 			 * Mark the page accessed if we read the beginning.
 			 */
-			if (!offset)
+			if (!pos_to_off(page, *ppos))
 				mark_page_accessed(page);
 		} else {
 			page = ZERO_PAGE(0);
@@ -1855,10 +1880,9 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 		 * "pos" here (the actor routine has to update the user buffer
 		 * pointers and the remaining count).
 		 */
-		ret = actor(desc, page, offset, nr);
-		offset += ret;
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
+		ret = actor(desc, page, pos_to_off(page, *ppos), nr);
+		*ppos += ret;
+		index = *ppos >> PAGE_CACHE_SHIFT;
 
 		page_cache_release(page);
 		if (ret != nr || !desc->count)
@@ -1867,7 +1891,7 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 		cond_resched();
 	}
 
-	*ppos = ((loff_t) index << PAGE_CACHE_SHIFT) + offset;
+	i_split_up_read(inode);
 	file_accessed(filp);
 }
 
-- 
1.8.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
