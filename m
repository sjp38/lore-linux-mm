Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8BA6B0103
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 17:13:31 -0400 (EDT)
Date: Mon, 18 Jul 2011 22:13:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: page allocator: Initialise ZLC for first zone
 eligible for zone_reclaim
Message-ID: <20110718211325.GC5349@suse.de>
References: <1310742540-22780-1-git-send-email-mgorman@suse.de>
 <1310742540-22780-2-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1107180951390.30392@router.home>
 <20110718160552.GB5349@suse.de>
 <alpine.DEB.2.00.1107181208050.31576@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107181208050.31576@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 18, 2011 at 12:20:11PM -0500, Christoph Lameter wrote:
> 
> 
> On Mon, 18 Jul 2011, Mel Gorman wrote:
> 
> > On Mon, Jul 18, 2011 at 09:56:31AM -0500, Christoph Lameter wrote:
> > > On Fri, 15 Jul 2011, Mel Gorman wrote:
> > >
> > > > Currently the zonelist cache is setup only after the first zone has
> > > > been considered and zone_reclaim() has been called. The objective was
> > > > to avoid a costly setup but zone_reclaim is itself quite expensive. If
> > > > it is failing regularly such as the first eligible zone having mostly
> > > > mapped pages, the cost in scanning and allocation stalls is far higher
> > > > than the ZLC initialisation step.
> > >
> > > Would it not be easier to set zlc_active and allowednodes based on the
> > > zone having an active ZLC at the start of get_pages()?
> > >
> >
> > What do you mean by a zones active ZLC? zonelists are on a per-node,
> > not a per-zone basis (see node_zonelist) so a zone doesn't have an
> > active ZLC as such. If the zlc_active is set at the beginning of
> 
> Look at get_page_from_freelist(): It sets
> zlc_active = 0 even through the zonelist under consideration may have a
> ZLC. zlc_active = 0 can also mean that the function has not bothered to
> look for the zlc information of the current zonelist.
> 

Yes. So? It's only necessary if the watermarks are not met.

> > get_page_from_freelist(), it implies that we are calling zlc_setup()
> > even when the watermarks are met which is unnecessary.
> 
> Ok then that decision to not call zlc_setup() for performance reasons is
> what created the problem that you are trying to solve. In case that the
> first zones watermarks are okay we can avoid calling zlc_setup().
> 

The original implementation did not check the ZLC in the first loop
at all. It wasn't just about avoiding the cost of setup. I suspect
this problem has been there a long time and it's taking this long
for bug reports to show up because NUMA machines are being used for
generic numa-unaware workloads.

> What we do now have is checking for zlc_active in the loop just so that
> the first time around we do not call zlc_setup().
> 

Yes, why incur the cost for the common case?

> We may be able to simplify the function by:
> 
> 1.  Checking for the special case that the first zone is ok and that we do
> not want to call zlc_setup before we get to the loop.
> 
> 2. Do the zlc_setup() before the loop.
> 
> 3. Remove the zlc_setup() code as you did from the loop as well as the
> checks for zlc_active. zlc_active becomes not necessary since a zlc
> is always available when we go through the loop.
> 

That initial test will involve duplication of things like the cpuset and
no watermarks check just to place the zlc_setup() in a different place.
I might be missing your point but it seems like the gain would be
marginal. Fancy posting a patch?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
