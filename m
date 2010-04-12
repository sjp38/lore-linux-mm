Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 134A56B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 02:48:58 -0400 (EDT)
Date: Mon, 12 Apr 2010 16:48:51 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412064850.GQ5683@laptop>
References: <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <r2j84144f021004112318v78f28c3ds46531d1233966a20@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <r2j84144f021004112318v78f28c3ds46531d1233966a20@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 09:18:56AM +0300, Pekka Enberg wrote:
> On Mon, Apr 12, 2010 at 9:09 AM, Nick Piggin <npiggin@suse.de> wrote:
> >> I think Andrea and Mel and you demonstrated that while defrag is futile in
> >> theory (we can always fill up all of RAM with dentries and there's no 2MB
> >> allocation possible), it seems rather usable in practice.
> >
> > One problem is that you need to keep a lot more memory free in order
> > for it to be reasonably effective. Another thing is that the problem
> > of fragmentation breakdown is not just a one-shot event that fills
> > memory with pinned objects. It is a slow degredation.
> >
> > Especially when you use something like SLUB as the memory allocator
> > which requires higher order allocations for objects which are pinned
> > in kernel memory.
> 
> I guess we'd need to merge the SLUB defragmentation patches to fix that?

No that's a different problem. And SLUB 'defragmentation' isn't really
defragmentation, it is just selective reclaim.

Reclaimable slab memory allocations are not the problem. The problem are
the ones that you can't reclaim. The problem is this:

- Memory gets fragmented by allocation of pinned pages within larger
  ranges so that we cannot allocate that large range.

- Anti-frag improves this by putting pinned pages in different ranges
  and unpinned pages in different ranges. So the ranges of unpinned
  pages can get reclaimed to use a larger range.

- However there is still an underlying problem of pinned pages causing
  fragmentation within their ranges.

- If you require higher order allocations for pinned pages especially,
  then you will end up with your pinned ranges becoming fragmented and
  unable to satisfy the higher order allocation. So you must expand your
  pinned ranges into unpinned.

If you only do 4K slab allocations, then things get better, however it
can of course still break down if the pinned allocation requirement
grows large. It's really hard to control this because it includes
anything from open files to radix tree nodes to page tables and anything
that any driver or subsystem allocates with kmalloc.

Basically, if you were going to add another level of indirection to
solve that, you may as well just go ahead and do nonlinear mappings of
the kernel memory with page tables, so you'd only have to fix up places
that require translated addresses rather than everything that touches
KVA. This would still be a big headache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
