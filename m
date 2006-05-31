Message-ID: <447DA010.1070005@yahoo.com.au>
Date: Wed, 31 May 2006 23:54:24 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org> <447BD31E.7000503@yahoo.com.au> <447BD63D.2080900@yahoo.com.au> <Pine.LNX.4.64.0605301041200.5623@g5.osdl.org> <447CE43A.6030700@yahoo.com.au> <Pine.LNX.4.64.0605301739030.24646@g5.osdl.org> <447D9A41.8040601@yahoo.com.au> <20060531134125.GQ29535@suse.de>
In-Reply-To: <20060531134125.GQ29535@suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Jens Axboe wrote:
> On Wed, May 31 2006, Nick Piggin wrote:
> 
>>Now having a mechanism for a task to batch up requests might be a
>>good idea. Eg.
>>
>>plug();
>>submit reads
>>unplug();
>>wait for page
> 
> 
> How's this different from what we have now? The plugging will happen
> implicitly, if we need to. If the queue is already running, chances are
> that there are requests there so you won't get to your first read first
> anyways.
> 
> The unplug(); wait_for_page(); is already required unless you want to
> wait for the plugging to time out (unlikely, since you are now waiting
> for io completion on one of them).
> 
> 
>>I'd think this would give us the benefits of corse grained (per-queue)
>>plugging and more (e.g. it works when the request queue isn't empty).
>>And it would be simpler because the unplug point is explicit and doesn't
>>need to be kicked by lock_page or wait_on_page
> 
> 
> I kind of like having the implicit unplug, for several reasons. One is
> that people forget to unplug. We had all sorts of hangs there in 2.4 and
> earlier because of that. Making the plugging implicit should help that
> though. The other is that I don't see what the explicit unplug gains
> you. Once you start waiting for one of the pages submitted, that is
> exactly the point where you want to unplug in the first place.

OK I wasn't aware it was explicit in 2.4 and earlier.

Two upsides I see to explicit: firstly, it works on non-empty queues. Less
of a problem perhaps, but only because it is statistically less likely to
be the next submitted, so there will still be some improvement.

Second, for async work (aio, readahead, writeback, writeout for page reclaim),
the point where you wait is probably not the best place to unplug.

Also, it would allow lock_page to be untangled.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
