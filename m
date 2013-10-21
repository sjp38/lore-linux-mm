Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 031956B035E
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 17:48:23 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so7590852pbc.4
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:48:23 -0700 (PDT)
Received: from psmtp.com ([74.125.245.119])
        by mx.google.com with SMTP id ph6si9639159pbb.217.2013.10.21.14.48.22
        for <linux-mm@kvack.org>;
        Mon, 21 Oct 2013 14:48:23 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so8667582pab.39
        for <linux-mm@kvack.org>; Mon, 21 Oct 2013 14:48:21 -0700 (PDT)
Date: Mon, 21 Oct 2013 14:48:17 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCHv2 10/13] mm, thp, tmpfs: huge page support in shmem_fallocate
Message-ID: <20131021214817.GK29870@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>, Ning Qu <quning@gmail.com>

Try to allocate huge page if the range fits, otherwise,
fall back to small pages.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 1764a29..48b1d84 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2156,8 +2156,11 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
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
@@ -2169,8 +2172,15 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 			error = -ENOMEM;
 		else {
 			gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
+			int flags = 0;
+
+			if (mapping_can_have_hugepages(inode->i_mapping) &&
+			    ((index == (index & ~HPAGE_CACHE_INDEX_MASK)) &&
+			     (index != (end & ~HPAGE_CACHE_INDEX_MASK))))
+				flags |= AOP_FLAG_TRANSHUGE;
+
 			error = shmem_getpage(inode, index, &page, SGP_FALLOC,
-					      gfp, 0, NULL);
+					      gfp, flags, NULL);
 		}
 		if (error) {
 			/* Remove the !PageUptodate pages we added */
@@ -2180,13 +2190,16 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 			goto undone;
 		}
 
+		nr = hpagecache_nr_pages(page);
+		if (PageTransHugeCache(page))
+			index &= ~HPAGE_CACHE_INDEX_MASK;
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
@@ -2199,6 +2212,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		unlock_page(page);
 		page_cache_release(page);
 		cond_resched();
+		index += nr;
 	}
 
 	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
@@ -2209,7 +2223,9 @@ undone:
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
