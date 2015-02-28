Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2696B0083
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 13:36:08 -0500 (EST)
Received: by wesx3 with SMTP id x3so26053862wes.6
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 10:36:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5si9978412wiv.80.2015.02.28.10.36.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 28 Feb 2015 10:36:06 -0800 (PST)
Message-ID: <54F20A93.6080704@suse.cz>
Date: Sat, 28 Feb 2015 19:36:03 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: How to handle TIF_MEMDIE stalls?
References: <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp> <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp> <20150210151934.GA11212@phnom.home.cmpxchg.org> <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp> <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp> <20150217125315.GA14287@phnom.home.cmpxchg.org> <20150217225430.GJ4251@dastard> <20150219102431.GA15569@phnom.home.cmpxchg.org> <20150219225217.GY12722@dastard> <20150221235227.GA25079@phnom.home.cmpxchg.org> <20150223004521.GK12722@dastard>
In-Reply-To: <20150223004521.GK12722@dastard>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On 23.2.2015 1:45, Dave Chinner wrote:
> On Sat, Feb 21, 2015 at 06:52:27PM -0500, Johannes Weiner wrote:
>> On Fri, Feb 20, 2015 at 09:52:17AM +1100, Dave Chinner wrote:
>>> I will actively work around aanything that causes filesystem memory
>>> pressure to increase the chance of oom killer invocations. The OOM
>>> killer is not a solution - it is, by definition, a loose cannon and
>>> so we should be reducing dependencies on it.
>>
>> Once we have a better-working alternative, sure.
> 
> Great, but first a simple request: please stop writing code and
> instead start architecting a solution to the problem. i.e. we need a
> design and have that documented before code gets written. If you
> watched my recent LCA talk, then you'll understand what I mean
> when I say: stop programming and start engineering.

About that... I guess good engineering also means looking at past solutions to
the same problem. I expect there would be a lot of academic work on this, which
might tell us what's (not) possible. And maybe even actual implementations with
real-life experience to learn from?

>>> I really don't care about the OOM Killer corner cases - it's
>>> completely the wrong way line of development to be spending time on
>>> and you aren't going to convince me otherwise. The OOM killer a
>>> crutch used to justify having a memory allocation subsystem that
>>> can't provide forward progress guarantee mechanisms to callers that
>>> need it.
>>
>> We can provide this.  Are all these callers able to preallocate?
> 
> Anything that allocates in transaction context (and therefor is
> GFP_NOFS by definition) can preallocate at transaction reservation
> time. However, preallocation is dumb, complex, CPU and memory
> intensive and will have a *massive* impact on performance.
> Allocating 10-100 pages to a reserve which we will almost *never
> use* and then free them again *on every single transaction* is a lot
> of unnecessary additional fast path overhead.  Hence a "preallocate
> for every context" reserve pool is not a viable solution.

But won't even the reservation have potentially large impact on performance, if
as you later suggest (IIUC), we don't actually dip into our reserves until
regular reclaim starts failing? Doesn't that mean potentially lot of wasted
memory? Right, it doesn't have to be if we allow clean reclaimable pages to be
part of reserve, but still...

> And, really, "reservation" != "preallocation".
> 
> Maybe it's my filesystem background, but those to things are vastly
> different things.
> 
> Reservations are simply an *accounting* of the maximum amount of a
> reserve required by an operation to guarantee forwards progress. In
> filesystems, we do this for log space (transactions) and some do it
> for filesystem space (e.g. delayed allocation needs correct ENOSPC
> detection so we don't overcommit disk space).  The VM already has
> such concepts (e.g. watermarks and things like min_free_kbytes) that
> it uses to ensure that there are sufficient reserves for certain
> types of allocations to succeed.
> 
> A reserve memory pool is no different - every time a memory reserve
> occurs, a watermark is lifted to accommodate it, and the transaction
> is not allowed to proceed until the amount of free memory exceeds
> that watermark. The memory allocation subsystem then only allows
> *allocations* marked correctly to allocate pages from that the
> reserve that watermark protects. e.g. only allocations using
> __GFP_RESERVE are allowed to dip into the reserve pool.
> 
> By using watermarks, freeing of memory will automatically top
> up the reserve pool which means that we guarantee that reclaimable
> memory allocated for demand paging during transacitons doesn't
> deplete the reserve pool permanently.  As a result, when there is
> plenty of free and/or reclaimable memory, the reserve pool
> watermarks will have almost zero impact on performance and
> behaviour.
> 
> Further, because it's just accounting and behavioural thresholds,
> this allows the mm subsystem to control how the reserve pool is
> accounted internally. e.g. clean, reclaimable pages in the page
> cache could serve as reserve pool pages as they can be immediately
> reclaimed for allocation. This could be acheived by setting reclaim
> targets first to the reserve pool watermark, then the second target
> is enough pages to satisfy the current allocation.

Hmm but what if the clean pages need us to take some locks to unmap and some
proces holding them is blocked... Also we would need to potentally block a
process that wants to dirty a page, is that being done now?

> And, FWIW, there's nothing stopping this mechanism from have order
> based reserve thresholds. e.g. IB could really do with a 64k reserve
> pool threshold and hence help solve the long standing problems they
> have with filling the receive ring in GFP_ATOMIC context...

I don't know the details here, but if the allocation is done for incoming
packets i.e. something you can't predict then how would you set the reserve for
that? If they could predict, they would be able to preallocate necessary buffers
already.

> Sure, that's looking further down the track, but my point still
> remains: we need a viable long term solution to this problem. Maybe
> reservations are not the solution, but I don't see anyone else who
> is thinking of how to address this architectural problem at a system
> level right now.  We need to design and document the model first,
> then review it, then we can start working at the code level to
> implement the solution we've designed.

Right. A conference to discuss this on could come handy :)

> Cheers,
> 
> Dave.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
