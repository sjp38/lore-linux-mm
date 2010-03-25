Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3BFE36B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 07:08:28 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2PB8PZf017887
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 25 Mar 2010 20:08:25 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A47445DE57
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 20:08:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06EF445DE4E
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 20:08:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D805CE3800D
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 20:08:24 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A3B7E38004
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 20:08:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
In-Reply-To: <20100319100917.GR12388@csn.ul.ie>
References: <20100319152105.8772.A69D9226@jp.fujitsu.com> <20100319100917.GR12388@csn.ul.ie>
Message-Id: <20100325142414.6C80.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Mar 2010 20:08:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Hmm..Hmmm...........
> > 
> > Today, I've reviewed this patch and [11/11] carefully twice. but It is harder to ack.
> > 
> > This patch seems to assume page compaction is faster than direct
> > reclaim. but it often doesn't, because dropping useless page cache is very
> > lightweight operation,
> 
> Two points with that;
> 
> 1. It's very hard to know in advance how often direct reclaim of clean page
>    cache would be enough to satisfy the allocation.

Yeah, This is main reason why I'd suggest tightly integrate vmscan and compaction.


> 2. Even if it was faster to discard page cache, it's not necessarily
>    faster when the cost of reading that page cache back-in is taken into
>    account

_If_ this is useful page, you are right. but please remember, In typical
case the system have lots no longer used pages.

> 
> Lumpy reclaim tries to avoid dumping useful page cache but it is perfectly
> possible for hot data to be discarded because it happened to be located
> near cold data. 

Yeah, I fully agree.

> It's impossible to know in general how much unnecessary IO
> takes place as a result of lumpy reclaim because it depends heavily on the
> system-state when lumpy reclaim starts.

I think this is explained why vmscan and compaction shouldn't be separated.
Yes, Only vmscan can know it.


> > but page compaction makes a lot of memcpy (i.e. cpu cache
> > pollution). IOW this patch is focusing to hugepage allocation very aggressively, but
> > it seems not enough care to reduce typical workload damage.
> > 
> 
> What typical workload is making aggressive use of high order
> allocations? Typically when such a user is found, effort is spent on
> finding alternatives to high-orders as opposed to worrying about the cost
> of allocating them. There was a focus on huge page allocation because it
> was the most useful test case that was likely to be encountered in practice.
> 
> I can adjust the allocation levels to some other value but it's not typical
> for a system to make very aggressive use of other orders. I could have it
> use random orders but also is not very typical.

If this compaction is trigged only order-9 allocation, I don't oppose it at all.
Also PAGE_ALLOC_COSTLY_ORDER is probably acceptable. I agree huge page 
allocation made lots trouble. but low order and the system
have lots no longer used page case, your logic is worse than current.
I worry about it.

My point is, We have to consider to disard useful cached pages and to
discard no longer accessed pages. latter is nearly zero cost. please
don't consider page discard itself is bad, it is correct page life cycle.
To protest discard useless cached page can makes reduce IO throughput.

> 
> > At first, I would like to clarify current reclaim corner case and how
> > vmscan should do at this mail.
> > 
> > Now we have Lumpy reclaim. It is very excellent solution for externa
> > fragmentation.
> 
> In some situations, it can grind a system to trash for a time. What is far
> more likely is to be dealing with a machine with no swap - something that
> is common in clusters. In this case, lumpy is a lot less likely to succeed
> unless the machine is very quiet. It's just not going to find the contiguous
> page cache it needs to discard and anonymous pages get in the way.
> 
> > but unfortunately it have lots corner case.
> > 
> > Viewpoint 1. Unnecessary IO
> > 
> > isolate_pages() for lumpy reclaim frequently grab very young page. it is often
> > still dirty. then, pageout() is called much.
> > 
> > Unfortunately, page size grained io is _very_ inefficient. it can makes lots disk
> > seek and kill disk io bandwidth.
> > 
> 
> Page-based IO like this has also been reported as being a problem for some
> filesystems. When this happens, lumpy reclaim potentially stalls for a long
> time waiting for the dirty data to be flushed by a flusher thread. Compaction
> does not suffer from the same problem.
> 
> > Viewpoint 2. Unevictable pages 
> > 
> > isolate_pages() for lumpy reclaim can pick up unevictable page. it is obviously
> > undroppable. so if the zone have plenty mlocked pages (it is not rare case on
> > server use case), lumpy reclaim can become very useless.
> > 
> 
> Also true. Potentially, compaction can deal with unevictable pages but it's
> not done in this series as it's significant enough as it is and useful in
> its current form.
> 
> > Viewpoint 3. GFP_ATOMIC allocation failure
> > 
> > Obviously lumpy reclaim can't help GFP_ATOMIC issue.
> > 
> 
> Also true although right now, it's not possible to compact for GFP_ATOMIC
> either. I think it could be done on some cases but I didn't try for it.
> High-order GFP_ATOMIC allocations are still something we simply try and
> avoid rather than deal with within the page allocator.
> 
> > Viewpoint 4. reclaim latency
> > 
> > reclaim latency directly affect page allocation latency. so if lumpy reclaim with
> > much pageout io is slow (often it is), it affect page allocation latency and can
> > reduce end user experience.
> > 
> 
> Also true. When allocation huge pages on a normal desktop for example,
> it scan stall the machine for a number of seconds while reclaim kicks
> in.
> 
> With direct compaction, this does not happen to anywhere near the same
> degree. There are still some stalls because as huge pages get allocated,
> free memory drops until pages have to be reclaimed anyway. The effects
> are a lot less prononced and the operation finishes a lot faster.
> 
> > I really hope that auto page migration help to solve above issue. but sadly this 
> > patch seems doesn't.
> > 
> 
> How do you figure? I think it goes a long way to mitigating the worst of
> the problems you laid out above.

