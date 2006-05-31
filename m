Message-ID: <447D9A41.8040601@yahoo.com.au>
Date: Wed, 31 May 2006 23:29:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org> <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org> <447BD31E.7000503@yahoo.com.au> <447BD63D.2080900@yahoo.com.au> <Pine.LNX.4.64.0605301041200.5623@g5.osdl.org> <447CE43A.6030700@yahoo.com.au> <Pine.LNX.4.64.0605301739030.24646@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605301739030.24646@g5.osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Wed, 31 May 2006, Nick Piggin wrote:
> 
>>The requests can only get merged if contiguous requests from the upper
>>layers come down, right?
> 
> 
> It has nothing to do with merging. It has to do with IO patterns.
> 
> Seeking.
> 
> Seeking is damn expensive - much more so than command issue. People forget 
> that sometimes.

OK, I didn't forget that it is expensive, but I didn't make the
connection that this is what you were arguing for.

I would be surprised if plugging made a big difference to seeking:
1. the queue will be plugged only if there are no other requests (so,
    nothing else to seek to).
2. if the queue was plugged and we submitted one small request,
    another request to somewhere else on the drive that comes in can
    itself unplug the queue and cause seeking.

as-iosched is good at cutting down seeks because it doesn't "unplug"
in situation #2.

Now having a mechanism for a task to batch up requests might be a
good idea. Eg.

plug();
submit reads
unplug();
wait for page

I'd think this would give us the benefits of corse grained (per-queue)
plugging and more (e.g. it works when the request queue isn't empty).
And it would be simpler because the unplug point is explicit and doesn't
need to be kicked by lock_page or wait_on_page

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
