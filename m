Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 96BCC5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 19:56:24 -0400 (EDT)
Date: Fri, 22 Oct 2010 10:56:16 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
Message-ID: <20101021235616.GC3270@amd>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010211255570.24115@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 12:59:17PM -0500, Christoph Lameter wrote:
> Slab objects (and other caches) are always allocated from ZONE_NORMAL.
> Not from any other zone. Calling the shrinkers for those zones may put
> unnecessary pressure on the caches.
> 
> Check the zone if we are in a reclaim situation where we are targeting
> a specific node. Can occur f.e. in kswapd and in zone reclaim.

Can you see my per-zone shrinker patches posted a few days ago?
Rather than special case things, they just fold the slab shrinking
with the pagecache shrinking so they now both operate per-zone.

Shrinkers that are zone aware and don't have any objects in a particular
zone would of course not do any scanning.

I guess other than adding special casing, another problem others have
pointed out is that you don't really know what zone a shrinker has
memory in. Whether it is DMA or DMA32 or ZONE_MOVABLE or whatever comes
up.

There is also no restriction from shrinkers having HIGHMEM pages. They
are sometimes called "slab shinkers", but really it is just any type of
reclaimable memory a subsystem might have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
