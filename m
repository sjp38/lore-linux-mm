Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 2B81B6B0007
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 19:20:20 -0500 (EST)
MIME-Version: 1.0
Message-ID: <413ecbbe-cc87-4f9e-a938-aad32e8fe7a9@default>
Date: Mon, 25 Feb 2013 16:20:03 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv5 1/8] zsmalloc: add to mm/
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1360780731-11708-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130219091804.GA13989@lge.com> <5123BC4D.1010404@linux.vnet.ibm.com>
 <20130219233733.GA16950@blaptop> <20130222092420.GA8077@lge.com>
 <5127CF34.9040302@linux.vnet.ibm.com>
 <69936094-e2fc-44bd-b179-f567e8681bec@default>
 <512BB825.7070304@linux.vnet.ibm.com>
In-Reply-To: <512BB825.7070304@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCHv5 1/8] zsmalloc: add to mm/
>=20
> On 02/25/2013 11:05 AM, Dan Magenheimer wrote:
> >> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> >> Sent: Friday, February 22, 2013 1:04 PM
> >> To: Joonsoo Kim
> >> Subject: Re: [PATCHv5 1/8] zsmalloc: add to mm/
> >>
> >> On 02/22/2013 03:24 AM, Joonsoo Kim wrote:
> >>>
> >>> It's my quick thought. So there is no concrete idea.
> >>> As Seth said, with a FULL list, zsmalloc always access all zspage.
> >>> So, if we want to know what pages are for zsmalloc, we can know it.
> >>> The EMPTY list can be used for pool of zsmalloc itself. With it, we d=
on't
> >>> need to free zspage directly, we can keep zspages, so can reduce
> >>> alloc/free overhead. But, I'm not sure whether it is useful.
> >>
> >> I think it's a good idea.  zswap actually does this "keeping some free
> >> pages around for later allocations" outside zsmalloc in a mempool that
> >> zswap manages.  Minchan once mentioned bringing that inside zsmalloc
> >> and this would be a way we could do it.
> >
> > I think it's a very bad idea.  If I understand, the suggestion will
> > hide away some quantity (possibly a very large quantity) of pages
> > for the sole purpose of zswap, in case zswap gets around to using them
> > sometime in the future.  In the meantime, those pages are not available
> > for use by any other kernel subsystems or by userland processes.
> > An idle page is a wasted page.
> >
> > While you might defend the mempool use for a handful of pages,
> > frontswap writes/reads thousands of pages in a bursty way,
> > and then can go idle for a very long time.  This may not be
> > readily apparent with artificially-created memory pressure
> > from kernbench with -jN (high N).  Leaving thousands
> > of pages in zswap's personal free list may cause memory pressure
> > that would otherwise never have existed.
>=20
> I experimentally determined that this pool increased allocation
> success rate and, therefore, reduced the number of pages going to the
> swap device.

Of course it does.  But you can't experimentally determine how
pre-allocating pages will impact overall performance, especially
over a wide range of workloads that may or may not even swap.

> The zswap mempool has a target size of 256 pages.  This places an
> upper bound on the number of pages held in reserve for zswap.  So we
> aren't talking about "thousands of pages".

I used "thousands of pages" in reference to Joonsoo's idea about
releasing pages to the EMPTY list, not about mempool.  I wasn't
aware that mempool has a target size of 256 pages, but even
that smaller amount seems wrong to me, especially if the
mempool user (zswap) will blithely use many thousands of pages
in a burst.
=20
> And yes, the pool does remove up to 1MB of memory (on a 4k PAGE_SIZE)
> from general use, which causes the reclaim to start very slightly earlier=
.
>=20
> >
> >> Just want to be clear that I'd be in favor of looking at this after
> >> the merge.
> >
> > I disagree... I think this is exactly the kind of fundamental
> > MM interaction that should be well understood and resolved
> > BEFORE anything gets merged.
>=20
> While there is discussion to be had here, I don't agree that it's
> "fundamental" and should not block merging.
>=20
> The mempool does serve a purpose and adds measurable benefit. However,
> if it is determined at some future time that having a reserved pool of
> any size in zswap is bad practice, it can be removed trivially.

We had this argument last summer... Sure, _any_ cache can be shown
to add some measurable benefit under the right circumstances.
Any cacheing solution also has some often subtle side effects
on some workloads, that can have more costs than benefits.
Our cache (zcache and/or zswap and/or zram) is not just a cache
but it is also stealing capacity from its backing store (total
kernel RAM), so is even more likely to have side effects.

While I firmly believe -- intuitively -- that compression should
eventually be a feature of the MM subsystem, I don't think we
have enough understanding yet of the interactions or the
policies needed to control those interactions or the impact
of those policies on the underlying zram/zcache/zswap design choices.
For example, zswap completely ignores the pagecache... is that
a good thing or a bad thing, and why?

Seth, I'm not trying to piss you off, but last summer you seemed
hell-bent on promoting zcache out of staging, and it didn't
happen so you hacked off the part of zcache you were most interested
in, forked it and rewrote it, and are now trying to merge that
fork into MM ASAP.  Why?  Why can't we work together on solving
the hard problems instead of infighting and reimplementing the wheel?

Dan "shakes head"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
