Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 855A26B003A
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:06:15 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so3514616pab.29
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:06:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 15/22] thp, mm: naive support of thp in generic_perform_write
Date: Mon, 23 Sep 2013 15:05:43 +0300
Message-Id: <1379937950-8411-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now we still write/read at most PAGE_CACHE_SIZE bytes a time.

This implementation doesn't cover address spaces with backing storage.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 410879a801..38d6856737 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2384,12 +2384,14 @@ static ssize_t generic_perform_write(struct file *file,
 	if (segment_eq(get_fs(), KERNEL_DS))
 		flags |= AOP_FLAG_UNINTERRUPTIBLE;
 
+	i_split_down_read(mapping->host);
 	do {
 		struct page *page;
 		unsigned long offset;	/* Offset into pagecache page */
 		unsigned long bytes;	/* Bytes to write to page */
 		size_t copied;		/* Bytes copied from user */
 		void *fsdata;
+		int subpage_nr = 0;
 
 		offset = (pos & (PAGE_CACHE_SIZE - 1));
 		bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
@@ -2419,8 +2421,14 @@ again:
 		if (mapping_writably_mapped(mapping))
 			flush_dcache_page(page);
 
+		if (PageTransHuge(page)) {
+			off_t huge_offset = pos & ~HPAGE_PMD_MASK;
+			subpage_nr = huge_offset >> PAGE_CACHE_SHIFT;
+		}
+
 		pagefault_disable();
-		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
+		copied = iov_iter_copy_from_user_atomic(page + subpage_nr, i,
+				offset, bytes);
 		pagefault_enable();
 		flush_dcache_page(page);
 
@@ -2457,6 +2465,7 @@ again:
 		}
 	} while (iov_iter_count(i));
 
+	i_split_up_read(mapping->host);
 	return written ? written : status;
 }
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
