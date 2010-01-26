Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4439A6003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 11:31:18 -0500 (EST)
Date: Tue, 26 Jan 2010 10:30:43 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
In-Reply-To: <20100126161120.GN30452@random.random>
Message-ID: <alpine.DEB.2.00.1001261022480.25184@router.home>
References: <patchbomb.1264054824@v2.random> <alpine.DEB.2.00.1001220845000.2704@router.home> <20100122151947.GA3690@random.random> <alpine.DEB.2.00.1001221008360.4176@router.home> <20100123175847.GC6494@random.random> <alpine.DEB.2.00.1001251529070.5379@router.home>
 <20100125224643.GA30452@random.random> <alpine.DEB.2.00.1001260939050.23549@router.home> <20100126161120.GN30452@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 2010, Andrea Arcangeli wrote:
> No. O_DIRECT already works on those pages without splitting them,
> there is no need to split them, just run 512 gups like you would be
> doing if those weren't hugepages.

That show the scaling issue is not solved.

> If your I/O can be interrupted then just use mmu notifier, call
> gup_fast, and be notified if anything runs that split the page.

"Just use mmu notifier"? Its quite a cost to register/unregister the
memory range. Again unnecessary complexity here.

> Splitting the page doesn't mean relocating it, DMA won't be able to
> notice. So if you use mmu notifier just 1 gup + put_page will be
> enough exactly because with mmu notifier you won't need refcounting on
> tail pages and head pages at all!

Page migration can relocate 4k pieces it seems.

> If you don't have longstanding mapping and a way to synchronously
> interrupt the visibility of hugepages from your device, then likely
> you work with small dma sizes like storage and networking does, and
> gup each 4k will be fine.

"synchronously interrupt the visibility of hugepages"???? What does that
mean?

> > Earlier you stated that reclaim can remove 4k pieces of huge pages after a
> > split. How does gup keep the huge pages stable while doing I/O? Does gup
> > submit 512 pointers to 4k chunks or 1 pointer to a 2M chunk?
>
> gup works like now, you just write code that works today on a
> fragmented hugepage, and it'll still work. So you need to run 512 gup_fast
> to be sure all 4k fragments are stable. But if you can use mmu
> notifier just one gup_fast(&head_page), put_page(head_page) will be
> enough after you're registered.

Just dont want that... Would like to have one 2M page not 512 4k pages.

> Note a malloc(3G)+memset(3G) takes >5sec with lockdep without
> transparent hugepage, or <2sec after "echo always >enabled", TLB
> pressure is irrelevant in that workload that spends all time
> allocating pages and clearing them through kernel direct
> mapping. Your idea that this is only taking care of TLB pressure is
> totally wrong and I posted benchmarks already as proof (which become
> extreme the moment you enable lockdep and all the little locks becomes
> more costly, so avoiding 512 page faults and doing a single call to
> alloc_pages(order=9) speedup the workload more than 100%).

So the allocation works in 2M chunks. Okay that scales at that point but
code cannot rely on these 2M chunks to continue to exist without
ancilliary expensive measures (mmu notifier)

> > That all depends on what you mean by guarantee I guess.
>
> mmu notifier is a must if the mapping is longstanding or you'll lock
> the ram. It's also a lot more efficient than doing 512 gup_fast which
> would achieve the same effect but it's evil against the VM (lock the
> user virtual memory in ram) and requires 512 gup instead of just 1.

mmu notifier is expensive. The earlier implementations were able to get a
stable huge page reference by simply doing a get_page().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
