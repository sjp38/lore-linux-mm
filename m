Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EAAF36B0055
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 07:09:44 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090612100756.GA25185@elte.hu>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
	 <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
	 <20090612100756.GA25185@elte.hu>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 21:09:40 +1000
Message-Id: <1244804980.7172.124.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 12:07 +0200, Ingo Molnar wrote:
> 
> IMHO such invisible side-channels modifying the semantics of GFP 
> flags is a bit dubious.
> 
> We could do GFP_INIT or GFP_BOOT. These can imply other useful 
> modifiers as well: panic-on-failure for example. (this would clean 
> up a fair amount of init code that currently checks for an panics on 
> allocation failure.)

I disagree.

I believe most code shouldn't have to care whether it's in boot, suspend
or similar to get the right flags to kmalloc().

This is especially true for when the allocator is called indirectly by
something that can itself be called from either boot or non-boot.

I believe the best example here is __get_vm_area() will use GFP_KERNEL.
I don't think it should be "fixed" to do anything else. The normal case
of GFP_KERNEL is correct and it shouldn't be changed to do GFP_NOWAIT
just because it happens that we use it earlier during init time.

This is also true of a lot of code used on "hotplug" path that is
commonly used at init time but can be used later on.

To some extent, the subtle distinction of whether interrupts are enabled
or not is something that shouldn't be something those callers have to
bother with. Yes, it is obvious for some strictly init code, but it's
far from being always that simple, and it's not unlikely that we'll
decide to move around in the init sequence the point at which we decide
to enable interrupts. We shouldn't have to fix half of the init code
when we do that.

In fact, we could push the logic further (but please read it all before
reacting :-) The fact that we -do- specific GFP_ATOMIC for atomic
context is -almost- a side effect of history. To some extent we could
get rid of it since we can almost always know when we are in such a
context. In that case, though, I believe we should keep it that way, at
least because it does discourage people from allocating in those
contexts which is a good thing.

Back to the general idea, I think we shouldn't burden arch, driver,
subsystem etc... code with the need to understand the system state, in
our present case, init vs. non init, but the same issue applies with
suspend/resume vs. GFP_NOIO as I explained in a separate email.

This typically a case where I believe the best way to ensure we do the
right thing is to put the check in the few common code path where
everybody funnels through, which is the allocator itself.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
