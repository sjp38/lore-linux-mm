Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3067D6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 12:42:32 -0400 (EDT)
Date: Wed, 31 Mar 2010 18:41:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #16
Message-ID: <20100331164147.GN5825@random.random>
References: <patchbomb.1269887833@v2.random>
 <20100331141035.523c9285.kamezawa.hiroyu@jp.fujitsu.com>
 <20100331153339.GK5825@random.random>
 <alpine.DEB.2.00.1003311102580.17603@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003311102580.17603@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2010 at 11:24:02AM -0500, Christoph Lameter wrote:
> On Wed, 31 Mar 2010, Andrea Arcangeli wrote:
> 
> > > I'm sorry if you answered someone already.
> >
> > The generic archs without pmd approach can't mix hugepages and regular
> > pages in the same vma, so they can't provide graceful fallback and
> > never fail an allocation despite there is pleny of memory free which
> > is one critical fundamental point in the design (and later collapse
> > those with khugepaged which also can run memory compaction
> > asynchronously in the background and not synchronously during page
> > fault which would be entirely worthless for short lived allocations).
> 
> Large pages would be more independent from the page table structure with
> the approach that I outlined earlier since you would not have to do these
> sync tricks.

I was talking about memory compaction. collapse_huge_page will still
be needed forever regardless of split_huge_page existing or not.

> > About the HPAGE_PMD_ prefix it's not only HPAGE_ like I did initially,
> > in case we later decide to split/collapse 1G pages too but frankly I
> > think by the time memory size doubles 512 times across the board (to
> > make 1G pages a not totally wasted effort to implement in the
> > transparent hugepage support) we'd better move the PAGE_SIZE to 2M and
> > stick to the HPAGE_PMD_ again.
> 
> There are applications that have benefited for years already from 1G page
> sizes (available on IA64 f.e.). So why wait?

Because the difficulty on finding hugepages free increases
exponentially with the order of allocation. Plus increasing MAX_ORDER
so much would slowdown everything for no gain because we will fail to
obtain 1G pages freed. The cost of compacting 1G pages also is 512
times bigger than with regular pages. It's not feasible right now with
current memory sizes, I just said it's probably better to move to
PAGE_SIZE 2M instead of extending to 1g pages in a kernel whose
PAGE_SIZE is 4k.

Last but not the least it can be done but considering I'm abruptly
failing to merge 35 patches (and surely your comments aren't helping
in that direction...), it'd be counter-productive to make the core
even more complex with support for 1G pages immediately. In any case
the 1G support should be done at the very end of the patchset, not in
the core, or merging would be even harder as it'll all become more
complex all over the place requiring to modify two places instead of
just 1 all over the VM for every pagetable walk, and split_huge_page
internals would become more complex too. Doing it incremental also
allows the 1G support to be bisectable later.

In short, I think it makes zero sense to do it now, I think it makes
no sense until memory sizes increases 512 times, but in any case I
agreed to call it HPAGE_PMD_ and not HPAGE_ for a reason, so
discussing it now or mentioning lack of immediate
monolithic-no-bisectable 1G support isn't good reason for going
against my current patchset and we can defer this unpractical 1G
support after the useful 2M support is merged. In fact I think the
preferred way to do it (if we ever add it) is to make 2M handling
native first and then convert split_huge_page to be the "compatibility
fallback code" from 1G to 2M. Otherwise at times split_huge_page would
be forced to run a 262144 loop which might become noticeable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
