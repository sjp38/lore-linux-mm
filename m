Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 341E06B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 07:30:28 -0500 (EST)
Date: Wed, 24 Nov 2010 20:30:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 08/13] writeback: quit throttling when bdi dirty pages
 dropped low
Message-ID: <20101124123023.GA10413@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042850.245782303@intel.com>
 <1290597233.2072.454.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290597233.2072.454.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 07:13:53PM +0800, Peter Zijlstra wrote:
> On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> 
> > @@ -578,6 +579,25 @@ static void balance_dirty_pages(struct a
> >  				    bdi_stat(bdi, BDI_WRITEBACK);
> >  		}
> >  
> > +		/*
> > +		 * bdi_thresh takes time to ramp up from the initial 0,
> > +		 * especially for slow devices.
> > +		 *
> > +		 * It's possible that at the moment dirty throttling starts,
> > +		 * 	bdi_dirty = nr_dirty
> > +		 * 		  = (background_thresh + dirty_thresh) / 2
> > +		 * 		  >> bdi_thresh
> > +		 * Then the task could be blocked for a dozen second to flush
> > +		 * all the exceeded (bdi_dirty - bdi_thresh) pages. So offer a
> > +		 * complementary way to break out of the loop when 250ms worth
> > +		 * of dirty pages have been cleaned during our pause time.
> > +		 */
> > +		if (nr_dirty < dirty_thresh &&
> > +		    bdi_prev_dirty - bdi_dirty >
> > +		    bdi->write_bandwidth >> (PAGE_CACHE_SHIFT + 2))
> > +			break;
> > +		bdi_prev_dirty = bdi_dirty;
> > +
> >  		if (bdi_dirty >= bdi_thresh) {
> >  			pause = HZ/10;
> >  			goto pause;
> 
> 
> So we're testing to see if during our pause time (<=100ms) we've written
> out 250ms worth of pages (given our current bandwidth estimation),
> right? 
> 
> (1/4th of bandwidth in bytes/s is bytes per 0.25s) 

Right.

> (and in your recent patches you've changed the bw to pages/s so I take
> it the PAGE_CACHE_SIZE will be gone from all these sites).

Yeah. Actually I did one more fix after that. The break is designed
mainly to help single task case. It helps less for concurrent dirtier
cases, however for long run servers I guess they don't really care
some boot time lags.

For the 1-dd case, it looks better to lower the break threshold to
125ms. After all, it's not easy for the dirty pages to drop by 250ms
worth of data when you only slept 200ms (note: the max pause time has
been doubled mainly for servers).

-               if (nr_dirty < dirty_thresh &&
-                   bdi_prev_dirty - bdi_dirty > (long)bdi->write_bandwidth / 4)
+               if (nr_dirty <= dirty_thresh &&
+                   bdi_prev_dirty - bdi_dirty > (long)bdi->write_bandwidth / 8)
                        break;

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
