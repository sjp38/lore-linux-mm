Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7ED896B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 05:02:16 -0400 (EDT)
Date: Mon, 12 Apr 2010 11:01:21 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412090121.GK5656@random.random>
References: <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <4BC2BF67.80903@redhat.com>
 <20100412071525.GR5683@laptop>
 <4BC2CF8C.5090108@redhat.com>
 <20100412082844.GU5683@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412082844.GU5683@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 06:28:44PM +1000, Nick Piggin wrote:
> If virtualization is the main worry (which it seems that it is
> seeing as your TLB misses cost like 6 times more cachelines),
> then complexity should be pushed into the hypervisor, not the
> core kernel.

It's not just about virtualization on host, or I could have done a
much smaller patch without bothering so much to make something as
universal as possible with cows and stuff.

Also about virtualization you forget that the CPU can establish 2M tlb
entries in guest only if both the guest and the host shadow pagetables
are both pmd_huge, if one of the two pmd isn't huge then the guest
virtual to host physical translation won't be the same for all 512 4k
pages (well it might be if you're extremely lucky but I strongly doubt
the CPU bothers to check the host pfns are contiguous if both guest pmd
and shadow pmd aren't huge).

In other words we've to do something that is totally disconnected from
virtualization, in order to advantage of it to the maximum extent with
virt ;).

This allows to leverage the KVM design compared to vmware or and the
other inferior virtualization designs. We make gcc run 8% faster on a
cheap single socket workstation without virt, and we get even bigger
cumulative boost in virtualized gcc without changing anything at all
in KVM. If this isn't the obvious best way to go, I don't know what it
is! ;)

> And that involves auditing and rewriting anything that allocates
> and pins kernel memory. It's not only dentries.

All not short lived gup pins have to use mmu notifier, no piece of the
kernel is allowed to keep movable pages pinned for more than the time
it takes to complete the DMA. It has to be fixed to provide all other
benefits with GRU, XPMEM now that VM locks are switching to mutex (and
as usual to KVM too).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
