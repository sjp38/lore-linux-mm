Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 229A16B0011
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:03:44 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p49Muaem027586
	for <linux-mm@kvack.org>; Mon, 9 May 2011 16:56:36 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p49N3UOF095340
	for <linux-mm@kvack.org>; Mon, 9 May 2011 17:03:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p49H327A009640
	for <linux-mm@kvack.org>; Mon, 9 May 2011 11:03:03 -0600
Subject: [PATCH 1/7] mm: Wait for writeback when grabbing pages to begin a
	write
From: "Darrick J. Wong" <djwong@us.ibm.com>
Date: Mon, 09 May 2011 16:03:26 -0700
Message-ID: <20110509230326.19566.16027.stgit@elm3c44.beaverton.ibm.com>
In-Reply-To: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

When grabbing a page for a buffered IO write, the mm should wait for writeback
on the page to complete so that the page does not become writable during the IO
operation.  This change is needed to provide page stability during writes for
all filesystems.

Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
---
 mm/filemap.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)


diff --git a/mm/filemap.c b/mm/filemap.c
index c641edf..fd0e7f2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2288,7 +2288,7 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 repeat:
 	page = find_lock_page(mapping, index);
 	if (page)
-		return page;
+		goto found;
 
 	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~gfp_notmask);
 	if (!page)
@@ -2301,6 +2301,8 @@ repeat:
 			goto repeat;
 		return NULL;
 	}
+found:
+	wait_on_page_writeback(page);
 	return page;
 }
 EXPORT_SYMBOL(grab_cache_page_write_begin);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
