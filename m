Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1BE126B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 03:15:39 -0400 (EDT)
Date: Mon, 12 Apr 2010 17:15:25 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412071525.GR5683@laptop>
References: <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <4BC2BF67.80903@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC2BF67.80903@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 09:36:23AM +0300, Avi Kivity wrote:
> On 04/12/2010 09:09 AM, Nick Piggin wrote:
> >On Sun, Apr 11, 2010 at 02:08:00PM +0200, Ingo Molnar wrote:
> >>* Avi Kivity<avi@redhat.com>  wrote:
> >>
> >>3) futility
> >>
> >>I think Andrea and Mel and you demonstrated that while defrag is futile in
> >>theory (we can always fill up all of RAM with dentries and there's no 2MB
> >>allocation possible), it seems rather usable in practice.
> >One problem is that you need to keep a lot more memory free in order
> >for it to be reasonably effective.
> 
> It's the usual space-time tradeoff.  You don't want to do it on a
> netbook, but it's worth it on a 16GB server, which is already not
> very high end.

Possibly.

 
> >Another thing is that the problem
> >of fragmentation breakdown is not just a one-shot event that fills
> >memory with pinned objects. It is a slow degredation.
> >
> >Especially when you use something like SLUB as the memory allocator
> >which requires higher order allocations for objects which are pinned
> >in kernel memory.
> 
> Won't the usual antifrag tactics apply?  Try to allocate those
> objects from the same block.

"try" is the key point.

 
> >Just running a few minutes of testing with a kernel compile in the
> >background does not show the full picture. You really need a box that
> >has been up for days running a proper workload before you are likely
> >to see any breakdown.
> 
> I'm sure we'll be able to generate worst-case scenarios.  I'm also
> reasonably sure we'll be able to deal with them.  I hope we won't
> need to, but it's even possible to move dentries around.

Pinned dentries? (which are the problem) That would be insane.

 
> >I'm sure it's horrible for planning if the RDBMS or VM boxes gradually
> >get slower after X days of uptime. It's better to have consistent
> >performance really, for anything except pure benchmark setups.
> 
> If that were the case we'd disable caches everywhere.  General

No we wouldn't. You can have consistent, predictable performance with
caches.

> purpose computing is a best effort thing, we try to be fast on the
> common case but we'll be slow on the uncommon case.  Access to a bit

Sure. And the common case for production systems like VM or databse
servers that are up for hundreds of days is when they are running with
a lot of uptime. Common case is not a fresh reboot into a 3 hour
benchmark setup.


> of memory can take 3 ns if it's in cache, 100 ns if not, and 3 ms if
> it's on disk.
> 
> Here, the uncommon case will be really uncommon, most applications
> (that can benefit from large pages) I'm aware of don't switch from
> large anonymous working sets to a dcache load of many tiny files.
> They tend to keep doing the same thing over and over again.
> 
> I'm not saying we don't need to adapt to changing conditions (we do,
> especially for kvm, that's what khugepaged is for), but as long as
> we have a graceful fallback, we don't need to worry too much about
> failure in extreme conditions.
> 
> >Defrag is not futile in theory, you just have to either have a reserve
> >of movable pages (and never allow pinned kernel pages in there), or
> >you need to allocate pinned kernel memory in units of the chunk size
> >goal (which just gives you different types of fragmentation problems)
> >or you need to do non-linear kernel mappings so you can defrag pinned
> >kernel memory (with *lots* of other problems of course). So you just
> >have a lot of downsides.
> 
> Non-linear kernel mapping moves the small page problem from
> userspace back to the kernel, a really unhappy solution.

Not unhappy for userspace intensive workloads. And user working sets
I'm sure are growing faster than kernel working set. Also there would
be nothing against compacting and merging kernel memory into larger
pages.


> Very large (object count, not object size) kernel caches can be
> addressed by compacting them, but I hope we won't need to do that.

You can't say that fragmentation is not a fundamental problem.  And
adding things like indirect pointers or weird crap adding complexity
to code that deals with KVA IMO is not acceptable. So you can't
just assert that you can "address" the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
