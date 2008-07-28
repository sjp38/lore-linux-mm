Subject: Re: [PATCH 1/1] mm: unify pmd_free() implementation
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.LFD.1.10.0807280937150.3486@nehalem.linux-foundation.org>
References: <> <1217260287-13115-1-git-send-email-righi.andrea@gmail.com>
	 <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org>
	 <1217261852.3503.89.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0807280937150.3486@nehalem.linux-foundation.org>
Content-Type: text/plain
Date: Mon, 28 Jul 2008 11:58:58 -0500
Message-Id: <1217264339.3503.97.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Righi <righi.andrea@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-28 at 09:45 -0700, Linus Torvalds wrote:
> 
> On Mon, 28 Jul 2008, James Bottomley wrote:
> > 
> > Are you sure about this (the barrier)?
> 
> I'm sure. Try it. It perturbs the code quite a bit to have a function call 
> in the thing, because it
> 
>  - clobbers all callee-clobbered registers.
> 
>    This means that all functions that _used_ to be leaf functions and 
>    needed no stack frame at all (because they were simple enough to use 
>    only the callee-clobbered registers) are suddenly now going to be 
>    significantly more costly.
> 
>    Ergo: you get more stack movement with save/restore crud.
> 
>  - it is a barrier wrt any variables that may be visible externally 
>    (perhaps because they had their address taken), so it forces a flush to 
>    memory for those.
> 
>  - if it has arguments and return values, it also ends up forcing a 
>    totally unnecessary argument setup (and all the fixed register crap 
>    that involves, which means that you lost almost all your register 
>    allocation freedom - not that you likely care, since most of your 
>    registers are dead _anyway_ around the function call)
> 
> So empty functions calls are _deadly_ especially if the code was a leaf 
> function before, and suddenly isn't any more.
> 
> On the other hand, there are also many cases where function calls won't 
> matter much at all. If you had other function calls around that same area, 
> all the above issues essentially go away, since your registers are dead 
> anyway, and the function obviously wasn't a leaf function before the new 
> call.
> 
> So it does depend quite a bit on the pattern of use. And yes, function 
> argument setup can be a big part of it too.

Sorry ... should have been clearer.  My main concern is the cost of
barrier() which is just a memory clobber ... we have to use barriers to
place the probe points correctly in the code.

We already get that spilling function clobbered registers to stack (or
elsewhere) and yanking values out of the optimisation stream for the
arguments is pretty costly ... although the current LTT tracepoint code
argues that this cost can be borne.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
