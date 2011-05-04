Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA5366B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 13:44:01 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p44HRHoQ026009
	for <linux-mm@kvack.org>; Wed, 4 May 2011 11:27:17 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p44HhXrf058176
	for <linux-mm@kvack.org>; Wed, 4 May 2011 11:43:33 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p44HgRL5013943
	for <linux-mm@kvack.org>; Wed, 4 May 2011 11:42:28 -0600
Date: Wed, 4 May 2011 10:42:27 -0700
From: "Darrick J. Wong" <djwong@us.ibm.com>
Subject: [PATCH v3 3/3] mm: Wait for writeback when grabbing pages to begin
	a write
Message-ID: <20110504174227.GH20579@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
References: <20110321164305.GC7153@quack.suse.cz> <20110406232938.GF1110@tux1.beaverton.ibm.com> <20110407165700.GB7363@quack.suse.cz> <20110408203135.GH1110@tux1.beaverton.ibm.com> <20110411124229.47bc28f6@corrin.poochiereds.net> <1302543595-sup-4352@think> <1302569212.2580.13.camel@mingming-laptop> <20110412005719.GA23077@infradead.org> <1302742128.2586.274.camel@mingming-laptop> <20110422000226.GA22189@tux1.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110422000226.GA22189@tux1.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jeff Layton <jlayton@redhat.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Joel Becker <jlbec@evilplan.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@kernel.dk>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mingming Cao <mcao@us.ibm.com>, linux-scsi <linux-scsi@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>

When grabbing a page for a buffered IO write, the mm should wait for writeback
on the page to complete so that the page does not become writable during the IO
operation.

Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
---

 mm/filemap.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c641edf..c22675f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2287,8 +2287,10 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 		gfp_notmask = __GFP_FS;
 repeat:
 	page = find_lock_page(mapping, index);
-	if (page)
+	if (page) {
+		wait_on_page_writeback(page);
 		return page;
+	}
 
 	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~gfp_notmask);
 	if (!page)
@@ -2301,6 +2303,7 @@ repeat:
 			goto repeat;
 		return NULL;
 	}
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
