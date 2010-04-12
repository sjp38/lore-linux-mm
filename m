Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 079E86B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 03:09:10 -0400 (EDT)
Date: Mon, 12 Apr 2010 09:08:11 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412070811.GD5656@random.random>
References: <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412060931.GP5683@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 04:09:31PM +1000, Nick Piggin wrote:
> One problem is that you need to keep a lot more memory free in order
> for it to be reasonably effective. Another thing is that the problem
> of fragmentation breakdown is not just a one-shot event that fills
> memory with pinned objects. It is a slow degredation.

set_recommended_min_free_kbytes seems to not be in function of ram
size, 60MB aren't such a big deal.

> Especially when you use something like SLUB as the memory allocator
> which requires higher order allocations for objects which are pinned
> in kernel memory.
> 
> Just running a few minutes of testing with a kernel compile in the
> background does not show the full picture. You really need a box that
> has been up for days running a proper workload before you are likely
> to see any breakdown.
> 
> I'm sure it's horrible for planning if the RDBMS or VM boxes gradually
> get slower after X days of uptime. It's better to have consistent
> performance really, for anything except pure benchmark setups.

All data I provided is very real, in addition to building a ton of
packages and running emerge on /usr/portage I've been running all my
real loads. Only problem I only run it for 1 day and half, but the
load I kept it under was significant (surely a lot bigger inode/dentry
load that any hypervisor usage would ever generate).

> Defrag is not futile in theory, you just have to either have a reserve
> of movable pages (and never allow pinned kernel pages in there), or
> you need to allocate pinned kernel memory in units of the chunk size
> goal (which just gives you different types of fragmentation problems)
> or you need to do non-linear kernel mappings so you can defrag pinned
> kernel memory (with *lots* of other problems of course). So you just
> have a lot of downsides.

That's what the kernelcore= option does no? Isn't that a good enough
math guarantee? Probably we should use it in hypervisor products just
in case, to be math-guaranted to never have to use VM migration as
fallback (but definitive) defrag algorithm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
