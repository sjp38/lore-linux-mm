Date: Sun, 10 Sep 2006 17:40:51 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 5/5] linear reclaim core
Message-Id: <20060910174051.0c14a3b8.akpm@osdl.org>
In-Reply-To: <20060910234509.GB10482@wohnheim.fh-wedel.de>
References: <exportbomb.1157718286@pinky>
	<20060908122718.GA1662@shadowen.org>
	<20060908114114.87612de3.akpm@osdl.org>
	<20060910234509.GB10482@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-1?B?SvZybg==?= Engel <joern@wohnheim.fh-wedel.de>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Sep 2006 01:45:09 +0200
Jorn Engel <joern@wohnheim.fh-wedel.de> wrote:

> On Fri, 8 September 2006 11:41:14 -0700, Andrew Morton wrote:
> > 
> > I'm somewhat surprised at the implementation.  Would it not be sufficient
> > to do this within shrink_inactive_list()?  Something along the lines of:
> > 
> > - Pick tail page off LRU.
> > 
> > - For all "neighbour" pages (alignment == 1<<order, count == 1<<order)
> > 
> >   - If they're all PageLRU and !PageActive, add them all to page_list for
> >     possible reclaim
> > 
> > And, in shrink_active_list:
> > 
> > - Pick tail page off LRU
> > 
> > - For all "neighbour" pages (alignment == 1<<order, count == 1<<order)
> > 
> >   If they're all PageLRU, put all the active pages in this block onto
> >   l_hold for possible deactivation.
> 
> Hmm.  Trying to shoot holes into your approach, I find two potential
> problems:
> A) With sufficient fragmentation, all inactive pages have one active
> neighbour, so shrink_inactive_list() will never find a cluster of the
> required order.

Nope.  If the clump of pages has a mix of active and inactive, the above
design would cause the active ones to be deactivated, so now the entire
clump is eligible for treatment by shrink_inactive_list().

> B) With some likelihood, shrink_active_list() will pick neighbours
> which happen to be rather hot pages.  They get freed, only to get
> paged in again within little more than rotational latency.

Maybe.  Careful benchmarking and carefully-designed microbenchmarks are, as
always, needed.

Bear in mind that simply moving the pages to the inactive list isn't enough
to get them reclaimed: we still do various forms of page aging and the
pages can still be preserved due to that.  IOW, we have several different
forms of page aging, one of which is LRU-ordering.  The above design
compromises just one of those aging steps.

I'd be more concerned about higher-order atomic allocations.  If this thing
is to work I suspect we'll need per-zone, per-order watermarks and kswapd
will need to maintain those.

> How about something like:
> 1. Free 1<<order pages from the inactive list.
> 2. Pick a page cluster of requested order.
> 3. Move all pages from the cluster to the just freed pages.

Don't think in terms of "freeing".  Think in terms of "scanning".  A lot of
page reclaim's balancing tricks are cast in terms of pages-scanned,
slabs-scanned, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
