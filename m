Received: by py-out-1112.google.com with SMTP id d32so7021617pye
        for <linux-mm@kvack.org>; Tue, 18 Sep 2007 13:13:10 -0700 (PDT)
Message-ID: <170fa0d20709181313t1de8b63cp7840542b9fd86b4d@mail.gmail.com>
Date: Tue, 18 Sep 2007 16:13:09 -0400
From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <200709181140.58256.phillips@phunq.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070814142103.204771292@sgi.com>
	 <200709171728.26180.phillips@phunq.net>
	 <170fa0d20709172027g3b83d606k6a8e641f71848c3@mail.gmail.com>
	 <200709181140.58256.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/18/07, Daniel Phillips <phillips@phunq.net> wrote:
> (Reposted after original was accidentally sent as html.  CC's deleted)
>
> On Monday 17 September 2007 20:27, Mike Snitzer wrote:
> > To give you context for where I'm coming from; I'm looking to get NBD
> > to survive the mke2fs hell I described here:
> > http://marc.info/?l=linux-mm&m=118981112030719&w=2
>
> The dread blk_congestion_wait is biting you hard.  We're very familiar
> with the feeling.  Congestion_wait is basically the traffic cop that
> implements the dirty page limit.  I believe it was conceived as a
> method of fixing writeout deadlocks, but in our experience it does not
> help, in fact it introduces a new kind of deadlock
> (blk_congestion_wait) that is much easier to trigger.  One of the
> things we do to get ddsnap running reliably is disable congestion_wait
> via the PF_LESS_THROTTLE hack that was introduced to stop local NFS
> clients from deadlocking.  NBD will need a similar treatment.

OK thanks, this helps me understand things a clearer.  I have
questions regarding PF_LESS_THROTTLE below.

> Actually, I hope to show quite soon that dirty page limiting is not
> needed at all in order to prevent writeout deadlock.  In which case we
> can just get rid of the dirty limits and go back to being able to use
> all of non-reserve memory as a write cache, the way things used to be
> in the days of yore.
>
> It has been pointed out to me that congestion_wait not only enforces
> the dirty limit, it controls the balancing of memory resources between
> slow and fast block devices.  The Peterz/Phillips approach to deadlock
> prevention does not provide any such balancing and so it seems to me
> that congestion_wait is ideally situated in the kernel to provide that
> missing functionality.  As I see it, blk_congestion_wait can easily be
> modified to balance the _rate_ at which cache memory is dirtied for
> various block devices of different speeeds.  This should turn out to
> be less finicky than balancing the absolute ratios, after all you can
> make a lot of mistakes in rate limiting and still not deadlock so long
> as dirty rate doesn't drop to zero and stay there for any block
> device.  Gotta be easy, hmm?
>
> Please note: this plan is firmly in the category of speculation until
> we have actually tried it and have patches to show, but I thought that
> now  is about the right time to say something about where we think
> this storage robustness work is headed.

It is reassuring that the end is in sight but it sounds like a
considerable amount of work needs to be done to prove to others that
such changes are needed.  One thing that is painfully clear is that
this line of work is _not_ a high priority for the maintainers.  Your
and Peter Z's work has been coldly received more often than not by
individuals who quite clearly haven't suffered the wrath of the
existing VM's propensity to deadlock once network resources are
required for writeback.

> > >   - All allocations performed by the block driver must have access
> > >     to dedicated memory resources.
> > >
> > >   - Disable the congestion_wait mechanism for our code as much as
> > >     possible, at least enough to obtain the maximum memory
> > > resources that can be used on the writeout path.
> >
> > Would peter's per bdi dirty page accounting patchset provide this?
> > If not, what steps are you taking to disable this mechanism?  I've
> > found that nbd-server is frequently locked with 'blk_congestion_wait'
> > in its call trace when I hit the deadlock.
>
> See PF_LESS_THROTTLE.   Also notice that this mechanism is somewhat
> less than general.  In mainline it only has one user, NFS, and it only
> can have one user before you have to fiddle that code to create things
> like PF_EVEN_LESS_THROTTLE.

So while PF_LESS_THROTTLE seems quite promising/necessary to help me
overcome my current MD+NBD deadlock I'm missing how it can _really_
work if only one task can have PF_LESS_THROTTLE set.

In fact, I'm not seeing where this "single-consumer" constraint is imposed.
mm/page-writeback.c's get_dirty_limits() is the only code in the only
code that takes action if PF_LESS_THROTTLE is set:
        if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
                background += background / 4;
                dirty += dirty / 4;
        }

So what mechanism in the kernel is preventing me from having all
userspace nbd-server instances (each associated with a unique block
device) from setting PF_LESS_THROTTLE?  In order for this workaround
to fly each nbd-server instance needs to be throttled less (relative
to the normal dirty_ratio); correct?

> As far as I can see, not having any dirty page limit for normal
> allocations is the way to go, it avoids this mess nicely.  Now we just
> need to prove that this works ;-)

Yes, I'm interested to see how things evolve in this area.

> > > The specific measure we implement in order to prove a bound is:
> > >
> > >   - Throttle IO on our block device to a known amount of traffic
> > > for which we are sure that the MEMALLOC reserve will always be
> > > adequate.
> >
> > I've embraced Evgeniy's bio throttle patch on a 2.6.22.6 kernel
> > http://thread.gmane.org/gmane.linux.network/68021/focus=68552
> >
> > But are you referring to that (as you did below) or is this more a
> > reference to peterz's bdi dirty accounting patchset?
>
> No, it's a patch I wrote based on Evgeniy's original, that appeared
> quietly later in the thread.  At the time we hadn't tested it and now
> we have.  It works fine, it's short, general, efficient and easy to
> understand.  So it will get a post of its own pretty soon.

