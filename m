Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6182482F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:37 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id n5so237575572pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:37 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wb2si13830644pab.213.2016.03.20.11.41.50
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 49/71] ncpfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:56 +0300
Message-Id: <1458499278-1516-50-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Petr Vandrovec <petr@vandrovec.name>

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
Cc: Petr Vandrovec <petr@vandrovec.name>
---
 fs/ncpfs/dir.c           | 10 +++++-----
 fs/ncpfs/ncplib_kernel.h |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/ncpfs/dir.c b/fs/ncpfs/dir.c
index b7f8eaeea5d8..bfdad003ee56 100644
--- a/fs/ncpfs/dir.c
+++ b/fs/ncpfs/dir.c
@@ -510,7 +510,7 @@ static int ncp_readdir(struct file *file, struct dir_context *ctx)
 			kunmap(ctl.page);
 			SetPageUptodate(ctl.page);
 			unlock_page(ctl.page);
-			page_cache_release(ctl.page);
+			put_page(ctl.page);
 			ctl.page = NULL;
 		}
 		ctl.idx  = 0;
@@ -520,7 +520,7 @@ invalid_cache:
 	if (ctl.page) {
 		kunmap(ctl.page);
 		unlock_page(ctl.page);
-		page_cache_release(ctl.page);
+		put_page(ctl.page);
 		ctl.page = NULL;
 	}
 	ctl.cache = cache;
@@ -554,14 +554,14 @@ finished:
 		kunmap(ctl.page);
 		SetPageUptodate(ctl.page);
 		unlock_page(ctl.page);
-		page_cache_release(ctl.page);
+		put_page(ctl.page);
 	}
 	if (page) {
 		cache->head = ctl.head;
 		kunmap(page);
 		SetPageUptodate(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 out:
 	return result;
@@ -649,7 +649,7 @@ ncp_fill_cache(struct file *file, struct dir_context *ctx,
 			kunmap(ctl.page);
 			SetPageUptodate(ctl.page);
 			unlock_page(ctl.page);
-			page_cache_release(ctl.page);
+			put_page(ctl.page);
 		}
 		ctl.cache = NULL;
 		ctl.idx  -= NCP_DIRCACHE_SIZE;
diff --git a/fs/ncpfs/ncplib_kernel.h b/fs/ncpfs/ncplib_kernel.h
index 5233fbc1747a..17cfb743b5bf 100644
--- a/fs/ncpfs/ncplib_kernel.h
+++ b/fs/ncpfs/ncplib_kernel.h
@@ -191,7 +191,7 @@ struct ncp_cache_head {
 	int		eof;
 };
 
-#define NCP_DIRCACHE_SIZE	((int)(PAGE_CACHE_SIZE/sizeof(struct dentry *)))
+#define NCP_DIRCACHE_SIZE	((int)(PAGE_SIZE/sizeof(struct dentry *)))
 union ncp_dir_cache {
 	struct ncp_cache_head	head;
 	struct dentry		*dentry[NCP_DIRCACHE_SIZE];
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
