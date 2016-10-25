Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBC906B0264
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:13 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id gg9so20166483pac.6
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:13 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p187si17912762pfg.145.2016.10.24.17.14.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 14/43] filemap: handle huge pages in do_generic_file_read()
Date: Tue, 25 Oct 2016 03:13:13 +0300
Message-Id: <20161025001342.76126-15-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
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
index f8387488636f..ca4536f2035e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1906,6 +1906,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 			if (unlikely(page == NULL))
 				goto no_cached_page;
 		}
+		page = compound_head(page);
 		if (PageReadahead(page)) {
 			page_cache_async_readahead(mapping,
 					ra, filp, page,
@@ -1984,7 +1985,8 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 		 * now we can copy it to user space...
 		 */
 
-		ret = copy_page_to_iter(page, offset, nr, iter);
+		ret = copy_page_to_iter(page + index - page->index, offset,
+				nr, iter);
 		offset += ret;
 		index += offset >> PAGE_SHIFT;
 		offset &= ~PAGE_MASK;
@@ -2402,6 +2404,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
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
