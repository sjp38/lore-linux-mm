Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6A25C6B008C
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 21:19:14 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB82JBUc026905
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Dec 2010 11:19:11 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D5CF2E68C2
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 11:19:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4261B1EF083
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 11:19:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B355E08004
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 11:19:11 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E24EAE08001
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 11:19:10 +0900 (JST)
Date: Wed, 8 Dec 2010 11:13:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101208111329.ad0a8dca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikXO1YxzX2PJyKobeb=Cg_EhTVW9-pBFnPE9dYh@mail.gmail.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101207123308.GD5422@csn.ul.ie>
	<AANLkTimzL_CwLruzPspgmOk4OJU8M7dXycUyHmhW2s9O@mail.gmail.com>
	<20101208093948.1b3b64c5.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTin+p5WnLjMkr8Qntkt4fR1+fdY=t6hkvV6G8Mok@mail.gmail.com>
	<20101208102812.5b93c1bc.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikXO1YxzX2PJyKobeb=Cg_EhTVW9-pBFnPE9dYh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Dec 2010 18:10:11 -0800
Ying Han <yinghan@google.com> wrote:

> >
> >> I haven't measured the lock contention and cputime for each kswapd
> >> running. Theoretically it would be a problem
> >> if thousands of cgroups are configured on the the host and all of them
> >> are under memory pressure.
> >>
> > I think that's a configuration mistake.
> >
> >> We can either optimize the locking or make each kswapd smarter (hold
> >> the lock less time). My current plan is to have the
> >> one-kswapd-per-cgroup on the V2 patch w/ select_victim_node, and the
> >> optimization for this comes as following patchset.
> >>
> >
> > My point above is holding remove node's lock, touching remote node's page
> > increases memory reclaim cost very much. Then, I like per-node approach.
> 
> So in a case of one physical node and thousands of cgroups, we are
> queuing all the works into single kswapd
> which is doing the global background reclaim as well. This could be a
> problem on a multi-core system where
> all the cgroups queuing behind the current work being throttle which
> might not be necessary.

percpu thread is enough. And there is direct reclaim, absense of kswapd
will not be critical (because memcg doesn't need 'zone balancing').
And as you said, 'usual' users will not use 100+ cgroups. Queueing will
not be fatal, I think.

> 
> I am not sure which way is better at this point. I would like to keep
> the current implementation for the next post V2
> since smaller changes between versions sounds better to me.
> 
yes, please go ahread. I'm not against the functionality itself.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
