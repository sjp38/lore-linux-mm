Date: Fri, 12 May 2000 14:11:49 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.21.0005121246410.6487-100000@inspiron>
Message-ID: <Pine.LNX.4.10.10005121307370.3348-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 12 May 2000, Andrea Arcangeli wrote:

> >IMO high memory should not be balanced. Stock pre7-9 tried to balance high
> >memory once it got below the treshold (causing very bad VM behavior and
> >high kswapd usage) - this is incorrect because there is nothing special
> >about the highmem zone, it's more like an 'extension' of the normal zone,
> >from which specific caches can turn. (patch attached)
> 
> IMHO that is an hack to workaround the currently broken design of the MM.
> And it will also produce bad effect since you won't age the recycle the
> cache in the highmem zone correctly.

what bad effects? the LRU list of the pagecache is a completely
independent mechanizm. Highmem pages are LRU-freed just as effectively as
normal pages. The pagecache LRU list is not per-zone but (IMHO correctly)
global, so the particular zone of highmem pages is completely transparent
and irrelevant to the LRU mechanizm. I cannot see any bad effects wrt. LRU
recycling and the highmem zone here. (let me know if you ment some
different recycling mechanizm)

> What you're trying to workaround on the highmem part is exactly the
> same problem you also have between the normal zone and the dma zone.
> Why don't you also just take 3mbyte always free from the dma zone and
> you never shrink the normal zone?

i'm not working around anything. Highmem _should not be balanced_, period.
It's a superset of normal memory, and by just balancing normal memory (and
adding highmem free count to the total) we are completely fine. Highmem is
also a temporary phenomenon, it will probably disappear in a few years
once 64-bit systems and proper 64-bit DMA becomes commonplace. (and small
devices will do 32-bit + 32-bit DMA.)

'balanced' means: 'keep X amount of highmem free'. What is your point in
keeping free highmem around?

the DMA zone resizing suggestion from yesterday is i believe conceptually
correct as well, _want to_ isolate normal allocators from these 'emergency
pools'. IRQ handlers cannot wait for more free RAM.


about classzone. This was the initial idea how to do balancing when the
zoned allocator was implemented (along with per-zone kswapd threads or
per-zone queues), but it just gets too complex IMHO. Why dont you give the
simpler suggestion from yesterday a thought? We have only one zone
essentially which has to be balanced, ZONE_NORMAL. ZONE_DMA is and should
become special because it also serves as an atomic pool for IRQ
allocations. (ZONE_HIGHMEM is special and uninteresting as far as memory
balance goes, as explained above.) So we only have ZONE_NORMAL to worry
about. Zonechains are perfect ways of defining fallback routes.

i've had a nicely balanced (heavily loaded) 8GB box for the past couple of
weeks, just by doing (yesterday's) slight trivial changes to the
zone-chains and watermarks. The default settings in the stock kernel were
not tuned, but all the mechanizm is there. LRU is working, there was
always DMA RAM around, no classzones necessery here. So what is exactly
the case you are trying to balance?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
