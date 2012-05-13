Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 2242E6B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 16:47:22 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7628575pbb.14
        for <linux-mm@kvack.org>; Sun, 13 May 2012 13:47:21 -0700 (PDT)
Date: Sun, 13 May 2012 13:47:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] ext4: hole-punch use truncate_pagecache_range
Message-ID: <alpine.LSU.2.00.1205131342420.1547@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

When truncating a file, we unmap pages from userspace first, as that's
usually more efficient than relying, page by page, on the fallback in
truncate_inode_page() - particularly if the file is mapped many times.

Do the same when punching a hole: 3.4 added truncate_pagecache_range()
to do the unmap and trunc, so use it in ext4_ext_punch_hole(), instead
of calling truncate_inode_pages_range() directly.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 fs/ext4/extents.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- next-20120511/fs/ext4/extents.c	2012-05-11 00:22:26.011158147 -0700
+++ linux/fs/ext4/extents.c	2012-05-12 18:01:14.988654723 -0700
@@ -4789,8 +4789,8 @@ int ext4_ext_punch_hole(struct file *fil
 
 	/* Now release the pages */
 	if (last_page_offset > first_page_offset) {
-		truncate_inode_pages_range(mapping, first_page_offset,
-					   last_page_offset-1);
+		truncate_pagecache_range(inode, first_page_offset,
+					 last_page_offset - 1);
 	}
 
 	/* finish any pending end_io work */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
