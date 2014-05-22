Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACBF6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 04:10:19 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so2235538eek.8
        for <linux-mm@kvack.org>; Thu, 22 May 2014 01:10:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m45si13328133eeu.47.2014.05.22.01.10.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 01:10:17 -0700 (PDT)
Message-ID: <537DB0E5.40602@suse.cz>
Date: Thu, 22 May 2014 10:10:13 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: compaction is still too expensive for thp
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz> <1400233673-11477-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 05/22/2014 05:20 AM, David Rientjes wrote:
> On Fri, 16 May 2014, Vlastimil Babka wrote:
>
>> Compaction uses compact_checklock_irqsave() function to periodically check for
>> lock contention and need_resched() to either abort async compaction, or to
>> free the lock, schedule and retake the lock. When aborting, cc->contended is
>> set to signal the contended state to the caller. Two problems have been
>> identified in this mechanism.
>>
>> First, compaction also calls directly cond_resched() in both scanners when no
>> lock is yet taken. This call either does not abort async compaction, or set
>> cc->contended appropriately. This patch introduces a new compact_should_abort()
>> function to achieve both. In isolate_freepages(), the check frequency is
>> reduced to once by SWAP_CLUSTER_MAX pageblocks to match what the migration
>> scanner does in the preliminary page checks. In case a pageblock is found
>> suitable for calling isolate_freepages_block(), the checks within there are
>> done on higher frequency.
>>
>> Second, isolate_freepages() does not check if isolate_freepages_block()
>> aborted due to contention, and advances to the next pageblock. This violates
>> the principle of aborting on contention, and might result in pageblocks not
>> being scanned completely, since the scanning cursor is advanced. This patch
>> makes isolate_freepages_block() check the cc->contended flag and abort.
>>
>> In case isolate_freepages() has already isolated some pages before aborting
>> due to contention, page migration will proceed, which is OK since we do not
>> want to waste the work that has been done, and page migration has own checks
>> for contention. However, we do not want another isolation attempt by either
>> of the scanners, so cc->contended flag check is added also to
>> compaction_alloc() and compact_finished() to make sure compaction is aborted
>> right after the migration.
>>
>
> We have a pretty significant problem with async compaction related to thp
> faults and it's not limited to this patch but was intended to be addressed
> in my series as well.  Since this is the latest patch to be proposed for
> aborting async compaction when it's too expensive, it's probably a good
> idea to discuss it here.

I already tried to call for some higher level discussion eariler in your 
series, good that hear that now you also agree it might be useful :)

> With -mm, it turns out that while egregious thp fault latencies were
> reduced, faulting 64MB of memory backed by thp on a fragmented 128GB
> machine can result in latencies of 1-3s for the entire 64MB.  Collecting
> compaction stats from older kernels that give more insight into
> regressions, one such incident is as follows.
>
> Baseline:
> compact_blocks_moved 8181986
> compact_pages_moved 6549560
> compact_pagemigrate_failed 1612070
> compact_stall 101959
> compact_fail 100895
> compact_success 1064
>
> 5s later:
> compact_blocks_moved 8182447
> compact_pages_moved 6550286
> compact_pagemigrate_failed 1612092
> compact_stall 102023
> compact_fail 100959
> compact_success 1064
>
> This represents faulting two 64MB ranges of anonymous memory.  As you can
> see, it results in falling back to 4KB pages because all 64 faults of
> hugepages ends up triggering compaction and failing to allocate.  Over the
> 64 async compactions, we scan on average 7.2 pageblocks per call,
> successfully migrate 11.3 pages per call, and fail migrating 0.34 pages
> per call.
>
> If each async compaction scans 7.2 pageblocks per call, it would have to
> be called 9103 times to scan all memory on this 128GB machine.  We're
> simply not scanning enough memory as a result of ISOLATE_ABORT due to
> need_resched().

Well, the two objectives of not being expensive and at the same time 
scanning "enough memory" (which is hard to define as well) are clearly 
quite opposite :/

> So the net result is that -mm is much better than Linus's tree, where such
> faulting of 64MB ranges could stall 8-9s, but we're still very expensive.

