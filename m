Date: Tue, 5 Dec 2006 08:14:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
In-Reply-To: <Pine.LNX.4.64.0612042338390.2108@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0612050806300.11213@schroedinger.engr.sgi.com>
References: <20061130170746.GA11363@skynet.ie> <20061130173129.4ebccaa2.akpm@osdl.org>
 <Pine.LNX.4.64.0612010948320.32594@skynet.skynet.ie> <20061201110103.08d0cf3d.akpm@osdl.org>
 <20061204140747.GA21662@skynet.ie> <20061204113051.4e90b249.akpm@osdl.org>
 <Pine.LNX.4.64.0612041946460.26428@skynet.skynet.ie> <20061204143435.6ab587db.akpm@osdl.org>
 <Pine.LNX.4.64.0612042338390.2108@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@osdl.org>, Andy Whitcroft <apw@shadowen.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Dec 2006, Mel Gorman wrote:

> 4. Offlining a DIMM
> 5. Offlining a Node
> 
> For Situation 4, a zone may be needed because MAX_ORDER_NR_PAGES would have
> to be set to too high for anti-frag to be effective. However, zones would
> have to be tuned at boot-time and that would be an annoying restriction. If
> DIMMs are being offlined for power reasons, it would be sufficient to be
> best-effort.

We are able to depopularize a portion of the pages in a MAX_ORDER chunk if 
the page structs pages on the borders of that portion are not stored on 
the DIMM. Set a flag in the page struct of those page struct pages 
straddling the border and free the page struct pages describing only
memory in the DIMM.

> Situation 5 requires that a hotpluggable node only allows __GFP_MOVABLE
> allocations in the zonelists. This would probably involving having one
> zone that only allowed __GFP_MOVABLE.

This is *node* hotplug and we already have a node/zone structure etc where 
we could set some option to require only movable allocations. Note that 
NUMA nodes have always had only a single effective zone. There are some 
exceptions on some architectures where we have additional DMA zones on the 
first or first two nodes but NUMA memory policies will *not* allow to 
exercise control over allocations from those zones.

> In other words, to properly address all situations, we may need anti-frag
> and zones, not one or the other.

I still do not see a need for additional zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
