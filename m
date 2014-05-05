Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id CE8806B0098
	for <linux-mm@kvack.org>; Mon,  5 May 2014 10:48:32 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so5497797eek.8
        for <linux-mm@kvack.org>; Mon, 05 May 2014 07:48:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si2886694eeg.204.2014.05.05.07.48.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 May 2014 07:48:31 -0700 (PDT)
Message-ID: <5367A4BD.2010209@suse.cz>
Date: Mon, 05 May 2014 16:48:29 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v2 4/4] mm, thp: do not perform sync compaction on pagefault
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011435210.23898@chino.kir.corp.google.com> <20140502102231.GQ23991@suse.de> <alpine.DEB.2.02.1405020402500.19297@chino.kir.corp.google.com> <20140502115834.GR23991@suse.de> <alpine.DEB.2.02.1405021319350.24195@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1405021319350.24195@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/02/2014 10:29 PM, David Rientjes wrote:
> On Fri, 2 May 2014, Mel Gorman wrote:
>
>>> The page locks I'm referring to is the lock_page() in __unmap_and_move()
>>> that gets called for sync compaction after the migrate_pages() iteration
>>> makes a few passes and unsuccessfully grabs it.  This becomes a forced
>>> migration since __unmap_and_move() returns -EAGAIN when the trylock fails.
>>>
>>
>> Can that be fixed then instead of disabling it entirely?
>>
>
> We could return -EAGAIN when the trylock_page() fails for
> MIGRATE_SYNC_LIGHT.  It would become a forced migration but we ignore that
> currently for MIGRATE_ASYNC, and I could extend it to be ignored for
> MIGRATE_SYNC_LIGHT as well.
>
>>> We have perf profiles from one workload in particular that shows
>>> contention on i_mmap_mutex (anon isn't interesting since the vast majority
>>> of memory on this workload [120GB on a 128GB machine] is has a gup pin and
>>> doesn't get isolated because of 119d6d59dcc0 ("mm, compaction: avoid
>>> isolating pinned pages")) between cpus all doing memory compaction trying
>>> to fault thp memory.
>>>
>>
>> Abort SYNC_LIGHT compaction if the mutex is contended.
>>
>
> Yeah, I have patches for that as well but we're waiting to see if they are
> actually needed when sync compaction is disabled for thp.  If we aren't
> actually going to disable it entirely, then I can revive those patches if
> the contention becomes such an issue.
>
>>> That's one example that we've seen, but the fact remains that at times
>>> sync compaction will iterate the entire 128GB machine and not allow an
>>> order-9 page to be allocated and there's nothing to preempt it like the
>>> need_resched() or lock contention checks that async compaction has.
>>
>> Make compact_control->sync the same enum field and check for contention
>> on the async/sync_light case but leave it for sync if compacting via the
>> proc interface?
>>
>
> Ok, that certainly can be done, I wasn't sure you would be happy with such
> a change.  I'm not sure there's so much of a difference between the new
> compact_control->sync == MIGRATE_ASYNC and == MIGRATE_SYNC_LIGHT now,
> though.  Would it make sense to remove MIGRATE_SYNC_LIGHT entirely from
> the page allocator, i.e. remove sync_migration entirely, and just retry
> with a second call to compaction before failing instead?

Maybe we should step back and rethink the conditions for all sources of 
compaction to better balance effort vs desired outcome, so distinguish 4 
modes (just quick thoughts):

1) kswapd - we don't want to slow it down too much, thus async, uses 
cached pfns, honors skip bits, but does not give up on order=X blocks of 
pages just because some page was unable to be isolated/migrated (so 
gradually it might clean up such block over time).

2) hugepaged - it can afford to wait, so async + sync, use cached pfns, 
ignore skip bits on sync, also do not give up on order=THP blocks (?)

3) direct compaction on allocation of order X- we want to avoid 
allocation latencies, so it should skip over order=X blocks of pages as 
soon as it cannot isolate some page in such block (and put back 
already-isolated pages instead of migrating them). As for other 
parameters I'm not sure. Sync should still be possible thanks to the 
deferred_compaction logic? Maybe somehow transform the yes/no answer of 
deferred compaction to a number of how many pageblocks it should try 
before giving up, so there are no latency spikes limited only by the 
size of the zone?

4) compaction from proc interface - sync, reset cached pfn's, ignore 
deferring, ignore skip bits...

Vlastimil


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
