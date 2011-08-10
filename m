Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2C09C6B016F
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 07:07:15 -0400 (EDT)
Date: Wed, 10 Aug 2011 19:07:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/5] writeback: dirty rate control
Message-ID: <20110810110709.GA27604@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.878435971@intel.com>
 <1312901852.1083.26.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312901852.1083.26.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 09, 2011 at 10:57:32PM +0800, Peter Zijlstra wrote:
> On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:
> > 
> > Estimation of balanced bdi->dirty_ratelimit
> > ===========================================
> > 
> > When started N dd, throttle each dd at
> > 
> >          task_ratelimit = pos_bw (any non-zero initial value is OK)
> 
> This is (0), since it makes (1). But it fails to explain what the
> difference is between task_ratelimit and pos_bw (and why positional
> bandwidth is a good name).

Yeah it's (0) and is another form of the formula used in
balance_dirty_pages():

        rate = bdi->dirty_ratelimit * pos_ratio

In fact the estimation of ref_bw can take a more general form, by
writing (0) as

        task_ratelimit = task_ratelimit_0

where task_ratelimit_0 is any non-zero value balance_dirty_pages()
uses to throttle the tasks during that 200ms.

> > After 200ms, we got
> > 
> >          dirty_bw = # of pages dirtied by app / 200ms
> >          write_bw = # of pages written to disk / 200ms
> 
> Right, so that I get. And our premise for the whole work is to delay
> applications so that we match the dirty_bw to the write_bw, right?

Right, the balance target is (dirty_bw == write_bw),
but let's rename dirty_bw to dirty_rate as you suggested.

> > For aggressive dirtiers, the equality holds
> > 
> >          dirty_bw == N * task_ratelimit
> >                   == N * pos_bw                         (1)
> 
> So dirty_bw is in pages/s, so task_ratelimit should also be in pages/s,
> since N is a unit-less number.

Right.

> What does task_ratelimit in pages/s mean? Since we make the tasks sleep
> the only thing we can make from this is a measure of pages. So I expect
> (in a later patch) we compute the sleep time on the amount of pages we
> want written out, using this ratelimit measure, right?

Right. balance_dirty_pages() will use it this way (the variable name
used in code is 'bw', will change to 'rate'):

        pause = (HZ * pages_dirtied) / task_ratelimit

> > The balanced throttle bandwidth can be estimated by
> > 
> >          ref_bw = pos_bw * write_bw / dirty_bw          (2)
> 
> Here you introduce reference bandwidth, what does it mean and what is
> its relation to positional bandwidth. Going by the equation, we got
> (pages/s * pages/s) / (pages/s) so we indeed have a bandwidth unit.

Yeah. Or better do some renames:

          balanced_rate = task_ratelimit_0 * (write_bw / dirty_rate)    (2)

> write_bw/dirty_bw is the ration between output and input of dirty pages,
> but what is pos_bw and what does that make ref_bw?

It's (bdi->dirty_ratelimit * pos_ratio), the effective dirty rate
balance_dirty_pages() used to limit each bdi task for the past 200ms.

For example, if (task_ratelimit_0 = write_bw). Then the N dd tasks
will make bdi dirty rate (dirty_rate = N * task_ratelimit_0), and the
balanced ratelimit will be

        balanced_rate
        = task_ratelimit_0 * (write_bw / (N * task_ratelimit_0))
        = write_bw / N

Thus within 200ms, we get the estimation of balanced_rate without
knowing N beforehand.

> > >From (1) and (2), we get equality
> > 
> >          ref_bw == write_bw / N                         (3)
> 
> Somehow this seems like the primary postulate, yet you present it like a
> derivation. The whole purpose of your control system is to provide this
> fairness between processes, therefore I would expect you start out with
> this postulate and reason therefrom.

Good idea.

> > If the N dd's are all throttled at ref_bw, the dirty/writeback rates
> > will match. So ref_bw is the balanced dirty rate.
> 
> Which does lead to the question why its not called that instead ;-)

Sure, changed to balanced_rate :-)

