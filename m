Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 2A5D76B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 21:07:40 -0400 (EDT)
Date: Sat, 22 Sep 2012 02:07:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
Message-ID: <20120922010733.GX11266@suse.de>
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de>
 <20120921180222.GA7220@phenom.dumpdata.com>
 <505CB9BC.8040905@linux.vnet.ibm.com>
 <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Fri, Sep 21, 2012 at 01:35:15PM -0700, Dan Magenheimer wrote:
> > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > Subject: Re: [RFC] mm: add support for zsmalloc and zcache
> > 
> > On 09/21/2012 01:02 PM, Konrad Rzeszutek Wilk wrote:
> > > On Fri, Sep 21, 2012 at 05:12:52PM +0100, Mel Gorman wrote:
> > >> On Tue, Sep 04, 2012 at 04:34:46PM -0500, Seth Jennings wrote:
> > >>> zcache is the remaining piece of code required to support in-kernel
> > >>> memory compression.  The other two features, cleancache and frontswap,
> > >>> have been promoted to mainline in 3.0 and 3.5 respectively.  This
> > >>> patchset promotes zcache from the staging tree to mainline.
> > 
> > >>
> > >> Very broadly speaking my initial reaction before I reviewed anything was
> > >> that *some* sort of usable backend for cleancache or frontswap should exist
> > >> at this point. My understanding is that Xen is the primary user of both
> > >> those frontends and ramster, while interesting, is not something that a
> > >> typical user will benefit from.
> > >
> > > Right, the majority of users do not use virtualization. Thought embedded
> > > wise .. well, there are a lot of Android users - thought I am not 100%
> > > sure they are using it right now (I recall seeing changelogs for the clones
> > > of Android mentioning zcache).
> > >>
> > >> That said, I worry that this has bounced around a lot and as Dan (the
> > >> original author) has a rewrite. I'm wary of spending too much time on this
> > >> at all. Is Dan's new code going to replace this or what? It'd be nice to
> > >> find a definitive answer on that.
> > >
> > > The idea is to take parts of zcache2 as seperate patches and stick it
> > > in the code you just reviewed (those that make sense as part of unstaging).
> > 
> > I agree with this.  Only the changes from zcache2 (Dan's
> > rewrite) that are necessary for promotion should be
> > considered right now.  Afaict, none of the concerns raised
> > in these comments are addressed by the changes in zcache2.
> 
> While I may agree with the proposed end result, this proposal
> is a _very_ long way away from a solution.  To me, it sounds like
> a "split the baby in half" proposal (cf. wisdom of Solomon)
> which may sound reasonable to some but, in the end, everyone loses.
> 

I tend to agree but this really is an unhappy situation that should be
resolved in the coming weeks instead of months if it's going to move
forward.

> I have proposed a reasonable compromise offlist to Seth, but
> it appears that it has been silently rejected; I guess it is
> now time to take the proposal public.  I apologize in advance
> for my characteristic bluntness...
> 

Meh, I'm ok with blunt.

> So let's consider two proposals and the pros and cons of them,
> before we waste any further mm developer time.  (Fortunately,
> most of Mel's insightful comments apply to both versions, though
> he did identify some of the design issues that led to zcache2!)
> 
> The two proposals:
> A) Recreate all the work done for zcache2 as a proper sequence of
>    independent patches and apply them to zcache1. (Seth/Konrad)
> B) Add zsmalloc back in to zcache2 as an alternative allocator
>    for frontswap pages. (Dan)

Throwing it out there but ....

C) Merge both, but freeze zcache1 except for critical fixes. Only allow
   future work on zcache2. Document limitations of zcache1 and
   workarounds until zcache2 is fully production ready.

> 
> Pros for (A):
> 1. It better preserves the history of the handful of (non-zsmalloc)
>    commits in the original zcache code.

Marginal benefit.

> 2. Seth[1] can incrementally learn the new designs by reading
>    normal kernel patches.

Which would be nice but that is not exactly compelling.

> 3. For kernel purists, it is the _right_ way dammit (and Dan
>    should be shot for redesigning code non-incrementally, even
>    if it was in staging, etc.)

Yes, but there are historical examples of ditching something completely
too. USB has been ditched a few times. Andrea shot a large chunk of the
VM out the window in 2.6.10. jbd vs jbd2 is still there.

