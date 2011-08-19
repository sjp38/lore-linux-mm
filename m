Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 263036B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 01:28:44 -0400 (EDT)
Date: Fri, 19 Aug 2011 13:28:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: Per-block device
 bdi->dirty_writeback_interval and bdi->dirty_expire_interval.
Message-ID: <20110819052839.GB28266@localhost>
References: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
 <20110818094824.GA25752@localhost>
 <1313669702.6607.24.camel@sauron>
 <20110818131343.GA17473@localhost>
 <CAFPAmTShNRykOEbUfRan_2uAAbBoRHE0RhOh4DrbWKq7a4-Z9Q@mail.gmail.com>
 <20110819023406.GA12732@localhost>
 <CAFPAmTSzYg5n150_ykv-Vvc4QVbz14Oxn_Mm+EqxzbUL3c39tg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFPAmTSzYg5n150_ykv-Vvc4QVbz14Oxn_Mm+EqxzbUL3c39tg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Artem Bityutskiy <dedekind1@gmail.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

On Fri, Aug 19, 2011 at 12:38:36PM +0800, Kautuk Consul wrote:
> HI Wu,
> 
> On Fri, Aug 19, 2011 at 8:04 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > Hi Kautuk,
> >
> > On Fri, Aug 19, 2011 at 12:25:58AM +0800, Kautuk Consul wrote:
> >>
> >> Lines: 59
> >>
> >> Hi Wu,
> >>
> >> On Thu, Aug 18, 2011 at 6:43 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> >> > Hi Artem,
> >> >
> >> >> Here is a real use-case we had when developing the N900 phone. We had
> >> >> internal flash and external microSD slot. Internal flash is soldered in
> >> >> and cannot be removed by the user. MicroSD, in contrast, can be removed
> >> >> by the user.
> >> >>
> >> >> For the internal flash we wanted long intervals and relaxed limits to
> >> >> gain better performance.
> >> >>
> >> >> For MicroSD we wanted very short intervals and tough limits to make sure
> >> >> that if the user suddenly removes his microSD (users do this all the
> >> >> time) - we do not lose data.
> >> >
> >> > Thinking twice about it, I find that the different requirements for
> >> > interval flash/external microSD can also be solved by this scheme.
> >> >
> >> > Introduce a per-bdi dirty_background_time (and optionally dirty_time)
> >> > as the counterpart of (and works in parallel to) global dirty[_background]_ratio,
> >> > however with unit "milliseconds worth of data".
> >> >
> >> > The per-bdi dirty_background_time will be set low for external microSD
> >> > and high for internal flash. Then you get timely writeouts for microSD
> >> > and reasonably delayed writes for internal flash (controllable by the
> >> > global dirty_expire_centisecs).
> >> >
> >> > The dirty_background_time will actually work more reliable than
> >> > dirty_expire_centisecs because it will checked immediately after the
> >> > application dirties more pages. And the dirty_time could provide
> >> > strong data integrity guarantee -- much stronger than
> >> > dirty_expire_centisecs -- if used.
> 
> The dirty_writeback_centisecs is the value we are also actually
> interested in, and not just
> dirty_expire_interval. This value is what is actually used to reset
> the per-BDI timeout in the code.

Yes. I assumed if one reduced dirty_expire_centisecs, he may well want
to reduce dirty_writeback_centisecs.

> >> >
> >> > Does that sound reasonable?
> >> >
> >> > Thanks,
> >> > Fengguang
> >> >
> >>
> >> My understanding of your email appears that you are agreeing in
> >> principle that the temporal
> >> aspect of this problem needs to be addressed along with your spatial
> >> pattern analysis technique.
> >
> > Yup.
> >
> >> I feel a more generic solution to the problem is required because the
> >> problem faced by Artem can appear
> >> in a different situation for a different application.
> >>
> >> I can re-implement my original patch in either centiseconds or
> >> milliseconds as suggested by you.
> >
> > My concern on your patch is the possible conflicts and confusions
> > between the global and the per-bdi dirty_expire_centisecs. To maintain
> > compatibility you need to keep the global one. Then there is the hard
> 
> If you refer to my original email, I have addressed this as follows:
> When the global value is set, then all the per-BDI dirty*_centisecs
> are also reset
> to the global value.
> This is essential for retaining the functionality across Linux
> distributions using
> the global values.
> This amounts to compatibility as the global values will take effect.
> After that point, if the user/admin feels, he/she can adjust/tune the
> per-BDI counters to
> certain empirical value as per the specific application. This will not
> alter the global values.

Such "resetting all" behavior could be disgusting. Some users without
the global view may be puzzled why their set value is lost.

A better scheme would be to use the bdi value if it's non-zero, and
fall back to the global value otherwise. This will reduce complexity
of the code as well as interface.

> > Given that we'll need to introduce the dirty_background_time interface
> > anyway, and it happen to can address the N900 internal/removable storage
> > problem (mostly), I'm more than glad to cancel the dirty_expire_centisecs
> > problem.
> >
> 
> I have following doubts with respect to your dirty_background_time
> interface suggestion:
> i)   You say that you'll do this only for the N900 problem for solving
> the unexpected disk removal
>       problem.
>       I believe you are ignoring the problem of rate of undirtying of
> the block device pages for
>       making reclamation of that block device's file-cache pages at a
> sooner possible future time.
>       I mentioned this in my earlier emails also.

I care the dirty page reclaim problem a lot, however this patch is
fundamentally not the right answer to that problem.

> ii)   Will you be changing the dirty_background_time dynamically with
> your algorithm ?
>       According to your description, I think not.

dirty_background_time will be some static value.

> iii)  I cannot see how your implementation of dirty_background_time is
> different from mine, except
>       maybe for the first time interval taking effect properly.

dirty_background_time will be the analog to dirty_background_ratio.

dirty_background_ratio/dirty_ratio and
dirty_writeback_centisecs/dirty_expire_centisecs is as different as
apple and orange.

>       However, we can also think that the first time interval should
> probably be honoured with the older
>       value to make the transition from the old timer value to new
> timer value smoother in terms of
>       periodic writeback functionality.

There is no "interval" thing for dirty_background_time.
(I'll show you the implementation tomorrow.)

> > Or, do you have better way out of the dirty_expire_centisecs dilemma?
> >
> 
> Maybe we can delete the global value entirely. However as you
> correctly mentioned above, this
> will impact other tools distributions altering these global values.

Right. Deleting existing interfaces are NOT an option.

> You mentioned the close relationship between the dirty_background_time
> and the global dirty
> [_background]_ratio.
> Do you mean to say that you intend to change the dirty_background_time
> based on changes to
> the dirty_background_ratio ?
> Since the global dirty_background_ratio doesn't result in changes to
> the dirty_writeback_centisecs
> wouldn't this amount to a radical change in the existing relationship
> of these configurable values ?

dirty_background_time will be complementing dirty_background_ratio.
One will be adaptive to device bandwidth, the other to memory size.

The users typically don't want to accumulate many dirty pages to eat
up the memory, or take too much time to writeout.

So it's very natural to introduce dirty_background_time to fill the gap.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
