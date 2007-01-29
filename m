Message-ID: <45BDE7C1.203@shadowen.org>
Date: Mon, 29 Jan 2007 12:25:37 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Lumpy Reclaim V3
References: <exportbomb.1165424343@pinky> <20061212031312.e4c91778.akpm@osdl.org>
In-Reply-To: <20061212031312.e4c91778.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 6 Dec 2006 16:59:04 +0000
> Andy Whitcroft <apw@shadowen.org> wrote:
> 
>> This is a repost of the lumpy reclaim patch set.
> 
> more...
> 
> One concern is that when the code goes to reclaim a lump and fails, we end
> up reclaiming a number of pages which we didn't really want to reclaim. 
> Regardless of the LRU status of those pages.

Yes, the "ineffective reclaim" is more of an issue with this than
linear, and the cost metric we are working on should help us show that;
and then help us evaluate the utility of pushing the pages back without
releasing them.

> I think what we should do here is to add the appropriate vmstat counters
> for us to be able to assess the frequency of this occurring, then throw a
> spread of workloads at it.  If that work indicates that there's a problem
> then we should look at being a bit smarter about whether all the pages look
> to be reclaimable and if not, restore them all and give up.

Yes, what was obvious from the linear against lumpy was that the only
valid comparison was on the 'effectiveness' metric (which was basically
the same) and code complexity (where lumpy clearly wins).  But we have
no feel for 'cost'.  We are working on a cost metric for reclaim which
we can use to compare performance.

> 
> Also, I suspect it would be cleaner and faster to pass the `active' flag
> into isolate_lru_pages(), rather than calculating it on the fly.  And I
> don't think we need to calculate it on every pass through the loop?

Yes this is actually IMO wrong for not doing this, and I've updated it.

> 
> We really do need those vmstat counters to let us see how effective this
> thing is being.  Basic success/fail stuff.  Per-zone, I guess.

Yes, though the ones I have seem sane the output isn't stable and we're
investigating that right now.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
