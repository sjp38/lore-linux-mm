Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 51F596B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 07:10:52 -0500 (EST)
Date: Wed, 24 Nov 2010 20:10:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
Message-ID: <20101124121046.GA8333@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042850.002299964@intel.com>
 <1290596732.2072.450.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290596732.2072.450.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 07:05:32PM +0800, Peter Zijlstra wrote:
> On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> > +void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
> > +                               unsigned long *bw_time,
> > +                               s64 *bw_written)
> > +{
> > +       unsigned long written;
> > +       unsigned long elapsed;
> > +       unsigned long bw;
> > +       unsigned long w;
> > +
> > +       if (*bw_written == 0)
> > +               goto snapshot;
> > +
> > +       elapsed = jiffies - *bw_time;
> > +       if (elapsed < HZ/100)
> > +               return;
> > +
> > +       /*
> > +        * When there lots of tasks throttled in balance_dirty_pages(), they
> > +        * will each try to update the bandwidth for the same period, making
> > +        * the bandwidth drift much faster than the desired rate (as in the
> > +        * single dirtier case). So do some rate limiting.
> > +        */
> > +       if (jiffies - bdi->write_bandwidth_update_time < elapsed)
> > +               goto snapshot;
>
> Why this goto snapshot and not simply return? This is the second call
> (bdi_update_bandwidth equivalent).

Good question. The loop inside balance_dirty_pages() normally run only
once, however wb_writeback() may loop over and over again. If we just
return here, the condition

        (jiffies - bdi->write_bandwidth_update_time < elapsed)

cannot be reset, then future bdi_update_bandwidth() calls in the same
wb_writeback() loop will never find it OK to update the bandwidth.

It does assume no races between CPUs.. We may need some per-cpu based
estimation.

> If you were to leave the old bw_written/bw_time in place the next loop
> around in wb_writeback() would see a larger delta..
>
> I guess this funny loop in wb_writeback() is also the reason you've got
> a single function and not the get/update like separation

I do the single function mainly for wb_writeback(), where it
continuously updates bandwidth inside the loop. The function can be
called in such way:

loop {
        take snapshot on first call

        no action if recalled within 10ms
        ...
        no action if recalled within 10ms
        ...

        update bandwidth and prepare for next update by taking the snapshot

        no action if recalled within 10ms
        ...
}

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
