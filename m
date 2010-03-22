Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9A04B6B01BA
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 13:17:43 -0400 (EDT)
Date: Mon, 22 Mar 2010 18:15:53 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
Message-ID: <20100322171553.GS29874@random.random>
References: <patchbomb.1268839142@v2.random>
 <alpine.DEB.2.00.1003171353240.27268@router.home>
 <20100318234923.GV29874@random.random>
 <alpine.DEB.2.00.1003190812560.10759@router.home>
 <20100319144101.GB29874@random.random>
 <alpine.DEB.2.00.1003221027590.16606@router.home>
 <20100322163523.GA12407@cmpxchg.org>
 <alpine.DEB.2.00.1003221139300.17230@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003221139300.17230@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 22, 2010 at 11:46:01AM -0500, Christoph Lameter wrote:
> On Mon, 22 Mar 2010, Johannes Weiner wrote:
> 
> > > entries while walking the page tables! Go incrementally use what
> > > is there.
> >
> > That only works if you merely read the tables.  If the VMA gets broken
> > up in the middle of a huge page, you definitely have to map ptes again.
> 
> Yes then follow the established system for remapping stuff.

I followed exactly what __pte_alloc does already. When pmds can't go
away after they're established, the only place that uses that locking
is __pte_alloc. Now obviously more stuff will have to use that _same_
locking, because it's not true anymore that a pmd can't go away after
it's established _if_ it's huge.

I also made sure a pmd can't become huge without mmap_sem and anon_vma
rmap lock, so that we can lockless check if pmd is huge, and if it's
not, we just take the legacy 4k paths. That is how it guarantees there
is no measurable slowdown unless you actively use 2M pages and in turn
you get a huge boost (like 50% faster) which outweights any overhead
introduced by having to take the page_table_lock in the pmd_huge new
paths.

It's just pmd_huge -> page_table_lock, not pmd_huge -> call pmd_offset
lockless and take the PT lock.

page_table_lock for pmd_huge acts the _exact_ same way of the PT lock
for the not pmd_huge path.

> It results in a volatility in the page table entries that requires new
> synchronization procedures. It also increases the difficulty in
> establishing a reliable state of the pages / page tables for
> operations since there is potentially on-the-fly atomic conversion
> wizardry going on.

Again: split_huge_page has nothing to do with the pte or pmd locking.

Especially obvious in the case your proposed alternate design will
still use one form of split_huge_page but one that can fail if the
page is under gup (which would practically make it unusable anywhere
but swap and even in swap it would lead to potential livelocks in
unsolvable oom as it's not just slow-unfrequent-IO calling gup).

> You do not need to do this all at once. Again the huge page subsystem has
> been around for years and we have established mechanisms to move/remap.
> There nothing hindering us from implementing huge page -> regular page
> conversion using the known methods or also implementing explicit huge page
> support in more portions of the kernel.

Indeed hugetlbfs also adds page_table_lock around every pmd
manipulation. But personally I prefer you focus on __pte_alloc as
transparent hugepage has to mirror exactly the pte locking to be
clean, regardless of hugetlbfs (in this case hugetlbfs happen to use
the same locking of __pte_alloc and transparent hugepage huge_memory.c).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
