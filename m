Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id E4E916B004D
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 22:22:54 -0500 (EST)
Received: by iacb35 with SMTP id b35so38497378iac.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 19:22:54 -0800 (PST)
Date: Tue, 3 Jan 2012 19:22:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
In-Reply-To: <20120103151236.893d2460.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1201031900140.1378@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils> <alpine.LSU.2.00.1112282037000.1362@eggly.anvils> <20111229145548.e34cb2f3.akpm@linux-foundation.org> <alpine.LSU.2.00.1112291510390.4888@eggly.anvils> <4EFD04B2.7050407@gmail.com>
 <alpine.LSU.2.00.1112291753350.3614@eggly.anvils> <20111229195917.13f15974.akpm@linux-foundation.org> <alpine.LSU.2.00.1112312302010.18500@eggly.anvils> <20120103151236.893d2460.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Tue, 3 Jan 2012, Andrew Morton wrote:
> On Sat, 31 Dec 2011 23:18:15 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > On Thu, 29 Dec 2011, Andrew Morton wrote:
> > > 
> > > This is not all some handwavy theoretical thing either.  If we've gone
> > > and introduced serious latency issues, people *will* hit them and treat
> > > it as a regression.
> > 
> > Sure, though the worst I've seen so far (probably haven't been trying
> > hard enough yet, I need to go for THPs) is 39 pages freed in one call.
> 
> 39 is OK.  How hugepage-intensive was the workload?

Not very hugepagey at all.  I've since tried harder, and the most I've
seen is 523 - I expect you to be more disagreeable about that number!

And we should be able to see twice that on i386 without PAE, though
I don't suppose there's a vital market for THP in that direction.

> 
> > Regression?  Well, any bad latency would already have been there on
> > the gathering side.

I did check whether similar numbers were coming out of isolate_lru_pages
(it could have been that only a hugepage was gathered, but then split
into many by the threat of swapping); yes, similar numbers at that end.

So using page_list in putback_lru/inactive_pages would not be increasing
the worst latency, just doubling its frequency.  (Assuming that isolating
and putting back have the same cost: my guess is roughly the same, but
I've not measured.)

> > > 
> > > Now, a way out here is to remove lumpy reclaim (please).  And make the
> > > problem not come back by promising to never call putback_lru_pages(lots
> > > of pages) (how do we do this?).
> > 
> > We can very easily put a counter in it, doing a spin_unlock_irq every
> > time we hit the max.  Nothing prevents that, it's just an excrescence
> > I'd have preferred to omit and have not today implemented.
> 
> Yes.  It's ultra-cautious, but perhaps we should do this at least until
> lumpy goes away.

I don't think you'll accept my observations above as excuse to do
nothing, but please clarify which you think is more cautious.  Should
I or should I not break up the isolating end in the same way as the
putting back?

I imagine breaking in every SWAP_CLUSTER_MAX 32, so the common order
0 isn't slowed at all; hmm, maybe add on (1 << PAGE_ALLOC_COSTLY_ORDER)
8 so Kosaki-san's point is respected at least for the uncostly orders.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
