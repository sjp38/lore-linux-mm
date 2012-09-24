Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id CAA0D6B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 16:37:08 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f0890e7c-9f9f-4110-8da9-05d0fdf7f91c@default>
Date: Mon, 24 Sep 2012 13:36:48 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de> <20120921180222.GA7220@phenom.dumpdata.com>
 <505CB9BC.8040905@linux.vnet.ibm.com>
 <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
 <20120922010733.GX11266@suse.de>
 <589fd823-40f1-418c-81ad-ca8daa3f064d@default>
 <20120924103150.GA11266@suse.de>
In-Reply-To: <20120924103150.GA11266@suse.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Mel Gorman [mailto:mgorman@suse.de]
> Subject: Re: [RFC] mm: add support for zsmalloc and zcache
>=20
> On Sat, Sep 22, 2012 at 02:18:44PM -0700, Dan Magenheimer wrote:
> > > From: Mel Gorman [mailto:mgorman@suse.de]
> > > Subject: Re: [RFC] mm: add support for zsmalloc and zcache
> > >
> > > On Fri, Sep 21, 2012 at 01:35:15PM -0700, Dan Magenheimer wrote:
> > > > > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > > > > Subject: Re: [RFC] mm: add support for zsmalloc and zcache
> > > > The two proposals:
> > > > A) Recreate all the work done for zcache2 as a proper sequence of
> > > >    independent patches and apply them to zcache1. (Seth/Konrad)
> > > > B) Add zsmalloc back in to zcache2 as an alternative allocator
> > > >    for frontswap pages. (Dan)
> > >
> > > Throwing it out there but ....
> > >
> > > C) Merge both, but freeze zcache1 except for critical fixes. Only all=
ow
> > >    future work on zcache2. Document limitations of zcache1 and
> > >    workarounds until zcache2 is fully production ready.
> >
> What would the impact be if zcache2 and zcache1 were mutually exclusive
> in Kconfig and the naming was as follows?
>=20
> CONFIG_ZCACHE_DEPRECATED=09(zcache1)
> CONFIG_ZCACHE=09=09=09(zcache2)
>=20
> That would make it absolutely clear to distributions which one they shoul=
d
> be enabling and also make it clear that all future development happen
> on zcache2.
>=20
> I know it looks insane to promote something that is instantly deprecated
> but none of the other alternatives seem to be gaining traction either.
> This would at least allow the people who are currently heavily behind
> zcache1 to continue supporting it and applying critical fixes until they
> move to zcache2.

Just wondering... how, in your opinion, is this different from
leaving zcache1 (or even both) in staging?  "Tainting" occurs
either way, it's just a matter of whether or not there is a message
logged by the kernel that it is officially tainted, right?

However, it _is_ another attempt at compromise and, if this
is the only solution that allows the debate to end, and it
is agreed on by whatever maintainer is committed to pull
both (be it you, or Andrew, or Konrad, or Linux), I would
agree to your "C-prime" proposal.
=20
> > I use the terms "zcache1" and "zcache2" only to clarify which
> > codebase, not because they are dramatically different. I estimate
> > that 85%-90% of the code in zcache1 and zcache2 is identical, not
> > counting the allocator or comments/whitespace/janitorial!
>=20
> If 85-90% of the code is identicial then they really should be sharing
> the code rather than making copies. That will result in some monolithic
> patches but it's unavoidable. I expect it would end up looking like
>=20
> Patch 1=09=09promote zcache1
> Patch 2=09=09promote zcache2
> Patch 3=09=09move shared code for zcache1,zcache2 to common files
>=20
> If the shared code is really shared and not copied it may reduce some of
> the friction between the camps.

This part I would object to... at least I would object to signing
up to do Patch 3 myself.  Seems like a lot of busywork if zcache1
is truly deprecated.

> zcache1 does appear to have a few snarls that would make me wary of havin=
g
> to support it. I don't know if zcache2 suffers the same problems or not
> as I have not read it.
>=20
> Unfortunately, I'm not going to get the chance to review [zcache2] in the
> short-term. However, if zcache1 and zcache2 shared code in common files
> it would at least reduce the amount of new code I have to read :)

Understood, which re-emphasizes my point about how the presence
of both reduces the (to date, very limited) MM developer time available
for either.

> > Seth (and IBM) seems to have a bee in his bonnet that the existing
> > zcache1 code _must_ be promoted _soon_ with as little change as possibl=
e.
> > Other than the fact that he didn't like my patching approach [1],
> > the only technical objection Seth has raised to zcache2 is that he
> > thinks zsmalloc is the best choice of allocator [2] for his limited
> > benchmarking [3].
>=20
> FWIW, I would fear that kernbench is not that interesting a benchmark for
> something like zcache. From an MM perspective, I would be wary that the
> data compresses too well and fits too neatly in the different buckets and
> make zsmalloc appear to behave much better than it would for a more gener=
al
> workload.  Of greater concern is that the allocations for zcache would be
> too short lived to measure if external fragmentation was a real problem
> or not. This is pure guesswork as I didn't read zsmalloc but this is the
> sort of problem I'd be looking out for if I did review it. In practice,
> I would probably prefer to depend on zbud because it avoids the external
> fragmentation problem even if it wasted memory but that's just me being
> cautious.

Your well-honed intuition is IMHO exactly right.

But my compromise proposal would allow the allocator decision to be delayed
until a broader set of workloads are brought to bear.

> > I've offered to put zsmalloc back in to zcache2 as an optional
> > (even default) allocator, but that doesn't seem to be good enough
> > for Seth.  Any other technical objections to zcache2, or explanation
> > for his urgent desire to promote zcache1, Seth (and IBM) is keeping
> > close to his vest, which I find to be a bit disingenuous.
>=20
> I can only guess what the reasons might be for this and none of the
> guesses will help resolve this problem.

Me too.  Given the amount of time already spent on this discussion
(and your time reviewing, IMHO, old code), I sure hope the reasons
are compelling.

It's awfully hard to determine a compromise when one side
refuses to budge for unspecified reasons.   And the difference
between deprecated and in-staging seems minor enough that
it's hard to believe your modified proposal will make that
side happy... but we are both shooting in the dark.

> > So, I'd like to challenge Seth with a simple question:
> >
> > If zcache2 offers zsmalloc as an alternative (even default) allocator,
> > what remaining _technical_ objections do you (Seth) have to merging
> > zcache2 _instead_ of zcache1?
> >
> > If Mel agrees that your objections are worth the costs of bifurcating
> > zcache and will still endorse merging both into core mm, I agree to mov=
e
> > forward with Mel's alternative (C) (and will then repost
> > https://lkml.org/lkml/2012/7/31/573).
>=20
> If you go with C), please also add another patch on top *if possible*
> that actually shares any common code between zcache1 and zcache2.

Let's hear Seth's technical objections first, and discuss post-merge
followon steps later?

Thanks again, Mel, for wading into this.  Hopefully the disagreement
can be resolved and I will value your input on some of the zcache next
steps currently blocked by this unfortunate logjam.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
