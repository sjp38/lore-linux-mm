Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A3C0B6B01B1
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 12:35:41 -0400 (EDT)
Date: Mon, 22 Mar 2010 17:35:23 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
Message-ID: <20100322163523.GA12407@cmpxchg.org>
References: <patchbomb.1268839142@v2.random> <alpine.DEB.2.00.1003171353240.27268@router.home> <20100318234923.GV29874@random.random> <alpine.DEB.2.00.1003190812560.10759@router.home> <20100319144101.GB29874@random.random> <alpine.DEB.2.00.1003221027590.16606@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003221027590.16606@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 22, 2010 at 10:38:23AM -0500, Christoph Lameter wrote:
> On Fri, 19 Mar 2010, Andrea Arcangeli wrote:
> > defrag, migration they all can fail, split_huge_page cannot. The very
> > simple reason split_huge_page cannot fail is this: if I have to do
> > anything more than a one liner to make mremap, mprotect and all the
> > rest, then I prefer to take your non-practical more risky design. The
> > moment you have to alter some very inner pagetable walking function to
> > handle a split_huge_page error return, you'll already have to recraft
> > the code in a big enough way, that you better make it hugepage
> > aware. Making it hugepage aware is like 10 times more difficult and
> > error prone and hard to test, than handling a split_huge_page error
> > retval, but still in 10 files fixed for the error retval, will be
> > worth 1 file converted not to call split_huge_page at all. That
> > explains very clearly my decision to make split_huge_page not fail,
> > and make sure all next efforts will be spent in removing
> > split_huge_page and not in handling an error retval for a function
> > that shouldn't have been called in the first place!
> 
> We already have 2M pmd handling in the kernel and can consider huge pmd
> entries while walking the page tables! Go incrementally use what
> is there.

That only works if you merely read the tables.  If the VMA gets broken
up in the middle of a huge page, you definitely have to map ptes again.

And as already said, allowing it to happen always-succeeding and
atomically allows to switch users step by step.

That sure sounds more incremental to me than being required to do
non-trivial adjustments to all the places at once!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
