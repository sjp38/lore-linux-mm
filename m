Message-Id: <20070424013433.778077000@suse.de>
References: <20070424012346.696840000@suse.de>
Date: Tue, 24 Apr 2007 11:23:57 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 11/44] fs: fix data-loss on error
Content-Disposition: inline; filename=fs-dataloss-stop.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Filesystems <linux-fsdevel@vger.kernel.org>, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

New buffers against uptodate pages are simply be marked uptodate, while the
buffer_new bit remains set. This causes error-case code to zero out parts
of those buffers because it thinks they contain stale data: wrong, they
are actually uptodate so this is a data loss situation.

Fix this by actually clearning buffer_new and marking the buffer dirty. It
makes sense to always clear buffer_new before setting a buffer uptodate.

Cc: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Filesystems <linux-fsdevel@vger.kernel.org>
Signed-off-by: Nick Piggin <npiggin@suse.de>

 fs/buffer.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -1800,7 +1800,9 @@ static int __block_prepare_write(struct 
 				unmap_underlying_metadata(bh->b_bdev,
 							bh->b_blocknr);
 				if (PageUptodate(page)) {
+					clear_buffer_new(bh);
 					set_buffer_uptodate(bh);
+					mark_buffer_dirty(bh);
 					continue;
 				}
 				if (block_end > to || block_start < from) {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
