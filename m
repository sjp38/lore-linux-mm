Received: by py-out-1112.google.com with SMTP id d32so6196848pye
        for <linux-mm@kvack.org>; Mon, 17 Sep 2007 20:27:26 -0700 (PDT)
Message-ID: <170fa0d20709172027g3b83d606k6a8e641f71848c3@mail.gmail.com>
Date: Mon, 17 Sep 2007 23:27:25 -0400
From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <200709171728.26180.phillips@phunq.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070814142103.204771292@sgi.com>
	 <200709050916.04477.phillips@phunq.net>
	 <170fa0d20709072212m4563ce76sa83092640491e4f3@mail.gmail.com>
	 <200709171728.26180.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>, Wouter Verhelst <w@uter.be>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>
List-ID: <linux-mm.kvack.org>

On 9/17/07, Daniel Phillips <phillips@phunq.net> wrote:
> On Friday 07 September 2007 22:12, Mike Snitzer wrote:
> > Can you be specific about which changes to existing mainline code
> > were needed to make recursive reclaim "work" in your tests (albeit
> > less ideally than peterz's patchset in your view)?
>
> Sorry, I was incommunicado out on the high seas all last week.  OK, the
> measures that actually prevent our ddsnap driver from deadlocking are:

Hope you enjoyed yourself.  First off, as always thanks for the
extremely insightful reply.

To give you context for where I'm coming from; I'm looking to get NBD
to survive the mke2fs hell I described here:
http://marc.info/?l=linux-mm&m=118981112030719&w=2

>   - Statically prove bounded memory use of all code in the writeout
>     path.
>
>   - Implement any special measures required to be able to make such a
>     proof.

Once the memory requirements of a userspace daemon (e.g. nbd-server)
are known; should one mlockall() the memory similar to how is done in
heartbeat daemon's realtime library?

Bigger question for me is what kind of hell am I (or others) in for to
try to cap nbd-server's memory usage?  All those glib-gone-wild
changes over the recent past feel problematic but I'll look to work
with Wouter to see if we can get things bounded.

>   - All allocations performed by the block driver must have access
>     to dedicated memory resources.
>
>   - Disable the congestion_wait mechanism for our code as much as
>     possible, at least enough to obtain the maximum memory resources
>     that can be used on the writeout path.

Would peter's per bdi dirty page accounting patchset provide this?  If
not, what steps are you taking to disable this mechanism?  I've found
that nbd-server is frequently locked with 'blk_congestion_wait' in its
call trace when I hit the deadlock.

> The specific measure we implement in order to prove a bound is:
>
>   - Throttle IO on our block device to a known amount of traffic for
>     which we are sure that the MEMALLOC reserve will always be
>     adequate.

I've embraced Evgeniy's bio throttle patch on a 2.6.22.6 kernel
http://thread.gmane.org/gmane.linux.network/68021/focus=68552

But are you referring to that (as you did below) or is this more a
reference to peterz's bdi dirty accounting patchset?

> Note that the boundedness proof we use is somewhat loose at the moment.
> It goes something like "we only need at most X kilobytes of reserve and
> there are X megabytes available".  Much of Peter's patch set is aimed
> at getting more precise about this, but to be sure, handwaving just
> like this has been part of core kernel since day one without too many
> ill effects.
>
> The way we provide guaranteed access to memory resources is:
>
>   - Run critical daemons in PF_MEMALLOC mode, including
>     any userspace daemons that must execute in the block IO path
>    (cluster coders take note!)

I've been using Avi Kivity's patch from some time ago:
http://lkml.org/lkml/2004/7/26/68

to get nbd-server to to run in PF_MEMALLOC mode (could've just used
the _POSIX_PRIORITY_SCHEDULING hack instead right?)... it didn't help
on its own; I likely didn't have enough of the stars aligned to see my
MD+NBD mke2fs test not deadlock.

> Right now, all writeout submitted to ddsnap gets handed off to a daemon
> running in PF_MEMALLOC mode.  This is a needless inefficiency that we
> want to remove in future, and handle as many of those submissions as
> possible entirely in the context of the submitter.  To do this, further
> measures are needed:
>
>   - Network writes performed by the block driver must have access to
>     dedicated memory resources.

I assume peterz's network deadlock avoidance patchset (or some subset
of it) has you covered here?

> We have not yet managed to trigger network read memory deadlock, but it
> is just a matter of time, additional fancy virtual block devices, and
> enough stress.  So:
>
>   - Network reads need some fancy extra support because dedicated
>     memory resources must be consumed before knowing whether the
>     network traffic belongs to a block device or not.
>
> Now, the interesting thing about this whole discussion is, none of the
> measures that we are actually using at the moment are implemented in
> either Peter's or Christoph's patch set.  In other words, at present we
> do not require either patch set in order to run under heavy load
> without deadlocking.  But in order to generalize our solution to a
> wider range of virtual block devices and other problematic systems such
> as userspace filesystems, we need to incorporate a number of elements
> of Peter's patch set.
>
> As far as Christoph's proposal goes, it is not required to prevent
> deadlocks.   Whether or not it is a good optimization is an open
> question.

OK, yes I've included Christoph's recursive reclaim patch and didn't
have any luck either.  Good to know that patch isn't _really_ going to
help me.

> Of all the patches posted so far related to this work, the only
> indispensable one is the bio throttling patch developed by Evgeniy and
> I in a parallel thread.  The other essential pieces are all implemented
> in our block driver for now.  Some of those can be generalized and
> moved at least partially into core, and some cannot.

I've been working off-list (with Evgeniy's help!) to give the bio
throttling patch a try.  I hacked MD (md.c and raid1.c) to limit NBD
members to only 10 in-flight IOs.  Without this throttle I'd see up to
170 IOs on the raid1's nbd0 member; with it the IOs holds farely
constant at ~16.  But this didn't help my deadlock test either.  Also,
throttling in-flight IOs like this feels inherently sub-optimal.  Have
you taken any steps to make the 'bio-limit' dynamic in some way?

Anyway, I'm thinking I need to be stacking more/all of these things
together rather than trying them piece-wise.

I'm going to try adding all the things I've learned into the mix all
at once; including both of peterz's patchsets.  Peter, do you have a
git repo or website/ftp site for you r latest per-bdi and network
deadlock patchsets?  Pulling them out of LKML archives isn't "fun".

Also, I've noticed that the more recent network deadlock avoidance
patchsets haven't included NBD changes; any reason why these have been
dropped?  Should I just look to shoe-horn in previous NBD-oriented
patches from an earlier version of that patchset?

> I do need to write some sort of primer on this, because there is no
> fire-and-forget magic core kernel solution.  There are helpful things
> we can do in core, but some of it can only be implemented in the
> drivers themselves.

That would be quite helpful; all that I've learned has largely been
from your various posts (or others' responses to your posts).
Requires a hell of a lot of digging and ultimately I'm still missing
something.

In closing, if you (or others) are aware of a minimalist recipe that
would help me defeat this mke2fs MD+NBD deadlock test (as detailed in
my linux-mm post that I referenced above) I'd be hugely grateful.

thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
