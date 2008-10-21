Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L2pELs019059
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 11:51:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EC38853C161
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 11:51:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C06A224005E
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 11:51:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A9A741DB803F
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 11:51:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 630E21DB803E
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 11:51:13 +0900 (JST)
Date: Tue, 21 Oct 2008 11:50:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
Message-Id: <20081021115048.2ca024b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830810201915g8af14fbg3de7a23a1409ef68@mail.gmail.com>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830810201829o5483ef48g633e920cce9cc015@mail.gmail.com>
	<20081021104932.5115a077.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830810201915g8af14fbg3de7a23a1409ef68@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 20 Oct 2008 19:15:37 -0700
"Paul Menage" <menage@google.com> wrote:

> On Mon, Oct 20, 2008 at 6:49 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > res_counter's operation is very short.
> >  take a lock => add and compare. => unlock.
> >
> > So, I wonder there is not enough runway to do prefetch.
> 
> Sorry, let me be clearer. I'm assuming that since a write operation on
> the base counter will generally be accompanied by a write operation on
> the aggregate counter, that one of the following is true:
> 
That's not true.  Mem+Swap contoller has following ops.

   charge:  page++
            compare page < mem_limit.
            compare page+swap < memsw_limit.
   unmap/cache delete:
            page--
   swapout:
            page--
            swap++
   swap_free:
            swap--

....there is no *aggregate* counter. just have limit of total.

But Ok, to get Ack, I'll have to do something.

2 coutner version will be..

   charge: page++   compare page < mem_limit.
           memsw++  counrare memsw < memsw_limit
   unmap/cache-delete:
           page--
   swapout:
           no change.
   swap_free:
           memsw--

No need for *aggregate* counter. just call charge twice.


> - neither cache line is in a M or E state in our cache. So the
> prefetchw on the aggregate counter proceeds in parallel to the stall
> on fetching the base counter, and there's no additional delay to
> access the aggregate counter.
> 


   CPU 0                CPU1
  prefetchw()
                      prefetchw()
  spinlock()
                      spinlock()
  win-spinlock
  cache-miss.
                      cache-miss.

Mem+Swap counter will rerely see this. But if you want to use aggregate counter
for parent/child, you'll see *prefetchw* is no help. 
parent is busier than child.

> - both cache lines are in a M or E state in our cache, so there are no
> misses on either counter.
>
But adds cost of unnecessary prefetch.


Maybe, I'll just use 2 res_coutnters. more updates will be done later if necessary.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
