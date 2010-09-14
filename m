Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 85C266B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 05:17:25 -0400 (EDT)
Date: Tue, 14 Sep 2010 17:17:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 05/17] writeback: quit throttling when signal pending
Message-ID: <20100914091720.GA23042@localhost>
References: <20100914172028.C9B2.A69D9226@jp.fujitsu.com>
 <20100914083338.GA20295@localhost>
 <20100914174017.C9BB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100914174017.C9BB.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Neil Brown <neilb@suse.de>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 14, 2010 at 04:44:37PM +0800, KOSAKI Motohiro wrote:
> > On Tue, Sep 14, 2010 at 04:23:56PM +0800, KOSAKI Motohiro wrote:
> > > > Subject: writeback: quit throttling when fatal signal pending
> > > > From: Wu Fengguang <fengguang.wu@intel.com>
> > > > Date: Wed Sep 08 17:40:22 CST 2010
> > > > 
> > > > This allows quick response to Ctrl-C etc. for impatient users.
> > > > 
> > > > It mainly helps the rare bdi/global dirty exceeded cases.
> > > > In the normal case of not exceeded, it will quit the loop anyway. 
> > > > 
> > > > CC: Neil Brown <neilb@suse.de>
> > > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > > ---
> > > >  mm/page-writeback.c |    3 +++
> > > >  1 file changed, 3 insertions(+)
> > > > 
> > > > --- linux-next.orig/mm/page-writeback.c	2010-09-12 13:25:23.000000000 +0800
> > > > +++ linux-next/mm/page-writeback.c	2010-09-13 11:39:33.000000000 +0800
> > > > @@ -552,6 +552,9 @@ static void balance_dirty_pages(struct a
> > > >  		__set_current_state(TASK_INTERRUPTIBLE);
> > > >  		io_schedule_timeout(pause);
> > > >  
> > > > +		if (fatal_signal_pending(current))
> > > > +			break;
> > > > +
> > > >  check_exceeded:
> > > >  		/*
> > > >  		 * The bdi thresh is somehow "soft" limit derived from the
> > > 
> > > I think we need to change callers (e.g. generic_perform_write) too.
> > > Otherwise, plenty write + SIGKILL combination easily exceed dirty limit.
> > > It mean we can see strange OOM.
> > 
> > If it's dangerous, we can do without this patch.  
> 
> How?

As you described.

> > The users can still
> > get quick response in normal case after all.
> > 
> > However, I suspect the process is guaranteed to exit on
> > fatal_signal_pending, so it won't dirty more pages :)
> 
> Process exiting is delayed until syscall exiting. So, we exit write syscall
> manually if necessary.

Got it, you mean this fix. It looks good. I didn't add "status =
-EINTR" in the patch because the bottom line "written ? : status" will
always select the non-zero written.

diff --git a/mm/filemap.c b/mm/filemap.c
index 3d4df44..f6d2740 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2304,7 +2304,8 @@ again:
 		written += copied;
 
 		balance_dirty_pages_ratelimited(mapping);
-
+		if (fatal_signal_pending(current))
+			break;
 	} while (iov_iter_count(i));
 
 	return written ? written : status;

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
