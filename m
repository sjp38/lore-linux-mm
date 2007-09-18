Received: from ip6-localhost ([::1] helo=phunq.net)
	by moonbase.phunq.net with esmtp (Exim 4.63)
	(envelope-from <phillips@phunq.net>)
	id 1IXi0I-0004C2-MB
	for linux-mm@kvack.org; Tue, 18 Sep 2007 11:40:58 -0700
From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
References: <20070814142103.204771292@sgi.com> <200709171728.26180.phillips@phunq.net> <170fa0d20709172027g3b83d606k6a8e641f71848c3@mail.gmail.com>
In-Reply-To: <170fa0d20709172027g3b83d606k6a8e641f71848c3@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
Date: Tue, 18 Sep 2007 11:40:58 -0700
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200709181140.58256.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(Reposted after original was accidentally sent as html.  CC's deleted)

On Monday 17 September 2007 20:27, Mike Snitzer wrote:
> To give you context for where I'm coming from; I'm looking to get NBD
> to survive the mke2fs hell I described here:
> http://marc.info/?l=linux-mm&m=118981112030719&w=2

The dread blk_congestion_wait is biting you hard.  We're very familiar
with the feeling.  Congestion_wait is basically the traffic cop that
implements the dirty page limit.  I believe it was conceived as a
method of fixing writeout deadlocks, but in our experience it does not
help, in fact it introduces a new kind of deadlock
(blk_congestion_wait) that is much easier to trigger.  One of the
things we do to get ddsnap running reliably is disable congestion_wait
via the PF_LESS_THROTTLE hack that was introduced to stop local NFS
clients from deadlocking.  NBD will need a similar treatment.

Actually, I hope to show quite soon that dirty page limiting is not
needed at all in order to prevent writeout deadlock.  In which case we
can just get rid of the dirty limits and go back to being able to use
all of non-reserve memory as a write cache, the way things used to be
in the days of yore.

It has been pointed out to me that congestion_wait not only enforces
the dirty limit, it controls the balancing of memory resources between
slow and fast block devices.  The Peterz/Phillips approach to deadlock
prevention does not provide any such balancing and so it seems to me
that congestion_wait is ideally situated in the kernel to provide that
missing functionality.  As I see it, blk_congestion_wait can easily be
modified to balance the _rate_ at which cache memory is dirtied for
various block devices of different speeeds.  This should turn out to
be less finicky than balancing the absolute ratios, after all you can
make a lot of mistakes in rate limiting and still not deadlock so long
as dirty rate doesn't drop to zero and stay there for any block
device.  Gotta be easy, hmm?

Please note: this plan is firmly in the category of speculation until
we have actually tried it and have patches to show, but I thought that
now  is about the right time to say something about where we think
this storage robustness work is headed.

> >   - Statically prove bounded memory use of all code in the writeout
> >     path.
> >
> >   - Implement any special measures required to be able to make such
> > a proof.
>
> Once the memory requirements of a userspace daemon (e.g. nbd-server)
> are known; should one mlockall() the memory similar to how is done in
> heartbeat daemon's realtime library?

Yes, and also inspect the code to ensure it doesn't violate mlock_all
by execing programs (no shell scripts!), dynamically loading
libraries, etc.

> Bigger question for me is what kind of hell am I (or others) in for
> to try to cap nbd-server's memory usage?  All those glib-gone-wild
> changes over the recent past feel problematic but I'll look to work
> with Wouter to see if we can get things bounded.

Avoiding glib is a good start.  Look at your library dependencies and
prune them merclilessly.  Just don't use any libraries that you can
code up yourself in a few hundred bytes of program text for the
functionalituy you need.

> >   - All allocations performed by the block driver must have access
> >     to dedicated memory resources.
> >
> >   - Disable the congestion_wait mechanism for our code as much as
> >     possible, at least enough to obtain the maximum memory
> > resources that can be used on the writeout path.
>
> Would peter's per bdi dirty page accounting patchset provide this?
> If not, what steps are you taking to disable this mechanism?  I've
> found that nbd-server is frequently locked with 'blk_congestion_wait'
> in its call trace when I hit the deadlock.

See PF_LESS_THROTTLE.   Also notice that this mechanism is somewhat
less than general.  In mainline it only has one user, NFS, and it only
can have one user before you have to fiddle that code to create things
like PF_EVEN_LESS_THROTTLE.

As far as I can see, not having any dirty page limit for normal
allocations is the way to go, it avoids this mess nicely.  Now we just
need to prove that this works ;-)

> > The specific measure we implement in order to prove a bound is:
> >
> >   - Throttle IO on our block device to a known amount of traffic
> > for which we are sure that the MEMALLOC reserve will always be
> > adequate.
>
> I've embraced Evgeniy's bio throttle patch on a 2.6.22.6 kernel
> http://thread.gmane.org/gmane.linux.network/68021/focus=68552
>
> But are you referring to that (as you did below) or is this more a
> reference to peterz's bdi dirty accounting patchset?

No, it's a patch I wrote based on Evgeniy's original, that appeared
quietly later in the thread.  At the time we hadn't tested it and now
we have.  It works fine, it's short, general, efficient and easy to
understand.  So it will get a post of its own pretty soon.

