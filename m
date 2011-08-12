Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C9BE46B016C
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 10:20:26 -0400 (EDT)
Date: Fri, 12 Aug 2011 22:20:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110812142020.GB17781@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313154259.6576.42.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313154259.6576.42.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Peter,

Sorry for the delay..

On Fri, Aug 12, 2011 at 09:04:19PM +0800, Peter Zijlstra wrote:
> On Tue, 2011-08-09 at 19:20 +0200, Peter Zijlstra wrote:

To start with,

                                                write_bw
        ref_bw = task_ratelimit_in_past_200ms * --------
                                                dirty_bw

where
        task_ratelimit_in_past_200ms ~= dirty_ratelimit * pos_ratio

> > Now all of the above would seem to suggest:
> > 
> >   dirty_ratelimit := ref_bw

Right, ideally ref_bw is the balanced dirty ratelimit. I actually
started with exactly the above equation when I got choked by pure
pos_bw based feedback control (as mentioned in the reply to Jan's
email) and introduced the ref_bw estimation as the way out.

But there are some imperfections in ref_bw, too. Which makes it not
suitable for direct use:

1) large fluctuations

The dirty_bw used for computing ref_bw is merely averaged in the
past 200ms (very small comparing to the 3s estimation period in
write_bw), which makes rather dispersed distribution of ref_bw.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/8G/ext4-10dd-4k-32p-6802M-20:10-3.0.0-next-20110802+-2011-08-06.16:48/balance_dirty_pages-pages.png

Take a look at the blue [*] points in the above graph. I find it pretty
hard to average out the singular points by increasing the estimation
period. Considering that the averaging technique will introduce the
very undesirable time lags, I give it up totally. (btw, the write_bw
averaging time lag is much more acceptable because its impact is
one-way and therefore won't lead to oscillations.)

The one practical way is filtering -- the most large singular ref_bw
points can be filtered out effectively by remembering some prev_ref_bw
and prev_prev_ref_bw. However it cannot do away all of them. And the
remaining majority ref_bw points are still randomly dancing around the
ideal balanced rate. 

2) due to truncates and fs redirties, the (write_bw <=> dirty_bw)
becomes unbalanced match, which leads to large systematical errors
in ref_bw. The truncates, due to its possibly bumpy nature, can hardly
be compensated smoothly. So let's face it. When some over-estimated
ref_bw brings ->dirty_ratelimit high, higher than the setpoint, the
pos_bw will in turn become lower than ->dirty_ratelimit. So if we
consider both ref_bw and pos_bw and update ->dirty_ratelimit only when
they are on the same side of ->dirty_ratelimit, the systematical
errors in ref_bw won't be able to bring ->dirty_ratelimit too away.

The ref_bw estimation is also not accurate when near the max pause and
free run areas.

3) since we ultimately want to

- keep the dirty pages around the setpoint as long time as possible
- keep the fluctuations of task ratelimit as small as possible

the update policy used for (2) also serves the above goals nicely:
if for some reason the dirty pages are high (pos_bw < dirty_ratelimit),
and dirty_ratelimit is low (dirty_ratelimit < ref_bw), there is no
point to bring up dirty_ratelimit in a hurry and to hurt both the
above two goals.

> > However for that you use:
> > 
> >   if (pos_bw < dirty_ratelimit && ref_bw < dirty_ratelimit)
> >         dirty_ratelimit = max(ref_bw, pos_bw);
> > 
> >   if (pos_bw > dirty_ratelimit && ref_bw > dirty_ratelimit)
> >         dirty_ratelimit = min(ref_bw, pos_bw);

The above are merely constraints to the dirty_ratelimit update.
It serves to

1) stop adjusting the rate when it's against the position control
   target (the adjusted rate will slow down the progress of dirty
   pages going back to setpoint).

2) limit the step size. pos_bw is changing values step by step,
   leaving a consistent trace comparing to the randomly jumping
   ref_bw. pos_bw also has smaller errors in stable state and normally
   have larger errors when there are big errors in rate. So it's a
   pretty good limiting factor for the step size of dirty_ratelimit.

> > You have:
> > 
> >   pos_bw = dirty_ratelimit * pos_ratio
> > 
> > Which is ref_bw without the write_bw/dirty_bw factor, this confuses me..
> > why are you ignoring the shift in output vs input rate there? 

Again, you need to understand pos_bw the other way.  Only (pos_bw -
dirty_ratelimit) matters here, which is exactly the position error.

> Could you elaborate on this primary feedback loop? Its the one part I
> don't feel I actually understand well.

Hope the above elaboration helps :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
