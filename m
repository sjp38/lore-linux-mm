Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA3036B01F5
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 12:17:24 -0400 (EDT)
Message-Id: <20100428161713.971813259@szeredi.hu>
References: <20100428161636.272097923@szeredi.hu>
Date: Wed, 28 Apr 2010 18:16:40 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [RFC PATCH 4/6] fuse: get page reference for readpages
Content-Disposition: inline; filename=fuse-get-page-ref-for-readpages.patch
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Acquire a page ref on pages in ->readpages() and release them when the
read has finished.  Not acquiring a reference didn't seem to cause any
trouble since the page is locked and will not be kicked out of the
page cache during the read.

However the following patches will want to remove the page from the
cache so a separate ref is needed.  Making the reference in req->pages
explicit also makes the code easier to understand.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/file.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/fs/fuse/file.c
===================================================================
--- linux-2.6.orig/fs/fuse/file.c	2010-04-28 15:50:32.000000000 +0200
+++ linux-2.6/fs/fuse/file.c	2010-04-28 15:50:35.000000000 +0200
@@ -536,6 +536,7 @@ static void fuse_readpages_end(struct fu
 		else
 			SetPageError(page);
 		unlock_page(page);
+		page_cache_release(page);
 	}
 	if (req->ff)
 		fuse_file_put(req->ff);
@@ -589,6 +590,7 @@ static int fuse_readpages_fill(void *_da
 			return PTR_ERR(req);
 		}
 	}
+	page_cache_get(page);
 	req->pages[req->num_pages] = page;
 	req->num_pages++;
 	return 0;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
