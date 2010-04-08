Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED3836B0215
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 13:56:23 -0400 (EDT)
Date: Thu, 8 Apr 2010 19:56:04 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 56 of 67] Memory compaction core
Message-ID: <20100408175604.GD28964@cmpxchg.org>
References: <patchbomb.1270691443@v2.random> <a86f1d01d86dffb4ab53.1270691499@v2.random> <20100408161814.GC28964@cmpxchg.org> <20100408164630.GL5749@random.random> <20100408170948.GQ5749@random.random> <20100408171458.GS5749@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100408171458.GS5749@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 08, 2010 at 07:14:58PM +0200, Andrea Arcangeli wrote:
> On Thu, Apr 08, 2010 at 07:09:48PM +0200, Andrea Arcangeli wrote:
> > +		if (PageTransCompound(page)) {
> > +			low_pfn += (1 << page_order(page)) - 1;
> > +			continue;
> > +		}
> 
> Thinking again the low_pfn += I'll have to remove it even from the
> hugepage case, because this could be a compound page that doesn't
> belong to transparent hugepage support, so it could go away from under
> us and make the order-reading invalid despite we hold the lru_lock.

Compared to _splitting_ huge pages, it's already an improvement, even
without the clever skipping :-)

> Unless we mark the transparent hugepages with a special bit in the
> page->flags we can't retain this optimization.
> 
> This would have been safe if we used compound_order and we knew it was
> owned by transparent hugepage support. Given how short we are in
> page->flags (I already had to remove the PG_buddy) it's unlikely we
> can mark it specially and retain this.

Humm, maybe the start pfn could be huge page aligned?  That would make
it possible to check for PageTransHuge() and skip over compound_order()
pages.  This way, we should never actually run into PG_tail pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
