Date: Thu, 8 Mar 2007 09:46:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V4
In-Reply-To: <Pine.LNX.4.64.0703081022040.1615@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0703080937410.27614@schroedinger.engr.sgi.com>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703081022040.1615@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Mar 2007, Mel Gorman wrote:

> Brought up 4 CPUs
> Node 0 CPUs: 0-3
> mm/memory.c:111: bad pud c0000000050e4480.

Lower bits must be clear right? Looks like the pud was released
and then reused for a 64 byte cache or so. This is likely a freelist 
pointer that slub put there after allocating the page for the 64 byte 
cache. Then we tried to use the pud.

> migration_cost=0,1000
> *** SLUB: Redzone Inactive check fails in kmalloc-64@c0000000050de0f0 Slab
> c000000000756090
>     offset=240 flags=5000000000c7 inuse=3 freelist=c0000000050de0f0
>   Bytes b4 c0000000050de0e0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ................
>     Object c0000000050de0f0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ................
>     Object c0000000050de100:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ................
>     Object c0000000050de110:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ................
>     Object c0000000050de120:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ................
>    Redzone c0000000050de130:  00 00 00 00 00 00 00 00
> ........ FreePointer c0000000050de138: 0000000000000000

Data overwritten after free or after slab was allocated. So this may be 
the same issue. pud was zapped after it was freed destroying the poison 
of another object in the 64 byte cache.

Hmmm.. Maybe I should put the pad checks before the object checks. 
That way we detect that the whole slab was corrupted and do not flag just 
a single object.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
