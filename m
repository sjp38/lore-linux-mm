Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6E26B02BE
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 05:04:02 -0400 (EDT)
Received: by wgav7 with SMTP id v7so85005401wga.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 02:04:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oo2si39724774wjc.190.2015.07.21.02.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 02:04:00 -0700 (PDT)
Message-ID: <55AE0AFE.8070200@suse.cz>
Date: Tue, 21 Jul 2015 11:03:58 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz> <1435826795-13777-2-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 07/09/2015 11:53 PM, David Rientjes wrote:
> On Thu, 2 Jul 2015, Vlastimil Babka wrote:
>
>> Memory compaction can be currently performed in several contexts:
>>
>> - kswapd balancing a zone after a high-order allocation failure
>> - direct compaction to satisfy a high-order allocation, including THP page
>>    fault attemps
>> - khugepaged trying to collapse a hugepage
>> - manually from /proc
>>
>> The purpose of compaction is two-fold. The obvious purpose is to satisfy a
>> (pending or future) high-order allocation, and is easy to evaluate. The other
>> purpose is to keep overal memory fragmentation low and help the
>> anti-fragmentation mechanism. The success wrt the latter purpose is more
>> difficult to evaluate.
>>
>> The current situation wrt the purposes has a few drawbacks:
>>
>> - compaction is invoked only when a high-order page or hugepage is not
>>    available (or manually). This might be too late for the purposes of keeping
>>    memory fragmentation low.
>> - direct compaction increases latency of allocations. Again, it would be
>>    better if compaction was performed asynchronously to keep fragmentation low,
>>    before the allocation itself comes.
>> - (a special case of the previous) the cost of compaction during THP page
>>    faults can easily offset the benefits of THP.
>>
>> To improve the situation, we need an equivalent of kswapd, but for compaction.
>> E.g. a background thread which responds to fragmentation and the need for
>> high-order allocations (including hugepages) somewhat proactively.
>>
>> One possibility is to extend the responsibilities of kswapd, which could
>> however complicate its design too much. It should be better to let kswapd
>> handle reclaim, as order-0 allocations are often more critical than high-order
>> ones.
>>
>> Another possibility is to extend khugepaged, but this kthread is a single
>> instance and tied to THP configs.
>>
>> This patch goes with the option of a new set of per-node kthreads called
>> kcompactd, and lays the foundations. The lifecycle mimics kswapd kthreads.
>>
>> The work loop of kcompactd currently mimics an pageblock-order direct
>> compaction attempt each 15 seconds. This might not be enough to keep
>> fragmentation low, and needs evaluation.
>>
>> When there's not enough free memory for compaction, kswapd is woken up for
>> reclaim only (not compaction/reclaim).
>>
>> Further patches will add the ability to wake up kcompactd on demand in special
>> situations such as when hugepages are not available, or when a fragmentation
>> event occured.
>>
>
> Thanks for looking at this again.
>
> The code is certainly clean and the responsibilities vs kswapd and
> khugepaged are clearly defined, but I'm not sure how receptive others
> would be of another per-node kthread.

We'll hopefully see...

> Khugepaged benefits from the periodic memory compaction being done
> immediately before it attempts to compact memory, and that may be lost
> with a de-coupled approach like this.

That could be helped with waking up khugepaged after kcompactd is 
successful in making a hugepage available. Also in your rfc you propose 
the compaction period to be 15 minutes, while khugepaged wakes up each 
10 (or 30) seconds by default for the scanning and collapsing, so only 
fraction of the work is attempted right after the compaction anyway?

> Initially, I suggested implementing this inside khugepaged for that
> purpose, and the full compaction could be done on the next
> scan_sleep_millisecs wakeup before allocating a hugepage and when
> kcompactd_sleep_millisecs would have expired.  So the true period between
> memory compaction events could actually be
> kcompactd_sleep_millisecs - scan_sleep_millisecs.
>
> You bring up an interesting point, though, about non-hugepage uses of
> memory compaction and its effect on keeping fragmentation low.  I'm not
> sure of any reports of that actually being an issue in the wild?

Hm reports of even not-so-high-order allocation failures occur from time 
to time. Some might be from atomic context, but some are because 
compaction just can't help due to the unmovable fragmentation. That's 
mostly a guess, since such detailed information isn't there, but I think 
Joonsoo did some experiments that confirmed this.

Also effects on the fragmentation are evaluated when making changes to 
compaction, see e.g. http://marc.info/?l=linux-mm&m=143634369227134&w=2
In the past it has prevented changes that would improve latency of 
direct compaction. They might be possible if there was a reliable source 
of more thorough periodic compaction to counter the not-so-thorough 
direct compaction.

> I know that the networking layer has done work recently to reduce page
> allocator latency for high-order allocations that can easily fallback to
> order-0 memory: see commit fb05e7a89f50 ("net: don't wait for order-3 page
> allocation").

Yep.

> The slub allocator does try to allocate its high-order memory with
> __GFP_WAIT before falling back to lower orders if possible.  I would think
> that this would be the greatest sign of on-demand memory compaction being
> a problem, especially since CONFIG_SLUB is the default, but I haven't seen
> such reports.

Hm it's true I don't remember such report in the slub context.

> So I'm inclined to think that the current trouble spot for memory
> compaction is thp allocations.  I may live to find differently :)

Yeah it's the most troublesome one, but I wouldn't discount the others.

> How would you feel about implementing this as part of the khugepaged loop
> before allocating a hugepage and scanning memory?

Yeah that's what the previous version did:

http://thread.gmane.org/gmane.linux.kernel.mm/132522

But I found it increasingly clumsy and something that should not depend 
on CONFIG_THP only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