> > In practice, the ref_bw calculated by (2) may fluctuate and have
> > estimation errors. So the bdi->dirty_ratelimit update policy is to
> > follow it only when both pos_bw and ref_bw point to the same direction
> > (indicating not only the dirty position has deviated from the global/bdi
> > setpoints, but also it's still departing away).
> 
> Which is where you introduce the need for pos_bw, yet you have not yet
> explained its meaning. In this explanation you allude to it being the
> speed (first time derivative) of the deviation from the setpoint.

That's right.

> The set point's measure is in pages, so the measure of its first time
> derivative would indeed be pages/s, just like bandwidth, but calling it
> a bandwidth seems highly confusing indeed.

Yeah, I'll rename the relevant vars *bw to *rate.

> I would also like a few more words on your update condition, why did you
> pick those, and what are the full ramifications of them.

OK.

> Also missing in this story is your pos_ratio thing, it is used in the
> code, but there is no explanation on how it ties in with the above
> things.

There are two control targets

(1) dirty setpoint
(2) dirty rate

pos_ratio does the position based control for (1). It's not inherently
relevant to the computation of balanced_rate. I hope the below rephrased
text will make it easier to understand.

: When started N dd, we would like to throttle each dd at
: 
:          balanced_rate == write_bw / N                                  (1)
: 
: We don't know N beforehand, but still can estimate balanced_rate
: within 200ms.
: 
: Start by throttling each dd task at rate
: 
:         task_ratelimit = task_ratelimit_0                               (2)
:                          (any non-zero initial value is OK)
: 
: After 200ms, we got
: 
:         dirty_rate = # of pages dirtied by all dd's / 200ms
:         write_bw   = # of pages written to the disk / 200ms
: 
: For the aggressive dd dirtiers, the equality holds
: 
:         dirty_rate == N * task_rate
:                    == N * task_ratelimit
:                    == N * task_ratelimit_0                              (3)
: Or
:         task_ratelimit_0 = dirty_rate / N                               (4)
:                           
: So the balanced throttle bandwidth can be estimated by
:                           
:         balanced_rate = task_ratelimit_0 * (write_bw / dirty_rate)      (5)
:                           
: Because with (4) and (5) we can get the desired equality (1):
:                           
:         balanced_rate == (dirty_rate / N) * (write_bw / dirty_rate)
:                       == write_bw / N
:
: Since balance_dirty_pages() will be using
:        
:         task_ratelimit = bdi->dirty_ratelimit * bdi_position_ratio()    (6)
: 
:        
: Taking (5) and (6), we get the real formula used in the code
:                                                                  
:         balanced_rate = bdi->dirty_ratelimit * bdi_position_ratio() * 
:                                 (write_bw / dirty_rate)                 (7)
: 

> You seem very skilled in control systems (your earlier read-ahead work
> was also a very complex system),

Thank you! I majored in the college "Pattern Recognition and Intelligent
Systems" and "Control theory and Control Engineering", which happen to be
the perfect preparations for read-ahead and dirty balancing :)

> but the explanations of your systems are highly confusing.

Sorry for that!

> Can you go back to the roots and explain how you constructed your
> model and why you did so? (without using graphs please)

As mentioned above, the root requirements are

(1) position target: to keep dirty pages around the bdi/global setpoints
(2) rate target:     to keep bdi dirty rate around bdi write bandwidth

In order to meet (2), we try to estimate (balanced_rate = write_bw / N)
and use it to throttle the N dd tasks.

However that's not enough. When the dirty rate perfectly matches the
write bandwidth, the dirty pages can stay stationary at any point.  We
want the dirty pages to stay around the setpoints as required by (1).

So if the dirty pages are ABOVE the setpoints, we throttle each task
a bit more HEAVY than balanced_rate, so that the dirty pages are
created less fast than they are cleaned, thus DROP to the setpoints
(and the reverse). With that positional adjustment, the formula is
transformed from

        task_ratelimit = balanced_rate              => meets (2)

to

        task_ratelimit = balanced_rate * pos_ratio  => meets both (1),(2)

At last, due to the possible large fluctuations in the raw
balanced_rate value, the more stable bdi->dirty_ratelimit which tracks
balanced_rate in a conservative way is used, resulting in the final form

        task_ratelimit = bdi->dirty_ratelimit * bdi_position_ratio()

> PS. I'm not criticizing your work, the results are impressive (as
> always), but I find it very hard to understand. 
> 
> PPS. If it would help, feel free to refer me to educational material on
> control system theory, either online or in books.

Fortunately no fancy control theory is used here ;) Only the simple
theory of negative feedback control is used, which states that there
will be overshoots and ringing if trying to correct the errors way too
fast.

The overshooting concept can be explained in the graph of the below page,
where the step response can be a sudden start of dd reader that took
away all the disk write bandwidth.

http://en.wikipedia.org/wiki/Step_response

In terms of the negative feedback control theory, the
bdi_position_ratio() function (control lines) can be expressed as

1) f(setpoint) = 1.0
2) df/dt < 0

3) optionally, abs(df/dt) should be large on large errors (= dirty -
   setpoint) in order to cancel the errors fast, and be smaller when
   dirty pages get closer to the setpoints in order to avoid overshooting.

The principle of (3) will be implemented in some follow up patches :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
