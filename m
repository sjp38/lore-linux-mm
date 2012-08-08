Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 6A0086B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 13:48:18 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <c90d1b27-280d-4a87-9359-9c0325999392@default>
Date: Wed, 8 Aug 2012 10:47:48 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <5021795A.5000509@linux.vnet.ibm.com>
 <3f8dfac9-2b92-442c-800a-f0bfef8a90cb@default>
 <502293E2.8010505@linux.vnet.ibm.com>
In-Reply-To: <502293E2.8010505@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Kurt Hackel <kurt.hackel@oracle.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]

Hi Seth --

Good discussion.  Even though we disagree, I appreciate
your enthusiasm and your good work on the kernel!

> Subject: Re: [PATCH 0/4] promote zcache from staging
>=20
> On 08/07/2012 04:47 PM, Dan Magenheimer wrote:
> > I notice your original published benchmarks [1] include
> > N=3D24, N=3D28, and N=3D32, but these updated results do not.  Are you =
planning
> > on completing the runs?  Second, I now see the numbers I originally
> > published for what I thought was the same benchmark as yours are actual=
ly
> > an order of magnitude larger (in sec) than yours.  I didn't notice
> > this in March because we were focused on the percent improvement, not
> > the raw measurements.  Since the hardware is highly similar, I suspect
> > it is not a hardware difference but instead that you are compiling
> > a much smaller kernel.  In other words, your test case is much
> > smaller, and so exercises zcache much less.  My test case compiles
> > a full enterprise kernel... what is yours doing?
>=20
> I am doing a minimal kernel build for my local hardware
> configuration.
>=20
> With the reduction in RAM, 1GB to 512MB, I didn't need to do
> test runs with >20 threads to find the peak of the benefit
> curve at 16 threads.  Past that, zcache is saturated and I'd
> just be burning up my disk.

I think that's exactly what I said in a snippet of my response
that you deleted.  A cache needs to work well both when it
is non-full and when it is full.  You are only demonstrating
that it works well when it is non-full.  When it is
"saturated", bad things can happen.  Finding the "peak of the
benefit" is only half the work of benchmarking.

So it appears you are trying to prove your point by showing
the workloads that look good, while _not_ showing the workloads
that look bad, and then claiming you don't care about those
bad workloads anyway.

> Also, I provide the magnitude numbers (pages, seconds) just
> to show my source data.  The %change numbers are the real
> results as they remove build size as a factor.

You'll have to explain what you mean because, if I understand
correctly, this is just not true.  Different build sizes
definitely affect memory management differently, just as
different values of N (for make -jN) have an effect.

> > At LSFMM, Andrea
> > Arcangeli pointed out that zcache, for frontswap pages, has no "writeba=
ck"
> > capabilities and, when it is full, it simply rejects further attempts
> > to put data in its cache.  He said this is unacceptable for KVM and I
> > agreed that it was a flaw that needed to be fixed before zcache should
> > be promoted.
>=20
> KVM (in-tree) is not a current user of zcache.  While the
> use cases of possible future zcache users should be
> considered, I don't think they can be used to prevent promotion.

That wasn't my point.  Andrea identified the flaw as an issue
of zcache.

> > A second flaw is that the "demo" zcache has no concept of LRU for
> > either cleancache or frontswap pages, or ability to reclaim pageframes
> > at all for frontswap pages.
> ...
> >
> > A third flaw is that the "demo" version has a very poor policy to
> > determine what pages are "admitted".
> ...
> >
> > I can add more issues to the list, but will stop here.
>=20
> All of the flaws you list do not prevent zcache from being
> beneficial right now, as my results demonstrate.  Therefore,
> the flaws listed are really potential improvements and can
> be done in mainline after promotion.  Even if large changes
> are required to make these improvements, they can be made in
> mainline in an incremental and public way.

Your results only demonstrate that zcache is beneficial on
the workloads that you chose to present.  But using the same
workload with slightly different parameters (-jN or compiling
a larger kernel), zcache can be _detrimental_, and you've chosen
to not measure or present those cases, even though you did
measure and present some of those cases in your first benchmark
runs posted in March (on an earlier kernel).

I can only speak for myself, but this appears disingenuous to me.

Sorry, but FWIW my vote is still a NACK.  IMHO zcache needs major
work before it should be promoted, and I think we should be spending
the time fixing the known flaws rather than arguing about promoting
"demo" code.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
