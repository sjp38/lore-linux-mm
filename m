Message-ID: <45350CF3.6030306@yahoo.com.au>
Date: Wed, 18 Oct 2006 03:03:47 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Fix bug in try_to_free_pages and balance_pgdat when they
 fail to reclaim pages
References: <453425A5.5040304@google.com> <453475A4.2000504@yahoo.com.au> <453479D2.1090302@google.com> <45347CA3.9020904@yahoo.com.au> <4534E397.8090505@google.com>
In-Reply-To: <4534E397.8090505@google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@google.com>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:

>> But temp_priority should be set to 0 at that point.
> 
> 
> It that were true, it'd be great. But how?
> This is everything that touches it:
> 
> 0 mmzone.h     <global>             208 int temp_priority;
> 1 page_alloc.c free_area_init_core 2019 zone->temp_priority =
>                                         zone->prev_priority = DEF_PRIORITY;
> 2 vmscan.c     shrink_zones         937 zone->temp_priority = priority;
> 3 vmscan.c     try_to_free_pages    987 zone->temp_priority = DEF_PRIORITY;
> 4 vmscan.c     try_to_free_pages   1031 zone->prev_priority =
>                                         zone->temp_priority;
> 5 vmscan.c     balance_pgdat       1081 zone->temp_priority = DEF_PRIORITY;
> 6 vmscan.c     balance_pgdat       1143 zone->temp_priority = priority;
> 7 vmscan.c     balance_pgdat       1189 zone->prev_priority =
>                                         zone->temp_priority;
> 8 vmstat.c     zoneinfo_show        593 zone->temp_priority,
> 
> Only thing that looks interesting here is shrink_zones.

For try_to_free_pages, shrink_zones will continue to be called until
priority reaches 0. So temp_priority and prev_priority are now 0. When
it breaks out of the loop, prev_priority gets assigned temp_priority.
Both of which are zero *unless you've hit the temp_priority race*. As
I said, getting rid of temp_priority and somehow tracking it locally
will close this race. I agree this race is a bug and would be happy to
see it fixed. This might be what your patch inadvertently fixes.



>> But your loops are not exactly per reclaimer either. Granted there
>> is a large race window in the current code, but this patch isn't the
>> way to fix that particular problem.
> 
> 
> Why not? Perhaps it's not a panacea, but it's a definite improvement.

OK it is an improvement for the cases when we hit priority = 0. It would
be nice to fix the race for medium priorities as well though. Hmm, OK,
if we can't do that easily then I would be OK with this approach for the
time being.

Please don't duplicate that whole loop again in try_to_free_pages, though.

> 
>>> Moreover, whilst try_to_free_pages calls shrink_zones, balance_pgdat
>>> does not. Nothing else I can see sets temp_priority.
>>
>>
>> balance_pgdat.
> 
> 
> That's only called from kswapd. If we're in balance_pgdat, we ARE 
> kswapd. We can't fix ourself. So effectively we're doing:
> 
> while (priority--) {
>     if (we reclaimed OK)
>         goto out;
> }
> out:
> prev_priority = DEF_PRIORITY;
> 
> We've just walked the whole bloody list with priority set to 0.
> 
> We failed to reclaim a few pages.
> 
> We know the world is in deep pain.
> 
> Why the hell would we elevate prev_priority?

No. If we've walked the whole bloody list and failed to reclaim any
pages, we do not set prev_priority to DEF_PRIORITY. Read the code, it
does the same thing with the priorities as shrink_zones.

>> Unnecesary and indicates something else is broken if you are seeing
>> problems here.
> 
> 
> You think we should set prev_priority up, when we've just walked the
> whole list at prio 0 and can't reclaim anything? Unless so, I fail
> to see how the patch is unnecessary.
> 
> And yes, I'm sure other things are broken, but again, this fixes a
> clear bug.

AFAIKS there is no bug that have identified here or in your changelog.
There is a race, there are many of tolerable races in reclaim. I can
accept this races is intolerable for you, so I am OK with fixing it.


>  > So do you still see the problem on upstream kernel
> 
>> without your patches applied?
> 
> 
> I can't slap an upstream bleeding edge kernel across a few thousand
> production machines, and wait to see if the world blows up, sorry.
> If I can make a reproduce test case, I'll send it out, but thus far
> we've been unsuccessful.

No problem, I didn't ask you to do that. But if you want this patch
in the upstream kerenl, then I will keep asking whether it fixes a
problem in the upstream kernel.

> 
> But I can see it happening in earlier versions, and I can read the
> code in 2.6.18, and see obvious bugs.

I can't see any besides the temp_priority race.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
