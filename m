Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A21386B01E3
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 01:19:18 -0400 (EDT)
Date: Thu, 15 Apr 2010 13:19:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: 32GB SSD on USB1.1 P3/700 == ___HELL___ (2.6.34-rc3)
Message-ID: <20100415051911.GA17110@localhost>
References: <20100415132312.D180.A69D9226@jp.fujitsu.com> <20100415044111.GA15682@localhost> <20100415135031.D186.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415135031.D186.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andreas Mohr <andi@lisas.de>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 12:55:30PM +0800, KOSAKI Motohiro wrote:
> > On Thu, Apr 15, 2010 at 12:32:50PM +0800, KOSAKI Motohiro wrote:
> > > > On Thu, Apr 15, 2010 at 11:31:52AM +0800, KOSAKI Motohiro wrote:
> > > > > > > Many applications (this one and below) are stuck in
> > > > > > > wait_on_page_writeback(). I guess this is why "heavy write to
> > > > > > > irrelevant partition stalls the whole system".  They are stuck on page
> > > > > > > allocation. Your 512MB system memory is a bit tight, so reclaim
> > > > > > > pressure is a bit high, which triggers the wait-on-writeback logic.
> > > > > > 
> > > > > > I wonder if this hacking patch may help.
> > > > > > 
> > > > > > When creating 300MB dirty file with dd, it is creating continuous
> > > > > > region of hard-to-reclaim pages in the LRU list. priority can easily
> > > > > > go low when irrelevant applications' direct reclaim run into these
> > > > > > regions..
> > > > > 
> > > > > Sorry I'm confused not. can you please tell us more detail explanation?
> > > > > Why did lumpy reclaim cause OOM? lumpy reclaim might cause
> > > > > direct reclaim slow down. but IIUC it's not cause OOM because OOM is
> > > > > only occur when priority-0 reclaim failure.
> > > > 
> > > > No I'm not talking OOM. Nor lumpy reclaim.
> > > > 
> > > > I mean the direct reclaim can get stuck for long time, when we do
> > > > wait_on_page_writeback() on lumpy_reclaim=1.
> > > > 
> > > > > IO get stcking also prevent priority reach to 0.
> > > > 
> > > > Sure. But we can wait for IO a bit later -- after scanning 1/64 LRU
> > > > (the below patch) instead of the current 1/1024.
> > > > 
> > > > In Andreas' case, 512MB/1024 = 512KB, this is way too low comparing to
> > > > the 22MB writeback pages. There can easily be a continuous range of
> > > > 512KB dirty/writeback pages in the LRU, which will trigger the wait
> > > > logic.
> > > 
> > > In my feeling from your explanation, we need auto adjustment mechanism
> > > instead change default value for special machine. no?
> > 
> > You mean the dumb DEF_PRIORITY/2 may be too large for a 1TB memory box?
> > 
> > However for such boxes, whether it be DEF_PRIORITY-2 or DEF_PRIORITY/2
> > shall be irrelevant: it's trivial anyway to reclaim an order-1 or
> > order-2 page. In other word, lumpy_reclaim will hardly go 1.  Do you
> > think so?
> 
> If my remember is correct, Its order-1 lumpy reclaim was introduced
> for solving such big box + AIM7 workload made kernel stack (order-1 page)
> allocation failure.
> 
> Now, We are living on moore's law. so probably we need to pay attention
> scalability always. today's big box is going to become desktop box after
> 3-5 years.
> 
> Probably, Lee know such problem than me. cc to him.

In Andreas' trace, the processes are blocked in
- do_fork:              console-kit-d
- __alloc_skb:          x-terminal-em, konqueror
- handle_mm_fault:      tclsh
- filemap_fault:        ls

I'm a bit confused by the last one, and wonder what's the typical
gfp order of __alloc_skb().

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
