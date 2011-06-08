Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 105646B00E7
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 05:27:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E95D43EE0BD
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 18:26:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 70AB345DED5
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 18:26:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D33E45DED0
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 18:26:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DA5A1DB8041
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 18:26:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FC7D1DB802F
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 18:26:57 +0900 (JST)
Date: Wed, 8 Jun 2011 18:20:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix behavior of per cpu charge cache
 draining.
Message-Id: <20110608182003.1ca11db0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110608091510.GB6742@tiehlicka.suse.cz>
References: <20110608140518.0cd9f791.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608144934.b5944a64.nishimura@mxp.nes.nec.co.jp>
	<20110608152901.f16b3e59.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608091510.GB6742@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>

On Wed, 8 Jun 2011 11:15:11 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 08-06-11 15:29:01, KAMEZAWA Hiroyuki wrote:
> > On Wed, 8 Jun 2011 14:49:34 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > I have a few minor comments.
> > > 
> > > On Wed, 8 Jun 2011 14:05:18 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > This patch is made against mainline git tree.
> > > > ==
> > > > From d1372da4d3c6f8051b5b1cf7b5e8b45a8094b388 Mon Sep 17 00:00:00 2001
> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > Date: Wed, 8 Jun 2011 13:51:11 +0900
> > > > Subject: [BUGFIX][PATCH] memcg: fix behavior of per cpu charge cache draining.
> > > > 
> > > > For performance, memory cgroup caches some "charge" from res_counter
> > > > into per cpu cache. This works well but because it's cache,
> > > > it needs to be flushed in some cases. Typical cases are
> > > > 	1. when someone hit limit.
> > > > 	2. when rmdir() is called and need to charges to be 0.
> > > > 
> > > > But "1" has problem.
> > > > 
> > > > Recently, with large SMP machines, we see many kworker/%d:%d when
> > > > memcg hit limit. It is because of flushing memcg's percpu cache. 
> > > > Bad things in implementation are
> > > > 
> > > > a) it's called before calling try_to_free_mem_cgroup_pages()
> > > >    so, it's called immidiately when a task hit limit.
> > > >    (I thought it was better to avoid to run into memory reclaim.
> > > >     But it was wrong decision.)
> > > > 
> > > > b) Even if a cpu contains a cache for memcg not related to
> > > >    a memcg which hits limit, drain code is called.
> > > > 
> > > > This patch fixes a) and b) by
> > > > 
> > > > A) delay calling of flushing until one run of try_to_free...
> > > >    Then, the number of calling is much decreased.
> > > > B) check percpu cache contains a useful data or not.
> > > > plus
> > > > C) check asynchronous percpu draining doesn't run on the cpu.
> > > > 
> > > > Reported-by: Ying Han <yinghan@google.com>
> > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Looks good to me.
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> 
> One minor note though. 
> AFAICS we can end up having CHARGE_BATCH * (NR_ONLINE_CPU) pages pre-charged
> for a group which would be freed by drain_all_stock_async so we could get
> under the limit and so we could omit direct reclaim, or?

If drain_all_stock_async flushes charges, we go under limit and skip
direct reclaim. yes. It was my initial thought. But in recent test while
we do for keep-margin or some other, we saw too much kworkers/%d:%d.

Then, What I think now is....

 1. if memory can be reclaimed easily, the cost of calling kworker is very bad.
 2. if memory reclaim cost is too high, the benefit of flushing per-cpu
    cache is very low.

In future, situation will be much better.

 a. Our test shows async shrinker for keep-margin will reduce memory
    effectively and process will not dive into direct reclaim because of limit
    in not-very-havy workload.
 b. dirty-ratio will stop very-heavy-workload before reclaim is troublesome.

Hmm,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
