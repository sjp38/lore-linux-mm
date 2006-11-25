Date: Sat, 25 Nov 2006 11:01:45 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH 1/11] Add __GFP_MOVABLE flag and update callers
In-Reply-To: <Pine.LNX.4.64.0611241924110.17508@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0611251058350.6991@woody.osdl.org>
References: <20061121225022.11710.72178.sendpatchset@skynet.skynet.ie>
 <20061121225042.11710.15200.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0611211529030.32283@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611212340480.11982@skynet.skynet.ie>
 <Pine.LNX.4.64.0611211637120.3338@woody.osdl.org> <20061123163613.GA25818@skynet.ie>
 <Pine.LNX.4.64.0611230906110.27596@woody.osdl.org> <20061124104422.GA23426@skynet.ie>
 <Pine.LNX.4.64.0611241924110.17508@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Mel Gorman <mel@skynet.ie>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Fri, 24 Nov 2006, Hugh Dickins wrote:
> 
> You need to add in something like the patch below (mutatis mutandis
> for whichever approach you end up taking): tmpfs uses highmem pages
> for its swap vector blocks, noting where on swap the data pages are,
> and allocates them with mapping_gfp_mask(inode->i_mapping); but we
> don't have any mechanism in place for reclaiming or migrating those.

I think this really just points out that you should _not_ put MOVABLE into 
the "mapping_gfp_mask()" at all.

The mapping_gfp_mask() should really just contain the "constraints" on 
the allocation, not the "how the allocation is used". So things like "I 
need all my pages to be in the 32bit DMA'able region" is a constraint on 
the allocator, as is something like "I need the allocation to be atomic". 

But MOVABLE is really not a constraint on the allocator, it's a guarantee 
by the code _calling_ the allocator that it will then make sure that it 
_uses_ the allocation in a way that means that it is movable.

So it shouldn't be a property of the mapping itself, it should always be a 
property of the code that actually does the allocation.

Hmm?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
