Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 321C76B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 07:13:44 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090612101511.GC13607@wotan.suse.de>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
	 <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
	 <20090612100756.GA25185@elte.hu>
	 <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
	 <20090612101511.GC13607@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 21:13:50 +1000
Message-Id: <1244805230.7172.130.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>


> I agree with Ingo though that exposing it as a gfp modifier is
> not so good. I just like the implementation to mask off GFP_WAIT
> better, and also prefer not to test system state, but have someone
> just call into slab to tell it not to unconditionally enable
> interrupts.

But interrupts is just one example. GFP_NOIO is another one vs. suspend
and resume.

What we have here is the allocator needs to be clamped down based on the
system state. I think it will not work to try to butcher every caller,
especially since they don't always know themselves in what state they
are called.

Moving the "fix" into the couple of nexuses where all the code path go
through really seem like a better, simpler, more maintainable and more
fool proof solution to me.

> Yes, with sufficient warnings in place, I don't think it should be
> too error prone to clean up remaining code over the course of
> a few releases.

But that will no fix all the cases. That will not fix __get_vm_area()
being called from both boot and non-boot (and ioremap, etc..) and every
similar thing we can have all over the place (I have some in the
interrupt handling on powerpc, I'm sure we can find much more).

I don't see what the problem is in providing simple allocator semantics
and have the allocator itself adapt to the system state, especially when
the code is as small as having a bit mask applied in 2 or 3 places.

Cheers,
Ben.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
