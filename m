Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A70B28024B
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n24so89446204pfb.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y81si33438682pfb.247.2016.09.15.04.55.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:40 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 15/41] filemap: handle huge pages in do_generic_file_read()
Date: Thu, 15 Sep 2016 14:54:57 +0300
Message-Id: <20160915115523.29737-16-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
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
index 50afe17230e7..b77bcf6843ee 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
