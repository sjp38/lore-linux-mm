Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 97AD56B01EF
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 21:14:48 -0400 (EDT)
Date: Tue, 6 Apr 2010 03:13:45 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406011345.GT5825@random.random>
References: <patchbomb.1270168887@v2.random>
 <20100405120906.0abe8e58.akpm@linux-foundation.org>
 <20100405193616.GA5125@elte.hu>
 <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>
 <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com>
 <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
 <20100405232115.GM5825@random.random>
 <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 05, 2010 at 05:26:15PM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 6 Apr 2010, Andrea Arcangeli wrote:
> >
> > Some performance result:
> 
> Quite frankly, these "performance results" seem to be basically dishonest.
> 
> Judging by your numbers, the big win is apparently pre-populating the page 
> tables, the "tlb miss" you quote seem to be almost in the noise. IOW, we 
> have 
> 
> 	memset page fault 1566023
> 
> vs
> 
> 	memset page fault 2182476
> 
> looking like a major performance advantage, but then the actual usage is 
> much less noticeable.
> 
> IOW, how much of the performance advantage would we get from a _much_ 
> simpler patch to just much more aggressively pre-populate the page tables 
> (especially for just anonymous pages, I assume) or even just fault pages 
> in several at a time when you have lots of memory?

I had a prefaulting patch that also allocated an hugepage but only
mapped it with 2 ptes, 4 ptes, 8 ptes, up to 256ptes using a sysctl,
until the memset faulted in the rest and that triggered another chunk
of prefault on the reamining hugepage. In the end these weren't worth
it so I went stright with huge pmd immediately (even if initially I
worried about the more intensive clear-page in cow), which is hugely
simpler too and doesn't only provide a page fault advantage.

> In particular, when you quote 6% improvement for a kernel compile, your 

The memset test you mention above was run on host. The kernel compile
is run on guest with an unmodified guest kernel. The kernel compile
isn't mangling pagetables differently. The kernel compile is run on
two different host kernels: one running with transparent hugepages one
without, the guest kernel has no modifications at all. No page fault
ever happens in the host, only gcc runs in the guest in an unmodified
kernel that isn't using hugepages at all.

> own numbers make seriously wonder how many percentage points you'd get 
> from just faulting in 8 pages at a time when you have lots of memory free, 
> and use a single 3-order allocation to get those eight pages?
> 
> Would that already shrink the difference between those "memset page 
> faults" by a factor of eight?
> 
> See what I'm saying?  

I see what you're saying but that has nothing to do with the 6% boost.

In short I first measured the page fault improvement in host (~+50%
faster, sure that has nothing to do with pmd_huge or the tlb miss, I
said I mentioned it just for curiosity in fact), then measured the tlb
miss improvement in host (a few percent faster as usual with
hugetlbfs) then measured the boost in guest if host uses hugepages
(with no guest kernel change at all, just the tlb miss going faster in
guest and that boosts the guest kernel compile 6%) and then some other
test with dd with all combinations of host/guest using hugepages or
not, and also with dd run on bare metal with or without hugepages.

As said gcc is a sort of worst case, so you can assume any guest math
will run 6% faster or more in guest if the host runs with transparent
hugepages enabled (and there's memory compaction etc).

The page fault speedup is a "nice addon" that has nothing to do with
the kernel compile improvement because it was repeated many times and
the guest kernel memory was already faulted in before. I only wanted
to point it out "for curiosity" as I wrote in the prev email.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
