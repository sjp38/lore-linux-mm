Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A51AE6B00F3
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 12:06:01 -0400 (EDT)
Date: Mon, 18 Jul 2011 17:05:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: page allocator: Initialise ZLC for first zone
 eligible for zone_reclaim
Message-ID: <20110718160552.GB5349@suse.de>
References: <1310742540-22780-1-git-send-email-mgorman@suse.de>
 <1310742540-22780-2-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1107180951390.30392@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107180951390.30392@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 18, 2011 at 09:56:31AM -0500, Christoph Lameter wrote:
> On Fri, 15 Jul 2011, Mel Gorman wrote:
> 
> > Currently the zonelist cache is setup only after the first zone has
> > been considered and zone_reclaim() has been called. The objective was
> > to avoid a costly setup but zone_reclaim is itself quite expensive. If
> > it is failing regularly such as the first eligible zone having mostly
> > mapped pages, the cost in scanning and allocation stalls is far higher
> > than the ZLC initialisation step.
> 
> Would it not be easier to set zlc_active and allowednodes based on the
> zone having an active ZLC at the start of get_pages()?
> 

What do you mean by a zones active ZLC? zonelists are on a per-node,
not a per-zone basis (see node_zonelist) so a zone doesn't have an
active ZLC as such. If the zlc_active is set at the beginning of
get_page_from_freelist(), it implies that we are calling zlc_setup()
even when the watermarks are met which is unnecessary.

> Buffered_rmqueue is handling the situation of a zone with an ZLC in a
> weird way right now since it ignores the (potentially existing) ZLC
> for the first pass.

Where does buffered_rmqueue() refer to a zonelist_cache?

> zlc_setup() does a lot of things. So that is because
> there is a performance benefit?
> 

I do not understand this question. Are you asking if zonelist_cache
has a performance benefit? The answer is "yes" because you can see
how the performance when zone_reclaim degrades when it is not used
for the first zone.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
