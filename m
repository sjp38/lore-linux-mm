Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id B267A6B005D
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 06:31:59 -0400 (EDT)
Date: Mon, 24 Sep 2012 11:31:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
Message-ID: <20120924103150.GA11266@suse.de>
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de>
 <20120921180222.GA7220@phenom.dumpdata.com>
 <505CB9BC.8040905@linux.vnet.ibm.com>
 <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
 <20120922010733.GX11266@suse.de>
 <589fd823-40f1-418c-81ad-ca8daa3f064d@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <589fd823-40f1-418c-81ad-ca8daa3f064d@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Sat, Sep 22, 2012 at 02:18:44PM -0700, Dan Magenheimer wrote:
> > From: Mel Gorman [mailto:mgorman@suse.de]
> > Subject: Re: [RFC] mm: add support for zsmalloc and zcache
> > 
> > On Fri, Sep 21, 2012 at 01:35:15PM -0700, Dan Magenheimer wrote:
> > > > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > > > Subject: Re: [RFC] mm: add support for zsmalloc and zcache
> > > The two proposals:
> > > A) Recreate all the work done for zcache2 as a proper sequence of
> > >    independent patches and apply them to zcache1. (Seth/Konrad)
> > > B) Add zsmalloc back in to zcache2 as an alternative allocator
> > >    for frontswap pages. (Dan)
> > 
> > Throwing it out there but ....
> > 
> > C) Merge both, but freeze zcache1 except for critical fixes. Only allow
> >    future work on zcache2. Document limitations of zcache1 and
> >    workarounds until zcache2 is fully production ready.
> 
> Hi Mel (with request for Seth below) --
> 
> (C) may be the politically-expedient solution but, personally,
> I think it is a bit insane and I suspect that any mm developer
> who were to deeply review both codebases side-by-side would come to
> the same conclusion. 

I have not read zcache2 and maybe it is the case that no one in their
right mind would use zcache1 if zcache2 was available but the discussion
keeps going in circles.

> The cost in developer/maintainer time,
> and the confusion presented to the user/distro base if both
> are promoted/merged would be way too high, and IMHO completely
> unwarranted.  Let me try to explain...
> 

What would the impact be if zcache2 and zcache1 were mutually exclusive
in Kconfig and the naming was as follows?

CONFIG_ZCACHE_DEPRECATED	(zcache1)
CONFIG_ZCACHE			(zcache2)

That would make it absolutely clear to distributions which one they should
be enabling and also make it clear that all future development happen
on zcache2.

I know it looks insane to promote something that is instantly deprecated
but none of the other alternatives seem to be gaining traction either.
This would at least allow the people who are currently heavily behind
zcache1 to continue supporting it and applying critical fixes until they
move to zcache2.

> I use the terms "zcache1" and "zcache2" only to clarify which
> codebase, not because they are dramatically different. I estimate
> that 85%-90% of the code in zcache1 and zcache2 is identical, not
> counting the allocator or comments/whitespace/janitorial!
> 

If 85-90% of the code is identicial then they really should be sharing
the code rather than making copies. That will result in some monolithic
patches but it's unavoidable. I expect it would end up looking like

Patch 1		promote zcache1
Patch 2		promote zcache2
Patch 3		move shared code for zcache1,zcache2 to common files

If the shared code is really shared and not copied it may reduce some of
the friction between the camps.

> Zcache2 _is_ zcache1 with some good stuff added and with zsmalloc
> dropped.  I think after careful study, there would be wide agreement
> among mm developers that the stuff added is all moving in the direction
> of making zcache "production-ready".  IMHO, zcache1 has _never_
> been production-ready, and zcache2 is merely a big step in the right
> direction.
> 

zcache1 does appear to have a few snarls that would make me wary of having
to support it. I don't know if zcache2 suffers the same problems or not
as I have not read it.

> (Quick logistical aside: zcache2 is in staging-next and linux-next,
> currently housed under the drivers/staging/ramster directory...
> with !CONFIG_RAMSTER, ramster _is_ zcache2.)
> 

Unfortunately, I'm not going to get the chance to review it in the
short-term. However, if zcache1 and zcache2 shared code in common files
it would at least reduce the amount of new code I have to read :)

> Seth (and IBM) seems to have a bee in his bonnet that the existing
> zcache1 code _must_ be promoted _soon_ with as little change as possible.
> Other than the fact that he didn't like my patching approach [1],
> the only technical objection Seth has raised to zcache2 is that he
> thinks zsmalloc is the best choice of allocator [2] for his limited
> benchmarking [3].
> 

FWIW, I would fear that kernbench is not that interesting a benchmark for
something like zcache. From an MM perspective, I would be wary that the
data compresses too well and fits too neatly in the different buckets and
make zsmalloc appear to behave much better than it would for a more general
workload.  Of greater concern is that the allocations for zcache would be
too short lived to measure if external fragmentation was a real problem
or not. This is pure guesswork as I didn't read zsmalloc but this is the
sort of problem I'd be looking out for if I did review it. In practice,
I would probably prefer to depend on zbud because it avoids the external
fragmentation problem even if it wasted memory but that's just me being
cautious.

> I've offered to put zsmalloc back in to zcache2 as an optional
> (even default) allocator, but that doesn't seem to be good enough
> for Seth.  Any other technical objections to zcache2, or explanation
> for his urgent desire to promote zcache1, Seth (and IBM) is keeping
> close to his vest, which I find to be a bit disingenuous.
> 

I can only guess what the reasons might be for this and none of the
guesses will help resolve this problem.

> So, I'd like to challenge Seth with a simple question:
> 
> If zcache2 offers zsmalloc as an alternative (even default) allocator,
> what remaining _technical_ objections do you (Seth) have to merging
> zcache2 _instead_ of zcache1?
> 
> If Mel agrees that your objections are worth the costs of bifurcating
> zcache and will still endorse merging both into core mm, I agree to move
> forward with Mel's alternative (C) (and will then repost
> https://lkml.org/lkml/2012/7/31/573).
> 

If you go with C), please also add another patch on top *if possible*
that actually shares any common code between zcache1 and zcache2.

> Personally, I would _really_ like to get back to writing code to make
> zcacheN more suitable for production so would really like to see this
> resolved!
> 
> Dan
> 
> [1] Monolithic, because GregKH seemed to be unwilling to take further
> patches to zcache before it was promoted, and because I thought
> a number of things had to be fixed before I would feel comfortable
> presenting zcache to be reviewed by mm developers
> [2] Note, zsmalloc is used in zcache1 only for frontswap pages...
> zbud is used in both zcache1 and zcache2 for cleancache pages.
> [3] I've never seen any benchmark results posted for zcache other
> than some variation of kernbench.  IMHO that's an issue all in itself.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
