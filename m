Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D32C98D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 20:56:50 -0500 (EST)
Date: Thu, 2 Dec 2010 09:56:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 01/13] writeback: IO-less balance_dirty_pages()
Message-ID: <20101202015646.GA6629@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042849.410279291@intel.com>
 <1290085474.2109.1480.camel@laptop>
 <20101129151719.GA30590@localhost>
 <1291064013.32004.393.camel@laptop>
 <20101130043735.GA22947@localhost>
 <1291156522.32004.1359.camel@laptop>
 <1291156765.32004.1365.camel@laptop>
 <20101201133818.GA13377@localhost>
 <20101201150333.fa4b8955.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101201150333.fa4b8955.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 02, 2010 at 07:03:33AM +0800, Andrew Morton wrote:
> On Wed, 1 Dec 2010 21:38:18 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > It shows that
> > 
> > 1) io_schedule_timeout(200ms) always return immediately for iostat,
> >    forming a busy loop.  How can this happen? When iostat received
> >    some signal? Then we may have to break out of the loop on catching
> >    signals. Note that I already have
> >                 if (fatal_signal_pending(current))
> >                         break;
> >    in the balance_dirty_pages() loop. Obviously that's not enough.
> 
> Presumably the calling task has singal_pending().
> 
> Using TASK_INTERRUPTIBLE in balance_dirty_pages() seems wrong.  If it's
> going to do that then it must break out if signal_pending(), otherwise
> it's pretty much guaranteed to degenerate into a busywait loop.

Right. It seems not rewarding enough to check signal_pending().  We've
already been able to response to signals much faster than before
(which takes more time to block in get_request_wait()).

> Plus we *do* want these processes to appear in D state and to
> contribute to load average.
> 
> So it should be TASK_UNINTERRUPTIBLE.

Fair enough. I do missed the D state (without the long wait :).
Here is the patch.

Thanks,
Fengguang
---
Subject: writeback: do uninterruptible sleep in balance_dirty_pages()
Date: Thu Dec 02 09:31:19 CST 2010

Using TASK_INTERRUPTIBLE in balance_dirty_pages() seems wrong.  If it's
going to do that then it must break out if signal_pending(), otherwise
it's pretty much guaranteed to degenerate into a busywait loop.  Plus
we *do* want these processes to appear in D state and to contribute to
load average.

So it should be TASK_UNINTERRUPTIBLE.                 -- Andrew Morton

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-02 09:30:29.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-02 09:30:34.000000000 +0800
@@ -636,7 +636,7 @@ pause:
 					  pages_dirtied,
 					  pause);
 		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
-		__set_current_state(TASK_INTERRUPTIBLE);
+		__set_current_state(TASK_UNINTERRUPTIBLE);
 		io_schedule_timeout(pause);
 		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
