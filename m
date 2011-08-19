Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C3DFE6B0169
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 22:34:10 -0400 (EDT)
Date: Fri, 19 Aug 2011 10:34:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: Per-block device
 bdi->dirty_writeback_interval and bdi->dirty_expire_interval.
Message-ID: <20110819023406.GA12732@localhost>
References: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
 <20110818094824.GA25752@localhost>
 <1313669702.6607.24.camel@sauron>
 <20110818131343.GA17473@localhost>
 <CAFPAmTShNRykOEbUfRan_2uAAbBoRHE0RhOh4DrbWKq7a4-Z9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFPAmTShNRykOEbUfRan_2uAAbBoRHE0RhOh4DrbWKq7a4-Z9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Artem Bityutskiy <dedekind1@gmail.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

Hi Kautuk,

On Fri, Aug 19, 2011 at 12:25:58AM +0800, Kautuk Consul wrote:
> 
> Lines: 59
> 
> Hi Wu,
> 
> On Thu, Aug 18, 2011 at 6:43 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > Hi Artem,
> >
> >> Here is a real use-case we had when developing the N900 phone. We had
> >> internal flash and external microSD slot. Internal flash is soldered in
> >> and cannot be removed by the user. MicroSD, in contrast, can be removed
> >> by the user.
> >>
> >> For the internal flash we wanted long intervals and relaxed limits to
> >> gain better performance.
> >>
> >> For MicroSD we wanted very short intervals and tough limits to make sure
> >> that if the user suddenly removes his microSD (users do this all the
> >> time) - we do not lose data.
> >
> > Thinking twice about it, I find that the different requirements for
> > interval flash/external microSD can also be solved by this scheme.
> >
> > Introduce a per-bdi dirty_background_time (and optionally dirty_time)
> > as the counterpart of (and works in parallel to) global dirty[_background]_ratio,
> > however with unit "milliseconds worth of data".
> >
> > The per-bdi dirty_background_time will be set low for external microSD
> > and high for internal flash. Then you get timely writeouts for microSD
> > and reasonably delayed writes for internal flash (controllable by the
> > global dirty_expire_centisecs).
> >
> > The dirty_background_time will actually work more reliable than
> > dirty_expire_centisecs because it will checked immediately after the
> > application dirties more pages. And the dirty_time could provide
> > strong data integrity guarantee -- much stronger than
> > dirty_expire_centisecs -- if used.
> >
> > Does that sound reasonable?
> >
> > Thanks,
> > Fengguang
> >
> 
> My understanding of your email appears that you are agreeing in
> principle that the temporal
> aspect of this problem needs to be addressed along with your spatial
> pattern analysis technique.

Yup.

> I feel a more generic solution to the problem is required because the
> problem faced by Artem can appear
> in a different situation for a different application.
> 
> I can re-implement my original patch in either centiseconds or
> milliseconds as suggested by you.

My concern on your patch is the possible conflicts and confusions
between the global and the per-bdi dirty_expire_centisecs. To maintain
compatibility you need to keep the global one. Then there is the hard
question of "what to do with the per-bdi values when the global value
is changed". Whatever policy you choose, there will be user unexpected
behaviors.

I don't like such conflicting/inconsistent interfaces.

Given that we'll need to introduce the dirty_background_time interface
anyway, and it happen to can address the N900 internal/removable storage
problem (mostly), I'm more than glad to cancel the dirty_expire_centisecs
problem.

Or, do you have better way out of the dirty_expire_centisecs dilemma?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
