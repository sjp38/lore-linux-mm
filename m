Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC0B6B0260
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 05:18:52 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so14947180wib.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 02:18:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oo2si7191241wjc.190.2015.07.23.02.18.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jul 2015 02:18:50 -0700 (PDT)
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
 <1435826795-13777-2-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com>
 <55AE0AFE.8070200@suse.cz>
 <alpine.DEB.2.10.1507211549380.3833@chino.kir.corp.google.com>
 <55AFB569.90702@suse.cz>
 <alpine.DEB.2.10.1507221509520.24115@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B0B175.9090306@suse.cz>
Date: Thu, 23 Jul 2015 11:18:45 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1507221509520.24115@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 07/23/2015 12:36 AM, David Rientjes wrote:
> On Wed, 22 Jul 2015, Vlastimil Babka wrote:
> 
>> > I don't think the criteria for waking up khugepaged should become any more
>> > complex beyond its current state, which is impacted by two different
>> > tunables, and whether it actually has memory to scan.  During this
>> > additional wakeup, you'd also need to pass kcompactd's node and only do
>> > local khugepaged scanning since there's no guarantee khugepaged can
>> > allocate on all nodes when one kcompactd defragments memory.
>> 
>> Keeping track of the nodes where hugepage allocations are expected to succeed
>> is already done in this series. "local khugepaged scanning" is unfortunately
>> not possible in general, since the node that will be used for a given pmd is
>> not known until half of pte's (or more) are scanned.
>> 
> 
> When a khugepaged allocation fails for a node, it could easily kick off 
> background compaction on that node and revisit the range later, very 
> similar to how we can kick off background compaction in the page allocator 
> when async or sync_light compaction fails.

The revisiting sounds rather complicated. Page allocator doesn't have to do that.

> The distinction I'm trying to draw is between "periodic" and "background" 
> compaction.  I think there're usecases for both and we shouldn't be 
> limiting ourselves to one or the other.

OK, I understand you think we can have both, and the periodic one would be in
khugepaged. My main concern is that if we do the periodic one in khugepaged,
people might oppose adding yet another one as kcompactd. I hope we agree that
khugepaged is not suitable for all the use cases of the background one.

My secondary concern/opinion is that I would hope that the background compaction
would be good enough to remove the need for the periodic one. So I would try the
background one first. But I understand the periodic one is simpler to implement.
On the other hand, it's not as urgent if you can simulate it from userspace.
With the 15min period you use, there's likely not much overhead saved when
invoking it from within the kernel? Sure there wouldn't be the synchronization
with khugepaged activity, but I still wonder if wiating for up to 1 minute
before khugepaged wakes up can make much difference with the 15min period.
Hm, your cron job could also perhaps adjust the khugepaged sleep tunable when
compaction is done, which IIRC results in immediate wakeup.

> Periodic compaction would wakeup at a user-defined period and fully 
> compact memory over all nodes, round-robin at each wakeup.  This keeps 
> fragmentation low so that (ideally) background compaction or direct 
> compaction wouldn't be needed.
> 
> Background compaction would be triggered from the page allocator when 
> async or sync_light compaction fails, regardless of whether this was from 
> khugepaged, page fault context, or any other high-order allocation.  This 
> is an interesting discussion because I can think of lots of ways to be 
> smart about it, but I haven't tried to implement it yet: heuristics that 
> do ratelimiting, preemptive compaction based on fragmentation stats, etc.

Yes.

> My rfc implements periodic compaction in khugepaged simply because we find 
> very large thp_fault_fallback numbers and these faults tend to come in 
> bunches so that background compaction wouldn't really help the situation 
> itself: it's simply not fast enough and we give up compaction at fault way 
> too early for it have a chance of being successful.  I have a hard time 
> finding other examples of that outside thp, especially at such large 
> orders.  The number one culprit that I can think of would be slub and I 
> haven't seen any complaints about high order_fallback stats.
> 
> The additional benefit of doing the periodic compaction in khugepaged is 
> that we can do it before scanning, where alloc_sleep_millisecs is so high 
> that kicking off background compaction on allocation failure wouldn't 
> help.
> 
> Then, storing the nodes where khugepaged allocation has failed isn't 
> needed: the allocation itself would trigger background compaction.

The storing is more useful for THP page faults as it prevents further direct
reclaim and compaction attempts (potentially interferring with the background
compaction), until the triggered background compaction succeeds. The assumption
is that the attempts would likely fail anyway and just increase the page fault
latency. You could see it as a simple rate limiting too.

>> > If it's unmovable fragmentation, then any periodic synchronous memory
>> > compaction isn't going to help either.
>> 
>> It can help if it moves away movable pages out of unmovable pageblocks, so the
>> following unmovable allocations can be served from those pageblocks and not
>> fallback to pollute another movable pageblock. Even better if this is done
>> (kcompactd woken up) in response to such fallback, where unmovable page falls
>> to a partially filled movable pageblock. Stuffing also this into khugepaged
>> would be really a stretch. Joonsoo proposed another daemon for that in
>> https://lkml.org/lkml/2015/4/27/94 but extending kcompactd would be a very
>> natural way for this.
>> 
> 
> Sure, this is an example of why background compaction would be helpful and 
> triggered by the page allocator when async or migrate_sync allocation 
> fails.
> 
>> > Hmm, I don't think we have to select one to the excusion of the other.  I
>> > don't think that because khugepaged may do periodic synchronous memory
>> > compaction (to eventually remove direct compaction entirely from the page
>> > fault path, since we have checks in the page allocator that specifically
>> > do that)
>> 
>> That would be nice for the THP page faults, yes. Or maybe just change the
>> default for thp "defrag" tunable to "madvise".
>> 
> 
> Right, however I'm afraid that what we have done to compaction in the 
> fault path for MIGRATE_ASYNC has been implicitly change that default in 
> the code :)  I have examples where async compaction in the fault path 
> scans three pageblocks and gives up because of the abort heuristics, 
> that's not suggesting that we'll be very successful.  The hope is that we 
> can change the default to "madvise" due to periodic and background 
> compaction and then make the "always" case do some actual defrag :)

OK.

>> I think pushing compaction in a workqueue would meet a bigger resistance than
>> new kthreads. It could be too heavyweight for this mechanism and what if
>> there's suddenly lots of allocations in parallel failing and scheduling the
>> work items? So if we do it elsewhere, I think it's best as kcompactd kthreads
>> and then why would we do it also in khugepaged?
>> 
> 
> We'd need the aforementioned ratelimiting to ensure that background 
> compaction is handled appropriately, absolutely.

So we would limit the number of work items, but a single work item could still
be very heavyweight. I'm not sure it would be perceived well, as well as lack of
accountability. Kthread is still better for this type of work IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
