Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D06646B0211
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 14:48:54 -0400 (EDT)
Date: Thu, 8 Apr 2010 20:48:42 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 56 of 67] Memory compaction core
Message-ID: <20100408184842.GE28964@cmpxchg.org>
References: <patchbomb.1270691443@v2.random> <a86f1d01d86dffb4ab53.1270691499@v2.random> <20100408161814.GC28964@cmpxchg.org> <20100408164630.GL5749@random.random> <20100408170948.GQ5749@random.random> <20100408171458.GS5749@random.random> <20100408175604.GD28964@cmpxchg.org> <20100408175847.GV5749@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100408175847.GV5749@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 08, 2010 at 07:58:47PM +0200, Andrea Arcangeli wrote:
> On Thu, Apr 08, 2010 at 07:56:04PM +0200, Johannes Weiner wrote:
> > Humm, maybe the start pfn could be huge page aligned?  That would make
> > it possible to check for PageTransHuge() and skip over compound_order()
> > pages.  This way, we should never actually run into PG_tail pages.
> 
> The problem here are random compound pages that aren't owned by the
> transparent hugepage subsystem. If we can't identify those, it's
> unsafe to call compound_order (like it's unsafe to call page_order for
> pagebuddy pages).

But transparent huge pages are the only compound pages on the LRU, so
we should be able to identify them.

The lru_lock excludes isolation, splitting and collapsing, so I think
this is safe:

	if (PageLRU() && PageTransCompound()) {
		low_pfn += (1 << compound_order()) - 1
		continue
	}

	if (__isolate_lru_page())
		continue

	...

Do I still miss something?  If so, I will shut up now :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
