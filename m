Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B22ED6B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 11:50:50 -0400 (EDT)
Date: Thu, 4 Jun 2009 16:50:24 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: swapoff throttling and speedup?
In-Reply-To: <4A26AC73.6040804@gmail.com>
Message-ID: <Pine.LNX.4.64.0906041600540.18591@sister.anvils>
References: <4A26AC73.6040804@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Joel Krauska <jkrauska@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009, Joel Krauska wrote:

> On occasion we need to unswap a system that's gotten unruly.
> 
> Scenario: Some leaky app eats up way more RAM than it should, and pushes
> a few gigs of the running system in to swap.  The leaky app is killed, but
> there's still lots of good stuff sitting in swap that we need to tidy
> up to get the system back to normal performance levels.
> 
> 
> The normal recourse is to run
> swapoff -a ; swapon -a
> 
> 
> I have two related questions about the swap tools and how they work.
> 
> 
> 1. Has anyone tried making a nicer swapoff?
> Right now swapoff can be pretty aggressive if the system is otherwise
> heavily loaded.  On systems that I need to leave running other jobs,
> swapoff compounds the slowness of the system overall by burning up
> a single CPU and lots of IO
> 
> I wrote a perl wrapper that briefly runs swapoff and then kills it, but it
> would seem more reasonable to have a knob
> to make swapoff less aggressive. (max kb/s, etc)  

Though what you're doing is inelegant, it does seem a good solution to me:
why add fancy kernel tunables, for what is (I think) a rare use case?

> It looked to me like the swapoff code was immediately hitting kernel internals
> instead of doing more lifting itself (and making it obvious where I could
> insert some sleeps)

Yes, all the hard work is in the one swapoff(2) system call.
You could add an option to swapoff(8), to alarm and sleep and retry;
but why bother when you've already got your perl script?

> 
> Has anyone found better options here?

Could the answer be in your question: "a nicer swapoff?"
Does running "nice swapoff -a" behave more as you want?
Won't help on the IO side, I suppose.

> 
> 2. A faster(multithreaded?) swapoff?
> From what I can tell, swapoff is single threaded, which seems to make
> unswapping a CPU bound activity.  
> In the opposite use case of my first question, on systems that I /can/
> halt all the running code (assuming if they've gone off the deep end and have
> several gigs in SWAP) it can take quite a long time for unswap to tidy up the
> mess.  
> Has anyone considered improvements to swapoff to speed it up?
> (multiple threads?)

Until there's some unforeseen revolution in swap usage, swapoff will
always be nasty.

It's hugely inefficient, but you're one of the very few people to be
hurt by that: for most people, it's something that only gets run at
shutdown time, when there's very little work left for it to do, and
nothing left to mind anyway.

Certainly there are ways in which swapoff could be made much nicer;
but at the cost of maintaining additional pointers which use more
memory and slow down codepaths critical to performance, when most
critical processes will never go to swap in the first place.

So, in view of the tradeoffs, swapoff has remained a nasty backwater:
it goes about its business in that hugely inefficient way, to save
the rest of mm from having to support it throughout normal usage.

Multiple threads?  Hmm, never pondered on that.  It would certainly
make your first case worse, occupying all CPUs instead of just one.

If you can muster a chorus of other users upset by swapoff's
behaviour, then it would be fun to improve it somewhat; but I'd
much rather cut down its CPU usage, than spread the same across CPUs.

I've often thought that the 16 bits of the swap_map are poorly used
(rarely can more than 2 be set): we could make better use of them
with a hash to reduce the amount of blind scanning by an order or
two of magnitude.  But that's always seemed more a bloat of kernel
text than a good use of a developer's time.

And it's a very long time since I tried swapin_readahead() instead
of the read_swap_cache_async() in try_to_unuse(): more likely to
help with your first use case (when you've competing IO) than your
second (when the disk is likely to be caching the readahead anyway).

> 
> I'm hoping others have been down this road before.
> 
> As a rule, we try to avoid swapping when possible, but using:
> vm.swappiness = 1
> 
> But it does still happen on occasion and that lead to this mail.

Thanks for taking the trouble to write: opinions, anyone?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
