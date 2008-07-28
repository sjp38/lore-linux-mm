Date: Mon, 28 Jul 2008 10:10:19 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: unify pmd_free() implementation
In-Reply-To: <1217264339.3503.97.camel@localhost.localdomain>
Message-ID: <alpine.LFD.1.10.0807281000070.3486@nehalem.linux-foundation.org>
References: <> <1217260287-13115-1-git-send-email-righi.andrea@gmail.com>  <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org>  <1217261852.3503.89.camel@localhost.localdomain>  <alpine.LFD.1.10.0807280937150.3486@nehalem.linux-foundation.org>
 <1217264339.3503.97.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrea Righi <righi.andrea@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 28 Jul 2008, James Bottomley wrote:
> 
> Sorry ... should have been clearer.  My main concern is the cost of
> barrier() which is just a memory clobber ... we have to use barriers to
> place the probe points correctly in the code.

Oh, "barrier()" itself has _much_ less cost.

It still has all the "needs to flush any global/address-taken-of variables 
to memory" property and can thus cause reloads, but that's kind of the 
point of it, after all. So in that sense "barrier()" is free: the only 
cost of a barrier is the cost of what you actually need to get done. It's 
not really "free", but it's also not any more costly than what your 
objective was.

In contrast, the "objective" in an empty function call is seldom the 
serialization, so in that case the serialization is all just unnecessary 
overhead.

Also, barrier() avoids the big hit of turning a leaf function into a 
non-leaf one. It also avoids all the fixed registers and the register 
clobbers (although for tracing purposes you may end up setting up fixed 
regs, of course).

The leaf -> non-leaf thing is actually often the major thing. Yes, the 
compiler will often inline functions that are simple enough to be leaf 
functions with no stack frame, so we don't have _that_ many of them, but 
when it hits, it's often the most noticeable part of an unnecessary 
function call. And "barrier()" should never trigger that problem.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
