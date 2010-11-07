Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9123E6B0092
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 08:38:02 -0500 (EST)
Date: Sun, 7 Nov 2010 21:37:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: Avoid livelocking of WB_SYNC_ALL writeback
Message-ID: <20101107133745.GA12009@localhost>
References: <1288992383-25475-1-git-send-email-jack@suse.cz>
 <20101106041202.GA15411@localhost>
 <20101107132204.GC5126@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101107132204.GC5126@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 07, 2010 at 09:22:04PM +0800, Jan Kara wrote:
> On Sat 06-11-10 12:12:02, Wu Fengguang wrote:
> > On Sat, Nov 06, 2010 at 05:26:23AM +0800, Jan Kara wrote:
> > 
> > > +	/*
> > > +	 * In WB_SYNC_ALL mode, we just want to ignore nr_to_write as
> > > +	 * we need to write everything and livelock avoidance is implemented
> > > +	 * differently.
> > > +	 */
> > > +	if (wbc.sync_mode == WB_SYNC_NONE)
> > > +		write_chunk = MAX_WRITEBACK_PAGES;
> > > +	else
> > > +		write_chunk = LONG_MAX;
> > 
> > This looks like a safe change for .37.  I updated the patch on the
> > above comment and made no other changes (it seems OK to also remove
> > the below line, however that's not the necessary change as a bug fix,
> > so I'd rather leave the extra change to the next merge window).
> > write_cache_pages():
> > 
> > -->                     /*
> > -->                      * We stop writing back only if we are not doing
> > -->                      * integrity sync. In case of integrity sync we have to
> > -->                      * keep going until we have written all the pages
> > -->                      * we tagged for writeback prior to entering this loop.
> > -->                      */
> >                         if (--wbc->nr_to_write <= 0 &&
> > ==>                         wbc->sync_mode == WB_SYNC_NONE) {
> >                                 done = 1;
> >                                 break;
>   Well, I'd rather leave the test as is. In fact, in my mind-model the
> target rather is to completely ignore nr_to_write when we do WB_SYNC_ALL
> writeback since obeying it is never what a caller wants to happen...

I thought (nr_to_write = LONG_MAX) effectively means to complete
ignore it. But whatever, it's not a big issue.

> > +	/*
> > +	 * WB_SYNC_ALL mode does livelock avoidance by syncing dirty
> > +	 * inodes/pages in one big loop. Setting wbc.nr_to_write=LONG_MAX
> > +	 * here avoids calling into writeback_inodes_wb() more than once.
>   Maybe I'd add here:
> The intended call sequence for WB_SYNC_ALL writeback is:

Good addition.  Here is the updated patch.

Thanks,
Fengguang

---
writeback: avoid livelocking WB_SYNC_ALL writeback

From: Jan Kara <jack@suse.cz>

When wb_writeback() is called in WB_SYNC_ALL mode, work->nr_to_write is
usually set to LONG_MAX. The logic in wb_writeback() then calls
__writeback_inodes_sb() with nr_to_write == MAX_WRITEBACK_PAGES and thus
we easily end up with negative nr_to_write after the function returns.
wb_writeback() then decides we need another round of writeback but this
is wrong in some cases! For example when a single large file is
continuously dirtied, we would never finish syncing it because each pass
would be able to write MAX_WRITEBACK_PAGES and inode dirty timestamp
never gets updated (as inode is never completely clean).

Fix the issue by setting nr_to_write to LONG_MAX in WB_SYNC_ALL mode. We
do not need nr_to_write in WB_SYNC_ALL mode anyway since livelock
avoidance is done differently for it.

After this patch, program from http://lkml.org/lkml/2010/10/24/154 is no
longer able to stall sync forever.

Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

  Fengguang, I've been testing with those writeback fixes you reposted
a few days ago and I've been able to still reproduce livelocks with
Jan Engelhard's test case. Using writeback tracing I've tracked the
problem to the above and with this patch, sync finishes OK (well, it still
takes about 15 minutes but that's about expected time given the throughput
I see to the disk - the test case randomly dirties pages in a huge file).
So could you please add this patch to the previous two send them to Jens
for inclusion?

--- linux-next.orig/fs/fs-writeback.c	2010-11-06 23:55:35.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-07 21:34:35.000000000 +0800
@@ -630,6 +630,7 @@ static long wb_writeback(struct bdi_writ
 	};
 	unsigned long oldest_jif;
 	long wrote = 0;
+	long write_chunk;
 	struct inode *inode;
 
 	if (wbc.for_kupdate) {
@@ -642,6 +643,24 @@ static long wb_writeback(struct bdi_writ
 		wbc.range_end = LLONG_MAX;
 	}
 
+	/*
+	 * WB_SYNC_ALL mode does livelock avoidance by syncing dirty
+	 * inodes/pages in one big loop. Setting wbc.nr_to_write=LONG_MAX
+	 * here avoids calling into writeback_inodes_wb() more than once.
+	 *
+	 * The intended call sequence for WB_SYNC_ALL writeback is:
+	 *
+	 *      wb_writeback()
+	 *          writeback_inodes_wb()       <== called only once
+	 *              write_cache_pages()     <== called once for each inode
+	 *                   (quickly) tag currently dirty pages
+	 *                   (maybe slowly) sync all tagged pages
+	 */
+	if (wbc.sync_mode == WB_SYNC_NONE)
+		write_chunk = MAX_WRITEBACK_PAGES;
+	else
+		write_chunk = LONG_MAX;
+
 	wbc.wb_start = jiffies; /* livelock avoidance */
 	for (;;) {
 		/*
@@ -667,7 +686,7 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		wbc.more_io = 0;
-		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
+		wbc.nr_to_write = write_chunk;
 		wbc.pages_skipped = 0;
 
 		trace_wbc_writeback_start(&wbc, wb->bdi);
@@ -677,8 +696,8 @@ static long wb_writeback(struct bdi_writ
 			writeback_inodes_wb(wb, &wbc);
 		trace_wbc_writeback_written(&wbc, wb->bdi);
 
-		work->nr_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
-		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
+		work->nr_pages -= write_chunk - wbc.nr_to_write;
+		wrote += write_chunk - wbc.nr_to_write;
 
 		/*
 		 * If we consumed everything, see if we have more
@@ -693,7 +712,7 @@ static long wb_writeback(struct bdi_writ
 		/*
 		 * Did we write something? Try for more
 		 */
-		if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
+		if (wbc.nr_to_write < write_chunk)
 			continue;
 		/*
 		 * Nothing written. Wait for some inode to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
