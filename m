Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L345YT024205
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 12:04:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 49AC82AC026
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 12:04:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C00912C0A7
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 12:04:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EE9711DB8037
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 12:04:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A541F1DB803B
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 12:04:01 +0900 (JST)
Date: Tue, 21 Oct 2008 12:03:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
Message-Id: <20081021120336.07acb54f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830810201920j4452c304ub34bc77d22afb436@mail.gmail.com>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830810201829o5483ef48g633e920cce9cc015@mail.gmail.com>
	<20081021104932.5115a077.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830810201920j4452c304ub34bc77d22afb436@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 20 Oct 2008 19:20:16 -0700
"Paul Menage" <menage@google.com> wrote:

> On Mon, Oct 20, 2008 at 6:49 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > If you give me NACK, maybe I have to try that..
> > (But I believe aggregated child-parent counter will be verrrry slow.)
> 
> If it's really impossible to implement the aggregated version without
> a significant performance hit then that might be a reason to have a
> separate counter class. But I'd rather have a clean generic solution
> if we can manage it.
> 
I think we can't do without performance hit. Considering parent<->child counter,
parent is busier than child if usage is propergated from child to parent. So,
prefetch will be just a smal help.

> > BTW, can we have *unsigned long* version of res_counter ?
> > memcg doesn't need *unsigned long long*.
> 
> Potentially - but how often is a read-only operation on the
> performance sensitive path? Don't most fast-path operations that
> involve a res_counter have an update on the res_counter when they
> succeed? In which case you have to pull the cache line into a Modified
> state anyway.
>
I don't like *unsigned long long* just because we have to do following
=
   res->usage < *some number*
=
or
=
   val = res->usage.
=
always under lock because usage is unsigned long long.

> >
> > And as another discussion, I'd like optimize res_counter by per_cpu.
> 
> What were you thinking of doing for this?
> 
just an idea. I believe a process has locality to a res_counter.

==
  struct res_counter_cache {
	unsigned long cache;
	struct res_counter	*res;
  }
  DEFINE_PER_CPU(res_counter_cache, pcp_memcg_res);

  res_counter_charge(struct res_counter *res, struct res_counter_cache *cache, num)
  {
	if (cache->res == res && cache->res >= num) {
		cache->cache -= num;
		return 0;
	} else if (cache->res != res) {
		/* forget cache */
		spin_lock(cache->res);
		cache->res->usage -= cache->cache;
		cache->cache = NULL;
		spin_unlock(cache->res);
  	}
        ....
	cache->cache = res;
  }
  ....
==

But not have a fragile of code.

Thanks,
-Kame













--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
