Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 8D8BD6B002B
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 17:19:08 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <589fd823-40f1-418c-81ad-ca8daa3f064d@default>
Date: Sat, 22 Sep 2012 14:18:44 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de> <20120921180222.GA7220@phenom.dumpdata.com>
 <505CB9BC.8040905@linux.vnet.ibm.com>
 <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
 <20120922010733.GX11266@suse.de>
In-Reply-To: <20120922010733.GX11266@suse.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Mel Gorman [mailto:mgorman@suse.de]
> Subject: Re: [RFC] mm: add support for zsmalloc and zcache
>=20
> On Fri, Sep 21, 2012 at 01:35:15PM -0700, Dan Magenheimer wrote:
> > > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > > Subject: Re: [RFC] mm: add support for zsmalloc and zcache
> > The two proposals:
> > A) Recreate all the work done for zcache2 as a proper sequence of
> >    independent patches and apply them to zcache1. (Seth/Konrad)
> > B) Add zsmalloc back in to zcache2 as an alternative allocator
> >    for frontswap pages. (Dan)
>=20
> Throwing it out there but ....
>=20
> C) Merge both, but freeze zcache1 except for critical fixes. Only allow
>    future work on zcache2. Document limitations of zcache1 and
>    workarounds until zcache2 is fully production ready.

Hi Mel (with request for Seth below) --

(C) may be the politically-expedient solution but, personally,
I think it is a bit insane and I suspect that any mm developer
who were to deeply review both codebases side-by-side would come to
the same conclusion.  The cost in developer/maintainer time,
and the confusion presented to the user/distro base if both
are promoted/merged would be way too high, and IMHO completely
unwarranted.  Let me try to explain...

I use the terms "zcache1" and "zcache2" only to clarify which
codebase, not because they are dramatically different. I estimate
that 85%-90% of the code in zcache1 and zcache2 is identical, not
counting the allocator or comments/whitespace/janitorial!

Zcache2 _is_ zcache1 with some good stuff added and with zsmalloc
dropped.  I think after careful study, there would be wide agreement
among mm developers that the stuff added is all moving in the direction
of making zcache "production-ready".  IMHO, zcache1 has _never_
been production-ready, and zcache2 is merely a big step in the right
direction.

(Quick logistical aside: zcache2 is in staging-next and linux-next,
currently housed under the drivers/staging/ramster directory...
with !CONFIG_RAMSTER, ramster _is_ zcache2.)

Seth (and IBM) seems to have a bee in his bonnet that the existing
zcache1 code _must_ be promoted _soon_ with as little change as possible.
Other than the fact that he didn't like my patching approach [1],
the only technical objection Seth has raised to zcache2 is that he
thinks zsmalloc is the best choice of allocator [2] for his limited
benchmarking [3].

I've offered to put zsmalloc back in to zcache2 as an optional
(even default) allocator, but that doesn't seem to be good enough
for Seth.  Any other technical objections to zcache2, or explanation
for his urgent desire to promote zcache1, Seth (and IBM) is keeping
close to his vest, which I find to be a bit disingenuous.

So, I'd like to challenge Seth with a simple question:

If zcache2 offers zsmalloc as an alternative (even default) allocator,
what remaining _technical_ objections do you (Seth) have to merging
zcache2 _instead_ of zcache1?

If Mel agrees that your objections are worth the costs of bifurcating
zcache and will still endorse merging both into core mm, I agree to move
forward with Mel's alternative (C) (and will then repost
https://lkml.org/lkml/2012/7/31/573).

Personally, I would _really_ like to get back to writing code to make
zcacheN more suitable for production so would really like to see this
resolved!

Dan

[1] Monolithic, because GregKH seemed to be unwilling to take further
patches to zcache before it was promoted, and because I thought
a number of things had to be fixed before I would feel comfortable
presenting zcache to be reviewed by mm developers
[2] Note, zsmalloc is used in zcache1 only for frontswap pages...
zbud is used in both zcache1 and zcache2 for cleancache pages.
[3] I've never seen any benchmark results posted for zcache other
than some variation of kernbench.  IMHO that's an issue all in itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
