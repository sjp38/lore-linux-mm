Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 992BA828F4
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:29 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id n5so237454672pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:29 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id v81si1985562pfa.20.2016.03.20.11.42.15
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:42:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 66/71] hugetlb: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:13 +0300
Message-Id: <1458499278-1516-67-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
---
 fs/hugetlbfs/inode.c | 10 +++++-----
 mm/hugetlb.c         |  8 ++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index e1f465a389d5..4ea71eba40a5 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -213,12 +213,12 @@ hugetlbfs_read_actor(struct page *page, unsigned long offset,
 	int i, chunksize;
 
 	/* Find which 4k chunk and offset with in that chunk */
-	i = offset >> PAGE_CACHE_SHIFT;
-	offset = offset & ~PAGE_CACHE_MASK;
+	i = offset >> PAGE_SHIFT;
+	offset = offset & ~PAGE_MASK;
 
 	while (size) {
 		size_t n;
-		chunksize = PAGE_CACHE_SIZE;
+		chunksize = PAGE_SIZE;
 		if (offset)
 			chunksize -= offset;
 		if (chunksize > size)
@@ -237,7 +237,7 @@ hugetlbfs_read_actor(struct page *page, unsigned long offset,
 /*
  * Support for read() - Find the page attached to f_mapping and copy out the
  * data. Its *very* similar to do_generic_mapping_read(), we can't use that
- * since it has PAGE_CACHE_SIZE assumptions.
+ * since it has PAGE_SIZE assumptions.
  */
 static ssize_t hugetlbfs_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
@@ -285,7 +285,7 @@ static ssize_t hugetlbfs_read_iter(struct kiocb *iocb, struct iov_iter *to)
 			 * We have the page, copy it to user space buffer.
 			 */
 			copied = hugetlbfs_read_actor(page, offset, to, nr);
-			page_cache_release(page);
+			put_page(page);
 		}
 		offset += copied;
 		retval += copied;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 06058eaa173b..19d0d08b396f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3346,7 +3346,7 @@ retry_avoidcopy:
 			old_page != pagecache_page)
 		outside_reserve = 1;
 
-	page_cache_get(old_page);
+	get_page(old_page);
 
 	/*
 	 * Drop page table lock as buddy allocator may be called. It will
@@ -3364,7 +3364,7 @@ retry_avoidcopy:
 		 * may get SIGKILLed if it later faults.
 		 */
 		if (outside_reserve) {
-			page_cache_release(old_page);
+			put_page(old_page);
 			BUG_ON(huge_pte_none(pte));
 			unmap_ref_private(mm, vma, old_page, address);
 			BUG_ON(huge_pte_none(pte));
@@ -3425,9 +3425,9 @@ retry_avoidcopy:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 out_release_all:
-	page_cache_release(new_page);
+	put_page(new_page);
 out_release_old:
-	page_cache_release(old_page);
+	put_page(old_page);
 
 	spin_lock(ptl); /* Caller expects lock to be held */
 	return ret;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
