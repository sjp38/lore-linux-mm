Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE316B00A3
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 08:56:22 -0500 (EST)
Date: Thu, 26 Nov 2009 13:56:15 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
Message-ID: <20091126135615.GD13095@csn.ul.ie>
References: <20091126121945.GB13095@csn.ul.ie> <1259240937.7371.15.camel@marge.simson.net> <200911261420.57121.bzolnier@gmail.com> <1259242651.6622.5.camel@marge.simson.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1259242651.6622.5.camel@marge.simson.net>
Sender: owner-linux-mm@kvack.org
To: Mike Galbraith <efault@gmx.de>
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 26, 2009 at 02:37:31PM +0100, Mike Galbraith wrote:
> On Thu, 2009-11-26 at 14:20 +0100, Bartlomiej Zolnierkiewicz wrote:
> > On Thursday 26 November 2009 02:08:57 pm Mike Galbraith wrote:
> > > On Thu, 2009-11-26 at 12:19 +0000, Mel Gorman wrote:
> > > > (cc'ing the people from the page allocator failure thread as this might be
> > > > relevant to some of their problems)
> > > > 
> > > > I know this is very last minute but I believe we should consider disabling
> > > > the "low_latency" tunable for block devices by default for 2.6.32.  There was
> > > > evidence that low_latency was a problem last week for page allocation failure
> > > > reports but the reproduction-case was unusual and involved high-order atomic
> > > > allocations in low-memory conditions. It took another few days to accurately
> > > > show the problem for more normal workloads and it's a bit more wide-spread
> > > > than just allocation failures.
> > > > 
> > > > Basically, low_latency looks great as long as you have plenty of memory
> > > > but in low memory situations, it appears to cause problems that manifest
> > > > as reduced performance, desktop stalls and in some cases, page allocation
> > > > failures. I think most kernel developers are not seeing the problem as they
> > > > tend to test on beefier machines and without hitting swap or low-memory
> > > > situations for the most part. When they are hitting low-memory situations,
> > > > it tends to be for stress tests where stalls and low performance are expected.
> > > 
> > > Ouch.  It was bad desktop stalls under heavy write that kicked the whole
> > > thing off.
> > 
> > The problem is that 'desktop' means different things for different people
> > (for some kernel developers 'desktop' is more like 'a workstation' and for
> > others it is more like 'an embedded device').

Will concede that - the term "desktop" is fuzzy at best. The
characteristics of note are a mid-range machine running workloads that
are not steady, have abupt phase changes and are not very well sized to
the available memory. "Desktops" fall into this category but it's also
possible that badly-or-borderline-provisioned servers would also fall
into it.

> 
> The stalls I'm talking about were reported for garden variety desktop
> PC. 

The stalls I'm seeing on the laptop are tiny but there. It's prefectly
possible a whole host of stalls for people have been resolved but there
is one corner case.

> I reproduced them on my supermarket special Q6600 desktop PC.  That
> problem has been with us roughly forever, but I'd hoped it had been
> cured.  Guess not.
> 

It's possible the corner case causing stalls is specific to low-memory rather
than writes. Conceivably, what is going wrong is that writes need to complete
for pages to be clean so pages can be reclaimed.  The cleaning of pages is
getting pre-empted by sync IO until such point as pages cannot be reclaimed
and they stall allowing writes to complete. I'll prototype something to
disable low_latency if kswapd is awake. If it makes as difference, this
might be plausible.

As Jens would say though, this is "mostly hand-wavy nonsense".

> As an idle speculation, I wonder if the sync vs async slice ratios may
> not have been knocked out of kilter a bit by giving more to sync.
> 

I don't know enough to speculate.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
