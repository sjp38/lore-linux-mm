Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1992F6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 14:09:10 -0500 (EST)
Date: Thu, 18 Nov 2010 20:08:39 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 6/8] mm: compaction: Perform a faster scan in
 try_to_compact_pages()
Message-ID: <20101118190839.GF30376@random.random>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
 <1290010969-26721-7-git-send-email-mel@csn.ul.ie>
 <20101118183448.GC30376@random.random>
 <20101118185046.GQ8135@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118185046.GQ8135@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 06:50:46PM +0000, Mel Gorman wrote:
> For THP in general, I think we can abuse __GFP_NO_KSWAPD. For other callers,
> I'm not sure it's fair to push the responsibility of async/sync to them. We
> don't do it for reclaim for example and I'd worry the wrong decisions would
> be made or that they'd always select async for "performance" and then bitch
> about an allocation failure.

Ok, let's leave the __GFP and let's stick to the simplest for now
without alloc_pages caller knowledge.

> My only whinge about the lack of reclaimcompact_zone_order is that it
> makes it harder to even contemplate lumpy compaction in the future but
> it could always be reintroduced if absolutely necessary.

Ok. I don't know the plan of lumpy compaction and that's probably why
I didn't appreciate it...

So my preference as usual would be to remove lumpy. BTW, everything up
to patch 3 included should work fine with THP and solve my problem
with lumpy, thanks!

> GFP flags would be my last preference. 

yep. I'm just probably too paranoid at being lowlatency in the
hugepage allocation because I know it's the only spot where THP may
actually introduce a regression for short lived tasks if we do too
much work to create the hugepage. OTOH even for short lived allocation
on my westmire a bzero(1g) runs 250% (not 50% faster like in the older
hardware I was using) faster just thanks to the page being huge and
I'm talking about super short lived allocation here (the troublesome
one if we spend too much time in compaction and reclaim before
failing). Plus it only makes a difference when hugepages are so spread
across the whole system and it's still doing purely short lived
allocations. So again let's worry about the GFP flag later if
something... this is already an huge latency improvement (very
appreciated) compared to current upstream even without GPF flag ;)
like your .ps files show clearly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
