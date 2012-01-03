Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 0D5036B00A9
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 18:12:37 -0500 (EST)
Date: Tue, 3 Jan 2012 15:12:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
Message-Id: <20120103151236.893d2460.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1112312302010.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
	<alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
	<20111229145548.e34cb2f3.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1112291510390.4888@eggly.anvils>
	<4EFD04B2.7050407@gmail.com>
	<alpine.LSU.2.00.1112291753350.3614@eggly.anvils>
	<20111229195917.13f15974.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1112312302010.18500@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Sat, 31 Dec 2011 23:18:15 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Thu, 29 Dec 2011, Andrew Morton wrote:
> > 
> > This is not all some handwavy theoretical thing either.  If we've gone
> > and introduced serious latency issues, people *will* hit them and treat
> > it as a regression.
> 
> Sure, though the worst I've seen so far (probably haven't been trying
> hard enough yet, I need to go for THPs) is 39 pages freed in one call.

39 is OK.  How hugepage-intensive was the workload?

> Regression?  Well, any bad latency would already have been there on
> the gathering side.
> 
> > 
> > Now, a way out here is to remove lumpy reclaim (please).  And make the
> > problem not come back by promising to never call putback_lru_pages(lots
> > of pages) (how do we do this?).
> 
> We can very easily put a counter in it, doing a spin_unlock_irq every
> time we hit the max.  Nothing prevents that, it's just an excrescence
> I'd have preferred to omit and have not today implemented.

Yes.  It's ultra-cautious, but perhaps we should do this at least until
lumpy goes away.

> > 
> > So I think the best way ahead here is to distribute this patch in the
> > same release in which we remove lumpy reclaim (pokes Mel).
> 
> I'm sure there are better reasons for removing lumpy than that I posted
> a patch which happened to remove some limitation.  No need to poke Mel
> on my behalf!

No harm done - Mel's been getting rather unpoked lately.

Not that poking works very well anyway <checks to see if mm/thrash.c
is still there>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
