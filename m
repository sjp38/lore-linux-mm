Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A494B82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:47:16 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id 4so106632054pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:47:16 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qx12si13425508pab.169.2016.03.20.11.41.48
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 36/71] fscache: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:43 +0300
Message-Id: <1458499278-1516-37-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Howells <dhowells@redhat.com>

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
Cc: David Howells <dhowells@redhat.com>
---
 fs/fscache/page.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 6b35fc4860a0..3078b679fcd1 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -113,7 +113,7 @@ try_again:
 
 	wake_up_bit(&cookie->flags, 0);
 	if (xpage)
-		page_cache_release(xpage);
+		put_page(xpage);
 	__fscache_uncache_page(cookie, page);
 	return true;
 
@@ -164,7 +164,7 @@ static void fscache_end_page_write(struct fscache_object *object,
 	}
 	spin_unlock(&object->lock);
 	if (xpage)
-		page_cache_release(xpage);
+		put_page(xpage);
 }
 
 /*
@@ -884,7 +884,7 @@ void fscache_invalidate_writes(struct fscache_cookie *cookie)
 		spin_unlock(&cookie->stores_lock);
 
 		for (i = n - 1; i >= 0; i--)
-			page_cache_release(results[i]);
+			put_page(results[i]);
 	}
 
 	_leave("");
@@ -982,7 +982,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 
 	radix_tree_tag_set(&cookie->stores, page->index,
 			   FSCACHE_COOKIE_PENDING_TAG);
-	page_cache_get(page);
+	get_page(page);
 
 	/* we only want one writer at a time, but we do need to queue new
 	 * writers after exclusive ops */
@@ -1026,7 +1026,7 @@ submit_failed:
 	radix_tree_delete(&cookie->stores, page->index);
 	spin_unlock(&cookie->stores_lock);
 	wake_cookie = __fscache_unuse_cookie(cookie);
-	page_cache_release(page);
+	put_page(page);
 	ret = -ENOBUFS;
 	goto nobufs;
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
