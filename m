Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E0F786B008C
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 11:12:18 -0500 (EST)
Date: Tue, 26 Jan 2010 17:11:20 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100126161120.GN30452@random.random>
References: <patchbomb.1264054824@v2.random>
 <alpine.DEB.2.00.1001220845000.2704@router.home>
 <20100122151947.GA3690@random.random>
 <alpine.DEB.2.00.1001221008360.4176@router.home>
 <20100123175847.GC6494@random.random>
 <alpine.DEB.2.00.1001251529070.5379@router.home>
 <20100125224643.GA30452@random.random>
 <alpine.DEB.2.00.1001260939050.23549@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001260939050.23549@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 09:47:51AM -0600, Christoph Lameter wrote:
> I have to disable swap to be able to make use of these huge pages?

No.

> Just because your configuration did not split does not mean that there
> is a guarantee of them not splitting. You need to guarantee that the VM
> does not split them in order to be able to safely refer to them from
> code (like I/O paths).

No. O_DIRECT already works on those pages without splitting them,
there is no need to split them, just run 512 gups like you would be
doing if those weren't hugepages.

If your I/O can be interrupted then just use mmu notifier, call
gup_fast, and be notified if anything runs that split the page.

Splitting the page doesn't mean relocating it, DMA won't be able to
notice. So if you use mmu notifier just 1 gup + put_page will be
enough exactly because with mmu notifier you won't need refcounting on
tail pages and head pages at all!

If you don't have longstanding mapping and a way to synchronously
interrupt the visibility of hugepages from your device, then likely
you work with small dma sizes like storage and networking does, and
gup each 4k will be fine.

> Earlier you stated that reclaim can remove 4k pieces of huge pages after a
> split. How does gup keep the huge pages stable while doing I/O? Does gup
> submit 512 pointers to 4k chunks or 1 pointer to a 2M chunk?

gup works like now, you just write code that works today on a
fragmented hugepage, and it'll still work. So you need to run 512 gup_fast
to be sure all 4k fragments are stable. But if you can use mmu
notifier just one gup_fast(&head_page), put_page(head_page) will be
enough after you're registered.

I'm unsure exactly what you need to do that won't be feasible with mmu
notifier and 1 gup or 512 gup.

> This implementation seems to only address the TLB pressure issue
> but not the scaling issue that arises because we have to handle data in
> 4k chunks (512 4k pointers instead of one 2M pointer). Scaling is not
> addressed because complex fallback logic sabotages a basic benefit of
> huge pages.

Scaling is addressed for everything, including collapsing the hugepage
back after swapin if they're fragmented because of that. Furthermore
we want to remove split_huge_page from as many paths as possible but
Rome wasn't built in a day. We need to stabilize and stress this code
now, then we include it, and extend it to tmpfs and pagecache.

Note a malloc(3G)+memset(3G) takes >5sec with lockdep without
transparent hugepage, or <2sec after "echo always >enabled", TLB
pressure is irrelevant in that workload that spends all time
allocating pages and clearing them through kernel direct
mapping. Your idea that this is only taking care of TLB pressure is
totally wrong and I posted benchmarks already as proof (which become
extreme the moment you enable lockdep and all the little locks becomes
more costly, so avoiding 512 page faults and doing a single call to
alloc_pages(order=9) speedup the workload more than 100%).

> > performance and functionality than what my patch delivers already
> > (ok swapping will be a little more efficient if done through 2M I/O
> > but swap performance isn't so critical). Our objective is to over time
> > eliminate the need of split_huge_page. khugepaged will remain required
> 
> Ok then establish some way to make these huge pages stable.

Again: register into mmu notifer, call gup_fast; put_page, and you're
done. 1 op, and just 3 cachelines for pgd,pud and pmd to get to the page.

> That all depends on what you mean by guarantee I guess.

mmu notifier is a must if the mapping is longstanding or you'll lock
the ram. It's also a lot more efficient than doing 512 gup_fast which
would achieve the same effect but it's evil against the VM (lock the
user virtual memory in ram) and requires 512 gup instead of just 1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
