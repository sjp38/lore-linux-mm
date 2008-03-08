Date: Sat, 8 Mar 2008 01:46:54 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/13] General DMA zone rework
Message-ID: <20080308004654.GQ7365@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <20080307175148.3a49d8d3@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080307175148.3a49d8d3@mandriva.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 07, 2008 at 05:51:48PM -0300, Luiz Fernando N. Capitulino wrote:
> Em Fri,  7 Mar 2008 10:07:10 +0100 (CET)
> Andi Kleen <andi@firstfloor.org> escreveu:
> 
> | I chose to implement a new "maskable memory" allocator to solve these
> | problems. The existing page buddy allocator is not really suited for
> | this because the data structures don't allow cheap allocation by physical 
> | address boundary. 
> 
>  These patches are supposed to work, I think?

Yes they work fine here and survived quite some stress testing.
But of course I only have limited configurations.

> 
>  I've tried to give them a try but got some problems. First, the
> simple test case seems to fail miserably:

Hmm I guess you got a pretty filled up 16MB area already.
Do you have a full log? It just couldn't allocate some memory
for the 24bit mask, but that is likely because it just ran out of 
memory.

I suppose it will work if you cut down the allocations in the 
test case a bit, e.g. decrease NUMALLOC to 10 and perhaps MAX_LEN to
5*PAGE_SIZE. Did that in my copy.

> 
> """
> testing mask alloc upto 24 bits
> gpm1 3 mask 3fffff size 20440 total 62KB failed
> gpm1 4 mask 3fffff size 24369 total 62KB failed
> gpm1 6 mask 3fffff size 15255 total 64KB failed
> gpm1 7 mask 3fffff size 12676 total 64KB failed
> gpm1 8 mask 3fffff size 23917 total 64KB failed
> gpm1 9 mask 3fffff size 11682 total 64KB failed
> gpm1 10 mask 3fffff size 23091 total 64KB failed
> gpm1 11 mask 3fffff size 16880 total 64KB failed
> gpm1 12 mask 3fffff size 17257 total 64KB failed
> gpm1 13 mask 3fffff size 8686 total 64KB failed
> gpm1 14 mask 3fffff size 9871 total 64KB failed
> gpm1 15 mask 3fffff size 19740 total 64KB failed
> gpm1 16 mask 3fffff size 11557 total 64KB failed
> gpm1 18 mask 3fffff size 23723 total 67KB failed
> gpm1 19 mask 3fffff size 16136 total 67KB failed
> gpm2 6 mask 3fffff size 4471 failed
> gpm2 7 mask 3fffff size 16868 failed
> gpm2 8 mask 3fffff size 22093 failed
> gpm2 9 mask 3fffff size 17666 failed
> gpm2 11 mask 3fffff size 14416 failed
> gpm2 12 mask 3fffff size 10825 failed
> gpm2 13 mask 3fffff size 3918 failed
> gpm2 14 mask 3fffff size 6255 failed
> gpm2 15 mask 3fffff size 2428 failed
> gpm2 16 mask 3fffff size 517 failed
> gpm2 18 mask 3fffff size 12890 failed
> gpm2 19 mask 3fffff size 3211 failed
> verify & free
> mask fffff
> mask 1fffff
> mask 3fffff
> mask 7fffff
> mask ffffff
> done
> """
> 
>  Then boot up goes on and while init is running I get this:

Ah, I see the problem. Your sound driver allocates a dma area < 16 bytes.
I had added a BUG_ON for that to catch some mistakes (of passing 
order instead of size), but it triggers here incorrectly. 

Didn't see that in my testing. 

I put up an updated patchkit on ftp://firstfloor.org/pub/ak/mask/patches/
It also has some other fixes.

Can you retest with that please?

Thanks for testing.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