Both lumpy reclaim and page comaction have some advantage and some disadvantage.
However we already have lumpy reclaim. I hope you rememver we are attacking
very narrowing corner case. we have to consider to reduce the downside of compaction
at first priority.
Not only big benefit but also big downside seems no good.

So, I'd suggest either way
1) no change caller place, but invoke compaction at very limited situation, or
2) invoke compaction at only lumpy reclaim unfit situation

My last mail, I proposed about (2). but you seems got bad impression. then,
now I propsed (1). I mean we will _start_ to treat the compaction is for
hugepage allocation assistance feature, not generic allocation change.

btw, I hope drop or improve patch 11/11 ;-)



> > Honestly, I think this patch was very impressive and useful at 2-3 years ago.
> > because 1) we didn't have lumpy reclaim 2) we didn't have sane reclaim bail out.
> > then, old vmscan is very heavyweight and inefficient operation for high order reclaim.
> > therefore the downside of adding this page migration is hidden relatively. but...
> > 
> > We have to make an effort to reduce reclaim latency, not adding new latency source.
> 
> I recognise that reclaim latency has been reduced but there is a wall.

If it is a wall, we have to fix this! :)


> The cost of reading the data back in will always be there and on
> swapless systems, it might simply be impossible for lumpy reclaim to do
> what it needs.

Well, I didn't and don't think the compaction is useless. I haven't saied
the compaction is useless.  I've talked about how to avoid downside mess.


> > Instead, I would recommend tightly integrate page-compaction and lumpy reclaim.
> > I mean 1) reusing lumpy reclaim's neighbor pfn page pickking up logic
> 
> There are a number of difficulties with this. I'm not saying it's impossible,
> but the win is not very clear-cut and there are some disadvantages.
> 
> One, there would have to be exceptions for kswapd in the path because it
> really should continue reclaiming. The reclaim path is already very dense
> and this would add significant compliexity to that path.
> 
> The second difficulty is that the migration and free block selection
> algorithm becomes a lot harder, more expensive and identifying the exit
> conditions presents a significant difficultly. Right now, the selection is
> based on linear scans with straight-forward selection and the exit condition
> is simply when the scanners meet. With the migration scanner based on LRU,
> significant care would have to be taken to ensure that appropriate free blocks
> were chosen to migrate to so that we didn't "migrate from" a block in one
> pass and "migrate to" in another (the reason why I went with linear scans
> in the first place). Identifying when the zone has been compacted and should
> just stop is no longer as straight-forward either.  You'd have to track what
> blocks had been operated on in the past which is potentially a lot of state. To
> maintain this state, an unknown number structures would have to be allocated
> which may re-enter the allocator presenting its own class of problems.
> 
> Third, right now it's very easy to identify when compaction is not going
> to work in advance - simply check the watermarks and make a calculation
> based on fragmentation. With a combined reclaim/compaction step, these
> type of checks would need to be made continually - potentially
> increasing the latency of reclaim albeit very slightly.
> 
> Lastly, with this series, there is very little difference between direct
> compaction and proc-triggered compaction. They share the same code paths
> and all that differs is the exit conditions. If it was integrated into
> reclaim, it becomes a lot less straight-forward to share the code.
> 
> > 2) do page
> > migration instead pageout when the page is some condition (example active or dirty
> > or referenced or swapbacked).
> > 
> 
> Right now, it is identifed when pageout should happen instead of page
> migration. It's known before compaction starts if it's likely to be
> successful or not.
> 

patch 11/11 says, it's known likely to be successfull or not, but not exactly.
I think you and I don't have so big different analisys about current behavior.
I feel I merely pesimistic rather than you.



> > This patch seems shoot me! /me die. R.I.P. ;-)
> 
> That seems a bit dramatic. Your alternative proposal has some significant
> difficulties and is likely to be very complicated. Also, there is nothing
> to say that this mechanism could not be integrated with lumpy reclaim over
> time once it was shown that useless migration was going on or latencies were
> increased for some workload.
> 
> This patch seems like a far more rational starting point to me than adding
> more complexity to reclaim at the outset.
> 
> > btw please don't use 'hugeadm --set-recommended-min_free_kbytes' at testing.
> 
> It's somewhat important for the type of stress tests I do for huge page
> allocation. Without it, fragmentation avoidance has trouble and the
> results become a lot less repeatable.
> 
> >     To evaluate a case of free memory starvation is very important for this patch
> >     series, I think. I slightly doubt this patch might invoke useless compaction
> >     in such case.
> > 
> 
> I can drop the min_free_kbytes change but the likely result will be that
> allocation success rates will simply be lower. The calculations on
> whether compaction should be used or not are based on watermarks which
> adjust to the value of min_free_kbytes.

Then, should we need min_free_kbytes auto adjustment trick?


> > At bottom line, the explict compaction via /proc can be merged soon, I think.
> > but this auto compaction logic seems need more discussion.
> 
> My concern would be that the compaction paths would then be used very
> rarely in practice and we'd get no data on how direct compaction should
> be done.

Agree almost.

Again, I think this patch is attacking corner case issue. then, I don't
hope this will makes new corner case. I don't think your approach is
perfectly broken.

But please remember, now compaction might makes very large lru shuffling
in compaction failure case. It mean vmscan might discard very wrong pages.
I have big worry about it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
