Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 698F66B0062
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 16:35:32 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
Date: Fri, 21 Sep 2012 13:35:15 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de> <20120921180222.GA7220@phenom.dumpdata.com>
 <505CB9BC.8040905@linux.vnet.ibm.com>
In-Reply-To: <505CB9BC.8040905@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Mel Gorman <mgorman@suse.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [RFC] mm: add support for zsmalloc and zcache
>=20
> On 09/21/2012 01:02 PM, Konrad Rzeszutek Wilk wrote:
> > On Fri, Sep 21, 2012 at 05:12:52PM +0100, Mel Gorman wrote:
> >> On Tue, Sep 04, 2012 at 04:34:46PM -0500, Seth Jennings wrote:
> >>> zcache is the remaining piece of code required to support in-kernel
> >>> memory compression.  The other two features, cleancache and frontswap=
,
> >>> have been promoted to mainline in 3.0 and 3.5 respectively.  This
> >>> patchset promotes zcache from the staging tree to mainline.
>=20
> >>
> >> Very broadly speaking my initial reaction before I reviewed anything w=
as
> >> that *some* sort of usable backend for cleancache or frontswap should =
exist
> >> at this point. My understanding is that Xen is the primary user of bot=
h
> >> those frontends and ramster, while interesting, is not something that =
a
> >> typical user will benefit from.
> >
> > Right, the majority of users do not use virtualization. Thought embedde=
d
> > wise .. well, there are a lot of Android users - thought I am not 100%
> > sure they are using it right now (I recall seeing changelogs for the cl=
ones
> > of Android mentioning zcache).
> >>
> >> That said, I worry that this has bounced around a lot and as Dan (the
> >> original author) has a rewrite. I'm wary of spending too much time on =
this
> >> at all. Is Dan's new code going to replace this or what? It'd be nice =
to
> >> find a definitive answer on that.
> >
> > The idea is to take parts of zcache2 as seperate patches and stick it
> > in the code you just reviewed (those that make sense as part of unstagi=
ng).
>=20
> I agree with this.  Only the changes from zcache2 (Dan's
> rewrite) that are necessary for promotion should be
> considered right now.  Afaict, none of the concerns raised
> in these comments are addressed by the changes in zcache2.

While I may agree with the proposed end result, this proposal
is a _very_ long way away from a solution.  To me, it sounds like
a "split the baby in half" proposal (cf. wisdom of Solomon)
which may sound reasonable to some but, in the end, everyone loses.

I have proposed a reasonable compromise offlist to Seth, but
it appears that it has been silently rejected; I guess it is
now time to take the proposal public.  I apologize in advance
for my characteristic bluntness...

So let's consider two proposals and the pros and cons of them,
before we waste any further mm developer time.  (Fortunately,
most of Mel's insightful comments apply to both versions, though
he did identify some of the design issues that led to zcache2!)

The two proposals:
A) Recreate all the work done for zcache2 as a proper sequence of
   independent patches and apply them to zcache1. (Seth/Konrad)
B) Add zsmalloc back in to zcache2 as an alternative allocator
   for frontswap pages. (Dan)

Pros for (A):
1. It better preserves the history of the handful of (non-zsmalloc)
   commits in the original zcache code.
2. Seth[1] can incrementally learn the new designs by reading
   normal kernel patches.
3. For kernel purists, it is the _right_ way dammit (and Dan
   should be shot for redesigning code non-incrementally, even
   if it was in staging, etc.)
4. Seth believes that zcache will be promoted out of staging sooner
   because, except for a few nits, it is ready today.

Cons for (A):
1. Nobody has signed up to do the work, including testing.  It
   took the author (and sole expert on all the components
   except zsmalloc) between two and three months essentially
   fulltime to move zcache1->zcache2.  So forward progress on
   zcache will likely be essentially frozen until at least the
   end of 2012, possibly a lot longer.
2. The end result (if we reach one) is almost certainly a
   _third_ implementation of zcache: "zcache 1.5".  So
   we may not be leveraging much of the history/testing
   from zcache1 anyway!
3. Many of the zcache2 changes are closely interwoven so
   a sequence of patches may not be much more incrementally
   readable than zcache2.
4. The merge with ramster will likely be very low priority
   so the fork between the two will continue.
5. Dan believes that, if zcache1 does indeed get promoted with
   few or none of the zcache2 redesigns, zcache will never
   get properly finished.

Pros for (B):
1. Many of the design issues/constraints of zcache are resolved
   in code that has already been tested approximately as well
   as the original. All of the redesign (zcache1->zcache2) has
   been extensively discussed on-list; only the code itself is
   "non-incremental".
2. Both allocators (which AFAIK is the only technical area
   of controversy) will be supported in the same codebase.
3. Dan (especially with help from Seth) can do the work in a
   week or two, and then we can immediately move forward
   doing useful work and adding features on a solid codebase.
4. Zcache2 already has the foundation in place for "reclaim
   frontswap zpages", which mm experts have noted is a critical
   requirement for broader zcache acceptance (e.g. KVM).
5. Ramster is already a small incremental addition to core zcache2 code
   rather than a fork.  While many may ignore ramster as "not valuable",
   it is the foundation for future related work so there's a reasonable
   chance that some form of ramster will need to be merged in the future.

Cons for (B):
1. Seth [1] has to relearn some of the zcache2 code via diffs and
   code reading instead of incremental patches.
2. Dan doesn't get properly punished for not doing incremental patches.

[1] With all due respect, at this time, there are really only
two people in the world that have a reasonably deep understanding
of zcache and the technologies it's built on: Dan and Seth.
Seth admits less than thorough understanding of some of the
components (e.g. cleancache, zbud, tmem).  Dan admits poor
understanding of zsmalloc internals.

P.S.
For history on how the "fork" between zcache1 and zcache2 happened, see:
https://lkml.org/lkml/2012/8/16/617=20
For a high-level list of the redesign in zcache2, see:
https://lkml.org/lkml/2012/7/31/573=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
