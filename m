Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 406686B01F1
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 21:27:35 -0400 (EDT)
Date: Tue, 6 Apr 2010 03:26:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFD] Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406012647.GU5825@random.random>
References: <patchbomb.1270168887@v2.random>
 <20100405120906.0abe8e58.akpm@linux-foundation.org>
 <20100405193616.GA5125@elte.hu>
 <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
 <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com>
 <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
 <20100405232115.GM5825@random.random>
 <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051747030.21411@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1004051747030.21411@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 05, 2010 at 06:08:51PM -0700, Linus Torvalds wrote:
> 
> 
> On Mon, 5 Apr 2010, Linus Torvalds wrote:
> > 
> > In particular, when you quote 6% improvement for a kernel compile, your 
> > own numbers make [me] seriously wonder how many percentage points you'd get 
> > from just faulting in 8 pages at a time when you have lots of memory free, 
> > and use a single 3-order allocation to get those eight pages?
> 
> THIS PATCH IS TOTALLY UNTESTED!
> 
> It's very very unlikely to work, but it compiles for me at least in one 
> particular configuration. So it must be perfect. Ship it.
> 
> It basically tries to just fill in anonymous memory PTE entries roughly 
> one cacheline at a time, avoiding extra page-faults and extra memory 
> allocations.
> 
> It's probably buggy as hell, I don't dare try to actually boot the crap I 
> write. It literally started out as a pseudo-code patch that I then ended 
> up expanding until it compiled and then fixed up some corner cases in. 
> 
> IOW, it's not really a serious patch, although when I look at it, it 
> doesn't really look all that horrible.
> 
> Now, I'm pretty sure that allocating the page with a single order-3 
> allocation, and then treating it as 8 individual order-0 pages is broken 
> and probably makes various things unhappy. That "make_single_page()" 
> monstrosity may or may not be sufficient.
> 
> In other words, what I'm trying to say is: treat this patch as a request 
> for discussion, rather than something that necessarily _works_. 

This will provide 0% speedup to a kernel compile in guest where
transparent hugepage support (or hugetlbfs too) would provide a 6%
speedup.

I evaluated the prefault approach before I finalized my design and
then generated an huge pmd when the whole hugepage was mapped. It's
all worthless complexity in my view.

In fact except at boot time we'll likely won't be interested to take
advantage of this, as it is not a free optimization and it magnifies
the time it takes to clear-page copy-page (which is why I tried to try
to only prefault an hugepages, and then after benchmarking I figured
out it wasn't worth it and it'd be hugely more complicated too). The
only case it is worth mapping more than one 4k page, is when we can
take advantage of the tlb miss speedup and of the 2M tlb, otherwise
it's better to stick to 4k page faults and do a 4k clear-page
copy-page and not risk to take more than 4k of memory. And let
khugepaged do the rest.

I think I already mentioned it in the previous email but seeing your
patch I feel obliged to re-post:

---------------
hugepages in the virtualization hypervisor (and also in the guest!)
are much more important than in a regular host not using
virtualization, becasue with NPT/EPT they decrease the tlb-miss
cacheline accesses from 24 to 19 in case only the hypervisor uses
transparent hugepages, and they decrease the tlb-miss cacheline
accesses from 19 to 15 in case both the linux hypervisor and the linux
guest both uses this patch (though the guest will limit the addition
speedup to anonymous regions only for now...).  Even more important is
that the tlb miss handler is much slower on a NPT/EPT guest than for a
regular shadow paging or no-virtualization scenario. So maximizing the
amount of virtual memory cached by the TLB pays off significantly more
with NPT/EPT than without (even if there would be no significant
speedup in the tlb-miss runtime).
----------------

This is in the changelog of the "transparent hugepage core" patch too
and here as well:

http://linux-mm.org/TransparentHugepage?action=AttachFile&do=get&target=transparent-hugepage.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
