Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7066B003D
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 20:13:38 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so118330pdj.2
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:13:37 -0700 (PDT)
Received: by mail-pb0-f49.google.com with SMTP id xb12so80301pbc.8
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:13:35 -0700 (PDT)
Date: Mon, 14 Oct 2013 17:13:31 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCH 09/12] mm, thp, tmpfs: huge page support in shmem_fallocate
Message-ID: <20131015001331.GJ3432@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

Try to allocate huge page if the range fits, otherwise,
fall back to small pages.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 7065ae5..cbf01ce 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2179,8 +2179,11 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 	inode->i_private = &shmem_falloc;
 	spin_unlock(&inode->i_lock);
 
-	for (index = start; index < end; index++) {
+	i_split_down_read(inode);
+	index = start;
+	while (index < end) {
 		struct page *page;
+		int nr = 1;
 
 		/*
 		 * Good, the fallocate(2) manpage permits EINTR: we may have
@@ -2192,8 +2195,16 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 			error = -ENOMEM;
 		else {
 			gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
+			int flags = 0;
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+			if ((index == (index & ~HPAGE_CACHE_INDEX_MASK)) &&
+			    (index != (end & ~HPAGE_CACHE_INDEX_MASK)))
+				flags |= AOP_FLAG_TRANSHUGE;
+#endif
+
 			error = shmem_getpage(inode, index, &page, SGP_FALLOC,
-					      gfp, 0, NULL);
+					      gfp, flags, NULL);
 		}
 		if (error) {
 			/* Remove the !PageUptodate pages we added */
@@ -2203,13 +2214,18 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 			goto undone;
 		}
 
+		nr = hpagecache_nr_pages(page);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+		if (PageTransHugeCache(page))
+			index &= ~HPAGE_CACHE_INDEX_MASK;
+#endif
 		/*
 		 * Inform shmem_writepage() how far we have reached.
 		 * No need for lock or barrier: we have the page lock.
 		 */
-		shmem_falloc.next++;
+		shmem_falloc.next += nr;
 		if (!PageUptodate(page))
-			shmem_falloc.nr_falloced++;
+			shmem_falloc.nr_falloced += nr;
 
 		/*
 		 * If !PageUptodate, leave it that way so that freeable pages
@@ -2222,6 +2238,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		unlock_page(page);
 		page_cache_release(page);
 		cond_resched();
+		index += nr;
 	}
 
 	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
@@ -2232,7 +2249,9 @@ undone:
 	inode->i_private = NULL;
 	spin_unlock(&inode->i_lock);
 out:
+	i_split_up_read(inode);
 	mutex_unlock(&inode->i_mutex);
+
 	return error;
 }
 
-- 
1.8.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
