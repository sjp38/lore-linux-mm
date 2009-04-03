Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CB8BE6B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 20:50:22 -0400 (EDT)
Message-ID: <49D55D69.5030605@goop.org>
Date: Thu, 02 Apr 2009 17:50:49 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [patch 0/6] Guest page hinting version 7.
References: <20090327150905.819861420@de.ibm.com>	<20090402175249.3c4a6d59@skybase> <49D50CB7.2050705@redhat.com>	<200904030622.30935.nickpiggin@yahoo.com.au> <49D51A82.8090908@redhat.com>
In-Reply-To: <49D51A82.8090908@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, frankeh@watson.ibm.com, virtualization@lists.osdl.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> I guess we could try to figure out a simple and robust policy
> for ballooning.  If we can come up with a policy which nobody
> can shoot holes in by just discussing it, it may be worth
> implementing and benchmarking.
>
> Maybe something based on the host passing memory pressure
> on to the guests, and the guests having their own memory
> pressure push back to the host.
>
> I'l start by telling you the best auto-ballooning policy idea
> I have come up with so far, and the (major?) hole in it.
>   

I think the first step is to reasonably precisely describe what the 
outcome you're trying to get to.  Once you have that you can start 
talking about policies and mechanisms to achieve it.  I suspect we all 
have basically the same thing in mind, but there's no harm in being 
explicit.

I'm assuming that:

   1. Each domain has a minimum guaranteed amount of resident memory.  
      If you want to shrink a domain to smaller than that minimum, you
      may as well take all its memory away (ie suspend to disk,
      completely swap out, migrate elsewhere, etc).  The amount is at
      least the bare-minimum WSS for the domain, but it may be higher to
      achieve other guarantees.
   2. Each domain has a maximum allowable resident memory, which could
      be unbounded.  The sums of all maximums could well exceed the
      total amount of host memory, and that represents the overcommit case.
   3. Each domain has a weight, or memory priority.  The simple case is
      that they all have the same weight, but a useful implementation
      would probably allow more.
   4. Domains can be cooperative, unhelpful (ignore all requests and
      make none) or malicious (ignore requests, always try to claim more
      memory).  An incompetent cooperative domain could be effectively
      unhelpful or malicious.
          * hard max limits will prevent non-cooperative domains from
            causing too much damage
          * they could be limited in other ways, by lowering IO or CPU
            priorities
          * a domain's "goodness" could be measured by looking to see
            how much memory is actually using relative to its min size
            and its weight
          * other remedies are essentially non-technical, such as more
            expensive billing the more non-good a domain is
          * (its hard to force a Xen domain to give up memory you've
            already given it)

Given that, what outcome do we want?  What are we optimising for?

    * Overall throughput?
    * Fairness?
    * Minimise wastage?
    * Rapid response to changes in conditions?  (Cope with domains
      swinging between 64MB and 3GB on a regular basis?)
    * Punish wrong-doers / Reward cooperative domains?
    * ...?

Trying to make one thing work for all cases isn't going to be simple or 
robust.  If we pick one or two (minimise wastage+overall throughput?) 
then it might be more tractable.

> Basically, the host needs the memory pressure notification,
> where the VM will notify the guests when memory is running
> low (and something could soon be swapped).  At that point,
> each guest which receives the signal will try to free some
> memory and return it to the host.
>
> Each guest can have the reverse in its own pageout code.
> Once memory pressure grows to a certain point (eg. when
> the guest is about to swap something out), it could reclaim
> a few pages from the host.
>
> If all the guests behave themselves, this could work.
>   

Yes.  It seems to me the basic metric is that each domain needs to keep 
track of how much easily allocatable memory it has on hand (ie, pages it 
can drop without causing a significant increase in IO).  If it gets too 
large, then it can afford to give pages back to the host.  If it gets 
too small, it must ask for more memory (preferably early enough to 
prevent a real memory crunch).

> However, even with just reasonably behaving guests,
> differences between the VMs in each guest could lead
> to unbalanced reclaiming, penalizing better behaving
> guests.
>   

Well, it depends on what you mean by penalized.  If they can function 
properly with the amount of memory they have, then they're fine.  If 
they're struggling because they don't have enough memory for their WSS, 
then they got their "do I have enough memory on hand" calculation wrong.

> If one guest is behaving badly, it could really impact
> the other guests.
>
> Can you think of improvements to this idea?
>
> Can you think of another balloon policy that does
> not have nasty corner cases?
>   

In fully cooperative environments you can rely on ballooning to move 
things around dramatically.  But with only partially cooperative guests, 
the best you can hope for is that it allows you some provisioning 
flexibility so you can deal with fluctuating demands in guests, but not 
order-of-magnitude size changes.  You just have to leave enough headroom 
to make the corner cases not too pointy.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
