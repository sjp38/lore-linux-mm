Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9D99A6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 04:39:59 -0500 (EST)
Received: by wesw55 with SMTP id w55so32047255wes.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 01:39:59 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h8si21642482wja.42.2015.03.02.01.39.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 01:39:57 -0800 (PST)
Message-ID: <54F42FEA.1020404@suse.cz>
Date: Mon, 02 Mar 2015 10:39:54 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: How to handle TIF_MEMDIE stalls?
References: <20150210151934.GA11212@phnom.home.cmpxchg.org> <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp> <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp> <20150217125315.GA14287@phnom.home.cmpxchg.org> <20150217225430.GJ4251@dastard> <20150219102431.GA15569@phnom.home.cmpxchg.org> <20150219225217.GY12722@dastard> <20150221235227.GA25079@phnom.home.cmpxchg.org> <20150223004521.GK12722@dastard> <20150222172930.6586516d.akpm@linux-foundation.org> <20150223073235.GT4251@dastard>
In-Reply-To: <20150223073235.GT4251@dastard>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On 02/23/2015 08:32 AM, Dave Chinner wrote:
> On Sun, Feb 22, 2015 at 05:29:30PM -0800, Andrew Morton wrote:
>> On Mon, 23 Feb 2015 11:45:21 +1100 Dave Chinner <david@fromorbit.com> wrote:
>>
>> Yes, as we do for __GFP_HIGH and PF_MEMALLOC etc.  Add a dynamic
>> reserve.  So to reserve N pages we increase the page allocator dynamic
>> reserve by N, do some reclaim if necessary then deposit N tokens into
>> the caller's task_struct (it'll be a set of zone/nr-pages tuples I
>> suppose).
>>
>> When allocating pages the caller should drain its reserves in
>> preference to dipping into the regular freelist.  This guy has already
>> done his reclaim and shouldn't be penalised a second time.  I guess
>> Johannes's preallocation code should switch to doing this for the same
>> reason, plus the fact that snipping a page off
>> task_struct.prealloc_pages is super-fast and needs to be done sometime
>> anyway so why not do it by default.
>
> That is at odds with the requirements of demand paging, which
> allocate for objects that are reclaimable within the course of the
> transaction. The reserve is there to ensure forward progress for
> allocations for objects that aren't freed until after the
> transaction completes, but if we drain it for reclaimable objects we
> then have nothing left in the reserve pool when we actually need it.
>
> We do not know ahead of time if the object we are allocating is
> going to modified and hence locked into the transaction. Hence we
> can't say "use the reserve for this *specific* allocation", and so
> the only guidance we can really give is "we will to allocate and
> *permanently consume* this much memory", and the reserve pool needs
> to cover that consumption to guarantee forwards progress.

I'm not sure I understand properly. You don't know if a specific 
allocation is permanent or reclaimable, but you can tell in advance how 
much in total will be permanent? Is it because you are conservative and 
assume everything will be permanent, or how?

Can you at least at some later point in transaction recognize that "OK, 
this object was not permanent after all" and tell mm that it can lower 
your reserve?

> Forwards progress for all other allocations is guaranteed because
> they are reclaimable objects - they either freed directly back to
> their source (slab, heap, page lists) or they are freed by shrinkers
> once they have been released from the transaction.

Which are the "all other allocations?" Above you wrote that all 
allocations are treated as potentially permanent. Also how does the fact 
that an object is later reclaimable, affect forward progress during its 
allocation? Or all you talking about allocations from contexts that 
don't use reserves?

> Hence we need allocations to come from the free list and trigger
> reclaim, regardless of the fact there is a reserve pool there. The
> reserve pool needs to be a last resort once there are no other
> avenues to allocate memory. i.e. it would be used to replace the OOM
> killer for GFP_NOFAIL allocations.

That's probably going to result in lot of wasted memory and I still 
don't understand why it's needed, if your reserve estimate is guaranteed 
to cover the worst-case.

>> Both reservation and preallocation are vulnerable to deadlocks - 10,000
>> tasks all trying to reserve/prealloc 100 pages, they all have 50 pages
>> and we ran out of memory.  Whoops.
>
> Yes, that's the big problem with preallocation, as well as your
> proposed "depelete the reserved memory first" approach. They
> *require* up front "preallocation" of free memory, either directly
> by the application, or internally by the mm subsystem.

I don't see why it would deadlock, if during reserve time the mm can 
return ENOMEM as the reserver should be able to back out at that point.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
