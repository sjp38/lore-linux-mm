Message-ID: <492EF391.1040408@google.com>
Date: Thu, 27 Nov 2008 11:22:57 -0800
From: Mike Waychison <mikew@google.com>
MIME-Version: 1.0
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
References: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com> <20081123091843.GK30453@elte.hu> <604427e00811251042t1eebded6k9916212b7c0c2ea0@mail.gmail.com> <20081126123246.GB23649@wotan.suse.de> <492DAA24.8040100@google.com> <20081127085554.GD28285@wotan.suse.de> <492E6849.6090205@google.com> <1227780007.4454.1344.camel@twins> <20081127101436.GI28285@wotan.suse.de>
In-Reply-To: <20081127101436.GI28285@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, "H. Peter Anvin" <hpa@zytor.com>, edwintorok@gmail.com
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Thu, Nov 27, 2008 at 11:00:07AM +0100, Peter Zijlstra wrote:
>> On Thu, 2008-11-27 at 01:28 -0800, Mike Waychison wrote:
>>
>>> Correct.  I don't recall the numbers from the pathelogical cases we were 
>>> seeing, but iirc, it was on the order of 10s of seconds, likely 
>>> exascerbated by slower than usual disks.  I've been digging through my 
>>> inbox to find numbers without much success -- we've been using a variant 
>>> of this patch since 2.6.11.
>>> We generally try to avoid such things, but sometimes it a) can't be 
>>> easily avoided (third party libraries for instance) and b) when it hits 
>>> us, it affects the overall health of the machine/cluster (the monitoring 
>>> daemons get blocked, which isn't very healthy).
>> If its only monitoring, there might be another solution. If you can keep
>> the required data in a separate (approximate) copy so that you don't
>> need mmap_sem at all to show them.
>>
>> If your mmap_sem is so contended your latencies are unacceptable, adding
>> more users to it - even statistics gathering, just isn't going to cure
>> the situation.
>>
>> Furthermore, /proc code usually isn't written with performance in mind,
>> so its usually simple and robust code. Adding it to a 'hot'-path like
>> you're doing doesn't seem advisable.
>>
>> Also, releasing and re-acquiring mmap_sem can significantly add to the
>> cacheline bouncing that thing already has.
> 
> Yes, it would be nice to reduce mmap_sem load regardless of any other
> fixes or problems. I guess they're not very worried about cacheline
> bouncing but more about hold time (how many sockets in these systems?
> 4 at most?)
> 
> I guess it is the pagemap stuff that they use most heavily?
> 

We aren't using pagemap yet.  Reading /proc/pid/maps alone hurts.

> pagemap_read looks like it can use get_user_pages_fast. The smaps and
> clear_refs stuff might have been nicer if they could work on ranges
> like pagemap. Then they could avoid mmap_sem as well (although maps
> would need to be sampled and take mmap_sem I guess).
> 
> One problem with dropping mmap_sem is that it hurts priority/fairness.
> And it opens a bit of a (maybe theoretical but not something to completely
> ignore) forward progress hole AFAIKS. If mmap_sem is very heavily
> contended, then the refault is going to take a while to get through,
> and then the page might get reclaimed etc).

Right, this can be an issue.  The way around it should be to minimize 
the length of time any single lock holder can sit on it.  Compared to 
what we have today with:

   - sleep in major fault with read lock held,
   - enqueue writer behind it,
   - and make all other faults wait on the rwsem

The retry logic seems to be a lot better for forward progress.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
