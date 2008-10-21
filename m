Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L1nwnJ024751
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 10:49:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 27CA82AC026
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 10:49:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 002D312C044
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 10:49:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C3E6E1DB803F
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 10:49:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 67B531DB8043
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 10:49:57 +0900 (JST)
Date: Tue, 21 Oct 2008 10:49:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
Message-Id: <20081021104932.5115a077.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830810201829o5483ef48g633e920cce9cc015@mail.gmail.com>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830810201829o5483ef48g633e920cce9cc015@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 20 Oct 2008 18:29:28 -0700
"Paul Menage" <menage@google.com> wrote:
> How bad would things really be if you did something like the code below?
> 
> if (charge_swap()) {
>   uncharge_mem();
> } else {
>   return -ENOMEM;
> }
Nitpick, charge_swap() has to always succeed (because mem+swap counter.
So,

  BUG_ON(charge_swap());
or
  charge_swap_and_uncharge_mem();

is necessary. Swap itself has no limit.

> > 3. We want to pack all member into a cache-line, multiple res_counter
> >   is no good.
> 
> As I said previously, if we do a prefetch on the aggregated
> res_counter before we touch any fields in the basic counter, then in
> theory we should never have to wait on a cache miss on the aggregated
> counter - either we have no misses (if both were in cache) or we fetch
> both lines concurrently (if neither were in cache). Do you think that
> reasoning is invalid?

res_counter's operation is very short.
  take a lock => add and compare. => unlock.

So, I wonder there is not enough runway to do prefetch.
(Considering memcg, we can place 2 counters on a cacheline that by putting 2
 counters on aligned line.)


> >
> >> Maybe have an "aggregate" pointer in a res_counter that points to
> >> another res_counter that sums some number of counters; both the mem
> >> and the swap res_counter objects for a cgroup would point to the
> >> mem+swap res_counter for their aggregate. Adjusting the usage of a
> >> counter would also adjust its aggregate (or fail if adjusting the
> >> aggregate failed).
> >>
> > It's complicated.
> 
> Agreed, it's a bit more complicated than defining a new structure and
> code that's very reminiscent of res_counter. But it does solve the
> problem of aggregating across multiple resource types and multiple
> children in a generic way.
> 
If you give me NACK, maybe I have to try that..
(But I believe aggregated child-parent counter will be verrrry slow.)
 
BTW, can we have *unsigned long* version of res_counter ?
memcg doesn't need *unsigned long long*.

And as another discussion, I'd like optimize res_counter by per_cpu.
This will be impossible with counters tied by pointer.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
