From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008111721.KAA03038@google.engr.sgi.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Fri, 11 Aug 2000 10:21:17 -0700 (PDT)
In-Reply-To: <200008111320.OAA02445@flint.arm.linux.org.uk> from "Russell King" at Aug 11, 2000 02:20:23 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Roman Zippel <roman@augan.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> Roman Zippel writes:
> > Can you send me that patch? I'd like to check it, if it can be used for

http://oss.sgi.com/projects/numa/download/map.patch

And even if it doesn't help m68k, it definitely will help mips64, ia64 
and ARM (from what I am understanding from Russell). So, unless it is
_breaking_ m68k, I would rather see the patch go in ...

> > the m68k port. m68k still has its own support for discontinous mem and
> > from what I've seen so far I'm not really convinced yet to give it up.
> 
> I don't see anything wrong in continuing with this.  ARM also does
> this in addition to support for the discontig mem stuff.  Why?
> 
> The generial discontig code is ok so long as you have a lot of RAM
> in node 0.  However, since all allocations currently come from node
> 0, if this node is small, then there is a chance that you will run
> out of memory at bootup, and then not be able to continue (and
> because we both use fbcon, there is no message visible to the user,
> and hence no diagnostics).

Note: the biggest component of bootmem allocation is the mem_map for
that node, which happens on specific nodes. I agree, other allocations
happen out of node 0, but if there is a chance that on specific architectures
we might run out of memory on node 0, we can fix this, although I would
like to hear details offline ...

> 
> Continuing with the single node but many "areas" that ARM follows, and
> from what it sounds like m68k does, means that you can allocate from
> any "area", and therefore don't hit this restriction.
> 
> One way out of this would be if the NUMA stuff can have the "allocations
> only from node 0" feature turned off, and then I'd be happy to let the
> ARM version be replaced totally by the discontig case.

This is not NUMA, this is regular DISCONTIG. One option while doing 
alloc_bootmem (ie, no node specified), is to do the allocation from node 
0, since no other node can be guranteed to exist. 

If this sounds too constricting, we can modify alloc_bootmem to try 
allocating from all nodes for which alloc_bootmem_node() has already
been done. Shouldn't be too hard to implement and the changes are
completely in the bootmem allocator code. Lets talk offline (along
with Roman) if you are interested.

Kanoj

>    _____
>   |_____| ------------------------------------------------- ---+---+-
>   |   |         Russell King        rmk@arm.linux.org.uk      --- ---
>   | | | | http://www.arm.linux.org.uk/personal/aboutme.html   /  /  |
>   | +-+-+                                                     --- -+-
>   /   |               THE developer of ARM Linux              |+| /|\
>  /  | | |                                                     ---  |
>     +-+-+ -------------------------------------------------  /\\\  |
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
