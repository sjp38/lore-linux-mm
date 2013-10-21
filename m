Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9186B035C
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 17:48:10 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so9206300pdj.17
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:48:09 -0700 (PDT)
Received: from psmtp.com ([74.125.245.194])
        by mx.google.com with SMTP id zl9si9672813pbc.24.2013.10.21.14.48.08
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 14:48:09 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so8708341pab.11
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:48:07 -0700 (PDT)
Date: Mon, 21 Oct 2013 14:48:03 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCHv2 09/13] mm, thp, tmpfs: huge page support in
 do_shmem_file_read
Message-ID: <20131021214803.GJ29870@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>, Ning Qu <quning@gmail.com>

Support huge page in do_shmem_file_read when possible.

Still have room to improve, since we re-search the page in
page cache everytime, but for huge page, we might save some
searches and reuse the huge page for the next read across
page boundary.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 47 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 33 insertions(+), 14 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index f6829fd..1764a29 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1747,13 +1747,25 @@ shmem_write_end(struct file *file, struct address_space *mapping,
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
@@ -1765,25 +1777,26 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 		sgp = SGP_DIRTY;
 
 	index = *ppos >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
 
+	i_split_down_read(inode);
 	for (;;) {
 		struct page *page = NULL;
 		pgoff_t end_index;
 		unsigned long nr, ret;
 		loff_t i_size = i_size_read(inode);
+		int flags = AOP_FLAG_TRANSHUGE;
 
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
@@ -1796,18 +1809,25 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 		 * We must evaluate after, since reads (unlike writes)
 		 * are called without i_mutex protection against truncate
 		 */
-		nr = PAGE_CACHE_SIZE;
 		i_size = i_size_read(inode);
 		end_index = i_size >> PAGE_CACHE_SHIFT;
+
+		nr = PAGE_CACHE_SIZE;
+		if (page && PageTransHugeCache(page)) {
+			index &= ~HPAGE_CACHE_INDEX_MASK;
+			end_index &= ~HPAGE_CACHE_INDEX_MASK;
+			nr = PAGE_CACHE_SIZE << compound_order(page);
+		}
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
@@ -1820,7 +1840,7 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 			/*
 			 * Mark the page accessed if we read the beginning.
 			 */
-			if (!offset)
+			if (!pos_to_off(page, *ppos))
 				mark_page_accessed(page);
 		} else {
 			page = ZERO_PAGE(0);
@@ -1837,10 +1857,9 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
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
@@ -1849,7 +1868,7 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
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
