Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 73A076B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 09:18:21 -0400 (EDT)
Date: Tue, 13 Apr 2010 15:17:05 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100413131705.GK5583@random.random>
References: <4BC0E556.30304@redhat.com>
 <4BC19663.8080001@redhat.com>
 <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
 <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu>
 <4BC1B034.4050302@redhat.com>
 <20100411115229.GB10952@elte.hu>
 <20100412042230.5d974e5d@infradead.org>
 <20100412133019.GZ5656@random.random>
 <20100413113825.GD19757@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100413113825.GD19757@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Arjan van de Ven <arjan@infradead.org>, Avi Kivity <avi@redhat.com>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 01:38:25PM +0200, Ingo Molnar wrote:
> 
> * Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > On Mon, Apr 12, 2010 at 04:22:30AM -0700, Arjan van de Ven wrote:
> > >
> > > Now hugepages have some interesting other advantages, namely they save 
> > > pagetable memory..which for something like TPC-C on a fork based database 
> > > can be a measureable win.
> > 
> > It doesn't save pagetable memory (as in `grep MemFree /proc/meminfo`). [...]
> 
> It does save in terms of CPU cache footprint. (which the argument was about) 
> The RAM is wasted, but are always cache cold.

Definitely, thanks for further clarifying this, and this is why I've
been careful to specify "as in `grep MemFree..".

> i think it's very much interesting for 'pure' hugetlb mappings, as a next-step 
> thing. It amounts to 8 bytes wasted per 4K page [0.2% of RAM wasted] - much 
> more with the kind of aliasing that DBs frequently do - for hugetlb workloads 
> it is basically roughly equivalent to a +8 bytes increase in struct page size 
> - few MM hackers would accept that.
> 
> So it will have to be fixed down the line.

It's exactly 4k wasted for each pmd set as pmd_trans_huge. Removing
the pagetable preallocation will be absolutely trivial as far as
huge_memory.c is concerned (takes like 1 minute of hacking) and in
fact it simplifies a bit of the code, what will be not trivial will be
to handle the -ENOMEM retval from every place that calls
split_huge_page_pmd, which definitely we can address down the line
(ideally by removing split_huge_page_pmd). The other benefit the
current preallocation provides, is that it doesn't increase
requirements from the PF_MEMALLOC pool, until we can swap hugepages
natively with huge-swapcache, in order to swap we need to allocate the
pte.

Who tried this before (Dave IIRC) answered some email ago that he also
had to preallocate the pte to avoid running into the above issue. When
he said that, it further confirmed me that it's worth to go this way
initially. Also note: we're not wasting memory compared to when pmd is
not huge, we just don't take advantage of the full potential of
hugepages to keep things more manageable initially.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