I couldn't find a patch from you in that thread.  Any chance you could
send me the patch offlist?  Either that or please send a pointer to
the post in an lkml archive?

> > > The way we provide guaranteed access to memory resources is:
> > >
> > >   - Run critical daemons in PF_MEMALLOC mode, including
> > >     any userspace daemons that must execute in the block IO path
> > >    (cluster coders take note!)
> >
> > I've been using Avi Kivity's patch from some time ago:
> > http://lkml.org/lkml/2004/7/26/68
>
> Yes.  Ddsnap includes a bit of code almost identical to that, which we
> wrote independently.  Seems wild and crazy at first blush, doesn't it?
> But this approach has proved robust in practice, and is to my mind,
> obviously correct.
>
> > to get nbd-server to to run in PF_MEMALLOC mode (could've just used
> > the _POSIX_PRIORITY_SCHEDULING hack instead right?)... it didn't help
> > on its own; I likely didn't have enough of the stars aligned to see
> > my MD+NBD mke2fs test not deadlock.
>
> You do need the block IO throttling, and you need to bypass the dirty
> page limiting.
>
> Without throttling, your block driver will quickly consume any amount
> of reserve memory you have, and you are dead.

So I used the attached patch (depends on Evgeniy's throttle patch) to
throttle just the raid1's nbd member.  The thinking being that the
raid1 MD virtual layer will only be able to proceed as far as its
slowest member; so if I confined the throttling to just the NBD member
it should constrain the MD device as well.  In practice I saw that the
in-flight IOs for the local member were still at the normal ~160 level
while the nbd member's in-flight IOs were ~16.

DO I need to throttle _all_ physical members of the MD (local and
nbd)?  And even then is filtering the physical devices below the MD
still prone to deadlock?  I quickly read through the numerous
exchanges you and Evgeniy had related to his proposed throttle patch.
The way you left it was his patch wasn't adequate; and he disagreed...

> Without an exemption
> from dirty page limiting, the number of pages your user space daemon
> can allocate without deadlocking is zero, which makes life very
> difficult.
>
> I will post our in-production version of the throttling patch in a day
> or two.

OK, please do.  I'd imagine it is what zumastor's ddsnap.c does?  I
saw that is where you limit to 1000 in-flight pages.  So are you
working to pull that body of work out of the ddsnap driver and pushing
it into the generic to the DM layer?

> > > Of all the patches posted so far related to this work, the only
> > > indispensable one is the bio throttling patch developed by Evgeniy
> > > and I in a parallel thread.  The other essential pieces are all
> > > implemented in our block driver for now.  Some of those can be
> > > generalized and moved at least partially into core, and some
> > > cannot.
> >
> > I've been working off-list (with Evgeniy's help!) to give the bio
> > throttling patch a try.  I hacked MD (md.c and raid1.c) to limit NBD
> > members to only 10 in-flight IOs.  Without this throttle I'd see up
> > to 170 IOs on the raid1's nbd0 member; with it the IOs holds farely
> > constant at ~16.  But this didn't help my deadlock test either.
> > Also, throttling in-flight IOs like this feels inherently
> > sub-optimal.  Have you taken any steps to make the 'bio-limit'
> > dynamic in some way?
>
> Yes, at least for device mapper devices.  In our production device
> mapper throttling patch, which I will post pretty soon, we provide an
> aribitrary limit by default, and the device mapper device may change
> it in its constructor method.  Something similar should work for NBD.
>
> As far as sub-optimal throughput goes, we run with a limit of 1,000
> bvecs in flight (about 4 MB) and that does not seem to restrict
> throughput measurably.

OK, good to know.  I look forward to getting my hands on your DM
throttling patch.

> Though you also need this throttling, it is apparent from the traceback
> you linked above that you ran around on blk_congestion_wait.   Try
> setting your user space daemon into PF_LESS_THOTTLE mode and see what
> happens.
>
> > Anyway, I'm thinking I need to be stacking more/all of these things
> > together rather than trying them piece-wise.
>
> A vm dagwood sandwich, I hope it tastes good :-)

Tastes horribly!

> Well, pretty soon we will join you in the NBD rehabilitation effort
> because we require it for the next round of storage work, which
> centers around the ddraid distributed block device.  This requires an
> NBD that functions reliably, even when accessing an exported block
> device locally.

NBD couldn't be rehabilitated soon enough; I welcome any advances that
will help realize this.  But what are your thoughts on embracing
Evgeniy's distributed storage in addition to NBD?  I like the fact
that DST's server is in-kernel.  Granted nbd's server could be made
in-kernel too.

> > In closing, if you (or others) are aware of a minimalist recipe that
> > would help me defeat this mke2fs MD+NBD deadlock test (as detailed in
> > my linux-mm post that I referenced above) I'd be hugely grateful.
>
> Seeing as we have a virtually identical target configuration in mind,
> you can expect quite a lot of help from our direction in the near
> future, and in the mean time we can provide encouragement, information
> and perhaps a few useful lines of code.

Sounds great.

thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
