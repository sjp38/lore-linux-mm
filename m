Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B44036B01AE
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 14:21:01 -0400 (EDT)
Date: Mon, 22 Mar 2010 19:20:28 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
Message-ID: <20100322182028.GA13114@cmpxchg.org>
References: <patchbomb.1268839142@v2.random> <alpine.DEB.2.00.1003171353240.27268@router.home> <20100318234923.GV29874@random.random> <alpine.DEB.2.00.1003190812560.10759@router.home> <20100319144101.GB29874@random.random> <alpine.DEB.2.00.1003221027590.16606@router.home> <20100322163523.GA12407@cmpxchg.org> <alpine.DEB.2.00.1003221139300.17230@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003221139300.17230@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
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

This is not comparable.  The existing remapping code does not have to deal
with structural changes in the page tables.

> > And as already said, allowing it to happen always-succeeding and
> > atomically allows to switch users step by step.
> 
> It results in a volatility in the page table entries that requires new
> synchronization procedures. It also increases the difficulty in
> establishing a reliable state of the pages / page tables for
> operations since there is potentially on-the-fly atomic conversion
> wizardry going on.

I really fail to see how.  Right now, when you want a stable entry, you
take the pte lock.  This is exactly the same for huge page entries.

Migration happens on the fly as well, you can just hide it better for
cases like mremap(), which is unaffected by the actual entries it copies.

It becomes only visible at sites affected by the entries themselves,
which are not that many, the fault handler e.g.  It is much easier to
keep that stuff centralized.

But pmd splitting affects everyone sensitive to the page table structure
itself and that ends up being everyone, well, walking page tables.

> > That sure sounds more incremental to me than being required to do
> > non-trivial adjustments to all the places at once!
> 
> You do not need to do this all at once. Again the huge page subsystem has
> been around for years and we have established mechanisms to move/remap.
> There nothing hindering us from implementing huge page -> regular page
> conversion using the known methods or also implementing explicit huge page
> support in more portions of the kernel.

I see the real complexity in actually dealing with dynamically changing
page table structure and none of the existing code does that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
