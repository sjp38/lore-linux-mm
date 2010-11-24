Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 243356B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 08:20:21 -0500 (EST)
Date: Wed, 24 Nov 2010 21:20:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
Message-ID: <20101124132012.GA12117@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042850.002299964@intel.com>
 <1290596732.2072.450.camel@laptop>
 <20101124121046.GA8333@localhost>
 <1290603047.2072.465.camel@laptop>
 <20101124131437.GE10413@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101124131437.GE10413@localhost>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 09:14:37PM +0800, Wu Fengguang wrote:
> On Wed, Nov 24, 2010 at 08:50:47PM +0800, Peter Zijlstra wrote:
> > On Wed, 2010-11-24 at 20:10 +0800, Wu Fengguang wrote:
> > > > > +       /*
> > > > > +        * When there lots of tasks throttled in balance_dirty_pages(), they
> > > > > +        * will each try to update the bandwidth for the same period, making
> > > > > +        * the bandwidth drift much faster than the desired rate (as in the
> > > > > +        * single dirtier case). So do some rate limiting.
> > > > > +        */
> > > > > +       if (jiffies - bdi->write_bandwidth_update_time < elapsed)
> > > > > +               goto snapshot;
> > > >
> > > > Why this goto snapshot and not simply return? This is the second call
> > > > (bdi_update_bandwidth equivalent).
> > > 
> > > Good question. The loop inside balance_dirty_pages() normally run only
> > > once, however wb_writeback() may loop over and over again. If we just
> > > return here, the condition
> > > 
> > >         (jiffies - bdi->write_bandwidth_update_time < elapsed)
> > > 
> > > cannot be reset, then future bdi_update_bandwidth() calls in the same
> > > wb_writeback() loop will never find it OK to update the bandwidth.
> > 
> > But the thing is, you don't want to reset that, it might loop so fast
> > you'll throttle all of them, if you keep the pre-throttle value you'll
> > eventually pass, no?
> 
> It (let's name it A) only resets the _local_ vars bw_* when it's sure
> by the condition
> 
>         (jiffies - bdi->write_bandwidth_update_time < elapsed)

this will be true if someone else has _done_ overlapped estimation,
otherwise it will equal:

        jiffies - bdi->write_bandwidth_update_time == elapsed

Sorry the comment needs updating.

Thanks,
Fengguang

> that someone else (name B) has updated the _global_ bandwidth in the
> time range we planned. So there may be some time in A's range that is
> not covered by B, but sure the range is not totally bypassed without
> updating the bandwidth.
> 
> > > It does assume no races between CPUs.. We may need some per-cpu based
> > > estimation. 
> > 
> > But that multi-writer race is valid even for the balance_dirty_pages()
> > call, two or more could interleave on the bw_time and bw_written
> > variables.
> 
> The race will only exist in each task's local vars (their bw_* will
> overlap). But the update bdi->write_bandwidth* will be safeguarded
> by the above check. When the task is scheduled back, it may find
> updated write_bandwidth_update_time and hence give up his estimation.
> This is rather tricky..
> 
> Thanks,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
