Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7036B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 10:11:35 -0400 (EDT)
Date: Mon, 8 Aug 2011 22:11:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110808141128.GA22080@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312811193.10488.33.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 08, 2011 at 09:46:33PM +0800, Peter Zijlstra wrote:
> On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:
> > +static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
> > +                                       unsigned long thresh,
> > +                                       unsigned long dirty,
> > +                                       unsigned long bdi_thresh,
> > +                                       unsigned long bdi_dirty)
> > +{
> > +       unsigned long limit = hard_dirty_limit(thresh);
> > +       unsigned long origin;
> > +       unsigned long goal;
> > +       unsigned long long span;
> > +       unsigned long long pos_ratio;   /* for scaling up/down the rate limit */
> > +
> > +       if (unlikely(dirty >= limit))
> > +               return 0;
> > +
> > +       /*
> > +        * global setpoint
> > +        */
> > +       goal = thresh - thresh / DIRTY_SCOPE;
> > +       origin = 4 * thresh;
> > +
> > +       if (unlikely(origin < limit && dirty > (goal + origin) / 2)) {
> > +               origin = limit;                 /* auxiliary control line */
> > +               goal = (goal + origin) / 2;
> > +               pos_ratio >>= 1; 
> 
> use before init?

Yeah it's embarrassing, I find this bug all the way back to the initial version...

It's actually dead code because (origin < limit) should never happen.
I feel so good being able to drop 5 more lines of code :)

Thanks,
Fengguang
---

--- linux-next.orig/mm/page-writeback.c	2011-08-08 21:56:11.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-08 22:04:48.000000000 +0800
@@ -538,11 +538,6 @@ static unsigned long bdi_position_ratio(
 	goal = thresh - thresh / DIRTY_SCOPE;
 	origin = 4 * thresh;
 
-	if (unlikely(origin < limit && dirty > (goal + origin) / 2)) {
-		origin = limit;			/* auxiliary control line */
-		goal = (goal + origin) / 2;
-		pos_ratio >>= 1;
-	}
 	pos_ratio = origin - dirty;
 	pos_ratio <<= BANDWIDTH_CALC_SHIFT;
 	do_div(pos_ratio, origin - goal + 1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
