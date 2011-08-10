Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DF320900138
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 17:41:21 -0400 (EDT)
Date: Wed, 10 Aug 2011 17:40:57 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110810214057.GA6576@redhat.com>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110808230535.GC7176@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 09, 2011 at 07:05:35AM +0800, Wu Fengguang wrote:
> On Mon, Aug 08, 2011 at 10:41:41PM +0800, Peter Zijlstra wrote:
> > On Mon, 2011-08-08 at 22:11 +0800, Wu Fengguang wrote:
> > > @@ -538,11 +538,6 @@ static unsigned long bdi_position_ratio(
> > >         goal = thresh - thresh / DIRTY_SCOPE;
> > >         origin = 4 * thresh;
> > >  
> > > -       if (unlikely(origin < limit && dirty > (goal + origin) / 2)) {
> > > -               origin = limit;                 /* auxiliary control line */
> > > -               goal = (goal + origin) / 2;
> > > -               pos_ratio >>= 1;
> > > -       }
> > >         pos_ratio = origin - dirty;
> > >         pos_ratio <<= BANDWIDTH_CALC_SHIFT;
> > >         do_div(pos_ratio, origin - goal + 1); 
> 
> FYI I've updated the fix to the below one, so that @limit will be used
> as the origin in the rare case of (4*thresh < dirty).
> 
> --- linux-next.orig/mm/page-writeback.c	2011-08-08 21:56:11.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2011-08-09 06:34:25.000000000 +0800
> @@ -536,13 +536,8 @@ static unsigned long bdi_position_ratio(
>  	 * global setpoint
>  	 */
>  	goal = thresh - thresh / DIRTY_SCOPE;
> -	origin = 4 * thresh;
> +	origin = max(4 * thresh, limit);

Hi Fengguang,

Ok, so just trying to understand this pos_ratio little better.

You have following basic formula.

                     origin - dirty
         pos_ratio = --------------
                     origin - goal

Terminology is very confusing and following is my understanding. 

- setpoint == goal

  setpoint is the point where we would like our number of dirty pages to
  be and at this point pos_ratio = 1. For global dirty this number seems
  to be (thresh - thresh / DIRTY_SCOPE) 

- thresh
  dirty page threshold calculated from dirty_ratio (Certain percentage of
  total memory).

- Origin (seems to be equivalent of limit)

  This seems to be the reference point/limit we don't want to cross and
  distance from this limit basically decides the pos_ratio. Closer we
  are to limit, lower the pos_ratio and further we are higher the
  pos_ratio.

So threshold is just a number which helps us determine goal and limit.

goal = thresh - thresh / DIRTY_SCOPE
limit = 4*thresh

So goal is where we want to be and we start throttling the task more as
we move away goal and approach limit. We keep the limit high enough
so that (origin-dirty) does not become negative entity.

So we do expect to cross "thresh" otherwise thresh itself could have
served as limit?

If my understanding is right, then can we get rid of terms "setpoint" and
"origin". Would it be easier to understand the things if we just talk
in terms of "goal" and "limit" and how these are derived from "thresh".

	thresh == soft limit
	limit == 4*thresh (hard limit)
	goal = thresh - thresh / DIRTY_SCOPE (where we want system to
						be in steady state).
                     limit - dirty
         pos_ratio = --------------
                     limit - goal

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
