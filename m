Message-ID: <45364092.3030206@yahoo.com.au>
Date: Thu, 19 Oct 2006 00:56:18 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Remove temp_priority
References: <45351423.70804@google.com> <4535160E.2010908@yahoo.com.au> <45351877.9030107@google.com> <45362130.6020804@yahoo.com.au> <45363E66.8010201@google.com>
In-Reply-To: <45363E66.8010201@google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@google.com>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
>> Coming from another angle, I am thinking about doing away with direct
>> reclaim completely. That means we don't need any GFP_IO or GFP_FS, and
>> solves the problem of large numbers of processes stuck in reclaim and
>> skewing aging and depleting the memory reserve.
> 
> 
> Last time I proposed that, the objection was how to throttle the heavy
> dirtiers so they don't fill up RAM with dirty pages?

Now that we have the dirty mmap accounting, page dirtiers should be
throttled pretty well via page writeback throttling.

> Also, how do you do atomic allocations? Create a huge memory pool and
> pray really hard?

Well, yes. Atomic allocations as of *today* cannot do any reclaim, and
thus they rely on kswapd to free their memory, and we keep a (not huge)
memory pool for them. They also have to be able to handle failures, and
by and large they do OK.

>> But that's tricky because we don't have enough kswapds to get maximum
>> reclaim throughput on many configurations (only single core opterons
>> and UP systems, really).
> 
> 
> It's not a question of enough kswapds. It's that we can dirty pages
> faster than they can possibly be written to disk.
> 
> dd if=/dev/zero of=/tmp/foo

You can't catch that at the allocation side anyway because clean pagecache
may already exist for /tmp/foo.

We've always done pretty well (in 2.6) with correctly throttling and
limiting write(2) writes into pagecache, haven't we?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
