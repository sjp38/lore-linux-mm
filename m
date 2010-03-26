Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 890306B0217
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 14:47:22 -0400 (EDT)
Date: Fri, 26 Mar 2010 13:44:23 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #15
In-Reply-To: <20100326182311.GD5825@random.random>
Message-ID: <alpine.DEB.2.00.1003261335210.31938@router.home>
References: <patchbomb.1269622804@v2.random> <alpine.DEB.2.00.1003261256080.31109@router.home> <20100326182311.GD5825@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Mar 2010, Andrea Arcangeli wrote:

> BTW, unfortunately according to tons of measurements done so far, SLUB
> is too slow on most workstations and small/mid servers (usually single
> digits but in some case even double digits percentage slowdowns
> depending on the workload, hackbench tends to stress it the
> most). It's a tradeoff between avoiding wasting tons of ram on
> 1024-way and running fast. Either that or something's wrong with SLUB
> implementation (and I'm talking about 2.6.32, no earlier code). I'd
> also like to save memory so it'd be great if SLUB can be fixed to
> perform faster!

The SLUB fastpath is the fastest there is. Problems arise because of
locality constraints in SLUB. SLAB can throw gobs of memory at it to
guarantee a high cache hit rate but to cover all angles on NUMA requires
to throw the gobs multiple times. The weakness is SLUBs free functions
which frees the object directly to the slab page instead of
running through a series of caching structures. If frees occur to
locally dispersed objects then SLUB is at a disadvantage since its hitting cold
cache lines for metadata on free.

On the other hand SLUB hands out objects in a locality aware fashion and
not randomly from everywhere like SLAB. This is certainly good to reduce
TLB pressure. Huge pages would accellerate SLUB since more objects can be
served from the same page than before.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
