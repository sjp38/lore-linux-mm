Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEAD6B00D7
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 08:18:17 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hi2so617649wib.4
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 05:18:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fu7si26711099wib.85.2014.06.12.05.18.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 05:18:15 -0700 (PDT)
Message-ID: <53999A84.7010105@suse.cz>
Date: Thu, 12 Jun 2014 14:18:12 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 6/6] mm, compaction: don't migrate in blocks that
 cannot be fully compacted in async direct compaction
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-6-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041705140.22536@chino.kir.corp.google.com> <53908F10.4020603@suse.cz> <alpine.DEB.2.02.1406051431030.18119@chino.kir.corp.google.com> <53916EE7.9000806@suse.cz> <alpine.DEB.2.02.1406090156340.24247@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406090156340.24247@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/09/2014 11:06 AM, David Rientjes wrote:
> On Fri, 6 Jun 2014, Vlastimil Babka wrote:
>
>>> Agreed.  I was thinking higher than 1GB would be possible once we have
>>> your series that does the pageblock skip for thp, I think the expense
>>> would be constant because we won't needlessly be migrating pages unless it
>>> has a good chance at succeeding.
>>
>> Looks like a counter of iterations actually done in scanners, maintained in
>> compact_control, would work better than any memory size based limit? It could
>> better reflect the actual work done and thus latency. Maybe increase the counter
>> also for migrations, with a higher cost than for a scanner iteration.
>>
>
> I'm not sure we can expose that to be configurable by userspace in any
> meaningful way.  We'll want to be able to tune this depending on the size
> of the machine if we are to truly remove the need_resched() heuristic and
> give it a sane default.  I was thinking it would be similar to
> khugepaged's pages_to_scan value that it uses on each wakeup.

Perhaps userspace can see the value in memory size unit, which would be 
translated to pages_to_scan assuming the worst case, i.e. scanning each 
page? Which would be used to limit the iterations, so if we end up 
skipping blocks of pages instead of single pages for whatever reasons, 
we can effectively scan a bigger memory size with the same effort?

>>> This does beg the question about parallel direct compactors, though, that
>>> will be contending on the same coarse zone->lru_lock locks and immediately
>>> aborting and falling back to PAGE_SIZE pages for thp faults that will be
>>> more likely if your patch to grab the high-order page and return it to the
>>> page allocator is merged.
>>
>> Hm can you explain how the page capturing makes this worse? I don't see it.
>>
>
> I was expecting that your patch to capture the high-order page made a
> difference because the zone watermark check doesn't imply the high-order
> page will be allocatable after we return to the page allocator to allocate
> it.  In that case, we terminated compaction prematurely.

In fact compact_finished() uses both a watermark check and then a 
free_list check. Only if both pass, it exits. But page allocation then 
does another watermark check which may fail (due to its raciness and 
drift) even though the page is still available on the free_list.

> If that's true,
> then it seems like no parallel thp allocator will be able to allocate
> memory that another direct compactor has freed without entering compaction
> itself on a fragmented machine, and thus an increase in zone->lru_lock
> contention if there's migratable memory.

I think it's only fair if someone who did the compaction work can 
allocate the page. Another compaction then has to do its own work, so in 
the end it's 2 units of work for 2 allocations (assuming success). 
Without the fairness, it might be 2 units of work by single allocator, 
for 2 successful allocations of two allocators. Or, as you seem to 
imply, 1 unit of work for 1 successful allocation, because the one doing 
the work will terminate prematurely and end up without allocation.
If we really rely on this premature termination as a contention 
prevention, then it seems quite unfair and fragile to me.

> Having 32 cpus fault thp memory and all entering compaction and contending
> (and aborting because of contention, currently) on zone->lru_lock is a
> really bad situation.

I'm not sure if the premature termination could prevent this reliably. I 
rather doubt that. The lock contention checks should work just fine in 
this case. And also I don't think it's that bad if they abort due to 
contention, if it happens quickly. It means that in such situation, it's 
simply a better performance tradeoff to give up on THP and fallback to 
4k allocation. Also you say "currently" but we are not going to change 
that for lock contention, are we?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
