Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E21A828F3
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:44:51 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so5706856pad.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:44:51 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id t78si10108463pfi.19.2016.08.12.11.39.00
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:39:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 15/41] filemap: handle huge pages in do_generic_file_read()
Date: Fri, 12 Aug 2016 21:37:58 +0300
Message-Id: <1471027104-115213-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Most of work happans on head page. Only when we need to do copy data to
userspace we find relevant subpage.

We are still limited by PAGE_SIZE per iteration. Lifting this limitation
would require some more work.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index ae1d996fa089..9d7d70b265d4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1860,6 +1860,7 @@ find_page:
 			if (unlikely(page == NULL))
 				goto no_cached_page;
 		}
+		page = compound_head(page);
 		if (PageReadahead(page)) {
 			page_cache_async_readahead(mapping,
 					ra, filp, page,
@@ -1936,7 +1937,8 @@ page_ok:
 		 * now we can copy it to user space...
 		 */
 
-		ret = copy_page_to_iter(page, offset, nr, iter);
+		ret = copy_page_to_iter(page + index - page->index, offset,
+				nr, iter);
 		offset += ret;
 		index += offset >> PAGE_SHIFT;
 		offset &= ~PAGE_MASK;
@@ -2356,6 +2358,7 @@ page_not_uptodate:
 	 * because there really aren't any performance issues here
 	 * and we need to check for errors.
 	 */
+	page = compound_head(page);
 	ClearPageError(page);
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
