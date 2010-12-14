Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 853476B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 01:51:38 -0500 (EST)
Date: Tue, 14 Dec 2010 14:51:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 16/35] writeback: increase min pause time on concurrent
 dirtiers
Message-ID: <20101214065133.GA6940@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150328.284979629@intel.com>
 <15881.1292264611@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15881.1292264611@localhost>
Sender: owner-linux-mm@kvack.org
To: "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2010 at 02:23:31AM +0800, Valdis.Kletnieks@vt.edu wrote:
> On Mon, 13 Dec 2010 22:47:02 +0800, Wu Fengguang said:
> > Target for >60ms pause time when there are 100+ heavy dirtiers per bdi.
> > (will average around 100ms given 200ms max pause time)
> 
> > --- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:16.000000000 +0800
> > +++ linux-next/mm/page-writeback.c	2010-12-13 21:46:16.000000000 +0800
> > @@ -659,6 +659,27 @@ static unsigned long max_pause(unsigned 
> >  }
> >  
> >  /*
> > + * Scale up pause time for concurrent dirtiers in order to reduce CPU overheads.
> > + * But ensure reasonably large [min_pause, max_pause] range size, so that
> > + * nr_dirtied_pause (and hence future pause time) can stay reasonably stable.
> > + */
> > +static unsigned long min_pause(struct backing_dev_info *bdi,
> > +			       unsigned long max)
> > +{
> > +	unsigned long hi = ilog2(bdi->write_bandwidth);
> > +	unsigned long lo = ilog2(bdi->throttle_bandwidth);
> > +	unsigned long t;
> > +
> > +	if (lo >= hi)
> > +		return 1;
> > +
> > +	/* (N * 10ms) on 2^N concurrent tasks */
> > +	t = (hi - lo) * (10 * HZ) / 1024;
> 
> Either I need more caffeine, or the comment doesn't match the code
> if HZ != 1000?

The "ms" in the comment may be confusing, but the pause time (t) is
measured in jiffies :)  Hope the below patch helps.

Thanks,
Fengguang
---
Subject: writeback: pause time is measured in jiffies
Date: Tue Dec 14 14:46:23 CST 2010

Add comments to make it clear.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-14 14:45:15.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-14 14:46:20.000000000 +0800
@@ -649,7 +649,7 @@ unlock:
  */
 static unsigned long max_pause(unsigned long bdi_thresh)
 {
-	unsigned long t;
+	unsigned long t;  /* jiffies */
 
 	/* 1ms for every 4MB */
 	t = bdi_thresh >> (32 - PAGE_CACHE_SHIFT -
@@ -669,7 +669,7 @@ static unsigned long min_pause(struct ba
 {
 	unsigned long hi = ilog2(bdi->write_bandwidth);
 	unsigned long lo = ilog2(bdi->throttle_bandwidth);
-	unsigned long t;
+	unsigned long t;  /* jiffies */
 
 	if (lo >= hi)
 		return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
