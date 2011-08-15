Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E42346B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 10:08:41 -0400 (EDT)
Date: Mon, 15 Aug 2011 22:08:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/5] writeback: dirty rate control
Message-ID: <20110815140832.GA23601@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.878435971@intel.com>
 <1312901852.1083.26.camel@twins>
 <20110810110709.GA27604@localhost>
 <1312993075.23660.40.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312993075.23660.40.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 11, 2011 at 12:17:55AM +0800, Peter Zijlstra wrote:
> How about something like the below, it still needs some more work, but
> its more or less complete in that is now explains both controls in one
> story. The actual update bit is still missing.

Looks pretty good, thanks!  I'll post the completed version at the
bottom.

> ---
> 
> balance_dirty_pages() needs to throttle tasks dirtying pages such that
> the total amount of dirty pages stays below the specified dirty limit in
> order to avoid memory deadlocks. Furthermore we desire fairness in that
> tasks get throttled proportionally to the amount of pages they dirty.
> 
> IOW we want to throttle tasks such that we match the dirty rate to the
> writeout bandwidth, this yields a stable amount of dirty pages:
> 
> 	ratelimit = writeout_bandwidth
> 
> The fairness requirements gives us:
> 
> 	task_ratelimit = write_bandwidth / N
> 
> > : When started N dd, we would like to throttle each dd at
> > : 
> > :          balanced_rate == write_bw / N                                  (1)
> > : 
> > : We don't know N beforehand, but still can estimate balanced_rate
> > : within 200ms.
> > : 
> > : Start by throttling each dd task at rate
> > : 
> > :         task_ratelimit = task_ratelimit_0                               (2)
> > :                          (any non-zero initial value is OK)
> > : 
> > : After 200ms, we got
> > : 
> > :         dirty_rate = # of pages dirtied by all dd's / 200ms
> > :         write_bw   = # of pages written to the disk / 200ms
> > : 
> > : For the aggressive dd dirtiers, the equality holds
> > : 
> > :         dirty_rate == N * task_rate
> > :                    == N * task_ratelimit
> > :                    == N * task_ratelimit_0                              (3)
> > : Or
> > :         task_ratelimit_0 = dirty_rate / N                               (4)
> > :                           
> > : So the balanced throttle bandwidth can be estimated by
> > :                           
> > :         balanced_rate = task_ratelimit_0 * (write_bw / dirty_rate)      (5)
> > :                           
> > : Because with (4) and (5) we can get the desired equality (1):
> > :                           
> > :         balanced_rate == (dirty_rate / N) * (write_bw / dirty_rate)
> > :                       == write_bw / N
> 
> Then using the balance_rate we can compute task pause times like:
> 
> 	task_pause = task->nr_dirtied / task_ratelimit
> 
> [ however all that still misses the primary feedback of:
> 
>    task_ratelimit_(i+1) = task_ratelimit_i * (write_bw / dirty_rate)
> 
>   there's still some confusion in the above due to task_ratelimit and
>   balanced_rate.
> ]
> 
> However, while the above gives us means of matching the dirty rate to
> the writeout bandwidth, it at best provides us with a stable dirty page
> count (assuming a static system). In order to control the dirty page
> count such that it is high enough to provide performance, but does not
> exceed the specified limit we need another control.
> 
> > So if the dirty pages are ABOVE the setpoints, we throttle each task
> > a bit more HEAVY than balanced_rate, so that the dirty pages are
> > created less fast than they are cleaned, thus DROP to the setpoints
> > (and the reverse). With that positional adjustment, the formula is
> > transformed from
> > 
> >         task_ratelimit = balanced_rate
> > 
> > to
> > 
> >         task_ratelimit = balanced_rate * pos_ratio
> 
> > In terms of the negative feedback control theory, the
> > bdi_position_ratio() function (control lines) can be expressed as
> > 
> > 1) f(setpoint) = 1.0
> > 2) df/dt < 0
> > 
> > 3) optionally, abs(df/dt) should be large on large errors (= dirty -
> >    setpoint) in order to cancel the errors fast, and be smaller when
> >    dirty pages get closer to the setpoints in order to avoid overshooting.
> 
> 

Estimation of balanced bdi->dirty_ratelimit
===========================================

balanced task_ratelimit
-----------------------

balance_dirty_pages() needs to throttle tasks dirtying pages such that
the total amount of dirty pages stays below the specified dirty limit in
order to avoid memory deadlocks. Furthermore we desire fairness in that
tasks get throttled proportionally to the amount of pages they dirty.

IOW we want to throttle tasks such that we match the dirty rate to the
writeout bandwidth, this yields a stable amount of dirty pages:

	ratelimit = write_bw						(1)

The fairness requirement gives us:

        task_ratelimit = write_bw / N					(2)

