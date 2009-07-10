Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D30966B008C
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 05:10:00 -0400 (EDT)
Date: Fri, 10 Jul 2009 11:33:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/3] fs: buffer_head writepage no invalidate
Message-ID: <20090710093325.GG14666@wotan.suse.de>
References: <20090710073028.782561541@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090710073028.782561541@suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, jack@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

After the previous patchset, this is my progress on the page_mkwrite
thing... These patches are RFC only and have some bugs.
--
invalidate should not be required in the writeout path. The truncate
sequence will first reduce i_size, then clean and discard any existing
pagecache (and no new dirty pagecache can be added because i_size was
reduced and i_mutex is being held), then filesystem data structures
are updated.

Filesystem needs to be able to handle writeout at any point before
the last step, and once the 2nd step completes, there should be no
unfreeable dirty buffers anyway (truncate performs the do_invalidatepage).

Having filesystem changes depend on reading i_size without holding
i_mutex is confusing at least. There is still a case in writepage
paths in buffer.c uses i_size (testing which block to write out), but
this is a small improvement.
---
 fs/buffer.c |   20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2663,18 +2663,8 @@ int nobh_writepage(struct page *page, ge
 	/* Is the page fully outside i_size? (truncate in progress) */
 	offset = i_size & (PAGE_CACHE_SIZE-1);
 	if (page->index >= end_index+1 || !offset) {
-		/*
-		 * The page may have dirty, unmapped buffers.  For example,
-		 * they may have been added in ext3_writepage().  Make them
-		 * freeable here, so the page does not leak.
-		 */
-#if 0
-		/* Not really sure about this  - do we need this ? */
-		if (page->mapping->a_ops->invalidatepage)
-			page->mapping->a_ops->invalidatepage(page, offset);
-#endif
 		unlock_page(page);
-		return 0; /* don't care */
+		return 0;
 	}
 
 	/*
@@ -2867,14 +2857,8 @@ int block_write_full_page_endio(struct p
 	/* Is the page fully outside i_size? (truncate in progress) */
 	offset = i_size & (PAGE_CACHE_SIZE-1);
 	if (page->index >= end_index+1 || !offset) {
-		/*
-		 * The page may have dirty, unmapped buffers.  For example,
-		 * they may have been added in ext3_writepage().  Make them
-		 * freeable here, so the page does not leak.
-		 */
-		do_invalidatepage(page, 0);
 		unlock_page(page);
-		return 0; /* don't care */
+		return 0;
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
