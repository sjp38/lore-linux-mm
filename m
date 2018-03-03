Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B81626B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 20:39:39 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id y17so9045216qth.11
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 17:39:39 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c184si2648125qkf.344.2018.03.02.17.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 17:39:38 -0800 (PST)
Subject: Re: [PATCH 1/1] mm: make start_isolate_page_range() fail if already
 isolated
References: <20180226191054.14025-1-mike.kravetz@oracle.com>
 <20180226191054.14025-2-mike.kravetz@oracle.com>
 <20180302160607.570e13f2157f56503fe1bdaa@linux-foundation.org>
 <3887b37d-2bc0-1eff-9aec-6a99cc0715fb@oracle.com>
 <20180302165614.edb17a020964e9ea2f1797ca@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <40e790c9-cd78-3d41-a69b-bff4f024c9f1@oracle.com>
Date: Fri, 2 Mar 2018 17:39:25 -0800
MIME-Version: 1.0
In-Reply-To: <20180302165614.edb17a020964e9ea2f1797ca@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On 03/02/2018 04:56 PM, Andrew Morton wrote:
> On Fri, 2 Mar 2018 16:38:33 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> On 03/02/2018 04:06 PM, Andrew Morton wrote:
>>> On Mon, 26 Feb 2018 11:10:54 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>>>
>>>> start_isolate_page_range() is used to set the migrate type of a
>>>> set of page blocks to MIGRATE_ISOLATE while attempting to start
>>>> a migration operation.  It assumes that only one thread is
>>>> calling it for the specified range.  This routine is used by
>>>> CMA, memory hotplug and gigantic huge pages.  Each of these users
>>>> synchronize access to the range within their subsystem.  However,
>>>> two subsystems (CMA and gigantic huge pages for example) could
>>>> attempt operations on the same range.  If this happens, page
>>>> blocks may be incorrectly left marked as MIGRATE_ISOLATE and
>>>> therefore not available for page allocation.
>>>>
>>>> Without 'locking code' there is no easy way to synchronize access
>>>> to the range of page blocks passed to start_isolate_page_range.
>>>> However, if two threads are working on the same set of page blocks
>>>> one will stumble upon blocks set to MIGRATE_ISOLATE by the other.
>>>> In such conditions, make the thread noticing MIGRATE_ISOLATE
>>>> clean up as normal and return -EBUSY to the caller.
>>>>
>>>> This will allow start_isolate_page_range to serve as a
>>>> synchronization mechanism and will allow for more general use
>>>> of callers making use of these interfaces.  So, update comments
>>>> in alloc_contig_range to reflect this new functionality.
>>>>
>>>> ...
>>>>
>>>> --- a/mm/page_isolation.c
>>>> +++ b/mm/page_isolation.c
>>>> @@ -28,6 +28,13 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
>>>>  
>>>>  	spin_lock_irqsave(&zone->lock, flags);
>>>>  
>>>> +	/*
>>>> +	 * We assume we are the only ones trying to isolate this block.
>>>> +	 * If MIGRATE_ISOLATE already set, return -EBUSY
>>>> +	 */
>>>> +	if (is_migrate_isolate_page(page))
>>>> +		goto out;
>>>> +
>>>>  	pfn = page_to_pfn(page);
>>>>  	arg.start_pfn = pfn;
>>>>  	arg.nr_pages = pageblock_nr_pages;
>>>
>>> Seems a bit ugly and I'm not sure that it's correct.  If the loop in
>>> start_isolate_page_range() gets partway through a number of pages then
>>> we hit the race, start_isolate_page_range() will then go and "undo" the
>>> work being done by the thread which it is racing against?
>>
>> I agree that it is a bit ugly.  However, when a thread hits the above
>> condition it will only undo what it has done.  Only one thread is able
>> to set migrate state to isolate (under the zone lock).  So, a thread
>> will only undo what it has done.
> 
> I don't get it.  That would make sense if start_isolate_page_range()
> held zone->lock across the entire loop, but it doesn't do that.
> 

It works because all threads set migrate isolate on page blocks going
from pfn low to pfn high.  When they encounter a conflict, they know
exactly which blocks they set and only undo those blocks.  Perhaps, I
am missing something, but it does not matter because ...

>> The exact problem of one thread undoing what another thread has done
>> is possible with the code today and is what this patch is attempting
>> to address.
>>
>>> Even if that can't happen, blundering through a whole bunch of pages
>>> then saying whoops then undoing everything is unpleasing.
>>>
>>> Should we be looking at preventing these races at a higher level?
>>
>> I could not immediately come up with a good idea here.  The zone lock
>> would be the obvious choice, but I don't think we want to hold it while
>> examining each of the page blocks.  Perhaps a new lock or semaphore
>> associated with the zone?  I'm open to suggestions.
> 
> Yes, I think it would need a new lock.  Hopefully a mutex.

I'll look into adding an 'isolate' mutex to the zone structure and reworking
this patch.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
