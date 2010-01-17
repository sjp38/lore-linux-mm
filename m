Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 53A766B0047
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 13:58:19 -0500 (EST)
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was:
 Re: [linux-pm] Memory allocations in .suspend became very unreliable)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <201001171427.27954.rjw@sisk.pl>
References: <1263549544.3112.10.camel@maxim-laptop>
	 <201001170138.37283.rjw@sisk.pl> <201001170224.36267.oliver@neukum.org>
	 <201001171427.27954.rjw@sisk.pl>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 18 Jan 2010 05:58:04 +1100
Message-ID: <1263754684.724.444.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Oliver Neukum <oliver@neukum.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-01-17 at 14:27 +0100, Rafael J. Wysocki wrote:

> Yes it will, but why exactly shouldn't it?  System suspend/resume _is_ a
> special situation anyway.

To some extent this is similar to the boot time allocation problem for
which it was decided to bury the logic in the allocator as well.
 
> Memory allocations are made for other purposes during suspend/resume too.  For
> example, new kernel threads may be created (for async suspend/resume among
> other things).

Right. Well, I would add in fact that this isn't even the main issue I
see. If it was just a matter of changing a kmalloc() call in a driver
suspend() routine, I would agree with Oliver.

However, there are two categories of allocations that make this
extremely difficult:

 - One is implicit allocations. IE. suspend() is a normal task context,
it's expected that any function can be called that might itself call a
function etc... that does an allocation. There is simply no way all of
these code path can be identified and the allocation "flags" pushed up
all the way to the API in every case.

 - There's a more subtle issue at play here. The moment the core starts
calling driver's suspend() routines, all allocations can potentially
hang since a device with dirty pages might have been suspended and the
VM can stall trying to swap out to it. (I don't think Rafael proposed
patch handles this in a race free way btw, but that's hard, especially
for allocations already blocked waiting for a write back ...). That
means that a driver that has -not- been suspended yet (and thus doesn't
necessarily know the suspend process has been started) might be blocked
in an allocation somewhere, holding a mutex or similar, which will then
cause a deadlock when that same driver's suspend() routine is called
which tries to take the same mutex.

Overall, it's a can of worms. The only way out I can see that is
reasonably sane and doesn't impose API changes thorough the kernel and
unreasonable expectations from driver writers is to deal with it at the
allocator level.

However, it's hard to deal with the case of allocations that have
already started waiting for IOs. It might be possible to have some VM
hook to make them wakeup, re-evaluate the situation and get out of that
code path but in any case it would be tricky.

So Rafael's proposed patch is a first step toward fixing that problem
but isn't, I believe, enough.

> Besides, the fact that you tell people to do something doesn't necessary imply
> that they will listen. :-)
> 
> I have discussed that with Ben for a couple of times and we have generally
> agreed that memory allocation problems during suspend/resume are not avoidable
> in general unless we disable __GFP_FS and __GFP_IO at the high level.
> 

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
