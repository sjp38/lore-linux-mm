Date: Tue, 5 Dec 2006 17:17:05 +0000
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that may be migrated
Message-ID: <20061205171705.GC20614@skynet.ie>
References: <20061130170746.GA11363@skynet.ie> <20061130173129.4ebccaa2.akpm@osdl.org> <Pine.LNX.4.64.0612010948320.32594@skynet.skynet.ie> <20061201110103.08d0cf3d.akpm@osdl.org> <20061204140747.GA21662@skynet.ie> <20061204113051.4e90b249.akpm@osdl.org> <Pine.LNX.4.64.0612041946460.26428@skynet.skynet.ie> <20061204143435.6ab587db.akpm@osdl.org> <Pine.LNX.4.64.0612042338390.2108@skynet.skynet.ie> <Pine.LNX.4.64.0612050806300.11213@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0612050806300.11213@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Andy Whitcroft <apw@shadowen.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On (05/12/06 08:14), Christoph Lameter didst pronounce:
> On Mon, 4 Dec 2006, Mel Gorman wrote:
> 
> > 4. Offlining a DIMM
> > 5. Offlining a Node
> > 
> > For Situation 4, a zone may be needed because MAX_ORDER_NR_PAGES would have
> > to be set to too high for anti-frag to be effective. However, zones would
> > have to be tuned at boot-time and that would be an annoying restriction. If
> > DIMMs are being offlined for power reasons, it would be sufficient to be
> > best-effort.
> 
> We are able to depopularize a portion of the pages in a MAX_ORDER chunk if 
> the page structs pages on the borders of that portion are not stored on 
> the DIMM.

Portions of it sure, but to offline the DIMM, all pages must be removed from
it. To guarantee the offlining, that means only __GFP_MOVABLE allocations
are allowed within that area and a zone is the easiest way to do it.

Now, that said, if anti-fragmentation only uses lower PFNs, the number
of active unmovable pages has to be large enough to span all DIMMs
before the offlining would fail. This problem will be hit in some
situations.

> Set a flag in the page struct of those page struct pages 
> straddling the border and free the page struct pages describing only
> memory in the DIMM.
> 

I'm not sure what you mean by this. If I wanted to offline a DIMM and I had
anti-frag (specifically the portion of it that allows a flag that affects a
whole block of pages), I would mark all the MAX_ORDER_NR_PAGES blocks there
as going offline so that the pages will not be reallocated. Some time in
the future, the DIMM will be offlined but it could be an indefinte length
of time. If the DIMM consisted of just ZONE_MOVABLE, it could be offlined
in the length of time it takes to migrate all pages elsewhere or page them out.

> > Situation 5 requires that a hotpluggable node only allows __GFP_MOVABLE
> > allocations in the zonelists. This would probably involving having one
> > zone that only allowed __GFP_MOVABLE.
> 
> This is *node* hotplug and we already have a node/zone structure etc where 
> we could set some option to require only movable allocations.

True. It would be a bit of a hack, but it's work without needing zones.

> Note that 
> NUMA nodes have always had only a single effective zone. There are some 
> exceptions on some architectures where we have additional DMA zones on the 
> first or first two nodes but NUMA memory policies will *not* allow to 
> exercise control over allocations from those zones.
> 
> > In other words, to properly address all situations, we may need anti-frag
> > and zones, not one or the other.
> 
> I still do not see a need for additional zones.

It's needed if you want to 100% guarantee the ability to offline a DIMM under
all circumstances. However, ZONE_MOVABLE comes with it's own problems such
as not allowing kernel allocations like network buffers.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
