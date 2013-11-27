Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id E19E86B0031
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 19:48:01 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so4563803yhz.8
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 16:48:01 -0800 (PST)
Received: from mail-yh0-x232.google.com (mail-yh0-x232.google.com [2607:f8b0:4002:c01::232])
        by mx.google.com with ESMTPS id s46si25775098yhd.270.2013.11.26.16.48.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 16:48:00 -0800 (PST)
Received: by mail-yh0-f50.google.com with SMTP id b6so4521344yha.23
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 16:48:00 -0800 (PST)
Date: Tue, 26 Nov 2013 16:47:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, vmscan: abort futile reclaim if we've been oom
 killed
In-Reply-To: <20131121164019.GK3556@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311261634040.21003@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311121801200.18803@chino.kir.corp.google.com> <20131113152412.GH707@cmpxchg.org> <alpine.DEB.2.02.1311131400300.23211@chino.kir.corp.google.com> <20131114000043.GK707@cmpxchg.org> <alpine.DEB.2.02.1311131639010.6735@chino.kir.corp.google.com>
 <20131118164107.GC3556@cmpxchg.org> <alpine.DEB.2.02.1311181712080.4292@chino.kir.corp.google.com> <20131120160712.GF3556@cmpxchg.org> <alpine.DEB.2.02.1311201803000.30862@chino.kir.corp.google.com> <20131121164019.GK3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 21 Nov 2013, Johannes Weiner wrote:

> All I'm trying to do is find the broader root cause for the problem
> you are experiencing and find a solution that will leave us with
> maintainable code.  It does not matter how few instructions your fix
> adds, it changes the outcome of the algorithm and makes every
> developer trying to grasp the complexity of page reclaim think about
> yet another special condition.
> 
> The more specific the code is, the harder it will be to understand in
> the future.  Yes, it's a one-liner, but we've had death by a thousand
> cuts before, many times.  A few cycles ago, kswapd was blowing up left
> and right simply because it was trying to meet too many specific
> objectives from facilitating order-0 allocators, maintaining zone
> health, enabling compaction for higher order allocation, writing back
> dirty pages.  Ultimately, it just got stuck in endless loops because
> of conflicting conditionals.  We've had similar problems in the scan
> count calculation etc where all the checks and special cases left us
> with code that was impossible to reason about.  There really is a
> history of "low overhead one-liner fixes" eating us alive in the VM.
> 

Your objection is that the added code is obscure and will require kernel 
hackers to think about why it's there?  I could certainly add a comment:

	/*
	 * The oom killer only kills processes when reclaim has already
	 * failed for its allocation context, continuously trying won't
	 * help.
	 */

to the patch? 

> The solution was always to take a step back and integrate all
> requirements properly.  Not only did this fix the problems, the code
> ended up being much more robust and easier to understand and modify as
> well.
> 
> If shortening the direct reclaim cycle is an adequate solution to your
> problem, it would be much preferable.  Because
> 
>   "checking at a reasonable interval if the work I'm doing is still
>    necessary"
> 
> is a much more approachable, generic, and intuitive concept than
> 
>   "the OOM killer has gone off, direct reclaim is futile, I should
>    exit quickly to release memory so that not more tasks get caught
>    doing direct reclaim".
> 
> and the fix would benefit a much wider audience.
> 

I agree with your point that obscure random fixes does obfuscate the VM in 
many different ways and I'd like to support you in anyway that I can to 
make sure that my fix doesn't do that for anybody in the future, the 
comment being added may be one way of doing that.

I disagree with changing the "reasonable interval" to determine if reclaim 
is still necessary because many parallel reclaimers will indicate a higher 
demand for free memory and it prevents short-circuiting direct reclaim, 
returning to the page allocator, and finding that the memory you've 
reclaimed has been stolen by another allocator.

That race to allocate the reclaimed memory will always exist if checking 
zone watermarks from direct reclaim to determine whether we should 
terminate or not as part of your suggested, the alternative would be to 
actually do get_page_from_freelist() and actually allocate on every 
iteration.  For the vast majority of reclaimers, I think this would 
terminate prematurely when we haven't hit the SWAP_CLUSTER_MAX threshold 
and since the removal of lumpy reclaim and the reliance on synchronous 
memory compaction following one of these oom events to defragment memory, 
I would be tenative to implement such a solution.

> Lastly, as far as I know, you are the only reporter that noticed an
> issue with this loooooong-standing behavior, and you don't even run
> upstream kernels.  There really is no excuse to put up with a quick &
> dirty fix.
> 

I certainly do run upstream kernels and I would agree that I may be one of 
the only reporters of such an issue because Google probably hits more out 
of memory conditions to enforce memory isolation than anybody else and 
stalls like this are more noticible.

I would certainly add the comment if you feel it's necessary, though, just 
let me know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
