Message-ID: <41E7A58C.5010805@yahoo.com.au>
Date: Fri, 14 Jan 2005 21:57:16 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page table lock patch V15 [0/7]: overview II
References: <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com> <41E5BC60.3090309@yahoo.com.au> <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com> <20050113031807.GA97340@muc.de> <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com> <20050113180205.GA17600@muc.de> <Pine.LNX.4.58.0501131701150.21743@schroedinger.engr.sgi.com> <20050114043944.GB41559@muc.de> <m14qhkr4sd.fsf_-_@muc.de> <1105678742.5402.109.camel@npiggin-nld.site> <20050114104732.GB72915@muc.de>
In-Reply-To: <20050114104732.GB72915@muc.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: clameter@sgi.com, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>>I have a question for the x86 gurus. We're currently using the lock
>>prefix for set_64bit. This will lock the bus for the RMW cycle, but
>>is it a prerequisite for the atomic 64-bit store? Even on UP?
> 
> 
> An atomic 64bit store doesn't need a lock prefix. A cmpxchg will
> need to though.

Are you sure the cmpxchg8b need a lock prefix? Sure it does to
get the proper "atomic cmpxchg" semantics, but what about a
simple 64-bit store... If it boils down to 8 byte load, 8 byte
store on the memory bus, and that store is atomic, then maybe
a lock isn't needed at all?

I think when emulating a *load*, then the lock is needed, because
otherwise the subsequent store may overwrite some value that has
just been stored by another processor.... but for a store I'm not
so sure.

> Note that UP kernels define LOCK to nothing.
> 

Yes. In this case (include/asm-i386/system.h:__set_64bit), it
is using lowercase lock, which I think is not defined away,
right?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
