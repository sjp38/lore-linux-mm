Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8911B6B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 03:19:51 -0400 (EDT)
Date: Mon, 12 Apr 2010 09:18:56 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412071856.GE5656@random.random>
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
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 09:36:23AM +0300, Avi Kivity wrote:
> On 04/12/2010 09:09 AM, Nick Piggin wrote:
> > On Sun, Apr 11, 2010 at 02:08:00PM +0200, Ingo Molnar wrote:
> >    
> >> * Avi Kivity<avi@redhat.com>  wrote:
> >>
> >> 3) futility
> >>
> >> I think Andrea and Mel and you demonstrated that while defrag is futile in
> >> theory (we can always fill up all of RAM with dentries and there's no 2MB
> >> allocation possible), it seems rather usable in practice.
> >>      
> > One problem is that you need to keep a lot more memory free in order
> > for it to be reasonably effective.
> 
> It's the usual space-time tradeoff.  You don't want to do it on a 
> netbook, but it's worth it on a 16GB server, which is already not very 
> high end.

Agreed. BTW, if booting with transparent_hugepage=0,
set_recommended_min_free_kbyte in-kernel logic won't run automatically
during the late_initcall invocation.

> Non-linear kernel mapping moves the small page problem from userspace 
> back to the kernel, a really unhappy solution.

Yeah, so we have hugepages in userland but we lose them in kernel ;)
and we run kmalloc as slow as vmalloc ;). I think kernelcore= here is
the answer when somebody asks the math guarantee. We should just focus
on providing a math guarantee with kernelcore= and be done with it.

Limiting the unmovable caches to a certain amount of RAM is orders of
magnitude magnitude more flexible and transparent (and absolutely
unnoticeable) than having to limit only hugepages (so unusable as
regular anon memory, or regular pagecache, or any other movable
entitiy) to a certain amount at boot (plus not being able to swap
them, having to mount filesystems, using LD_PRELOAD tricks
etc...). Furthermore with hypervisor usage the unmovable stuff really
isn't a big deal (1G is more than enough for that even on monster
servers) and we'll never care or risk to hit on the limit. All we need
is the movable memory to grow freely and dynamically and being able to
spread all over the RAM of the system automatically as needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