So I guess the difference here is mainly thanks to not doing sync 
compaction? Or do you have any insight which patch helped the most?

> We may need to consider scanning more memory on a single call to async
> compaction even when need_resched() and if we are unsuccessful in
> allocating a hugepage to defer async compaction in subsequent calls up to
> 1 << COMPACT_MAX_DEFER_SHIFT.  Today, we defer on sync compaction but that
> is now never done for thp faults since it is reliant solely on async
> compaction.

So if I understand correctly, your intention is to scan more in a single 
scan, but balance the increased latencies by introducing deferring for 
async compaction.

Offhand I can think of two issues with that.

1) the result will be that often the latency will be low thanks to 
defer, but then there will be a huge (?) spike by scanning whole 1GB (as 
you suggest further in the mail) at once. I think that's similar to what 
you had now with the sync compaction?

2) 1GB could have a good chance of being successful (?) so there would 
be no defer anyway.

I have some other suggestion at the end of my mail.

> I have a few improvements in mind, but thought it would be better to
> get feedback on it first because it's a substantial rewrite of the
> pageblock migration:
>
>   - For all async compaction, avoid migrating memory unless enough
>     contiguous memory is migrated to allow a cc->order allocation.

Yes I suggested something like this earlier. Also in the scanner, skip 
to the next cc->order aligned block as soon as any page fails the 
isolation and is not PageBuddy.
I would just dinstinguish kswapd and direct compaction, not "all async 
compaction". Or maybe kswapd could be switched to sync compaction.

>     This
>     would remove the COMPACT_CLUSTER_MAX restriction on pageblock
>     compaction

Yes.

>     and keep pages on the cc->migratepages list between
>     calls to isolate_migratepages_range().

This might not be needed. It's called within a single pageblock (except 
maybe CMA but that's quite a different thing) and I think we can ignore 
order > pageblock_nr_order here.

>     When an unmigratable page is encountered or memory hole is found,
>     put all pages on cc->migratepages back on the lru lists unless
>     cc->nr_migratepages >= (1 << cc->order).  Otherwise, migrate when
>     enough contiguous memory has been isolated.
>
>   - Remove the need_resched() checks entirely from compaction and
>     consider only doing a set amount of scanning for each call, such
>     as 1GB per call.
>
>     If there is contention on zone->lru_lock, then we can still abort
>     to avoid excessive stalls, but need_resched() is a poor heuristic
>     to determine when async compaction is taking too long.

I tend to agree. I've also realized that because need_resched() leads to 
cc->contended = true, direct reclaim and second compaction that would 
normally follow (used to be sync, now only in hugepaged) is skipped. 
need_resched() seems to be indeed unsuitable for this.

>     The expense of calling async compaction if this is done is easily
>     quantified since we're not migrating any memory unless it is
>     sufficient for the page allocation: it would simply be the iteration
>     over 1GB of memory and avoiding contention on zone->lru_lock.
>
> We may also need to consider deferring async compaction for subsequent
> faults in the near future even though scanning the previous 1GB does not
> decrease or have any impact whatsoever in the success of defragmenting the
> next 1GB.
>
> Any other suggestions that may be helpful?

I suggested already the idea of turning the deferred compaction into a 
live-tuned amount of how much to scan, instead of doing a whole zone 
(before) or an arbitrary amount like 1GB, with the hope of reducing the 
latency spikes. But I realize this would be tricky.

Even less concrete, it might be worth revisiting the rules we use for 
deciding if compaction is worth trying, and the decisions if to continue 
or we believe the allocation will succeed. It relies heavily on 
watermark checks that also consider the order, and I found it somewhat 
fragile. For example, in the alloc slowpath -> direct compaction path, a 
check in compaction concludes that allocation should succeed and 
finishes the compaction, and few moments later the same check in the 
allocation will conclude that everything is fine up to order 8, but 
there probably isn't a page of order 9. In between, the nr_free_pages 
has *increased*. I suspect it's because the watermark checking is racy 
and the counters drift, but I'm not sure yet.
However, this particular problem should be gone when I finish my series 
that would capture the page that compaction has just freed. But still, 
the decisions regarding compaction could be suboptimal.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
