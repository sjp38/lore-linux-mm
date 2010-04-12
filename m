Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A31496B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 02:10:00 -0400 (EDT)
Date: Mon, 12 Apr 2010 16:09:31 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412060931.GP5683@laptop>
References: <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100411120800.GC10952@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 11, 2010 at 02:08:00PM +0200, Ingo Molnar wrote:
> 
> * Avi Kivity <avi@redhat.com> wrote:
> 
> 3) futility
> 
> I think Andrea and Mel and you demonstrated that while defrag is futile in 
> theory (we can always fill up all of RAM with dentries and there's no 2MB 
> allocation possible), it seems rather usable in practice.

One problem is that you need to keep a lot more memory free in order
for it to be reasonably effective. Another thing is that the problem
of fragmentation breakdown is not just a one-shot event that fills
memory with pinned objects. It is a slow degredation.

Especially when you use something like SLUB as the memory allocator
which requires higher order allocations for objects which are pinned
in kernel memory.

Just running a few minutes of testing with a kernel compile in the
background does not show the full picture. You really need a box that
has been up for days running a proper workload before you are likely
to see any breakdown.

I'm sure it's horrible for planning if the RDBMS or VM boxes gradually
get slower after X days of uptime. It's better to have consistent
performance really, for anything except pure benchmark setups.

Defrag is not futile in theory, you just have to either have a reserve
of movable pages (and never allow pinned kernel pages in there), or
you need to allocate pinned kernel memory in units of the chunk size
goal (which just gives you different types of fragmentation problems)
or you need to do non-linear kernel mappings so you can defrag pinned
kernel memory (with *lots* of other problems of course). So you just
have a lot of downsides.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
