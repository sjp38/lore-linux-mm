Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8FDA36003C1
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 17:47:46 -0500 (EST)
Date: Mon, 25 Jan 2010 23:46:43 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100125224643.GA30452@random.random>
References: <patchbomb.1264054824@v2.random>
 <alpine.DEB.2.00.1001220845000.2704@router.home>
 <20100122151947.GA3690@random.random>
 <alpine.DEB.2.00.1001221008360.4176@router.home>
 <20100123175847.GC6494@random.random>
 <alpine.DEB.2.00.1001251529070.5379@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001251529070.5379@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 03:50:31PM -0600, Christoph Lameter wrote:
> There is always VM activity, so we need 512 pointers sigh.

well you said some week ago that actual systems never swap and swap is
useless... if they don't swap there will be just 1 pointer in the
pmd. The mprotect/mremap we want to learn using pmd_trans_huge
natively without split but again, this is incremental work.

> So its not possible to use these "huge" pages in a useful way inside of
> the kernel. They are volatile and temporary.

They are so useless that firefox never splits them, this is my
laptop. khugepaged running so if there's swapout, after swapin they
will be collapsed back into hugepages.

AnonPages:        357148 kB
AnonHugePages:     53248 kB

> In short they cannot be treated as 2M entities unless we add some logic to
> prevent splitting.

They can on the physical side, splitting only involves the virtual
side, this is why O_DIRECT DMA through gup already works on hugepages
without splitting them.

> Frankly this seems to be adding splitting that cannot be used if one
> really wants to use large pages for something.
> 
> I still think we should get transparent huge page support straight up
> first without complicated fallback schemes that makes huge pages difficult
> to use.

Just send me patches to remove all callers of split_huge_page, then
split_huge_page can go away too. But saying that hugepages aren't
useful already is absurd, kvm with "madvise" default of sysfs already
gets the full benefit, nothing more can be achieved by kvm in
performance and functionality than what my patch delivers already
(ok swapping will be a little more efficient if done through 2M I/O
but swap performance isn't so critical). Our objective is to over time
eliminate the need of split_huge_page. khugepaged will remain required
forever, unless the whole kernel ram will become relocatable and
defrag not just an heuristic but a guarantee (it is needed after one
VM exits and release several gigs of hugepages, so the other VM get
the speedup).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
