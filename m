Message-ID: <466D6312.2010302@redhat.com>
Date: Mon, 11 Jun 2007 10:58:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
References: <8e38f7656968417dfee0.1181332979@v2.random> <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random>
In-Reply-To: <20070610181700.GC7443@v2.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Sun, Jun 10, 2007 at 01:36:46PM -0400, Rik van Riel wrote:
>> Andrea Arcangeli wrote:
>>
>>> -	else
>>> +	nr_inactive = zone_page_state(zone, NR_INACTIVE) >> priority;
>>> +	if (nr_inactive < sc->swap_cluster_max)
>>> 		nr_inactive = 0;
>> This is a problem.
>>
>> On workloads with lots of anonymous memory, for example
>> running a very large JVM or simply stressing the system
>> with AIM7, the inactive list can be very small.
>>
>> If dozens (or even hundreds) of tasks get into the
>> pageout code simultaneously, they will all spend a lot
>> of time moving pages from the active to the inactive
>> list, but they will not even try to free any of the
>> (few) inactive pages the system has!
>>
>> We have observed systems in stress tests that spent
>> well over 10 minutes in shrink_active_list before
>> the first call to shrink_inactive_list was made.
>>
>> Your code looks like it could exacerbate that situation,
>> by not having zone->nr_scan_inactive increment between
>> calls.
> 
> If all tasks spend 10 minutes in shrink_active_list before the first
> call to shrink_inactive_list that could mean you hit the race that I'm
> just trying to fix with this very patch. (i.e. nr_*active going
> totally huge because of the race triggering,

Nope.  In this case it spends its time in shrink_active_list
because the active list is 99% of memory (several GB) while
the inactive list is so small that nr_inactive_pages >> priority
is zero.

> Normally if the highest priority passes only calls into
> shrink_active_list that's because the two lists needs rebalancing. But
> I fail to see how it could ever take 10min for the first
> shrink_inactive_list to trigger with my patch applied, while if it
> happens in current vanilla that could be the race triggering, or
> anyway something unrelated is going wrong in the VM.

Yeah, I have no real objection to your patch, but was
just pointing out that it does not fix the big problem
with this code.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
