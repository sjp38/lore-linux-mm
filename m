Message-ID: <447DAEDE.5070305@yahoo.com.au>
Date: Thu, 01 Jun 2006 00:57:34 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org> <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org> <447BD31E.7000503@yahoo.com.au> <447BD63D.2080900@yahoo.com.au> <Pine.LNX.4.64.0605301041200.5623@g5.osdl.org> <447CE43A.6030700@yahoo.com.au> <Pine.LNX.4.64.0605301739030.24646@g5.osdl.org> <447D9A41.8040601@yahoo.com.au> <Pine.LNX.4.64.0605310740530.24646@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605310740530.24646@g5.osdl.org>
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
>>Now having a mechanism for a task to batch up requests might be a
>>good idea. Eg.
>>
>>plug();
>>submit reads
>>unplug();
>>wait for page
> 
> 
> What do you think we're _talking_ about?

Plugging. Emphasis on task.

> 
> What do you think my example of sys_readahead() was all about?
> 
> WE DO HAVE EXACTLY THAT MECHANISM. IT'S CALLED PLUGGING!

It isn't exactly that. I'm thinking per-task rather than per-queue might
be a better idea because a) you don't know what else is putting requests
on the queue, and b) the point where you wait is not always the best place
to unplug.

> 
> 
>>I'd think this would give us the benefits of corse grained (per-queue) 
>>plugging and more (e.g. it works when the request queue isn't empty). 
>>And it would be simpler because the unplug point is explicit and doesn't 
>>need to be kicked by lock_page or wait_on_page
> 
> 
> What do you think plugging IS?
> 
> It's _exactly_ what you're talking about.

Yes, and I'm talking about per-task vs per-queue plugging (because I want
to get rid of the implicit unplug, because I want to make lock_page & co
nicer).

> And yes, we used to have 
> explicit unplugging (a long long long time ago), and IT SUCKED. People 
> would forget, but even more importantly, people would do it even when not 

I don't see what the problem is. Locks also suck if you forget to unlock
them.

> needed because they didn't have a good place to do it because the waiter 
> was in a totally different path.

Example?

> 
> The reason it's kicked by wait_on_page() is that is when it's needed.

Yes, you already said that, and I showed cases where that isn't optimal.

I don't know why you think this way of doing plugging is fundamentally
right and anything else must be wrong... it is always heuristic, isn't
it?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