> > Note that the boundedness proof we use is somewhat loose at the
> > moment. It goes something like "we only need at most X kilobytes of
> > reserve and there are X megabytes available".  Much of Peter's
> > patch set is aimed at getting more precise about this, but to be
> > sure, handwaving just like this has been part of core kernel since
> > day one without too many ill effects.
> >
> > The way we provide guaranteed access to memory resources is:
> >
> >   - Run critical daemons in PF_MEMALLOC mode, including
> >     any userspace daemons that must execute in the block IO path
> >    (cluster coders take note!)
>
> I've been using Avi Kivity's patch from some time ago:
> http://lkml.org/lkml/2004/7/26/68

Yes.  Ddsnap includes a bit of code almost identical to that, which we
wrote independently.  Seems wild and crazy at first blush, doesn't it?
But this approach has proved robust in practice, and is to my mind,
obviously correct.

> to get nbd-server to to run in PF_MEMALLOC mode (could've just used
> the _POSIX_PRIORITY_SCHEDULING hack instead right?)... it didn't help
> on its own; I likely didn't have enough of the stars aligned to see
> my MD+NBD mke2fs test not deadlock.

You do need the block IO throttling, and you need to bypass the dirty
page limiting.

Without throttling, your block driver will quickly consume any amount
of reserve memory you have, and you are dead.  Without an exemption
from dirty page limiting, the number of pages your user space daemon
can allocate without deadlocking is zero, which makes life very
difficult.

I will post our in-production version of the throttling patch in a day
or two.

> > Right now, all writeout submitted to ddsnap gets handed off to a
> > daemon running in PF_MEMALLOC mode.  This is a needless
> > inefficiency that we want to remove in future, and handle as many
> > of those submissions as possible entirely in the context of the
> > submitter.  To do this, further measures are needed:
> >
> >   - Network writes performed by the block driver must have access
> > to dedicated memory resources.
>
> I assume peterz's network deadlock avoidance patchset (or some subset
> of it) has you covered here?

Yes.

> > Of all the patches posted so far related to this work, the only
> > indispensable one is the bio throttling patch developed by Evgeniy
> > and I in a parallel thread.  The other essential pieces are all
> > implemented in our block driver for now.  Some of those can be
> > generalized and moved at least partially into core, and some
> > cannot.
>
> I've been working off-list (with Evgeniy's help!) to give the bio
> throttling patch a try.  I hacked MD (md.c and raid1.c) to limit NBD
> members to only 10 in-flight IOs.  Without this throttle I'd see up
> to 170 IOs on the raid1's nbd0 member; with it the IOs holds farely
> constant at ~16.  But this didn't help my deadlock test either.
> Also, throttling in-flight IOs like this feels inherently
> sub-optimal.  Have you taken any steps to make the 'bio-limit'
> dynamic in some way?

Yes, at least for device mapper devices.  In our production device
mapper throttling patch, which I will post pretty soon, we provide an
aribitrary limit by default, and the device mapper device may change
it in its constructor method.  Something similar should work for NBD.

As far as sub-optimal throughput goes, we run with a limit of 1,000
bvecs in flight (about 4 MB) and that does not seem to restrict
throughput measurably.

Though you also need this throttling, it is apparent from the traceback
you linked above that you ran around on blk_congestion_wait.   Try
setting your user space daemon into PF_LESS_THOTTLE mode and see what
happens.

> Anyway, I'm thinking I need to be stacking more/all of these things
> together rather than trying them piece-wise.

A vm dagwood sandwich, I hope it tastes good :-)

Well, pretty soon we will join you in the NBD rehabilitation effort
because we require it for the next round of storage work, which
centers around the ddraid distributed block device.  This requires an
NBD that functions reliably, even when accessing an exported block
device locally.

> I'm going to try adding all the things I've learned into the mix all
> at once; including both of peterz's patchsets.  Peter, do you have a
> git repo or website/ftp site for you r latest per-bdi and network
> deadlock patchsets?  Pulling them out of LKML archives isn't "fun".
>
> Also, I've noticed that the more recent network deadlock avoidance
> patchsets haven't included NBD changes; any reason why these have
> been dropped?  Should I just look to shoe-horn in previous
> NBD-oriented patches from an earlier version of that patchset?

I thought Peter was swapping over NBD?  Anyway, we have not moved into
the NBD problem yet because we are still busy chasing
non-deadlock-related ddsnap bugs.  Which require increasingly creative
efforts to trigger by the way, but we haven't quite run out of new
bugs, so we don't get to play with distributed storage just yet.

> > I do need to write some sort of primer on this, because there is no
> > fire-and-forget magic core kernel solution.  There are helpful
> > things we can do in core, but some of it can only be implemented in
> > the drivers themselves.
>
> That would be quite helpful; all that I've learned has largely been
> from your various posts (or others' responses to your posts).
> Requires a hell of a lot of digging and ultimately I'm still missing
> something.
>
> In closing, if you (or others) are aware of a minimalist recipe that
> would help me defeat this mke2fs MD+NBD deadlock test (as detailed in
> my linux-mm post that I referenced above) I'd be hugely grateful.

Seeing as we have a virtually identical target configuration in mind,
you can expect quite a lot of help from our direction in the near
future, and in the mean time we can provide encouragement, information
and perhaps a few useful lines of code.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