where N is the number of dd tasks.  We don't know N beforehand, but
still can estimate the balanced task_ratelimit within 200ms.

Start by throttling each dd task at rate

        task_ratelimit = task_ratelimit_0				(3)
 		  	 (any non-zero initial value is OK)

After 200ms, we measured

        dirty_rate = # of pages dirtied by all dd's / 200ms
        write_bw   = # of pages written to the disk / 200ms

For the aggressive dd dirtiers, the equality holds

	dirty_rate == N * task_rate
                   == N * task_ratelimit
                   == N * task_ratelimit_0            			(4)
Or
	task_ratelimit_0 = dirty_rate / N            			(5)

Now we conclude that the balanced task ratelimit can be estimated by

        task_ratelimit = task_ratelimit_0 * (write_bw / dirty_rate)	(6)

Because with (4) and (5) we can get the desired equality (1):

	task_ratelimit == (dirty_rate / N) * (write_bw / dirty_rate)
	       	       == write_bw / N

Then using the balanced task ratelimit we can compute task pause times like:
        
        task_pause = task->nr_dirtied / task_ratelimit

task_ratelimit with position control
------------------------------------

However, while the above gives us means of matching the dirty rate to
the writeout bandwidth, it at best provides us with a stable dirty page
count (assuming a static system). In order to control the dirty page
count such that it is high enough to provide performance, but does not
exceed the specified limit we need another control.

The dirty position control works by splitting (6) to

        task_ratelimit = balanced_rate					(7)
        balanced_rate = task_ratelimit_0 * (write_bw / dirty_rate)	(8)

and extend (7) to

        task_ratelimit = balanced_rate * pos_ratio			(9)

where pos_ratio is a negative feedback function that subjects to

1) f(setpoint) = 1.0
2) df/dx < 0

That is, if the dirty pages are ABOVE the setpoint, we throttle each
task a bit more HEAVY than balanced_rate, so that the dirty pages are
created less fast than they are cleaned, thus DROP to the setpoints
(and the reverse).

bdi->dirty_ratelimit update policy
----------------------------------

The balanced_rate calculated by (8) is not suitable for direct use (*).
For the reasons listed below, (9) is further transformed into

	task_ratelimit = dirty_ratelimit * pos_ratio			(10)

where dirty_ratelimit will be tracking balanced_rate _conservatively_.

---
(*) There are some imperfections in balanced_rate, which make it not
suitable for direct use:

1) large fluctuations

The dirty_rate used for computing balanced_rate is merely averaged in
the past 200ms (very small comparing to the 3s estimation period for
write_bw), which makes rather dispersed distribution of balanced_rate.

It's pretty hard to average out the singular points by increasing the
estimation period. Considering that the averaging technique will
introduce very undesirable time lags, I give it up totally. (btw, the 3s
write_bw averaging time lag is much more acceptable because its impact
is one-way and therefore won't lead to oscillations.)

The more practical way is filtering -- most singular balanced_rate
points can be filtered out by remembering some prev_balanced_rate and
prev_prev_balanced_rate. However the more reliable way is to guard
balanced_rate with pos_rate.

2) due to truncates and fs redirties, the (write_bw <=> dirty_rate)
match could become unbalanced, which may lead to large systematical
errors in balanced_rate. The truncates, due to its possibly bumpy
nature, can hardly be compensated smoothly. So let's face it. When some
over-estimated balanced_rate brings dirty_ratelimit high, dirty pages
will go higher than the setpoint. pos_rate will in turn become lower
than dirty_ratelimit.  So if we consider both balanced_rate and pos_rate
and update dirty_ratelimit only when they are on the same side of
dirty_ratelimit, the systematical errors in balanced_rate won't be able
to bring dirty_ratelimit far away.

The balanced_rate estimation may also be inaccurate when near the max
pause and free run areas, however is less an issue.

3) since we ultimately want to

- keep the fluctuations of task ratelimit as small as possible
- keep the dirty pages around the setpoint as long time as possible

the update policy used for (2) also serves the above goals nicely:
if for some reason the dirty pages are high (pos_rate < dirty_ratelimit),
and dirty_ratelimit is low (dirty_ratelimit < balanced_rate), there is
no point to bring up dirty_ratelimit in a hurry only to hurt both the
above two goals.

In summary, the dirty_ratelimit update policy consists of two constraints:

1) avoid changing dirty rate when it's against the position control target
   (the adjusted rate will slow down the progress of dirty pages going
   back to setpoint).

2) limit the step size. pos_rate is changing values step by step,
   leaving a consistent trace comparing to the randomly jumping
   balanced_rate. pos_rate also has the nice smaller errors in stable
   state and typically larger errors when there are big errors in rate.
   So it's a pretty good limiting factor for the step size of dirty_ratelimit.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
