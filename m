Date: Sat, 3 May 2008 19:54:26 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC 0/2] Rootmem: boot-time memory allocator
Message-ID: <20080503175426.GB5292@elte.hu>
References: <20080503152502.191599824@symbol.fehenstaub.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080503152502.191599824@symbol.fehenstaub.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Johannes Weiner <hannes@saeurebad.de> wrote:

> I was spending some time and work on the bootmem allocator the last 
> few weeks and came to the conclusion that its current design is not 
> appropriate anymore.
> 
> As Ingo said in another email, NUMA technologies will become weirder, 
> nodes whose PFNs span other nodes for example and it makes bootmem 
> code become an unreadable mess.
> 
> So I sat down two days ago and rewrote the allocator, here is the 
> result: rootmem!

hehe :-)

> The biggest difference to the old design is that there is only one 
> bitmap for all PFNs of all nodes together, so the overlapping PFN 
> problems simply dissolve and fun like allocations crossing node 
> boundaries work implicitely.  The new API requires every node used by 
> the allocator to be registered and after that the bitmap gets 
> allocated and the allocator enabled.
> 
> I chose to add a new allocator rather than replacing bootmem at once 
> because that would have required all callsites to switch in one go, 
> which would be a lot.  The new allocator can be adopted more slowly 
> and I added a compatibility API for everything besides actually 
> setting up the allocator.  When the last user dies, bootmem can be 
> dropped completely (including pgdat->bdata, whee..)
> 
> The main ideas from bootmem have been stolen^W preserved but the new 
> design allowed me to shrink the code a lot and express things more 
> simple and clear:
> 
> $ sloc.awk < mm/bootmem.c
> 455 lines of code, 65 lines of comments (520 lines total)
> 
> $ sloc.awk < mm/rootmem.c
> 243 lines of code, 96 lines of comments (339 lines total)

amazing!

i'd still suggest to keep it all named bootmem though :-/ How about 
bootmem2.c and then renaming it back to bootmem.c, once the last user is 
gone? That would save people from having to rename whole chapters in 
entire books ;-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
