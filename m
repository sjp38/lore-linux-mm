Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3E326B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:28:03 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id q40so1342990ywa.8
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:28:03 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b39-v6si208008ybi.714.2018.03.13.14.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 14:28:02 -0700 (PDT)
Subject: Re: [PATCH v2] mm: make start_isolate_page_range() fail if already
 isolated
References: <20180226191054.14025-1-mike.kravetz@oracle.com>
 <20180309224731.16978-1-mike.kravetz@oracle.com>
 <20180313141454.f3ad61c301c299ab6f81aae0@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <182227bf-3fa1-e8dd-1bd2-b2530f5bd0e8@oracle.com>
Date: Tue, 13 Mar 2018 14:27:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180313141454.f3ad61c301c299ab6f81aae0@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On 03/13/2018 02:14 PM, Andrew Morton wrote:
> On Fri,  9 Mar 2018 14:47:31 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> start_isolate_page_range() is used to set the migrate type of a
>> set of pageblocks to MIGRATE_ISOLATE while attempting to start
>> a migration operation.  It assumes that only one thread is
>> calling it for the specified range.  This routine is used by
>> CMA, memory hotplug and gigantic huge pages.  Each of these users
>> synchronize access to the range within their subsystem.  However,
>> two subsystems (CMA and gigantic huge pages for example) could
>> attempt operations on the same range.  If this happens, one thread
>> may 'undo' the work another thread is doing.  This can result in
>> pageblocks being incorrectly left marked as MIGRATE_ISOLATE and
>> therefore not available for page allocation.
>>
>> What is ideally needed is a way to synchronize access to a set
>> of pageblocks that are undergoing isolation and migration.  The
>> only thing we know about these pageblocks is that they are all
>> in the same zone.  A per-node mutex is too coarse as we want to
>> allow multiple operations on different ranges within the same zone
>> concurrently.  Instead, we will use the migration type of the
>> pageblocks themselves as a form of synchronization.
>>
>> start_isolate_page_range sets the migration type on a set of page-
>> blocks going in order from the one associated with the smallest
>> pfn to the largest pfn.  The zone lock is acquired to check and
>> set the migration type.  When going through the list of pageblocks
>> check if MIGRATE_ISOLATE is already set.  If so, this indicates
>> another thread is working on this pageblock.  We know exactly
>> which pageblocks we set, so clean up by undo those and return
>> -EBUSY.
>>
>> This allows start_isolate_page_range to serve as a synchronization
>> mechanism and will allow for more general use of callers making
>> use of these interfaces.  Update comments in alloc_contig_range
>> to reflect this new functionality.
>>
>> ...
>>
>> + * There is no high level synchronization mechanism that prevents two threads
>> + * from trying to isolate overlapping ranges.  If this happens, one thread
>> + * will notice pageblocks in the overlapping range already set to isolate.
>> + * This happens in set_migratetype_isolate, and set_migratetype_isolate
>> + * returns an error.  We then clean up by restoring the migration type on
>> + * pageblocks we may have modified and return -EBUSY to caller.  This
>> + * prevents two threads from simultaneously working on overlapping ranges.
>>   */
> 
> Well I can kinda visualize how this works, with two CPUs chewing away
> at two overlapping blocks of pfns, possibly with different starting
> pfns.  And I can't immediately see any holes in it, apart from possible
> memory ordering issues.  What guarantee is there that CPU1 will see
> CPU2's writes in the order in which CPU2 performed them?  And what
> guarantee is there that CPU1 will see CPU2's writes in a sequential
> manner?  If four of CPU2's writes get written back in a single atomic
> flush, what will CPU1 make of that?
> 

Each CPU holds the associated zone lock to modify or examine the migration
type of a pageblock.  And, it will only examine/update a single pageblock
per lock acquire/release cycle.

-- 
Mike Kravetz