> 4. Seth believes that zcache will be promoted out of staging sooner
>    because, except for a few nits, it is ready today.
> 

I wouldn't call them minor but it's probably better understood by more
people. It's why I'd be sortof ok with promoting zcache1 as long as
the limitations were clearly understood and there was a migration path
to zcache2.

> Cons for (A):
> 1. Nobody has signed up to do the work, including testing.  It
>    took the author (and sole expert on all the components
>    except zsmalloc) between two and three months essentially
>    fulltime to move zcache1->zcache2.  So forward progress on
>    zcache will likely be essentially frozen until at least the
>    end of 2012, possibly a lot longer.

This to me is a big issue. It's one reason why I think it would be ok for
zcache1 + zcache2 to exist in parallel but zcache1 would have to freeze for
this to be sensible. If zcache1 gained capabilities that zcache2 did *not*
have, it would be very problematic.

> 2. The end result (if we reach one) is almost certainly a
>    _third_ implementation of zcache: "zcache 1.5".  So
>    we may not be leveraging much of the history/testing
>    from zcache1 anyway!

Sod that.

> 3. Many of the zcache2 changes are closely interwoven so
>    a sequence of patches may not be much more incrementally
>    readable than zcache2.

Impossible for me to tell unfortunately. I'm too much of a newbie.

> 4. The merge with ramster will likely be very low priority
>    so the fork between the two will continue.

If zcache1 froze and ramaster supported only zcache2, it would be a path
to promotion for ramster, right?

> 5. Dan believes that, if zcache1 does indeed get promoted with
>    few or none of the zcache2 redesigns, zcache will never
>    get properly finished.
> 

This is the tricky part. If zcache1 gets promoted then zcache2 still needs
to go somewhere. My feeling is that we should promote both once testing
indicates that zcache2 does not regress in comparison to zcache1. It would
be nice to agree on what that testing would look like. I would like to
suggest MMTests with some configuration files because it should only take
a few hours to implement some zcache support. Other than the kernel
parameter this should not be a major problem. If it is, it actually
indicates that the feature is basically unusable for mere mortals :)

> Pros for (B):
> 1. Many of the design issues/constraints of zcache are resolved
>    in code that has already been tested approximately as well
>    as the original. All of the redesign (zcache1->zcache2) has
>    been extensively discussed on-list; only the code itself is
>    "non-incremental".

If zcache2 resolves some of the fundamental problems of zcache1 then it
cannot be ignored.

> 2. Both allocators (which AFAIK is the only technical area
>    of controversy) will be supported in the same codebase.
> 3. Dan (especially with help from Seth) can do the work in a
>    week or two, and then we can immediately move forward
>    doing useful work and adding features on a solid codebase.
> 4. Zcache2 already has the foundation in place for "reclaim
>    frontswap zpages", which mm experts have noted is a critical
>    requirement for broader zcache acceptance (e.g. KVM).

I, for one, am really concerned about the reclaim frontswap zpages
problem. I think it potentially leads to deadlock and if zcache2 deals
with it, that's great.

> 5. Ramster is already a small incremental addition to core zcache2 code
>    rather than a fork.  While many may ignore ramster as "not valuable",
>    it is the foundation for future related work so there's a reasonable
>    chance that some form of ramster will need to be merged in the future.
> 
> Cons for (B):
> 1. Seth [1] has to relearn some of the zcache2 code via diffs and
>    code reading instead of incremental patches.
> 2. Dan doesn't get properly punished for not doing incremental patches.
> 

Neither of those cons are compelling to me. zcache2 may require a full
review from scratch which is annoying but hardly insurmountable. Minimally
it should be possible to batter both with blackbox testing and at least
confirm that zcache2 does not regress in comparison to zcache1. If both
pass the same testing, promote both but freeze zcache1 and document the
limitations and do all future development on zcache2. People that are
currently supporting zcache1 can continue to do so and merge critical
fixes while migrating to zcache2 over time.

> [1] With all due respect, at this time, there are really only
> two people in the world that have a reasonably deep understanding
> of zcache and the technologies it's built on: Dan and Seth.

Which may be correct but I would expect that this would change once
something gets promoted out of staging.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
