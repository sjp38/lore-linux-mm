Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id F2CC16B01F4
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 17:47:41 -0500 (EST)
Date: Tue, 13 Dec 2011 09:47:37 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: XFS causing stack overflow
Message-ID: <20111212224737.GS14273@dastard>
References: <20111209221956.GE14273__25752.826271537$1323469420$gmane$org@dastard>
 <m262hop5kc.fsf@firstfloor.org>
 <20111210221345.GG14273@dastard>
 <20111211000036.GH24062@one.firstfloor.org>
 <20111211230511.GH14273@dastard>
 <20111212023130.GI24062@one.firstfloor.org>
 <20111212043657.GO14273@dastard>
 <20111212051311.GJ24062@one.firstfloor.org>
 <20111212090033.GQ14273@dastard>
 <CAAnfqPC0Ed=PDUOowGTEZyfqHFjB3Jj2YNAaxuYqA2+wVb6tSA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAnfqPC0Ed=PDUOowGTEZyfqHFjB3Jj2YNAaxuYqA2+wVb6tSA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ryan C. England" <ryan.england@corvidtec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, xfs@oss.sgi.com

On Mon, Dec 12, 2011 at 08:43:57AM -0500, Ryan C. England wrote:
> On Mon, Dec 12, 2011 at 4:00 AM, Dave Chinner <david@fromorbit.com> wrote:
> > On Mon, Dec 12, 2011 at 06:13:11AM +0100, Andi Kleen wrote:
> > > BTW I suppose it wouldn't be all that hard to add more stacks and
> > > switch to them too, similar to what the 32bit do_IRQ does.
> > > Perhaps XFS could just allocate its own stack per thread
> > > (or maybe only if it detects some specific configuration that
> > > is known to need much stack)
> >
> > That's possible, but rather complex, I think.
> > > It would need to be per thread if you could sleep inside them.
> >
> > Yes, we'd need to sleep, do IO, possibly operate within a
> > transaction context, etc, and a workqueue handles all these cases
> > without having to do anything special. Splitting the stack at a
> > logical point is probably better, such as this patch:
> >
> > http://oss.sgi.com/archives/xfs/2011-07/msg00443.html
>
> Is it possible to apply this patch to my current installation?  We use this
> box in production and the reboots that we're experiencing are an
> inconvenience.

Not easily. The problem with a backport is that the workqueue
infrastructure changed around 2.6.36, allowing workqueues to act
like an (almost) infinite pool of worker threads and so by using a
workqueue we can have effectively unlimited numbers of concurrent
allocations in progress at once.

The workqueue implementation in 2.6.32 only allows a single work
instance per workqueue thread, and so even with per-CPU worker
threads, would only allow one allocation at a time per CPU. This
adds additional serialisation within a filesystem, between
filesystem and potentially adds new deadlock conditions as well.

So it's not exactly obvious whether it can be backported in a sane
manner or not.

> Is there is a walkthrough on how to apply this patch?  If not, could your
> provide the steps necessary to apply successfully?  I would greatly
> appreciate it.

It would probably need redesigning and re-implementing from scratch
because of the above reasons. It'd then need a lot of testing and
review. As a workaround, you might be better off doing what Andi
first suggested - recompiling your kernel to use 16k stacks.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
