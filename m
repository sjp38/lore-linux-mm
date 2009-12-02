Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9D153600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 06:32:49 -0500 (EST)
Date: Wed, 2 Dec 2009 11:32:41 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: still getting allocation failures (was Re: [PATCH] vmscan:
	Stop kswapd waiting on congestion when the min watermark is not
	being met V2)
Message-ID: <20091202113241.GC1457@csn.ul.ie>
References: <20091113142608.33B9.A69D9226@jp.fujitsu.com> <20091113135443.GF29804@csn.ul.ie> <20091114023138.3DA5.A69D9226@jp.fujitsu.com> <20091113181557.GM29804@csn.ul.ie> <2f11576a0911131033w4a9e6042k3349f0be290a167e@mail.gmail.com> <20091113200357.GO29804@csn.ul.ie> <alpine.DEB.2.00.0911261542500.21450@sebohet.brgvxre.pu> <alpine.DEB.2.00.0911290834470.20857@sebohet.brgvxre.pu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0911290834470.20857@sebohet.brgvxre.pu>
Sender: owner-linux-mm@kvack.org
To: Tobi Oetiker <tobi@oetiker.ch>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 29, 2009 at 08:42:09AM +0100, Tobi Oetiker wrote:
> Hi Mel,
> 
> Thursday Tobias Oetiker wrote:
> > Hi Mel,
> >
> > Nov 13 Mel Gorman wrote:
> >
> > > The last version has a stupid bug in it. Sorry.
> > >
> > > Changelog since V1
> > >   o Fix incorrect negation
> > >   o Rename kswapd_no_congestion_wait to kswapd_skip_congestion_wait as
> > >     suggested by Rik
> > >
> > > If reclaim fails to make sufficient progress, the priority is raised.
> > > Once the priority is higher, kswapd starts waiting on congestion.  However,
> > > if the zone is below the min watermark then kswapd needs to continue working
> > > without delay as there is a danger of an increased rate of GFP_ATOMIC
> > > allocation failure.
> > >
> > > This patch changes the conditions under which kswapd waits on
> > > congestion by only going to sleep if the min watermarks are being met.
> >
> > I finally got around to test this together with the whole series on
> > 2.6.31.6. after running it for a day I have not yet seen a single
> > order:5 allocation problem ... (while I had several an hour before)
> 
> > for the record, my kernel is now running with the following
> > patches:
> >
> > patch1:Date: Thu, 12 Nov 2009 19:30:31 +0000
> > patch1:Subject: [PATCH 1/5] page allocator: Always wake kswapd when restarting an allocation attempt after direct reclaim failed
> >
> > patch2:Date: Thu, 12 Nov 2009 19:30:32 +0000
> > patch2:Subject: [PATCH 2/5] page allocator: Do not allow interrupts to use ALLOC_HARDER
> >
> > patch3:Date: Thu, 12 Nov 2009 19:30:33 +0000
> > patch3:Subject: [PATCH 3/5] page allocator: Wait on both sync and async congestion after direct reclaim
> >
> > patch4:Date: Thu, 12 Nov 2009 19:30:34 +0000
> > patch4:Subject: [PATCH 4/5] vmscan: Have kswapd sleep for a short interval and double check it should be asleep
> >
> > patch5:Date: Fri, 13 Nov 2009 20:03:57 +0000
> > patch5:Subject: [PATCH] vmscan: Stop kswapd waiting on congestion when the min watermark is not being met V2
> >
> > patch6:Date: Tue, 17 Nov 2009 10:34:21 +0000
> > patch6:Subject: [PATCH] vmscan: Have kswapd sleep for a short interval and double check it should be asleep fix 1
> >
> I have now been running the new kernel for a few days and I am
> sorry to report that about a day after booting the allocation
> failures started showing again. More order:4 instead of order:5 ...
> 

Why has the order changed?

Also, what allocator were you using in 2.6.30 and 2.6.31.6, SLAB or
SLUB? Did you happen to change them when upgrading the kernel?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
