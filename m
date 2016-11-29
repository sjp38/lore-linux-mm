Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48AC66B027D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:57 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so421899479pgc.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:57 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 59si30847614plp.46.2016.11.29.03.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:56 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 08/36] filemap: handle huge pages in do_generic_file_read()
Date: Tue, 29 Nov 2016 14:22:36 +0300
Message-Id: <20161129112304.90056-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
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
index 74341f8b831e..6a2f9ea521fb 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1749,6 +1749,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 			if (unlikely(page == NULL))
 				goto no_cached_page;
 		}
+		page = compound_head(page);
 		if (PageReadahead(page)) {
 			page_cache_async_readahead(mapping,
 					ra, filp, page,
@@ -1830,7 +1831,8 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 		 * now we can copy it to user space...
 		 */
 
-		ret = copy_page_to_iter(page, offset, nr, iter);
+		ret = copy_page_to_iter(page + index - page->index, offset,
+				nr, iter);
 		offset += ret;
 		index += offset >> PAGE_SHIFT;
 		offset &= ~PAGE_MASK;
@@ -2248,6 +2250,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 * because there really aren't any performance issues here
 	 * and we need to check for errors.
 	 */
+	page = compound_head(page);
 	ClearPageError(page);
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
