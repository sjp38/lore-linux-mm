Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CCC7E6B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 22:02:29 -0400 (EDT)
Date: Wed, 7 Sep 2011 10:02:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 14/18] writeback: control dirty pause time
Message-ID: <20110907020214.GA13755@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020916.460538138@intel.com>
 <1315324285.14232.16.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315324285.14232.16.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 06, 2011 at 11:51:25PM +0800, Peter Zijlstra wrote:
> On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> > plain text document attachment (max-pause-adaption)
> > The dirty pause time shall ultimately be controlled by adjusting
> > nr_dirtied_pause, since there is relationship
> > 
> > 	pause = pages_dirtied / task_ratelimit
> > 
> > Assuming
> > 
> > 	pages_dirtied ~= nr_dirtied_pause
> > 	task_ratelimit ~= dirty_ratelimit
> > 
> > We get
> > 
> > 	nr_dirtied_pause ~= dirty_ratelimit * desired_pause
> > 
> > Here dirty_ratelimit is preferred over task_ratelimit because it's
> > more stable.
> > 
> > It's also important to limit possible large transitional errors:
> > 
> > - bw is changing quickly
> > - pages_dirtied << nr_dirtied_pause on entering dirty exceeded area
> > - pages_dirtied >> nr_dirtied_pause on btrfs (to be improved by a
> >   separate fix, but still expect non-trivial errors)
> > 
> > So we end up using the above formula inside clamp_val().
> > 
> > The best test case for this code is to run 100 "dd bs=4M" tasks on
> > btrfs and check its pause time distribution.
> 
> 
> 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  mm/page-writeback.c |   15 ++++++++++++++-
> >  1 file changed, 14 insertions(+), 1 deletion(-)
> > 
> > --- linux-next.orig/mm/page-writeback.c	2011-08-29 19:08:43.000000000 +0800
> > +++ linux-next/mm/page-writeback.c	2011-08-29 19:08:44.000000000 +0800
> > @@ -1193,7 +1193,20 @@ pause:
> >  	if (!dirty_exceeded && bdi->dirty_exceeded)
> >  		bdi->dirty_exceeded = 0;
> >  
> > -	current->nr_dirtied_pause = dirty_poll_interval(nr_dirty, dirty_thresh);
> > +	if (pause == 0)
> > +		current->nr_dirtied_pause =
> > +				dirty_poll_interval(nr_dirty, dirty_thresh);
> > +	else if (period <= max_pause / 4 &&
> > +		 pages_dirtied >= current->nr_dirtied_pause)
> > +		current->nr_dirtied_pause = clamp_val(
> > +					dirty_ratelimit * (max_pause / 2) / HZ,
> > +					pages_dirtied + pages_dirtied / 8,
> > +					pages_dirtied * 4);
> > +	else if (pause >= max_pause)
> > +		current->nr_dirtied_pause = 1 | clamp_val(
> > +					dirty_ratelimit * (max_pause * 3/8)/HZ,
> > +					pages_dirtied / 4,
> > +					pages_dirtied * 7/8);
> >  
> 
> I very much prefer { } over multi line stmts, even if not strictly
> needed.

Yeah, that does look better.

> I'm also not quite sure why pause==0 is a special case,

Good question, it covers the important case that dirty pages are still
in the freerun area, where we don't do pause at all and hence cannot
adaptively adjust current->nr_dirtied_pause based on the pause time.

I'll add a simple comment for that condition:

        if (pause == 0) { /* in freerun area */

> also, do the two other line segments connect on the transition
> point?

I guess we can simply unify the other two formulas into one:

        } else if (period <= max_pause / 4 &&
                 pages_dirtied >= current->nr_dirtied_pause) {
                current->nr_dirtied_pause = clamp_val(
==>                                     dirty_ratelimit * (max_pause / 2) / HZ,
                                        pages_dirtied + pages_dirtied / 8,
                                        pages_dirtied * 4);
        } else if (pause >= max_pause) {
                current->nr_dirtied_pause = 1 | clamp_val(
==>                                     dirty_ratelimit * (max_pause / 2) / HZ,
                                        pages_dirtied / 4,
                                        pages_dirtied - pages_dirtied / 8);
        }

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
