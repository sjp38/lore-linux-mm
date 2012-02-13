Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id DD7C26B13F1
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 05:12:44 -0500 (EST)
Date: Mon, 13 Feb 2012 10:12:39 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20120213101239.GU5938@suse.de>
References: <alpine.DEB.2.00.1202080907320.30248@router.home>
 <20120208163421.GL5938@suse.de>
 <alpine.DEB.2.00.1202081338210.32060@router.home>
 <20120208212323.GM5938@suse.de>
 <alpine.DEB.2.00.1202081557540.5970@router.home>
 <20120209125018.GN5938@suse.de>
 <alpine.DEB.2.00.1202091345540.4413@router.home>
 <20120210102605.GO5938@suse.de>
 <alpine.DEB.2.00.1202101443570.31424@router.home>
 <alpine.DEB.2.00.1202101606530.3840@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202101606530.3840@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, Feb 10, 2012 at 04:07:57PM -0600, Christoph Lameter wrote:
> Proposal for a patch for slub to move the pfmemalloc handling out of the
> fastpath by simply not assigning a per cpu slab when pfmemalloc processing
> is going on.
> 
> 
> 
> Subject: [slub] Fix so that no mods are required for the fast path
> 
> Remove the check for pfmemalloc from the alloc hotpath and put the logic after
> the election of a new per cpu slab.
> 
> For a pfmemalloc page do not use the fast path but force use of the slow
> path (which is also used for the debug case).
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 

This weakens pfmemalloc processing in the following way

1. Process that is performance network swap calls __slab_alloc.
   pfmemalloc_match is true so the freelist is loaded and
   c->freelist is now pointing to a pfmemalloc page
2. Process that is attempting normal allocations calls slab_alloc,
   finds the pfmemalloc page on the freelist and uses it because it
   did not check pfmemalloc_match()

The patch allows non-pfmemalloc allocations to use pfmemalloc pages with
the kmalloc slabs being the most vunerable caches on the grounds they are
most likely to have a mix of pfmemalloc and !pfmemalloc requests. Patch
14 will still protect the system as processes will get throttled if the
pfmemalloc reserves get depleted so performance will not degrade as smoothly.

Assuming this passes testing, I'll add the patch to the series with the
information above included in the changelog.

Thanks Christoph.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
