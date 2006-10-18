Message-ID: <45362130.6020804@yahoo.com.au>
Date: Wed, 18 Oct 2006 22:42:24 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Remove temp_priority
References: <45351423.70804@google.com> <4535160E.2010908@yahoo.com.au> <45351877.9030107@google.com>
In-Reply-To: <45351877.9030107@google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Martin Bligh wrote:
> Nick Piggin wrote:

>> For that matter (going off the topic a bit), I wonder if
>> try_to_free_pages should have a watermark check there too? This
>> might help reduce the latency issue you brought up where one process
>> has reclaimed a lot of pages, but another isn't making any progress
>> and has to go through the full priority range? Maybe that's
>> statistically pretty unlikely?
> 
> 
> I've been mulling over how to kill prev_priority (and make everyone
> happy, including akpm). My original thought was to keep a different
> min_priority for each of GFP_IO, GFP_IO|GFP_FS, and the no IO ones.
> But we still have the problem of how to accurately set the min back
> up when we are sucessful.
> 
> Perhaps we should be a little more radical, and treat everyone apart
> from kswapd as independant. Keep a kswapd_priority in the zone
> structure, and all the direct reclaimers have their own local priority.
> Then we set distress from min(kswap_priority, priority). All that does
> is kick the direct reclaimers up a bit faster - kswapd has the easiest
> time reclaiming pages, so that should never be too low.

I think that could *work*, but I still think it is a heuristics change
rather than a bug fix.

Do we want everyone to make some progress, even if that means having
some do some swapping and others not; or have the zone pressure (and
tendancy to swap) depend on how well progress is going, globally?

The latter is what we have now, and I don't think it is terrible (not
saying your idea can't work better, but it would need careful
consideration).

Coming from another angle, I am thinking about doing away with direct
reclaim completely. That means we don't need any GFP_IO or GFP_FS, and
solves the problem of large numbers of processes stuck in reclaim and
skewing aging and depleting the memory reserve.

But that's tricky because we don't have enough kswapds to get maximum
reclaim throughput on many configurations (only single core opterons
and UP systems, really).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
