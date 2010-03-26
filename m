Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CC5636B01AC
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 02:01:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2Q61kXt012910
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 26 Mar 2010 15:01:46 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F0C3845DE4F
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 15:01:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CBFB45DE67
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 15:01:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D6D8A1DB803B
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 15:01:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 835EEE38002
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 15:01:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
In-Reply-To: <20100325151121.GU2024@csn.ul.ie>
References: <20100325142414.6C80.A69D9226@jp.fujitsu.com> <20100325151121.GU2024@csn.ul.ie>
Message-Id: <20100326142552.6CA4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 26 Mar 2010 15:01:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> If you insist, I can limit direct compaction for > PAGE_ALLOC_COSTLY_ORDER. The
> allocator is already meant to be able to handle these orders without special
> assistance and it'd avoid compaction becoming a cruch for subsystems that
> suddently decide it's a great idea to use order-1 or order-2 heavily.
> 
> > My point is, We have to consider to disard useful cached pages and to
> > discard no longer accessed pages. latter is nearly zero cost.
> 
> I am not opposed to moving in this sort of direction although
> particularly if we disable compaction for the lower orders. I believe
> what you are suggesting is that the allocator would take the steps
> 
> 1. Try allocate from lists
> 2. If that fails, do something like zone_reclaim_mode and lumpy reclaim
>    only pages which are cheap to discard
> 3. If that fails, try compaction to move around the active pages
> 4. If that fails, lumpy reclaim 

This seems makes a lot of sense. 
I think todo are

1) now almost system doesn't use zone_reclaim. we need to consider change
    zone_reclaim as by default or not.
2) current zone_reclaim doesn't have light reclaim mode. it start reclaim as priority=5.
    we need to consider adding new zone reclaim mode or not.


> > please
> > don't consider page discard itself is bad, it is correct page life cycle.
> > To protest discard useless cached page can makes reduce IO throughput.
> 
> I don't consider it bad as such but I had generally considered compaction to
> be better than discarding pages. I take your point though that if we compact
> many old pages, it might be a net loss.

thanks.


> > > How do you figure? I think it goes a long way to mitigating the worst of
> > > the problems you laid out above.
> > 
> > Both lumpy reclaim and page comaction have some advantage and some disadvantage.
> > However we already have lumpy reclaim. I hope you rememver we are attacking
> > very narrowing corner case. we have to consider to reduce the downside of compaction
> > at first priority.
> > Not only big benefit but also big downside seems no good.
> > 
> > So, I'd suggest either way
> > 1) no change caller place, but invoke compaction at very limited situation, or
> 
> I'm ok with enabling compaction only for >= PAGE_ALLOC_COSTLY_ORDER.
> This will likely limit it to just huge pages for the moment but even
> that would be very useful to me on swapless systems

Agreed! thanks.

sidenote: I don't think this is only a feature for swapless systems. example, btrfs
doesn't have pageout implementation, it mean btrfs can't use lumpy reclaim.
page comaction can help to solve this issue.


> > 2) invoke compaction at only lumpy reclaim unfit situation
> > 
> > My last mail, I proposed about (2). but you seems got bad impression. then,
> > now I propsed (1).
> 
> 1 would be my preference to start with.
> 
> After merge, I'd look into "cheap" lumpy reclaim which is used as a
> first option, then compaction, then full direct reclaim. Would that be
> satisfactory?

Yeah! this is very nice for me!


> > I mean we will _start_ to treat the compaction is for
> > hugepage allocation assistance feature, not generic allocation change.
> > 
> 
> Agreed.
> 
> > btw, I hope drop or improve patch 11/11 ;-)
> 
> I expect it to be improved over time. The compactfail counter is there to
> identify when a bad situation occurs so that the workload can be better
> understood. There are different heuristics that could be applied there to
> avoid the wait but all of them have disadvantages.

great!


> > > > Honestly, I think this patch was very impressive and useful at 2-3 years ago.
> > > > because 1) we didn't have lumpy reclaim 2) we didn't have sane reclaim bail out.
> > > > then, old vmscan is very heavyweight and inefficient operation for high order reclaim.
> > > > therefore the downside of adding this page migration is hidden relatively. but...
> > > > 
> > > > We have to make an effort to reduce reclaim latency, not adding new latency source.
> > > 
> > > I recognise that reclaim latency has been reduced but there is a wall.
> > 
> > If it is a wall, we have to fix this! :)
> 
> Well, the wall I had in mind was IO bandwidth :)

ok, I catched you mention.

> > > Right now, it is identifed when pageout should happen instead of page
> > > migration. It's known before compaction starts if it's likely to be
> > > successful or not.
> > > 
> > 
> > patch 11/11 says, it's known likely to be successfull or not, but not exactly.
> 
> Indeed. For example, it might not have been possible to migrate the necessary
> pages because they were pagetables, slab etc. It might also be simply memory
> pressure. It might look like there should be enough pages to compaction but
> there are too many processes allocating at the same time.

agreed.


> > > I can drop the min_free_kbytes change but the likely result will be that
> > > allocation success rates will simply be lower. The calculations on
> > > whether compaction should be used or not are based on watermarks which
> > > adjust to the value of min_free_kbytes.
> > 
> > Then, should we need min_free_kbytes auto adjustment trick?
> 
> I have considered this in the past. Specifically that it would be auto-adjusted
> the first time a huge page was allocated. I never got around to it though.

Hmhm, ok.
we can discuss it as separate patch and separate thread.


> > But please remember, now compaction might makes very large lru shuffling
> > in compaction failure case. It mean vmscan might discard very wrong pages.
> > I have big worry about it.
> > 
> 
> Would disabling compaction for the lower orders alleviate your concerns?
> I have also taken note to investigate how much LRU churn can be avoided.

that's really great.

I'm looking for your v6 post :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
