Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 989415F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 15:41:45 -0400 (EDT)
Date: Thu, 21 Oct 2010 12:40:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
Message-Id: <20101021124054.14b85e50.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1010211255570.24115@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010 12:59:17 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> Slab objects (and other caches) are always allocated from ZONE_NORMAL.
> Not from any other zone. Calling the shrinkers for those zones may put
> unnecessary pressure on the caches.
> 
> Check the zone if we are in a reclaim situation where we are targeting
> a specific node. Can occur f.e. in kswapd and in zone reclaim.

I have a vague feeling that there was a reason for shrinking the slab
for highmem reclaim.  Perhaps some scenario in which freeing a slab
object would make a highmem page freeable.  Something like stripping
buffer_heads from a pagecache page, but it wasn't that.  I can't
immediately find mention in code comments or in ancient changelogs. 
hrm.

Obviously we do want to shrink slab when someone's trying to allocate
with __GFP_HIGHMEM because that allocation can also use ZONE_NORMAL. 
But vmscan will do that as it advances from ZONE_HIGHMEM down to
ZONE_NORMAL.

The patch doesn't patch direct reclaim, in do_try_to_free_pages().  How
come?


<ancient memories are stirring>

OK, maybe this.  Suppose we have a machine with 800M lowmem and 200M
highmem.  And suppose the lowmem region is stuffed full of clean
icache/dcache.  A __GFP_HIGHMEM allocation should put pressure on
lowmem to get some of those pages back.  What we don't want to do is to
keep on reclaiming the highmem zone and allocating pages from there,
because the machine would effectively end up with only 200M available
for pagecache.

Please convince us that your patch doesn't screw up zone balancing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
