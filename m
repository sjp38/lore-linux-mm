Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE39828DF
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:17 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id x3so237457807pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:17 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id v13si13849828pas.199.2016.03.20.11.41.52
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 62/71] udf: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:09 +0300
Message-Id: <1458499278-1516-63-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>

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
Cc: Jan Kara <jack@suse.com>
---
 fs/udf/file.c  | 6 +++---
 fs/udf/inode.c | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/udf/file.c b/fs/udf/file.c
index 1af98963d860..877ba1c9b461 100644
--- a/fs/udf/file.c
+++ b/fs/udf/file.c
@@ -46,7 +46,7 @@ static void __udf_adinicb_readpage(struct page *page)
 
 	kaddr = kmap(page);
 	memcpy(kaddr, iinfo->i_ext.i_data + iinfo->i_lenEAttr, inode->i_size);
-	memset(kaddr + inode->i_size, 0, PAGE_CACHE_SIZE - inode->i_size);
+	memset(kaddr + inode->i_size, 0, PAGE_SIZE - inode->i_size);
 	flush_dcache_page(page);
 	SetPageUptodate(page);
 	kunmap(page);
@@ -87,14 +87,14 @@ static int udf_adinicb_write_begin(struct file *file,
 {
 	struct page *page;
 
-	if (WARN_ON_ONCE(pos >= PAGE_CACHE_SIZE))
+	if (WARN_ON_ONCE(pos >= PAGE_SIZE))
 		return -EIO;
 	page = grab_cache_page_write_begin(mapping, 0, flags);
 	if (!page)
 		return -ENOMEM;
 	*pagep = page;
 
-	if (!PageUptodate(page) && len != PAGE_CACHE_SIZE)
+	if (!PageUptodate(page) && len != PAGE_SIZE)
 		__udf_adinicb_readpage(page);
 	return 0;
 }
diff --git a/fs/udf/inode.c b/fs/udf/inode.c
index 166d3ed32c39..2dc461eeb415 100644
--- a/fs/udf/inode.c
+++ b/fs/udf/inode.c
@@ -287,7 +287,7 @@ int udf_expand_file_adinicb(struct inode *inode)
 	if (!PageUptodate(page)) {
 		kaddr = kmap(page);
 		memset(kaddr + iinfo->i_lenAlloc, 0x00,
-		       PAGE_CACHE_SIZE - iinfo->i_lenAlloc);
+		       PAGE_SIZE - iinfo->i_lenAlloc);
 		memcpy(kaddr, iinfo->i_ext.i_data + iinfo->i_lenEAttr,
 			iinfo->i_lenAlloc);
 		flush_dcache_page(page);
@@ -319,7 +319,7 @@ int udf_expand_file_adinicb(struct inode *inode)
 		inode->i_data.a_ops = &udf_adinicb_aops;
 		up_write(&iinfo->i_data_sem);
 	}
-	page_cache_release(page);
+	put_page(page);
 	mark_inode_dirty(inode);
 
 	return err;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
