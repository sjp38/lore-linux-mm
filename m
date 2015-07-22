Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5994A6B0256
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 11:23:27 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so103323495wic.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 08:23:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bb10si25314400wib.69.2015.07.22.08.23.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 08:23:25 -0700 (PDT)
Message-ID: <55AFB569.90702@suse.cz>
Date: Wed, 22 Jul 2015 17:23:21 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz> <1435826795-13777-2-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com> <55AE0AFE.8070200@suse.cz> <alpine.DEB.2.10.1507211549380.3833@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507211549380.3833@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 07/22/2015 01:07 AM, David Rientjes wrote:
> On Tue, 21 Jul 2015, Vlastimil Babka wrote:
>
>>> Khugepaged benefits from the periodic memory compaction being done
>>> immediately before it attempts to compact memory, and that may be lost
>>> with a de-coupled approach like this.
>>
>
> Meant to say "before it attempts to allocate a hugepage", but it seems you
> understood that :)

Right :)

>> That could be helped with waking up khugepaged after kcompactd is successful
>> in making a hugepage available.
>
> I don't think the criteria for waking up khugepaged should become any more
> complex beyond its current state, which is impacted by two different
> tunables, and whether it actually has memory to scan.  During this
> additional wakeup, you'd also need to pass kcompactd's node and only do
> local khugepaged scanning since there's no guarantee khugepaged can
> allocate on all nodes when one kcompactd defragments memory.

Keeping track of the nodes where hugepage allocations are expected to 
succeed is already done in this series. "local khugepaged scanning" is 
unfortunately not possible in general, since the node that will be used 
for a given pmd is not known until half of pte's (or more) are scanned.

> I think
> coupling these two would be too complex and not worth it.

It wouldn't be that complex (see above), and go away if khugepaged 
scanning is converted to deferred task work. In that case it's also 
possible to assume that it's only worth touching memory local to the 
task, so if that node indicates no available hugepages, the scanning can 
be skipped.

>> Also in your rfc you propose the compaction
>> period to be 15 minutes, while khugepaged wakes up each 10 (or 30) seconds by
>> default for the scanning and collapsing, so only fraction of the work is
>> attempted right after the compaction anyway?
>>
>
> The rfc actually proposes the compaction period to be 0, meaning it's
> disabled, but suggests in the changelog that we have seen a reproducible
> benefit with the period of 15m.

Ah, right.

> I'm not concerned about scan_sleep_millisecs here, if khugepaged was able
> to successfully allocate in its last scan.  I'm only concerned with
> alloc_sleep_millisecs which defaults to 60000.  I think it would be
> unfortunate if kcompactd were to free a pageblock, and then khugepaged
> waits for 60s before allocating.

Don't forget that khugepaged has to find a suitable pmd first, which can 
take much longer than 60s. It might be rescanning address spaces that 
have no candidates, or processes that are sleeping and wouldn't benefit 
from THP. Another potential advantage for doing the scanning and 
collapses in task context...

>> Hm reports of even not-so-high-order allocation failures occur from time to
>> time. Some might be from atomic context, but some are because compaction just
>> can't help due to the unmovable fragmentation. That's mostly a guess, since
>> such detailed information isn't there, but I think Joonsoo did some
>> experiments that confirmed this.
>>
>
> If it's unmovable fragmentation, then any periodic synchronous memory
> compaction isn't going to help either.

It can help if it moves away movable pages out of unmovable pageblocks, 
so the following unmovable allocations can be served from those 
pageblocks and not fallback to pollute another movable pageblock. Even 
better if this is done (kcompactd woken up) in response to such 
fallback, where unmovable page falls to a partially filled movable 
pageblock. Stuffing also this into khugepaged would be really a stretch. 
Joonsoo proposed another daemon for that in
https://lkml.org/lkml/2015/4/27/94 but extending kcompactd would be a 
very natural way for this.

> The page allocator already does
> MIGRATE_SYNC_LIGHT compaction on its second pass and that will terminate
> when a high-order page is available.  If it is currently failing, then I
> don't see the benefit of synchronous memory compaction over all memory
> that would substantially help this case.

The sync compaction is no longer done for THP page faults, so if there's 
no other source of the sync compaction, system can fragment over time 
and then it might be too late when the need comes.

>> Also effects on the fragmentation are evaluated when making changes to
>> compaction, see e.g. http://marc.info/?l=linux-mm&m=143634369227134&w=2
>> In the past it has prevented changes that would improve latency of direct
>> compaction. They might be possible if there was a reliable source of more
>> thorough periodic compaction to counter the not-so-thorough direct compaction.
>>
>
> Hmm, I don't think we have to select one to the excusion of the other.  I
> don't think that because khugepaged may do periodic synchronous memory
> compaction (to eventually remove direct compaction entirely from the page
> fault path, since we have checks in the page allocator that specifically
> do that)

That would be nice for the THP page faults, yes. Or maybe just change 
the default for thp "defrag" tunable to "madvise".

> that we can't do background memory compaction elsewhere.  I think
> it would be trivial to schedule a workqueue in the page allocator when
> MIGRATE_ASYNC compaction fails for a high-order allocation on a node and
> to have that local compaction done in the background.

I think pushing compaction in a workqueue would meet a bigger resistance 
than new kthreads. It could be too heavyweight for this mechanism and 
what if there's suddenly lots of allocations in parallel failing and 
scheduling the work items? So if we do it elsewhere, I think it's best 
as kcompactd kthreads and then why would we do it also in khugepaged?

I guess a broader input than just us two would help :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
