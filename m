Date: Wed, 26 Apr 2000 19:06:57 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <852568CD.0057D4FC.00@raylex-gh01.eo.ray.com>
Message-ID: <Pine.LNX.4.21.0004261823290.1687-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson.RTS@raytheon.com
Cc: linux-mm@kvack.org, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Apr 2000 Mark_H_Johnson.RTS@raytheon.com wrote:

>In the context of "memory balancing" - all processors and all memory is NOT
>equal in a NUMA system. To get the best performance from the hardware, you
>prefer to put "all" of the memory for each process into a single memory unit -
>then run that process from a processor "near" that memory unit. This seemingly

The classzone approch (aka overlapped zones approch) is irrelevant with
NUMA problematics as far I can tell.

NUMA is a problematic that belongs outside the pg_data_t. It doesn't
matter how we restructure the internal of the zone_t.

I only changed the internal structure of one node. Not at all how to
policy the allocations and the balance between different nodes (that
decisions have to live in the linux/arch/ tree and not in __alloc_pages).

On NUMA hardware you have only one zone per node since nobody uses ISA-DMA
on such machines and you have PCI64 or you can use the PCI-DMA sg for
PCI32. So on NUMA hardware you are going to have only one zone per node
(at least this was the setup of the NUMA machine I was playing with). So
you don't mind at all about classzone/zone. Classzone and zone are the
same thing in such a setup, they both are the plain ZONE_DMA zone_t.
Finished. Said that you don't care anymore about the changes of how the
overlapped zones are handled since you don't have overlapped zones in
first place.

Now on NUMA when you want to allocate memory you have to use
alloc_pages_node so that you can tell also which node allocate from.

Here Linus was proposing of making alloc_pages_node this way:

	alloc_pages_node(nid, gfpmask, order)
	{
		zonelist_t ** zonelist = nid2zonelist(nid, gfpmask);

		__alloc_pages(zonelist, order);
	}

and then having the automatic falling back between nodes and numa memory
balancing handled by __alloc_pages and by the current 2.3.99-pre6-5
zonelist falling back trick.

I care to explain why I think that's not the right approch for handling
NUMA allocations and balancing decisions.

As first it's clear that the above described NUMA approch is abusing
zonelist_t by looking the size of the zonelist_t structure:

	typedef struct zonelist_struct {
		zone_t * zones [MAX_NR_ZONES+1]; // NULL delimited
		int gfp_mask;
	} zonelist_t;

If zonelist was designed for NUMA it should be something like:

	typedef struct zonelist_struct {
		zone_t * zones [max(MAX_NR_ZONES*MAX_NR_NODES)+1]; // NULL delimited
		int gfp_mask;
	} zonelist_t;

however we can fix that easily by enlarging the zones array in the
zonelist.

and as second the zonelist-NUMA solution isn't enough flexible since if
there's lots of cache allocate in one node we may prefer to move or shrink
the cache than to allocate mapped areas of the same task in different
nodes (as the __alloc_pages would do).

With the zonelist_t abused to do NUMA we _don't_ have flexibility.

If you move the NUMA balancing and node selection into the higher layer
as I was proposing, instead you can do clever things.

And as soon as you move the decisions at the higher layer you don't mind
anymore about the node internals. Or better you only care to be able to
find the current life-state of a node and you of course can do that. Then
once you know the state of the interesting node you can do the decision of
what to do _still_ at the highlever layer.

At the highlevel layer you can see that the node is filled with 90% of
cache, and then you can say: ok allocate from this node anyway and let it 
to shrink some cache if necessary.

Then the lower layer (__alloc_pages) will do automatically the balancing
and it will try to allocate memory from such node. You can also grab the
per-node spinlock in the highlever layer before checking the state of the
node so that you'll know the state of the node won't change from under you
while doing the allocation.

>These are issues that need to be addressed if you expect to use this

I always tried to keep these issues in mind (also before writing the
classzone approch).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
