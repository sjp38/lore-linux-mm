Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 2AE0F6B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 22:55:42 -0500 (EST)
Date: Thu, 29 Dec 2011 19:59:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: take pagevecs off reclaim stack
Message-Id: <20111229195917.13f15974.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1112291753350.3614@eggly.anvils>
References: <alpine.LSU.2.00.1112282028160.1362@eggly.anvils>
	<alpine.LSU.2.00.1112282037000.1362@eggly.anvils>
	<20111229145548.e34cb2f3.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1112291510390.4888@eggly.anvils>
	<4EFD04B2.7050407@gmail.com>
	<alpine.LSU.2.00.1112291753350.3614@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Thu, 29 Dec 2011 17:55:14 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:

> > However, at that time, I think this patch behave
> > better than old. If we release and retake zone lock per 14 pages,
> > other tasks can easily steal a part of lumpy reclaimed pages. and then
> > long latency wrongness will be happen when system is under large page
> > memory allocation pressure. That's the reason why I posted very similar patch
> > a long time ago.
> 
> Aha, and another good point.  Thank you.

I hope you understand it better than I :(

Long lock hold times and long irq-off times are demonstrable problems
which have hurt people in the past.  Whereas the someone-stole-my-page
issue is theoretical, undemonstrated and unquantified.  And for
some people, lengthy worst-case latency is a serious problem, doesn't
matter whether the system is under memory pressure or not - that simply
determines when the worst-case hits.

This is not all some handwavy theoretical thing either.  If we've gone
and introduced serious latency issues, people *will* hit them and treat
it as a regression.


Now, a way out here is to remove lumpy reclaim (please).  And make the
problem not come back by promising to never call putback_lru_pages(lots
of pages) (how do we do this?).

So I think the best way ahead here is to distribute this patch in the
same release in which we remove lumpy reclaim (pokes Mel).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
