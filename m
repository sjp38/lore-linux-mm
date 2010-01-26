Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8DC666003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 11:46:06 -0500 (EST)
Date: Tue, 26 Jan 2010 17:45:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100126164550.GQ30452@random.random>
References: <patchbomb.1264054824@v2.random>
 <alpine.DEB.2.00.1001220845000.2704@router.home>
 <20100122151947.GA3690@random.random>
 <alpine.DEB.2.00.1001221008360.4176@router.home>
 <20100123175847.GC6494@random.random>
 <alpine.DEB.2.00.1001251529070.5379@router.home>
 <20100125224643.GA30452@random.random>
 <alpine.DEB.2.00.1001260939050.23549@router.home>
 <20100126161120.GN30452@random.random>
 <alpine.DEB.2.00.1001261022480.25184@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001261022480.25184@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 10:30:43AM -0600, Christoph Lameter wrote:
> So the allocation works in 2M chunks. Okay that scales at that point but
> code cannot rely on these 2M chunks to continue to exist without
> ancilliary expensive measures (mmu notifier)

mmu notifier "ancilliary expensive measures"? Ask robin with xpmem,
check gru and see how slower kvm runs thanks to mmu notifier..

All you're asking is in the future to also add a 2M-wide pin in gup,
that is not what the current API provides, and so it requires a new
gup_huge_fast API, not the current one, and it is feasible! Just not
done in this implementation as it'd make things more complex.

Just stop this red herring of yours that a replacement of the
pmd_trans_huge with a pte has anything to do with the physical side of
the hugepage. Splitting the page doesn't alter the physical side at
all, it's a _virtual_ split, and your remaining argument is how to
take a global pin on only the head page and having it distributed to
all tail pages when the virtual split happens. This is utterly
unnecessary overhead to all subsystems using mmu notifier, but it
might speedup O_DIRECT a little bit on hugepages, so it may happen
later.

> mmu notifier is expensive. The earlier implementations were able to get a
> stable huge page reference by simply doing a get_page().

That only works on hugetlbfs and it's not a property of gup_fast. It
breaks if userland maps a different mapping under you or if
libhugetlbfs is unloaded. We can extend the refcounting logic to
achieve the same "1 op pins 2M" feature but first of all we need a new
API gup_huge_fast, current api doesn't allow it. I think it's simply
wise to wait stabilizing this, before adding a new feature but if you
want me to do it now that's ok with me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
