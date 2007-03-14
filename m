Date: Wed, 14 Mar 2007 13:15:43 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/2] splice: dont readpage
Message-ID: <20070314121543.GB926@wotan.suse.de>
References: <20070314121440.GA926@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070314121440.GA926@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Splice does not need to readpage to bring the page uptodate before writing
to it, because prepare_write will take care of that for us.

Splice is also wrong to SetPageUptodate before the page is actually uptodate.
This results in the old uninitialised memory leak. This gets fixed as a
matter of course when removing the readpage logic.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -593,36 +593,6 @@ find_page:
 			goto out;
 	}
 
-	/*
-	 * We get here with the page locked. If the page is also
-	 * uptodate, we don't need to do more. If it isn't, we
-	 * may need to bring it in if we are not going to overwrite
-	 * the full page.
-	 */
-	if (!PageUptodate(page)) {
-		if (this_len < PAGE_CACHE_SIZE) {
-			ret = mapping->a_ops->readpage(file, page);
-			if (unlikely(ret))
-				goto out;
-
-			lock_page(page);
-
-			if (!PageUptodate(page)) {
-				/*
-				 * Page got invalidated, repeat.
-				 */
-				if (!page->mapping) {
-					unlock_page(page);
-					page_cache_release(page);
-					goto find_page;
-				}
-				ret = -EIO;
-				goto out;
-			}
-		} else
-			SetPageUptodate(page);
-	}
-
 	ret = mapping->a_ops->prepare_write(file, page, offset, offset+this_len);
 	if (unlikely(ret)) {
 		loff_t isize = i_size_read(mapping->host);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
